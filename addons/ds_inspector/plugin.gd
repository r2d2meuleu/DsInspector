@tool
extends EditorPlugin

var debug_tool: Node
var tool_menu: PopupMenu
var save_config: SaveConfig

# Language selection - can be referenced by other scripts
# Available languages: "cn", "en"
static var current_language: String = "cn"

func _enter_tree():
	# 创建工具菜单
	tool_menu = PopupMenu.new()
	tool_menu.add_check_item(I18nManager.tr("MENU_RUN_IN_EDITOR"), 0)
	tool_menu.add_check_item(I18nManager.tr("MENU_RUN_IN_GAME"), 1)
	tool_menu.add_separator()
	tool_menu.add_submenu_item("Language", _create_language_menu())
	
	SaveConfig.save_path = "user://ds_inspector_editor_config.json"
	# 设置初始状态
	save_config = SaveConfig.new()
	add_child(save_config)

	# Load saved language or use default
	current_language = save_config.get_language()

	tool_menu.set_item_checked(0, save_config.get_enable_in_editor())
	tool_menu.set_item_checked(1, save_config.get_enable_in_game())

	# 连接信号
	tool_menu.connect("id_pressed", Callable(self, "_on_tool_menu_pressed"))

	# 添加到工具菜单
	add_tool_submenu_item("DsInspector", tool_menu)

	_refresh_debug_tool(save_config.get_enable_in_editor())
	_refresh_debug_tool_in_game(save_config.get_enable_in_game())

func _exit_tree():
	remove_tool_menu_item("DsInspector")
	if save_config.get_enable_in_game():
		remove_autoload_singleton("DsInspector")
	if debug_tool != null:
		debug_tool.free()
		debug_tool = null

func _create_language_menu() -> PopupMenu:
	var lang_menu = PopupMenu.new()
	lang_menu.add_radio_check_item("中文 (Chinese)", 0)
	lang_menu.add_radio_check_item("English", 1)
	
	# Set initial language selection
	if current_language == "cn":
		lang_menu.set_item_checked(0, true)
	else:
		lang_menu.set_item_checked(1, true)
	
	lang_menu.connect("id_pressed", Callable(self, "_on_language_menu_pressed"))
	return lang_menu

func _on_language_menu_pressed(id: int):
	var lang_menu = tool_menu.get_popup()
	if id == 0:  # Chinese
		current_language = "cn"
		lang_menu.set_item_checked(0, true)
		lang_menu.set_item_checked(1, false)
	elif id == 1:  # English
		current_language = "en"
		lang_menu.set_item_checked(0, false)
		lang_menu.set_item_checked(1, true)
	
	# Save language preference
	save_config.set_language(current_language)

func _on_tool_menu_pressed(id: int):
	if id == 0: # 启用编辑器运行
		var enabled = not save_config.get_enable_in_editor()
		save_config.set_enable_in_editor(enabled)
		tool_menu.set_item_checked(0, enabled)
		_refresh_debug_tool(enabled)
	elif id == 1: # 启用游戏中运行
		var enabled = not save_config.get_enable_in_game()
		save_config.set_enable_in_game(enabled)
		tool_menu.set_item_checked(1, enabled)
		_refresh_debug_tool_in_game(enabled)

func _refresh_debug_tool(enabled: bool):
	if enabled:
		if debug_tool != null:
			debug_tool.free()
		debug_tool = load("res://addons/ds_inspector/DsInspectorTool.tscn").instantiate()
		debug_tool.save_config = save_config
		add_child(debug_tool)
	else:
		if debug_tool != null:
			debug_tool.free()
			debug_tool = null

func _refresh_debug_tool_in_game(enabled: bool):
	if enabled:
		# 添加自动加载场景
		add_autoload_singleton("DsInspector", "res://addons/ds_inspector/DsInspector.gd")
	else:
		# 移除自动加载场景
		remove_autoload_singleton("DsInspector")