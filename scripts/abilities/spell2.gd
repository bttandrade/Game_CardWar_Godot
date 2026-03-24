extends Node

const SPELL_DAMAGE = 1
const ABILITY_TRIGGER_EVENT = "card_placed"

func trigger_ability(battle_manager_reference, input_manager_reference, this_card, trigger_event):
	if ABILITY_TRIGGER_EVENT != trigger_event:
		return
		
	input_manager_reference.input_disabled = true
	battle_manager_reference.enable_end_turn_btn(false)
	
	await battle_manager_reference.timer(1.0)
	
	battle_manager_reference.direct_damage(SPELL_DAMAGE)
	
	await battle_manager_reference.timer(1.0)
	
	input_manager_reference.input_disabled = false
	battle_manager_reference.enable_end_turn_btn(true)
	
	battle_manager_reference.destroy_magic_card(this_card)

func reset_ability():
	pass
