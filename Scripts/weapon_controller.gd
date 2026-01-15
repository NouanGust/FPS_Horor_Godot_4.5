extends Node3D

# --- Ref de Nodes --- 
@onready var muzzle_point: Marker3D = $MuzzlePoint
@onready var muzzle_light: OmniLight3D = $OmniLight3D
@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D

# --- Bullet ---
@export var bullet_scene: PackedScene


# --- Função de atirar
func shoot(damage_amount: int) -> void:
	muzzle_flash()
	
	if bullet_scene and muzzle_point:
		var bullet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		
		bullet.global_position = muzzle_point.global_position
		bullet.global_rotation = muzzle_point.global_rotation
		
		bullet.damage = damage_amount
	else:
		print("Erro, sem cena da bala.")
		
		
	# Decal

# --- Feedback visual do flash ---
func muzzle_flash():
	muzzle_light.light_energy = 2.0
	await get_tree().create_timer(0.1).timeout
	muzzle_light.light_energy = 0.0
