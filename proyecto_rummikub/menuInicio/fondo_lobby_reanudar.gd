extends Panel

@export var icono0: MarcoIcono
@export var icono1: MarcoIcono
@export var icono2: MarcoIcono
@export var icono3: MarcoIcono

func _ready() -> void:
	self.visible = false
	$PanelReanudarPartida/BotonCerrar.pressed.connect(_cerrar)
	$PanelReanudarPartida/BotonEmpezar.pressed.connect(_buscar_partida)
	cambiar_icono_amigo(null,0)
	cambiar_icono_amigo(null,2)

func _cerrar() -> void:
	self.visible = false

func _buscar_partida() -> void:
	get_tree().change_scene_to_file("res://proyecto_rummikub/menuTransicion/menuTransicion.tscn")

func mostrar() -> void:
	self.visible = true
	actualizar_lista_partidas()
	actualizar_lista_amigos()

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


static var imagen1: Texture2D = preload("res://imagenes/avatares_posibles/Miguel.png")
static var imagen2: Texture2D = preload("res://imagenes/avatares_posibles/Dian.png")
static var imagen3: Texture2D = preload("res://imagenes/avatares_posibles/Miguel.png")
static var imagen4: Texture2D = preload("res://imagenes/avatares_posibles/Dian.png")

static var partida1: PartidaSeleccionable =  PartidaSeleccionable.partida_seleccionable("11/09/2001",[preload("res://imagenes/avatares_posibles/Miguel.png"),imagen2,imagen3,imagen4])
static var partida2: PartidaSeleccionable =  PartidaSeleccionable.partida_seleccionable("5/09/2005",[imagen2,imagen1,imagen2,imagen1])

var partidas: Array[PartidaSeleccionable] = [partida1, partida2]
var amigos: Array[Amigo] = [Amigo.amigo(preload("res://imagenes/avatares_posibles/Miguel.png"), "Miguel"), Amigo.amigo(preload("res://imagenes/avatares_posibles/Dian.png"), "Dian")]

var amigos_usando: Array[Amigo] = []
var partidas_usando: Array[PartidaSeleccionable] = []

func actualizar_lista_partidas() -> void:
	
	for partida: PartidaSeleccionable in partidas_usando:
		partida.queue_free()
	
	for partida: PartidaSeleccionable in partidas:
		partidas_usando.append(PartidaSeleccionable.partida_seleccionable(partida.mi_fecha,partida.mi_iconos_jugadores.duplicate()))
		globales.apropiar_hijo($PanelReanudarPartida/PanelSeleccionPartida/ScrollContainer/contenedorPartidas, partida)
	

func actualizar_lista_amigos()->void:
	for amigo: Amigo in amigos_usando:
		amigo.queue_free()

	for amigo: Amigo in amigos:
		amigos_usando.append(Amigo.amigo(amigo.mi_icono, amigo.mi_nombre))
		globales.apropiar_hijo($PanelReanudarPartida/PanelSeleccionAmigos/ScrollContainer/contenedorAmigos, amigo)
