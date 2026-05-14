class_name tableroTienda extends ElementoTienda

var color: String

static func tableroTienda (_color: String, precio: String, descripcion: String, tipo: TIPO_SKIN) -> tableroTienda:
	var nuevo_elemento_tienda: ElementoTienda = escena_elemento_tienda.instantiate()
	nuevo_elemento_tienda.set_script(preload("res://proyecto_rummikub/menuInicio/elementoTienda/tableroTienda.gd"))
	nuevo_elemento_tienda.color = _color
	if tipo == TIPO_SKIN.FICHA:
		nuevo_elemento_tienda.mi_skin = globales.colores_fichas[_color]
	else:
		nuevo_elemento_tienda.mi_skin = globales.colores[_color]
	nuevo_elemento_tienda.boton_comprar.text = str(precio)
	nuevo_elemento_tienda.descripcion_skin.text = descripcion
	
	if tipo == TIPO_SKIN.FICHA:
		nuevo_elemento_tienda.icono_skin.modulate = globales.colores_fichas[_color]
	else:
		nuevo_elemento_tienda.icono_skin.modulate = globales.colores[_color]

	nuevo_elemento_tienda.boton_comprar.button_group = LISTA_BUTTON_GROUPS[tipo]
	
	return nuevo_elemento_tienda

func _init() -> void:
	$Fondo/BotonComprar.toggled.connect(_ineteraccion_con_skin)
	icono_skin = $Fondo/marco/IconoSkin
	descripcion_skin = $Fondo/DescripcionSkin
	boton_comprar = $Fondo/BotonComprar
	fondo = $Fondo
