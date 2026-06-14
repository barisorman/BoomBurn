extends Node2D


@export var damageArea : Area2D
@export var bombDelay: float
@export var push_force: float = 500
@export var Damage: int = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(bombDelay).timeout
	BombEvent()
	# Büyük sarsıntı (Patlama anında tetiklenir)
	EventBus.emit_signal("screen_shake_requested", 4)
	pass # Replace with function body.
	

func BombEvent() -> void:
	print("bomba gümledi")
	EventBus.bomb_sound.emit()
	var enemies = damageArea.get_overlapping_areas()
	for body in enemies:
		var enemy_root = body.get_parent()
		if enemy_root.has_method("take_damage"):
			enemy_root.take_damage(Damage)
			# karakterlerin hasar sonrası geri tepebilmesi için
			if enemy_root.has_method("ApplyKnockback"):
				var direction = (enemy_root.global_position - global_position).normalized()
				enemy_root.ApplyKnockback(direction * push_force)
			
			
	queue_free()
	
	
