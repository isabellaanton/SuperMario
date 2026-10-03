extends Control

func _ready():
	var restart_button = $VBoxContainer/RestartButton
	var quit_button = $VBoxContainer/QuitButton

	restart_button.connect("pressed", Callable(self, "_on_restart_pressed"))
	quit_button.connect("pressed", Callable(self, "_on_quit_pressed"))

func _on_restart_pressed():
	get_tree().change_scene_to_file("res://Level_1.tscn")

func _on_quit_pressed():
	get_tree().quit()
