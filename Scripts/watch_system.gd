extends Node3D

# --- Ref ---
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var time_label: Node3D = $LeftArm/Time_label
@onready var items_label: Node3D = $LeftArm/Items_label
@onready var inventory_layer: CanvasLayer = $Inventory_layer
@onready var grid_container: GridContainer = $Inventory_layer/ColorRect/Panel/GridContainer

# --- Estados ---
var is_watching = false


func _ready() -> void:
	anim_player.play("RESET")
	inventory_layer.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		toggle_watch()

# --- Função para controlar o relógio ---
func toggle_watch():
	is_watching = !is_watching
	
	if is_watching:
		get_tree().paused = true
		anim_player.play("Look_Watch")
		update_watch_info()
		
		# Inventário
		# Mouse Visible
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		inventory_layer.visible = true
		update_inventory_ui()
		
	else:
		anim_player.play_backwards("Look_Watch")
		await  anim_player.animation_finished
		get_tree().paused = false
		inventory_layer.visible = false
		# Mouse Captured
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func update_watch_info():
	var world = get_tree().current_scene
	
	if "time_left" in world and "items_collected" in world:
		var minutes = floor(world.time_left / 60)
		var seconds = int(world.time_left) % 60
		time_label.text = "%02d:%02d" % [minutes, seconds]
		
		items_label.text = "%d/%d" % [world.items_collected, world.items_to_win]
		
		if world.time_left < 60:
			time_label.modulate = Color(1,0,0)
		else:
			time_label.modulate = Color(0,1,0)
	else:
		time_label.text = "--:--"


# --- UI do Inventário ---
func update_inventory_ui() -> void:
	# Limpa os botões 
	for child in grid_container.get_children():
		child.queue_free()
		
	var player = get_tree().get_first_node_in_group("player")
	if not player: return

	
	for i in range(player.inventory.size()):
		var item = player.inventory[i]
		
		if item:
			var btn = Button.new()
			btn.custom_minimum_size = Vector2(80,80)
			
			if item.icon:
				btn.icon = item.icon
				btn.expand_icon = true
				btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
				btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
			else:
				btn.text = item.name
				btn.clip_text = true
				
			btn.tooltip_text = item.name
			btn.pressed.connect(_on_item_clicked.bind(player, i))
			grid_container.add_child(btn)


func _on_item_clicked(player: CharacterBody3D, index: int) -> void:
	player.equip_item(index)
	toggle_watch()
