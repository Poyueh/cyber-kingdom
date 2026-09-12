extends RefCounted
## Leave enough time to walk home, even from the far end of the island.
static func should_return(is_night: bool, until_night: float, from_x: float, home_x: float, speed: float, margin: float) -> bool:
	return is_night or until_night <= absf(home_x-from_x)/maxf(1.0,speed)+maxf(0.0,margin)
