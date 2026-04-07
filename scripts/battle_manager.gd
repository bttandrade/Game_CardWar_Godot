extends Node

const SMALL_CARD_SCALE = 0.8
const CARD_MOVE_SPEED = 0.2
const DEFAULT_HEALTH = 10
const BATTLE_POS_OFFSET = 10

signal spell_target_selected(card)

var waiting_for_spell_target = false
var enemy_cards_on_field = []
var player_cards_on_field = []
var player_health
var enemy_health
var player_cards_that_attacked_this_turn = []
var can_attack = false

func _ready() -> void:
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_disconnected(_peer_id):
	get_parent().get_parent().get_node("Announcement").show_message("Oponente desconectou!", 2.0)
	await get_tree().create_timer(2.0).timeout
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
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func direct_damage(damage):
	var player_id = multiplayer.get_unique_id()
	direct_damage_here_and_for_client(player_id, damage)
	rpc("direct_damage_here_and_for_client", player_id, damage)

@rpc("any_peer")
func direct_damage_here_and_for_client(player_id, damage):
	if multiplayer.get_unique_id() == player_id:
		enemy_health = max(0, enemy_health - damage)
		get_parent().get_parent().get_node("EnemyField/EnemyCrystal/EnemyHealth").text = str(enemy_health)
	else:
		player_health = max(0, player_health - damage)
		$"../PlayerCrystal/PlayerHealth".text = str(player_health)
	
	check_game_over()

func _on_end_turn_button_pressed() -> void:
	can_attack = true
	enable_end_turn_btn(false)
	$"../InputManager".input_disabled = true
	$"../CardManager".unselect_selected_unit()
	for card in player_cards_that_attacked_this_turn:
		if card.ability_script:
			card.ability_script.reset_ability()
	player_cards_that_attacked_this_turn = []
	get_parent().get_parent().get_node("Announcement").show_message("Vez do oponente!", 2.0)
	rpc("change_turn")

@rpc("any_peer")
func change_turn():
	can_attack = true
	$"../InputManager".input_disabled = true
	
	var coin_area = $"../CoinArea"
	coin_area.on_turn_start(1)
	
	var player_id = multiplayer.get_unique_id()
	rpc("sync_enemy_coins", player_id, coin_area.current_coins)
	
	get_parent().get_parent().get_node("Announcement").show_message("Sua vez!", 2.0)
	
	await $"../PlayerDeck".reset_draw()
	enable_end_turn_btn(true)
	$"../InputManager".input_disabled = false

@rpc("any_peer")
func sync_enemy_coins(player_id, count):
	if multiplayer.get_unique_id() != player_id:
		get_parent().get_parent().get_node("EnemyField/CoinArea").set_coins(count)

func attack_card(attacking_card, defending_card):
	if !can_attack:
		return
	$"../InputManager".input_disabled = true
	$"../CardManager".selected_monster = null
	player_cards_that_attacked_this_turn.append(attacking_card)
	
	var player_id = multiplayer.get_unique_id()
	var has_death_touch = attacking_card.get("has_death_touch") == true
	var has_cannon = attacking_card.get("has_cannon") == true
	
	attack_card_here_and_for_client(player_id, str(attacking_card.name), str(defending_card.name), has_death_touch, has_cannon)
	rpc("attack_card_here_and_for_client", player_id, str(attacking_card.name), str(defending_card.name), has_death_touch, has_cannon)
	
	if attacking_card.ability_script:
		await attacking_card.ability_script.trigger_ability(self, $"../InputManager", attacking_card, "after_attack")
	$"../InputManager".input_disabled = false
	enable_end_turn_btn(true)

