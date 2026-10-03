extends Label
class_name PointsLabel

var score: int = 0
var displayed_score: float = 0.0
var tween: Tween = null

func _ready():
	update_text()

	# Conecta automaticamente aos players da cena
	for player in get_tree().get_nodes_in_group("player"):
		if not player.is_connected("points_scored", Callable(self, "_on_player_points_scored")):
			player.connect("points_scored", Callable(self, "_on_player_points_scored"))

func _on_player_points_scored(points: int) -> void:
	add_points(points)

func add_points(points: int) -> void:
	score += points
	if tween and tween.is_valid():
		tween.kill()

	tween = get_tree().create_tween()
	tween.tween_property(self, "displayed_score", score, 0.3)
	tween.tween_callback(update_text)

func update_text() -> void:
	text = str(int(displayed_score))
