extends Resource
class_name ItemData

enum Item_type {
	EQUIPMENT,
	AMMO,
	CONSUMABLE,
	KEY_COMMON,
	KEY,
}

# --- Caracteristicas dos itens ---
@export_category("Dados dos itens")
@export var type: Item_type = Item_type.EQUIPMENT
@export var name: String = "Item Genérico"
@export_multiline var description: String = "Desrição do item"
@export var is_weapon: bool = false

@export_category("Configs")
@export var icon: Texture2D
@export var model_scene: PackedScene
@export var amount: int = 1
@export var damage: int = 0
