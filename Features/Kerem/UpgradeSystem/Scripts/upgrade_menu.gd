extends CanvasLayer

# --- UI ELEMANLARI ---
@export var btn_wall : TextureButton
@export var btn_turret : TextureButton
@export var btn_rocket : TextureButton

# --- AYARLAR ---
var animation_offset = 500 # Kartlar ne kadar aşağıdan gelsin?
var anim_duration = 0.5 # Animasyon kaç saniye sürsün?

# --- DEĞİŞKENLER ---
var selected_wall_percent : int
var selected_turret_type : String
var selected_rocket_type : String

var original_positions = {} 
var btns_array = [] 

func _ready():
	if EventBus.has_signal("level_changed"):
		EventBus.level_changed.connect(open)

	visible = false
	btns_array = [btn_wall, btn_turret, btn_rocket]

	# Orijinal pozisyonları kaydet
	# (Bunu call_deferred ile yapıyoruz ki UI tam yüklensin, pozisyonlar kaymasın)
	call_deferred("save_positions")

	btn_wall.pressed.connect(_on_wall_pressed)
	btn_turret.pressed.connect(_on_turret_pressed)
	btn_rocket.pressed.connect(_on_rocket_pressed)

func save_positions():
	for btn in btns_array:
		original_positions[btn] = btn.position

# --- AÇILIŞ (GİRİŞ) ---
func open(amount):
	# 1. ÖNCE kartları aşağıya ışınla (Henüz görünür değiller)
	for btn in btns_array:
		btn.disabled = false 
		# Eğer oyun başında pozisyon alınamadıysa, şu an al
		if not original_positions.has(btn):
			original_positions[btn] = btn.position
		
		# Aşağıya gönder
		btn.position.y = original_positions[btn].y + animation_offset
		# Opaklıklarını sıfırla (Şeffaf başlasınlar, daha pürüzsüz olur)
		btn.modulate.a = 0.0

	# 2. ŞİMDİ görünür yap (Kütük gibi görünme sorunu biter)
	visible = true
	get_tree().paused = true 

	setup_wall_card()
	setup_turret_card()
	setup_rocket_card()

	# 3. Animasyonu başlat
	var tween = create_tween().set_parallel(true)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	for i in range(btns_array.size()):
		var btn = btns_array[i]
		# Yukarı kaydır
		tween.tween_property(btn, "position:y", original_positions[btn].y, anim_duration)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(i * 0.1)
		# Görünür yap (Fade in)
		tween.tween_property(btn, "modulate:a", 1.0, anim_duration)\
			.set_delay(i * 0.1)

# --- KAPANIŞ (ÇIKIŞ) ---
func _play_exit_animation(selected_btn):
	# Tıklamaları kilitle
	for btn in btns_array:
		btn.disabled = true

	var tween = create_tween().set_parallel(true)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	# Seçilmeyenleri aşağı yolla
	for btn in btns_array:
		if btn != selected_btn:
			# Aşağı kaydır ve şeffaflaştır
			tween.tween_property(btn, "position:y", original_positions[btn].y + animation_offset, 0.4)\
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			tween.tween_property(btn, "modulate:a", 0.0, 0.3)
		else:
			# Seçilen kart hafifçe parlasın veya büyüsün (Juice)
			tween.tween_property(btn, "scale", Vector2(1.1, 1.1), 0.2)
			pass

	# Tween'in bitmesini kesin olarak bekle
	await tween.finished
	
	# Şimdi kapat
	close_menu()
	
	# Kart boyutunu eski haline getir (Sonraki açılış için)
	if selected_btn:
		selected_btn.scale = Vector2(1, 1)

# --- İŞLEVLER ---
func setup_wall_card():
	var options = [10, 20, 30]
	selected_wall_percent = options.pick_random()
	if btn_wall.get_child_count() > 0:
		btn_wall.get_child(0).text = "DUVAR TAMİRİ\n\nCanı " + str(selected_wall_percent) + " değer kadar yenile"

func _on_wall_pressed():
	EventBus.increase_health_wall.emit(selected_wall_percent)
	_play_exit_animation(btn_wall)

func setup_turret_card():
	var types = ["fire_rate", "ammo_limit", "reload_speed"]
	selected_turret_type = types.pick_random()
	var label_node = btn_turret.get_child(0)
	if selected_turret_type == "fire_rate": label_node.text = "TARET HIZI\nAtış Hızı Artar"
	elif selected_turret_type == "ammo_limit": label_node.text = "TARET ŞARJÖRÜ\n+10 Mermi Kapasitesi"
	elif selected_turret_type == "reload_speed": label_node.text = "HIZLI YENİLEME\nMermiler Hızlı Dolar"

func _on_turret_pressed():
	if selected_turret_type == "fire_rate": EventBus.increase_turret_fireRate.emit(0.90)
	elif selected_turret_type == "ammo_limit": EventBus.increase_turret_ammoLimit.emit(10)
	elif selected_turret_type == "reload_speed": EventBus.increase_turret_reloadDelady.emit(0.20)
	_play_exit_animation(btn_turret)

func setup_rocket_card():
	var types = ["ammo_limit", "reload_speed"]
	selected_rocket_type = types.pick_random()
	var label_node = btn_rocket.get_child(0)
	if selected_rocket_type == "ammo_limit": label_node.text = "ROKET STOK\n+4 Roket Kapasitesi"
	elif selected_rocket_type == "reload_speed": label_node.text = "ROKET ÜRETİMİ\nRoket Hızlı Gelir"

func _on_rocket_pressed():
	if selected_rocket_type == "ammo_limit": EventBus.increase_rocket_ammoLimit.emit(4)
	elif selected_rocket_type == "reload_speed": EventBus.increase_rocket_reloadDelay.emit(0.40)
	_play_exit_animation(btn_rocket)

func close_menu():
	visible = false
	get_tree().paused = false
