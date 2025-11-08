extends "res://assets/scripts/misilbase.gd"

func _ready():
	# Configuración específica del misil
	velocidad = 500
	tiempo_vida = 2.0
	animacion_misil = "default"

	# Conectar body_entered en su propio Area2D
	if has_node("Area2D"):
		$Area2D.body_entered.connect(_on_body_entered)

	# Llamar al _ready() del padre
	super._ready()

# Función para detectar colisiones con cuerpos físicos
func _on_body_entered(body):
	if body.is_in_group("enemigo1") or body.is_in_group("mapa"):
		queue_free()
	elif body.is_in_group("jugador"):
		return
