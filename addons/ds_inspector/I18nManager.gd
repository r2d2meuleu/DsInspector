@tool
extends RefCounted
class_name I18nManager

# Static instance for global access
static var instance: I18nManager

# Translation data storage
var translations: Dictionary = {}

# Initialize the translation manager
static func get_instance() -> I18nManager:
	if instance == null:
		instance = I18nManager.new()
		instance._load_translations()
	return instance

# Load translation files
func _load_translations():
	translations.clear()
	
	# Load Chinese translations
	var cn_data = _load_csv_file("res://addons/ds_inspector/i18n/cn.csv")
	if cn_data:
		translations["cn"] = cn_data
	
	# Load English translations
	var en_data = _load_csv_file("res://addons/ds_inspector/i18n/en.csv")
	if en_data:
		translations["en"] = en_data

# Load CSV translation file
func _load_csv_file(file_path: String) -> Dictionary:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("I18nManager: Cannot open file ", file_path)
		return {}
	
	var data = {}
	var is_first_line = true
	
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line.is_empty():
			continue
			
		# Skip the header line
		if is_first_line:
			is_first_line = false
			continue
			
		# Parse CSV line (simple parsing for quoted strings)
		var parts = _parse_csv_line(line)
		if parts.size() >= 2:
			var key = parts[0].strip_edges().trim_prefix('"').trim_suffix('"')
			var value = parts[1].strip_edges().trim_prefix('"').trim_suffix('"')
			data[key] = value
	
	file.close()
	return data

# Simple CSV line parser for quoted strings
func _parse_csv_line(line: String) -> Array:
	var parts = []
	var current_part = ""
	var in_quotes = false
	var i = 0
	
	while i < line.length():
		var char = line[i]
		
		if char == '"':
			in_quotes = !in_quotes
			current_part += char
		elif char == ',' and !in_quotes:
			parts.append(current_part)
			current_part = ""
		else:
			current_part += char
		
		i += 1
	
	if current_part != "":
		parts.append(current_part)
	
	return parts

# Get translated text
func get_text(key: String, language: String = "") -> String:
	# Use current language if not specified
	if language.is_empty():
		language = get_current_language()
	
	if translations.has(language) and translations[language].has(key):
		return translations[language][key]
	
	# Fallback to Chinese if English not found
	if language != "cn" and translations.has("cn") and translations["cn"].has(key):
		return translations["cn"][key]
	
	# Return key if no translation found
	return key

# Static convenience function for global access
static func tr(key: String, language: String = "") -> String:
	return I18nManager.get_instance().get_text(key, language)

# Get current language from plugin
static func get_current_language() -> String:
	# Try to access the plugin's current language
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root:
		var plugins = tree.root.get_children()
		for child in plugins:
			if child.get_script() and child.get_script().get_path().ends_with("plugin.gd"):
				if child.has_method("get") and child.get("current_language"):
					return child.get("current_language")
	return "cn"  # Default to Chinese

# Set current language in plugin
static func set_current_language(language: String):
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root:
		var plugins = tree.root.get_children()
		for child in plugins:
			if child.get_script() and child.get_script().get_path().ends_with("plugin.gd"):
				if child.has_method("set"):
					child.set("current_language", language)
					return