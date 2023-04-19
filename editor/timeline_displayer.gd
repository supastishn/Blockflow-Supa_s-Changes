@tool
extends Tree

const TimelineClass = preload("res://addons/blockflow/timeline.gd")
const FALLBACK_ICON = preload("res://icon.svg")


var _current_timeline:TimelineClass

var root:TreeItem

func load_timeline(timeline:TimelineClass) -> void:
	_current_timeline = timeline
	_reload()


func _reload() -> void:
	clear()
	
	if not _current_timeline:
		return
	
	var timeline_name:String = _current_timeline.resource_name
	if timeline_name.is_empty():
		timeline_name = _current_timeline.resource_path.get_file()
	
	set_column_custom_minimum_width(0, 164)
	
	root = create_item()
	root.custom_minimum_height = 32
	
	for i in columns:
		root.set_expand_right(i, false)
	
	root.set_text(0, timeline_name)
	root.set_expand_right(0, true)
	root.set_text_alignment(0, HORIZONTAL_ALIGNMENT_LEFT)
	root.set_text(columns-1, str(_current_timeline.commands.size()))
	# See this little trick here? Is to remove the column expand.
	# I hate it.
	#root.set_text(columns-1, " ")
	
	var commands:Array = _current_timeline.commands
	for command_idx in commands.size():
		var item:TreeItem = create_item(root)
		var command:Command = commands[command_idx] as Command
		
		if not command:
			assert(command)
			load_timeline(null)
			return
	
		item.set_metadata(0, command)
		if not command.changed.is_connected(_build_item):
			command.changed.connect(_build_item.bind(item, command))
		
		_build_item(item, command)


func _build_item(item:TreeItem, command:Command) -> void:
	var hint:String = ""
	var bookmark:Texture = null
	var command_name:String = command.get_command_name()
	var command_icon:Texture = command.get_icon()
	if not command_icon:
		command_icon = FALLBACK_ICON
	var command_hint:String = command.get_hint()
	var command_hint_icon:Texture = command.get_hint_icon()
	
	if not command.label.is_empty():
		hint += "Label:\n"+command.label
		bookmark = load("res://addons/blockflow/icons/bookmark.svg")
	
	for i in columns:
		item.set_icon_max_width(i, 32)
	
	item.set_text(0, command_name)
	item.set_icon(0, command_icon)
	
	item.set_text(1, command_hint)
	item.set_icon(1, command_hint_icon)
	
	var disabled_color = get_theme_color("disabled_font_color", "Editor")
	item.set_text(columns-1, str(_current_timeline.get_command_idx(command)))
	item.set_custom_color(columns-1, disabled_color)
	item.set_text_alignment(columns-1, HORIZONTAL_ALIGNMENT_RIGHT)
	
	item.set_icon(2, bookmark)
	item.set_icon_modulate(2, disabled_color)
	item.set_tooltip_text(2, hint)


func _init() -> void:
	columns = 3
	allow_rmb_select = true
	select_mode = SELECT_ROW
	scroll_horizontal_enabled = false
	
	set_column_expand(0, false)
	set_column_expand(1, true)
	set_column_expand(2, false)
	