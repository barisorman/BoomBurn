extends Sprite2D

@export var max_scatter_speed: float = 200.0  
@export var min_scatter_speed: float = 500.0  
@export var friction: float = 10.0        
@export var magnet_speed: float = 600.0   
@export var detection_radius: float = 150.0 
@export var collect_radius: float = 20.0  
@export var xp_amount: int = 10

var velocity: Vector2 = Vector2.ZERO
var is_magnetized: bool = false

func _ready():
	var random_angle = randf_range(0, TAU)
	var random_speed = randf_range(min_scatter_speed, max_scatter_speed)
	velocity = Vector2.RIGHT.rotated(random_angle) * random_speed
	
	friction = randf_range(10, 20)
	
	await get_tree().create_timer(5).timeout
	is_magnetized = true
	
	#var random_scale = randf_range(0.8, 1.2)
	#scale = Vector2(random_scale, random_scale)
	
func _physics_process(delta):
	# Mouse pozisyonunu al
	var target_pos = get_global_mouse_position()
	var distance = global_position.distance_to(target_pos)

	# --- DURUM KONTROLÜ ---
	
	# Eğer mouse menzile girdiyse mıknatıs modunu aç
	if distance < detection_radius:
		is_magnetized = true

	# --- HAREKET MANTIĞI ---

	if is_magnetized:
		# MAGNET MODU: Hedefe doğru hızlanarak git (Lerp ile yumuşak dönüş)
		var direction = global_position.direction_to(target_pos)
		# Mevcut hızı hedefe doğru kaydır (Smooth turn)
		velocity = velocity.move_toward(direction * magnet_speed, 2500 * delta)
		
		# Eğer çok yaklaştıysa topla
		if distance < collect_radius:
			collect_xp()
			
	else:
		# SCATTER MODU: Yavaşlayarak dur (Sürtünme)
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta * 50)

	# Hareketi uygula
	global_position += velocity * delta

func collect_xp():
	# Burada Player'a sinyal gönderebilir veya direkt Global bir değişkene ekleyebilirsin
	# Örnek: Signal Bus kullanıyorsan: SignalBus.xp_gained.emit(xp_amount)
	EventBus.xp_changed.emit(1)
	# Ses efekti eklemek için burası harika bir yerdir.
	
	queue_free() # Nesneyi sil
