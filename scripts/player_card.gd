extends Node2D

signal hovered_over
signal hovered_off

var card_hand_position
var card_is_in_slot
var card_type
var health
var attack
var ability_script
var cost = 1

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered_over", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
