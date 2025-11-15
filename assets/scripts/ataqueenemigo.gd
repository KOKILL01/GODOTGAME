extends CharacterBody2D

@export var velocidad: float = 500
var direccion: Vector2 = Vector2.ZERO

func _ready():
	$AnimatedSprite2D.play("default")

	# Destruir el proyectil después de 5 segundos
	await get_tree().create_timer(5.0).timeout
	if is_inside_tree():
		queue_free()

func _physics_process(delta):
	if direccion != Vector2.ZERO:
		# Normaliza la dirección y aplica la velocidad
		velocity = direccion.normalized() * velocidad
		move_and_slide()

		# 🔄 Rotar el sprite hacia la dirección del disparo
		# Si tu sprite está dibujado mirando hacia la derecha, deja esta línea así
		rotation = direccion.angle()
		
		# Si está dibujado mirando hacia arriba, usa esto en su lugar:
		# rotation = direccion.angle() + deg_to_rad(90)

		# Animación de vuelo
		$AnimatedSprite2D.play("default")

		# Colisiones
		for i in range(get_slide_collision_count()):
			var collider = get_slide_collision(i).get_collider()

			if collider.is_in_group("jugador"):
				queue_free()
			elif collider.is_in_group("mapa"):
				queue_free()
			elif collider.is_in_group("enemigo1") or collider.is_in_group("enemigo2"):
				continue
