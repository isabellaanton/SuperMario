extends Control

func _ready():
	# Conecta os botões aos métodos (ajuste os nomes dos botões)
	$VBoxContainer/PlayButton.connect("pressed", Callable(self, "_on_play_pressed"))
	$VBoxContainer/QuitButton.connect("pressed", Callable(self, "_on_quit_pressed"))

func _on_play_pressed():
	# Troca para a cena principal do jogo (Level.tscn)
	get_tree().change_scene_to_file("res://Level_1.tscn")

func _on_quit_pressed():
	get_tree().quit()
