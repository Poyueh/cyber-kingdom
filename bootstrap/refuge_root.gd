extends Node
## Independent prototype: real combat, disposable progress, one visible allocation.
const Refuge = preload("res://application/refuge_session.gd")
const Memory = preload("res://infrastructure/memory_progress_store.gd")
const Mapper = preload("res://bootstrap/tuning_mapper.gd")
const Encounter = preload("res://scenes/training.tscn")
@export var tuning: Resource = preload("res://data/refuge.tres")
@export var knight_tuning: Resource = preload("res://data/expedition_knight.tres")
@export var sentinel_tuning: Resource = preload("res://data/sentinel.tres")
@onready var panel = $Panel
var run: Refuge
var battle_view: Node2D

func _ready() -> void:
	run = Refuge.new(Mapper.combat_stats(knight_tuning), Mapper.combat_stats(sentinel_tuning),
		Memory.new(), tuning.crystals, tuning.shield_per_crystal, tuning.residents)
	panel.allocation_requested.connect(_allocate)
	panel.depart_requested.connect(_depart_or_retry)
	panel.exit_requested.connect(_exit)
	panel.present_allocation(run.preview())

func _allocate(amount: int) -> void:
	if run.allocate(amount):
		panel.present_allocation(run.preview())

func _depart_or_retry() -> void:
	if run.phase == Refuge.Phase.RESULT:
		run.restart()
		panel.present_allocation(run.preview())
		return
	if not run.depart():
		return
	battle_view = Encounter.instantiate()
	battle_view.session = run.battle
	battle_view.knight_tuning = knight_tuning
	battle_view.sentinel_tuning = sentinel_tuning
	battle_view.expedition_mode = true
	battle_view.retreat_requested.connect(_return_home)
	add_child(battle_view)
	panel.hide()

func _process(_seconds: float) -> void:
	if run != null and run.phase == Refuge.Phase.EXPEDITION:
		if not run.battle.hero.is_alive() or not run.battle.enemy.is_alive():
			_return_home()

func _return_home() -> void:
	if run.phase != Refuge.Phase.EXPEDITION:
		return
	var report := run.finish()
	battle_view.controls.release_all()
	remove_child(battle_view)
	battle_view.queue_free()
	battle_view = null
	panel.show()
	panel.present_result(report)

func _exit() -> void:
	get_tree().change_scene_to_file("res://scenes/training.tscn")
