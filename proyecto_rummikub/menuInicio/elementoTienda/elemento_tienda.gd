class_name ElementoTienda extends Control

signal interaccion_con_skin

static var escena_elemento_tienda: PackedScene = preload("res://proyecto_rummikub/menuInicio/elementoTienda/elementoTienda.tscn")

@export var icono_skin: Panel
@export var descripcion_skin: RichTextLabel
@export var boton_comprar: Button 
@export var fondo: Panel

enum TIPO_SKIN {FICHA, TABLERO}

const LISTA_BUTTON_GROUPS: Dictionary[TIPO_SKIN, ButtonGroup] = {
	TIPO_SKIN.FICHA: preload("res://proyecto_rummikub/menuInicio/elementoTienda/button_group_tienda_ficha.tres"),
	TIPO_SKIN.TABLERO: preload("res://proyecto_rummikub/menuInicio/elementoTienda/button_group_tienda_tablero.tres")
}

const EQUIPADO: String = "Equipado"
const DESEQUIPADO:  String = "Equipar"

const fondo_desequipado: StyleBoxFlat = preload("res://proyecto_rummikub/menuInicio/elementoTienda/style_box_comprable_desequipado.tres")
const fondo_equipado:    StyleBoxFlat = preload("res://proyecto_rummikub/menuInicio/elementoTienda/style_box_comprable_equipado.tres")

const boton_desequipado:       StyleBoxFlat = preload("res://proyecto_rummikub/menuInicio/elementoTienda/style_box_flat_boton_desequipado.tres")
const boton_equipado:          StyleBoxFlat = preload("res://proyecto_rummikub/menuInicio/elementoTienda/style_box_flat_boton_equipado.tres")
const boton_hover_desequipado: StyleBoxFlat = preload("res://proyecto_rummikub/menuInicio/elementoTienda/style_box_flat_boton_hover_desequipado.tres")

const color_letra_equipado: String = "15f535"
const color_letra_desequipado: String = "ffffff"
var mi_skin

const ALTURA: float = 133.0
static func ElementoTienda (icono, precio: String, descripcion: String, tipo: TIPO_SKIN) -> ElementoTienda:
	
	var nuevo_elemento_tienda: ElementoTienda = escena_elemento_tienda.instantiate()
	
	nuevo_elemento_tienda.mi_skin = icono
	nuevo_elemento_tienda.boton_comprar.text = str(precio)
	nuevo_elemento_tienda.descripcion_skin.text = descripcion
	
	match tipo:
		TIPO_SKIN.FICHA:
			var icono_aux: StyleBoxTexture = nuevo_elemento_tienda.icono_skin.get_theme_stylebox("panel").duplicate()
			var ratio: float = icono.get_size().x /  icono.get_size().y 
			icono_aux.texture = icono
			nuevo_elemento_tienda.icono_skin.add_theme_stylebox_override("panel",icono_aux)
			nuevo_elemento_tienda.icono_skin.size.x = ratio * ALTURA
		TIPO_SKIN.TABLERO:
			nuevo_elemento_tienda.icono_skin.modulate = icono
	nuevo_elemento_tienda.boton_comprar.button_group = LISTA_BUTTON_GROUPS[tipo]
	
	return nuevo_elemento_tienda

func _ready() -> void:
	$Fondo/BotonComprar.toggled.connect(_ineteraccion_con_skin)

## Devuelve -1 si ya ha sido comprado y -2 si esta equipado
func get_precio() -> int:
	if boton_comprar.text == DESEQUIPADO:
		return -1
	elif boton_comprar.text == EQUIPADO:
		return -2
	else:
		return int(boton_comprar.text)

func set_precio(precio: String):
	boton_comprar.text = precio
	if precio == EQUIPADO:
		fondo.add_theme_stylebox_override("panel",fondo_equipado)
		boton_comprar.add_theme_stylebox_override("hover",boton_equipado)
		boton_comprar.add_theme_stylebox_override("pressed",boton_equipado)
		boton_comprar.add_theme_color_override("font_pressed_color", color_letra_equipado)
		boton_comprar.add_theme_color_override("font_hover_pressed_color", color_letra_equipado)
	
	if precio == DESEQUIPADO:
		fondo.add_theme_stylebox_override("panel",fondo_desequipado)
		boton_comprar.add_theme_stylebox_override("hover",boton_hover_desequipado)
		boton_comprar.add_theme_stylebox_override("pressed",boton_desequipado)
		boton_comprar.add_theme_color_override("font_pressed_color", color_letra_desequipado)
		boton_comprar.add_theme_color_override("font_hover_pressed_color", color_letra_desequipado)

func get_skin():
	return mi_skin

func equipar() -> void:
	self.icono_skin.add_theme_stylebox_override("panel",fondo_equipado)

func desequipar() -> void:
	self.icono_skin.add_theme_stylebox_override("panel",fondo_desequipado)

func _ineteraccion_con_skin(toggled : bool) -> void:
	interaccion_con_skin.emit(self, toggled)
