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
		var err: Error =  await ConectorRed.registrar_usuario(textoNombreUsuario.text,textoContrasena.text)
		if not err:
			err = await ConectorRed.iniciar_sesion(textoNombreUsuario.text,textoContrasena.text)
			if not err:
				get_tree().change_scene_to_file("res://proyecto_rummikub/menuInicio/menuInicio.tscn")
			else:
				get_tree().change_scene_to_file("res://proyecto_rummikub/menuInicioSesion/menu_inicio_sesion.tscn")
		else:
			$ColorRect/MensajeError.visible = true
func ir_a_iniciar_sesion() -> void:
	get_tree().change_scene_to_file("res://proyecto_rummikub/menuInicioSesion/menu_inicio_sesion.tscn")
