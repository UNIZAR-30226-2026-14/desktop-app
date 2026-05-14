extends Control

@export var menuInicio: Control

@export var botonTienda: Button
@export var botonCerrarTienda: Button

@export var ContenedorTableros: GridContainer
@export var ContenedorSkinFichas: GridContainer

var lista_skins_tableros: Dictionary[String, tableroTienda] = {
	"amarillo":    tableroTienda.tableroTienda("amarillo",   "200" ,"Amarillo dorado", ElementoTienda.TIPO_SKIN.TABLERO),
	"azul": tableroTienda.tableroTienda("azul","100" ,"Azul marino"    , ElementoTienda.TIPO_SKIN.TABLERO),
	"gris":        tableroTienda.tableroTienda("gris",       "10"  ,"Gris"           , ElementoTienda.TIPO_SKIN.TABLERO),
	"rojo":        tableroTienda.tableroTienda("rojo",       "1000","Rojo sangre"    , ElementoTienda.TIPO_SKIN.TABLERO),
	"verde":       tableroTienda.tableroTienda("verde", ElementoTienda.EQUIPADO, "Verde oscuro"    , ElementoTienda.TIPO_SKIN.TABLERO),
}

var lista_skins_fichas: Dictionary[String, tableroTienda] = {
	"gris":        tableroTienda.tableroTienda("gris",       "800"  ,"Gris oficina"           , ElementoTienda.TIPO_SKIN.FICHA),
	"rosa":        tableroTienda.tableroTienda("rosa",       "2000","Divina"    , ElementoTienda.TIPO_SKIN.FICHA),
	"blanco":       tableroTienda.tableroTienda("blanco", ElementoTienda.EQUIPADO, "Original"    , ElementoTienda.TIPO_SKIN.FICHA),
}



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	botonTienda.pressed.connect(sacar_tienda)
	botonCerrarTienda.pressed.connect(cerrar_tienda)
	await ConectorRed.get_perfil()
	for skin_tablero: tableroTienda in lista_skins_tableros.values():
		globales.apropiar_hijo(ContenedorTableros, skin_tablero)
		skin_tablero.interaccion_con_skin.connect(_interaccion_con_elemento_tienda)
		if skin_tablero.color in globales.mis_skins_tablero:
			#skin_tablero.boton_comprar.button_pressed = true
			skin_tablero.set_precio(ElementoTienda.DESEQUIPADO)
		if skin_tablero.color in globales.skin_tablero_equipada:
			skin_tablero.boton_comprar.button_pressed = true
			skin_tablero.set_precio(ElementoTienda.EQUIPADO)
	
	for skin_ficha: tableroTienda in lista_skins_fichas.values():
		globales.apropiar_hijo(ContenedorSkinFichas, skin_ficha)
		skin_ficha.interaccion_con_skin.connect(_interaccion_con_elemento_tienda)
		if skin_ficha.color in globales.mis_skins_ficha:
			#skin_tablero.boton_comprar.button_pressed = true
			skin_ficha.set_precio(ElementoTienda.DESEQUIPADO)
		if skin_ficha.color in globales.skin_ficha_equipada:
			skin_ficha.boton_comprar.button_pressed = true
			skin_ficha.set_precio(ElementoTienda.EQUIPADO)

func sacar_tienda() -> void:
	self.visible = true

func cerrar_tienda() -> void:
	self.visible = false
	menuInicio.set_dinero()
	ConectorRed.set_skins()

func _interaccion_con_elemento_tienda(interactuado: ElementoTienda, toggled: bool) -> void:
	if toggled:
		if (interactuado.get_precio() > -1) and (interactuado.get_precio() <= globales.monedas):
			# Se consigue comprar el elemento de la tienda
			globales.monedas = globales.monedas - interactuado.get_precio()
			menuInicio.set_dinero()
			globales.set_color_tablero(interactuado.get_skin())
			interactuado.set_precio(ElementoTienda.EQUIPADO)
			
		elif interactuado.get_precio() == -1:
			# Se equipa un objeto ya comprado
			globales.set_color_tablero(interactuado.get_skin())
			interactuado.set_precio(ElementoTienda.EQUIPADO)
			
		elif interactuado.get_precio() > globales.monedas:
			# Demasiado caro no pasa nada
			interactuado.boton_comprar.button_pressed = false
			lista_skins_tableros[globales.skin_tablero_equipada].boton_comprar.button_pressed = true

	else:
		if (interactuado.get_precio() == -2):
			#Se desequipa un objeto ya comprado
			interactuado.set_precio(ElementoTienda.DESEQUIPADO)
