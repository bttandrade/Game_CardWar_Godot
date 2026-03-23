extends Node2D

const CARD_SCENE_PATH = preload("res://entities/player_card.tscn")
const CARD_DRAW_SPEED = 0.2
const STARTING_HAND_SIZE = 4

var player_deck = ["human_tornado", "green_dual", "human_tornado", "human_tornado", "green_dual", "green_dual", "human_archer", "human_archer"]
var card_database_reference
var drawn_card_this_turn = false

func _ready() -> void:
	player_deck.shuffle()
	$Label.text = str(player_deck.size())
	card_database_reference = preload("res://scripts/card_database.gd")
	for i in range(STARTING_HAND_SIZE):
		draw_card()
		drawn_card_this_turn = false
	#drawn_card_this_turn = true

func draw_card():
	if drawn_card_this_turn:
		return
	drawn_card_this_turn = true
	
	var card_drawn = player_deck[0]
	player_deck.erase(card_drawn)
	
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$Label.visible = false
	
	$Label.text = str(player_deck.size())
	var card_scene = CARD_SCENE_PATH
	var new_card = card_scene.instantiate()
	
	var card_texture = str(card_drawn)
	var attack_value = str(card_database_reference.CARDS[card_drawn][0])
	var health_value = str(card_database_reference.CARDS[card_drawn][1])
	
	new_card.get_node("Sprite2D").texture = load("res://assets/card_" + card_texture + ".png")
	new_card.card_type = card_database_reference.CARDS[card_drawn][2]
	
	if new_card.card_type == "unit":
		#new_card.get_node("Label").visible = false
		new_card.attack = card_database_reference.CARDS[card_drawn][0]
		new_card.health = card_database_reference.CARDS[card_drawn][1]
		
		new_card.get_node("Sprite2D/Control/Attack").texture = load("res://assets/value_" + attack_value + ".png")
		new_card.get_node("Sprite2D/Control/Health").texture = load("res://assets/value_" + health_value + ".png")
	else:
		new_card.get_node("Sprite2D/Control/Attack").visible = false
		new_card.get_node("Sprite2D/Control/Health").visible = false
	new_card.get_node("Sprite2D/Control/Label").text = card_database_reference.CARDS[card_drawn][3]
	var new_card_ability_script_path = card_database_reference.CARDS[card_drawn][4]
	if new_card_ability_script_path:
		new_card.ability_script = load(new_card_ability_script_path).new()
	else:
		new_card.get_node("Sprite2D/Control/Label").visible = false
		
	$"../CardManager".add_child(new_card)
	new_card.position = position
	new_card.name = "Card"
	$"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
	new_card.get_node("AnimationPlayer").play("card_flip")

func reset_draw():
	drawn_card_this_turn = false
