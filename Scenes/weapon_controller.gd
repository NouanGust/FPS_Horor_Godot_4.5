extends Node3D

# --- Ref de Nodes --- 
@onready var raycast: RayCast3D = $RayCast3D
@onready var muzzle_light: OmniLight3D = $OmniLight3D
@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D


# --- Função de atirar
func shoot(damage_amount: int) -> void:
	muzzle_flash()
	
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		print("Tiro acertou: %s" %[collider])
		
		if collider.has_method("take_damage"):
			collider.take_damage(damage_amount)
		
	# Decal

# --- Feedback visual do flash ---
func muzzle_flash():
	muzzle_light.light_energy = 2.0
	await get_tree().create_timer(0.05).timeout
	muzzle_light.light_energy = 0.0
