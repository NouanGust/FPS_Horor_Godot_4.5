extends CharacterBody3D
class_name Player

# Move config
@export_category("Movimento")
@export var speed: float = 4.0
@export var sprint_speed: float = 6.0
@export var jump_velocity: float = 4.5
@export var mouse_sense: float = 0.003

# Escadas e degraus
@export_category("Escadas e degraus")
@export var max_step_height: float = 0.5
@export var step_check_distance: float = 0.5

# HeadBob
@export_category("HeadBob")
@export var bob_freq:float = 2.5
@export var bob_amp:float = 0.2
var t_bob: float = 0.0

# --- Ref de Nodes ---
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var raycast: RayCast3D = $Head/Camera3D/RayCast3D
@onready var hud_reticle: ColorRect = $CanvasLayer/ColorRect
@onready var flashlight:SpotLight3D = $Head/Camera3D/HandHolder/SpotLight3D
@onready var hand_holder: Node3D = $Head/Camera3D/HandHolder
@onready var ammo_display: Label = $CanvasLayer/AmmoDisplay
@onready var interaction_label: Label = $CanvasLayer/Label

@export_category("Sway e lanterna")
@export var sway_amount: float = 0.002
@export var sway_smooth: float = 10.0
@export var sway_max_angle: float = 5.0
@export var flashlight_smoothness: float = 15.0
var mouse_input_sway: Vector2 = Vector2.ZERO

# --- Inventário ---
@export var inventory: Array[ItemData] = []
var current_item_index: int = -1
var current_item_node: Node3D = null
var history_items_seen: Array[String] = []

# ---  Sistema de Combate
@export var ammo: int = 0

# --- Utilitários ---
var is_frozen: bool = false

#func get_shader() -> Shader:
	#return camera.

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if inventory.size() > 0:
		equip_item(0)
	


func _unhandled_input(event: InputEvent) -> void:
	if is_frozen: return
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_input_sway = event.relative
		rotate_y(-event.relative.x * mouse_sense)
		head.rotate_x(-event.relative.y * mouse_sense)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	if Input.is_action_just_pressed("pause"):
		if Input.mouse_mode ==  Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	if is_frozen: return
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Movimentação
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var current_speed = sprint_speed if Input.is_action_pressed("sprint") else speed
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		
	
	# HeadBob
	t_bob = delta * velocity.length() * float(is_on_floor())
	var pos = Vector3.ZERO
	pos.y = sin(t_bob * bob_freq) * bob_amp
	pos.x = cos(t_bob * bob_freq / 2) * bob_amp
	camera.transform.origin = pos
	
	# Manter a luz da laterna em foco e sway
	_process_sway(delta)
	#_update_flashlight_focus(delta)
	# Interação 
	check_interation()
	
	# Tiro/Combate
	_handle_shooting()
	
	# Mover padrão da Godot
	move_and_slide()
	
	
	
	# Degraus
	if is_on_floor() and direction != Vector3.ZERO:
		_handle_stairs(delta, direction)


# --- Função para lidar com foco da lanterna --- 
func _update_flashlight_focus(delta) -> void:
	var target_point: = Vector3.ZERO
	
	if raycast.is_colliding():
		target_point = raycast.get_collision_point()
	else:
		target_point = raycast.global_position + (-raycast.global_transform.basis.z * 20.0)
		
	var target_transform = flashlight.global_transform.looking_at(target_point, Vector3.UP)
	flashlight.global_transform = flashlight.global_transform.interpolate_with(target_transform, flashlight_smoothness * delta)
 
# --- Função do Sway
func _process_sway(delta: float) -> void:
	mouse_input_sway = mouse_input_sway.lerp(Vector2.ZERO, 10 * delta)
	
	var target_rot_x = -mouse_input_sway.y * sway_amount
	var target_rot_y = -mouse_input_sway.x * sway_amount
	
	target_rot_x = clamp(target_rot_x, deg_to_rad(-sway_max_angle), deg_to_rad(sway_max_angle))
	target_rot_y = clamp(target_rot_y, deg_to_rad(-sway_max_angle), deg_to_rad(sway_max_angle))
	
	var target_rotation = Vector3(target_rot_x, target_rot_y, 0)
	
	hand_holder.rotation.x = lerp_angle(hand_holder.rotation.x, target_rotation.x, sway_smooth * delta)
	hand_holder.rotation.y = lerp_angle(hand_holder.rotation.y, target_rotation.y, sway_smooth * delta)
	
	var breathing_time = Time.get_ticks_msec() * 0.001
	var breath_x = sin(breathing_time * 1.0) * 0.002
	var breath_y = cos(breathing_time * 0.5) * 0.002
	
	hand_holder.rotation.x += breath_x
	hand_holder.rotation.y += breath_y

