extends StaticBody3D

# --- Config do barril --- 
var vida: int = 30
var original_material: Material

# --- Refs ---
@onready var mesh: MeshInstance3D = $Barrel1

func _ready() -> void:
	if mesh:
		var mat = mesh.get_active_material(0)
		if mat:
			original_material = mat.duplicate()
			mesh.set_surface_override_material(0, original_material)

# --- Função de dano ---
func take_damage(amount) -> void:
	vida -= amount
	
	# Feedback visual de dano
	if original_material is StandardMaterial3D:
		var tween = create_tween()
		tween.tween_property(original_material, "albedo_color", Color(1,0,0), 0.0)
		tween.tween_interval(0.3)
		tween.tween_property(original_material, "albedo_color", Color(1,1,1), 0.0)
		
	
	# Dar dano
	if vida <= 0:
		queue_free()
