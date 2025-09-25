extends CharacterBody2D

@export var velocidad: float = 500
var direccion: Vector2 = Vector2.ZERO

func _ready():
	# Auto-destrucción después de 5 segundos
	await get_tree().create_timer(5.0).timeout
	if is_inside_tree():
		queue_free()

func _physics_process(delta):
	if direccion != Vector2.ZERO:
		velocity = direccion * velocidad
		move_and_slide()

		# Verificar colisiones solo con el jugador
		for i in get_slide_collision_count():
			var collider = get_slide_collision(i).get_collider()
			if collider.is_in_group("jugador") or collider.is_in_group("mapaa"):
				print("¡Jugador golpeado!")
				queue_free()
