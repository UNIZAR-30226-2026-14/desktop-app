class_name BotonSelector extends Control
static var escena_boton_selector: PackedScene = preload("res://proyecto_rummikub/poder/selectorFicha/boton_selector/botonSelector.tscn")

@export var boton: Button

@export var tamano: Vector2
var identificador

signal pulsacion

static func boton_selector(tamano_in: Vector2, identificador_in, desvio_in: Vector2 = Vector2(0.0,0.0))->BotonSelector:
	var nuevo_boton_selector: BotonSelector = escena_boton_selector.instantiate()
	
	nuevo_boton_selector.tamano = tamano_in
	
	nuevo_boton_selector.custom_minimum_size = tamano_in
	nuevo_boton_selector.boton.custom_minimum_size = tamano_in
	
	nuevo_boton_selector.size = tamano_in
	nuevo_boton_selector.boton.size = tamano_in
	nuevo_boton_selector.position += tamano_in/2 + desvio_in
	
	nuevo_boton_selector.identificador = identificador_in
	
	return nuevo_boton_selector

func _ready() -> void:
	boton.toggled.connect(_pulsacion)

func _pulsacion(toggled:bool)->void:
	if toggled:
		pulsacion.emit(identificador)
