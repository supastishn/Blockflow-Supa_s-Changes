@tool
extends Command

const _Utils = preload("res://addons/blockflow/core/utils.gd")

var use_bookmark:bool:
	set(value):
		use_bookmark = value
		emit_changed()
		notify_property_list_changed()
	get: return use_bookmark
var by_index:int:
	set(value):
		by_index = value
		emit_changed()
	get: return by_index
var by_bookmark:String:
	set(value):
		by_bookmark = value
		emit_changed()
	get: return by_bookmark
var go_to_timeline:bool:
	set(value):
		go_to_timeline = value
		emit_changed()
		notify_property_list_changed()
	get: return go_to_timeline
var timeline:Timeline:
	set(value):
		timeline = value
		emit_changed()
	get: return timeline

var on_condition:String:
	set(value):
		on_condition = value
		emit_changed()
	get:
		return on_condition

func _execution_steps() -> void:
	command_started.emit()
	
	# A conditional is set on this command
	if not on_condition.is_empty():
		# TODO: replace with node variables, for ex. command_manager.get_property_list()
		var variables:Dictionary = {}
		var evaluated_condition = _Utils.evaluate(on_condition, command_manager, variables)
		
		# Do not move on unless the conditional is true
		if not (evaluated_condition and (str(evaluated_condition) != on_condition)):
			# The only time command_finished is emitted for goto event
			command_finished.emit()
			return

	var target_idx = by_index
	if go_to_timeline:
		if use_bookmark:
			var target_command = command_manager.timeline.get_command_by_bookmark(by_bookmark)
			target_idx = command_manager.timeline.get_command_idx(target_command)
		command_manager.timeline = timeline
		command_manager.start_timeline(target_idx)
	else:
		if use_bookmark:
			var target_command = command_manager.timeline.get_command_by_bookmark(by_bookmark)
			target_idx = command_manager.timeline.get_command_idx(target_command)
		command_manager.go_to_command(target_idx)



func _get_name() -> String:
	return "Go To"


func _get_hint() -> String:
	var hint_str = ""
	if use_bookmark:
		hint_str += "bookmark: " + by_bookmark
	else:
		hint_str += "index: " + str(by_index)
	if go_to_timeline:
		hint_str += " on "
		if timeline != null:
			hint_str += "timeline "
			if timeline.resource_name.is_empty():
				hint_str += "'" + timeline.resource_path + "'"
			else:
				hint_str += "'" + timeline.resource_name + "'"
		else:
			hint_str += "<Invalid Timeline!>"
	if on_condition:
		hint_str += " if " + str(on_condition)
	return hint_str


func _get_icon() -> Texture:
	return load("res://addons/blockflow/icons/jump.svg")


func _get_property_list():
	var tl_usage = PROPERTY_USAGE_NO_EDITOR
	if go_to_timeline:
		tl_usage = PROPERTY_USAGE_DEFAULT

	var bm_usage = PROPERTY_USAGE_NO_EDITOR
	var idx_usage = PROPERTY_USAGE_DEFAULT
	if use_bookmark:
		bm_usage = PROPERTY_USAGE_DEFAULT
		idx_usage = PROPERTY_USAGE_NO_EDITOR

	var properties = [
		{
			"name": "use_bookmark",
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
		{
			"name": "by_index",
			"type": TYPE_INT,
			"usage": idx_usage,
		},
		{
			"name": "by_bookmark",
			"type": TYPE_STRING,
			"usage": bm_usage,
		},
		{
			"name": "go_to_timeline",
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
		{
			"name": "timeline",
			"type": TYPE_OBJECT,
			"class_name": "Timeline",
			"usage": tl_usage,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string": "Timeline"
		},
		{
			"name": "on_condition",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
	]

	return properties
