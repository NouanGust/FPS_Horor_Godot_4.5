extends Node3D

# --- Interação ---
@export var interaction_text: String

@onready var anim_player: AnimationPlayer = $"../../AnimationPlayer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
	
func interact():
	anim_player.play("Open")
	await anim_player.animation_finished
	await get_tree().create_timer(4).timeout
	anim_player.play("Close")
