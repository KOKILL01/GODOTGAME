extends ProgressBar

@export var vidamax: int = 100
var vida: int

func _ready():
	vida = vidamax
	max_value = vidamax
	value = vida
	#print("✅ Vida inicial:", vida)

func restar_vida(cantidad: int):
	vida -= cantidad
	if vida <= 0:
		vida = 0
		morir()
	actualizar_barra()

func actualizar_barra():
	value = vida
	print("❤️ Vida actual:", vida)

func morir():
	#print("💀 Enemigo muerto")
	get_parent().get_parent().queue_free()  # Elimina todo el enemigo
