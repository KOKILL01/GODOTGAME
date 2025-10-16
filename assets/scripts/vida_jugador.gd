extends Node

var vidamax: int = 100
var vida: int = vidamax
var puntuacion: int = 0
var nivel_actual: int = 1

# Señal para notificar cambios de vida
signal vida_cambiada(nueva_vida, vida_maxima)

func _ready():
	# Inicializar con valores por defecto
	vida = vidamax

func restar_vida(cantidad: int):
	vida -= cantidad
	if vida < 0:
		vida = 0
	vida_cambiada.emit(vida, vidamax)

func aumentar_vida(cantidad: int):
	vida += cantidad
	if vida > vidamax:
		vida = vidamax
	vida_cambiada.emit(vida, vidamax)

func resetear_vida():
	vida = vidamax
	vida_cambiada.emit(vida, vidamax)

func aumentar_puntuacion(cantidad: int):
	puntuacion += cantidad