@rpc("any_peer")
func attack_card_here_and_for_client(player_id, attacking_card_name, defending_card_name, attacker_has_death_touch, attacker_has_cannon):
	var attacking_card
	var defending_card
	var y_offset
	
	if multiplayer.get_unique_id() == player_id:
		attacking_card = $"../CardManager".get_node(attacking_card_name)
		defending_card = get_parent().get_parent().get_node("EnemyField/CardManager/" + defending_card_name)
		y_offset = BATTLE_POS_OFFSET
	else:
		attacking_card = get_parent().get_parent().get_node("EnemyField/CardManager/" + attacking_card_name)
		defending_card = $"../CardManager".get_node(defending_card_name)
		y_offset = -BATTLE_POS_OFFSET
	
	attacking_card.z_index = 5
	
	var new_pos = Vector2(defending_card.position.x, defending_card.position.y + y_offset)
	var tween = get_tree().create_tween()
	tween.tween_property(attacking_card, "position", new_pos, CARD_MOVE_SPEED)
	
	await timer(0.15)
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(attacking_card, "position", attacking_card.card_is_in_slot.global_position, CARD_MOVE_SPEED)
	
	if attacker_has_death_touch:
		defending_card.health = 0
		defending_card.get_node("Sprite2D/Control/Health").texture = load("res://assets/value_0.png")
		attacking_card.get_node("Sprite2D/Control/Health").texture = load("res://assets/value_" + str(attacking_card.health) + ".png")
	elif attacker_has_cannon:
		var cards_to_hit
		if multiplayer.get_unique_id() == player_id:
			cards_to_hit = enemy_cards_on_field.duplicate()
		else:
			cards_to_hit = player_cards_on_field.duplicate()
		for card in cards_to_hit:
			if card.health == null:
				continue
			card.health = max(0, card.health - attacking_card.attack)
			card.get_node("Sprite2D/Control/Health").texture = load("res://assets/value_" + str(card.health) + ".png")
		attacking_card.get_node("Sprite2D/Control/Health").texture = load("res://assets/value_" + str(attacking_card.health) + ".png")
	else:
		defending_card.health = max(0, defending_card.health - attacking_card.attack)
		defending_card.get_node("Sprite2D/Control/Health").texture = load("res://assets/value_" + str(defending_card.health) + ".png")
		attacking_card.health = max(0, attacking_card.health - defending_card.attack)
		attacking_card.get_node("Sprite2D/Control/Health").texture = load("res://assets/value_" + str(attacking_card.health) + ".png")
	
	await timer(1.0)
	
	attacking_card.z_index = 0
	
	var card_was_destroyed = false
	
	if attacker_has_cannon:
		var cards_to_check
		if multiplayer.get_unique_id() == player_id:
			cards_to_check = enemy_cards_on_field.duplicate()
		else:
			cards_to_check = player_cards_on_field.duplicate()
		for card in cards_to_check:
			if card.health == 0:
				if multiplayer.get_unique_id() == player_id:
					destroy_card(card, "enemy")
				else:
					destroy_card(card, "player")
				card_was_destroyed = true
	else:
		if attacking_card.health == 0:
			if multiplayer.get_unique_id() == player_id:
				destroy_card(attacking_card, "player")
			else:
				destroy_card(attacking_card, "enemy")
			card_was_destroyed = true
		if defending_card.health == 0:
			if multiplayer.get_unique_id() == player_id:
				destroy_card(defending_card, "enemy")
			else:
				destroy_card(defending_card, "player")
			card_was_destroyed = true
	
	if card_was_destroyed:
		await timer(1.0)

func destroy_card(card, card_owner):
	var new_pos
	if card_owner == "player":
		card.get_node("Area2D/CollisionShape2D").disabled = true
		new_pos = $"../PlayerDiscard".position
		if card in player_cards_on_field:
			player_cards_on_field.erase(card)
		card.card_is_in_slot.get_node("Area2D/CollisionShape2D").disabled = false
	else:
		new_pos = get_parent().get_parent().get_node("EnemyField/EnemyDiscard").position
		if card in enemy_cards_on_field:
			enemy_cards_on_field.erase(card)
	card.z_index = -1
	card.card_is_in_slot.card_in_slot = false
	card.card_is_in_slot = null
	
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_pos, CARD_MOVE_SPEED)

func attack_player(attacking_card):
	if !can_attack:
		return
	$"../InputManager".input_disabled = true
	enable_end_turn_btn(false)
	player_cards_that_attacked_this_turn.append(attacking_card)
	
	var player_id = multiplayer.get_unique_id()
	rpc("attack_player_here_and_for_client", player_id, str(attacking_card.name))
	await attack_player_here_and_for_client(player_id, str(attacking_card.name))
	
	if attacking_card.ability_script:
		await attacking_card.ability_script.trigger_ability(self, $"../InputManager", attacking_card, "after_attack")
	$"../InputManager".input_disabled = false
	enable_end_turn_btn(true)

