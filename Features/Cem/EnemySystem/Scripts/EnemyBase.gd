class_name EnemyBase extends CharacterBody2D

@export var turret : Node2D
@export var sprite : AnimatedSprite2D
@export_group("Stats")
@export var movement_speed : float = 100.0
@export var max_health : int = 10
@export var damage_to_wall : int = 1

@onready var raycast = $RayCast2D

@export var attack_cooldown: float = 1.0
@export var xp_reward : int = 10
var attack_timer: float = 0.0

var current_health: int

@export var visual_node : Node2D
var base_scale: Vector2

var sway_amount: float = 8.0  # Kaç derece yatsın?
var speed: float = 0.5

var knockback_velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	current_health = max_health
	setup_enemy()
	
	if visual_node:
		base_scale = visual_node.scale
	start_wobble_animation()

func _physics_process(delta: float) -> void:
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider == null:
			return
		if collider.is_in_group("Wall"):
			if attack_timer > 0:
				attack_timer -= delta
			try_attack(collider)
			velocity = Vector2.ZERO
	else:
		move_logic(delta)
		
func try_attack(target):
	if attack_timer <= 0:
		perform_attack(target)
		attack_timer = attack_cooldown

func perform_attack(target):
	if target.has_method("take_damage"):
		target.take_damage(damage_to_wall)

func move_logic(delta):
	var normal_movement = Vector2.LEFT * movement_speed
	velocity = normal_movement + knockback_velocity
	move_and_slide()
	
	knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 5.0 * delta)

func ApplyKnockback(force_vector: Vector2):
	knockback_velocity = force_vector




func take_damage(amount: int):
	current_health -= amount
	hit_flash()
	if current_health <= 0:
		die()
		
func hit_flash():
	if sprite.material:
		# 1. Değeri anında 1 yap (Tamamen Beyaz)
		sprite.material.set_shader_parameter("flash_modifier", 1.0)
	
		# 2. Tween oluştur
		var tween = create_tween()
	
		# 3. 0.1 saniye içinde değeri 1'den 0'a düşür (Beyazdan normale dön)
		tween.tween_property(sprite.material, "shader_parameter/flash_modifier", 0.0, 0.3)
	pass
	
	

func die():
	EventBus.request_xp_spawn.emit(global_position, xp_reward)
	#EventBus.xp_changed.emit(25)
	queue_free()

func setup_enemy():
	pass


# karakter yürüme animasyonları için
func start_wobble_animation():
	if visual_node == null: return

	var tween = create_tween().set_loops()
	tween.set_trans(Tween.TRANS_SINE) 
	tween.set_ease(Tween.EASE_IN_OUT)

	
	tween.tween_property(visual_node, "rotation_degrees", sway_amount, speed)
	
	tween.parallel().tween_property(visual_node, "scale", base_scale * Vector2(1.2, 0.8), speed)

	
	tween.tween_property(visual_node, "rotation_degrees", 0.0, speed)
	tween.parallel().tween_property(visual_node, "scale", base_scale * Vector2(0.9, 1.1), speed)

	
	tween.tween_property(visual_node, "rotation_degrees", -sway_amount, speed)
	tween.parallel().tween_property(visual_node, "scale", base_scale * Vector2(1.2, 0.8), speed)

	
	tween.tween_property(visual_node, "rotation_degrees", 0.0, speed)
	tween.parallel().tween_property(visual_node, "scale", base_scale * Vector2(0.9, 1.1), speed)
