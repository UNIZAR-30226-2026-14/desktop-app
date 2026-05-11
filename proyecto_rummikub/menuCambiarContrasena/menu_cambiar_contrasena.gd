extends Control

@export var confirmar: Button
@export var registrarse: Button

@export var textoNomUsuario: LineEdit
@export var textoAntiguaContrasena: LineEdit
@export var textoNuevaContrasena: LineEdit
@export var textoConfirmarContrasena: LineEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	confirmar.pressed.connect(comprobar_datos)
	registrarse.pressed.connect(ir_a_registrarse)

func comprobar_datos() -> void:
	if((textoAntiguaContrasena.text != "") and (textoNuevaContrasena.text != "") and (textoConfirmarContrasena.text != "") \
	and textoNomUsuario.text != "" ):
		if textoNuevaContrasena.text == textoConfirmarContrasena.text:
			var err = await ConectorRed.iniciar_sesion(textoNomUsuario.text,textoAntiguaContrasena.text)
			if err:
				var centro = get_viewport_rect().size/2
				PopUp.popUp("Error en usuario o contraseña antigua",centro,self )
			else:
				await ConectorRed.cambiar_contrasena(textoNuevaContrasena.text,textoAntiguaContrasena.text)
				err = await ConectorRed.iniciar_sesion(textoNomUsuario.text,textoNuevaContrasena.text)
				if not err:
					print("contraseña cambiada")
					get_tree().change_scene_to_file("res://proyecto_rummikub/menuInicio/menuInicio.tscn")
		else:
			var centro = get_viewport_rect().size
			PopUp.popUp("Fallo en la confirmación de contraseña",centro,self)


func ir_a_registrarse() -> void:
	get_tree().change_scene_to_file("res://proyecto_rummikub/menu_registrarse/menu_registrarse.tscn")
