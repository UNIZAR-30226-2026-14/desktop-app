extends Node

func _ready() -> void:
	await ConectorRed.registrar_usuario("usuario_debug", "contrasena_debug")
	await ConectorRed.iniciar_sesion("usuario_debug", "contrasena_debug")
	#await ConectorRed.crear_amistades()
	get_tree().change_scene_to_file("res://proyecto_rummikub/menuInicio/menuInicio.tscn")
	#await ConectorRed.buscar_partida()
	#await ConectorRed.espera_a_turno(func(_pa):pass)
	#await ConectorRed.paso_turno()
	#get_tree().change_scene_to_file("res://proyecto_rummikub/escenaPrincipal/escenaprincipal.tscn")
	#get_tree().change_scene_to_file("res://proyecto_rummikub/menuTransicion/menuTransicion.tscn")
