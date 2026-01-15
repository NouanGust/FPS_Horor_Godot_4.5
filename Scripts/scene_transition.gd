extends CanvasLayer

# --- Ref ---
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = $ColorRect

# --- Variáveis de Memória ---
var saved_outside_transform: Transform3D
var is_inside: bool = false

func _ready() -> void:
	color_rect.visible = false


# --- Função para entrar ---
func enter_interior(player: CharacterBody3D, destiny: Node3D) -> void:
	saved_outside_transform = player.global_transform
	print(saved_outside_transform)
	destiny.transform.basis = destiny.transform.basis.rotated(Vector3.UP, PI)
	_teleport_with_loading(player, destiny.global_transform)
	is_inside = true
	print(saved_outside_transform)
	

# --- Função para sair ---
func exit_to_world(player: CharacterBody3D) -> void:
	var target_transform = saved_outside_transform
	print(saved_outside_transform)
	print(target_transform)
	 #Rotacionar o jogador 180° para ficar de costas para porta
	target_transform.basis = target_transform.basis.rotated(Vector3.UP, PI)
	
	_teleport_with_loading(player, target_transform)
	is_inside = false
	print(saved_outside_transform)
	print(target_transform)

# --- Função para teletransportar o jogador ---
func _teleport_with_loading(player: CharacterBody3D,target_transform: Transform3D) -> void:
	print("Teleportando para: ", target_transform.origin)
	if player.has_method("set_freeze"): player.set_freeze(true)
	
	color_rect.visible = true
	anim_player.play("fade_in")
	await anim_player.animation_finished
	
	player.global_transform = target_transform
	
	if player.has_node("Head"): player.get_node("Head").rotation.x = 0

	await get_tree().create_timer(0.8).timeout
	
	anim_player.play("fade_out")
	color_rect.visible = false
	
	if player.has_method("set_freeze"): player.set_freeze(false)
