extends StaticBody3D

# --- Interação ---
@export var interaction_text: String

@export var min_amount: int = 2
@export var max_amount: int = 10

func interact() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		#ItemInspector.inspect_item(item_data)
		var amount := randi_range(min_amount, max_amount)
		player.add_ammo(amount)
		print("Munição coletada: ", player.ammo)
		queue_free()
