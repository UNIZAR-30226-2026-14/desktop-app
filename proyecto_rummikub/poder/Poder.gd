class_name Poder extends Node2D

signal cursor_sobre_poder
signal cursor_no_sobre_poder

enum PODER {NINGUNO, ANGEL_GUARDA, BOLA_CRISTAL, LUPA, TOQUE_MIDAS, TRUEQUE,
		BOMBA_HUMO, RON, REDUCIR_TIEMPO, MENOS, GUANTE_BLANCO, TECHO_CRISTAL}


const LISTA_PRECIOS_OBJETOS: Array[int] = [
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

const LISTA_DESCRIPCIONES_OBJETOS: Array[String] = [
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

const LISTA_TEXTURAS_PODERES: Array[Texture] = [
	preload("res://imagenes/imagenes_poderes/mas.png"),
	preload("res://imagenes/imagenes_poderes/angel-de-la-guarda.png"),
	preload("res://imagenes/imagenes_poderes/bola-de-cristal.png"),
	preload("res://imagenes/imagenes_poderes/Lupa.png"),
	preload("res://imagenes/imagenes_poderes/toque-de-midas.png"),
	preload("res://imagenes/imagenes_poderes/intercambio.png"),
	preload("res://imagenes/imagenes_poderes/bomba-de-humo.png"),
	preload("res://imagenes/imagenes_poderes/dos-copas-de-mas.png"),
	preload("res://imagenes/imagenes_poderes/mitad-de-tiempo.png"),
# MENOS
# GUANTE_BLANCO
# TECHO_CRISTAL
]

static var indice = 0
var mi_indice

@export var area_poder: Area2D
@export var icono_poder: Sprite2D

@export var manager_fichas: Node2D
@export var manager_juego: Node2D

@export var tienda_objetos: Node
@export var selector_adversario: Control
var poder: PODER

func cambiar_poder(nuevo_poder: PODER):
	icono_poder.texture = LISTA_TEXTURAS_PODERES[nuevo_poder]
	poder = nuevo_poder

func get_poder() -> PODER:
	return poder

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mi_indice = indice
	indice += 1
	area_poder.mouse_entered.connect(_actualizar_estado_cursor_entra)
	area_poder.mouse_exited.connect(_actualizar_estado_cursor_sale)
	manager_fichas.conectar_poder(self)
	cambiar_poder(Poder.PODER.TOQUE_MIDAS)

func _actualizar_estado_cursor_entra() -> void:
	cursor_sobre_poder.emit(self)

func _actualizar_estado_cursor_sale() -> void:
	cursor_no_sobre_poder.emit(self)

func ejecutar_poder() -> void:
	match poder:
		PODER.NINGUNO:
			var resultado: PODER = await(tienda_objetos.abrir_tienda(self))
			cambiar_poder(resultado)
		PODER.ANGEL_GUARDA:
			var adversaro_elegido: String = await selector_adversario.sacar_selector_adversarios(poder)
			print(adversaro_elegido)
		PODER.BOLA_CRISTAL:
			pass
		PODER.LUPA:
			pass
		PODER.TOQUE_MIDAS:
			cambiar_poder(PODER.NINGUNO)
			manager_juego.toque_de_midas()
		PODER.TRUEQUE:
			pass
		PODER.BOMBA_HUMO:
			pass
		PODER.RON:
			pass
		PODER.REDUCIR_TIEMPO:
			pass
		PODER.MENOS:
			pass
		PODER.GUANTE_BLANCO:
			pass
		PODER.TECHO_CRISTAL:
			pass
