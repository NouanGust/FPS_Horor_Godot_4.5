extends Node3D

@onready var particles: GPUParticles3D = $GPUParticles3D



func _ready() -> void:
	particles.emitting = true
	
	await get_tree().create_timer(15.0).timeout
	var tween = create_tween()
	
	tween.tween_property($Decal, "modulate:a", 0.0, 2.0)
	await tween.finished
	queue_free()
