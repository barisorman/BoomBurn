extends Camera2D

# --- AYARLAR ---
@export var shake_power : float = 20.0  # Pozisyon ne kadar kaysın?
@export var shake_rotate : float = 0.05 # DÖNME MİKTARI (0.05 = Çok hafif, 0.1 = Sarhoş)
@export var shake_speed : float = 20.0  # Sallantı hızı (Noise üzerinde ne kadar hızlı gezineceğiz?)
@export var decay : float = 3.0         # Ne kadar sürede dursun?

# --- DEĞİŞKENLER ---
var trauma : float = 0.0
var trauma_exponent : int = 2
var noise : FastNoiseLite
var time_counter : float = 0.0 

func _ready() -> void:
	randomize()
	
	# Noise ayarları (Daha yumuşak bir doku için)
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.1      
	noise.fractal_octaves = 2  
	
	if EventBus:
		if not EventBus.screen_shake_requested.is_connected(add_trauma):
			EventBus.screen_shake_requested.connect(add_trauma)

func add_trauma(amount: float):
	trauma = clamp(trauma + amount, 0.0, 1.0)

func _process(delta: float) -> void:
	if trauma > 0:
		# 1. Travmayı zamanla azalt
		trauma = max(trauma - decay * delta, 0.0)
		
		# 2. Şiddeti hesapla
		var amount = pow(trauma, trauma_exponent)
		
		# 3. Noise üzerinde ilerle
		time_counter += delta * shake_speed
		
		# 4. Pozisyon Sallantısı (X ve Y)
		offset.x = amount * shake_power * noise.get_noise_2d(time_counter, 0.0)
		offset.y = amount * shake_power * noise.get_noise_2d(time_counter, 100.0)
		
		# 5. ROTASYON SWAY (Yeni Eklenen Kısım)
		# "200.0" offsetini kullanıyoruz ki pozisyonla senkronize olmasın, bağımsız dönsün.
		# shake_rotate ile çarpıyoruz ki çok az dönsün.
		rotation = amount * shake_rotate * noise.get_noise_2d(time_counter, 200.0)
		
	else:
		# 6. Yavaşça ve "Sway" yaparak merkeze dön
		if offset != Vector2.ZERO or rotation != 0:
			# Lerp hızı (5.0) dönüşün yumuşaklığını ayarlar
			offset = lerp(offset, Vector2.ZERO, delta * 5.0)
			rotation = lerp_angle(rotation, 0.0, delta * 5.0)
			
			# Çok küçükse sıfırla (İşlemciyi yorma)
			if offset.length() < 1.0 and abs(rotation) < 0.001:
				offset = Vector2.ZERO
				rotation = 0.0