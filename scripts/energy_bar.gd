extends Node2D

const MAX_ENERGY = 7
const STARTING_ENERGY = 3
const ENERGY_SCENE = preload("res://entities/energy.tscn")
const ENERGY_SPACING = 50

signal energy_spent(current, maximum)

var is_enemy = false
var current_energy = 0
var max_energy_this_turn = STARTING_ENERGY

func _ready() -> void:
	update_display()
	
func on_turn_start():
	max_energy_this_turn = min(max_energy_this_turn + 1, MAX_ENERGY)
	current_energy = min(current_energy + 1, max_energy_this_turn)
	update_display()

func spend_energy(amount) -> bool:
	if current_energy < amount:
		return false
	current_energy -= amount
	update_display()
	emit_signal("energy_spent", current_energy, max_energy_this_turn)
	return true

func set_energy(current, maximum):
	current_energy = current
	max_energy_this_turn = maximum
	update_display()

func update_display():
	for child in get_children():
		child.queue_free()
	
	var direction = 1 if is_enemy else -1
	
	for i in range(current_energy):
		var energy = ENERGY_SCENE.instantiate()
		energy.position = Vector2(0, i * ENERGY_SPACING * direction)
		add_child(energy)
