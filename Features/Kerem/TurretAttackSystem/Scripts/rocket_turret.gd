extends Node2D

# --- GİRDİLER (INSPECTOR'DAN ATANACAK) ---
@export var projectile_scene : PackedScene  # Buraya 'MortarProjectile.tscn' sürükle
@export var explosion_scene : PackedScene   # Buraya 'Explosion.tscn' sürükle

# --- ATEŞLEME ANİMASYONU ---
# Bu fonksiyonu, tareti ateşlediğin (marker koyduğun) yerde çağır:
# play_mortar_animation(target_position)
func play_mortar_animation(target_pos: Vector2):
	
	# 1. BÖLÜM: YUKARI FIRLATMA (Ekran dışına çıkış)
	if projectile_scene:
		var visual_up = projectile_scene.instantiate()
		visual_up.global_position = global_position # Taretin üstünde doğsun
		get_tree().root.add_child(visual_up)        # Ekrana ekle
		
		visual_up.rotation_degrees = -90 # Yukarı baksın (Sprite yönüne göre 0 da olabilir)
		
		# Tween ile yukarı uçur
		var tween_up = create_tween()
		var up_dest = global_position + Vector2(0, -600) # 600px yukarı
		
		# 0.5 saniyede yukarı çıksın
		tween_up.tween_property(visual_up, "global_position", up_dest, 0.2)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			
		# Varınca kendini silsin
		tween_up.tween_callback(visual_up.queue_free)

	# 2. BÖLÜM: ZAMANLAMA VE DÜŞÜŞ
	# Hasar 2. saniyede vuruluyor. Roket 0.5 sn'de düşüyor.
	# Demek ki 1.5. saniyede tepede belirmeli.
	get_tree().create_timer(0.5).timeout.connect(func():
		drop_rocket_on_target(target_pos)
	)

# --- YARDIMCI: ROKETİ DÜŞÜRME ---
func drop_rocket_on_target(target_pos: Vector2):
	if projectile_scene:
		var visual_down = projectile_scene.instantiate()
		
		# Hedefin 600px yukarısında başlat
		var start_pos = target_pos + Vector2(0, -600)
		visual_down.global_position = start_pos
		get_tree().root.add_child(visual_down)
		
		visual_down.rotation_degrees = 90 # Aşağı baksın (Kafa üstü)
		
		# Tween ile aşağı çakıl
		var tween_down = create_tween()
		
		# 0.5 saniyede hedefe insin
		tween_down.tween_property(visual_down, "global_position", target_pos, 0.3)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		
		# --- KRİTİK NOKTA: PATLAMA ---
		# Hedefe varır varmaz patlamayı çağır
		tween_down.tween_callback(func(): spawn_explosion(target_pos))
		
		# Sonra roketi sil
		tween_down.tween_callback(visual_down.queue_free)

# --- YARDIMCI: PATLAMA EFEKTİ ---
func spawn_explosion(pos: Vector2):
	if explosion_scene:
		var effect = explosion_scene.instantiate()
		effect.global_position = pos
		get_tree().root.add_child(effect) # En tepeye ekle
		
		# Particle'ı başlat (Eğer 'Emitting' kapalı geldiyse)
		if effect is CPUParticles2D or effect is GPUParticles2D:
			effect.emitting = true
			
		# BURAYA EKRAN TİTREMESİ DE EKLERSİN TADINDAN YENMEZ:
		# if EventBus: EventBus.emit_signal("screen_shake_requested", 15.0)
