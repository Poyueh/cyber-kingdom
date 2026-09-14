extends Resource
## Replace individual game textures in the Inspector without changing simulation rules.
@export var woodland: Texture2D
@export var ground: Texture2D
@export var engineer_atlas: Texture2D
@export var citizens_atlas: Texture2D
@export var props: Dictionary = {}

@export var emission_masks: Dictionary = {}
@export var show_power_grid: bool = false

@export var forest_layer: Texture2D
@export_range(0.0,1.0) var forest_scroll: float = 0.25
@export var show_river: bool = false
