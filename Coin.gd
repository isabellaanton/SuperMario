extends Area2D
class_name Coin

@export var points: int = 100
signal collected(points: int)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if not body.is_in_group("player"):
		return

	emit_signal("collected", points)

	if collision_shape:
		collision_shape.disabled = true

	if animated_sprite and animated_sprite.sprite_frames.has_animation("collect"):
		animated_sprite.play("collect")
		await animated_sprite.animation_finished

	queue_free()
