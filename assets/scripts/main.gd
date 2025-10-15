extends Node2D

signal minijuego_terminado(puntuacion_final)

const LetraEscena = preload("res://assets/Escenas/letras.tscn")
var puntuacion: int = 0
var letra_actual: Node = null
var letras_mostradas: int = 0
var max_letras: int = 5  # Valor por defecto, se sobrescribe desde personaje.gd

func _ready():
	generar_nueva_letra()

func _input(event):
	if event.is_action_pressed("espacio"):
		game_over()

func generar_nueva_letra():
	if letras_mostradas >= max_letras:
		game_over()
		return

	if letra_actual:
		letra_actual.queue_free()
		letra_actual = null

	letra_actual = LetraEscena.instantiate()
	add_child(letra_actual)
	letras_mostradas += 1
	letra_actual.letra_presionada_correctamente.connect(_on_letra_presionada)

	var cam = get_viewport().get_camera_2d()
	if cam:
		var cam_pos = cam.global_position
		var cam_size = get_viewport().get_visible_rect().size / 2
		var margen = 50
		var pos_x = randf_range(cam_pos.x - cam_size.x + margen, cam_pos.x + cam_size.x - margen)
		var pos_y = randf_range(cam_pos.y - cam_size.y + margen, cam_pos.y + cam_size.y - margen)
		letra_actual.global_position = Vector2(pos_x, pos_y)
	else:
		var viewport_size = get_viewport().get_visible_rect().size
		var margen = 50
		letra_actual.position = Vector2(randf_range(margen, viewport_size.x - margen),
										randf_range(margen, viewport_size.y - margen))

func _on_letra_presionada(_letra_presionada: String):
	puntuacion += 10
	if has_node("PuntuacionLabel"):
		$PuntuacionLabel.text = "Puntos: " + str(puntuacion)
	generar_nueva_letra()

func game_over():
	minijuego_terminado.emit(puntuacion)
	await get_tree().create_timer(1.0).timeout
	queue_free()
