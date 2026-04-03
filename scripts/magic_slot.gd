extends Node2D

var card_in_slot = false
var card_slot_type = "magic"

func _ready() -> void:
	$Sprite2D.texture = load("res://assets/magic_slot.png")
