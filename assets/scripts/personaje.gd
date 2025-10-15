extends CharacterBody2D

var pixeles_por_metro: float = 80
var direction: Vector2 = Vector2.ZERO
var rapidez: float = 5 * pixeles_por_metro

var vidamax: int = 100
var vida: int = vidamax
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
	actualizar_salud()
	$Area2D.area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D):
	if area.is_in_group("enemigo1"):
		reproducir_dano()
		restar_vida(10)
	elif area.is_in_group("misilEnemigo"):
		reproducir_dano()
		restar_vida(20)

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

# --- Lanzamiento de hechizos ---
func verificar_lanzamiento():
	for nombre_accion in misiles_disponibles:
		if Input.is_action_just_pressed(nombre_accion) and not minijuego_activo:
			misil_a_lanzar = misiles_disponibles[nombre_accion]

			# Definir número de letras según el hechizo
			var cantidad_letras = 5
			if nombre_accion == "hechizo":
				cantidad_letras = 3
			elif nombre_accion == "hechizo2":
				cantidad_letras = 6

			activar_minijuego(cantidad_letras)

func cancelarAtaque():
	if Input.is_action_pressed("espacio"):
		desactivar_minijuego()

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

func activar_minijuego(cantidad_letras: int):
	$AnimatedSprite2D.play("atacar")
	$AnimatedSprite2D.animation_finished.connect(_on_animacion_terminada)

	instancia_minijuego = MinijuegoLetrasEscena.instantiate()
	get_parent().add_child(instancia_minijuego)

	# Pasar número de letras al minijuego
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
	# Cada letra vale 10 puntos
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

func restar_vida(cantidad: int):
	vida -= cantidad
	if vida < 0: vida = 0
	actualizar_salud()

func aumentar_vida(cantidad: int):
	vida += cantidad
	if vida > vidamax: vida = vidamax
	actualizar_salud()

func actualizar_salud():
	if barra_salud:
		barra_salud.actualizar_barra(vidamax, vida)
