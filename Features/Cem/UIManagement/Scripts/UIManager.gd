extends CanvasLayer
class_name UIManager

@onready var health_bar = $MarginContainer/HealthBar
@onready var xp_bar = $MarginContainer2/XPBar
@onready var bullet = $BulletCount
@onready var bomb = $BombCount
@onready var spawn_marker = $"../SpawnDamagedWeapons"

func update_health_bar(current_hp: int, max_hp: int):
	health_bar.max_value = max_hp
	health_bar.value = current_hp

func update_xp_bar(current_xp: int, max_xp: int):
	xp_bar.max_value = max_xp
	xp_bar.value = current_xp

func _process(delta: float) -> void:
	bullet.text = str(spawn_marker.bulletAmmo)
	bomb.text = str(spawn_marker.bombAmmo)
