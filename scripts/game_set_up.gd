extends Node2D

const STARTING_HEALTH = 10
const STARTING_ENERGY = 3

func host_set_up():
	$PlayerHealth.text = str(STARTING_HEALTH)
	get_parent().get_node("EnemyField/EnemyHealth").text = str(STARTING_HEALTH)
	$BattleManager.player_health = STARTING_HEALTH
	$BattleManager.enemy_health = STARTING_HEALTH
	
	var deck_size = $PlayerDeck.chosen_deck.size()
	var chosen = get_tree().get_meta("chosen_deck")
	var enemy = get_tree().get_meta("enemy_deck")
	
	get_parent().get_node("PlayerField/PlayerDeck").visible = true
	get_parent().get_node("PlayerField/PlayerDeck/Sprite2D").texture = load("res://assets/card_" + chosen + "_back.png")
	get_parent().get_node("EnemyField/EnemyDeck/Sprite2D").texture = load("res://assets/card_" + enemy + "_back.png")
	
	get_parent().get_node("EnemyField/EnemyDeck").deck_size = deck_size
	get_parent().get_node("EnemyField/EnemyDeck/Label").text = str(deck_size)
	
	$EnergyBar.is_enemy = false
	$EnergyBar.current_energy = STARTING_ENERGY
	$EnergyBar.max_energy_this_turn = STARTING_ENERGY
	$EnergyBar.update_display()
	
	var enemy_energy = get_parent().get_node("EnemyField/EnergyBar")
	enemy_energy.is_enemy = true
	enemy_energy.current_energy = STARTING_ENERGY
	enemy_energy.max_energy_this_turn = STARTING_ENERGY
	enemy_energy.update_display()
	
	$EnergyBar.connect("energy_spent", _on_energy_spent)
	
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
	var chosen = get_tree().get_meta("chosen_deck")
	var enemy = get_tree().get_meta("enemy_deck")
	
	get_parent().get_node("PlayerField/PlayerDeck/Sprite2D").texture = load("res://assets/card_" + chosen + "_back.png")
	get_parent().get_node("EnemyField/EnemyDeck/Sprite2D").texture = load("res://assets/card_" + enemy + "_back.png")
	
	get_parent().get_node("EnemyField/EnemyDeck").deck_size = deck_size
	get_parent().get_node("EnemyField/EnemyDeck/Label").text = str(deck_size)
	
	$EnergyBar.is_enemy = false
	$EnergyBar.current_energy = STARTING_ENERGY
	$EnergyBar.max_energy_this_turn = STARTING_ENERGY
	$EnergyBar.update_display()
	
	var enemy_energy = get_parent().get_node("EnemyField/EnergyBar")
	enemy_energy.is_enemy = true
	enemy_energy.current_energy = STARTING_ENERGY
	enemy_energy.max_energy_this_turn = STARTING_ENERGY
	enemy_energy.update_display()
	
	$EnergyBar.connect("energy_spent", _on_energy_spent)
	
	$PlayerDeck.draw_initial_hand()

func _on_energy_spent(current, maximum):
	$BattleManager.rpc("sync_enemy_energy", multiplayer.get_unique_id(), current, maximum)
