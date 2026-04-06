extends Label

func show_message(message: String, duration: float = 2.0):
	text = message
	visible = true
	await get_tree().create_timer(duration).timeout
	visible = false
