extends Command

func _execution_steps(manager) -> void:
	pass


func _get_command_name() -> String:
	return "Go To"


func _get_command_icon() -> Texture:
	return load("res://icon.svg")
