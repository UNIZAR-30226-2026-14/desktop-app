class_name MarcoIcono extends Control

var tamano: Vector2 
var icono: Texture2D 
var anchura: int 
var color_borde: Color
@export var color_fondo: Color

func _ready() -> void:
	tamano = get_meta("tamano_minimo")
	icono = get_meta("icono")
	anchura = get_meta("anchura")
	color_borde = get_meta("colorBorde")
	color_fondo = get_meta("colorFondo")
	
	self.custom_minimum_size = tamano
	self.size = tamano
	var icono_aux: StyleBoxTexture = $Borde/Fondo/Imagen.get_theme_stylebox("panel").duplicate()
	var ratio: float = icono.get_size().y /  icono.get_size().x 
	icono_aux.texture = icono
	$Borde/Fondo/Imagen.add_theme_stylebox_override("panel",icono_aux)
	$Borde/Fondo/Imagen.size.y = ratio * anchura
	$Borde.position = Vector2(0,0)
	$Borde/Fondo.position = Vector2(0,0)
	$Borde/Fondo/Imagen.position = Vector2(0,0)
	
	var panel_aux: StyleBoxFlat = $Borde/Fondo.get_theme_stylebox("panel").duplicate()
	panel_aux.bg_color = color_fondo
	$Borde/Fondo.add_theme_stylebox_override("panel",panel_aux)
	
	panel_aux = $Borde.get_theme_stylebox("panel").duplicate()
	panel_aux.border_color = color_borde
	$Borde.add_theme_stylebox_override("panel",panel_aux)

func cambiarParametros(color_borde_in, color_fondo_in, icono_in: Texture2D, tamano_minimo_in, anchura_in) -> void:

	if tamano_minimo_in != null:
		tamano = tamano_minimo_in
	
	if icono_in != null:
		icono = icono_in
	
	if anchura_in != null:
		anchura = anchura_in
	
	if color_borde_in != null:
		color_borde = color_borde_in
	
	if color_fondo_in != null:
		color_fondo = color_fondo_in
	
	self.size = tamano
	var icono_aux: StyleBoxTexture = $Borde/Fondo/Imagen.get_theme_stylebox("panel").duplicate()
	var ratio: float = icono.get_size().y /  icono.get_size().x 
	icono_aux.texture = icono
	$Borde/Fondo/Imagen.add_theme_stylebox_override("panel",icono_aux)
	$Borde/Fondo/Imagen.size.y = ratio * anchura
	$Borde.position = Vector2(0,0)
	$Borde/Fondo.position = Vector2(0,0)
	$Borde/Fondo/Imagen.position = Vector2(0,0)
	
	var panel_aux: StyleBoxFlat = $Borde/Fondo.get_theme_stylebox("panel").duplicate()
	panel_aux.bg_color = color_fondo
	$Borde/Fondo.add_theme_stylebox_override("panel",panel_aux)
	
	panel_aux = $Borde.get_theme_stylebox("panel").duplicate()
	panel_aux.border_color = color_borde
	$Borde.add_theme_stylebox_override("panel",panel_aux)

func cambiar_icono(icono_in)->void:
	if icono_in == null:
		$Borde/Fondo/Imagen.visible = false
	else:
		cambiarParametros(null,null,icono_in,null,null)
		$Borde/Fondo/Imagen.visible = true
	
