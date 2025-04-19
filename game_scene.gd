extends Node3D
class_name GameScene

@export var terrain: VoxelTerrain
@onready var voxel_tool := terrain.get_voxel_tool()

static var instance: GameScene

func _ready() -> void:
	instance = self
