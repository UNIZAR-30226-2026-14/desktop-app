class_name conector_red extends Node

signal perfil_actualizado

var username:String = "placeholder"
var password:String = "placeholder"

const siguiente_turno_manual: bool = false
const num_cartas_inicial: int = 14

var crea_ficha: Callable

static var singleton_instance: conector_red = null
var partida_en_curso: bool = false
var id_partida: int = -1

func _init() -> void:
	if singleton_instance == null:
		singleton_instance = self
	else:
		printerr("Trying to create another instance of MySingleton. Deleting it.")
		queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#if not is_queued_for_deletion():

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if partida_en_curso:
			await $red.salir_de_partida(id_partida)
		await $red.cerrar_sesion()
		get_tree().quit() # default behavior

#region DEBUG
func crear_amistades():
	$red.amigo_todos()
#endregion
#region INICIAR SESION
func iniciar_sesion(usr:String, passwd:String)->Error:
	password = passwd
	username = usr
	print(username)
	return await $red.inicia_sesion(usr,passwd)
	
func registrar_usuario(usr:String, passwd:String)->Error:
	password = passwd
	username = usr
	return await $red.registrar_usuario(usr,passwd)
#endregion
#region AMIGOS
func get_amigos(_amigos: Array[Amigo],_solicitud_env:Array[SolicitudEnviada],
				_solicitud_pen:Array[SolicitudPendiente], _retos:Array[RetoPendiente],
				mux: Mutex):
	var aux_amigos = []; var aux_env = []; var aux_reciv = []
	await $red.get_amigos(aux_amigos, aux_env, aux_reciv)
	mux.lock()
	
	_amigos.assign(aux_amigos.map(func(amigo):
		print(amigo["icono"])
		return Amigo.amigo(globales.get_avatar(amigo["icono"]), 
					amigo["nombre"],amigo["id"])) )
	_solicitud_env.assign(aux_env.map(func(amigo):
		return SolicitudEnviada.solicitud(amigo["nombre"])) )
	_solicitud_pen.assign(aux_reciv.map(func(amigo):
		return SolicitudPendiente.solicitud(amigo["nombre"], amigo["id"])) )
	mux.unlock()
	var aux = (await $red.get_retos()).map(func (reto):
		return RetoPendiente.solicitud(reto.emisor_nom,reto.emisor_id,reto.id_partida))
	mux.lock()
	_retos.assign(aux)
	mux.unlock()

@warning_ignore("shadowed_variable")
func rechazar_reto(id_partida:int, id_emisor:int):
	$red.rechazar_reto(id_partida,id_emisor)
func enviar_reto(id_amigo:int):
	$red.enviar_reto(id_amigo,id_partida)
	
func enviar_solicitud(amigo: int):
	$red.enviar_solicitud(amigo)
	
func responder_solicitud(amigo:int, acepta_solicitud: bool):
	if acepta_solicitud:
		$red.aceptar_solicitud(amigo)
	else:
		$red.denegar_solicitud(amigo)
#endregion
#region DURANTE PARTIDA
var mi_turno: int
##recibe_cartas toma las cartas del tablero como parametro
func espera_a_turno(recibe_cartas: Callable, fin_partida: Callable,partida_pausada: Callable) -> void:
	while true:
		var estado_partida = await $red.get_turno(id_partida)
		#print("fiTABLERO: ", estado_partida["mesa"], " TURNO: ",estado_partida["turno"])
		if estado_partida["estado"] == "FINISHED":
			print("partida finalizada")
			partida_en_curso = false
			fin_partida.call(estado_partida["ganadorId"],estado_partida["puntuacion"])
			return
		elif estado_partida["estado"] == "PAUSED":
			print("partida pausada")
			partida_pausada.call()
			return
		else: await recibe_cartas.call(estado_partida["mesa"])
		if estado_partida["turno"] == mi_turno and estado_partida["estado"]=="RUNNING":
			return

func paso_turno():
	await $red.pasar_turno_servidor(id_partida)

func hacer_jugada(tablero:Array[Grupo_fichas])->bool:
	if await $red.subir_jugada(id_partida, tablero):
		$red.ultimo_turno = -1
		return true
	else: 
		return false

func robar(receptor: Callable):
	var robada = await $red.robar_ficha(id_partida)
	$red.ultimo_turno = -1
	return receptor.call(robada["color"],robada["numero"] ) 

func robar_sin_pasar(receptor: Callable, num_fichas : int = 1)->Array:
	var robadas: Array = await $red.robar_fichas_sin_pasar(id_partida, num_fichas)
	return robadas.map(func(ficha):
		return receptor.call(ficha["color"],ficha["numero"]))

## devuelve mano inicial
func inicializar_partida(funcion_crea_fichas: Callable):
	crea_ficha = funcion_crea_fichas
	var info = await $red.info_inicial(id_partida, crea_ficha)
	mi_turno = info["turno"]
	return info["mano"]

