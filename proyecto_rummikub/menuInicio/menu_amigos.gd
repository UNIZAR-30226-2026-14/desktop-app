extends Panel

@export var botonAmigos: Button
@export var botonCerrarPestanaAmigos: Button

var amigos: Array[Amigo] = [Amigo.amigo(preload("res://imagenes/avatares_posibles/Miguel.png"), "Miguel"), Amigo.amigo(preload("res://imagenes/avatares_posibles/Dian.png"), "Dian")]
var enviadas: Array[SolicitudEnviada] = [SolicitudEnviada.solicitud("Miguel"), SolicitudEnviada.solicitud("Dian")]
var pendientes: Array[SolicitudPendiente] = [SolicitudPendiente.solicitud("Miguel",-1), SolicitudPendiente.solicitud("Dian",-1)]
var invitaciones: Array[RetoPendiente] = [RetoPendiente.solicitud("Dian",0,0), RetoPendiente.solicitud("Miguel",0,0)]

var accesoListas: Mutex = Mutex.new()

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
		await ConectorRed.get_amigos(amigos, enviadas, pendientes, invitaciones, accesoListas)
		var arbol = get_tree()
		if arbol != null:
			await arbol.create_timer(1.5).timeout

func get_amigos():
	return amigos

func _sacar_amigos() -> void:
	$BotonPendientes.text = "   Pendientes(" + str(pendientes.size()) + ")\n⎯⎯⎯⎯⎯⎯⎯"
	$BotonAmigos.text = "Amigos(" + str(amigos.size()) + ")\n⎯⎯⎯⎯⎯"
	$BotonEnviadas.text = "Enviadas(" + str(enviadas.size()) + ")\n⎯⎯⎯⎯⎯⎯⎯"
	$BotonInvitaciones.text = "Invitaciones(" + str(invitaciones.size()) + ")\n⎯⎯⎯⎯⎯⎯⎯" 
	self.visible = true
	$BotonAmigos.button_pressed = true

func _cerrar_amigos() -> void:
	self.visible = false


func _on_boton_amigos_toggled(toggled_on: bool) -> void:
	$BotonAmigos.text = "Amigos(" + str(amigos.size()) + ")\n⎯⎯⎯⎯⎯"
	if toggled_on:
		$BotonAmigos.modulate = "338bc8"
		accesoListas.lock()
		for amigo in amigos:
			if(amigo != null ):
				amigo.visible = true
				globales.apropiar_hijo($ScrollContainer/contenedorAmigos,amigo)
		accesoListas.unlock()
	else:
		$BotonAmigos.modulate = "dfdfdf"
		accesoListas.lock()
		for elemento in $ScrollContainer/contenedorAmigos.get_children():
			elemento.queue_free()
		accesoListas.unlock()

func _on_boton_pendientes_toggled(toggled_on: bool) -> void:
	$BotonPendientes.text = "   Pendientes(" + str(pendientes.size()) + ")\n⎯⎯⎯⎯⎯⎯⎯"
	if toggled_on:
		$BotonPendientes.modulate = "338bc8"
		accesoListas.lock()
		for pendiente in pendientes:
			if(pendiente != null ):
				pendiente.visible = true
				globales.apropiar_hijo($ScrollContainer/contenedorAmigos,pendiente)
		accesoListas.unlock()
	else:
		$BotonPendientes.modulate = "dfdfdf"
		accesoListas.lock()
		for elemento in $ScrollContainer/contenedorAmigos.get_children():
			elemento.queue_free()
		accesoListas.unlock()

func _on_boton_enviadas_toggled(toggled_on: bool) -> void:
	$BotonEnviadas.text = "Enviadas(" + str(enviadas.size()) + ")\n⎯⎯⎯⎯⎯⎯⎯"
	if toggled_on:
		$BotonEnviadas.modulate = "338bc8"
		accesoListas.lock()
		for enviada in enviadas:
			if(enviada != null ):
				enviada.visible = true
				globales.apropiar_hijo($ScrollContainer/contenedorAmigos,enviada)
		accesoListas.unlock()
	else:
		$BotonEnviadas.modulate = "dfdfdf"
		accesoListas.lock()
		for elemento in $ScrollContainer/contenedorAmigos.get_children():
			elemento.queue_free()
		accesoListas.unlock()

func _on_boton_invitaciones_toggled(toggled_on: bool) -> void:
	$BotonInvitaciones.text = "Invitaciones(" + str(invitaciones.size()) + ")\n⎯⎯⎯⎯⎯⎯⎯" 
	if toggled_on:
		$BotonInvitaciones.modulate = "338bc8"
		accesoListas.lock()
		for invitacion in invitaciones:
			invitacion.visible = true
			invitacion.aceptar_reto.connect(_on_reto_aceptado)
			globales.apropiar_hijo($ScrollContainer/contenedorAmigos,invitacion)
		accesoListas.unlock()
	else:
		$BotonInvitaciones.modulate = "dfdfdf"
		accesoListas.lock()
		for elemento in $ScrollContainer/contenedorAmigos.get_children():
			elemento.queue_free()
		accesoListas.unlock()

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
	
func _on_reto_aceptado(id_partida:int):
		var res = await ConectorRed.unirse_a_partida_con_lobby(id_partida)
		if res is Error:
			if res == Error.ERR_DOES_NOT_EXIST: PopUp.popUp("La partida no existe",Vector2(550,16),$"..")
			elif res: PopUp.popUp("Ha habido un error \nal unirse a la partida",Vector2(550,16),$"..")
		else: 
			$"../FondoLobby".visible = true
			$"../FondoLobby/PanelCreacionPartidaPrivada".mostrar(false,res,id_partida)

	
	
