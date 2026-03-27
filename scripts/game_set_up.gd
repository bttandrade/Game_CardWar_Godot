extends Node2D

const STARTING_HEALTH = 10

func host_set_up():
	$PlayerHealth.text = str(STARTING_HEALTH)
	get_parent().get_node("EnemyField/EnemyHealth").text = str(STARTING_HEALTH)
	$BattleManager.player_health = STARTING_HEALTH
	$BattleManager.enemy_health = STARTING_HEALTH
	
	var deck_size = $PlayerDeck.chosen_deck.size()
	if $PlayerDeck.chosen_deck == $PlayerDeck.villain_deck:
		get_parent().get_node("EnemyField/EnemyDeck/Sprite2D").texture = load("res://assets/card_villain_back.png")
		get_parent().get_node("PlayerField/PlayerDeck").visible = true
		get_parent().get_node("PlayerField/PlayerDeck/Sprite2D").texture = load("res://assets/card_villain_back.png")
	get_parent().get_node("EnemyField/EnemyDeck").deck_size = deck_size
	get_parent().get_node("EnemyField/EnemyDeck/Label").text = str(deck_size)
	
	await $PlayerDeck.draw_initial_hand()
	
	await get_tree().create_timer(0.5).timeout
	
	var extra_card = $PlayerDeck.chosen_deck[0]
	var player_id = multiplayer.get_unique_id()
	$PlayerDeck.draw_here_and_for_client(player_id, extra_card)
	$PlayerDeck.rpc("draw_here_and_for_client", player_id, extra_card)
	
	await get_tree().create_timer(0.5).timeout
	
	$EndTurnButton.visible = true
	$EndTurnButton.disabled = false
	$InputManager.input_disabled = false

func client_set_up():
	$PlayerHealth.text = str(STARTING_HEALTH)
	get_parent().get_node("EnemyField/EnemyHealth").text = str(STARTING_HEALTH)
	$BattleManager.player_health = STARTING_HEALTH
	$BattleManager.enemy_health = STARTING_HEALTH
	
	var deck_size = $PlayerDeck.chosen_deck.size()
	if $PlayerDeck.chosen_deck == $PlayerDeck.villain_deck:
		get_parent().get_node("EnemyField/EnemyDeck/Sprite2D").texture =  load("res://assets/card_villain_back.png")
		get_parent().get_node("PlayerField/PlayerDeck/Sprite2D").texture =  load("res://assets/card_villain_back.png")
	get_parent().get_node("PlayerField/PlayerDeck").visible = true
	get_parent().get_node("EnemyField/EnemyDeck").deck_size = deck_size
	get_parent().get_node("EnemyField/EnemyDeck/Label").text = str(deck_size)
	
	$PlayerDeck.draw_initial_hand()
