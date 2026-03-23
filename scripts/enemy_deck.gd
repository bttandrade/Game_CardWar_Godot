extends Node2D

const CARD_SCENE_PATH = preload("res://entities/enemy_card.tscn")
const CARD_DRAW_SPEED = 0.2
const STARTING_HAND_SIZE = 4

var enemy_deck = ["green_dual", "green_warrior", "green_dual", "green_warrior", "green_warrior","green_dual", "green_warrior", "green_warrior"]
var card_database_reference

func _ready() -> void:
	enemy_deck.shuffle()
	$Label.text = str(enemy_deck.size())
	card_database_reference = preload("res://scripts/card_database.gd")
	for i in range(STARTING_HAND_SIZE):
		draw_card()

func draw_card():
	if enemy_deck.size() == 0:
		return
		
	var card_drawn = enemy_deck[0]
	enemy_deck.erase(card_drawn)
	
	if enemy_deck.size() == 0:
		#$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$Label.visible = false
	
	$Label.text = str(enemy_deck.size())
	var card_scene = CARD_SCENE_PATH
	var new_card = card_scene.instantiate()

	new_card.scale = Vector2(1,1)
	
	var card_texture = str(card_drawn)
	var attack_value = str(card_database_reference.CARDS[card_drawn][0])
	var health_value = str(card_database_reference.CARDS[card_drawn][1])
	
	new_card.attack = card_database_reference.CARDS[card_drawn][0]
	new_card.health = card_database_reference.CARDS[card_drawn][1]
	
	new_card.get_node("Sprite2D").texture = load("res://assets/card_" + card_texture + ".png")
	new_card.get_node("Sprite2D/Control/Attack").texture = load("res://assets/value_" + attack_value + ".png")
	new_card.get_node("Sprite2D/Control/Health").texture = load("res://assets/value_" + health_value + ".png")
	new_card.card_type = card_database_reference.CARDS[card_drawn][2]
	
	$"../CardManager".add_child(new_card)
	new_card.position = position
	new_card.name = "Card"
	$"../EnemyHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
	#new_card.get_node("AnimationPlayer").play("card_flip")
