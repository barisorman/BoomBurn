extends Resource
class_name EnemySpawnConfig

@export_group("Düşman Ayarları")
@export var enemy_scene: PackedScene  
@export var spawn_weight: float = 10.0 
@export var weight_increase_per_level: float = 0.0
@export var min_level: int = 1         
