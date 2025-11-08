extends EnemyBase

func _ready():
	$AnimatedSprite2D.play("default")
	super._ready()
	velocidad = 170
	tiempo_accion = 2.5
	vida_maxima = 100  # Vida de este enemigo
	vida_actual = vida_maxima
	if barra_vida:
		barra_vida.max_value = vida_maxima
		barra_vida.value = vida_actual


func _on_area_2d_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
