class_name SolicitudPendiente extends Control

@export var NombreSolicitante: RichTextLabel
static var escena_solicitud_pendiente: PackedScene = preload("res://proyecto_rummikub/menuInicio/solicitud_pendiente/solicitudPendiente.tscn")
var id : int

static func solicitud (nombre_solicitante: String, id_solicitante: int) -> SolicitudPendiente:
	var nueva_solicitud: SolicitudPendiente = escena_solicitud_pendiente.instantiate()
	nueva_solicitud.id = id_solicitante
	nueva_solicitud.NombreSolicitante.text = nombre_solicitante
	return nueva_solicitud


func _on_rechazar_pressed() -> void:
	ConectorRed.responder_solicitud(id,false)
	self.queue_free()



func _on_aceptar_pressed() -> void:
	ConectorRed.responder_solicitud(id,true)
	queue_free()
