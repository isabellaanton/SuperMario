extends Area2D
class_name Key

signal collected  # Sinal emitido quando o Player coleta a chave

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if not body.is_in_group("player"):
		return

	# Emite sinal de coleta
	emit_signal("collected")

	# Desativa colisão e esconde a chave
	if collision_shape:
		collision_shape.disabled = true
	if sprite:
		sprite.visible = false

	# Remove o nó da cena (como a moeda)
	queue_free()
