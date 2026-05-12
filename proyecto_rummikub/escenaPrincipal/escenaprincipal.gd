extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Fondo.modulate = globales.skin_tablero_equipada
	$Fondo.visible = true
	$PantallaPartidaPausada.visible = false
	

func completarJugada() -> void:
	pass
