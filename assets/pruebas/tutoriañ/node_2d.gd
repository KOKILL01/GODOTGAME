extends Node2D

# --- Referencias de la escena ---
@onready var dialog_label: Label = $DialogLabel
@onready var timer: Timer = $Timer
@onready var arrow_label: Label = $DialogLabel/ArrowLabel

@onready var npc_tutorial: Node2D = $npcTutorial
@onready var personaje2: Node2D = $personaje2
@onready var camara: Camera2D = $personaje2/Camera2D

# --- Configuración del tutorial ---
var current_step: int = 0
var tutorial_steps: Array = [
	{"message": "Bien comencemos, presiona cualquier tecla para avanzar", "action": "pasar"},
	{"message": "Presiona WASD para moverte por la pantalla", "action": "check_movement"},
	{"message": "¡Bien! Ahora presiona 'E' o 'R' para lanzar un hechizo", "action": "hechizo"},
	{"message": "¡Bien hecho! Verás algunas letras - Presiona la letra que ves", "action": "misil_lanzado"},
	{"message": "¡Felicidades! Hay 2 tipos de ataques: débil y fuerte. Uno es más complicado de lanzar. Atento con eso", "action": "pasar"},
	{"message": "No se si lo notaste, pero tus ataques irán donde tengas el cursor.", "action": "pasar"},
	{"message": "Sabes lo suficiente para sobrevivir. Si no sabes, tu objetivo es derrotar a esos demonios traídos por 'DIOS'", "action": "pasar"},
	{"message": "Regresa y obligalo a volvernos la humanidad.", "action": "pasar"}
]

# --- Parámetros visuales ---
var float_offset := 0.0
var float_speed := 2.0
var float_amplitude := 5.0
var text_offset_y := -80

# --- Variables internas ---
var personaje: Node2D = null

func _ready():
	await get_tree().process_frame  # esperar un frame para cargar todo

	# Configurar cámara
	if camara:
		camara.zoom = Vector2(1, 1)

	# Buscar jugador por grupo
	personaje = get_tree().get_first_node_in_group("jugador")
	if personaje:
		conectar_senales()
		print("✅ Jugador encontrado y señales conectadas")
	else:
		push_warning("❌ No se encontró el jugador en el grupo 'jugador'")

	# Preparar flecha
	arrow_label.text = "→"
	arrow_label.visible = false

	# Configurar timer
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)

	# Iniciar tutorial
	show_tutorial_step(current_step)


func conectar_senales():
	if personaje:
		if personaje.has_signal("misil_lanzado") and not personaje.misil_lanzado.is_connected(misilLanzado):
			personaje.misil_lanzado.connect(misilLanzado)
		if personaje.has_signal("minijuego_activado") and not personaje.minijuego_activado.is_connected(minijuegoActivado):
			personaje.minijuego_activado.connect(minijuegoActivado)


func minijuegoActivado():
	if current_step < tutorial_steps.size():
		if tutorial_steps[current_step]["action"] == "check_minigame":
			print("🎮 Minijuego activado - avanzando tutorial")
			advance_tutorial()


func misilLanzado():
	if current_step < tutorial_steps.size():
		if tutorial_steps[current_step]["action"] == "misil_lanzado":
			print("🎯 Misil lanzado - avanzando tutorial")
			advance_tutorial()


func show_tutorial_step(step_index: int):
	if step_index >= tutorial_steps.size():
		dialog_label.text = "¡Tutorial completado!"
		await get_tree().create_timer(3.0).timeout
		get_tree().change_scene_to_file("res://assets/menus/menu.tscn")
		return

	var step = tutorial_steps[step_index]
	dialog_label.text = step["message"]
	print("📝 Mostrando paso del tutorial:", step["message"])

	# Mostrar flecha solo si el paso es "pasar"
	arrow_label.visible = step["action"] == "pasar"
	if arrow_label.visible:
		var text_width = dialog_label.get_minimum_size().x
		arrow_label.global_position = Vector2(dialog_label.global_position.x + text_width + 10, dialog_label.global_position.y)


func _input(event):
	if current_step >= tutorial_steps.size():
		return

	var current_action = tutorial_steps[current_step]["action"]

	# Paso especial: "pasar" → cualquier tecla
	if event is InputEventKey and event.pressed and current_action == "pasar":
		advance_tutorial()
		return

	match current_action:
		"check_movement":
			if Input.is_action_pressed("derecha") or Input.is_action_pressed("izquierda") or Input.is_action_pressed("arriba") or Input.is_action_pressed("abajo"):
				advance_tutorial()
		"hechizo":
			if Input.is_action_just_pressed("hechizo") or Input.is_action_just_pressed("hechizo2"):
				advance_tutorial()
		# Los pasos por señal se manejan aparte


func advance_tutorial():
	timer.start(0.5)


func _on_timer_timeout():
	current_step += 1
	show_tutorial_step(current_step)


func _process(delta):
	float_offset += float_speed * delta

	if current_step >= tutorial_steps.size():
		return

	# --- SIEMPRE mostrar el texto encima del NPC ---
	dialog_label.global_position.x = npc_tutorial.global_position.x - dialog_label.get_minimum_size().x / 2
	dialog_label.global_position.y = npc_tutorial.global_position.y + text_offset_y + sin(float_offset) * float_amplitude

	# --- Animación de la flecha ---
	if arrow_label.visible:
		var text_width = dialog_label.get_minimum_size().x
		arrow_label.global_position.x = dialog_label.global_position.x + text_width + 10
		arrow_label.global_position.y = dialog_label.global_position.y + sin(float_offset * 3) * 3
		arrow_label.modulate.a = 0.5 + 0.5 * sin(float_offset * 3)
