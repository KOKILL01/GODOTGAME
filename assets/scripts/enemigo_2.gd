extends EnemyBase2

func _ready():
	$AnimatedSprite2D.play("default")
	super._ready()
	velocidad = 270
	tiempo_accion = 1
	vida_maxima = 150  # Vida de este enemigo
	vida_actual = vida_maxima
	if barra_vida:
		barra_vida.max_value = vida_maxima
		barra_vida.value = vida_actual


func _on_area_2d_area_entered(area: Area2D) -> void:
	print("Detecté un área en enemy2")
	if area.is_in_group("misil1"):
		print("misil1 pegao")
		recibir_dano(50)
		
	elif area.is_in_group("misil2"):
		print("misil 2 pegaoa")
		recibir_dano(100)
