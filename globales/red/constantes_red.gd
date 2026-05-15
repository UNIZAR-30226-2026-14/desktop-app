extends Node

#region constantes
static var base_url: String = "https://rummiplus.onrender.com"
static var jugadores: String = "/api/jugadores"
static var perfil: String = "/perfil"
static var partidas: String = "/api/partidas"
static var participaciones: String = "/api/participaciones"
static var participiaciones_por_partida: String = "/api/participaciones?partidaId="
static var iniciar_partida: String = "/iniciar"
#static var pasar_turno: String = "/siguiente-turno"

static var id_partida = "idPartida"
static var turno = "turno"
static var fecha = "fecha"
static var mercado = "mercado"
static var bolsa_robar = "bolsa"
static var mesa = "conjuntoMesa"
static var partida_empezada = "corriendo"
static var turno_inicio = "turnoInicio"
static var estado_partida = "estado"

static var id_jugador = "idJugador"
static var num_fichas_mano = "fichasActuales"
static var fichas_mano = "manoActual"

const DORADO_RED = "D"
const ARCOIRIS_RED = ""
const ROJO_RED="R"
const NEGRO_RED = "K"
const AZUL_RED = "B"
const NARANJA_RED = "O"
const JOKER_RED = "J"

const ESTADO_PARTIDA_SIN_EMPEZAR="WAITING"
const ESTADO_PARTIDA_PAUSADA="PAUSED"
const ESTADO_PARTIDA_EMPEZADA="RUNNING"
const ESTADO_PARTIDA_TERMINADA="FINISHED"
#endregion
#region generales
## Indica que ha creado una partida que aún no ha empezado, uso interno
var creado_partida: bool = false
## Uso interno, ultima info de partida en la que estamos, debería ser un dict
var ultima_info_partida

var mi_id: int = -1
var mi_token = null

var forzar_inicio_partida: bool = false

func _ready() -> void:
	$HTTPRequest.request_completed.connect(_recibe_respuesta_json)
	login_timer = Timer.new()
	self.add_child(login_timer)
#endregion
#region debug
func amigo_todos():
	await _awaiting_request_get(base_url+jugadores)
	var amistades = json.data.map(func(jug): return jug.id)
	for amigo in amistades:
		print(amigo)
		if amigo != mi_id:
			await _awaiting_request(base_url+amigos,{amis1:mi_id,amis2:amigo,"estado":"ACEPTADO","fecha":"2026-04-05"},
			HTTPClient.METHOD_POST,header())
			print(json.data)
			if not _respuesta_buena(): push_error("Error al añadir amigo")
#endregion
#region auxiliares
func header()->PackedStringArray:
	return PackedStringArray(["Authorization: Bearer "+mi_token, "Content-Type: application/json"])

func ficha_to_string(ficha:Ficha)->String:
	var res: String = ""
	if ficha.color == Ficha.COLOR.COMODIN:
		return JOKER_RED + "*"
	match ficha.color:
		Ficha.COLOR.ROJO:
			res = ROJO_RED 
		Ficha.COLOR.AZUL:
			res = AZUL_RED
		Ficha.COLOR.NEGRO:
			res = NEGRO_RED 
		Ficha.COLOR.AMARILLO:
			res = NARANJA_RED 
	var especial = ""
	match ficha.especial:
		Ficha.ESPECIAL.ARCOIRIS: especial = "A"
		Ficha.ESPECIAL.DORADO: especial = "D"
	return res + str(ficha.numero)+especial
	

## Resultado arrays de arrays de Ficha.GuardaFicha
func string_to_grupos(s:String)->Array:
	var res = []
	var grupos = []
	if s != "": grupos = s.split(";")
	for grupo in grupos:
		var fichas = grupo.split(",")
		var grup = []
		for ficha in fichas:
			var fich = string_to_ficha(ficha)
			grup.append(fich)#Ficha.GuardaFicha.new(fich["numero"], fich["color"]))
		res.append(grup)
	
	return res

func string_to_poder(s:String)->Poder.PODER:
	match s:
		"GUARDIAN_ANGEL": 
			return Poder.PODER.ANGEL_GUARDA
		"CRYSTAL_BALL": 
			return Poder.PODER.BOLA_CRISTAL
		"MIDAS_TOUCH": 
			return Poder.PODER.TOQUE_MIDAS
		"PLUS_FOUR": 
			return Poder.PODER.MAS_CUATRO
		"SWAP_ON_FAIL": 
			return Poder.PODER.TRUEQUE
		"WHITE_GLOVE": 
			return Poder.PODER.GUANTE_BLANCO
		"SMOKE_BOMB": 
			return Poder.PODER.BOMBA_HUMO
		"CHILI_PEPPER": 
			return Poder.PODER.REDUCIR_TIEMPO
		"GLASS_CEILING": 
			return Poder.PODER.TECHO_CRISTAL
		_:
			return Poder.PODER.NINGUNO

