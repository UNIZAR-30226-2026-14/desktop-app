extends Control

func _ready() -> void:
	self.visible = false

func sacar_pantalla_victoria(imagen_ganador: Texture2D, nombre_ganador: String, puntos_ganados: int) -> void:
	$fondo/Panel/nombreGanador.text = nombre_ganador
	$fondo/Panel/iconoGanador.texture = imagen_ganador
	$fondo/dineroGanado.text = "+" + str(puntos_ganados) + "      "
	$self.visible = true

func boton_continua_pulsado() -> void:
	get_tree().change_scene_to_file("res://proyecto_rummikub/menuInicio/menuInicio.tscn")
