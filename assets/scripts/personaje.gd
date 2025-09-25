extends CharacterBody2D

var pixeles_por_metro: float = 80
var direction: Vector2 = Vector2.ZERO
var rapidez: float = 5 * pixeles_por_metro

# Variables de Vida
var vidamax: int = 100
var vida: int = vidamax

# Referencia a la barra de salud.
# @onready asegura que el nodo exista antes de que se use en el _ready.
@onready var barra_salud: ProgressBar = $ProgressBar

const MinijuegoLetrasEscena = preload("res://assets/Escenas/main.tscn")
const MisilEscena = preload("res://assets/Escenas/misil.tscn")

var minijuego_activo: bool = false
var instancia_minijuego: Node = null

func _ready():
	add_to_group("jugador")
	print("Vida inicial del jugador:", vida)
	# Conecta la señal body_entered del Area2D a la función _on_body_entered
	$Area2D.body_entered.connect(_on_body_entered)
	# Inicializa la barra de salud al comienzo de la escena
	actualizar_salud()

func _on_body_entered(body):
	if body.is_in_group("enemigo1"):
		restar_vida(10) # Llama a la nueva función
		print("¡Chocaste con un enemigo! Vida actual:", vida)
	if body.is_in_group("misilEnemigo"):
		restar_vida(20)
		print("Choco el misil",vida)

func _input(event):
	direccion()
	lanzarHechizo()

func _physics_process(delta):
	if not minijuego_activo:
		movimiento()

func direccion():
	direction = Vector2.ZERO
	
	if Input.is_action_pressed("derecha"):
		$AnimatedSprite2D.play("correr")
		$AnimatedSprite2D.flip_h = false
		direction.x += 1
		
	if Input.is_action_pressed("izquierda"):
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play("correr")
		direction.x -= 1
		
	if Input.is_action_pressed("arriba"):
		direction.y -= 1
		$AnimatedSprite2D.play("correr")
		
	if Input.is_action_pressed("abajo"):
		direction.y += 1
		$AnimatedSprite2D.play("correr")
		
	if direction == Vector2.ZERO:
		$AnimatedSprite2D.stop()
		
	if direction.length() > 0:
		direction = direction.normalized()

func movimiento():
	velocity = direction * rapidez
	move_and_slide()

func lanzarHechizo():
	if Input.is_action_just_pressed("hechizo") and not minijuego_activo:
		activar_minijuego()

func activar_minijuego():
	instancia_minijuego = MinijuegoLetrasEscena.instantiate()
	get_parent().add_child(instancia_minijuego)
	instancia_minijuego.minijuego_terminado.connect(_on_minijuego_terminado)
	minijuego_activo = true
	set_process_input(false)
	print("Minijuego de letras activado")

func _on_minijuego_terminado(puntuacion_final):
	print("Minijuego terminado con puntuación:", puntuacion_final)
	if puntuacion_final == 50:
		lanzar_misil()
	desactivar_minijuego()

func desactivar_minijuego():
	if instancia_minijuego:
		instancia_minijuego.queue_free()
		instancia_minijuego = null
	minijuego_activo = false
	set_process_input(true)
	print("Minijuego de letras desactivado - Personaje puede moverse nuevamente")

func lanzar_misil():
	var nuevo_misil = MisilEscena.instantiate()
	get_parent().add_child(nuevo_misil)
	var mouse_pos = get_global_mouse_position()
	var direccion_misil = (mouse_pos - global_position).normalized()
	nuevo_misil.lanzar(global_position, direccion_misil)
	print("¡Misil lanzado!")
	
# --- Nuevas funciones para gestionar la vida ---

func restar_vida(cantidad: int):
	vida -= cantidad
	if vida < 0:
		vida = 0
	actualizar_salud()

func aumentar_vida(cantidad: int):
	vida += cantidad
	if vida > vidamax:
		vida = vidamax
	actualizar_salud()

func actualizar_salud():
	if barra_salud:
		barra_salud.actualizar_barra(vidamax, vida)
