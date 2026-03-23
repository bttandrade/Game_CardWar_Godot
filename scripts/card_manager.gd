extends Node2D

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_SLOT = 2
const DEFAULT_CARD_MOVE_SPEED = 0.2
const DEFAULT_CARD_SCALE = 1
const DEFAULT_CARD_BIGGER_SCALE = 1.05
const DEFAULT_CARD_IN_SLOT_SCALE = 0.8

var screen_size
var card_being_dragged
var hovered_card = null
var player_hand_reference
var selected_monster

func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	$"../InputManager".connect("left_mouse_button_released", on_left_clicked_released)

func _process(_delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x), 
			clamp(mouse_pos.y, 0, screen_size.y))

func start_drag(card):
	card.scale = Vector2(DEFAULT_CARD_SCALE, DEFAULT_CARD_SCALE)
	card_being_dragged = card

func card_clicked(card):
	if card.card_is_in_slot:
		if $"../BattleManager".is_enemy_turn:
			return
	
		if card in $"../BattleManager".player_cards_that_attacked_this_turn:
			return
		
		if card.card_type != "unit":
			return
		
		if $"../BattleManager".enemy_cards_on_field.size() == 0:
			$"../BattleManager".attack_player(card, "player")
		else:
			select_card_for_battle(card)
	else:
		start_drag(card)

func select_card_for_battle(card):
	if selected_monster == card:
		card.position.y += 6
		selected_monster = null
		return

	if selected_monster != null:
		selected_monster.position.y += 6

	selected_monster = card
	card.position.y -= 6

func unselect_selected_unit():
	if selected_monster:
		selected_monster.position.y += 10
		selected_monster = null

func finish_drag():
	highlight_card(card_being_dragged, false)
	
	var card_slot_found = raycast_check_for_slot()
	if card_slot_found and not card_slot_found.card_in_slot:
		if card_being_dragged.card_type == card_slot_found.card_slot_type:
			card_being_dragged.scale = Vector2(DEFAULT_CARD_IN_SLOT_SCALE, DEFAULT_CARD_IN_SLOT_SCALE)
			card_being_dragged.z_index = -1
			card_being_dragged.card_is_in_slot = card_slot_found
			player_hand_reference.remove_card_from_hand(card_being_dragged)
			card_being_dragged.global_position = card_slot_found.global_position
			card_slot_found.get_node("Area2D/CollisionShape2D").disabled = true
			card_slot_found.card_in_slot = true
			
			if card_being_dragged.card_type == "unit":
				$"../BattleManager".player_cards_on_field.append(card_being_dragged)
			if card_being_dragged.ability_script:
				card_being_dragged.ability_script.trigger_ability($"../BattleManager", $"../InputManager", card_being_dragged, "card_placed")
			card_being_dragged = null
			return
	player_hand_reference.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
	card_being_dragged = null

func raycast_check_for_card():
	var space_state = get_viewport().world_2d.direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return get_card_with_highest_z_index(result)
	return null

func raycast_check_for_slot():
	var space_state = get_viewport().world_2d.direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card

func connect_card_signals(card):
	card.connect("hovered_over", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)

func on_hovered_over_card(card):
	#if card.card_is_in_slot:
		#return
		
	if card_being_dragged:
		return
	
	if hovered_card and hovered_card != card:
		highlight_card(hovered_card, false)

	hovered_card = card
	highlight_card(card, true)

func on_hovered_off_card(card):
	if !card.card_is_in_slot:
		if card_being_dragged:
			return

		if hovered_card == card:
			highlight_card(card, false)
			hovered_card = null

		var new_card_hovered = raycast_check_for_card()
		if new_card_hovered:
			on_hovered_over_card(new_card_hovered)

func highlight_card(card, hovered):
	if hovered:
		card.scale = Vector2(DEFAULT_CARD_BIGGER_SCALE, DEFAULT_CARD_BIGGER_SCALE)
		card.z_index = 2
	else:
		card.scale = Vector2(DEFAULT_CARD_SCALE, DEFAULT_CARD_SCALE)
		card.z_index = 1

func on_left_clicked_released():
	if card_being_dragged:
		finish_drag()
