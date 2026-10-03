extends CharacterBody2D
class_name Player

enum PlayerMode { SMALL, BIG, SHOOTING }

signal points_scored(points: int)

@onready var animated_sprite_2d: PlayerAnimatedSprite = $AnimatedSprite2D
@onready var area_2d: Area2D = $Area2D
@onready var win_screen = get_node_or_null("/root/Level_1/Win_screen")

# --- MOVIMENTO ---
@export var speed := 200.0
@export var run_speed_damping := 0.5
@export var jump_velocity := -400.0
@export var gravity := 1200.0

# --- STOMP ---
@export var stomp_y_velocity := -150

# --- ESTADO ---
var is_dead := false
var reached_goal := false
var player_mode: PlayerMode = PlayerMode.BIG  # 👈 agora começa como BIG
var direction := 1.0
var score := 0

# --- PRELOAD DE INIMIGOS ---
const ENEMY_SCRIPT = preload("res://Enemy.gd")
const KOOPA_SCRIPT = preload("res://Koopa.gd")  # se existir

# --- REFERÊNCIA DO GOAL ---
var goal_node: Node = null

func _ready():
	add_to_group("player")

	# Conecta moedas do grupo "coins"
	for coin in get_tree().get_nodes_in_group("coins"):
		if not coin.is_connected("collected", Callable(self, "_on_coin_collected")):
			coin.connect("collected", Callable(self, "_on_coin_collected"))

	# Conecta goals do grupo "goals" e guarda referência
	for goal in get_tree().get_nodes_in_group("goals"):
		if not goal.is_connected("body_entered", Callable(self, "_on_goal_body_entered")):
			goal.connect("body_entered", Callable(self, "_on_goal_body_entered"))
		goal_node = goal  # guarda a referência

	# Conecta colisão com área do player
	if area_2d and not area_2d.is_connected("area_entered", Callable(self, "_on_area_2d_area_entered")):
		area_2d.connect("area_entered", Callable(self, "_on_area_2d_area_entered"))

# --- PHYSICS PROCESS ---
func _physics_process(delta):
	if is_dead or reached_goal:
		return

	var input_dir := Input.get_axis("left", "right")

	if input_dir != 0:
		direction = sign(input_dir)
		velocity.x = lerp(velocity.x, speed * input_dir, run_speed_damping * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, speed * delta)

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	elif Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5

	move_and_slide()

	if animated_sprite_2d:
		animated_sprite_2d.trigger_animation(velocity, direction, player_mode)

# --- COLISÃO COM INIMIGOS ---
func _on_area_2d_area_entered(area: Area2D) -> void:
	var enemy_node = area.get_parent()
	if not is_instance_valid(enemy_node):
		return

	if enemy_node.get_script() == ENEMY_SCRIPT:
		handle_enemy_collision(enemy_node)
	elif enemy_node.get_script() == KOOPA_SCRIPT:
		handle_enemy_collision(enemy_node)

func handle_enemy_collision(enemy) -> void:
	if is_dead:
		return

	var is_stomping = global_position.y + 5 < enemy.global_position.y

	if enemy.get_script() == KOOPA_SCRIPT and enemy.in_a_shell:
		enemy.on_stomp(global_position)
		return

	if is_stomping:
		enemy.die()
		on_enemy_stomped()
		_on_coin_collected(100)
	else:
		die()

func on_enemy_stomped():
	velocity.y = stomp_y_velocity

# --- COLETA DE MOEDAS ---
func _on_coin_collected(_points: int) -> void:
	if is_dead or reached_goal:
		return

	if animated_sprite_2d and animated_sprite_2d.has_animation("coin_collect"):
		animated_sprite_2d.play("coin_collect")

	if has_node("CoinSound"):
		$CoinSound.play()

	emit_signal("points_scored", _points)

	if goal_node and goal_node.is_valid():
		var remaining_coins = get_tree().get_nodes_in_group("coins").size()
		if remaining_coins == 0:
			goal_node.set_meta("liberado", true)
			print("✅ Todas as moedas coletadas! Goal liberado.")

# --- MORTE ---
func die():
	if is_dead:
		return

	is_dead = true
	if animated_sprite_2d:
		animated_sprite_2d.play("small_death")

	set_physics_process(false)

	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", position + Vector2(0, -48), 0.5)
	tween.chain().tween_property(self, "position", position + Vector2(0, 256), 1.0)
	tween.tween_callback(func(): get_tree().reload_current_scene())

# --- GOAL ---
func _on_goal_body_entered(body):
	if body == self:
		reached_goal = true
		set_physics_process(false)
		print("🏁 Você chegou ao goal!")

		if win_screen:
			win_screen.visible = true
