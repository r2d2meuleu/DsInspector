@tool
extends EditorPlugin

var debug_tool: Node
var tool_menu: PopupMenu
var save_config: SaveConfig

# Language selection - can be referenced by other scripts
# Available languages: "cn", "en"
static var current_language: String = "cn"

func _enter_tree():
	SaveConfig.save_path = "user://ds_inspector_editor_config.json"
	# 设置初始状态
	save_config = SaveConfig.new()
	add_child(save_config)

	# Load saved language or use default
	current_language = save_config.get_language()
	
	# 创建工具菜单
	tool_menu = PopupMenu.new()
	tool_menu.add_check_item(I18nManager.translate("MENU_RUN_IN_EDITOR"), 0)
	tool_menu.add_check_item(I18nManager.translate("MENU_RUN_IN_GAME"), 1)
	tool_menu.add_separator()
	tool_menu.add_item("Language (" + ("中文" if current_language == "cn" else "English") + ")", 2)

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

func _toggle_language():
	# Simple toggle between Chinese and English
	if current_language == "cn":
		current_language = "en"
	else:
		current_language = "cn"
	
	# Save language preference
	save_config.set_language(current_language)
	
	# Update menu items with new language
	_update_menu_text()

func _update_menu_text():
	tool_menu.set_item_text(0, I18nManager.translate("MENU_RUN_IN_EDITOR"))
	tool_menu.set_item_text(1, I18nManager.translate("MENU_RUN_IN_GAME"))
	tool_menu.set_item_text(2, "Language (" + ("中文" if current_language == "cn" else "English") + ")")

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
	elif id == 2: # Language selection
		_toggle_language()

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
