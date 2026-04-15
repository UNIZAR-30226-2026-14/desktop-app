# variables globales del proyecto:
extends Node

enum LADOS {IZQUIERDA, DERECHA}

enum ESTADO_FICHA {MANO, TABLERO_FIJADA, TABLERO_NO_FIJADA}

enum ESTADO_CURSOR {MANO, TABLERO, LIMBO}

enum ESTADO_JUEGO {NO_MI_TURNO, PONIENDO_FICHAS, NO_PONIENDO_FICHAS}

enum PODER {NINGUNO, ANGEL_GUARDA, BOLA_CRISTAL, LUPA, TOQUE_MIDAS, TRUEQUE,
		BOMBA_HUMO, RON, REDUCIR_TIEMPO, MENOS, GUANTE_BLANCO, TECHO_CRISTAL}


class datos_poder:
	var imagen: Texture2D
	var descripcion: String
	var precio: int
	
	func _init(imagen_in: Texture2D, descripcion_in: String, precio_in: int) -> void:
		imagen = imagen_in
		descripcion = descripcion_in
		precio = precio_in

var LISTA_PRECIOS_OBJETOS: Array[int] = [
	100,
	100,
	100,
	100,
	100,
	100,
	100,
	100,
	100,
	100,
	100,
	100,
]

var LISTA_DESCRIPCIONES_OBJETOS: Array[String] = [
	"",
	"protección ante otro objeto, tras bloquear uno este se gasta",
	"ver fichas de un color o rango numérico de todos los jugadores",
	"poder ver las fichas y objetos de un jugador",
	"convierte de 2 a 4 de tus fichas en fichas doradas (al azar)",
	"mira 3 fichas de un oponente, elige una de esas tres y una tuya, las intercambias",
	"hacer que un jugador no pueda ver las fichas puestas en tablero",
	"invertir los controles de un jugador en un turno",
	"reducir a la mitad el tiempo del próximo turno de un jugador",
]

var LISTA_TEXTURAS_PODERES: Array[Texture] = [
	load("res://imagenes/imagenes_poderes/mas.png"),
	load("res://imagenes/imagenes_poderes/angel-de-la-guarda.png"),
	load("res://imagenes/imagenes_poderes/bola-de-cristal.png"),
	load("res://imagenes/imagenes_poderes/Lupa.png"),
	load("res://imagenes/imagenes_poderes/toque-de-midas.png"),
	load("res://imagenes/imagenes_poderes/intercambio.png"),
	load("res://imagenes/imagenes_poderes/bomba-de-humo.png"),
	load("res://imagenes/imagenes_poderes/dos-copas-de-mas.png"),
	load("res://imagenes/imagenes_poderes/mitad-de-tiempo.png"),
# MENOS
# GUANTE_BLANCO
# TECHO_CRISTAL
]
static var estado_cursor: ESTADO_CURSOR
static var estado_juego: ESTADO_JUEGO

# sin uso aun pero quiero usarlo para devolver la ficha al tablero si el cursor 
# viene del tablero o a la mano si venia de la mano
static var estado_anterior_cursor: ESTADO_CURSOR

static var nombre_usuario: String = ""
static var contrasena: String = ""

func apropiar_hijo(nuevo_padre: Node, hijo: Node) -> void:
	if hijo.get_parent():
		hijo.get_parent().remove_child(hijo)
	nuevo_padre.add_child(hijo)
