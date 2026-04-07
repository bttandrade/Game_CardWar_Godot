extends Node2D

const COIN_SCENE = preload("res://entities/coin.tscn")
const MAX_COINS = 7
const AREA_WIDTH = 150
const AREA_HEIGHT = 80
const MAX_ATTEMPTS = 30

var current_coins = 0
var is_enemy = false

signal coins_spent(current)

func on_turn_start(coins_to_add: int):
	var space = MAX_COINS - current_coins
	var actual_add = min(coins_to_add, space)
	for i in range(actual_add):
		spawn_coin()

func spawn_coin():
	if current_coins >= MAX_COINS:
		return
	
	var final_pos = find_free_position()
	
	var coin = COIN_SCENE.instantiate()
	coin.final_pos = final_pos
	
	var screen_width = get_viewport_rect().size.x
	var start_x = -screen_width / 2.0 if not is_enemy else screen_width / 2.0
	coin.position = Vector2(start_x, final_pos.y)
	
	add_child(coin)
	current_coins += 1
	
	var tween = get_tree().create_tween()
	tween.tween_property(coin, "position", final_pos, 0.4).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

func find_free_position() -> Vector2:
	var final_positions = []
	for child in get_children():
		if child.has_method("get") and child.get("final_pos") != null:
			final_positions.append(child.final_pos)
	
	for attempt in range(MAX_ATTEMPTS):
		var candidate = Vector2(
			randf_range(-AREA_WIDTH / 2.0, AREA_WIDTH / 2.0),
			randf_range(-AREA_HEIGHT / 2.0, AREA_HEIGHT / 2.0)
		)
		var valid = true
		for pos in final_positions:
			if candidate.distance_to(pos) < MIN_DISTANCE:
				valid = false
				break
		if valid:
			return candidate
	
	return Vector2(
		randf_range(-AREA_WIDTH / 2.0, AREA_WIDTH / 2.0),
		randf_range(-AREA_HEIGHT / 2.0, AREA_HEIGHT / 2.0)
	)

const MIN_DISTANCE = 24

func spend_coins(amount) -> bool:
	if current_coins < amount:
		return false
	var removed = 0
	var children = get_children().duplicate()
	for coin in children:
		if removed >= amount:
			break
		coin.queue_free()
		removed += 1
	current_coins -= amount
	emit_signal("coins_spent", current_coins)
	return true

func set_coins(count: int):
	if count > current_coins:
		var to_add = count - current_coins
		for i in range(to_add):
			spawn_coin()
	elif count < current_coins:
		var to_remove = current_coins - count
		var children = get_children().duplicate()
		for i in range(to_remove):
			if i < children.size():
				children[i].queue_free()
		current_coins = count
