extends EnemyBase2

func _ready():
	$AnimatedSprite2D.play("default")
	super._ready()
	velocidad = 270
	tiempo_accion = 1
	vida_maxima = 200  # Vida de este enemigo
	vida_actual = vida_maxima
	if barra_vida:
		barra_vida.max_value = vida_maxima
		barra_vida.value = vida_actual


func _on_area_2d_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
