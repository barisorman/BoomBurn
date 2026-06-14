extends Node2D


@export var bulletScene : PackedScene

func _on_marker_bullet_request(target: Vector2):
	var newAmmo: Area2D  = bulletScene.instantiate()
	newAmmo.global_position = global_position
	newAmmo.look_at(target)
	newAmmo.target_position = target
	get_tree().root.add_child(newAmmo)
	
	
