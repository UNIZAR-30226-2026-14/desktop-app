extends Panel

@export var icono0: MarcoIcono
@export var icono1: MarcoIcono
@export var icono2: MarcoIcono
@export var icono3: MarcoIcono

func _ready() -> void:
	self.visible = false
	$PanelCreacionPartidaPrivada.visible = false
	$PanelLobbyClasico/BotonCerrar.pressed.connect(_cerrar)
	$PanelLobbyClasico/BotonPartidaPublica.pressed.connect(_buscar_partida_publica)
	$PanelLobbyClasico/BotonPartidaPrivada.pressed.connect(_buscar_partida_privada)
	$PanelCreacionPartidaPrivada/BotonCerrar.pressed.connect(_cerrar_creacion_partida_privada)
	$PanelLobbyClasico/BotonPartidaPublica.pressed.connect(_empezar_partida_privada)
	cambiar_icono_amigo(null,0)
	cambiar_icono_amigo(null,2)

func _cerrar() -> void:
	self.visible = false
	$PanelCreacionPartidaPrivada.visible = false
	$PanelLobbyClasico/BotonUnriseConCodigo/InsertadorCodigo.text = ""

func _buscar_partida_publica() -> void:
	get_tree().change_scene_to_file("res://proyecto_rummikub/menuTransicion/menuTransicion.tscn")

func _buscar_partida_privada() -> void:
	$PanelLobbyClasico.visible = false
	$PanelCreacionPartidaPrivada.visible = true
	actualizar_lista_amigos()


func _cerrar_creacion_partida_privada() -> void:
	$PanelCreacionPartidaPrivada.visible = false
	$PanelLobbyClasico.visible = true

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
	# hacer aqui get amigos
	for amigo in amigos:
		globales.apropiar_hijo($PanelCreacionPartidaPrivada/PanelSeleccionAmigos/ScrollContainer/contenedorAmigos, amigo)

func _empezar_partida_privada()->void:
	pass
