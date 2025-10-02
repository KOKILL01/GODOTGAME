
extends EnemyBase

func _ready():
	$AnimatedSprite2D.play("default")
	super._ready()
	velocidad=170
	tiempo_accion=2.5
