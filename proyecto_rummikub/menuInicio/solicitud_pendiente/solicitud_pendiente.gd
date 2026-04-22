class_name SolicitudPendiente extends Control

@export var NombreSolicitante: RichTextLabel
static var escena_solicitud_pendiente: PackedScene = preload("res://proyecto_rummikub/menuInicio/solicitud_pendiente/solicitudPendiente.tscn")

static func solicitud (nombre_solicitante: String) -> SolicitudPendiente:
	var nueva_solicitud: SolicitudPendiente = escena_solicitud_pendiente.instantiate()
	nueva_solicitud.NombreSolicitante.text = nombre_solicitante
	return nueva_solicitud