func mano() -> Array[Ficha]:
	return  await $red.mano(id_partida)

#endregion
#region BUSCAR-INICIAR PARTIDA
static var imagen1: Texture2D = preload("res://imagenes/avatares_posibles/Miguel.png")
static var imagen2: Texture2D = preload("res://imagenes/avatares_posibles/Dian.png")
static var partida1: PartidaSeleccionable =  PartidaSeleccionable.partida_seleccionable("11/09/2001",[imagen1,imagen2,imagen1,imagen2],0)
static var partida2: PartidaSeleccionable =  PartidaSeleccionable.partida_seleccionable("5/09/2005",[imagen2,imagen1,imagen2,imagen1],0)
static var mis_partidas_en_curso: Array[PartidaSeleccionable] = [partida1, partida2, partida1, partida2, partida1] 
func unirse_a_partida_con_lobby(partida:int):
	var res = await $red.unirse_a_partida(partida)
	$red.creado_partida = false
	if not res is Error:
		id_partida = partida
	return res
func crear_partida_privada(es_arcade: bool):
	id_partida = await $red.crear_partida_publico(es_arcade)
	await $red.unirse_a_partida(id_partida)
	return id_partida
func esperar_comienzo_privada(status_busqueda:Label, iniciar: Button):
	await $red.espera_a_comienzo_partida(id_partida, status_busqueda, iniciar)

#devuelve false si cancelado se ha pulsado
func esperar_comienzo_cancelable(id,iniciar:Button,cancelar:Button):
	return await $red.espera_partida_cancelable(id,iniciar,cancelar)
	
func solo_inicia(id:int):
	if await $red.solo_inicia(id):
		id_partida = id
func buscar_partida(status_busqueda:Label, iniciar: Button, arcade: bool):
	id_partida = await $red.get_partidas(status_busqueda,arcade)
	await $red.unirse_a_partida(id_partida)
	await $red.espera_a_comienzo_partida(id_partida, status_busqueda, iniciar)
	partida_en_curso = true

func forzar_inicio_partida(): 
	$red.forzar_inicio_partida_set_true()

## cada diccionario tiene dos claves una con el valor: "nombre" asociada a un I con el nombre del adversario,
## y otra con el valor "icono" asociada a un Texture2D con el icono del adversario
func get_adversarios() -> Array[Dictionary]:
	return await $red.get_adversarios(id_partida)

func get_adversarios_con_id(id,solo_conectados) -> Array[Dictionary]:
	var res = await $red.get_adversarios(id)
	if solo_conectados:
		res = res.filter(func(adv): return adv["conectado"])
	return res
#endregion
#region CAMBIAR ESTADO PARTIDA
func parar_partida():
	if(partida_en_curso):
		await $red.pausar_partida(id_partida)
#endregion
#region COSMETICO
func cambia_perfil(icono: String):
	globales.set_avatar(icono)
	await $red.cambia_perfil(icono)
func _parse_tableros(skins:String):
	for skin: String in skins.split(","):
		if(skin != "" and skin[0] == "*"):
			globales.skin_tablero_equipada = skin.substr(1,-1)
			globales.mis_skins_tablero.push_back(globales.skin_tablero_equipada)
		elif skin != "":
			globales.mis_skins_tablero.push_back(skin)

func get_perfil():
	var perfil = await $red.get_perfil()
	globales.set_avatar(perfil["avatar"])
	globales.monedas = perfil["monedas"]
	_parse_tableros(perfil["tableros"])
	perfil_actualizado.emit()
func set_skins():
	await $red.set_perfil(globales.skin_tablero_equipada, globales.monedas)

#endregion
func cambiar_contrasena(contra_nueva: String, contra_vieja:String):
	if (await $red.cambiar_contrasena(contra_nueva,contra_vieja)):
		password = contra_nueva
		return true
	else: return false

#region BUSCAR PARTIDAS A MEDIAS
func get_reanudables()->Array[PartidaSeleccionable]:
	var partidas:Array[Dictionary]
	var res: Array[PartidaSeleccionable]
	partidas.assign( await $red.get_reanudables())
	printerr(partidas)
	for partida in partidas:
		var id = partida["id"]
		var fecha = partida["fecha"]
		var adv :Array[Texture2D]
		adv.assign(await  (await $red.get_adversarios(id)).map(
			func(adversario): return adversario["icono"]) )
		res.push_back( PartidaSeleccionable.partida_seleccionable(str(fecha),adv,id))

	printerr("numero de partidas: ", res.size())
	return res
	
func salirse_de_reanudable(id:int):
	if id != -1:
		$red.salirse_de_reanudable(id)

func unirse_a_reanudable(id:int):
	id_partida = id
	$red.unirse_a_reanudable(id)
