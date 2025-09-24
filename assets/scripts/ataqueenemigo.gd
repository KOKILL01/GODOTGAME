extends CharacterBody2D

@export var velocidad: float = 500
var direccion: Vector2 = Vector2.ZERO

func _ready():
	# Auto-destrucción después de 5 segundos
	await get_tree().create_timer(5.0).timeout
	queue_free()

func _physics_process(delta):
	# Solo moverse si hay dirección
	if direccion != Vector2.ZERO:
		velocity = direccion * velocidad
		move_and_slide()
		# Depuración
		print("Misil moviéndose hacia: ", direccion, " Posición actual: ", global_position)

	# Verificar colisiones
	if get_slide_collision_count() > 0:
		var collider = get_slide_collision(0).get_collider()
		if collider.is_in_group("jugador"):
			print("¡Jugador golpeado!")
			queue_free()

	# Salir si se va del viewport
	var viewport_rect = get_viewport().get_visible_rect().grow(100)
	if not viewport_rect.has_point(global_position):
		queue_free()
