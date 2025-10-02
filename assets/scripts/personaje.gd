extends CharacterBody2D

var pixeles_por_metro: float = 80
var direction: Vector2 = Vector2.ZERO
var rapidez: float = 5 * pixeles_por_metro

# Variables de Vida
var vidamax: int = 100
var vida: int = vidamax

var esta_en_dano: bool = false


# Referencia a la barra de salud.
# @onready asegura que el nodo exista antes de que se use en el _ready.
@onready var barra_salud: ProgressBar = $ProgressBar
const MinijuegoLetrasEscena = preload("res://assets/Escenas/main.tscn")

# Precarga todas las escenas de misil que vayas a usar.
const MisilEscena_original = preload("res://assets/Escenas/misil.tscn")
const Misilblue = preload("res://assets/Escenas/misil_2.tscn")# Asegúrate de que esta ruta sea correcta

# Diccionario para mapear las acciones de entrada con las escenas de misil.
var misiles_disponibles = {
	"hechizo": MisilEscena_original,
	"hechizo2": Misilblue,
}

var minijuego_activo: bool = false
var instancia_minijuego: Node = null

# Variable para guardar qué misil se va a lanzar después del minijuego.
var misil_a_lanzar: PackedScene = null

func _ready():
	add_to_group("jugador")
	print("Vida inicial del jugador:", vida)
	
	# Conecta la señal area_entered del Area2D a la función _on_area_entered
	$Area2D.area_entered.connect(_on_area_entered)
	
	# Inicializa la barra de salud al comienzo de la escena
	actualizar_salud()

func _on_area_entered(area: Area2D):
	if area.is_in_group("enemigo1"):
		reproducir_dano()
		restar_vida(10)
		print("¡Chocaste con un enemigo! Vida actual:", vida)
	
	elif area.is_in_group("misilEnemigo"):
		reproducir_dano()
		restar_vida(20)
		print("¡Chocó un misil! Vida actual:", vida)

func reproducir_dano():
	if not esta_en_dano:  # Evita reiniciar la animación si ya está corriendo
		esta_en_dano = true
		$AnimatedSprite2D.play("daño")
		$AnimatedSprite2D.animation_finished.connect(_on_animacion_dano_terminada, CONNECT_ONE_SHOT)

func _on_animacion_dano_terminada():
	if $AnimatedSprite2D.animation == "daño":
		esta_en_dano = false


func _input(event):
	direccion()
	verificar_lanzamiento() # Llama a la nueva función centralizada
	cancelarAtaque()

func _physics_process(delta):
	if not minijuego_activo:
		movimiento()

# --- NUEVA FUNCIÓN PARA GESTIONAR EL LANZAMIENTO ---
func verificar_lanzamiento():
	# Recorre el diccionario de misiles
	for nombre_accion in misiles_disponibles:
		# Si se presiona el botón asociado y no hay un minijuego activo
		if Input.is_action_just_pressed(nombre_accion) and not minijuego_activo:
			# Guarda la escena del misil que se lanzará
			misil_a_lanzar = misiles_disponibles[nombre_accion]
			# Activa el minijuego, la lógica es la misma para todos
			activar_minijuego()
			return # Sal del bucle para no procesar otros botones

func cancelarAtaque():
	if Input.is_action_pressed("espacio"):
		desactivar_minijuego()

func direccion():
	if esta_en_dano:
		return  # No permitir cambiar animación ni dirección

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

func activar_minijuego():
	$AnimatedSprite2D.play("atacar")
	$AnimatedSprite2D.animation_finished.connect(_on_animacion_terminada)

	instancia_minijuego = MinijuegoLetrasEscena.instantiate()
	get_parent().add_child(instancia_minijuego)
	instancia_minijuego.minijuego_terminado.connect(_on_minijuego_terminado)
	minijuego_activo = true
	set_process_input(false)
	print("Minijuego de letras activado")
	
func _on_animacion_terminada():
	if $AnimatedSprite2D.animation == "atacar":
		# Ahora reproducimos la segunda animación
		$AnimatedSprite2D.play("cargarAtaque")

	elif $AnimatedSprite2D.animation == "cargarAtaque":
		# Cuando termine la segunda, mostramos el minijuego
		instancia_minijuego.visible = true
		# Desconectamos la señal para no repetir
		$AnimatedSprite2D.animation_finished.disconnect(_on_animacion_terminada)

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

# --- FUNCIÓN DE LANZAMIENTO GENÉRICO ---
func lanzar_misil():
	# Si la variable tiene una escena, la instanciamos
	if misil_a_lanzar:
		var nuevo_misil = misil_a_lanzar.instantiate()
		get_parent().add_child(nuevo_misil)
		
		# DEBUG: Verificar el tipo y métodos del nodo
		print("Tipo del misil instanciado: ", nuevo_misil.get_class())
		print("¿Tiene método lanzar? ", nuevo_misil.has_method("lanzar"))
		
		if nuevo_misil.has_method("lanzar"):
			var mouse_pos = get_global_mouse_position()
			var direccion_misil = (mouse_pos - global_position).normalized()
			nuevo_misil.lanzar(global_position, direccion_misil)
			print("¡Misil lanzado!")
		else:
			print("ERROR: El misil no tiene método 'lanzar'")
			# Debug adicional
			print("Métodos disponibles: ")
			for method in nuevo_misil.get_method_list():
				print(" - ", method.name)
		
		# Limpiamos la variable para el próximo uso
		misil_a_lanzar = null
	
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
