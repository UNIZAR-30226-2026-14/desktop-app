class_name Poder extends Node2D

signal cursor_sobre_poder
signal cursor_no_sobre_poder

static var indice = 0
var mi_indice

@export var area_poder: Area2D
@export var icono_poder: Sprite2D

@export var manager_fichas: Node2D
@export var manager_juego: Node2D

@export var tienda_objetos: Node

var poder: globales.PODER

func cambiar_poder(nuevo_poder: globales.PODER):
	icono_poder.texture = globales.LISTA_TEXTURAS_PODERES[nuevo_poder]
	poder = nuevo_poder

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mi_indice = indice
	indice += 1
	area_poder.mouse_entered.connect(_actualizar_estado_cursor_entra)
	area_poder.mouse_exited.connect(_actualizar_estado_cursor_sale)
	manager_fichas.conectar_poder(self)
	cambiar_poder(globales.PODER.NINGUNO)

func _actualizar_estado_cursor_entra() -> void:
	cursor_sobre_poder.emit(self)

func _actualizar_estado_cursor_sale() -> void:
	cursor_no_sobre_poder.emit(self)

func ejecutar_poder() -> void:
	match poder:
		globales.PODER.NINGUNO:
			var resultado: globales.PODER = await(tienda_objetos.abrir_tienda(self))
			cambiar_poder(resultado)
		globales.PODER.ANGEL_GUARDA:
			pass
		globales.PODER.BOLA_CRISTAL:
			pass
		globales.PODER.LUPA:
			pass
		globales.PODER.TOQUE_MIDAS:
			pass
		globales.PODER.TRUEQUE:
			pass
		globales.PODER.BOMBA_HUMO:
			pass
		globales.PODER.RON:
			pass
		globales.PODER.REDUCIR_TIEMPO:
			pass
		globales.PODER.MENOS:
			pass
		globales.PODER.GUANTE_BLANCO:
			pass
		globales.PODER.TECHO_CRISTAL:
			pass
