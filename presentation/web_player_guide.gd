extends RefCounted
## Browser UI belongs to presentation; game rules and desktop exports do not use it.
static func open() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.CyberKingdomGuide.open()", true)
