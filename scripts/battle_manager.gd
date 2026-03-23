extends Node

const SMALL_CARD_SCALE = 0.8
const CARD_MOVE_SPEED = 0.2
const DEFAULT_HEALTH = 10
const BATTLE_POS_OFFSET = 10

var empty_unit_card_slots = []
var enemy_cards_on_field = []
var player_cards_on_field = []
var player_health
var enemy_health
var player_cards_that_attacked_this_turn = []
var is_enemy_turn = false

func _ready() -> void:
	empty_unit_card_slots.append($"../EnemyCardsSlots/EnemyCardSlot")
	empty_unit_card_slots.append($"../EnemyCardsSlots/EnemyCardSlot2")
	empty_unit_card_slots.append($"../EnemyCardsSlots/EnemyCardSlot3")
	empty_unit_card_slots.append($"../EnemyCardsSlots/EnemyCardSlot4")
	player_health = DEFAULT_HEALTH
	$"../PlayerHealth".text = str(player_health)
	enemy_health = DEFAULT_HEALTH
	$"../EnemyHealth".text = str(enemy_health)

func direct_damage(damage):
	enemy_health = max(0, enemy_health - damage)
	$"../EnemyHealth".text = str(enemy_health)

func _on_end_turn_button_pressed() -> void:
	is_enemy_turn = true
	$"../CardManager".unselect_selected_unit()
	for card in player_cards_that_attacked_this_turn:
		if card.ability_script:
			card.ability_script.reset_ability()
	player_cards_that_attacked_this_turn = []
	enemy_turn()

func enemy_turn():
	$"../EndTurnButton".disabled = true
	$"../EndTurnButton".visible = false
	
	await timer(1.0)
	
	if $"../EnemyDeck".enemy_deck.size() != 0:
		$"../EnemyDeck".draw_card()
		timer(1.0)
	
	if empty_unit_card_slots.size() != 0:
		await try_play_card_with_highest_atk()
	
	if enemy_cards_on_field.size() != 0:
		var enemy_cards_to_attack = enemy_cards_on_field.duplicate()
		for card in enemy_cards_to_attack:
			if player_cards_on_field.size() != 0:
				var card_to_attack = player_cards_on_field.pick_random()
				await attack_card(card, card_to_attack, "enemy")
			else:
				await attack_player(card, "enemy")
		
	end_enemy_turn()

func attack_card(attacking_card, defending_card, attacker):
	if attacker == "player":
		$"../InputManager".input_disabled = true
		$"../CardManager".selected_monster = null
		player_cards_that_attacked_this_turn.append(attacking_card)
	
	attacking_card.z_index = 5
	
	var new_pos = Vector2(defending_card.position.x, defending_card.position.y + BATTLE_POS_OFFSET)
	var tween = get_tree().create_tween()
	tween.tween_property(attacking_card, "position", new_pos, CARD_MOVE_SPEED)
	
	await timer(0.15)
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(attacking_card, "position", attacking_card.card_is_in_slot.global_position, CARD_MOVE_SPEED)
	
	defending_card.health = max(0, defending_card.health - attacking_card.attack)
	defending_card.get_node("Sprite2D/Control/Health").texture = load("res://assets/value_" + str(defending_card.health) + ".png")
	
	attacking_card.health = max(0, attacking_card.health - defending_card.attack)
	attacking_card.get_node("Sprite2D/Control/Health").texture = load("res://assets/value_" + str(attacking_card.health) + ".png")
	
	await timer(1.0)
	
	attacking_card.z_index = 0
	
	var card_was_destroyed = false
	if attacking_card.health == 0:
		destroy_card(attacking_card, attacker)
	if defending_card.health == 0:
		if attacker == "player":
			destroy_card(defending_card, "enemy")
			card_was_destroyed = true
		else:
			destroy_card(defending_card, "player")
		card_was_destroyed = true
	
	if card_was_destroyed:
		await timer(1.0)
		
	if attacker == "player":
		if attacking_card.ability_script:
			await attacking_card.ability_script.trigger_ability(self, $"../InputManager", attacking_card, "after_attack")
		$"../InputManager".input_disabled = false
		enable_end_turn_btn(true)

