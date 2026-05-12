class_name PopUp extends Control

static var escena_ficha: PackedScene = preload("res://proyecto_rummikub/popUp/popUp.tscn")

var distancia_a_esquina: Vector2 
var largo: bool = false
static var anterior: PopUp = null

static func popUp(texto_in: String, posicion: Vector2, padre: Node, largo_in: bool = false) -> PopUp:
	var popUp_creado: PopUp = escena_ficha.instantiate()
	popUp_creado.largo = largo_in
	popUp_creado.text = texto_in
	popUp_creado.position = posicion
	globales.apropiar_hijo(padre, popUp_creado)
	if anterior != null:
		anterior.queue_free()
	anterior = popUp_creado
	return popUp_creado

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if largo:
		modulate -= Color(0,0,0,(0.1*delta))
	else:
		modulate -= Color(0,0,0,(0.2*delta))
	if modulate.a <= 0:
		anterior = null
		self.queue_free()
