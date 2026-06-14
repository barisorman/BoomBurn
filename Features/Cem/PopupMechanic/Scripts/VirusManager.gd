extends CanvasLayer

@export var error_scene: PackedScene 
@export var min_windows: int = 3
@export var max_windows: int = 6
@onready var error = $"../SpawnDamagedWeapons/error"
var active_window_count = 0

func _ready() -> void:
	$Timer.wait_time = randf_range(15, 30)
	$Timer.timeout.connect(start_virus_attack)
	$Timer.start()
	EventBus.error_sound.connect(play_error)
	
func play_error():
	error.play()
	
func start_virus_attack():
	var event_index = randi_range(0,1)
	if event_index == 0:
		start_error_window()
	elif event_index == 1:
		start_cursor_glitch()
	
func start_error_window():
	if active_window_count > 0: return 
	
	EventBus.window_virus_started.emit() 
	
	var count = randi_range(min_windows, max_windows)
	active_window_count = count
	
	for i in range(count):
		spawn_window()
		
		await get_tree().create_timer(randf_range(0.1, 0.4)).timeout
		
	$Timer.wait_time = randf_range(15.0, 30.0)
	
func start_cursor_glitch():
	EventBus.cursor_virus_started.emit()
	var glitch_duration = randf_range(5.0, 8.0)
	await get_tree().create_timer(glitch_duration).timeout

	EventBus.cursor_virus_ended.emit()

	$Timer.wait_time = randf_range(15.0, 30.0)
	$Timer.start()
	
func spawn_window():
	EventBus.error_sound.emit()
	var win = error_scene.instantiate()
	add_child(win)
	# Pencere kapandığında haberdar ol
	win.window_closed.connect(_on_window_closed)
	win.window_duplicate.connect(_on_window_dup)

func _on_window_closed():
	active_window_count -= 1
	# Tüm pencereler kapandı mı?
	if active_window_count <= 0:
		EventBus.window_virus_ended.emit() # Oyuncuyu serbest bırak
func _on_window_dup():

	active_window_count += 1 
	for i in 2:
		spawn_window()
		await get_tree().create_timer(randf_range(0.1, 0.4)).timeout
