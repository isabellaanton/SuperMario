extends Node

@onready var goal1: Area2D = $Goal4
@onready var key: Key = $Key
@onready var message_label: Label = $CanvasLayer/MessageLabel

var key_collected := false
var message_tween = null  # Para evitar sobreposição de mensagens

func _ready():
	print("🟢 Level_4 carregado. Objetivo: pegar a chave e ir ao Goal!")

	# Mensagem inicial
	_show_message("🗝️ Pegue a chave para liberar o Goal!")

	# Conecta sinal da Key
	if key and key.has_signal("collected"):
		if not key.is_connected("collected", Callable(self, "_on_key_collected")):
			key.connect("collected", Callable(self, "_on_key_collected"))
			print("🔗 Sinal da Key conectado com sucesso!")

	# Conecta sinal do Goal
	if goal1 and goal1.has_signal("body_entered"):
		if not goal1.is_connected("body_entered", Callable(self, "_on_goal_body_entered")):
			goal1.connect("body_entered", Callable(self, "_on_goal_body_entered"))
			print("🔗 Sinal do Goal conectado com sucesso!")


# -----------------------------
# Quando o Player coleta a chave
# -----------------------------
func _on_key_collected():
	key_collected = true
	print("✅ Chave coletada!")
	_show_message("✅ Chave coletada! Vá para o Goal.")


# -----------------------------
# Quando o Player toca o Goal
# -----------------------------
func _on_goal_body_entered(body):
	if body.name != "Player":
		return

	if not key_collected:
		print("🚫 Goal bloqueado! Pegue a chave primeiro.")
		_show_message("🚫 Pegue a chave antes de ir ao Goal!")
		return

	print("🏁 Nível concluído! Você coletou a chave e chegou ao Goal.")
	_show_message("🏁 Nível concluído!")


# -----------------------------
# Função para mostrar mensagens com fade
# -----------------------------
func _show_message(text: String):
	if not message_label:
		print("⚠️ Nenhum Label encontrado para mostrar mensagem.")
		return

	message_label.visible = true
	message_label.text = text
	message_label.modulate.a = 1

	# Mata tween anterior se houver, para não sobrepor mensagens
	if message_tween and message_tween.is_valid():
		message_tween.kill()

	message_tween = self.create_tween()
	message_tween.tween_property(message_label, "modulate:a", 1, 0.2)
	message_tween.tween_interval(2)   # mantém a mensagem visível
	message_tween.tween_property(message_label, "modulate:a", 0, 0.8)  # fade out
