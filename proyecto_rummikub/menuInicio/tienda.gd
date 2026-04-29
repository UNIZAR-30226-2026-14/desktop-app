extends Control

@export var menuInicio: Control

@export var botonTienda: Button
@export var botonCerrarTienda: Button

@export var ContenedorTableros: GridContainer
@export var ContenedorSkinFichas: GridContainer

var lista_skins_tableros: Dictionary[Color, ElementoTienda] = {
	globales.colores["Amarillo"]:    ElementoTienda.ElementoTienda(globales.colores["Amarillo"],   "200" ,"Amarillo dorado", ElementoTienda.TIPO_SKIN.TABLERO),
	globales.colores["Azul marino"]: ElementoTienda.ElementoTienda(globales.colores["Azul marino"],"100" ,"Azul marino"    , ElementoTienda.TIPO_SKIN.TABLERO),
	globales.colores["Gris"]:        ElementoTienda.ElementoTienda(globales.colores["Gris"],       "10"  ,"Gris"           , ElementoTienda.TIPO_SKIN.TABLERO),
	globales.colores["Rojo"]:        ElementoTienda.ElementoTienda(globales.colores["Rojo"],       "1000","Rojo sangre"    , ElementoTienda.TIPO_SKIN.TABLERO),
	globales.colores["Verde"]:       ElementoTienda.ElementoTienda(globales.colores["Verde"], ElementoTienda.EQUIPADO, "Verde oscuro"    , ElementoTienda.TIPO_SKIN.TABLERO),
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	botonTienda.pressed.connect(sacar_tienda)
	botonCerrarTienda.pressed.connect(cerrar_tienda)
	for skin_tablero: ElementoTienda in lista_skins_tableros.values():
		globales.apropiar_hijo(ContenedorTableros, skin_tablero)
		skin_tablero.interaccion_con_skin.connect(_interaccion_con_elemento_tienda)
		if skin_tablero.get_precio() == -2:
			skin_tablero.boton_comprar.button_pressed = true
			skin_tablero.set_precio(ElementoTienda.EQUIPADO)


func sacar_tienda() -> void:
	self.visible = true

func cerrar_tienda() -> void:
	self.visible = false

func _interaccion_con_elemento_tienda(interactuado: ElementoTienda, toggled: bool) -> void:
	if toggled:
		if (interactuado.get_precio() > -1) and (interactuado.get_precio() <= menuInicio.get_dinero()):
			# Se consigue comprar el elemento de la tienda
			menuInicio.set_dinero(menuInicio.get_dinero() - interactuado.get_precio())
			globales.skin_tablero_equipada = interactuado.get_skin()
			interactuado.set_precio(ElementoTienda.EQUIPADO)
			
		elif interactuado.get_precio() == -1:
			# Se equipa un objeto ya comprado
			globales.skin_tablero_equipada = interactuado.get_skin()
			interactuado.set_precio(ElementoTienda.EQUIPADO)
			
		elif interactuado.get_precio() > menuInicio.get_dinero():
			# Demasiado caro no pasa nada
			interactuado.boton_comprar.button_pressed = false
			lista_skins_tableros[globales.skin_tablero_equipada].boton_comprar.button_pressed = true

	else:
		if (interactuado.get_precio() == -2):
			#Se desequipa un objeto ya comprado
			interactuado.set_precio(ElementoTienda.DESEQUIPADO)
