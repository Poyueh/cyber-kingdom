extends RefCounted
## Shared font changes regional glyph shapes while keeping every language name legible.
const TC="res://art/fonts/noto-sans-tc/NotoSansTC-Regular.otf"
const SC="res://art/fonts/noto-sans-sc/NotoSansSC-Regular.otf"
static var _shared: FontVariation
static func current() -> Font:
 if _shared==null:
  _shared=FontVariation.new()
 var simplified=TranslationServer.get_locale().begins_with("zh_CN")
 _shared.base_font=load(SC if simplified else TC)
 _shared.fallbacks=[load(TC if simplified else SC)]
 return _shared
