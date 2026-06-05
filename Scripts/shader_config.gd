extends Panel

@onready var rich_text_label_2: RichTextLabel = $VBoxContainer/RichTextLabel2
@onready var check_button: CheckButton = $VBoxContainer/CheckButton
@onready var h_slider: HSlider = $VBoxContainer/HSlider

@export var shader: ShaderMaterial
@onready var shader_path = Player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#print(shader.get_property_list())
	#print(shader.get_default_texture_parameter("pixel_size"))
	#print(shader.get_script())
	#print(shader.pixel_size)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_h_slider_value_changed(value: int) -> void:
	shader.set_shader_parameter("pixel_size", value)


func _on_check_button_toggled(toggled_on: bool) -> void:
	shader.set_shader_parameter("enabled", toggled_on)
