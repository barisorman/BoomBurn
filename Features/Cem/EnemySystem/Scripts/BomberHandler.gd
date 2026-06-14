extends EnemyBase

func take_damage(amount: int):
	super.take_damage(amount)

func perform_attack(target):
	if target.has_method("take_damage"):
		target.take_damage(damage_to_wall)
		queue_free()
	
