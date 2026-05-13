extends Control

func actualiar_icono_y_nombre(icono: Texture2D, nombre: String) -> void:
	$MarcoIcono.cambiar_icono(icono)
	$RichTextLabel.text = nombre