func string_to_poderes(poderes:Array)->Array:
	var s_poderes : Array = poderes.map(
		func(poder) : return poder["codigo"])
	return s_poderes.map(string_to_poder)
	
## Resultado con claves "color" y "numero"
func string_to_ficha(s:String) -> Dictionary:
	s=s.to_upper()
	var res = {}
	res["especial"] = Ficha.ESPECIAL.NO
	if s.length() >= 4:
		if s[3] == DORADO_RED:
			res["especial"] = Ficha.ESPECIAL.DORADO
		elif s[3] == ARCOIRIS_RED:
			res["especial"] = Ficha.ESPECIAL.ARCOIRIS
	
	if s[0] == JOKER_RED:
		res["color"] = Ficha.COLOR.COMODIN 
		res["numero"] = 10
		return res
	
	match s[0]:
		ROJO_RED:
			res["color"] = Ficha.COLOR.ROJO
		AZUL_RED:
			res["color"] = Ficha.COLOR.AZUL
		NEGRO_RED:
			res["color"] = Ficha.COLOR.NEGRO
		NARANJA_RED:
			res["color"] = Ficha.COLOR.AMARILLO
	res["numero"] = s.substr(1,2).to_int()
	return res


var codigo_respuesta: int
var textura: ImageTexture = ImageTexture.new()

