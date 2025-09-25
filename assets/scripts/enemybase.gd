extends CharacterBody2D
class_name EnemyBase

@export var velocidad: float = 100
@export var tiempo_accion: float = 1.0
@export var ataqueenemigo_escena: PackedScene

var jugador: Node2D
var tiempo_actual: float = 0
var estado: int = 0
var direccion: Vector2 = Vector2.ZERO

func _ready():
	jugador = get_tree().get_first_node_in_group("jugador")
	if not jugador:
		print("Jugador no encontrado")
	elegir_accion()

func _process(delta):
	tiempo_actual -= delta
	match estado:
		1: seguir_jugador()
		2: disparar()
		3: esquivar()
	if tiempo_actual <= 0:
		elegir_accion()

func elegir_accion():
	estado = randi_range(1,3)
	tiempo_actual = tiempo_accion
	if estado == 3:
		direccion = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()

func seguir_jugador():
	if jugador:
		var dir = (jugador.global_position - global_position).normalized()
		velocity = dir * velocidad
		move_and_slide()

func disparar():
	if jugador and ataqueenemigo_escena:
		var ataque = ataqueenemigo_escena.instantiate()
		
		# --- CORRECCIÓN: asignar dirección y posición con pequeño offset ---
		var dir = (jugador.global_position - global_position).normalized()
		ataque.direccion = dir
		ataque.global_position = global_position + dir * 20  # evita colisión inicial con el enemigo
		
		get_tree().current_scene.add_child(ataque)
		print("Misil disparado hacia: ", ataque.direccion)
	
	tiempo_actual = 0

func esquivar():
	velocity = direccion * velocidad
	move_and_slide()
