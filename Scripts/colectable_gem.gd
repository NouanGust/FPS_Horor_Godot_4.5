extends StaticBody3D

@export var interaction_text: String
@export var rotation_speed: float = 1.0

# --- Referências ---
@onready var models = $Modelos

var collected: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize_jewel()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not collected:
		rotation.y += rotation_speed * delta


# --- Função para randomizar a joia ---
func randomize_jewel():
	var gems = models.get_children()
	
	for gem in gems:
		if gem is Node3D:
			gem.visible = false
			
	if gems.size() > 0:
		var chose = gems.pick_random()
		chose.visible = true


# --- Coleta ---
func interact():
	if collected: return
	collected = true
	
	var main_scene = get_tree().current_scene
	if main_scene.has_method("collect_item"):
		main_scene.collect_item()
	
	visible = false
	$CollisionShape3D.disabled = true
	
	queue_free()
