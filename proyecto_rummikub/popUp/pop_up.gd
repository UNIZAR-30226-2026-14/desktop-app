class_name PopUp extends Control

static var escena_ficha: PackedScene = preload("res://proyecto_rummikub/popUp/popUp.tscn")

var distancia_a_esquina: Vector2 

static func popUp(texto_in: String, posicion: Vector2, padre: Node) -> PopUp:
	var popUp_creado: PopUp = escena_ficha.instantiate()
	popUp_creado.text = texto_in
	popUp_creado.position = posicion
	globales.apropiar_hijo(padre, popUp_creado)
	return popUp_creado


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	modulate -= Color(0,0,0,(0.2*delta))
	if modulate.a <= 0:
		self.queue_free()
