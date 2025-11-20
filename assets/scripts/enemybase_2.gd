extends CharacterBody2D
class_name EnemyBase2

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
	
	# Configurar barra de vida
	if has_node("Control/ProgressBar"):
		barra_vida = $Control/ProgressBar
		barra_vida.max_value = vida_maxima
		barra_vida.value = vida_actual
	
	# Buscar jugador
	jugador = get_tree().get_first_node_in_group("jugador")
	if not jugador:
		print("Jugador no encontrado")

	# Forzar conectar Area2D (aunque la escena esté mal configurada)
	if has_node("Area2D"):
		var area = $Area2D
		if not area.body_entered.is_connected(_on_area_2d_body_entered):
			area.body_entered.connect(_on_area_2d_body_entered)
	else:
		print("ERROR: EnemyBase2 no tiene Area2D")

	elegir_accion()


func _process(delta):
	tiempo_actual -= delta
	
	# Animación suave barra vida
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


# ---------------------------------------------------------
#  ATAQUE EN ABANICO (3 MISILES)
# ---------------------------------------------------------
func disparar():
	if jugador and ataqueenemigo_escena:
		var dir_base = (jugador.global_position - global_position).normalized()

		var angulos = [
			0,
			deg_to_rad(-15),
			deg_to_rad(15)
		]

		for ang in angulos:
			var ataque = ataqueenemigo_escena.instantiate()
			ataque.direccion = dir_base.rotated(ang)
			get_parent().add_child(ataque)
			ataque.global_position = global_position

	tiempo_actual = 0


func esquivar():
	velocity = direccion * velocidad
	move_and_slide()


# ---------------------------------------------------------
#   DETECCIÓN DE MISILES (idéntica a EnemyBase1)
# ---------------------------------------------------------
func _on_area_2d_body_entered(body: Node) -> void:
	if not body:
		return

	if body.is_in_group("misil1"):
		print("💥 EnemyBase2 golpeado por misil 1")

	elif body.is_in_group("misil2"):
		print("💥 EnemyBase2 golpeado por misil 2")
