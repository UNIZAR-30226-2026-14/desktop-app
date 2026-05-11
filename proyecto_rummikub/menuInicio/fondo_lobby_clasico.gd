extends Panel

@export var icono0: MarcoIcono
@export var icono1: MarcoIcono
@export var icono2: MarcoIcono
@export var icono3: MarcoIcono

func _ready() -> void:
	self.visible = false
	$PanelCreacionPartidaPrivada.visible = false
	$PanelLobby/BotonCerrar.pressed.connect(_cerrar)
	$PanelLobby/BotonPartidaPublica.pressed.connect(_buscar_partida_publica)
	$PanelLobby/BotonPartidaPrivada.pressed.connect(_crear_partida_privada)
	$PanelCreacionPartidaPrivada/BotonCerrar.pressed.connect(_cerrar_creacion_partida_privada)
	$PanelLobby/BotonPartidaPublica.pressed.connect(_empezar_partida_privada)
	cambiar_icono_amigo(null,0)
	cambiar_icono_amigo(null,2)

var es_arcade: bool
func mostrar(modo_arcade: bool)->void:
	es_arcade = modo_arcade
	if es_arcade:
		$PanelLobby/TituloModo.text = "MODO ARCADE"
	else:
		$PanelLobby/TituloModo.text = "MODO CLASICO"
	self.visible = true

func _cerrar() -> void:
	self.visible = false
	$PanelCreacionPartidaPrivada.visible = false
	$PanelLobby/BotonUnriseConCodigo/InsertadorCodigo.text = ""

func _buscar_partida_publica() -> void:
	var menu_transicion = preload("res://proyecto_rummikub/menuTransicion/menuTransicion.tscn").instantiate()
	menu_transicion.es_arcade = es_arcade
	get_tree().change_scene_to_node(menu_transicion)

func _crear_partida_privada() -> void:
	var id_partida = await ConectorRed.crear_partida_privada(es_arcade)
	$PanelLobby.visible = false
	$PanelCreacionPartidaPrivada.mostrar(true,es_arcade,id_partida)
	actualizar_lista_amigos()


func _cerrar_creacion_partida_privada() -> void:
	$PanelCreacionPartidaPrivada.visible = false
	$PanelLobby.visible = true

## indice va del 0 al 3, para ocultar meter un null en nuevo_icono
func cambiar_icono_amigo(nuevo_icono:Texture2D, indice: int) -> void:
	match(indice):
		0:
			icono0.cambiar_icono(nuevo_icono)
		1:
			icono1.cambiar_icono(nuevo_icono)
		2:
			icono2.cambiar_icono(nuevo_icono)
		3:
			icono3.cambiar_icono(nuevo_icono)

var amigos: Array[Amigo] = [Amigo.amigo(preload("res://imagenes/avatares_posibles/Miguel.png"), "Miguel"), Amigo.amigo(preload("res://imagenes/avatares_posibles/Dian.png"), "Dian")]


func actualizar_lista_amigos()->void:
	amigos = $"../MenuAmigos".get_amigos()
	for amigo in amigos:
		globales.apropiar_hijo($PanelCreacionPartidaPrivada/PanelSeleccionAmigos/ScrollContainer/contenedorAmigos, amigo)

func _empezar_partida_privada()->void:
	pass
