extends CharacterBody2D
class_name EnemyBase

@export var velocidad: float = 100
@export var tiempo_accion: float = 1.0
@export var ataqueenemigo_escena: PackedScene
@export var vida_maxima: int = 100

var vida_actual: float
var barra_vida: ProgressBar
var jugador: Node2D
var tiempo_actual: float = 0
var estado: int = 0
var direccion: Vector2 = Vector2.ZERO

func _ready():
	vida_actual = vida_maxima
	
	# --- Configurar barra de vida ---
	if has_node("Control/ProgressBar"):
		barra_vida = $Control/ProgressBar
		barra_vida.max_value = vida_maxima
		barra_vida.value = vida_actual
	
	# --- Buscar jugador ---
	jugador = get_tree().get_first_node_in_group("jugador")
	if not jugador:
		print("Jugador no encontrado")

	# --- Conectar detección de colisión (ahora detecta cuerpos) ---
	if has_node("Area2D"):
		var area = $Area2D
		area.body_entered.connect(_on_area_2d_body_entered)

	elegir_accion()


func _process(delta):
	tiempo_actual -= delta
	
	# Animación suave de la barra de vida
	if barra_vida:
		barra_vida.value = lerp(barra_vida.value, vida_actual, 5 * delta)
	
	match estado:
		1: seguir_jugador()
		2: disparar()
		3: esquivar()
	
	if tiempo_actual <= 0:
		elegir_accion()


func recibir_dano(cantidad: int):
	vida_actual -= cantidad
	if vida_actual < 0:
		vida_actual = 0
	
	if vida_actual <= 0:
		morir()


func morir():
	queue_free()
	#print("💀 Enemigo eliminado")


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
		ataque.direccion = (jugador.global_position - global_position).normalized()
		get_parent().add_child(ataque)
		ataque.global_position = global_position
	
	tiempo_actual = 0


func esquivar():
	velocity = direccion * velocidad
	move_and_slide()


# --- Señal del Area2D (ahora para cuerpos, no áreas) ---
func _on_area_2d_body_entered(body: Node) -> void:
	if body.is_in_group("misil1"):
		print("💥 Enemigo golpeado por misil 1")
		recibir_dano(30)
	elif body.is_in_group("misil2"):
		print("💥 Enemigo golpeado por misil 2")
		recibir_dano(50)
