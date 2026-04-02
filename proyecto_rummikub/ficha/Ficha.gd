class_name Ficha extends Node2D
@export var area2d: Area2D

# Responabilidad: Emitir señales cuando pasas por encima, verse, tener color y número

signal cursor_sobre_ficha
signal cursor_no_sobre_ficha

enum COLOR{ROJO, NEGRO, AZUL, AMARILLO, BLANCO, COMODIN}

static var escena_ficha: PackedScene = preload("res://proyecto_rummikub/ficha/Ficha.tscn")
static var indice: int = -1
const tamano_fichas : Vector2 = Vector2(70.0, 98.0)

var mi_indice : int
# estado puede ser: MANO, TABLERO_FIJADA, TABLERO_NO_FIJADA
var estado : globales.ESTADO_FICHA

var miGrupo : Grupo_fichas
## jugada o en la mano
var jugada: bool
var en_blanco : bool
var color: COLOR
var numero: int


static func ficha(color_in: COLOR, numero_in: int) -> Node2D:
	var ficha_creada: Node2D = escena_ficha.instantiate()
	ficha_creada.estado = globales.ESTADO_FICHA.MANO
	ficha_creada.z_index = 0
	ficha_creada.estado = globales.ESTADO_FICHA.MANO
	ficha_creada.name = str((indice +1 ))
	ficha_creada.cambiar_sprite(color_in, numero_in)
	ficha_creada.get_child(1).get_child(0).shape.size = tamano_fichas
	ficha_creada.jugada = false;
	ficha_creada.color = color_in
	ficha_creada.numero = numero_in
	return ficha_creada

func set_grupo(grupo: Grupo_fichas):
	estado = globales.ESTADO_FICHA.TABLERO_NO_FIJADA
	miGrupo = grupo
	
func get_grupo() -> Grupo_fichas:
	return miGrupo

# devuelve el tamaño por defecto de las fichas
static func tamano_ficha_static() -> Vector2:
	return tamano_fichas

# devuelve el tamaño de una ficha
func tamano_ficha() -> Vector2:
	return Vector2($Area2D/CollisionShape2D.shape.get_size())

func cambiar_sprite(color_in: COLOR, numero_in: int):
	en_blanco = false
	$Numero.text = str(numero_in)
	match color_in:
		COLOR.ROJO:
			$Numero.modulate = "b92300"
			$assDePicas.texture = load("res://imagenes/carta.jpg")
		COLOR.NEGRO: 
			$Numero.modulate = "000000"
			$assDePicas.texture = load("res://imagenes/carta.jpg")
		COLOR.AZUL:
			$Numero.modulate = "00aeaf"
			$assDePicas.texture = load("res://imagenes/carta.jpg")
		COLOR.AMARILLO:
			$Numero.modulate = "cfce00"
			$assDePicas.texture = load("res://imagenes/carta.jpg")
		COLOR.BLANCO:
			en_blanco = true
			$Numero.text = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	indice += 1
	mi_indice = indice 
	area2d.mouse_entered.connect(_emitir_señal_entrada)
	area2d.mouse_exited.connect(_emitir_señal_salida)

func _emitir_señal_entrada():
	cursor_sobre_ficha.emit(self)

func _emitir_señal_salida():
	cursor_no_sobre_ficha.emit(self)
