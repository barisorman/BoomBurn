extends StaticBody2D

signal health_changed(current_hp, max_hp)

@export var ui_reference: CanvasLayer
@export var max_health : int = 100
var current_health : int

func _ready() -> void:
	EventBus.increase_health_wall.connect(IncreaseHealth)
	current_health = max_health
	
	if ui_reference:
		health_changed.connect(ui_reference.update_health_bar)
		health_changed.emit(current_health, max_health)

func IncreaseHealth(amount) -> void:
	current_health += amount
	health_changed.emit(current_health,max_health)
	

func take_damage(amount):
	current_health -= amount
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		EventBus.player_died.emit()
		visible = false
		#game_over()
		
