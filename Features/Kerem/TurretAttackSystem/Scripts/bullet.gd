extends Area2D

@export var speed: float = 2000.0  
@export var damage: int = 1        


var target_position: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	
	var distance_to_target = global_position.distance_to(target_position)
	
	
	var step = speed * delta
	
	
	if distance_to_target <= step:
		
		global_position = target_position 
		queue_free()
	else:
		
		position += transform.x * step


func _on_area_entered(body: Area2D) -> void:
	var bodyEnemyRoot = body.get_parent()
	if bodyEnemyRoot.has_method("take_damage"):
		bodyEnemyRoot.take_damage(damage)
		bodyEnemyRoot.has_method("ApplyKnockback")
		
		bodyEnemyRoot.ApplyKnockback(transform.x * 100.0) 

	
		queue_free()
	pass 
