extends Node2D

signal left_mouse_button_clicked
signal left_mouse_button_released

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_ENEMY_CARD = 8

var card_manager_reference
var input_disabled = true

func _ready() -> void:
	card_manager_reference = $"../CardManager"

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			emit_signal("left_mouse_button_clicked")
			raycast_at_cursor()
		else:
			emit_signal("left_mouse_button_released")

func raycast_at_cursor():
	if input_disabled:
		return
	var space_state = get_viewport().world_2d.direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	
	if result.size() > 0:
		for hit in result:
			var mask = hit.collider.collision_mask
			if mask == COLLISION_MASK_CARD:
				var card_found = hit.collider.get_parent()
				if card_found:
					card_manager_reference.card_clicked(card_found)
				return
			elif mask == COLLISION_MASK_ENEMY_CARD:
				$"../BattleManager".enemy_card_selected(hit.collider.get_parent())
				return
