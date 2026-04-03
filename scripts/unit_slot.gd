extends Node2D

var card_in_slot = false
var card_slot_type = "unit"

func _ready() -> void:
	$Sprite2D.texture = load("res://assets/unit_slot.png")