@rpc("any_peer")
func attack_player_here_and_for_client(player_id, attacking_card_name):
	var attacking_card
	var attack_pos_y
	
	if multiplayer.get_unique_id() == player_id:
		attacking_card = $"../CardManager".get_node(attacking_card_name)
		attack_pos_y = 0
	else:
		attacking_card = get_parent().get_parent().get_node("EnemyField/CardManager/" + attacking_card_name)
		attack_pos_y = 700
	
	var new_pos = Vector2(attacking_card.position.x, attack_pos_y)
	
	attacking_card.z_index = 5

	var tween = get_tree().create_tween()
	tween.tween_property(attacking_card, "position", new_pos, CARD_MOVE_SPEED)
	
	await timer(0.15)
	
	if multiplayer.get_unique_id() == player_id:
		enemy_health = max(0, enemy_health - attacking_card.attack)
		get_parent().get_parent().get_node("EnemyField/EnemyCrystal/EnemyHealth").text = str(enemy_health)
	else:
		player_health = max(0, player_health - attacking_card.attack)
		$"../PlayerCrystal/PlayerHealth".text = str(player_health)
	
	check_game_over()
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(attacking_card, "position", attacking_card.card_is_in_slot.global_position, CARD_MOVE_SPEED)
	
	attacking_card.z_index = 0
	
	await timer(1.0)

func destroy_magic_card(card):
	var player_id = multiplayer.get_unique_id()
	destroy_magic_card_here_and_for_client(player_id, str(card.name))
	rpc("destroy_magic_card_here_and_for_client", player_id, str(card.name))

@rpc("any_peer")
func destroy_magic_card_here_and_for_client(player_id, card_name):
	var card
	if multiplayer.get_unique_id() == player_id:
		card = $"../CardManager".get_node(card_name)
		destroy_card(card, "player")
	else:
		var enemy_field = get_parent().get_parent().get_node("EnemyField")
		card = enemy_field.get_node("CardManager/" + card_name)
		destroy_card(card, "enemy")

func arrows(cards_on_field):
	var player_id = multiplayer.get_unique_id()
	var card_names = []
	for card in cards_on_field:
		card_names.append(str(card.name))
	arrows_here_and_for_client(player_id, card_names)
	rpc("arrows_here_and_for_client", player_id, card_names)
	await timer(1.0)

@rpc("any_peer")
func arrows_here_and_for_client(player_id, card_names):
	var cards_to_destroy = []
	var card_manager
	
	if multiplayer.get_unique_id() == player_id:
		card_manager = get_parent().get_parent().get_node("EnemyField/CardManager")
	else:
		card_manager = $"../CardManager"
	
	for card_name in card_names:
		var card = card_manager.get_node(card_name)
		if card.health == null:
			continue
		card.health = max(0, card.health - 1)
		card.get_node("Sprite2D/Control/Health").texture = load("res://assets/value_" + str(card.health) + ".png")
		if card.health == 0:
			cards_to_destroy.append(card)
	
	await timer(1.0)
	
	for card in cards_to_destroy:
		if multiplayer.get_unique_id() == player_id:
			destroy_card(card, "enemy")
		else:
			destroy_card(card, "player")

func decay(cards_on_field):
	var player_id = multiplayer.get_unique_id()
	var card_names = []
	for card in cards_on_field:
		card_names.append(str(card.name))
	decay_here_and_for_client(player_id, card_names)
	rpc("decay_here_and_for_client", player_id, card_names)
	await timer(1.0)

@rpc("any_peer")
func decay_here_and_for_client(player_id, card_names):
	var card_manager
	
	if multiplayer.get_unique_id() == player_id:
		card_manager = get_parent().get_parent().get_node("EnemyField/CardManager")
	else:
		card_manager = $"../CardManager"
	
	for card_name in card_names:
		var card = card_manager.get_node(card_name)
		if card.card_type != "unit":
			continue
		card.attack = max(0, card.attack - 1)
		card.get_node("Sprite2D/Control/Attack").texture = load("res://assets/value_" + str(card.attack) + ".png")

func hellfire(target_card):
	var player_id = multiplayer.get_unique_id()
	var target_name = str(target_card.name)
	hellfire_here_and_for_client(player_id, target_name)
	rpc("hellfire_here_and_for_client", player_id, target_name)
	await timer(1.0)

