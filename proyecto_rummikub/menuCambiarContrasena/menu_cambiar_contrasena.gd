extends Control

@export var confirmar: Button
@export var registrarse: Button

@export var textoAntiguaContrasena: LineEdit
@export var textoNuevaContrasena: LineEdit
@export var textoConfirmarContrasena: LineEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	confirmar.pressed.connect(comprobar_datos)
	registrarse.pressed.connect(ir_a_registrarse)

func comprobar_datos() -> void:
	if((textoAntiguaContrasena.text != "") and (textoNuevaContrasena.text != "") and (textoConfirmarContrasena.text != "") ):
		if (textoAntiguaContrasena.text == globales.contrasena) and (textoNuevaContrasena.text == textoConfirmarContrasena.text):
			globales.contrasena = textoNuevaContrasena.text
			get_tree().change_scene_to_file("res://proyecto_rummikub/menuInicio/menuInicio.tscn")

func ir_a_registrarse() -> void:
	get_tree().change_scene_to_file("res://proyecto_rummikub/menu_registrarse/menu_registrarse.tscn")
