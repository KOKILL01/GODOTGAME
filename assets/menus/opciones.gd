extends Control

	

@onready var slider = $VBoxContainer/HSlider
@onready var label = $VBoxContainer/Label
@onready var audio = get_node("/root/music/AudioStreamPlayer")

func _ready():
	
	if not music.get_node("AudioStreamPlayer").playing:
		music.get_node("AudioStreamPlayer").play()  # acceder al hijo
	
	
	slider.min_value = 0
	slider.max_value = 1
	slider.step = 0.01

	if audio:
		slider.value = db_to_linear(audio.volume_db)
		slider.connect("value_changed", Callable(self, "_on_volume_changed"))
		_on_volume_changed(slider.value)
	else:
		label.text = "Volumen: Error (sin música)"

func _on_volume_changed(value: float) -> void:
	if audio:
		audio.volume_db = linear_to_db(value)
		label.text = "Volumen: %d%%" % int(value * 100)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/menus/menu.tscn") # Replace with function body.
