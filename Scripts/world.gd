extends Node3D

# --- Config do Jogo ---
@export var game_duration: float = 300.0
@export var items_to_win: int = 10

# --- Variáveis de Estado ---
var time_left: float = 0.0
var items_collected: int = 0
var is_game_over: bool = false


# --- Ref da UI --- 
@onready var timer_label = $Player/CanvasLayer/Panel/Timer_label
@onready var itens_label = $Player/CanvasLayer/Panel/Itens_label
@onready var game_over_scren = $Player/CanvasLayer/GameOverScreen
@onready var resut_label = $Player/CanvasLayer/GameOverScreen/Result_label
@onready var restart_btn = $Player/CanvasLayer/GameOverScreen/Restart_btn

# --- Ref Player --- 
@onready var player = $Player

func _ready() -> void:
	time_left = game_duration
	update_ui()
	game_over_scren.visible = false
	
	restart_btn.pressed.connect(restart_game)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_game_over: return
	
	# Cronômetro
	time_left -= delta
	if time_left <= 0:
		time_left = 0
		game_over(false)
	
	update_ui()
	


# --- Função para atualizar a UI
func update_ui() -> void:
	var minutes = floor(time_left / 60)
	var seconds = int(time_left) % 60
	timer_label.text = "%02d:%02d" %[minutes, seconds]
	
	itens_label.text = "%d / %d" % [items_collected, items_to_win]


# --- Função para coletar itens --- 
func collect_item() -> void:
	if is_game_over: return
	
	items_collected += 1
	update_ui()
	
	if items_collected >= items_to_win:
		game_over(true)
		


# --- Função GameOver
func game_over(win: bool) -> void:
	is_game_over = true
	game_over_scren.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if win:
		resut_label.text = "VOCÊ COLETOU TODOS OS ITENS!"
		resut_label.modulate = Color(0,1,0)
	else:
		resut_label.text = "ACABOU O TEMPO \n TENTE OUTRA VEZ"
		resut_label.modulate = Color(1,0,0)
	

# --- Função para reiniciar o jogo
func restart_game() -> void:
	get_tree().reload_current_scene()
