extends CharacterBody2D

# Variables comunes para todos los misiles
var velocidad: float = 700
var direccion: Vector2 = Vector2.ZERO
var tiempo_vida: float = 3.0

@export var animacion_misil: String = "default"

func _ready():
	# Configurar Timer
	if has_node("Timer"):
		$Timer.wait_time = tiempo_vida
		$Timer.start()
	else:
		var new_timer = Timer.new()
		new_timer.name = "Timer"
		add_child(new_timer)
		new_timer.wait_time = tiempo_vida
		new_timer.timeout.connect(_on_timer_timeout)
		new_timer.start()
	
	# Animación
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play(animacion_misil)

func lanzar(pos: Vector2, dir: Vector2):
	global_position = pos
	direccion = dir
	rotation = atan2(dir.y, dir.x)

func _physics_process(delta):
	if direccion != Vector2.ZERO:
		velocity = direccion * velocidad
		move_and_slide()

		# Verificar colisiones
		for i in get_slide_collision_count():
			var collider = get_slide_collision(i).get_collider()

			if collider.is_in_group("enemigo1"):
				# Destruir si choca con enemigos
				queue_free()
			
			elif collider.is_in_group("enemigo2"):
				# Destruir si choca con enemigos
				queue_free()
				
			elif collider.is_in_group("boss"):
				# Destruir si choca con enemigos
				queue_free()

			elif collider.is_in_group("mapa"):
				# Destruir si choca con el mapa
				queue_free()

			elif collider.is_in_group("jugador"):
				# Evita que el misil del jugador explote contra sí mismo
				continue

func _on_timer_timeout():
	queue_free()
