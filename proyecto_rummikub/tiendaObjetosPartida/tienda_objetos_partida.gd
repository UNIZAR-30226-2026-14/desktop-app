extends Control
# NINGUNO, ANGEL_GUARDA, BOLA_CRISTAL, LUPA, TOQUE_MIDAS, TRUEQUE, 
# BOMBA_HUMO, RON, REDUCIR_TIEMPO, MENOS, GUANTE_BLANCO, TECHO_CRISTAL

@export var contador_dinero: RichTextLabel
@export var contenedor_botones: GridContainer

signal interaccion_con_tienda

enum OBJETO {BOTON_IZQUIERDA, BOTON_DERECHA, BOTON_CERRAR, BOTON_COMPRAR}

var objeto_pulsado: OBJETO
var posicion_puntero: int = 1
var anterior_pulsado: globales.PODER = globales.PODER.NINGUNO

var lista_poderes: Array[BotonTienda] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false

func abrir_tienda(ranura_quiere_comprar : Poder) -> globales.PODER:

	if self.visible:
		return ranura_quiere_comprar.poder
	self.visible = true
	$Panel/descripcion_objeto.visible = false
	$Panel/botonComprar.visible = false
	$Panel/descripcion_objeto.text = globales.LISTA_DESCRIPCIONES_OBJETOS[1]
	sacar_botones()
	while(true):
		await(interaccion_con_tienda)
		match objeto_pulsado:
			OBJETO.BOTON_CERRAR:
				borrar_botones()
				self.visible = false
				return globales.PODER.NINGUNO
			OBJETO.BOTON_COMPRAR:
				var dinero_disponible: int = contador_dinero.text.to_int()
				if  dinero_disponible >= globales.LISTA_PRECIOS_OBJETOS[anterior_pulsado+1]:
					dinero_disponible -= globales.LISTA_PRECIOS_OBJETOS[anterior_pulsado+1]
					contador_dinero.text = str(dinero_disponible)
					borrar_botones()
					self.visible = false
					return globales.PODER.values()[anterior_pulsado+1]
	return globales.PODER.NINGUNO

func sacar_botones() -> void:
	for poder: int in range(1,9):
		var boton_nuevo = BotonTienda.new(poder, globales.LISTA_TEXTURAS_PODERES[poder])
		globales.apropiar_hijo(contenedor_botones, boton_nuevo)
		lista_poderes.append(boton_nuevo)
		boton_nuevo.boton_tienda_pulsado.connect(_poder_pulsado)

func borrar_botones() -> void:
	for poder: BotonTienda in lista_poderes:
		poder.queue_free()
	lista_poderes = []

func _on_boton_cerrar_pressed() -> void:
	objeto_pulsado = OBJETO.BOTON_CERRAR
	interaccion_con_tienda.emit()

func _on_boton_comprar_pressed() -> void:
	objeto_pulsado = OBJETO.BOTON_COMPRAR
	interaccion_con_tienda.emit()

func _poder_pulsado(poder_pulsado: globales.PODER) -> void:
	$Panel/botonComprar.visible = true
	$Panel/descripcion_objeto.visible = true
	lista_poderes[anterior_pulsado].despulsar()
	anterior_pulsado = poder_pulsado - 1 as globales.PODER
	$Panel/descripcion_objeto.text = globales.LISTA_DESCRIPCIONES_OBJETOS[poder_pulsado]
	$Panel/botonComprar.text = str(globales.LISTA_PRECIOS_OBJETOS[poder_pulsado])
