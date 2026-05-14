extends Control
class_name Amigo

signal amigo_retado

@export var icono_conectado: Panel
@export var nombre_amigo: RichTextLabel
@export var avatar_amigo: Panel
@export var boton_retar: Button

static var escena_amigo: PackedScene = preload("res://proyecto_rummikub/menuInicio/amigo/amigo.tscn")

var mi_icono: Texture2D
var mi_nombre: String
var mi_id: int

const ANCHURA: float = 54.0
static func amigo (icono: Texture2D, nombre: String, id: int) -> Amigo:
	
	var nuevo_amigo: Amigo = escena_amigo.instantiate()	
	nuevo_amigo.mi_icono = icono
	nuevo_amigo.mi_nombre = nombre
	nuevo_amigo.mi_id = id
	
	var nuevoIcono: StyleBoxTexture = nuevo_amigo.avatar_amigo.get_theme_stylebox("panel").duplicate()
	var ratio: float = icono.get_size().y /  icono.get_size().x 
	nuevoIcono.texture = icono
	nuevo_amigo.avatar_amigo.add_theme_stylebox_override("panel",nuevoIcono)
	nuevo_amigo.avatar_amigo.size.y = ratio * ANCHURA

	
	nuevo_amigo.nombre_amigo.text = nombre
	#nuevo_amigo.avatar_amigo.texture = load("res://imagenes/Fernando.png")
	return nuevo_amigo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func esconder_boton_retar()->void:
	boton_retar.visible = false

func sacar_boton_retar()->void:
	boton_retar.visible = true


func _on_boton_retar_pressed() -> void:
	ConectorRed.enviar_reto(mi_id)
