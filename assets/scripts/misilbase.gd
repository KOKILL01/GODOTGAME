# misilbase.gd
extends CharacterBody2D

# Variables comunes para todos los misiles
var velocidad: float = 700
var direccion: Vector2 = Vector2.ZERO
var tiempo_vida: float = 3.0

# Variable para el nombre de la animación
@export var animacion_misil: String = "default"

func _ready():
	# Verificar que el Timer existe antes de usarlo
	if has_node("Timer"):
		$Timer.wait_time = tiempo_vida
		$Timer.start()
	else:
		print("ERROR: No se encontró el nodo Timer en ", name)
		# Crear un Timer dinámicamente como fallback
		var new_timer = Timer.new()
		new_timer.name = "Timer"
		add_child(new_timer)
		new_timer.wait_time = tiempo_vida
		new_timer.timeout.connect(_on_timer_timeout)
		new_timer.start()
	
	# Reproduce la animación
	if $AnimatedSprite2D:
		$AnimatedSprite2D.play(animacion_misil)

func lanzar(pos: Vector2, dir: Vector2):
	global_position = pos
	direccion = dir
	
	# Rotar el misil para que mire en la dirección de lanzamiento
	rotation = atan2(dir.y, dir.x)

func _physics_process(delta):
	if direccion != Vector2.ZERO:
		velocity = direccion * velocidad
		move_and_slide()

func _on_timer_timeout():
	queue_free()
