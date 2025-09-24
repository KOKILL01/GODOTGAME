extends Node2D

var vidamax: int = 100
var vida: int = vidamax
var puntuacion: int = 0
var nivel_actual: int = 1

@export var barra_salud: ProgressBar  # Ahora sí puedes arrastrar un ProgressBar estándar

signal vida_cambiada(nueva_vida, vida_maxima)
var _vida: int = vidamax:
	set(value):
		_vida = clamp(value, 0, vidamax)
		emit_signal("vida_cambiada", _vida, vidamax)
		
func _ready():
	# Si no asignaste en el inspector, intenta buscarlo automáticamente
	emit_signal("vida_cambiada", _vida, vidamax)
	if not barra_salud:
		barra_salud = $ProgressBar  # Ajusta la ruta si tu ProgressBar está en otra parte
	actualizar_salud()

func restar_vida(cantidad: int):
	vida -= cantidad
	if vida < 0:
		vida = 0
	actualizar_salud()

func aumentar_vida(cantidad: int):
	vida += cantidad
	if vida > vidamax:
		vida = vidamax
	actualizar_salud()

func aumentar_puntuacion(cantidad: int):
	puntuacion += cantidad

func actualizar_salud():
	if barra_salud:
		barra_salud.max_value = vidamax
		barra_salud.value = vida
	else:
		print("Barra de salud no asignada")
