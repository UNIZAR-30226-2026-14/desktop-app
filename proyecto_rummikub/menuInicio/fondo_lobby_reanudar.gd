extends Panel

@export var icono0: MarcoIcono
@export var icono1: MarcoIcono
@export var icono2: MarcoIcono
@export var icono3: MarcoIcono
var iconos :Array[MarcoIcono] = [icono0,icono1,icono2,icono3]
var id_partida: int = -1
var actualiza:bool

## indice va del 0 al 3, para ocultar meter un null en nuevo_icono
func cambiar_icono(nuevo_icono:Texture2D, indice: int) -> void:
	match(indice):
		0:
			icono0.cambiar_icono(nuevo_icono)
		1:
			icono1.cambiar_icono(nuevo_icono)
		2:
			icono2.cambiar_icono(nuevo_icono)
		3:
			icono3.cambiar_icono(nuevo_icono)

func _ready() -> void:
	self.visible = false
	$PanelReanudarPartida/BotonCerrar.pressed.connect(_cerrar)
	$PanelReanudarPartida/BotonEmpezar.pressed.connect(_iniciar_partida)
	$PanelReanudarPartida/BotonCerrar.pressed.connect(_no_esperar_partida) 
	$PanelReanudarPartida/BotonUnirse.pressed.connect(_esperar_partida)
	cambiar_icono(globales.avatar,0)
	cambiar_icono(null,1)
	cambiar_icono(null,2)
	cambiar_icono(null,3)

func _cerrar() -> void:
	self.visible = false
	actualiza = false
	ConectorRed.salirse_de_reanudable(id_partida)
	id_partida = -1

func mostrar() -> void:
	$PanelReanudarPartida/BotonCerrar.visible = false 
	$PanelReanudarPartida/BotonUnirse.visible = false
	$PanelReanudarPartida/BotonEmpezar.visible = false
	id_partida = -1
	actualiza = true
	self.visible = true
	await actualizar_partidas_pendientes()
	actualiza_varias_veces()

var partidas: Array[PartidaSeleccionable] = []
var amigos: Array[Amigo] = []
var amigos_usando: Array[Amigo] = []

func actualizar_partidas_pendientes() -> void:
	partidas.assign(await ConectorRed.get_reanudables())
	for partida: PartidaSeleccionable in $PanelReanudarPartida/PanelSeleccionPartida/ScrollContainer/contenedorPartidas.get_children():
		$PanelReanudarPartida/PanelSeleccionPartida/ScrollContainer/contenedorPartidas.remove_child(partida)
		partida.queue_free()
	for partida: PartidaSeleccionable in partidas:
		globales.apropiar_hijo($PanelReanudarPartida/PanelSeleccionPartida/ScrollContainer/contenedorPartidas, partida)
		partida.partida_seleccionada.connect(_partida_presionada)

func actualiza_varias_veces()->void:
	while actualiza:
	#amigos
		amigos = $"../MenuAmigos".get_amigos()
		for amigo:Amigo in amigos:
			amigo.sacar_boton_retar()
			globales.apropiar_hijo($PanelReanudarPartida/PanelSeleccionAmigos/ScrollContainer/contenedorAmigos, amigo)
	#jugadores en pestaña
		if id_partida == -1:
			for i in range(3):
				cambiar_icono(null,i+1)
		else:
			var adv:Array = await ConectorRed.get_adversarios_con_id(id_partida,true)
			for i in range(1,4):
				cambiar_icono(null,i)
			for i in adv.size():
				cambiar_icono(adv[i]["icono"],i+1)
		await get_tree().create_timer(2).timeout

func _partida_presionada(partida: PartidaSeleccionable):
	
	ConectorRed.salirse_de_reanudable(id_partida)
	id_partida = partida.id_partida
	ConectorRed.unirse_a_reanudable(id_partida)
	var adv:Array = await ConectorRed.get_adversarios_con_id(id_partida,true)
	for i in range(1,4):
		cambiar_icono(null,i)
	for i in adv.size():
		cambiar_icono(adv[i]["icono"],i+1)
	$PanelReanudarPartida/BotonUnirse.visible = true

func _esperar_partida()->void:
	$PanelReanudarPartida/BotonCerrar.visible = true 
	$PanelReanudarPartida/BotonEmpezar.visible = true
	$PanelReanudarPartida/BotonUnirse.visible = false
	if (await ConectorRed.esperar_comienzo_cancelable(id_partida,
		$PanelReanudarPartida/BotonEmpezar,$PanelReanudarPartida/BotonCancelar)):
		get_tree().change_scene_to_file("res://proyecto_rummikub/escenaPrincipal/escenaprincipal.tscn")
	else:
		ConectorRed.salirse_de_reanudable(id_partida)
	

func _no_esperar_partida()->void:
	$PanelReanudarPartida/BotonCerrar.visible = false 
	$PanelReanudarPartida/BotonUnirse.visible = false
	$PanelReanudarPartida/BotonEmpezar.visible = true
	

func _iniciar_partida() -> void:
	printerr("iniciar partida presionado")
