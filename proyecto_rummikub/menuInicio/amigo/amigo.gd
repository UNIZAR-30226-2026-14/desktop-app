extends Control
class_name Amigo

@export var icono_conectado: Panel
@export var nombre_amigo: RichTextLabel
@export var avatar_amigo: Sprite2D

static var escena_amigo: PackedScene = preload("res://proyecto_rummikub/menuInicio/amigo/amigo.tscn")



static func amigo (conectado: bool, nombre: String) -> Amigo:
	var nuevo_amigo: Amigo = escena_amigo.instantiate()
	if conectado:
		nuevo_amigo.icono_conectado.modulate = "077f16"
	else:
		nuevo_amigo.icono_conectado.modulate = "768487"
	
	nuevo_amigo.nombre_amigo.text = nombre
	#nuevo_amigo.avatar_amigo.texture = load("res://imagenes/Fernando.png")
	return nuevo_amigo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
