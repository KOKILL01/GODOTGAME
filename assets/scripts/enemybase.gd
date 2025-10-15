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
	
	$Area2D.monitoring = true
	$Area2D.connect("body_entered", Callable(self, "_on_area_2d_body_entered"))

	vida_actual = vida_maxima
	
	# Buscar ProgressBar
	if has_node("Control/ProgressBar"):
		barra_vida = $Control/ProgressBar
		barra_vida.max_value = vida_maxima
		barra_vida.value = vida_actual
		print("✅ Barra encontrada")
	else:
		print("❌ No se encontró la barra de vida")
	
	# Buscar jugador
	jugador = get_tree().get_first_node_in_group("jugador")
	if not jugador:
		print("❌ Jugador no encontrado")
	
	# Conectar señal Area2D por código
	if has_node("Area2D"):
		$Area2D.body_entered.connect(_on_area_2d_body_entered)
		print("✅ Señal Area2D conectada")
	else:
		print("❌ No se encontró Area2D")
	
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
	#print("Vida actual:", vida_actual)
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
		var dir = (jugador.global_position - global_position).normalized()
		ataque.direccion = dir
		ataque.global_position = global_position + dir * 20
		get_tree().current_scene.add_child(ataque)
		print("💥 Misil disparado hacia: ", ataque.direccion)
	tiempo_actual = 0

func esquivar():
	velocity = direccion * velocidad
	move_and_slide()

# --- Señal del Area2D ---
func _on_area_2d_body_entered(body):
	#print("💥 Area2D detectó:", body.name, "Grupos:", body.get_groups())

	#print("🔹 Se detectó colisión con:", body.name, "Grupos:", body.get_groups())
	if body.is_in_group("jugador"):
		print("⚔️ Golpe al enemigo")
		recibir_dano(50)
