extends Control

func _ready() -> void:
	var won = get_tree().get_meta("player_won")
	setup(won)

func setup(won: bool):
	if won:
		$MessageLabel.text = "Vitória!"
	else:
		$MessageLabel.text = "Derrota!"

func _on_lobby_btn_pressed() -> void:
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file("res://scenes/main.tscn")
