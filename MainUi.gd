extends Control

# Sahne dosyalarının yollarını buraya sürükle veya elle yaz
const GAME_SCENE_PATH = "res://Features/Cem/CemGame.tscn"

@onready var credits_panel = $CreditsPanel # Eğer credits paneli yaptıysan

func _ready():
	$Oyna.pressed.connect(_on_play_pressed)
	$Exit.pressed.connect(_on_exit_pressed)

func _on_play_pressed():
	# Oyuna geçiş yap
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _on_exit_pressed():
	# Oyunu kapat
	get_tree().quit()
