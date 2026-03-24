extends Node2D

const STARTING_HEALTH = 10

func host_set_up():
	$PlayerHealth.text = str(STARTING_HEALTH)
	get_parent().get_node("EnemyField/EnemyHealth").text = str(STARTING_HEALTH)
	$BattleManager.player_health = STARTING_HEALTH
	$BattleManager.enemy_health = STARTING_HEALTH
	
	get_parent().get_node("EnemyField/EnemyDeck").deck_size = 12
	get_parent().get_node("EnemyField/EnemyDeck/Label").text = "12"
	
	await $PlayerDeck.draw_initial_hand()
	
	$EndTurnButton.visible = true
	$EndTurnButton.disabled = false
	
	$InputManager.input_disabled = false

func client_set_up():
	$PlayerHealth.text = str(STARTING_HEALTH)
	get_parent().get_node("EnemyField/EnemyHealth").text = str(STARTING_HEALTH)
	$BattleManager.player_health = STARTING_HEALTH
	$BattleManager.enemy_health = STARTING_HEALTH
	
	get_parent().get_node("EnemyField/EnemyDeck").deck_size = 12
	get_parent().get_node("EnemyField/EnemyDeck/Label").text = "12"
	
	$PlayerDeck.draw_initial_hand()
