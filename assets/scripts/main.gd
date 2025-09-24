extends Node2D

# Señal para avisar cuando el minijuego termina
signal minijuego_terminado(puntuacion_final)

const LetraEscena = preload("res://assets/Escenas/letras.tscn")
var puntuacion: int = 0
var letra_actual: Node = null
var letras_mostradas: int = 0
var max_letras: int = 5  # Cambiado a 5 para coincidir con tu condición

func _ready():
	generar_nueva_letra()

func generar_nueva_letra():
	# Verificar si hemos alcanzado el límite máximo
	if letras_mostradas >= max_letras:
		print("Se ha alcanzado el límite de letras")
		game_over()
		return

	# Si ya hay una letra en pantalla, eliminarla
	if letra_actual:
		letra_actual.queue_free()
		letra_actual = null

	# Crear una nueva letra
	letra_actual = LetraEscena.instantiate()
	add_child(letra_actual)

	# Incrementar el contador de letras mostradas
	letras_mostradas += 1

	# Conectar la señal
	letra_actual.letra_presionada_correctamente.connect(_on_letra_presionada)

	# Obtener la cámara activa del jugador
	var cam = get_viewport().get_camera_2d()
	if cam:
		var cam_pos = cam.global_position
		var cam_size = get_viewport().get_visible_rect().size / 2
		var margen = 50

		# Generar dentro de los límites visibles de la cámara
		var pos_x = randf_range(cam_pos.x - cam_size.x + margen, cam_pos.x + cam_size.x - margen)
		var pos_y = randf_range(cam_pos.y - cam_size.y + margen, cam_pos.y + cam_size.y - margen)

		letra_actual.global_position = Vector2(pos_x, pos_y)
		print("Letra ", letras_mostradas, " de ", max_letras, " - Posición: ", letra_actual.global_position)
	else:
		# Si no encuentra cámara, usar fallback al viewport
		var viewport_size = get_viewport().get_visible_rect().size
		var margen = 50
		var pos_x = randf_range(margen, viewport_size.x - margen)
		var pos_y = randf_range(margen, viewport_size.y - margen)
		letra_actual.position = Vector2(pos_x, pos_y)
		print("Letra (fallback) en posición viewport: ", letra_actual.position)

func _on_letra_presionada(_letra_presionada: String):
	puntuacion += 10
	if has_node("PuntuacionLabel"):
		$PuntuacionLabel.text = "Puntos: " + str(puntuacion)
	print("Puntuación: ", puntuacion)

	# Generar una nueva letra después de acertar
	generar_nueva_letra()

func game_over():
	print("¡Juego terminado! Puntuación final: ", puntuacion)
	# Emitir la señal de que el minijuego terminó
	minijuego_terminado.emit(puntuacion)
	# Esperar un poco antes de cerrar (opcional)
	await get_tree().create_timer(1.0).timeout
	# Cerrar el minijuego
	queue_free()
