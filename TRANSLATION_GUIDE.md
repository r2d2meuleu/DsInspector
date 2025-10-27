# DsInspector Translation System

This document explains how to use the translation system implemented in DsInspector.

## Overview

The DsInspector plugin now supports multiple languages through a CSV-based translation system. Currently supported languages:
- **Chinese (cn)** - Default language
- **English (en)**

## For Users

### Switching Languages
1. In Godot Editor, go to `Project` menu
2. Find `DsInspector` submenu
3. Click on `Language (Current Language)` to toggle between Chinese and English
4. The language preference is automatically saved

## For Developers

### Using Translations in Code

Instead of hardcoded strings, use the translation manager:

```gdscript
# Instead of:
print("错误消息")

# Use:
print(I18nManager.translate("ERROR_MESSAGE"))

# Or use the short alias:
print(I18nManager.t("ERROR_MESSAGE"))
```

### Available Translation Keys

Common translation keys available in the system:

#### Menu Items
- `MENU_RUN_IN_EDITOR` - "在编辑器运行" / "Run in Editor"
- `MENU_RUN_IN_GAME` - "在游戏中运行" / "Run in Game"

#### Inspector Labels
- `INSPECTOR_BASIC_PROPERTIES` - "基础属性" / "Basic Properties"
- `INSPECTOR_NAME` - "名称：" / "Name:"
- `INSPECTOR_TYPE` - "类型：" / "Type:"
- `INSPECTOR_PATH` - "路径：" / "Path:"
- `INSPECTOR_SCENE` - "场景：" / "Scene:"
- `INSPECTOR_SCRIPT` - "脚本：" / "Script:"

#### UI Hints
- `HINT_NODE_SELECTION_MAC` - Mac node selection hint
- `HINT_NODE_SELECTION_PC` - PC node selection hint

#### Dialog Messages
- `DIALOG_DELETE_CONFIRMATION` - "确定要删除选中的节点吗？" / "Are you sure you want to delete the selected node?"

#### Error Messages
- `ERROR_CONFIG_SAVE_FAILED` - Config save error
- `ERROR_CONFIG_FORMAT` - Config format error
- `ERROR_JSON_PARSE` - JSON parsing error
- And more...

### Adding New Translations

1. **Add to CSV files**: Update both `cn.csv` and `en.csv` in `/addons/ds_inspector/i18n/`
2. **Use the key in code**: Replace hardcoded strings with `I18nManager.translate("YOUR_KEY")`

Example CSV entries:
```csv
keys,cn
"YOUR_NEW_KEY","你的中文文本"
```

```csv
keys,en
"YOUR_NEW_KEY","Your English Text"
```

### Language Detection

The system automatically:
- Loads the saved language preference on startup
- Falls back to Chinese if English translation is missing
- Falls back to the key itself if no translation is found

### Current Language Access

You can get the current language from the plugin:
```gdscript
var current_lang = I18nManager.get_current_language()  # Returns "cn" or "en"
```

## Adding New Languages

To add a new language (e.g., Japanese):

1. Create `/addons/ds_inspector/i18n/jp.csv`
2. Add all translation keys with Japanese translations
3. Update `I18nManager.gd` to load the new CSV file
4. Update the language switching mechanism in `plugin.gd`

## Technical Details

- **Translation Manager**: `I18nManager.gd` handles all translation logic
- **Language Storage**: Language preference is saved in the plugin's config file
- **CSV Format**: Simple key-value pairs with proper CSV escaping
- **Fallback System**: English → Chinese → Key if translation not found

## Current Language Variable

Other scripts can access the current language through:
```gdscript
# Static access to current language
var lang = I18nManager.get_current_language()

# Plugin's static variable (also available)
var lang = plugin.current_language  # Available in plugin context
```

The language is automatically saved and restored between sessions.