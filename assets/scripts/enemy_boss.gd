extends CharacterBody2D
class_name Boss

@export var velocidad: float = 100
@export var tiempo_accion: float = 1.0
@export var ataqueenemigo_escena: PackedScene
@export var vida_maxima: int = 500

var vida_actual: float
var barra_vida: ProgressBar
var jugador: Node2D
var tiempo_actual: float = 0
var estado: int = 0
var direccion: Vector2 = Vector2.ZERO

signal fase_cambiada(fase: int)

var fase := 1
var animacion_fase := false
var en_animacion_fase := false


func _ready():
	vida_actual = vida_maxima
	
	if has_node("Control/ProgressBar"):
		barra_vida = $Control/ProgressBar
		barra_vida.max_value = vida_maxima
		barra_vida.value = vida_actual
	
	jugador = get_tree().get_first_node_in_group("jugador")
	if not jugador:
		print("Jugador no encontrado")
	
	if has_node("Area2D"):
		$Area2D.body_entered.connect(_on_area_2d_body_entered)
	
	elegir_accion()


func _process(delta):
	if en_animacion_fase:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	tiempo_actual -= delta
	
	if barra_vida:
		barra_vida.value = lerp(barra_vida.value, vida_actual, 5 * delta)
	
	match estado:
		1: seguir_jugador()
		2: disparar()
		3: esquivar()
	
	if tiempo_actual <= 0:
		elegir_accion()


# --- Daño y fases ---
func recibir_dano(cantidad: int):
	vida_actual -= cantidad
	if vida_actual < 0:
		vida_actual = 0
	
	if vida_actual <= vida_maxima / 2 and fase == 1:
		fase = 2
		emit_signal("fase_cambiada", fase)
		activar_fase_2()
	
	if vida_actual <= 0:
		morir()


func activar_fase_2():
	if animacion_fase:
		return
	
	animacion_fase = true
	en_animacion_fase = true
	
	# ✅ Detener todo movimiento y animación
	velocity = Vector2.ZERO
	move_and_slide()
	if $AnimatedSprite2D:
		$AnimatedSprite2D.stop()
	
	print("🔥 Fase 2 activada")
	
	var cam = $CameraBoss
	await get_tree().process_frame
	
	if cam and cam.is_inside_tree():
		cam.make_current()
		var tween = get_tree().create_tween()
		tween.tween_property(cam, "zoom", Vector2(0.5, 0.5), 1.5)
		await tween.finished
	
	# ✅ Reproducir transformación
	if $AnimatedSprite2D:
		$AnimatedSprite2D.play("transformacion")
		await $AnimatedSprite2D.animation_finished
	
	# ✅ Regresar cámara y restaurar control
	if jugador and jugador.has_node("Camera2D"):
		jugador.get_node("Camera2D").make_current()
	
	if cam:
		cam.zoom = Vector2(1, 1)
	
	animacion_fase = false
	en_animacion_fase = false
	
	print("✅ Fin animación de fase 2")


# --- Muerte ---
func morir():
	queue_free()


# --- IA / movimiento ---
func elegir_accion():
	if en_animacion_fase:
		return
	
	estado = randi_range(1, 3)
	tiempo_actual = tiempo_accion
	if estado == 3:
		direccion = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()


func seguir_jugador():
	if en_animacion_fase:
		return
	
	if jugador:
		$AnimatedSprite2D.play("default")
		var dir = (jugador.global_position - global_position).normalized()
		velocity = dir * velocidad
		move_and_slide()


func disparar():
	if en_animacion_fase:
		return
	
	if jugador and ataqueenemigo_escena:
		var ataque = ataqueenemigo_escena.instantiate()
		ataque.direccion = (jugador.global_position - global_position).normalized()
		get_parent().add_child(ataque)
		ataque.global_position = global_position
	
	tiempo_actual = 0


func esquivar():
	if en_animacion_fase:
		return
	
	$AnimatedSprite2D.play("default")
	velocity = direccion * velocidad
	move_and_slide()


# --- Colisiones ---
func _on_area_2d_body_entered(body: Node) -> void:
	if en_animacion_fase:
		return
	
	if body.is_in_group("misil1"):
		print("💥 Enemigo golpeado por misil 1")
		recibir_dano(250)
	elif body.is_in_group("misil2"):
		print("💥 Enemigo golpeado por misil 2")
		recibir_dano(250)
