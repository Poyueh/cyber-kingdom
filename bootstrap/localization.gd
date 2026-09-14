extends Node
signal changed
const Choice=preload("res://application/language_choice.gd")
const Preferences=preload("res://infrastructure/language_preferences.gd")
const Texts=preload("res://localization/game_text.gd")
var preferences=Preferences.new()
var preference: String="auto"
var locale: String="en"
var steam_language: String="" # Future Steam bootstrap supplies GetCurrentGameLanguage().
var save_failed:=false
func _ready() -> void:
 process_mode=Node.PROCESS_MODE_ALWAYS
 for column in range(3):
  var translation=Translation.new();translation.locale=Choice.SUPPORTED[column]
  for row in Texts.ROWS:translation.add_message(row[0],row[column+1])
  TranslationServer.add_translation(translation)
 preference=preferences.read_choice();_apply()
func choose(value: String) -> bool:
 if value not in ["auto","zh_TW","zh_CN","en"]:return false
 preference=value
 save_failed=not preferences.write_choice(value)
 _apply()
 return not save_failed
func set_steam_language(value: String) -> void:
 steam_language=value;_apply()
func _apply() -> void:
 locale=Choice.resolve(preference,OS.get_locale(),steam_language)
 TranslationServer.set_locale(locale)
 changed.emit()