# --- Função para checar e aplicar interação ---
func check_interation() -> void:
	if is_frozen: 
		interaction_label.visible = false
		return
	
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider and collider.is_in_group("interactable"):
			hud_reticle.modulate = Color(1,0,0)
			
			interaction_label.visible = true
			var text = "Interagir"
			if "interaction_text" in collider:
				text = collider.interaction_text
			
			interaction_label.text = "[E]" + text
			if Input.is_action_just_pressed("interact"):
				collider.interact()
		else:
			hud_reticle.modulate = Color(0, 199, 200)
			interaction_label.visible = false
	else:
		hud_reticle.modulate = Color(0, 199, 200)
		interaction_label.visible = false

# --- Função para lidar com escadas e degraus --- 
func _handle_stairs(_delta: float, input_dir) -> void:
	if not is_on_wall(): return
	
	var test_transform = global_transform
	var forward_move = input_dir * step_check_distance * 0.5
	
	test_transform.origin.y += max_step_height
	test_transform.origin += forward_move
	
	if not test_move(test_transform, Vector3.ZERO):
		var down_check_dist = max_step_height * 1.5
		var _collision = move_and_collide(Vector3(0, -down_check_dist, 0), true, 0.001, true)
		position.y += max_step_height * 0.1

# --- Funções do Inventário ---
func collect_item(data: ItemData) -> void:
	match data.type:
		ItemData.Item_type.EQUIPMENT:
			add_item(data)
			
			if current_item_index == -1 and data.model_scene:
				equip_item(inventory.size() -1) 
		ItemData.Item_type.AMMO:
			add_ammo(data.amount)
			
		ItemData.Item_type.CONSUMABLE:
			add_item(data)
			
		ItemData.Item_type.KEY_COMMON:
			add_item(data)
			
		ItemData.Item_type.KEY:
			pass
			

func add_item(new_item: ItemData) -> void:
	inventory.append(new_item)
	print("Item adicionado: %s \n Tamanho do inventário: %s" %[new_item.name, inventory.size()])

func equip_item(index: int) -> void:
	if index < 0 or index >= inventory.size(): return
	
	current_item_index = index
	var item_data = inventory[index]
	
	if current_item_node:
		current_item_node.queue_free()
		current_item_node = null
		
	if item_data.model_scene:
		current_item_node = item_data.model_scene.instantiate()
		hand_holder.add_child(current_item_node)
		
		current_item_node.position = Vector3.ZERO
		current_item_node.rotation = Vector3.ZERO
		
	print("Equipado ", item_data.name)
	
	if item_data.is_weapon:
		ammo_display.visible = true
		update_ammo_ui()
	else:
		ammo_display.visible = false
		


func use_current_item():
	if current_item_index == -1: return
	
	var item_data = inventory[current_item_index]
	
	if item_data.is_consumable:
		print("Usou: ", item_data.name)
		inventory.remove_at(current_item_index)
		current_item_node.queue_free()
		current_item_index = -1

# --- Combate ---
func _handle_shooting() -> void:
	if Input.is_action_just_pressed("shoot"):
		if current_item_index == -1: return
		var item_data = inventory[current_item_index]
		
		if not item_data.is_weapon: return
		
		if ammo > 0:
			if current_item_node and current_item_node.has_method("shoot"):
				current_item_node.shoot(item_data.damage)
				ammo -= 1
				update_ammo_ui()
				head.rotate_x(deg_to_rad(2.0))
		else:
			print("Sem munição")
			var tween = create_tween()
			tween.tween_property(ammo_display, "modulate", Color.RED, 0.1)
			tween.tween_property(ammo_display, "modulate", Color.WHITE, 0.1)
			


func add_ammo(amount: int):
	ammo += amount
	print("Munição coletada! Total: ", ammo)
	
	if current_item_index != -1:
		var item = inventory[current_item_index]
		if item.is_weapon:
			update_ammo_ui()

func update_ammo_ui() -> void:
	ammo_display.text = str(ammo)

# --- Utilitários ----
func set_freeze(state: bool) -> void:
	is_frozen = state
	if hud_reticle:
		hud_reticle.visible = not state
		
	if is_frozen:
		velocity = Vector3.ZERO
		

func has_seen_item(item_name: String) -> bool:
	return history_items_seen.has(item_name)

func mark_item_as_seen(item_name: String) -> void:
	if not history_items_seen.has(item_name):
		history_items_seen.append(item_name)
