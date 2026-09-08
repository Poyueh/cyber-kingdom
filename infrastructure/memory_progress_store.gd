extends "res://application/ports/progress_store.gd"
## Deterministic in-memory adapter for tests and disposable play sessions.
var writes: int = 0
var accept_writes: bool = true
var _scrap: int = 0

func load_scrap() -> int:
	return _scrap

func save_scrap(amount: int) -> bool:
	writes += 1
	if not accept_writes:
		return false
	_scrap = amount
	return true
