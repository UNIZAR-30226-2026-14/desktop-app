extends Panel

@export var botonAmigos: Button
@export var botonCerrarPestanaAmigos: Button

var amigos: Array[Amigo] = []#[Amigo.amigo(preload("res://imagenes/avatares_posibles/Miguel.png"), "Miguel"), Amigo.amigo(preload("res://imagenes/avatares_posibles/Dian.png"), "Dian")]
var enviadas: Array[SolicitudEnviada] = [SolicitudEnviada.solicitud("Miguel"), SolicitudEnviada.solicitud("Dian")]
var pendientes: Array[SolicitudPendiente] = [SolicitudPendiente.solicitud("Miguel",-1), SolicitudPendiente.solicitud("Dian",-1)]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	botonAmigos.pressed.connect(_sacar_amigos)
	botonCerrarPestanaAmigos.pressed.connect(_cerrar_amigos)
	$MenuAnadirAmigo.visible = false
	amigos_actualizado()

func amigos_actualizado():
	while true:
		print("amigos actualizado")
		await ConectorRed.get_amigos(amigos, enviadas, pendientes)
		var arbol = get_tree()
		if arbol != null:
			await arbol.create_timer(1.5).timeout

func get_amigos():
	return amigos

func _sacar_amigos() -> void:
	$BotonPendientes.text = "Pendientes(" + str(pendientes.size()) + ")\n⎯⎯⎯⎯⎯⎯⎯⎯"
	$BotonAmigos.text = "Amigos(" + str(amigos.size()) + ")\n⎯⎯⎯⎯⎯⎯⎯⎯"
	$BotonEnviadas.text = "Enviadas(" + str(enviadas.size()) + ")\n⎯⎯⎯⎯⎯⎯⎯⎯"
	self.visible = true
	$BotonAmigos.button_pressed = true

func _cerrar_amigos() -> void:
	self.visible = false

func _on_boton_amigos_toggled(toggled_on: bool) -> void:
	$BotonAmigos.text = "Amigos(" + str(amigos.size()) + ")\n⎯⎯⎯⎯⎯⎯⎯⎯"
	if toggled_on:
		$BotonAmigos.modulate = "338bc8"
		for amigo in amigos:
			if(amigo != null ):
				amigo.visible = true
				globales.apropiar_hijo($ScrollContainer/contenedorAmigos,amigo )
	else:
		$BotonAmigos.modulate = "dfdfdf"
		for amigo in amigos:
			if(amigo != null ):
				amigo.visible = false

func _on_boton_pendientes_toggled(toggled_on: bool) -> void:
	$BotonPendientes.text = "Pendientes(" + str(pendientes.size()) + ")\n⎯⎯⎯⎯⎯⎯⎯⎯"
	if toggled_on:
		$BotonPendientes.modulate = "338bc8"
		for pendiente in pendientes:
			if(pendiente != null ):
				pendiente.visible = true
				globales.apropiar_hijo($ScrollContainer/contenedorAmigos,pendiente)
	else:
		$BotonPendientes.modulate = "dfdfdf"
		for pendiente in pendientes:
			if(pendiente != null ):
				pendiente.visible = false

func _on_boton_enviadas_toggled(toggled_on: bool) -> void:
	$BotonEnviadas.text = "Enviadas(" + str(enviadas.size()) + ")\n⎯⎯⎯⎯⎯⎯⎯⎯"
	if toggled_on:
		$BotonEnviadas.modulate = "338bc8"
		for enviada in enviadas:
			if(enviada != null ):
				enviada.visible = true
				globales.apropiar_hijo($ScrollContainer/contenedorAmigos,enviada)
	else:
		$BotonEnviadas.modulate = "dfdfdf"
		for enviada in enviadas:
			if(enviada != null ):
				enviada.visible = false


func _on_boton_anadir_amigo_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$MenuAnadirAmigo.visible = true
	else:
		$MenuAnadirAmigo.visible = false

func _on_boton_enviar_solicitud_pressed() -> void:
	if $MenuAnadirAmigo/InsertorIdNuevoAmigo.text != "":
		ConectorRed.enviar_solicitud(int($MenuAnadirAmigo/InsertorIdNuevoAmigo.text))
		$MenuAnadirAmigo.visible = false
		$BotonAnadirAmigo.button_pressed = false
		$MenuAnadirAmigo/InsertorIdNuevoAmigo.text = ""
		$BotonAmigos.button_pressed = true
		
func _on_boton_volver_toggled(_toggled_on: bool) -> void:
	$MenuAnadirAmigo.visible = false
	$MenuAnadirAmigo/InsertorIdNuevoAmigo.text = ""
	$BotonAmigos.button_pressed = true
