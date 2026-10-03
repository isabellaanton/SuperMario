extends Area2D
class_name Enemy

const POINTS_LABEL_SCENE = preload("res://points_label.tscn")
const PLAYER_SCRIPT = preload("res://Player.gd")

@export var horizontal_speed := 20
@export var vertical_speed := 100

@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var is_dead := false

func _process(delta: float) -> void:
	if is_dead:
		return

	position.x -= horizontal_speed * delta

	if ray_cast_2d and not ray_cast_2d.is_colliding():
		position.y += vertical_speed * delta

# ------------------------------
# 💀 Morte padrão
# ------------------------------
func die() -> void:
	if is_dead:
		return
	is_dead = true

	horizontal_speed = 0
	vertical_speed = 0

	if animated_sprite_2d and animated_sprite_2d.sprite_frames and animated_sprite_2d.sprite_frames.has_animation("dead"):
		animated_sprite_2d.play("dead")

	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)

	var timer := get_tree().create_timer(0.5)
	timer.timeout.connect(queue_free)

# ------------------------------
# 💨 Morte lançada (atingido por casco)
# ------------------------------
func die_from_hit() -> void:
	if is_dead:
		return
	is_dead = true

	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)

	var tween := get_tree().create_tween()
	tween.tween_property(self, "position", position + Vector2(0, -25), 0.2)
	tween.chain().tween_property(self, "position", position + Vector2(0, 500), 1)
	tween.tween_callback(queue_free)

	if animated_sprite_2d and animated_sprite_2d.sprite_frames and animated_sprite_2d.sprite_frames.has_animation("dead"):
		animated_sprite_2d.play("dead")

# ------------------------------
# ⚔️ Colisão com Player / Koopa
# ------------------------------
func _on_area_entered(area: Area2D) -> void:
	var player := area.get_parent()
	if player and player.get_script() == PLAYER_SCRIPT:
		player.die()
	elif area is Koopa and area.in_a_shell and area.horizontal_speed != 0:
		die_from_hit()

# ------------------------------
# 🚮 Saiu da tela -> remove
# ------------------------------
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