func destroy_card(card, card_owner):
	var new_pos
	var slot = card.card_is_in_slot
	if card_owner == "player":
		card.get_node("Area2D/CollisionShape2D").disabled = true
		new_pos = $"../PlayerDiscard".position
		if card in player_cards_on_field:
			player_cards_on_field.erase(card)
		card.card_is_in_slot.get_node("Area2D/CollisionShape2D").disabled = false
	else:
		new_pos = $"../EnemyDiscard".position
		if card in enemy_cards_on_field:
			enemy_cards_on_field.erase(card)
			
		if slot not in empty_unit_card_slots:
			empty_unit_card_slots.append(slot)
	
	card.card_is_in_slot.card_in_slot = false
	card.card_is_in_slot = null
	
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_pos, CARD_MOVE_SPEED)

func attack_player(attacking_card, attacker):
	var new_pos_y
	if attacker == "enemy":
		new_pos_y = 280
	else:
		$"../InputManager".input_disabled = true
		enable_end_turn_btn(false)
		new_pos_y = 0
		player_cards_that_attacked_this_turn.append(attacking_card)
	attacking_card.z_index = 5
	var new_pos = Vector2(attacking_card.position.x, new_pos_y)
	
	var tween = get_tree().create_tween()
	tween.tween_property(attacking_card, "position", new_pos, CARD_MOVE_SPEED)
	
	await timer(0.15)
	
	if attacker == "enemy":
		player_health = max(0, player_health - attacking_card.attack)
		$"../PlayerHealth".text = str(player_health)
	else:
		enemy_health = max(0, enemy_health - attacking_card.attack)
		$"../EnemyHealth".text = str(enemy_health)
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(attacking_card, "position", attacking_card.card_is_in_slot.global_position, CARD_MOVE_SPEED)
	
	attacking_card.z_index = 0
	
	await timer(1.0)
	
	if attacker == "player":
		if attacking_card.ability_script:
			await attacking_card.ability_script.trigger_ability(self, $"../InputManager", attacking_card, "after_attack")
		$"../InputManager".input_disabled = false
		enable_end_turn_btn(true)

func enemy_card_selected(defending_card):
	var attacking_card = $"../CardManager".selected_monster
	if attacking_card:
		if defending_card in enemy_cards_on_field:
			$"../CardManager".selected_monster = null
			attack_card(attacking_card, defending_card, "player")

func try_play_card_with_highest_atk():
	var enemy_hand = $"../EnemyHand".enemy_hand
	if enemy_hand.size() == 0:
		end_enemy_turn()
		return
	
	var random_empty_unit_card_slot = empty_unit_card_slots.pick_random()
	empty_unit_card_slots.erase(random_empty_unit_card_slot)
	
	var card_with_highest_atk = enemy_hand[0]
	for card in enemy_hand:
		if card.attack > card_with_highest_atk.attack:
			card_with_highest_atk = card
	
	var tween = get_tree().create_tween()
	tween.tween_property(card_with_highest_atk, "position", random_empty_unit_card_slot.global_position, CARD_MOVE_SPEED)
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(card_with_highest_atk, "scale", Vector2(SMALL_CARD_SCALE, SMALL_CARD_SCALE), CARD_MOVE_SPEED)
	card_with_highest_atk.get_node("AnimationPlayer").play("card_flip")
	
	$"../EnemyHand".remove_card_from_hand(card_with_highest_atk)
	card_with_highest_atk.card_is_in_slot = random_empty_unit_card_slot
	enemy_cards_on_field.append(card_with_highest_atk)
	
	
	await timer(1.0)

func timer(time):
	await get_tree().create_timer(time).timeout

func end_enemy_turn():
	$"../PlayerDeck".reset_draw()
	is_enemy_turn = false
	$"../EndTurnButton".disabled = false
	$"../EndTurnButton".visible = true

func enable_end_turn_btn(is_enable):
	if is_enable:
		$"../EndTurnButton".disabled = false
		$"../EndTurnButton".visible = true
	else:
		$"../EndTurnButton".disabled = true
		$"../EndTurnButton".visible = false