@rpc("any_peer")
func hellfire_here_and_for_client(player_id, target_card_name):
	var card_manager
	var cards_on_field
	
	if multiplayer.get_unique_id() == player_id:
		card_manager = get_parent().get_parent().get_node("EnemyField/CardManager")
		cards_on_field = enemy_cards_on_field
	else:
		card_manager = $"../CardManager"
		cards_on_field = player_cards_on_field
	
	var target = card_manager.get_node(target_card_name)
	
	var left_card = null
	var right_card = null
	var closest_left_dist = INF
	var closest_right_dist = INF
	
	for card in cards_on_field:
		if card == target:
			continue
		var diff = card.position.x - target.position.x
		if diff < 0 and abs(diff) < closest_left_dist:
			closest_left_dist = abs(diff)
			left_card = card
		elif diff > 0 and abs(diff) < closest_right_dist:
			closest_right_dist = abs(diff)
			right_card = card
	
	if closest_left_dist > 200:
		left_card = null
	if closest_right_dist > 200:
		right_card = null
	
	target.health = max(0, target.health - 2)
	target.get_node("Sprite2D/Control/Health").texture = load("res://assets/value_" + str(target.health) + ".png")
	
	if left_card:
		left_card.health = max(0, left_card.health - 1)
		left_card.get_node("Sprite2D/Control/Health").texture = load("res://assets/value_" + str(left_card.health) + ".png")
	
	if right_card:
		right_card.health = max(0, right_card.health - 1)
		right_card.get_node("Sprite2D/Control/Health").texture = load("res://assets/value_" + str(right_card.health) + ".png")
	
	await timer(1.0)
	
	if target.health == 0:
		if multiplayer.get_unique_id() == player_id:
			destroy_card(target, "enemy")
		else:
			destroy_card(target, "player")
	
	if left_card and left_card.health == 0:
		if multiplayer.get_unique_id() == player_id:
			destroy_card(left_card, "enemy")
		else:
			destroy_card(left_card, "player")
	
	if right_card and right_card.health == 0:
		if multiplayer.get_unique_id() == player_id:
			destroy_card(right_card, "enemy")
		else:
			destroy_card(right_card, "player")

func cannonball(shots, damage):
	var player_id = multiplayer.get_unique_id()
	cannonball_here_and_for_client(player_id, shots, damage)
	rpc("cannonball_here_and_for_client", player_id, shots, damage)
	await timer(float(shots) * 0.8)

@rpc("any_peer")
func cannonball_here_and_for_client(player_id, shots, damage):
	var cards_on_field
	if multiplayer.get_unique_id() == player_id:
		cards_on_field = enemy_cards_on_field.duplicate()
	else:
		cards_on_field = player_cards_on_field.duplicate()
	
	for i in range(shots):
		var targets = []
		for card in cards_on_field:
			if card.health > 0:
				targets.append({"type": "card", "ref": card})
		targets.append({"type": "player"})
		
		var target = targets.pick_random()
		
		if target.type == "card":
			var card = target.ref
			card.health = max(0, card.health - damage)
			card.get_node("Sprite2D/Control/Health").texture = load("res://assets/value_" + str(card.health) + ".png")
			
			if card.health == 0:
				cards_on_field.erase(card)
				await timer(0.3)
				if multiplayer.get_unique_id() == player_id:
					destroy_card(card, "enemy")
				else:
					destroy_card(card, "player")
		else:
			if multiplayer.get_unique_id() == player_id:
				enemy_health = max(0, enemy_health - damage)
				get_parent().get_parent().get_node("EnemyField/EnemyCrystal/EnemyHealth").text = str(enemy_health)
			else:
				player_health = max(0, player_health - damage)
				$"../PlayerCrystal/PlayerHealth".text = str(player_health)
			check_game_over()
		
		await timer(0.5)

func plunder():
	var player_id = multiplayer.get_unique_id()
	plunder_here_and_for_client(player_id)
	rpc("plunder_here_and_for_client", player_id)

