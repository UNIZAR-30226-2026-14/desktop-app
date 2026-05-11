extends Control
class_name PartidaSeleccionable

@export var fecha_partida: RichTextLabel

@export var jugador1: MarcoIcono
@export var jugador2: MarcoIcono
@export var jugador3: MarcoIcono
@export var jugador4: MarcoIcono

signal partida_seleccionada

var mi_fecha: String 
var mi_iconos_jugadores: Array[Texture2D]

static var escena_partida_seleccionable: PackedScene = preload("res://proyecto_rummikub/menuInicio/partidaSeleccionable/partidaSeleccionable.tscn")

## iconos_jugadores tiene que tener al menos 4 imagenes
static func partida_seleccionable (fecha: String, iconos_jugadores: Array[Texture2D]) -> PartidaSeleccionable:
	var nueva_partida_seleccionable: PartidaSeleccionable = escena_partida_seleccionable.instantiate()
	
	nueva_partida_seleccionable.fecha_partida.text = fecha
	
	nueva_partida_seleccionable.mi_fecha = fecha
	for i: Texture2D in iconos_jugadores:
		nueva_partida_seleccionable.mi_iconos_jugadores.append(i)
	
	return nueva_partida_seleccionable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	jugador1.cambiar_icono(mi_iconos_jugadores[0])
	jugador2.cambiar_icono(mi_iconos_jugadores[1])
	jugador3.cambiar_icono(mi_iconos_jugadores[2])
	jugador4.cambiar_icono(mi_iconos_jugadores[3])
	
	$Button.toggled.connect(_procesar_toggle)


func _procesar_toggle(toggled: bool) -> void:
	if toggled:
		partida_seleccionada.emit(self)
