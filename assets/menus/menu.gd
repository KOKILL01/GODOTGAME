extends Control

func _ready():
	music.get_node("AudioStreamPlayer").stop()
	

func _on_play_pressed() -> void:
	# Detener música del menú (si la hay)
	$AudioStreamPlayer.stop()
	
	# Cambiar a nivel 1
	get_tree().change_scene_to_file("res://assets/nivel/nivel_1.tscn")

func _on_cerrar_pressed() -> void:
	get_tree().quit()
	
func _on_tutorial_pressed():
	
	$AudioStreamPlayer.stop()
	get_tree().change_scene_to_file("res://assets/nivel/node_2d.tscn")


func _on_opciones_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/menus/opciones.tscn") # Replace with function body.
