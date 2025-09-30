extends AudioStreamPlayer

# Lista de canciones
var songs: Array[AudioStream] = [
	preload("res://assets/music y sonidos/A Prophecy-Asking Alexandria.mp3"),
	preload("res://assets/music y sonidos/Avenged Sevenfold - Afterlife [Official Music Video].mp3"),
	preload("res://assets/music y sonidos/Bullet For My Valentine - The End.mp3"),
]

func _ready():
	randomize()  # Inicializa el generador aleatorio
	play_random_song()

	# Conectar la señal 'finished' para saber cuando termina
	self.finished.connect(_on_song_finished)

func play_random_song():
	stream = songs[randi() % songs.size()]
	play()

func _on_song_finished():
	play_random_song()
