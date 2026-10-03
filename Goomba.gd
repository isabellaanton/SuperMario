extends Enemy
class_name Goomba

@onready var stomp_area: Area2D = $StompArea
@onready var notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _ready():
	if stomp_area:
		stomp_area.body_entered.connect(_on_stomp_area_body_entered)
	if notifier:
		notifier.screen_exited.connect(_on_screen_exited)

# ------------------------------
# ⚔️ Morte
# ------------------------------
func die():
	super.die()
	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)
	get_tree().create_timer(0.5).timeout.connect(queue_free)

# ------------------------------
# 👟 Player pisa em cima (stomp)
# ------------------------------
func _on_stomp_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.velocity.y > 0 and body.global_position.y < global_position.y - 8:
			die()  # Goomba morre
			body.velocity.y = body.jump_velocity * 0.6  # bounce
		else:
			body.die()  # player morre se bater de lado

# ------------------------------
# 🧨 Fallback: colisão direta
# ------------------------------
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		area.die()

# ------------------------------
# 🚮 Saiu da tela -> remove
# ------------------------------
func _on_screen_exited() -> void:
	queue_free()
