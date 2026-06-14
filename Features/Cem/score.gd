extends Label
var current_score = 0

func _ready() -> void:
	current_score = 0
	EventBus.request_xp_spawn.connect(score_change)

func score_change(pos: Vector2, amount: int):
	current_score += 1
	text = str(current_score)
