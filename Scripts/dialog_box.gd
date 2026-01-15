extends Control

# --- Sinais ---
signal dialogue_finished

# --- Config do diálogo
@export var text_speed: float = 0.05

# --- Ref ---
@onready var name_label: RichTextLabel = $MarginContainer/VBoxContainer/Name_label
@onready var text_label: RichTextLabel = $MarginContainer/VBoxContainer/Text_label

# --- Var de Estados ---
var dialogues = []
var current_index = 0
var is_active: bool = false
var can_skip: bool = false


func _ready() -> void:
	visible = false

# --- Função para os diálogos
func start_dialogue(npc_name: String, speech: Array) -> void:
	dialogues = speech
	current_index = 0
	name_label.text = npc_name
	visible = true
	
	get_tree().call_group("player", "set_freeze", true)
	show_text()
	
func show_text():
	var current_text = dialogues[current_index]
	text_label.text = current_text
	
	text_label.visible_characters = 0
	can_skip = false
	
	var tween = create_tween()
	var duration = current_text.length() * text_speed
	tween.tween_property(text_label, "visible_characters", current_text.length(), duration)
	tween.finished.connect(func(): can_skip = true)
	

func _input(event: InputEvent) -> void:
	if not visible: return
	
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		if can_skip:
			next_line()
		else:
			text_label.visible_characters = -1
			can_skip = true
		

func next_line():
	current_index += 1
	if current_index < dialogues.size():
		show_text()
	else:
		close_dialogue()

func close_dialogue():
	#is_active = false
	visible = false
	get_tree().call_group("player", "set_freeze", false)
	Input.action_release("interact")
	emit_signal("dialogue_finished")
	
