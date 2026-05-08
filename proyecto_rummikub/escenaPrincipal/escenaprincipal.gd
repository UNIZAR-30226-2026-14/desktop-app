extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Fondo.modulate = globales.skin_tablero_equipada
	$Fondo.visible = true
	$PantallaPartidaPausada.visible = false
	PopUp.popUp("viva el vino", Vector2(-74.0, -300.0), self)

func completarJugada() -> void:
	pass
#	if $managerFichas/tablero.
