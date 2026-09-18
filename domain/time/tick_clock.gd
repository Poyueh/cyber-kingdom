extends RefCounted
## Fixed-step simulation clock. The core counts ticks and never reads a frame
## delta or the system time; only presentation turns ticks back into seconds.
const TICKS_PER_SECOND := 30
const SECONDS_PER_TICK := 1.0/float(TICKS_PER_SECOND)

var tick: int = 0

func advance() -> void:
	tick += 1

## For display only. Rules compare tick counts.
func elapsed_seconds() -> float:
	return float(tick)*SECONDS_PER_TICK

## Data files stay in readable seconds; the core converts once while loading, so
## a positive duration can never collapse into zero ticks.
static func ticks_for(seconds: float) -> int:
	if not is_finite(seconds) or seconds<=0.0:
		return 0
	return maxi(1,int(round(seconds*float(TICKS_PER_SECOND))))

func capture() -> int:
	return tick

func restore(value: int) -> bool:
	if value<0:
		return false
	tick=value
	return true
