extends Node2D

@export var player_field_scene: PackedScene
@export var enemy_field_scene: PackedScene

const PORT = 9999
const SERVER_ADRESS = "localhost"
var peer = ENetMultiplayerPeer.new()

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
		get_node("PlayerField").host_set_up()
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

func _on_peer_connected(_peer_id):
	pass

func _on_join_btn_pressed() -> void:
	disable_btns()
	peer.create_client(SERVER_ADRESS, PORT)
	multiplayer.multiplayer_peer = peer
	get_tree().set_meta("is_host", false)
	get_tree().change_scene_to_file("res://scenes/deck_selection.tscn")
