extends Control

@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	var won = get_tree().get_meta("player_won")
	setup(won)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func setup(won: bool):
	if won:
		audio.stream = load("res://sounds/victory.mp3")
		audio.play()
		$MessageLabel.text = "Vitória!"
	else:
		audio.stream = load("res://sounds/defeat.mp3")
		audio.play()
		$MessageLabel.text = "Derrota!"

func _on_peer_disconnected(_peer_id):
	if get_tree().has_meta("last_host_started"):
		get_tree().remove_meta("last_host_started")
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_rematch_btn_pressed() -> void:
	if get_tree().has_meta("chosen_deck"):
		get_tree().remove_meta("chosen_deck")
	if get_tree().has_meta("enemy_deck"):
		get_tree().remove_meta("enemy_deck")
	if get_tree().has_meta("player_won"):
		get_tree().remove_meta("player_won")
	if get_tree().has_meta("host_starts"):
		get_tree().remove_meta("host_starts")
	get_tree().change_scene_to_file("res://scenes/deck_selection.tscn")

func _on_lobby_btn_pressed() -> void:
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	if get_tree().has_meta("chosen_deck"):
		get_tree().remove_meta("chosen_deck")
	if get_tree().has_meta("enemy_deck"):
		get_tree().remove_meta("enemy_deck")
	if get_tree().has_meta("is_host"):
		get_tree().remove_meta("is_host")
	if get_tree().has_meta("player_won"):
		get_tree().remove_meta("player_won")
	if get_tree().has_meta("host_starts"):
		get_tree().remove_meta("host_starts")
	if get_tree().has_meta("last_host_started"):
		get_tree().remove_meta("last_host_started")
	get_tree().change_scene_to_file("res://scenes/main.tscn")
