extends Control

@export var confirmar: Button
@export var iniciarSesion: Button

@export var textoNombreUsuario: LineEdit
@export var textoContrasena: LineEdit
@export var textoConfirmarContrasena: LineEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	confirmar.pressed.connect(guardar_datos)
	iniciarSesion.pressed.connect(ir_a_iniciar_sesion)

func guardar_datos() -> void:
	if((textoContrasena.text != "") and (textoNombreUsuario.text != "")) and (textoConfirmarContrasena.text == textoContrasena.text):
		globales.contrasena = textoContrasena.text
		globales.nombre_usuario = textoNombreUsuario.text
		get_tree().change_scene_to_file("res://proyecto_rummikub/menuInicio/menuInicio.tscn")

func ir_a_iniciar_sesion() -> void:
	get_tree().change_scene_to_file("res://proyecto_rummikub/menuInicioSesion/menu_inicio_sesion.tscn")
