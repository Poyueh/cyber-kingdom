extends RefCounted
## Dawn requires both time passing and the invading force being resolved.
var day := 1
var survived := 0
var is_night := false
var remaining: float
var day_seconds: float
var night_seconds: float
func _init(day_length: float = 180.0, night_length: float = 60.0) -> void:
	day_seconds = maxf(1,day_length)
	night_seconds = maxf(1,night_length)
	remaining = day_seconds
func advance(seconds: float, invasion_clear: bool) -> String:
	if seconds<=0 or not is_finite(seconds): return ""
	remaining = maxf(0,remaining-seconds)
	if remaining>0: return ""
	if not is_night:
		is_night = true
		remaining = night_seconds
		return "night"
	if invasion_clear:
		survived += 1
		day += 1
		is_night = false
		remaining = day_seconds
		return "dawn"
	return ""
