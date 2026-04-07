extends Node2D

const STARTING_HEALTH = 10
const STARTING_ENERGY = 3

func host_set_up():
	$PlayerCrystal/PlayerHealth.text = str(STARTING_HEALTH)
	get_parent().get_node("EnemyField/EnemyCrystal/EnemyHealth").text = str(STARTING_HEALTH)
	$BattleManager.player_health = STARTING_HEALTH
	$BattleManager.enemy_health = STARTING_HEALTH
	
	var chosen = get_tree().get_meta("chosen_deck")
	var enemy = get_tree().get_meta("enemy_deck")
	
	get_parent().get_node("PlayerField/PlayerDeck").visible = true
	get_parent().get_node("PlayerField/PlayerDeck/Sprite2D").texture = load("res://assets/card_" + chosen + "_back.png")
	get_parent().get_node("EnemyField/EnemyDeck/Sprite2D").texture = load("res://assets/card_" + enemy + "_back.png")
	$PlayerCrystal/Sprite2D.texture = load("res://assets/" + chosen + "_crystal.png")
	get_parent().get_node("EnemyField/EnemyCrystal/Sprite2D").texture = load("res://assets/" + enemy + "_crystal.png")
	
	$CoinArea.is_enemy = false
	$CoinArea.on_turn_start(3)
	
	var enemy_coin_area = get_parent().get_node("EnemyField/CoinArea")
	enemy_coin_area.is_enemy = true
	enemy_coin_area.set_coins(3)
	
	$CoinArea.connect("coins_spent", _on_coins_spent)
	
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
	
	get_parent().get_node("Announcement").show_message("Sua vez!", 2.0)

func client_set_up():
	$PlayerCrystal/PlayerHealth.text = str(STARTING_HEALTH)
	get_parent().get_node("EnemyField/EnemyCrystal/EnemyHealth").text = str(STARTING_HEALTH)
	$BattleManager.player_health = STARTING_HEALTH
	$BattleManager.enemy_health = STARTING_HEALTH
	
	var chosen = get_tree().get_meta("chosen_deck")
	var enemy = get_tree().get_meta("enemy_deck")
	
	get_parent().get_node("PlayerField/PlayerDeck/Sprite2D").texture = load("res://assets/card_" + chosen + "_back.png")
	get_parent().get_node("EnemyField/EnemyDeck/Sprite2D").texture = load("res://assets/card_" + enemy + "_back.png")
	$PlayerCrystal/Sprite2D.texture = load("res://assets/" + chosen + "_crystal.png")
	get_parent().get_node("EnemyField/EnemyCrystal/Sprite2D").texture = load("res://assets/" + enemy + "_crystal.png")
	
	$CoinArea.is_enemy = false
	$CoinArea.on_turn_start(3)
	
	var enemy_coin_area = get_parent().get_node("EnemyField/CoinArea")
	enemy_coin_area.is_enemy = true
	enemy_coin_area.set_coins(3)
	
	$CoinArea.connect("coins_spent", _on_coins_spent)
	
	$PlayerDeck.draw_initial_hand()

func _on_coins_spent(current):
	$BattleManager.rpc("sync_enemy_coins", multiplayer.get_unique_id(), current)
