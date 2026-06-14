extends Sprite2D
@export var shake_strength: float = 500.0 # Mouse ne kadar güçlü sarsılacak?
@export var change_dir_time: float = 0.6  # Yön değiştirme sıklığı

var is_glitch_active: bool = false
var drift_direction: Vector2 = Vector2.ZERO
var time_timer: float = 0.0
var target_color = Color(0.263, 0.271, 0.337, 1.0)

func _ready() -> void:
	# 1. Resmi Texture olarak değil, IMAGE olarak al
	var img = load("res://Features/Cem/CursorMechanic/Sprites/İmleç_gamejam_yamuk.png").get_image()
	
	img.resize(36, 36, Image.INTERPOLATE_BILINEAR)
	
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			var pixel_color = img.get_pixel(x, y)
			# Sadece şeffaf olmayan kısımları boya
			if pixel_color.a > 0:
				# Mevcut rengi hedef renkle çarp (Modulate mantığı)
				img.set_pixel(x, y, pixel_color * target_color)
	
	var final_texture = ImageTexture.create_from_image(img)
	# 4. İmleci ayarla (Hotspot'u da boyuta göre ayarla, örn: tam orta 16,16)
	Input.set_custom_mouse_cursor(final_texture, Input.CURSOR_ARROW, Vector2(13, 1))
	
	EventBus.cursor_virus_started.connect(func(): is_glitch_active = true)
	EventBus.cursor_virus_ended.connect(func(): is_glitch_active = false)
	
func _process(delta: float) -> void:
	handle_glitch(delta)
		
func handle_glitch(delta):
	var current_mouse_pos = get_viewport().get_mouse_position()
	if is_glitch_active:
		time_timer -= delta
		if time_timer <= 0:
			time_timer = change_dir_time
			drift_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		
		var new_pos = current_mouse_pos + (drift_direction * shake_strength * delta)
		var viewport_rect = get_viewport_rect().size
		new_pos.x = clamp(new_pos.x, 0, viewport_rect.x)
		new_pos.y = clamp(new_pos.y, 0, viewport_rect.y)
	
		Input.warp_mouse(new_pos)
		global_position = new_pos
	else:
		global_position = current_mouse_pos
