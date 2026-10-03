extends Node

@onready var goal1: Area2D = $Goal1
@onready var message_label: Label = get_node_or_null("CanvasLayer/MessageLabel")

var total_coins := 10          # número de moedas necessárias para liberar o Goal
var collected_coins := 0
var goal_liberado := false
var message_tween = null       # para evitar sobreposição de mensagens

func _ready():
	print("🟢 Level_1 carregado.")

	if not goal1:
		push_error("⚠️ Goal1 não encontrado!")
		return

	if not message_label:
		push_error("⚠️ MessageLabel não encontrada! Verifique CanvasLayer/MessageLabel.")
	else:
		# Mensagem inicial do objetivo
		_show_message("💰 Colete todas as moedas para liberar o Goal!")

	# Conecta sinais das moedas do grupo "coins"
	var coins = get_tree().get_nodes_in_group("coins")
	for coin in coins:
		if coin.has_signal("collected"):
			coin.connect("collected", Callable(self, "_on_coin_collected"))

	# Conecta sinal do Goal
	if goal1.has_signal("body_entered"):
		if not goal1.is_connected("body_entered", Callable(self, "_on_goal_body_entered")):
			goal1.connect("body_entered", Callable(self, "_on_goal_body_entered"))
			print("🔗 Sinal 'body_entered' do Goal conectado com sucesso!")


# -----------------------------
# Quando uma moeda é coletada
# -----------------------------
func _on_coin_collected(_points: int):
	collected_coins += 1
	print("✨ Moeda coletada! %d / %d" % [collected_coins, total_coins])
	_show_message("💰 Moedas: %d / %d" % [collected_coins, total_coins])

	if collected_coins >= total_coins and not goal_liberado:
		goal_liberado = true
		print("✅ Todas as 10 moedas coletadas! Goal liberado.")
		_show_message("✅ Todas as 10 moedas coletadas! Goal liberado!")


# -----------------------------
# Quando o Player toca o Goal
# -----------------------------
func _on_goal_body_entered(body):
	if body.name != "Player":
		return

	if not goal_liberado:
		print("🚫 Goal bloqueado! Ainda faltam moedas.")
		_show_message("🚫 Ainda faltam moedas! Pegue todas para liberar o Goal.")
		return

	print("🏁 Nível concluído! Indo para o Level_2...")
	_show_message("🏁 Indo para o próximo nível...")
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://Level_2.tscn")


# -----------------------------
# Função para mostrar mensagens na tela com fade
# -----------------------------
func _show_message(text: String):
	if not message_label:
		print("⚠️ Nenhum Label encontrado para mostrar texto.")
		return

	message_label.visible = true
	message_label.text = text
	message_label.modulate.a = 1

	if message_tween and message_tween.is_valid():
		message_tween.kill()

	message_tween = self.create_tween()
	message_tween.tween_property(message_label, "modulate:a", 1, 0.2)
	message_tween.tween_interval(2)
	message_tween.tween_property(message_label, "modulate:a", 0, 0.8)
