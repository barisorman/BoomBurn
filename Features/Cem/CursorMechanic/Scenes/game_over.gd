extends CanvasLayer

const MAIN_MENU_PATH = "res://Features/Cem/CursorMechanic/Scenes/main_menu.tscn"

func _ready():
	# Başlangıçta gizli olsun
	visible = false
	
	$TextureRect/again.pressed.connect(_on_retry_pressed)
	$TextureRect/exit.pressed.connect(_on_menu_pressed)

# Bu fonksiyonu dışarıdan çağıracağız
func show_game_over(final_score: String):
	# Skoru yaz
	$TextureRect/Score.text = final_score
	
	# Ekranı göster
	visible = true
	
	# OYUNU DURDUR (PAUSE)
	get_tree().paused = true

func _on_retry_pressed():
	# Önce pause modunu kapat (Yoksa yeni oyun da donuk başlar)
	get_tree().paused = false
	
	# Mevcut sahneyi yeniden yükle
	get_tree().reload_current_scene()

func _on_menu_pressed():
	get_tree().paused = false
	# Ana menüye dön
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
