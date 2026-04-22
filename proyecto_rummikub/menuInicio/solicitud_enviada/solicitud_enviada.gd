class_name SolicitudEnviada extends Control

@export var nombre_usuario: RichTextLabel

static var escena_solicitud_enviada: PackedScene = preload("res://proyecto_rummikub/menuInicio/solicitud_enviada/solicitudEnviada.tscn")

static func solicitud (nombre: String) -> SolicitudEnviada:
	var nueva_solicitud: SolicitudEnviada = escena_solicitud_enviada.instantiate()

	nueva_solicitud.nombre_usuario.text = nombre
	return nueva_solicitud
