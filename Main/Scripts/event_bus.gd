extends Node

#Level System Events
signal xp_changed(amount : int)
signal level_changed(amount : int)
signal request_xp_spawn(pos: Vector2, amount: int)

#Upgrading Events
signal increase_health_wall(amount : float)

signal increase_turret_fireRate(amount : float)
signal increase_turret_ammoLimit(amount : float)
signal increase_turret_reloadDelady(amount : float)

signal increase_rocket_ammoLimit(amount : float)
signal increase_rocket_reloadDelay(amount : float)


#Lose Control Events
signal window_virus_started 
signal window_virus_ended  

signal cursor_virus_started
signal cursor_virus_ended
signal virus_attack_started 
signal virus_attack_ended  

#kamera shake
signal screen_shake_requested(amount)
signal player_died

signal bullet_sound
signal bomb_sound
signal bomb_fall_sound
signal error_sound
