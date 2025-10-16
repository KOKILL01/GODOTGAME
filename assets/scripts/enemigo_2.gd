extends EnemyBase

func _ready():
	$AnimatedSprite2D.play("default")
	super._ready()  # Llama a la lógica base de EnemyBase

	# Ajustes específicos para este enemigo
	velocidad = 200           # más rápido que el EnemyBase
	tiempo_accion = 3.0       # cambia tiempo de acción
	vida_maxima = 150         # más vida
	vida_actual = vida_maxima # actualizar vida actual

	# Actualizar la barra de vida si existe
	if barra_vida:
		barra_vida.max_value = vida_maxima
		barra_vida.value = vida_actual
