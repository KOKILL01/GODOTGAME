extends CharacterBody2D

signal misil_lanzado()
signal minijuego_desactivado()
signal minijuego_activado()
signal movimiento_realizado()

var pixeles_por_metro: float = 80
var direction: Vector2 = Vector2.ZERO
var rapidez: float = 5 * pixeles_por_metro

var esta_en_dano: bool = false
var movimiento_detectado: bool = false
var muerto: bool = false   # 👈 bandera para evitar acciones después de morir

@onready var barra_salud: ProgressBar = $ProgressBar
@onready var anim := $AnimatedSprite2D

const MinijuegoLetrasEscena = preload("res://assets/Escenas/main.tscn")
const MisilEscena_original = preload("res://assets/Escenas/misil.tscn")
const Misilblue = preload("res://assets/Escenas/misil_2.tscn")

var misiles_disponibles = {
	"hechizo": MisilEscena_original,
	"hechizo2": Misilblue,
}

var minijuego_activo: bool = false
var instancia_minijuego: Node = null
var misil_a_lanzar: PackedScene = null

func _ready():
	add_to_group("jugador")
	VidaJugador.vida_cambiada.connect(actualizar_salud)
	VidaJugador.jugador_muerto.connect(_on_jugador_muerto)  # 👈 conectar la señal de muerte

	actualizar_salud(VidaJugador.vida, VidaJugador.vidamax)

	if $Area2D:
		$Area2D.area_entered.connect(_on_area_entered)
	else:
		push_error("⚠️ No se encontró el nodo Area2D en el personaje.")

func _on_area_entered(area: Area2D):
	if muerto:
		return

	if area.is_in_group("enemigo1"):
		reproducir_dano()
		VidaJugador.restar_vida(10)
	elif area.is_in_group("enemigo2"):
		reproducir_dano()
		VidaJugador.restar_vida(10)
	elif area.is_in_group("misilEnemigo"):
		reproducir_dano()
		VidaJugador.restar_vida(20)

func reproducir_dano():
	if not esta_en_dano and not muerto:
		esta_en_dano = true
		anim.play("daño")
		anim.animation_finished.connect(_on_animacion_dano_terminada, CONNECT_ONE_SHOT)

func _on_animacion_dano_terminada():
	esta_en_dano = false

func _input(event):
	if muerto:
		return
	direccion()
	verificar_lanzamiento()
	cancelarAtaque()

func _physics_process(delta):
	if not minijuego_activo and not muerto:
		movimiento()

func direccion():
	if esta_en_dano or muerto:
		return
	direction = Vector2.ZERO

	if Input.is_action_pressed("derecha"):
		anim.play("correr2")
		anim.flip_h = false
		direction.x += 1
	if Input.is_action_pressed("izquierda"):
		anim.flip_h = true
		anim.play("correr2")
		direction.x -= 1
	if Input.is_action_pressed("arriba"):
		anim.play("correr2")
		direction.y -= 1
	if Input.is_action_pressed("abajo"):
		anim.play("correr2")
		direction.y += 1

	if direction == Vector2.ZERO:
		anim.play("idle")
	else:
		direction = direction.normalized()

func movimiento():
	velocity = direction * rapidez
	move_and_slide()

# --- Minijuego de hechizos ---
func verificar_lanzamiento():
	for nombre_accion in misiles_disponibles:
		if Input.is_action_just_pressed(nombre_accion) and not minijuego_activo:
			misil_a_lanzar = misiles_disponibles[nombre_accion]
			var cantidad_letras = 5
			if nombre_accion == "hechizo":
				cantidad_letras = 3
			elif nombre_accion == "hechizo2":
				cantidad_letras = 6
			activar_minijuego(cantidad_letras)

func cancelarAtaque():
	if Input.is_action_pressed("espacio"):
		desactivar_minijuego()
		minijuego_desactivado.emit()

func activar_minijuego(cantidad_letras: int):
	anim.play("atacar")
	anim.animation_finished.connect(_on_animacion_terminada)
	instancia_minijuego = MinijuegoLetrasEscena.instantiate()
	get_parent().add_child(instancia_minijuego)
	instancia_minijuego.max_letras = cantidad_letras
	instancia_minijuego.minijuego_terminado.connect(_on_minijuego_terminado)
	minijuego_activo = true
	set_process_input(false)
	minijuego_activado.emit()

func _on_animacion_terminada():
	if anim.animation == "atacar":
		anim.play("cargarAtaque")
	elif anim.animation == "cargarAtaque":
		instancia_minijuego.visible = true
		anim.animation_finished.disconnect(_on_animacion_terminada)

func _on_minijuego_terminado(puntuacion_final):
	var puntos_por_letra = 10
	var puntos_necesarios = instancia_minijuego.max_letras * puntos_por_letra
	if puntuacion_final >= puntos_necesarios:
		lanzar_misil()
	desactivar_minijuego()

func desactivar_minijuego():
	if instancia_minijuego:
		instancia_minijuego.queue_free()
		instancia_minijuego = null
	minijuego_activo = false
	set_process_input(true)
	minijuego_desactivado.emit()

func lanzar_misil():
	misil_lanzado.emit()
	if misil_a_lanzar:
		var nuevo_misil = misil_a_lanzar.instantiate()
		get_parent().add_child(nuevo_misil)
		if nuevo_misil.has_method("lanzar"):
			var mouse_pos = get_global_mouse_position()
			var direccion_misil = (mouse_pos - global_position).normalized()
			nuevo_misil.lanzar(global_position, direccion_misil)
		misil_a_lanzar = null

func actualizar_salud(vida_actual: int, vida_maxima: int):
	if barra_salud:
		barra_salud.actualizar_barra(vida_maxima, vida_actual)

# --- Cuando la vida llega a 0 ---
func _on_jugador_muerto():
	if muerto:
		return
	muerto = true
	set_process_input(false)
	set_physics_process(false)
	$Area2D.monitoring = false
	anim.play("cargarAtaque")
	await CambioEscena()
	


func CambioEscena() -> void:
	await get_tree().create_timer(3.0).timeout  # Espera 3 segundos
	get_tree().change_scene_to_file("res://assets/menus/menu.tscn")

func _on_animacion_muerte_terminada():
	get_tree().change_scene_to_file("res://assets/menus/menu.tscn")
