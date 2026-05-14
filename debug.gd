extends Node

func _ready() -> void:
	await ConectorRed.registrar_usuario("usuario_debug", "contrasena_debug")
	await ConectorRed.iniciar_sesion("usuario_debug", "contrasena_debug")
	#await ConectorRed.crear_amistades()
	
	#get_tree().change_scene_to_file("res://proyecto_rummikub/menuTransicion/menuTransicion.tscn")
	get_tree().change_scene_to_file("res://proyecto_rummikub/menuInicio/menuInicio.tscn")
	
	# por probar:
	
