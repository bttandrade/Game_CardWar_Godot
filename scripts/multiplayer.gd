extends Node2D

@export var player_field_scene: PackedScene
@export var enemy_field_scene: PackedScene

const PORT = 9999
const DEFAULT_ADDRESS = "localhost"

var peer = ENetMultiplayerPeer.new()
var has_to_change = false

func _ready() -> void:
	if !get_tree().has_meta("chosen_deck"):
		return
	
	disable_btns()
	
	var player_scene = player_field_scene.instantiate()
	add_child(player_scene)
	
	var enemy_scene = enemy_field_scene.instantiate()
	add_child(enemy_scene)
	
	if get_tree().get_meta("is_host"):
		multiplayer.peer_connected.connect(_on_peer_connected_late)
		var host_starts: bool
		if get_tree().has_meta("last_host_started"):
			host_starts = !get_tree().get_meta("last_host_started")
		else:
			host_starts = randi() % 2 == 0
		get_tree().set_meta("host_starts", host_starts)
		get_tree().set_meta("last_host_started", host_starts)
		get_node("PlayerField").host_set_up(host_starts)
	else:
		get_node("PlayerField").client_set_up()

func _on_peer_connected_late(_peer_id):
	pass

func _on_host_btn_pressed() -> void:
	disable_btns()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	get_tree().set_meta("is_host", true)
	get_tree().change_scene_to_file("res://scenes/deck_selection.tscn")

func disable_btns():
	$HostBtn.disabled = true
	$HostBtn.visible = false
	$JoinBtn.disabled = true
	$JoinBtn.visible = false
	$IPInput.visible = false
	$QuitBtn.visible = false
	$CreditsBtn.visible = false
	$RulesBtn.visible = false
	$Sprite2D.visible = false
	$Credits.visible = false
	$Rules.visible = false

func _on_peer_connected(_peer_id):
	pass

func _on_join_btn_pressed() -> void:
	var address = $IPInput.text.strip_edges()
	
	if address.is_empty():
		$IPError.text = "Digite um IP antes de conectar!"
		$IPError.visible = true
		await get_tree().create_timer(2.0).timeout
		$IPError.visible = false
		return
	
	if not is_valid_ip(address):
		$IPError.text = "IP inválido!"
		$IPError.visible = true
		await get_tree().create_timer(2.0).timeout
		$IPError.visible = false
		return
	
	$IPError.visible = false
	disable_btns()
	peer.create_client(address, PORT)
	multiplayer.multiplayer_peer = peer
	get_tree().set_meta("is_host", false)
	get_tree().change_scene_to_file("res://scenes/deck_selection.tscn")

func is_valid_ip(address: String) -> bool:
	var parts = address.split(".")
	if parts.size() != 4:
		return false
	for part in parts:
		if not part.is_valid_int():
			return false
		var num = int(part)
		if num < 0 or num > 255:
			return false
	return true

func _on_audio_stream_player_finished() -> void:
	$AudioStreamPlayer.play()

func _on_rules_btn_pressed() -> void:
	$Rules.visible = true
	$CreditsBtn.visible = false
	$ReturnBtn.visible = true
	
	$RulesBtn.visible = false
	$HostBtn.visible = false
	$Sprite2D.visible = false
	$JoinBtn.visible = false
	$IPInput.visible = false
	$QuitBtn.visible = false

func _on_quit_btn_pressed() -> void:
	get_tree().quit()

func _on_credits_btn_pressed() -> void:
	$Credits.visible = true
	$CreditsBtn.visible = false
	$ReturnBtn.visible = true
	
	$RulesBtn.visible = false
	$HostBtn.visible = false
	$Sprite2D.visible = false
	$JoinBtn.visible = false
	$IPInput.visible = false
	$QuitBtn.visible = false

func _on_return_btn_pressed() -> void:
	$CreditsBtn.visible = true
	$Credits.visible = false
	$Rules.visible = false
	$ReturnBtn.visible = false
	
	$RulesBtn.visible = true
	$HostBtn.visible = true
	$Sprite2D.visible = true
	$JoinBtn.visible = true
	$IPInput.visible = true
	$QuitBtn.visible = true
