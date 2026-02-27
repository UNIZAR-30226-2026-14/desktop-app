class_name Ficha extends Node2D
@export var area2d: Area2D

static var escena_ficha: PackedScene = preload("res://proyecto_rummikub/ficha/Ficha.tscn")

signal cursor_sobre_ficha
signal cursor_no_sobre_ficha
static var indice: int = -1
var mi_indice: int

static func ficha(color: String) -> Node2D:
	var ficha_creada: Node2D = escena_ficha.instantiate()
	ficha_creada.name = str((indice +1 ))
	ficha_creada.cambiar_sprite(color)
	return ficha_creada
# bonasera bambino 
func cambiar_sprite(color: String):
	match color:
		"corazones":
			$assDePicas.texture = load("res://imagenes/asscorazones.jpg")
		"picas": 
			$assDePicas.texture = load("res://imagenes/asspicas.jpg")
		"treboles":
			$assDePicas.texture = load("res://imagenes/asstreboles.jpg")
		"diamantes":
			$assDePicas.texture = load("res://imagenes/assdiamantes.jpg")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("patata")
	indice += 1
	mi_indice = indice 
	area2d.mouse_entered.connect(_emitir_señal_entrada)
	area2d.mouse_exited.connect(_emitir_señal_salida)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _emitir_señal_entrada():
	cursor_sobre_ficha.emit(mi_indice)

func _emitir_señal_salida():
	cursor_no_sobre_ficha.emit(mi_indice)
