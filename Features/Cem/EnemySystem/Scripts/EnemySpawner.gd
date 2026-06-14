extends Node2D

@export var enemy_configs: Array[EnemySpawnConfig]

@onready var spawn_top_marker = $TopSpawnPoint
@onready var spawn_bottom_marker = $BottomSpawnPoint
@onready var spawn_timer = $SpawnTimer

@export var current_level: int = 1
@export_group("Zorluk Ayarları")
@export var spawn_rate_curve : Curve
@export var max_difficulty_level : int = 20
@export var min_spawn_limit : float = 0.2

func _ready() -> void:
	increase_difficulty(current_level)
	EventBus.level_changed.connect(increase_difficulty)

func get_random_enemy_for_level() -> PackedScene:
	var valid_entries = [] # Uygun düşmanları ve o anki hesaplanmış ağırlıklarını tutacak
	var total_weight: float = 0.0
	
	
	for config in enemy_configs:
		# Level yetiyor mu kontrolü
		if current_level >= config.min_level:
			
			var dynamic_weight = config.spawn_weight + (config.weight_increase_per_level * current_level)
			
			valid_entries.append({ "scene": config.enemy_scene, "weight": dynamic_weight })
			total_weight += dynamic_weight

	
	if valid_entries.is_empty():
		return null

	
	var random_value = randf_range(0.0, total_weight)
	var current_sum = 0.0
	
	
	for entry in valid_entries:
		current_sum += entry["weight"]
		if random_value <= current_sum:
			return entry["scene"]
			
	
	return valid_entries.back()["scene"]
	

func _on_spawn_timer_timeout() -> void:
	if enemy_configs.is_empty():
		push_warning("Spawner: Düşman listesi boş")
		return
	
	var enemy_scene = get_random_enemy_for_level()
	
	if enemy_scene == null:
		return
	
	var enemy_instance = enemy_scene.instantiate()
	
	var random_y = randf_range(spawn_top_marker.global_position.y, spawn_bottom_marker.global_position.y)
	var spawn_pos = Vector2(global_position.x, random_y)
	
	get_tree().current_scene.add_child(enemy_instance)
	enemy_instance.global_position = spawn_pos

func increase_difficulty(new_level: int):
	current_level = new_level
	
	var difficulty_progress = float(current_level - 1) / float(max_difficulty_level)
	difficulty_progress = clampf(difficulty_progress, 0.0, 1.0)
	
	var new_wait_time : float = 1.0
	
	if spawn_rate_curve:
		new_wait_time = spawn_rate_curve.sample(difficulty_progress)
	else:
		push_warning("Spawn Rate Curve atanmamış!")
	
	spawn_timer.wait_time = max(new_wait_time, min_spawn_limit)

	print("Level: ", current_level, " | Progress: %", difficulty_progress*100, " | Spawn Rate: ", spawn_timer.wait_time)
