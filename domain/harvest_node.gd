extends RefCounted
var kind: String
var x: float
var y: float = 430.0
var remaining_work: int = 75
var wood: int = 0
var food: int = 0
var crystals: int = 0
var scrap: int = 0
var stone: int = 0
var herbs: int = 0
var collected := false
var region: int
var marked := false
var worker := -1
var work_elapsed := 0.0
var carried := false
var delivered := false
var pickup_x := 0.0
var pickup_y := 430.0
func advance_work(seconds: float, duration: float) -> bool:
	if not marked or collected or seconds<=0 or not is_finite(seconds) or duration<=0 or not is_finite(duration):
		return false
	work_elapsed = minf(duration,work_elapsed+seconds)
	remaining_work = maxi(0,ceili(75*(1-work_elapsed/duration)))
	return remaining_work == 0
