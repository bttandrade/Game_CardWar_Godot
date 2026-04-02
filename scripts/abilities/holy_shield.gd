extends Node

const ABILITY_TRIGGER_EVENT = "card_placed"
const HEAL_AMOUNT = 2
const MAX_HEALTH = 9

func trigger_ability(battle_manager_reference, _input_manager_reference, _this_card, trigger_event):
	if ABILITY_TRIGGER_EVENT != trigger_event:
		return
	
	battle_manager_reference.holy_shield(HEAL_AMOUNT, MAX_HEALTH)

func reset_ability():
	pass
