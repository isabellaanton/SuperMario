extends Enemy
class_name Koopa

const KOOPA_FULL_SHAPE = preload("res://Resources/CollisionShapes/koopa_full.tres")
const KOOPA_SHELL_SHAPE = preload("res://Resources/CollisionShapes/koopa_shell.tres")
const KOOPA_SHELL_POSITION = Vector2(0, 5)

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var stomp_area: Area2D = $StompArea
@onready var notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

@export var slide_speed: float = 200.0

var in_a_shell: bool = false
var sliding: bool = false

func _ready():
	collision_shape_2d.shape = KOOPA_FULL_SHAPE
	if stomp_area:
		stomp_area.body_entered.connect(_on_stomp_area_body_entered)
	if notifier:
		notifier.screen_exited.connect(_on_screen_exited)

# ------------------------------
# ⚔️ Lógica de morte / transformação
# ------------------------------
func die():
	if !in_a_shell:
		super.die()
		collision_shape_2d.set_deferred("shape", KOOPA_SHELL_SHAPE)
		collision_shape_2d.set_deferred("position", KOOPA_SHELL_POSITION)
		in_a_shell = true
		sliding = false
	else:
		queue_free()  # já estava no casco, morre de vez

# ------------------------------
# 👟 Player pisa em cima (stomp)
# ------------------------------
func _on_stomp_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.velocity.y > 0 and body.global_position.y < global_position.y - 8:
			if not in_a_shell:
				die()  # vira casco
			else:
				# já está no casco → desliza na direção oposta do player
				var direction = sign(global_position.x - body.global_position.x)
				start_sliding(direction)
			body.velocity.y = body.jump_velocity * 0.6
		else:
			body.die()

# ------------------------------
# 💨 Inicia deslizamento do casco
# ------------------------------
func start_sliding(direction: float) -> void:
	sliding = true
	horizontal_speed = direction * slide_speed
	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)
	set_collision_layer_value(4, true)

func _physics_process(delta: float) -> void:
	if sliding:
		global_position.x += horizontal_speed * delta

# ------------------------------
# 🧨 Colisão genérica com Player
# ------------------------------
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		area.die()

# ------------------------------
# 🚮 Saiu da tela -> remove
# ------------------------------
func _on_screen_exited() -> void:
	queue_free()
