extends Node2D

const CARD_WIDTH = 120
const HAND_Y_POSITION = 650
const DEFAULT_CARD_MOVE_SPEED = 0.2
const MAX_ROTATION_DEGREES = 8.0
const Y_CURVE_STRENGTH = 4
const MAX_HAND_SIZE = 8

var player_hand = []
var center_screen_x

func _ready() -> void:
	center_screen_x = get_viewport_rect().size.x / 2

func add_card_to_hand(card, speed):
	if card not in player_hand:
		if player_hand.size() >= MAX_HAND_SIZE:
			get_parent().get_parent().get_parent().get_node("Announcement").show_message("Mão cheia! Jogue uma carta primeiro.", 2.0)
			return false
		player_hand.insert(0, card)
		update_hand_position(speed)
	else:
		animate_card_to_position(card, card.card_hand_position, DEFAULT_CARD_MOVE_SPEED)
	return true

func update_hand_position(speed):
	var count = player_hand.size()
	for i in range(count):
		var center_index = (count - 1) / 2.0
		var offset = i - center_index
		var x = calculate_card_position(i)
		var y = HAND_Y_POSITION - (player_hand.size() * 5) + offset * offset * Y_CURVE_STRENGTH
		var rotation_deg = offset * (MAX_ROTATION_DEGREES / max(center_index, 1))
		var card = player_hand[i]
		card.card_hand_position = Vector2(x, y)
		animate_card_to_position(card, Vector2(x, y), speed)
		var tween = get_tree().create_tween()
		tween.tween_property(card, "rotation_degrees", rotation_deg, speed)

func calculate_card_position(index):
	var dynamic_width = max(40, CARD_WIDTH - (player_hand.size() * 8))
	var total_width = (player_hand.size() - 1) * dynamic_width
	var x_offset = center_screen_x + index * dynamic_width - total_width / 2.0
	return x_offset

func animate_card_to_position(card, new_position, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_position(DEFAULT_CARD_MOVE_SPEED)
