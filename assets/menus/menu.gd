extends Control


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/nivel/nivel_1.tscn")


func _on_cerrar_pressed() -> void:
	get_tree().quit()
