extends RefCounted
## Application-owned port. Inject a file adapter or a test double at startup.
func load_scrap() -> int:
	return 0

func save_scrap(_amount: int) -> bool:
	return false
