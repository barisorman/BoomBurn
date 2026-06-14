extends CPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1.5).timeout
	queue_free()
	pass # Replace with function body.
