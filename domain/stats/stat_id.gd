extends RefCounted
## Every modifiable value is named here so a typo cannot silently create a stat
## nothing ever reads.
const MAX_HP := &"max_hp"
const DAMAGE := &"damage"
const ATTACK_RANGE := &"attack_range"
const MOVE_SPEED := &"move_speed"
const HARVEST_YIELD := &"harvest_yield"
const BUILD_SPEED := &"build_speed"
const TOWER_DAMAGE := &"tower_damage"
const ARCHER_DAMAGE := &"archer_damage"

const ALL: Array[StringName]=[MAX_HP,DAMAGE,ATTACK_RANGE,MOVE_SPEED,HARVEST_YIELD,BUILD_SPEED,TOWER_DAMAGE,ARCHER_DAMAGE]
