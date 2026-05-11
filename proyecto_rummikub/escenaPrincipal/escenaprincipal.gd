extends Node2D

var es_arcade: bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Fondo.modulate = globales.get_color_tablero()
	$Fondo.visible = true
	$PantallaPartidaPausada.visible = false
