extends "res://assets/scripts/misilbase.gd"  # Asegúrate de que la ruta sea correcta

func _ready():
	# Redefinimos las variables para este misil
	velocidad = 400  # Más rápido que el misil base
	tiempo_vida = 2.0 # Dura menos tiempo
	animacion_misil = "default" # Nombre de la animación para este misil

	# Llama a la función _ready() del script padre para que se ejecute su lógica.
	super._ready()
