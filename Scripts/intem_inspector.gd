extends CanvasLayer

# --- Refs ---
@onready var item_pivot: Node3D = $SubViewportContainer/SubViewport/ItemPivot
@onready var name_label: Label = $Name_label

# --- Configs ---
var is_inspecting: bool = false

func _ready() -> void:
	visible = false

func inspect_item(item_data: ItemData):
	print("inspeção: ", item_data)
	get_tree().paused = true
	is_inspecting = true
	visible = true
	
	name_label.text = item_data.name
	for child in item_pivot.get_children():
		child.queue_free()
	
	if item_data.model_scene:
		var model = item_data.model_scene.instantiate()
		item_pivot.add_child(model)
		
		model.position = Vector3.ZERO
		
		if model.has_method("set_process") : model.set_process(false)
		if model.has_method("set_physics_process") : model.set_physics_process(false)


func _process(delta: float) -> void:
	if visible:
		item_pivot.rotate_y(1.0 * delta)

func _input(event: InputEvent) -> void:
	if not is_inspecting: return
	
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_cancel"):
		close_inspection()

func close_inspection():
	is_inspecting = false
	visible = false
	get_tree().paused = false
	
	for child in item_pivot.get_children():
		child.queue_free()
