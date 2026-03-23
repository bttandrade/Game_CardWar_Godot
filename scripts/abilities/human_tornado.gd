extends Node

const TORNADO_DAMAGE = 1
const ABILITY_TRIGGER_EVENT = "card_placed"

func trigger_ability(battle_manager_reference, input_manager_reference, this_card, trigger_event):
	if ABILITY_TRIGGER_EVENT != trigger_event:
		return
		
	var cards_to_destroy = []
	
	input_manager_reference.input_disabled = true
	battle_manager_reference.enable_end_turn_btn(false)
	
	await battle_manager_reference.timer(1.0)
	
	for card in battle_manager_reference.enemy_cards_on_field:
		card.health = max(0, card.health - TORNADO_DAMAGE)
		card.get_node("Sprite2D/Control/Health").texture = load("res://assets/value_" + str(card.health) + ".png")
		
		if card.health == 0:
			cards_to_destroy.append(card)
			
	await battle_manager_reference.timer(1.0)
	if cards_to_destroy.size() > 0:
		for card in cards_to_destroy:
			battle_manager_reference.destroy_card(card, "enemy")
	
	#await battle_manager_reference.timer(1.0)
	
	battle_manager_reference.destroy_card(this_card, "player")
	
	input_manager_reference.input_disabled = false
	battle_manager_reference.enable_end_turn_btn(true)
