extends StaticBody3D

# --- Ref do Resource ---
@export var item_data: ItemData
@export var interaction_text: String = "Pegar Item"
@export var override_amount: int = -1

var collected = false


func _ready() -> void:
	if not item_data:
		print("Objeto %s sem ItemData" %[item_data])


func interact():
	print("Função interact do pickup.gd")
	if collected or not item_data: return
	var player = get_tree().get_first_node_in_group("player")
	
	if not player: return
	
	if not item_data:
		print("Erro: Objeto sem ItemData!")
		return
	
	collected = true
	
	var data_to_pass = item_data.duplicate()
	if override_amount > 0:
		data_to_pass.amount = override_amount
	elif data_to_pass.type == ItemData.Item_type.AMMO:
		data_to_pass.amount = randi_range(2, 10)
	
	var should_inspect: bool = false
	
	match data_to_pass.type:
		ItemData.Item_type.EQUIPMENT, ItemData.Item_type.KEY_COMMON, ItemData.Item_type.KEY:
			should_inspect = true
		ItemData.Item_type.AMMO, ItemData.Item_type.CONSUMABLE:
			if not player.has_seen_item(data_to_pass.name):
				should_inspect = true
				player.mark_item_as_seen(data_to_pass.name)
			else:
				should_inspect = false
		
	if should_inspect:
		ItemInspector.inspect_item(data_to_pass)
	else:
		print("Coletou: ", data_to_pass.name)
	player.collect_item(data_to_pass)
	queue_free()
