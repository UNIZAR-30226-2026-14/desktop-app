class_name RetoPendiente extends Control
signal aceptar_reto
@export var NombreSolicitante: RichTextLabel
static var escena_solicitud_pendiente: PackedScene = preload("res://proyecto_rummikub/menuInicio/solicitud_pendiente_reto/solicitudPendienteReto.tscn")
var id_partida : int
var id_solicitante: int

@warning_ignore("shadowed_variable")
static func solicitud (nombre_solicitante: String, id_solicitante:int, id_partida: int) -> RetoPendiente:
	var nueva_solicitud: RetoPendiente = escena_solicitud_pendiente.instantiate()
	nueva_solicitud.id_partida = id_partida
	nueva_solicitud.id_solicitante = id_solicitante
	nueva_solicitud.NombreSolicitante.text = nombre_solicitante
	return nueva_solicitud

func _on_rechazar_pressed() -> void:
	ConectorRed.rechazar_reto(id_partida,id_solicitante)
	self.queue_free()

func _on_aceptar_pressed() -> void:
	aceptar_reto.emit(id_partida)
	queue_free()
