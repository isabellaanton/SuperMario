extends Node

@onready var timer_label = $TimerLabel       # Label que mostra o tempo restante
@onready var message_label = $MessageLabel   # Label que mostra a mensagem inicial
@onready var timer = $TimerCountdown         # Timer node

var time_left: int = 20  # tempo total em segundos

func _ready():
	# Mostra mensagem inicial
	if message_label:
		_show_message("🏁 Você tem 20 segundos!")

	# Configura timer
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	update_timer_label()


# -----------------------------
# Atualiza o timer a cada segundo
# -----------------------------
func _on_timer_timeout():
	time_left -= 1
	update_timer_label()

	if time_left <= 0:
		game_over()


# -----------------------------
# Atualiza o Label do timer
# -----------------------------
func update_timer_label():
	timer_label.text = "⏱️ Tempo: %d" % time_left


# -----------------------------
# Quando o tempo acaba
# -----------------------------
func game_over():
	timer.stop()
	timer_label.text = "⏱️ Tempo esgotado!"
	get_tree().reload_current_scene()  # reinicia o nível


# -----------------------------
# Função para mostrar mensagens na tela com fade
# -----------------------------
func _show_message(text: String):
	if not message_label:
		print("⚠️ Nenhum Label encontrado para mostrar mensagem.")
		return

	message_label.visible = true
	message_label.text = text
	message_label.modulate.a = 1

	var tween = self.create_tween()
	tween.tween_property(message_label, "modulate:a", 1, 0.2)
	tween.tween_interval(2)   # mensagem visível por 2 segundos
	tween.tween_property(message_label, "modulate:a", 0, 0.8)  # fade out