var json = JSON.new()
func _recibe_respuesta_json(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	codigo_respuesta = response_code
	if result != HTTPRequest.RESULT_SUCCESS:
		assert(false,"codigo de error en http request: Error " + str(result))
	if Error.OK != json.parse(body.get_string_from_utf8()):
		assert(false,"Error al leer cuerpo")
@warning_ignore("shadowed_variable")
func _awaiting_request_get(url:String, header:PackedStringArray = PackedStringArray()):
	if $HTTPRequest.request(url, header) == ERR_BUSY:
		await $HTTPRequest.request_completed
		await _awaiting_request_get(url,header)
	else:
		ultima_request = url
		await $HTTPRequest.request_completed

var ultima_request
##Body puede ser diccionario o array, se convierte a string dentro de esta funcion
@warning_ignore("shadowed_variable")
func _awaiting_request(url:String, body, metodo:HTTPClient.Method, header:PackedStringArray = PackedStringArray(["Content-Type: application/json"])):
	print("POST ", url, ", Cuerpo: ",JSON.stringify(body), ", Cabecera: ",header)
	
	if $HTTPRequest.request(url,header,metodo,JSON.stringify(body)) == ERR_BUSY:
		await $HTTPRequest.request_completed
		await _awaiting_request(url,body,metodo,header)
	else:
		ultima_request = url
		await $HTTPRequest.request_completed

## acaba toma el valor de hacer get url y  debe devolver un bool que será true
## cuando se den las condiciones para acabar la espera
func _espera_a_resultado(acaba: Callable, url: String, polling_time: float = 0.5):
	await _awaiting_request_get(url,header())
	var timer = Timer.new()
	self.add_child(timer)
	while !acaba.call(json.data):
		timer.start(polling_time)
		await timer.timeout
		await _awaiting_request_get(url,header())
	timer.free()
	
func _respuesta_buena() -> bool:
	return codigo_respuesta >= 200 and codigo_respuesta < 300
#endregion
#region amigos
const nom_jugador = "nombre"
const imagen_perfil ="imagenPerfil"
const amigos = "/api/amigos"
const amigos_de_jugador = "/api/amigos?jugadorId="
const perfiles_de_amigos = "/amigos/perfiles"
const amis1 = "jugador1Id"
const amis2 = "jugador2Id"
const estado_amis = "estado"
const estado_aceptado = "ACEPTADO"
const estado_pendiente = "PENDIENTE"
const amigo_nom = "nombre"
const amigo_icono = "imagenPerfil"
const es_arcade = "modoArcade"
const es_privada = "privada"

func categoriza_solicitudes(_aceptadas,_enviadas,_recibidas):
	var todos_amigos = json.data
	var solic_pendientes_env: Array = todos_amigos.filter(func(amistad):
		return amistad[amis1] == mi_id\
		and amistad[estado_amis] == estado_pendiente )
	var solic_pendientes_reciv: Array = todos_amigos.filter(func(amistad):
		return  amistad[amis2] == mi_id \
		and amistad[estado_amis] == estado_pendiente)
	var solic_aceptadas: Array = todos_amigos.filter(func(amistad):
		return (amistad[amis1] == mi_id or amistad[amis2] == mi_id) \
		and amistad[estado_amis] == estado_aceptado)
		
	_enviadas.assign(solic_pendientes_env.map(func(amistad):
		return amistad[amis2]) )
	_recibidas.assign(solic_pendientes_reciv.map(func(amistad):
		return amistad[amis1]) )
	_aceptadas.assign(solic_aceptadas.map(func(amistad):
		if amistad[amis1]==mi_id: return amistad[amis2]
		else: return amistad[amis1] ) )
	pass

## Campos return: "icono", "nombre", "conectado"
func get_amigos(_aceptadas,_enviadas,_recibidas):
	await _awaiting_request_get(base_url+amigos,header())
	assert(_respuesta_buena(),json.data)
	var aux_aceptadas = []; var aux_enviadas = []; var aux_recibidas = []
	categoriza_solicitudes(aux_aceptadas,aux_enviadas,aux_recibidas)
	
	await _awaiting_request_get(base_url+jugadores+"/"+str(mi_id)+perfiles_de_amigos,header())
	if _respuesta_buena():
		@warning_ignore("shadowed_variable")
		var amigos: Array[Dictionary]
		amigos.assign(json.data)
		print(json.data)
		amigos.assign(amigos.map(func(amigo)->Dictionary:
			print("un amigo")
			return {"icono":amigo[amigo_icono],"nombre":amigo[amigo_nom],
			"id":amigo["id"] }))
		for grupo in [aux_aceptadas,aux_enviadas,aux_recibidas]:
			grupo.assign(amigos.filter(func(amigo):return amigo["id"] in grupo))
		_aceptadas.assign(aux_aceptadas)
		_enviadas.assign(aux_enviadas)
		_recibidas.assign(aux_recibidas)

func enviar_solicitud(amigo: int):
	var cuerpo = {amis1:mi_id,amis2:amigo,estado_amis:estado_pendiente}
	await _awaiting_request(base_url+amigos,cuerpo,HTTPClient.METHOD_POST,header())
	assert(_respuesta_buena())
	
func aceptar_solicitud(amigo:int):
	await _awaiting_request(base_url+amigos+"/"+str(amigo)+"/"+str(mi_id)+"/estado",
	{estado_amis:estado_aceptado}
	,HTTPClient.METHOD_PATCH,header())
	assert(_respuesta_buena(),json.data)

func denegar_solicitud(_amigo:int):
	pass

#endregion
#region inicio sesion
const inicio_sesion = "/api/auth/login"
const login_nom_usuario = "nombre"
const login_passw = "contrasena"
const login_token = "token"
const login_expiracion = "expiraEn"
const login_jugador = "jugador"
const login_id = "id"

var guarda_nom:String
var guarda_con:String

var login_timer:Timer 

func registrar_usuario(nombre: String, contrasena: String) -> Error:
	await _awaiting_request(base_url+jugadores,{login_nom_usuario:nombre,login_passw:contrasena,imagen_perfil:"dani"},HTTPClient.METHOD_POST)
	if _respuesta_buena():
		print("Bien", json.data)
		return Error.OK
	else:
		printerr("Error al registrar",json.data)
		return Error.FAILED
func reinicia_sesion(nombre, contrasena):
	while true:
		await _awaiting_request(base_url+inicio_sesion, {login_nom_usuario:nombre, login_passw:contrasena}, HTTPClient.METHOD_POST)
		var res = json.data
		mi_token = res[login_token]
		mi_id = res[login_jugador][login_id]
		var tiempo = Time.get_unix_time_from_datetime_string(res[login_expiracion]) - Time.get_unix_time_from_system()
		login_timer.start(10)
		#login_timer.start(tiempo)
		await login_timer.timeout
		print(tiempo)

func inicia_sesion(nombre: String, contrasena: String) -> Error:
	guarda_con = contrasena
	guarda_nom = nombre
	await _awaiting_request(base_url+inicio_sesion, {login_nom_usuario:nombre, login_passw:contrasena}, HTTPClient.METHOD_POST)
	if _respuesta_buena():
		globales.set_avatar(json.data[login_jugador][imagen_perfil])
		reinicia_sesion(nombre,contrasena)
		return Error.OK
	else:
		printerr("Error al iniciar sesion",json.data)
		return Error.FAILED
func cerrar_sesion():
	await _awaiting_request(base_url+inicio_sesion+"/logout",{},HTTPClient.METHOD_POST,header())
#endregion
var ultimo_turno = -1
#region iniciar partida
func unirse_a_partida(id: int):
	print("Busco partida: ", id)
	await _awaiting_request_get(base_url+partidas+"/"+str(id),header())
	if not _respuesta_buena():
		printerr(json.data)
		print("partida no existe")
		return Error.ERR_DOES_NOT_EXIST
	var partida: Dictionary = json.data
	
	if (partida.get(id_partida) == id) \
			and partida[estado_partida] == ESTADO_PARTIDA_SIN_EMPEZAR:
		print("Me uno a partida")
		ultima_info_partida = partida
		var participacion = {id_jugador:mi_id, id_partida:partida[id_partida]}
		await _awaiting_request(base_url+participaciones,participacion,HTTPClient.METHOD_POST,header())
		if not _respuesta_buena():
			push_error("Falla envio de participacion: ", json.data)
			print(participacion)
			return Error.FAILED
		ultimo_turno = -1
		return partida[es_arcade]
	# casos de error
	elif partida[estado_partida] != ESTADO_PARTIDA_SIN_EMPEZAR:
		push_error("En unirse a partida, partida ya empezada")
		return Error.ERR_BUSY
	elif partida.find_key(id_partida) != id_partida or partida[id_partida] == id:
		push_error("En unirse a partida, Partida no existe")
		return Error.ERR_CANT_CONNECT
	return Error.ERR_BUG

var cancelada: bool
var forzar_reanudar:bool
func reanudar_partida_set_true():
	forzar_reanudar = true
func cancelar_busqueda():
	cancelada = true
var maximos_jugadores: int = 4
var status_label: Label
func check_iniciar_partida_calncelable(res): 
	return forzar_reanudar or cancelada or (res[estado_partida]==ESTADO_PARTIDA_EMPEZADA )
# devuelve false si y solo si la busqueda de partida es cancelada
func espera_partida_cancelable(id:int,iniciar:Button,cancelar:Button):
	maximos_jugadores = 4
	forzar_reanudar = false
	cancelada = false
	iniciar.visible = true
	iniciar.pressed.connect(reanudar_partida_set_true)
	cancelar.pressed.connect(cancelar_busqueda)
	await _espera_a_resultado(check_iniciar_partida_calncelable,\
		base_url+partidas+"/"+str(id))
	creado_partida = false
	forzar_inicio_partida = false
	iniciar.visible = false
	iniciar.pressed.disconnect(reanudar_partida_set_true)
	cancelar.pressed.disconnect(cancelar_busqueda)
	return not cancelada
func solo_inicia(id:int):
	await _awaiting_request(base_url+partidas+"/"+str(id)+iniciar_partida,{},HTTPClient.METHOD_POST,header())
	return _respuesta_buena()
	

func forzar_inicio_partida_set_true():
	forzar_inicio_partida = true
func check_iniciar_partida(res): 
	var texto = "Oponentes en partida: "
	if res is Array: texto += str(res.size() - 1)
	else : texto += "0"
	if (status_label != null):
		status_label.text = texto
	return forzar_inicio_partida or (res is Array and res.size() == maximos_jugadores)
func espera_a_comienzo_partida(id: int, status_busqueda:Label, iniciar: Button,
			 max_jugadores: int=4,)->void:
	maximos_jugadores = max_jugadores
	status_label = status_busqueda
	if creado_partida:
		iniciar.visible = true
		iniciar.pressed.connect(forzar_inicio_partida_set_true)
		await _espera_a_resultado(check_iniciar_partida,\
			base_url+participiaciones_por_partida+str(id))
		if status_label != null:
			status_label.text = "Iniciando partida"
		await _awaiting_request(base_url+partidas+"/"+str(id)+iniciar_partida,{},HTTPClient.METHOD_POST,header())
		if status_label != null:
			status_label.text = "Partida iniciada"
		print("RECIBIDO DE INICIAR PARTIDA",json.data)
		creado_partida = false
		forzar_inicio_partida = false
		iniciar.visible = false
		iniciar.pressed.disconnect(forzar_inicio_partida_set_true)
	else:
		print("espero, no he creado partida")
		await _espera_a_resultado(func(dic:Dictionary): return dic[partida_empezada] ,base_url+partidas+"/"+str(id)) 
	ultima_info_partida = json.data

##Busca partida y devuelve su id, que termine no asegura que la partida haya empezado
func get_partidas(status_busqueda:Label, arcade: bool) -> int:
	await _awaiting_request_get(base_url+partidas,header())
	var body = json.data
	creado_partida = false
	if body is Array: # varias partidas
		for partida in body:
			print(partida)
			if partida[estado_partida] == ESTADO_PARTIDA_SIN_EMPEZAR and partida[es_arcade] == arcade \
			and not partida[es_privada]:
				print("encontrada la partida ", partida[id_partida])
				status_busqueda.text = "Partida encontrada"
				ultima_info_partida = partida
				return ultima_info_partida[id_partida]
	elif body is Dictionary:# una partida
		print(body)
		if body[estado_partida] == ESTADO_PARTIDA_SIN_EMPEZAR and body[es_arcade] == arcade \
			and not body[es_privada]:
			print("encontrada partida ", body[id_partida])
			ultima_info_partida = body
			status_busqueda.text = "Partida encontrada"
			return ultima_info_partida[id_partida]
	elif body == null:
		status_busqueda.text = "No hay partidas libres"
		print("no hay partidas")
	else:
		assert(false, "body con estructura o tipo inesperado en get_partidas: " + str(body))
	
	ultima_info_partida = await _crear_partida(arcade)
	status_busqueda.text = "Partida creada"
	return ultima_info_partida[id_partida]

func _crear_partida(arcade:bool) -> Dictionary:
	creado_partida = true
	print("crear partida ")
	var partida = {fecha:Time.get_date_string_from_system(), es_arcade:arcade,es_privada:false}
	await _awaiting_request(base_url+partidas,partida,HTTPClient.METHOD_POST,header())
	if not _respuesta_buena():
		printerr("Error creando partida, recibido:", json.data)
		assert(false, "Error creando partida")
	return json.data

func crear_partida_publico(arcade: bool):
	creado_partida = true
	print("crear partida ")
	var partida = {fecha:Time.get_date_string_from_system(), es_arcade:arcade,es_privada:true}
	await _awaiting_request(base_url+partidas,partida,HTTPClient.METHOD_POST,header())
	assert(_respuesta_buena(), "Error creando partida, recibido: " + str(json.data) )
	ultima_info_partida = json.data
	return ultima_info_partida[id_partida]
#endregion
#region parar y reanudar partida
const reanudables = "/api/invitaciones?idInvitado="
const reanudables2 = "&includeInProgress=true"
const conexion_reanudable = "/conexion"
func get_reanudables():
	await _awaiting_request_get(base_url+reanudables+str(mi_id)+reanudables2,header())
	assert(_respuesta_buena(),json.data)
	return json.data["partidasEnCurso"].map(func(partida):
		return {"id":partida[id_partida],"fecha":partida[fecha]})
	
func unirse_a_reanudable(id:int):
	await _awaiting_request(base_url+participaciones+"/"+str(mi_id)+"/"+str(id)+conexion_reanudable,
	{"conectado":true},HTTPClient.METHOD_PATCH,header())
	assert(_respuesta_buena(),json.data)

func salirse_de_reanudable(id:int):
	await _awaiting_request(base_url+participaciones+"/"+str(mi_id)+"/"+str(id)+conexion_reanudable,
	{"conectado":false},HTTPClient.METHOD_PATCH,header())
	assert(_respuesta_buena(),json.data)
func continuar_partida(id:int):
	await _awaiting_request(base_url+partidas+"/"+str(id)+"/"+"reanudar",{},HTTPClient.METHOD_POST,header())
	assert(_respuesta_buena(),json.data)

func parar_partida(id:int):
	await _awaiting_request(base_url+partidas+"/"+str(id)+"/"+"pausar",{},HTTPClient.METHOD_POST,header())
	assert(_respuesta_buena(),json.data)
#endregion
#region partida
const partic_mano = "manoActual"
const partic_turno = "ordenTurno"
const partida_robar = "/robar"
const partida_robar_sin_pasar = "/solo-robar"
const partida_jugar = "/jugar-avanzado"
const jugar_tipo = "moveType"
const jugar_tipo_cambio_tablero = "replace_board"
const jugar_tablero = "newBoard"
const partida_pasar = "/pasar"

## cada diccionario tiene dos claves una con el valor: "nombre" asociada a un String con el nombre del adversario,
## y otra con el valor "icono" asociada a un Texture2D con el icono del adversario
func get_adversarios(id: int) -> Array[Dictionary]:
	await _awaiting_request_get(base_url+participiaciones_por_partida+str(id))
	assert(_respuesta_buena())
	var aux :Array[Dictionary] = []
	for i in json.data.size():
		print(i, " imagen ", json.data[i]["jugadorImagenPerfil"])
	aux.assign( json.data.map(func(part)->Dictionary:
		return {"nombre":part["jugadorNombre"], "icono":globales.get_avatar(part["jugadorImagenPerfil"]),
				"id":part["idJugador"],"conectado":part["conectado"]}))
	return aux.filter(func(part): return part["id"] != mi_id)

##Devuelve la mano y el turno que tiene
##crea_ficha debe tomar como parametro 
func info_inicial(id: int, crea_ficha: Callable)->Dictionary:
	await _awaiting_request_get(base_url+participaciones+"/"+str(mi_id)+"/"+str(id),header())
	if _respuesta_buena():
		var campos = json.data
		
		var res:Dictionary={}
		res[turno]= campos[partic_turno]
		print(campos)
		res["poderes"] = []
		if campos["habilidadesActuales"] != null and campos["habilidadesActuales"] != "":
			res["poderes"] = string_to_poderes(campos["habilidadesActuales"])
		
		var cartas = campos[partic_mano]
		cartas = Array(cartas.split(","))
		print("CARTAS INICIALES: ", cartas)
		var carta_arr: Array[Ficha]
		carta_arr.assign(cartas.map( func(s:String)->Ficha: 
			var dict = string_to_ficha(s)
			return crea_ficha.call(dict["color"],dict["numero"],dict["especial"]) ))
		res["mano"]= carta_arr
		return res
	else:
		assert(false,"Error al obtener informacion inicial " + str(json.data))
		return {}

func mano(id: int, crea_ficha: Callable)->Array[Ficha]:
	await _awaiting_request_get(base_url+participaciones+"/"+str(mi_id)+"/"+str(id),header())
	if _respuesta_buena():
		var campos = json.data
		
		var cartas = campos[partic_mano]
		cartas = Array(cartas.split(","))
		var carta_arr: Array[Ficha]
		carta_arr.assign(cartas.map( func(s:String)->Ficha: 
			var dict = string_to_ficha(s)
			return crea_ficha.call(dict["color"],dict["numero"],dict["especial"]) ))
		return carta_arr
	else:
		return []

##Devuelve "turno" y "mesa"
## "mesa" es un array de arrays de fichas con los grupos que hay en el tablero 
func get_turno(id: int):
	await _espera_a_resultado(
		func(data)->bool:
			ultima_info_partida = data
			if data[estado_partida] == ESTADO_PARTIDA_TERMINADA or \
					data[estado_partida] == ESTADO_PARTIDA_PAUSADA:
				print("partida no continua")
				print(data)
				return true
			if data[turno] != ultimo_turno: 
				print("cambio de turno")
				ultimo_turno = data[turno]
				return true
			else: 
				print(data[turno])
				print("esperando")
				return false,
		base_url+partidas+"/"+str(id), 0.3)
	var datos = json.data
	var mi_puntuacion = null
	if datos[estado_partida] == ESTADO_PARTIDA_TERMINADA:
		mi_puntuacion = datos["puntuacionFinal"]["remaining"][str(mi_id)]
	var res={"turno":ultimo_turno, "mesa":string_to_grupos(datos[mesa]),
				"estado":datos["estado"],"ganadorId":datos["ganadorId"],
				"puntuacion":mi_puntuacion}
	return res

func subir_jugada(id:int, tablero: Array[Grupo_fichas]):
	var lista_tablero: Array = tablero.map(
		func(grupo:Grupo_fichas)->Array:
		return grupo.fichas.map(ficha_to_string)
	)
	await _awaiting_request(base_url+partidas+"/"+str(id)+partida_jugar,
	{id_jugador:mi_id,jugar_tipo:jugar_tipo_cambio_tablero,
	jugar_tablero:lista_tablero} ,
	HTTPClient.METHOD_POST, header())
	print("RESPUESTA A SUBIR JUGADA",json.data)
	return _respuesta_buena()

func pasar_turno_servidor(id:int):
	await _awaiting_request(base_url+partidas+"/"+str(id)+partida_pasar,{},HTTPClient.METHOD_POST,header())
	if _respuesta_buena(): print("TURNO PASADO CON EXITO")
	else: print("TURNO NO PASADO")

const num_fichas_robar = "cantidadRobar"
func robar_fichas_sin_pasar(id:int, num_fichas: int = 1)->Array:
	var dict_id = {id_jugador: mi_id, num_fichas_robar: num_fichas }
	if ultima_info_partida[bolsa_robar].split(",").size() >= num_fichas:
		await _awaiting_request(base_url+partidas+"/"+str(id)+partida_robar_sin_pasar,dict_id,
		HTTPClient.METHOD_POST,header())
		print("RECIBIDO DE PARTIDA ROBAR: ", json.data)
		assert(_respuesta_buena(),"Error en solo-robar request: "+str(json.data))
		var aux = json.data["fichasRobadas"]
		return aux.map(string_to_ficha)
	else:
		return []

func robar_ficha(id: int)->Dictionary:
	var dict_id = {id_jugador: mi_id}
	if ultima_info_partida[bolsa_robar].split(",").size() >= 1:
		await _awaiting_request(base_url+partidas+"/"+str(id)+partida_robar,dict_id,
		HTTPClient.METHOD_POST,header())
		print("RECIBIDO DE PARTIDA ROBAR: ", json.data)
		assert(_respuesta_buena(),"Error al robar ficha-roba request: "+str(json.data))
		await _awaiting_request_get(base_url+participaciones+"/"+str(mi_id)+"/"+str(id),header())
		assert(_respuesta_buena(),"Error al robar ficha-mano request: "+str(json.data))
		var nueva_mano: String = json.data[fichas_mano]
		var aux = nueva_mano.split(",")
		aux.reverse()
		return string_to_ficha(aux[0])
	else:
		return {"color": Ficha.COLOR.BLANCO,"numero":1}
#endregion
#region perfil
const num_monedas: String = "monedas"
const skins_fichas: String = "skinFichas"
const skins_tablero: String = "skinTablero"

func get_perfil()->Dictionary:
	await _awaiting_request_get(base_url+jugadores+"/"+str(mi_id),header())
	assert(_respuesta_buena(),json.data)
	var datos = json.data
	return {"avatar":datos[imagen_perfil], "monedas": datos[num_monedas],
	"tableros":datos[skins_tablero], "fichas":datos[skins_fichas],}

func cambia_perfil(icono: String):
	await _awaiting_request(base_url+jugadores+"/"+str(mi_id)+perfil,{imagen_perfil:icono},HTTPClient.METHOD_PATCH,header())
	assert(_respuesta_buena(),json.data)

func set_perfil(ficha_actual:String, tablero_actual: String, monedas: int):
	var lista_tableros : String =  ""
	for color: String in globales.mis_skins_tablero:
		if color == tablero_actual and not color.is_subsequence_of(lista_tableros):
			lista_tableros = lista_tableros + ("*"+color) + ","
		elif  not color.is_subsequence_of(lista_tableros):
			lista_tableros = lista_tableros + (color) + ","
	lista_tableros = lista_tableros.left(-1)
	var lista_fichas : String =  ""
	printerr(globales.mis_skins_ficha)
	for color: String in globales.mis_skins_ficha:
		if color == ficha_actual and not color.is_subsequence_of(lista_fichas):
			lista_fichas = lista_fichas + ("*"+color) + ","
		elif  not color.is_subsequence_of(lista_fichas):
			lista_fichas = lista_fichas + (color) + ","
	lista_fichas = lista_fichas.left(-1)

	print(lista_tableros)
	await _awaiting_request(base_url+jugadores+"/"+str(mi_id)+perfil,
		{skins_tablero:lista_tableros, num_monedas:monedas,skins_fichas:lista_fichas},
		HTTPClient.METHOD_PATCH,header())
	assert(_respuesta_buena(),json.data)

func cambiar_contrasena(contra_nueva: String, contra_vieja: String)->bool:
	await _awaiting_request(base_url+jugadores+"/"+str(mi_id)+"/contrasena",
		{"contrasenaActual":contra_vieja,"contrasenaNueva":contra_nueva},HTTPClient.METHOD_PATCH,header())
	if not _respuesta_buena():
		printerr(json.data)
	return _respuesta_buena()
	
#endregion
#region salir de partida
func pausar_partida(id: int):
	await _awaiting_request(base_url+partidas+"/"+str(id)+"/pausar",{},HTTPClient.METHOD_POST,header())
	return _respuesta_buena()
func salir_de_partida(id: int) :
	await _awaiting_request(base_url+partidas+"/"+str(id)+"/salir",{},HTTPClient.METHOD_POST,header())
#endregion
#region retos
const invitaciones = "/api/invitaciones"
const invitaciones_por_invitado = "/api/invitaciones/invitado/"
@warning_ignore("shadowed_variable")
func enviar_reto(id_amigo,id_partida):
	await _awaiting_request(base_url+invitaciones,{"idPartida":id_partida,
	"idInvitado":id_amigo},HTTPClient.METHOD_POST,header())
	assert(_respuesta_buena())
@warning_ignore("shadowed_variable")
func rechazar_reto(id_partida:int, id_emisor:int):
	await _awaiting_request(
		base_url+invitaciones+"/"+str(id_emisor)+"/"+str(mi_id)+"/"+str(id_partida),
		{},HTTPClient.METHOD_DELETE,header()
	)
	printerr(json.data)

func get_retos():
	await _awaiting_request_get(base_url+invitaciones_por_invitado+str(mi_id),header())
	assert(_respuesta_buena(),json.data)
	var dato
	if json.data is Dictionary:
		dato = [json.data]
	elif json.data is Array:
		dato = json.data
	return dato.map(func(solicitud):
		return{"id_partida": solicitud["idPartida"],
		"emisor_nom":solicitud["nombreEmisor"],"emisor_id":solicitud["idEmisor"]})
#endregion
#region eventos aleatorios
func get_evento()->String:
	return ultima_info_partida["eventoActual"]
#endregion
func comprar(id_partida,poder_comprar):
	var poder
	match poder_comprar:
		Poder.PODER.ANGEL_GUARDA:
			poder = "GUARDIAN_ANGEL"
		Poder.PODER.BOLA_CRISTAL:
			poder = "CRYSTAL_BALL"
		Poder.PODER.TOQUE_MIDAS:
			poder = "MIDAS_TOUCH"
		Poder.PODER.MAS_CUATRO:
			poder = "PLUS_FOUR"
		Poder.PODER.TRUEQUE:
			poder = "SWAP_ON_FAIL"
		Poder.PODER.GUANTE_BLANCO:
			poder = "WHITE_GLOVE"
		Poder.PODER.BOMBA_HUMO:
			poder = "SMOKE_BOMB"
		Poder.PODER.REDUCIR_TIEMPO:
			poder = "CHILI_PEPPER"
		Poder.PODER.TECHO_CRISTAL:
			poder = "GLASS_CEILING"
	await _awaiting_request(base_url+partidas+"/"+str(id_partida)+"/mercado/comprar",
	{"codigoObjeto":poder},HTTPClient.METHOD_POST,header())
	assert(_respuesta_buena(),json.data)
func set_monedas(id_partida,monedas):
	await _awaiting_request(base_url+participaciones+"/"+str(mi_id)+"/"+str(id_partida)+"/monedas",
	{"monedasPartida":monedas},HTTPClient.METHOD_PATCH,header())
	assert(_respuesta_buena(),json.data)
	print(json.data)
func get_mercado(id):
	printerr("aaaaaa")
	await _awaiting_request_get(base_url+partidas+"/"+str(id)+"/mercado",header())
	printerr("bbbbbb")
	assert(_respuesta_buena(), json.data)
	printerr("dinero: ", json.data["monedasPartida"])
	return {
	"monedas":json.data["monedasPartida"],
	"mercado":string_to_poderes(json.data["objetosMercado"]),
	"efectos":json.data["efectosActivos"].map(string_to_poder),
	"poderes":json.data["habilidadesCompradas"].map(string_to_poder)
	}
func activar_poder(id:int, poder: String, objetivo:int = -1):
	if objetivo >= 0:
		await _awaiting_request(base_url+partidas+"/"+str(id)+"/mercado/usar",
		{"codigoObjeto":poder, "idJugadorObjetivo":objetivo},
		HTTPClient.METHOD_POST, header())
	else:
		await _awaiting_request(base_url+partidas+"/"+str(id)+"/mercado/usar",
		{"codigoObjeto":poder},
		HTTPClient.METHOD_POST, header())
	assert(_respuesta_buena(),json.data)
	return json.data
func final_guante(id:int, objetivo:int,objeto: String):
	await _awaiting_request(base_url+partidas+"/"+str(id)+"/mercado/usar",
		{"codigoObjeto":"WHITE_GLOVE", "idJugadorObjetivo":objetivo,
		"codigoObjetoObjetivo":objeto},
		HTTPClient.METHOD_POST, header())
	assert(_respuesta_buena(),json.data)

func final_trueque(id:int,objetivo:int,mi_ficha:Ficha,su_ficha:Ficha):
	await _awaiting_request(base_url+partidas+"/"+str(id)+"/mercado/usar",
		{"codigoObjeto":"SWAP_ON_FAIL",
		"idJugadorObjetivo":objetivo,
		"fichaPropia":ficha_to_string(mi_ficha),
		"fichaObjetivo":ficha_to_string(su_ficha)},
		HTTPClient.METHOD_POST, header())
	assert(_respuesta_buena(),json.data)
