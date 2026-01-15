extends Area3D
# --- Config ---
@export var speed: float = 100.0
@export var impact_effect_scene: PackedScene
@onready var raycast: RayCast3D = $RayCast3D
var damage: int = 0

func _ready() -> void:
	set_collision_layer_value(1, false)
	
	body_entered.connect(_on_body_entered)
	$Timer.timeout.connect(_on_timer_timeout)



func _process(delta: float) -> void:
	position -= transform.basis.z * speed * delta
	
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		var hit_point = raycast.get_collision_point()
		var hit_normal = raycast.get_collision_normal()
		
		_handle_impact(collider, hit_point, hit_normal)


# --- Função de colisão da bala ---
func _on_body_entered(body):
	print("Acertou: ", body.name)
	
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	# Feedback visual - sangue ou particulas
	queue_free()
	

# --- Utils ---
func _on_timer_timeout():
	queue_free()

func _handle_impact(collider, point, normal):
	if collider.has_method("take_damage"):
		collider.take_damage(damage)
		
	
	if impact_effect_scene:
		var effect = impact_effect_scene.instantiate()
		get_tree().current_scene.add_child(effect)
		
		effect.global_position = point
		
		if normal.is_equal_approx(Vector3.UP) or normal.is_equal_approx(Vector3.DOWN):
			effect.look_at(point + normal, Vector3.RIGHT)
		else:
			effect.look_at(point + normal, Vector3.UP)
	queue_free()
