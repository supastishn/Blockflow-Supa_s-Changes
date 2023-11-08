## Modifying values here requires a plugin reload after save.

const DEFAULT_COMMAND_PATHS = [
	"res://addons/blockflow/commands/command_call.gd",
	"res://addons/blockflow/commands/command_animate.gd",
	"res://addons/blockflow/commands/command_comment.gd",
	"res://addons/blockflow/commands/command_condition.gd",
	"res://addons/blockflow/commands/command_goto.gd",
	"res://addons/blockflow/commands/command_return.gd",
	"res://addons/blockflow/commands/command_set.gd",
	"res://addons/blockflow/commands/command_wait.gd",
	"res://addons/blockflow/commands/command_end.gd",
	]

const PROJECT_SETTING_DEFAULT_COMMANDS =\
"blockflow/settings/commands/default_commands"
const PROJECT_SETTING_CUSTOM_COMMANDS =\
"blockflow/settings/commands/custom_commands"

const PROJECT_SETTING_BLOCK_ICON_MIN_SIZE =\
"blockflow/settings/editor/commands/icon_minimun_size"
const BLOCK_ICON_MIN_SIZE = 32

const Utils = preload("res://addons/blockflow/core/utils.gd")

# Made to ensure that classes are loaded before class_name populates editor
const CollectionClass = preload("res://addons/blockflow/collection.gd")
const CommandCollectionClass = preload("res://addons/blockflow/command_collection.gd")
const CommandClass = preload("res://addons/blockflow/commands/command.gd")
const CommandProcessorClass = preload("res://addons/blockflow/command_processor.gd")
const TimelineClass = preload("res://addons/blockflow/timeline.gd")

enum Toast {
	SEVERITY_INFO,
	SEVERITY_WARNING,
	SEVERITY_ERROR
	}

class CollectionData:
	var main_collection:CollectionClass
	var command_list:Array[CommandClass]
	var bookmarks:Dictionary

static func generate_tree(collection:CollectionClass) -> CollectionData:
#	if collection.is_updating_data: return
	collection.is_updating_data = true
	
	var data := CollectionData.new()
	
	var command_pt:CommandClass
	
	if collection.is_empty():
		return data
	
	var command_list:Array[CommandClass] = []
	var owner:CollectionClass
	command_pt = collection.collection[0]
	
	for command in collection.collection:
		_recursive_add(command, command_list)
	
	var position:int = 0
	var bookmarks := {}
	for command_position in command_list.size():
		command_pt = command_list[command_position]
		command_pt.position = command_position
		command_pt.weak_collection = weakref(collection as CommandCollectionClass)
	
	data.command_list = command_list
	data.bookmarks = bookmarks
	data.main_collection = collection
	
	if collection is CommandCollectionClass:
		command_list.make_read_only()
		collection._bookmarks = bookmarks
		collection._command_list = command_list
#	collection.set("data", data)
	
	collection.is_updating_data = false
	
	return data

static func _recursive_add(command, to) -> void:
	to.append(command)
	for subcommand in command:
		_recursive_add(subcommand, to)

static func move_to_collection(command, to_collection, to_position=0) -> void:
	var owner_collection = command.get_command_owner()
	owner_collection.erase(command)
	to_collection.insert(command, to_position)
#	var idx = to_position if to_position > -1 else to_collection.collection.size()
#	to_collection.collection.insert(idx, command)
#	owner_collection.emit_changed()
#	to_collection.emit_changed()
#	owner_collection._notify_changed()
#	to_collection._notify_changed()
