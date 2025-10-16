extends CharacterBody2D

var pixeles_por_metro: float = 80
var direction: Vector2 = Vector2.ZERO
var rapidez: float = 5 * pixeles_por_metro

var esta_en_dano: bool = false

@onready var barra_salud: ProgressBar = $ProgressBar
const MinijuegoLetrasEscena = preload("res://assets/Escenas/main.tscn")
const MisilEscena_original = preload("res://assets/Escenas/misil.tscn")
const Misilblue = preload("res://assets/Escenas/misil_2.tscn")

var misiles_disponibles = {
	"hechizo": MisilEscena_original,
	"hechizo2": Misilblue,
}

var minijuego_activo: bool = false
var instancia_minijuego: Node = null
var misil_a_lanzar: PackedScene = null

func _ready():
	add_to_group("jugador")
	
	# Conectar la señal del singleton para actualizar la barra
	VidaJugador.vida_cambiada.connect(actualizar_salud)
	
	# Actualizar la barra con los valores actuales
	actualizar_salud(VidaJugador.vida, VidaJugador.vidamax)

	# Asegurarse de que el Area2D exista
	if $Area2D:
		$Area2D.area_entered.connect(_on_area_entered)
	else:
		push_error("⚠️ No se encontró el nodo Area2D en el personaje.")

func _on_area_entered(area: Area2D):
	print("🔥 Colisión detectada con:", area.name, "| grupos:", area.get_groups())
	
	if area.is_in_group("enemigo1"):
		reproducir_dano()
		VidaJugador.restar_vida(10)  # Usar el singleton
	elif area.is_in_group("misilEnemigo"):
		reproducir_dano()
		VidaJugador.restar_vida(20)  # Usar el singleton

func reproducir_dano():
	if not esta_en_dano:
		esta_en_dano = true
		$AnimatedSprite2D.play("daño")
		$AnimatedSprite2D.animation_finished.connect(_on_animacion_dano_terminada, CONNECT_ONE_SHOT)

func _on_animacion_dano_terminada():
	esta_en_dano = false

func _input(event):
	direccion()
	verificar_lanzamiento()
	cancelarAtaque()

func _physics_process(delta):
	if not minijuego_activo:
		movimiento()

# --- Movimiento del jugador ---
func direccion():
	if esta_en_dano: return
	direction = Vector2.ZERO
	if Input.is_action_pressed("derecha"):
		$AnimatedSprite2D.play("correr2")
		$AnimatedSprite2D.flip_h = false
		direction.x += 1
	if Input.is_action_pressed("izquierda"):
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play("correr2")
		direction.x -= 1
	if Input.is_action_pressed("arriba"):
		direction.y -= 1
		$AnimatedSprite2D.play("correr2")
	if Input.is_action_pressed("abajo"):
		direction.y += 1
		$AnimatedSprite2D.play("correr2")
	if direction == Vector2.ZERO:
		$AnimatedSprite2D.play("idle")
	else:
		direction = direction.normalized()

func movimiento():
	velocity = direction * rapidez
	move_and_slide()

# --- Minijuego de hechizos ---
func verificar_lanzamiento():
	for nombre_accion in misiles_disponibles:
		if Input.is_action_just_pressed(nombre_accion) and not minijuego_activo:
			misil_a_lanzar = misiles_disponibles[nombre_accion]

			var cantidad_letras = 5
			if nombre_accion == "hechizo":
				cantidad_letras = 3
			elif nombre_accion == "hechizo2":
				cantidad_letras = 6

			activar_minijuego(cantidad_letras)

func cancelarAtaque():
	if Input.is_action_pressed("espacio"):
		desactivar_minijuego()

func activar_minijuego(cantidad_letras: int):
	$AnimatedSprite2D.play("atacar")
	$AnimatedSprite2D.animation_finished.connect(_on_animacion_terminada)

	instancia_minijuego = MinijuegoLetrasEscena.instantiate()
	get_parent().add_child(instancia_minijuego)

	instancia_minijuego.max_letras = cantidad_letras
	instancia_minijuego.minijuego_terminado.connect(_on_minijuego_terminado)

	minijuego_activo = true
	set_process_input(false)

func _on_animacion_terminada():
	if $AnimatedSprite2D.animation == "atacar":
		$AnimatedSprite2D.play("cargarAtaque")
	elif $AnimatedSprite2D.animation == "cargarAtaque":
		instancia_minijuego.visible = true
		$AnimatedSprite2D.animation_finished.disconnect(_on_animacion_terminada)

func _on_minijuego_terminado(puntuacion_final):
	var puntos_por_letra = 10
	var puntos_necesarios = instancia_minijuego.max_letras * puntos_por_letra

	if puntuacion_final >= puntos_necesarios:
		lanzar_misil()

	desactivar_minijuego()

func desactivar_minijuego():
	if instancia_minijuego:
		instancia_minijuego.queue_free()
		instancia_minijuego = null
	minijuego_activo = false
	set_process_input(true)

func lanzar_misil():
	if misil_a_lanzar:
		var nuevo_misil = misil_a_lanzar.instantiate()
		get_parent().add_child(nuevo_misil)
		if nuevo_misil.has_method("lanzar"):
			var mouse_pos = get_global_mouse_position()
			var direccion_misil = (mouse_pos - global_position).normalized()
			nuevo_misil.lanzar(global_position, direccion_misil)
		misil_a_lanzar = null

func actualizar_salud(vida_actual: int, vida_maxima: int):
	if barra_salud:
		barra_salud.actualizar_barra(vida_maxima, vida_actual)
