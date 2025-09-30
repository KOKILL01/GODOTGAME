extends Node2D

func _ready():
	if not music.get_node("AudioStreamPlayer").playing:
		music.get_node("AudioStreamPlayer").play()  # acceder al hijo
