extends Control

@export var confirmar: Button
@export var registrarse: Button
@export var cambiarContrasena: Button

@export var textoNombreUsuario: LineEdit
@export var textoContrasena: LineEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	confirmar.pressed.connect(comprobar_datos)
	registrarse.pressed.connect(ir_a_registrarse)
	cambiarContrasena.pressed.connect(ir_a_cambiar_contrasena)

func comprobar_datos() -> void:
	if((textoContrasena.text != "") and (textoNombreUsuario.text != "")):
		globales.contrasena = textoContrasena.text
		globales.nombre_usuario = textoNombreUsuario.text
		get_tree().change_scene_to_file("res://proyecto_rummikub/menuInicio/menuInicio.tscn")

func ir_a_registrarse() -> void:
	get_tree().change_scene_to_file("res://proyecto_rummikub/menu_registrarse/menu_registrarse.tscn")

func ir_a_cambiar_contrasena() -> void:
	get_tree().change_scene_to_file("res://proyecto_rummikub/menuCambiarContrasena/menuCambiarContrasena.tscn")
