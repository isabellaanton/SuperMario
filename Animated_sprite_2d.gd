extends AnimatedSprite2D
class_name PlayerAnimatedSprite

var valid_animations := [
	"small_idle", "small_run", "small_jump", "small_slide",
	"big_idle", "big_run", "big_jump", "big_slide",
	"shooting_idle", "shooting_run", "shooting_jump", "shooting_slide",
	"small_death"
]

var base_scale_x: float

func _ready():
	base_scale_x = scale.x

func trigger_animation(velocity: Vector2, direction: float, player_mode: int) -> void:
	var prefix: String = str(Player.PlayerMode.keys()[player_mode]).to_snake_case()
	var new_animation: String = animation  # começa com a atual, pra evitar troca desnecessária

	# --- Detecta estado do jogador ---
	var is_jumping: bool = not get_parent().is_on_floor()
	var is_running: bool = abs(velocity.x) > 20.0
	var is_sliding: bool = sign(velocity.x) != sign(direction) and is_running

	# --- Define animação desejada ---
	if is_jumping:
		new_animation = "%s_jump" % prefix
	elif is_sliding:
		new_animation = "%s_slide" % prefix
	elif is_running:
		new_animation = "%s_run" % prefix
	else:
		new_animation = "%s_idle" % prefix

	# --- Só troca se for diferente ---
	if new_animation != animation:
		play(new_animation)

	# --- Espelha sprite sem deformar ---
	if direction < 0:
		scale.x = -abs(base_scale_x)
	elif direction > 0:
		scale.x = abs(base_scale_x)
