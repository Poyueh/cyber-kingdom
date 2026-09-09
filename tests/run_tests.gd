extends SceneTree

var failures: Array[String] = []
var assertions := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var suites := ["res://tests/test_combat.gd", "res://tests/test_session.gd", "res://tests/test_file_store.gd", "res://tests/test_knight_visual.gd", "res://tests/test_impact_view.gd", "res://tests/test_refuge.gd"]
	for suite_path in suites:
		var script = load(suite_path)
		if script == null or not script.can_instantiate():
			failures.append("Cannot load test suite: " + suite_path)
			continue
		var suite = script.new()
		for method in suite.get_method_list():
			if str(method.name).begins_with("test_"):
				var before := assertions
				var previous := failures.size()
				suite.call(method.name, self)
				if before == assertions:
					failures.append(str(method.name) + ": no assertions (possible script error)")
				print(("PASS " if previous == failures.size() else "FAIL ") + str(method.name))
	if not failures.is_empty():
		for failure in failures:
			printerr(failure)
	print("Assertions: %d; failures: %d" % [assertions, failures.size()])
	quit(0 if failures.is_empty() else 1)

func equal(actual: Variant, expected: Variant, message: String) -> void:
	assertions += 1
	if actual != expected:
		failures.append("%s: expected %s, got %s" % [message, str(expected), str(actual)])

func truth(value: bool, message: String) -> void:
	equal(value, true, message)
