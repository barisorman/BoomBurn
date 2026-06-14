extends TextureRect

signal window_closed
signal window_duplicate

func _ready() -> void:
	randomize_position()
	
	pivot_offset = size / 2
	scale = Vector2.ZERO
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	$Button.pressed.connect(_on_close_button_pressed)
	$Button2.pressed.connect(_on_ok_button_pressed)

func randomize_position():
	var screen_size = get_viewport_rect().size
	var my_size = size * scale 

	var max_x = screen_size.x - my_size.x
	var max_y = screen_size.y - my_size.y
	var margin = 20.0

	var random_x = randf_range(margin, max_x - margin)
	var random_y = randf_range(margin, max_y - margin)
	
	position = Vector2(random_x, random_y)
	
func _on_close_button_pressed():
	$Button.disabled = true
	$Button2.disabled = true
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	await tween.finished
	
	emit_signal("window_closed") # Ben kapandım diye bağır
	queue_free() # Kendini yok et
func _on_ok_button_pressed():
	$Button.disabled = true
	$Button2.disabled = true
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	await tween.finished
	
	emit_signal("window_duplicate")
	queue_free() # Kendini yok et
