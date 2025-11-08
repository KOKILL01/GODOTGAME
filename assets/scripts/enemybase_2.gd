extends CharacterBody2D
class_name EnemyBase2

@export var velocidad: float = 100
@export var tiempo_accion: float = 2.0
@export var ataqueenemigo_escena: PackedScene
@export var vida_maxima: int = 100

# Configuración del disparo
@export var angulo_abanico: float = 20.0    # grados de separación lateral
@export var intervalo_disparo: float = 2.0   # segundos entre ráfagas

var vida_actual: float
var barra_vida: ProgressBar
var jugador: Node2D
var tiempo_actual: float = 0
var tiempo_disparo: float = 0
var estado: int = 0
var direccion: Vector2 = Vector2.ZERO

func _ready():
	vida_actual = vida_maxima
	
	if has_node("Control/ProgressBar"):
		barra_vida = $Control/ProgressBar
		barra_vida.max_value = vida_maxima
		barra_vida.value = vida_actual
	
	jugador = get_tree().get_first_node_in_group("jugador")
	if jugador:
		print("🎯 Jugador detectado:", jugador.name)
	else:
		print("⚠️ Jugador no encontrado")
	
	# Conectar detección de impactos si existe un Area2D
	var area = get_node_or_null("Area2D")
	if area and not area.is_connected("body_entered", Callable(self, "_on_area_2d_body_entered")):
		area.connect("body_entered", Callable(self, "_on_area_2d_body_entered"))
		print("🟢 Area2D conectada en", name)
	else:
		print("🔴 No se encontró Area2D en", name)
	
	elegir_accion()

func _process(delta):
	tiempo_actual -= delta
	
	if barra_vida:
		barra_vida.value = lerp(barra_vida.value, vida_actual, 5 * delta)
	
	match estado:
		1:
			seguir_jugador()
		2:
			disparar(delta)
		3:
			esquivar()
	
	if tiempo_actual <= 0:
		elegir_accion()

func recibir_dano(cantidad: int):
	vida_actual -= cantidad
	if vida_actual <= 0:
		morir()

func morir():
	print("💀 Enemigo2 eliminado:", name)
	queue_free()

func elegir_accion():
	# Alternar entre seguir o disparar
	estado = randi_range(1, 2)  # 1 = seguir, 2 = disparar
	tiempo_actual = tiempo_accion
	print("🧠 Nueva acción: ", "seguir" if estado == 1 else "disparar")
	if estado == 3:
		direccion = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()

func seguir_jugador():
	if jugador:
		var dir = (jugador.global_position - global_position).normalized()
		velocity = dir * velocidad
		move_and_slide()

func disparar(delta):
	if not jugador or not ataqueenemigo_escena:
		return
	
	tiempo_disparo -= delta
	if tiempo_disparo <= 0:
		tiempo_disparo = intervalo_disparo
		
		print("💥 EnemyBase2 dispara en abanico (", name, ")")

		var dir_central = (jugador.global_position - global_position).normalized()
		var rad = deg_to_rad(angulo_abanico)
		var dir_izquierda = dir_central.rotated(-rad)
		var dir_derecha = dir_central.rotated(rad)
		
		_disparar_misil(dir_central)
		_disparar_misil(dir_izquierda)
		_disparar_misil(dir_derecha)

func _disparar_misil(direccion_misil: Vector2):
	if not ataqueenemigo_escena:
		print("⚠️ No hay escena asignada para el misil enemigo")
		return

	var misil = ataqueenemigo_escena.instantiate()
	get_parent().add_child(misil)
	misil.global_position = global_position

	# Si el misil tiene la variable 'direccion', la establecemos
	if "direccion" in misil:
		misil.direccion = direccion_misil.normalized()
	else:
		print("⚠️ El misil enemigo no tiene la variable 'direccion'")

	print("🚀 Misil lanzado en dirección:", direccion_misil)

func esquivar():
	velocity = direccion * velocidad
	move_and_slide()

# Detección de impacto con misiles del jugador
func _on_area_2d_body_entered(body: Node) -> void:
	if body.is_in_group("misil1"):
		print("💥 Enemigo2 golpeado por misil 1")
		recibir_dano(100)
	elif body.is_in_group("misil2"):
		print("💥 Enemigo2 golpeado por misil 2")
		recibir_dano(100)
