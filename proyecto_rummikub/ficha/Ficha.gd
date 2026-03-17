class_name Ficha extends Node2D
@export var area2d: Area2D

# Responabilidad: Emitir señales cuando pasas por encima, verse, tener color y número

signal cursor_sobre_ficha
signal cursor_no_sobre_ficha

static var escena_ficha: PackedScene = preload("res://proyecto_rummikub/ficha/Ficha.tscn")
static var indice: int = -1
const tamano_fichas : Vector2 = Vector2(70.0, 98.0)

var mi_indice : int
var miGrupo : Grupo_fichas
## jugada o en la mano
var jugada: bool
var en_blanco : bool

static func ficha(color: String) -> Node2D:
	var ficha_creada: Node2D = escena_ficha.instantiate()
	ficha_creada.name = str((indice +1 ))
	ficha_creada.cambiar_sprite(color)
	ficha_creada.get_child(1).get_child(0).shape.size = tamano_fichas
	ficha_creada.jugada = false;
	return ficha_creada

func set_grupo(grupo: Grupo_fichas):
	miGrupo = grupo
	
func get_grupo() -> Grupo_fichas:
	return miGrupo

# devuelve el tamaño por defecto de las fichas
static func tamano_ficha_static() -> Vector2:
	return tamano_fichas

# devuelve el tamaño de una ficha
func tamano_ficha() -> Vector2:
	return Vector2($Area2D/CollisionShape2D.shape.get_size())

func cambiar_sprite(color: String):
	en_blanco = false
	match color:
		"corazones":
			$assDePicas.texture = load("res://imagenes/asscorazones.jpg")
		"picas": 
			$assDePicas.texture = load("res://imagenes/asspicas.jpg")
		"treboles":
			$assDePicas.texture = load("res://imagenes/asstreboles.jpg")
		"diamantes":
			$assDePicas.texture = load("res://imagenes/assdiamantes.jpg")
		"blanco":
			en_blanco = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("patata")
	indice += 1
	mi_indice = indice 
	area2d.mouse_entered.connect(_emitir_señal_entrada)
	area2d.mouse_exited.connect(_emitir_señal_salida)


func _emitir_señal_entrada():
	cursor_sobre_ficha.emit(self)

func _emitir_señal_salida():
	cursor_no_sobre_ficha.emit(self)
