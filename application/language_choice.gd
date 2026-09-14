extends RefCounted
## Pure selection rules; platform detection and persistence belong outside this layer.
const SUPPORTED=["zh_TW","zh_CN","en"]
static func normalize(value: String) -> String:
 var code=value.to_lower().replace("-","_")
 if code=="tchinese":return "zh_TW"
 if code=="schinese":return "zh_CN"
 if code=="english" or code=="en" or code.begins_with("en_"):return "en"
 if code=="zh" or code.begins_with("zh_"):
  var parts=code.split("_")
  if "hant" in parts:return "zh_TW"
  if "hans" in parts:return "zh_CN"
  if "tw" in parts or "hk" in parts or "mo" in parts:return "zh_TW"
  return "zh_CN"
 return ""
static func resolve(preference: String, system_locale: String, steam_language: String="") -> String:
 if preference in SUPPORTED:return preference
 var steam=normalize(steam_language)
 if not steam.is_empty():return steam
 var system=normalize(system_locale)
 return system if not system.is_empty() else "en"
