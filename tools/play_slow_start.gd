extends "res://tools/play_campaign.gd"
## Only the operator idles; the actual day/night clock and world keep running.
var opening_delay:=60.0
var first_input: Dictionary={}
func input_ready() -> bool:
 if elapsed<opening_delay:return false
 if first_input.is_empty():first_input=snapshot()
 return true
func experiment_report() -> Dictionary:
 return {"opening_idle_seconds":opening_delay,"first_input_state":first_input,"pause_used":false,"resource_grants":false}
