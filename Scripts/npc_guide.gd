extends StaticBody3D

@export var interaction_text: String

# --- Refs --- 
@onready var anim_player:AnimationPlayer = $Esqueleto_1/AnimationPlayer
@onready var detection_area:Area3D = $Detection_area

# --- Config das animações --- 
const ANIM_IDLE = "rig_007|mixamo_com|Layer0"
const ANIM_CALL = "rig_001|mixamo_com|Layer0"
const ANIM_TALK = "rig_003|mixamo_com|Layer0"
const ANIM_TALK_OTHER = "rig_004|mixamo_com|Layer0"

# --- Config das falas

var tips: Array = [
	["Olá estranho!","É um local estranho esse aqui, não é?!","Acho que você deveria procurar alguma pista para sair daqui antes que acabe como o Frank aqui."],
	["A grande vantagem de estar só o osso... é poder descansar em paz", "Me diga estranho, gostaria de descansar também."],
	["Ah, você outra vez... me deixa cara!"],
	["HAHAHAHAHAHAHAHAHAHA", "Lembrei de uma piada"],
	["Procura na torre grande", "Não é difícil de achar... ela é grande"],
]

# --- Estados ---

var player_in_area:bool = false
var is_talking:bool = false



func _ready() -> void:
	play_anim_smooth(ANIM_IDLE)
	
	detection_area.body_entered.connect(_on_player_entered)
	detection_area.body_exited.connect(_on_player_exited)


# --- Sistema de animação
func play_anim_smooth(anim_name: String, blend_time:float = 0.2):
	anim_player.play(anim_name, blend_time)
	

# --- Detectar proximidade --- 
func _on_player_entered(body):
	if body.name == "Player" or body.is_in_group("player"):
		player_in_area = true
		if not is_talking:
			play_anim_smooth(ANIM_CALL)

func _on_player_exited(body):
	if body.name == "Player" or body.is_in_group("player"):
		player_in_area = false
		if not is_talking:
			play_anim_smooth(ANIM_IDLE)

# --- Interação --- 
func interact():
	if is_talking: return
	
	give_tip()

func give_tip():
	if is_talking: return
	
	is_talking = true
	play_anim_smooth(ANIM_TALK)
	
	var dialogue_box = get_tree().get_first_node_in_group("ui_dialogue")
	
	if dialogue_box:
		var current_tip: Array = tips.pick_random()
		print(current_tip)
		dialogue_box.start_dialogue("Frank", current_tip)
		
		if not dialogue_box.dialogue_finished.is_connected(_on_dialogue_finished):
			dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	else:
		print("DialogBox não achado")
		is_talking = false
	

func _on_dialogue_finished() -> void:
	if player_in_area:
		play_anim_smooth(ANIM_CALL)
	else:
		play_anim_smooth(ANIM_IDLE)
	
	await get_tree().create_timer(1.0).timeout
	
	is_talking = false
func _process(_delta: float) -> void:
	pass
