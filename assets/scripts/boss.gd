extends Boss

func _ready():
	$AnimatedSprite2D.play("default")
	super._ready()
	velocidad = 200
	tiempo_accion = 2
	vida_maxima = 500
	vida_actual = vida_maxima
	if barra_vida:
		barra_vida.max_value = vida_maxima
		barra_vida.value = vida_actual


func _on_area_2d_area_entered(area: Area2D) -> void:
	pass


# 👇 Aquí sobrescribimos el método de la clase base
func activar_fase_2():
	if animacion_fase:
		return
	
	# ⬇️ Asegurar que las variables de control estén actualizadas
	animacion_fase = true
	en_animacion_fase = true
	
	# ⬇️ Detener movimiento inmediatamente
	velocity = Vector2.ZERO
	move_and_slide()
	
	# ⬇️ Detener cualquier animación actual
	if $AnimatedSprite2D:
		$AnimatedSprite2D.stop()
	
	print("🔥 Fase 2 activada en BOSS")

	await get_tree().process_frame

	var cam = $CameraBoss
	if cam and cam.is_inside_tree():
		cam.enabled = true
		cam.make_current()

		# Zoom in suave
		var tween = get_tree().create_tween()
		tween.tween_property(cam, "zoom", Vector2(2.5, 2.5), 1.5)
		await tween.finished
	else:
		print("⚠️ CameraBoss no está en el árbol o está deshabilitada")

	# Animación especial del boss
	if $AnimatedSprite2D:
		$AnimatedSprite2D.play("transformacion")
		await $AnimatedSprite2D.animation_finished

	# Regresar a la cámara del jugador
	if jugador and jugador.has_node("Camera2D"):
		var cam_jugador = jugador.get_node("Camera2D")
		cam_jugador.make_current()

	# Restaurar el zoom
	if cam:
		cam.zoom = Vector2(1, 1)

	# ⬇️ Restaurar control
	animacion_fase = false
	en_animacion_fase = false
	print("✅ Fin de animación de fase 2")
