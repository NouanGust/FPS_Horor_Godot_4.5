extends StaticBody3D

@export var interaction_text: String

@export var destiny_point: Marker3D
@export var local_name: String = "Galpão 13"


# --- Função de interação ---
func interact():
	var player = get_tree().get_first_node_in_group("player")
	if not player : return
	
	if SceneTransition.is_inside:
		print("Saindo para o mundo")
		SceneTransition.exit_to_world(player)
	else:
		if destiny_point:
			print("Entrando em %s" %[local_name])
			SceneTransition.enter_interior(player, destiny_point)
		else:
			print("impossivel sair")
