# misil.gd
extends CharacterBody2D

var velocidad = 700
var direccion: Vector2 = Vector2.ZERO
var tiempo_vida = 3.0

func _ready():
	# Programar autodestrucción después de tiempo_vida segundos
	$Timer.wait_time = tiempo_vida
	$Timer.start()

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
