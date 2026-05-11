extends Panel

var actualiza = true

func mostrar(he_creado:bool, es_arcade: bool, id_partida: int):
	$indicadorIdPartida/RichTextLabel.text = "RUM-"+str(id_partida)
	$BotonEmpezarPartida.visible = he_creado
	actualiza = true
	actualiza_iconos()
	visible = true
	await ConectorRed.esperar_comienzo_privada(null,$BotonEmpezarPartida)
	actualiza = false
	var escena_juego = preload("res://proyecto_rummikub/escenaPrincipal/escenaprincipal.tscn").instantiate()
	escena_juego.es_arcade = es_arcade
	get_tree().change_scene_to_node(escena_juego)

func actualiza_iconos():
	while actualiza:
		var adv = await ConectorRed.get_adversarios()
		if actualiza:
			var iconos_jugadores = $PanelIconosJugadores/contenedorIconos.get_children()
			for i in range(adv.size()):
				iconos_jugadores[i].cambiar_icono(adv[i]["icono"])
			await get_tree().physics_frame

func _on_boton_cerrar_pressed() -> void:
	actualiza = false
	for icono in $PanelIconosJugadores/contenedorIconos.get_children():
		icono.cambiar_icono(null)
	visible = false
