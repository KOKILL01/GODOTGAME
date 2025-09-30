extends Control

func _ready():
	# Detener la música del singleton al entrar al menú
	music.get_node("AudioStreamPlayer").stop()  # acceder al hijo

func _on_play_pressed() -> void:
	# Detener música del menú (si la hay)
	$AudioStreamPlayer.stop()
	
	# Cambiar a nivel 1
	get_tree().change_scene_to_file("res://assets/nivel/nivel_1.tscn")

func _on_cerrar_pressed() -> void:
	get_tree().quit()
