extends Area2D
func _on_body_entered(body:Node)->void:
	if body.is_in_group("jugador"):
		print("cambiandod")
		get_tree().change_scene_to_file("res://assets/nivel/nivel_3.tscn")
