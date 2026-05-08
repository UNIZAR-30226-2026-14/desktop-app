extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Fondo.modulate = globales.colores[globales.skin_tablero_equipada]


func completarJugada() -> void:
	pass
#	if $managerFichas/tablero.
