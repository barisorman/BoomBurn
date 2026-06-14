extends Node2D

var current_level : int = 1
@export var ui_reference: CanvasLayer
@export var xp_increase_rate : float = 1.2
@export var max_xp : int = 50
var current_xp : int = 0

func _ready() -> void:
	if ui_reference:
		ui_reference.update_xp_bar(current_xp, max_xp)
		EventBus.xp_changed.connect(gain_xp)
		

func gain_xp(amount):
	current_xp += amount
	if current_xp >= max_xp:
		current_xp = 0 
		current_level += 1
		max_xp *= xp_increase_rate
		EventBus.level_changed.emit(current_level)
	ui_reference.update_xp_bar(current_xp, max_xp)
