extends Node2D

var letra: String
signal letra_presionada_correctamente(letra: String)

# Ruta a la carpeta donde tienes las imágenes de letras
const RUTA_IMAGENES_LETRAS = "res://letras/"

func _ready():
	letra = generar_letra_aleatoria()
	
	# Verificar que el nodo LetraSprite existe
	if has_node("LetraSprite"):
		# Cargar la imagen correspondiente a la letra
		var textura_letra = load(RUTA_IMAGENES_LETRAS + letra + ".png")
		if textura_letra:
			$LetraSprite.texture = textura_letra
		else:
			print("Error: No se encontró la imagen para la letra ", letra, " en la ruta: ", RUTA_IMAGENES_LETRAS + letra + ".png")
	else:
		print("Error: No se encontró el nodo LetraSprite en la escena")
		# Crear el nodo dinámicamente si no existe (solución alternativa)
		var sprite = Sprite2D.new()
		sprite.name = "LetraSprite"
		add_child(sprite)
		sprite.texture = load(RUTA_IMAGENES_LETRAS + letra + ".png")
	
	# Ajustar tamaño si es necesario
	$LetraSprite.scale = Vector2(1.5, 1.5)  # Ajusta este valor según necesites

func generar_letra_aleatoria() -> String:
	var letras = "AWSD"
	return letras[randi() % letras.length()]

func _input(event):
	if event is InputEventKey and event.pressed:
		var tecla = OS.get_keycode_string(event.keycode)
		if tecla == letra:
			letra_presionada_correctamente.emit(letra)
			queue_free()
