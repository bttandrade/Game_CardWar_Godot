extends Node2D

const CARD_SCENE_PATH = preload("res://entities/enemy_card.tscn")
const CARD_DRAW_SPEED = 0.2
const STARTING_HAND_SIZE = 4

var player_deck_reference
var card_database_reference
var deck_size

func _ready() -> void:
	card_database_reference = preload("res://scripts/card_database.gd")
	player_deck_reference = get_parent().get_parent().get_node("PlayerField/PlayerDeck")

func draw_card(card_drawn_name):
	if deck_size - 1 == 0:
		visible = false
	else:
		deck_size -= 1
		$Label.text = str(deck_size)

	var card_scene = CARD_SCENE_PATH
	var new_card = card_scene.instantiate()

	new_card.scale = Vector2(1,1)
	
	var card_texture = str(card_drawn_name)
	var attack_value = str(card_database_reference.CARDS[card_drawn_name][0])
	var health_value = str(card_database_reference.CARDS[card_drawn_name][1])
	
	new_card.attack = card_database_reference.CARDS[card_drawn_name][0]
	new_card.health = card_database_reference.CARDS[card_drawn_name][1]
	
	if get_tree().get_meta("enemy_deck") == "villain":
		new_card.get_node("Sprite2D2").texture = load("res://assets/card_villain_back.png")
	
	new_card.get_node("Sprite2D").texture = load("res://assets/card_" + card_texture + ".png")
	new_card.card_type = card_database_reference.CARDS[card_drawn_name][2]
	if new_card.card_type == "unit":
		new_card.get_node("Sprite2D/Control/Attack").texture = load("res://assets/value_" + attack_value + ".png")
		new_card.get_node("Sprite2D/Control/Health").texture = load("res://assets/value_" + health_value + ".png")
	
	var ability_text = card_database_reference.CARDS[card_drawn_name][3]
	var label = new_card.get_node_or_null("Sprite2D/Control/Label")
	if label:
		if ability_text != "":
			label.text = ability_text
			label.visible = true
		else:
			label.visible = false
	
	$"../CardManager".add_child(new_card)
	new_card.position = position
	new_card.name = "Card"
	$"../EnemyHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
