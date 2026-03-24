extends Node

const ABILITY_TRIGGER_EVENT = "after_attack"

var already_activated = false

func trigger_ability(battle_manager_reference, _input_manager_reference, this_card, trigger_event):
	if ABILITY_TRIGGER_EVENT != trigger_event:
		return
	
	if already_activated:
		return
	
	if this_card in battle_manager_reference.player_cards_that_attacked_this_turn:
		battle_manager_reference.player_cards_that_attacked_this_turn.erase(this_card)
		already_activated = true

func reset_ability():
	already_activated = false
