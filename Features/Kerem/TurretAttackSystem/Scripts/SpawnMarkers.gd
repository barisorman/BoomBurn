extends Node2D


@export var bombScene : PackedScene
@export var bulletScene : PackedScene
@export var turret : Node2D

@onready var minigun_sound = $Minigun
@onready var bomb_sound = $Bomb
@onready var bomb_fall_sound = $BombFall

@export var bombAmmo : int = 3
@export var bombAmmoLimit : int = 3
@export var bombReloadDelay : float = 2


@export var bulletAmmo : int = 10
@export var bulletAmmoLimit : int = 10
@export var bulletReloadDelay : float = 0.5

@export var rocketTurret : Node2D


var bomb_timer : float = 0.0   # Bombanın dolması için geri sayım
var bullet_timer : float = 0.0 # Merminin dolması için geri sayım
var fire_cooldown : float = 0.0

var virus_attacked: bool = false

var fireRate : float = 0.1
var remainingTime : float = 0.0

func _ready() -> void:
	EventBus.increase_turret_fireRate.connect(IncTurretFirerate)
	EventBus.increase_turret_ammoLimit.connect(IncTurretAmmoLimit)
	EventBus.increase_turret_reloadDelady.connect(IncTurretReloadDelay)
	
	EventBus.increase_rocket_ammoLimit.connect(IncRocketAmmoLimit)
	EventBus.increase_rocket_reloadDelay.connect(IncRocketReloadDelay)
	
	EventBus.window_virus_started.connect(func(): virus_attacked = true)
	EventBus.window_virus_ended.connect(func(): virus_attacked = false)
	
	EventBus.bullet_sound.connect(play_bullet)
	EventBus.bomb_sound.connect(play_bomb)
	EventBus.bomb_fall_sound.connect(play_bomb_fall)
	

func play_bullet():
	minigun_sound.pitch_scale = randf_range(0.9,1.1)
	minigun_sound.play()
	
func play_bomb():
	minigun_sound.pitch_scale = randf_range(0.9,1.1)
	bomb_sound.play()

func play_bomb_fall():
	minigun_sound.pitch_scale = randf_range(0.9,1.1)
	bomb_fall_sound.play()

func IncTurretFirerate(amount) -> void:
	fireRate *= amount
	print("kod çalıştı")

	
func IncTurretAmmoLimit(amount) -> void:
	bulletAmmoLimit += amount
	print("kod çalıştı")
		
func IncTurretReloadDelay(amount) -> void:
	bulletReloadDelay *= amount
	print("kod çalıştı")
	
func IncRocketAmmoLimit(amount) -> void:
	bombAmmoLimit += amount
	print("kod çalıştı")
	
	
func IncRocketReloadDelay(amount) -> void:
	bombReloadDelay *= amount
	print("kod çalıştı")


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if virus_attacked:
			return
		elif bombAmmo > 0:
			SpawnBomb(get_global_mouse_position())
			bombAmmo -= 1
			bomb_timer = bombReloadDelay
			print(bombAmmo)
		
		
func _process(delta: float) -> void:
		handle_firing(delta)
		reload_logic(delta)
		random_firing()
		pass
		

func handle_firing(delta: float) -> void:
	# Ateş cooldown'ını düşür
	if fire_cooldown > 0:
		fire_cooldown -= delta
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if virus_attacked:
			return
		# Mermi var mı ve silah soğudu mu?
		elif bulletAmmo > 0 and fire_cooldown <= 0:
			SpawnBullet(get_global_mouse_position())
			bulletAmmo -= 1
			fire_cooldown = fireRate # Sayacı tekrar kur

# Ateş ederken mermi dolmasın istiyorsan sayacı resetle
			bullet_timer = bulletReloadDelay


func reload_logic(delta: float) -> void:

	if bombAmmo < bombAmmoLimit:
		bomb_timer -= delta # Geri sayım
		if bomb_timer <= 0:
			bombAmmo += 1
			bomb_timer = bombReloadDelay # Sayacı bir sonraki mermi için tekrar kur
			print("Bomba Doldu! Stok: ", bombAmmo)

# Eğer mermi eksikse VE şu an ateş etmiyorsak (Mouse basılı değilse)
	if bulletAmmo < bulletAmmoLimit:
		bullet_timer -= delta

		if bullet_timer <= 0:
			bulletAmmo += 1
			bullet_timer = bulletReloadDelay
		

func random_firing():
	if virus_attacked:
		if bombAmmo > 0:
			SpawnBomb(random_position())
			bombAmmo -= 1
			bomb_timer = bombReloadDelay

func random_position():
	var screen_size = get_viewport_rect().size
	var instance = bombScene.instantiate()
	var my_size = instance.get_node("mark").texture.get_size() * instance.get_node("mark").scale * scale
	
	var max_x = screen_size.x - my_size.x
	var max_y = screen_size.y - my_size.y
	var margin = 200.0
	
	var random_x = randf_range(margin, max_x - margin)
	var random_y = randf_range(margin, max_y - margin)
	
	position = Vector2(random_x, random_y)
	return position

func SpawnBomb(mousePoisiton) -> void:
	EventBus.bomb_fall_sound.emit()
	var newBombScene: Node2D = bombScene.instantiate()
	newBombScene.global_position = mousePoisiton
	rocketTurret.play_mortar_animation(mousePoisiton)
	print("bomba atıldı")
	get_tree().root.add_child(newBombScene)
	
	
func SpawnBullet(mousePosition) -> void:
	var newBulletScene: Node2D = bulletScene.instantiate()
	newBulletScene.FireRequest.connect(turret._on_marker_bullet_request)
	newBulletScene.global_position = mousePosition
	get_tree().root.add_child(newBulletScene)
	
	