@rpc("any_peer")
func plunder_here_and_for_client(player_id):
	if multiplayer.get_unique_id() == player_id:
		var my_energy = $"../EnergyBar"
		my_energy.current_energy = min(my_energy.current_energy + 1, my_energy.max_energy_this_turn)
		my_energy.update_display()
		
		rpc("sync_enemy_energy", player_id, my_energy.current_energy, my_energy.max_energy_this_turn)
	else:
		var my_energy = $"../EnergyBar"
		my_energy.current_energy = max(0, my_energy.current_energy - 1)
		my_energy.update_display()
		
		rpc("sync_enemy_energy", multiplayer.get_unique_id(), my_energy.current_energy, my_energy.max_energy_this_turn)

func warcry():
	var player_id = multiplayer.get_unique_id()
	warcry_here_and_for_client(player_id)
	rpc("warcry_here_and_for_client", player_id)

@rpc("any_peer")
func warcry_here_and_for_client(player_id):
	var cards_on_field
	if multiplayer.get_unique_id() == player_id:
		cards_on_field = player_cards_on_field
	else:
		cards_on_field = enemy_cards_on_field
	
	for card in cards_on_field:
		if card.card_type != "unit":
			continue
		card.attack += 1
		card.get_node("Sprite2D/Control/Attack").texture = load("res://assets/value_" + str(card.attack) + ".png")

func devastation():
	var player_id = multiplayer.get_unique_id()
	devastation_here_and_for_client(player_id)
	rpc("devastation_here_and_for_client", player_id)

@rpc("any_peer")
func devastation_here_and_for_client(_player_id):
	var all_cards = []
	for card in player_cards_on_field:
		if card.health != null:
			all_cards.append({"card": card, "owner": "player"})
	for card in enemy_cards_on_field:
		if card.health != null:
			all_cards.append({"card": card, "owner": "enemy"})
	
	if all_cards.is_empty():
		return
	
	var min_health = all_cards[0].card.health
	for entry in all_cards:
		if entry.card.health < min_health:
			min_health = entry.card.health
	
	for entry in all_cards:
		if entry.card.health == min_health:
			destroy_card(entry.card, entry.owner)

func holy_shield(heal_amount, max_health):
	var player_id = multiplayer.get_unique_id()
	holy_shield_here_and_for_client(player_id, heal_amount, max_health)
	rpc("holy_shield_here_and_for_client", player_id, heal_amount, max_health)

@rpc("any_peer")
func holy_shield_here_and_for_client(player_id, heal_amount, max_health):
	var cards_on_field
	if multiplayer.get_unique_id() == player_id:
		cards_on_field = player_cards_on_field
	else:
		cards_on_field = enemy_cards_on_field
	
	for card in cards_on_field:
		if card.health == null:
			continue
		card.health = min(card.health + heal_amount, max_health)
		card.get_node("Sprite2D/Control/Health").texture = load("res://assets/value_" + str(card.health) + ".png")

func enemy_card_selected(defending_card):
	var attacking_card = $"../CardManager".selected_monster
	
	if waiting_for_spell_target:
		if defending_card in enemy_cards_on_field:
			waiting_for_spell_target = false
			emit_signal("spell_target_selected", defending_card)
		return
	
	if attacking_card:
		if defending_card in enemy_cards_on_field:
			$"../CardManager".selected_monster = null
			attack_card(attacking_card, defending_card)

func timer(time):
	await get_tree().create_timer(time).timeout

func enable_end_turn_btn(is_enable):
	if is_enable:
		$"../EndTurnButton".disabled = false
		$"../EndTurnButton".visible = true
	else:
		$"../EndTurnButton".disabled = true
		$"../EndTurnButton".visible = false

func check_game_over():
	if player_health <= 0:
		await show_game_over(false)
	elif enemy_health <= 0:
		await show_game_over(true)

func show_game_over(player_won: bool):
	await get_tree().create_timer(1.0).timeout
	$"../InputManager".input_disabled = true
	enable_end_turn_btn(false)
	
	var player_id = multiplayer.get_unique_id()
	rpc("show_game_over_here_and_for_client", player_id, player_won)
	show_game_over_here_and_for_client(player_id, player_won)

@rpc("any_peer")
func show_game_over_here_and_for_client(player_id, player_won: bool):
	var won
	if multiplayer.get_unique_id() == player_id:
		won = player_won
	else:
		won = !player_won
	
	get_tree().set_meta("player_won", won)
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
