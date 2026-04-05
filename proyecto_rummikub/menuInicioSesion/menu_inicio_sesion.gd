extends Control

@export var confirmar: Button

@export var textoNombreUsuario: LineEdit
@export var textoContrasena: LineEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	confirmar.pressed.connect(guardar_datos)

func guardar_datos() -> void:
	if((textoContrasena.text != "") and (textoNombreUsuario.text != "")):
		globales.contrasena = textoContrasena.text
		globales.nombre_usuario = textoNombreUsuario.text
		get_tree().change_scene_to_file("res://proyecto_rummikub/menuInicio/menuInicio.tscn")
