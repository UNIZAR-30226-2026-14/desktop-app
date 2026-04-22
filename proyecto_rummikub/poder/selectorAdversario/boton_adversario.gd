class_name BotonAdversario extends Button
signal adversario_pulsado

const maxima_anchura_icono = 100
const tamano_letra = 40

var mi_nombre: String

func _init(nombre: String, icono: Texture2D) -> void:
	mi_nombre = nombre
	self.text = mi_nombre
	self.icon = icono


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.add_theme_stylebox_override("normal",load("res://proyecto_rummikub/poder/selectorAdversario/boton_adversario_normal.tres"))
	self.add_theme_stylebox_override("hover",load("res://proyecto_rummikub/poder/selectorAdversario/boton_adversario_hover.tres"))
	self.add_theme_stylebox_override("pressed",load("res://proyecto_rummikub/poder/selectorAdversario/boton_adversario_pressed.tres"))
	
	self.add_theme_font_size_override("font_size",tamano_letra) 
	self.add_theme_constant_override("icon_max_width", maxima_anchura_icono)
	
	self.pressed.connect(_adversario_pulsado)

func _adversario_pulsado() -> void:
	adversario_pulsado.emit(mi_nombre)
