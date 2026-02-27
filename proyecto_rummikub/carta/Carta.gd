class_name Carta extends Node2D
@export var area2d: Area2D

static var escena_carta: PackedScene = preload("res://proyecto_rummikub/carta/Carta.tscn")

signal cursor_sobre_carta
signal cursor_no_sobre_carta
static var indice: int = -1
var mi_indice: int

static func carta(color: String) -> Node2D:
	var carta_creada: Node2D = escena_carta.instantiate()
	carta_creada.name = str((indice +1 ))
	carta_creada.cambiar_sprite(color)
	return carta_creada

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
	cursor_sobre_carta.emit(mi_indice)

func _emitir_señal_salida():
	cursor_no_sobre_carta.emit(mi_indice)
