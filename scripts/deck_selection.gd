extends Node2D

var chosen_deck = ""
var enemy_deck = ""
var enemy_chose = false
var i_chose = false

func select_deck(deck_name):
	if i_chose:
		return
	chosen_deck = deck_name
	i_chose = true
	
	if deck_name == "hero":
		$HeroDeckSprite.modulate = Color(1, 1, 1, 1)
		$VillainDeckSprite.modulate = Color(0.5, 0.5, 0.5, 1)
	else:
		$VillainDeckSprite.modulate = Color(1, 1, 1, 1)
		$HeroDeckSprite.modulate = Color(0.5, 0.5, 0.5, 1)
	
	$WaitingLabel.visible = true
	
	var player_id = multiplayer.get_unique_id()
	rpc("player_chose_deck", player_id, deck_name)
	check_both_chose()

@rpc("any_peer")
func player_chose_deck(player_id, deck_name):
	if multiplayer.get_unique_id() != player_id:
		enemy_deck = deck_name
		enemy_chose = true
		check_both_chose()

func check_both_chose():
	if i_chose and enemy_chose:
		await get_tree().create_timer(1.5).timeout
		get_tree().set_meta("chosen_deck", chosen_deck)
		get_tree().set_meta("enemy_deck", enemy_deck)
		get_tree().change_scene_to_file("res://scenes/main.tscn")
