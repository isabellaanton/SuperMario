extends Area2D

@export var next_level_scene_path := "res://Level_4.tscn" # caminho da próxima cena

func _on_body_entered(body):
	if body.name == "Player":  # garante que só o Player ativa
		print("Você chegou ao goal!")
		if next_level_scene_path != "":
			get_tree().change_scene_to_file(next_level_scene_path)
