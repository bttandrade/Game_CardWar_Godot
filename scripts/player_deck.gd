extends Node2D

const CARD_SCENE_PATH = preload("res://entities/player_card.tscn")
const CARD_DRAW_SPEED = 0.2
const STARTING_HAND_SIZE = 4

var hero_deck = ["hero_soldier", "hero_archer", "hero_duelist", "hero_mage", "hero_knight", "hero_spear", "hero_spell1", "hero_spell2"]
var villain_deck = ["villain_soldier", "villain_archer", "villain_death", "villain_trident", "villain_demon", "villain_pyro", "villain_spell1", "villain_spell2"]
var chosen_deck = []
var card_database_reference
var drawn_card_this_turn = false

func _ready() -> void:
	chosen_deck = hero_deck
	chosen_deck.shuffle()
	card_database_reference = preload("res://scripts/card_database.gd")

func draw_initial_hand():
	await get_tree().create_timer(1.0).timeout
	var player_id = multiplayer.get_unique_id()
	
	for i in range(STARTING_HAND_SIZE):
		var card_drawn_name = chosen_deck[0]
		
		draw_here_and_for_client(player_id, card_drawn_name)
		rpc("draw_here_and_for_client", player_id, card_drawn_name)
		drawn_card_this_turn = false
		await get_tree().create_timer(0.1).timeout
	drawn_card_this_turn = true

@rpc("any_peer")
func draw_here_and_for_client(player_id, card_drawn_name):
	if multiplayer.get_unique_id() == player_id:
		draw_card(card_drawn_name)
	else:
		get_parent().get_parent().get_node("EnemyField/EnemyDeck").draw_card(card_drawn_name)

func deck_clicked():
	if drawn_card_this_turn:
		return
	var player_id = multiplayer.get_unique_id()
	var card_drawn_name = chosen_deck[0]
	
	draw_here_and_for_client(player_id, card_drawn_name)
	rpc("draw_here_and_for_client", player_id, card_drawn_name)

func draw_card(card_drawn_name):
	drawn_card_this_turn = true
	
	chosen_deck.erase(card_drawn_name)
	
	if chosen_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		visible = false
	
	$Label.text = str(chosen_deck.size())
	var card_scene = CARD_SCENE_PATH
	var new_card = card_scene.instantiate()
	
	var card_texture = str(card_drawn_name)
	var attack_value = str(card_database_reference.CARDS[card_drawn_name][0])
	var health_value = str(card_database_reference.CARDS[card_drawn_name][1])
	
	new_card.get_node("Sprite2D").texture = load("res://assets/card_" + card_texture + ".png")
	new_card.card_type = card_database_reference.CARDS[card_drawn_name][2]
	
	if new_card.card_type == "unit":
		new_card.attack = card_database_reference.CARDS[card_drawn_name][0]
		new_card.health = card_database_reference.CARDS[card_drawn_name][1]
		new_card.get_node("Sprite2D/Control/Attack").texture = load("res://assets/value_" + attack_value + ".png")
		new_card.get_node("Sprite2D/Control/Health").texture = load("res://assets/value_" + health_value + ".png")
	else:
		new_card.get_node("Sprite2D/Control/Attack").visible = false
		new_card.get_node("Sprite2D/Control/Health").visible = false
	new_card.get_node("Sprite2D/Control/Label").text = card_database_reference.CARDS[card_drawn_name][3]
	var new_card_ability_script_path = card_database_reference.CARDS[card_drawn_name][4]
	if new_card_ability_script_path:
		new_card.ability_script = load(new_card_ability_script_path).new()

	$"../CardManager".add_child(new_card)
	$"../CardManager".connect_card_signals(new_card)
	new_card.position = position
	new_card.name = "Card"
	$"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
	new_card.get_node("AnimationPlayer").play("card_flip")

func reset_draw():
	drawn_card_this_turn = false
