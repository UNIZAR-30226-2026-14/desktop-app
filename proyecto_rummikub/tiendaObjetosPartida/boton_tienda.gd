class_name BotonTienda extends Button

signal boton_tienda_pulsado

var poder: globales.PODER

var estilo_sin_fondo: StyleBoxFlat = preload("res://proyecto_rummikub/tiendaObjetosPartida/boton_sin_fondo.tres")
var estilo_hover: StyleBoxFlat = preload("res://proyecto_rummikub/tiendaObjetosPartida/boton_hover_redondito.tres")
var estilo_resaltado: StyleBoxFlat = preload("res://proyecto_rummikub/tiendaObjetosPartida/boton_pulsado.tres")
var estilo_resaltado_hover: StyleBoxFlat = preload("res://proyecto_rummikub/tiendaObjetosPartida/boton_pulsado_hover.tres")


func _init(poder_in: globales.PODER, icono: Texture2D) -> void:
	poder = poder_in
	self.pressed.connect(_boton_pulsado)
	self.icon = icono
	self.add_theme_stylebox_override("normal", estilo_sin_fondo)
	self.add_theme_stylebox_override("pressed", estilo_sin_fondo)
	self.add_theme_stylebox_override("hover", estilo_hover)

func _boton_pulsado() -> void:
	boton_tienda_pulsado.emit(poder)
	self.add_theme_stylebox_override("normal", estilo_resaltado)
	self.add_theme_stylebox_override("hover", estilo_resaltado_hover)

func despulsar() -> void:
	self.add_theme_stylebox_override("normal", estilo_sin_fondo)
	self.add_theme_stylebox_override("hover", estilo_hover)
