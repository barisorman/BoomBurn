extends Node2D

@export var bulletDelay : float
@export var Turret : Node2D

signal FireRequest(targetPosition)

func _ready() -> void:
	await get_tree().create_timer(bulletDelay).timeout
	BulletEvent()
	EventBus.emit_signal("screen_shake_requested", 0.15)

func BulletEvent() -> void:
	print("mermi ateşlendi")
	EventBus.bullet_sound.emit()
	emit_signal("FireRequest",global_position)
	queue_free()
	
