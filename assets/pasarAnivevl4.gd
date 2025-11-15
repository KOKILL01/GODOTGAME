extends Area2D

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("jugador"):
		# Obtener todos los enemigos vivos en la escena actual
		var enemigos2 = get_tree().get_nodes_in_group("enemigo2")

		# Filtrar los que sigan "vivos" (por si algunos aún no han hecho queue_free)
		enemigos2 = enemigos2.filter(func(e): return e.is_inside_tree())

		if enemigos2.size() == 0:
			print("✅ No hay enemigos, cambiando de nivel...")
			get_tree().change_scene_to_file("res://assets/nivel/nivel_4.tscn")
		else:
			print("🚫 Aún hay enemigos vivos, no puedes avanzar.")
