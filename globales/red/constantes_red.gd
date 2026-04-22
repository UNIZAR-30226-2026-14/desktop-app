extends Node
#region constantes
static var base_url: String = "http://localhost:8080"
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

const ROJO_RED="R"
const NEGRO_RED = "K"
const AZUL_RED = "B"
const NARANJA_RED = "O"
const JOKER_RED = "J"

const ESTADO_PARTIDA_SIN_EMPEZAR="WAITING"
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
		if amigo != mi_id:
			await _awaiting_request(base_url+amigos,{amis1:mi_id,amis2:amigo,"estado":"ACEPTADO","fecha":"2026-04-05"},
			HTTPClient.METHOD_POST,header())
			print(json.data)
			if not _respuesta_buena(): push_error("Error al añadir amigo")

#endregion
#region auxiliares
func header()->PackedStringArray:
	return PackedStringArray(["Authorization: Bearer "+mi_token, "Content-Type: application/json"])

func ficha_to_string(ficha)->String:
	var res: String = ""
	if ficha.color == Ficha.COLOR.COMODIN:
		return JOKER_RED + "1"
	
	match ficha.color:
		Ficha.COLOR.ROJO:
			res = ROJO_RED 
		Ficha.COLOR.AZUL:
			res = AZUL_RED
		Ficha.COLOR.NEGRO:
			res = NEGRO_RED 
		Ficha.COLOR.AMARILLO:
			res = NARANJA_RED 
	return res + str(ficha.numero)
	

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

## Resultado con claves "color" y "numero"
func string_to_ficha(s:String) -> Dictionary:
	s=s.to_upper()
	var res = {}
	print(s)
	if s[0] == JOKER_RED:
		return {"color":Ficha.COLOR.COMODIN, "numero":10}
	match s[0]:
		ROJO_RED:
			res["color"] = Ficha.COLOR.ROJO
		AZUL_RED:
			res["color"] = Ficha.COLOR.AZUL
		NEGRO_RED:
			res["color"] = Ficha.COLOR.NEGRO
		NARANJA_RED:
			res["color"] = Ficha.COLOR.AMARILLO
	
	res["numero"] = s.substr(1).to_int()
	return res

func get_imagen(url: String)->Texture2D:
	$HTTPRequest.request_completed.disconnect(_recibe_respuesta_json)
	$HTTPRequest.request_completed.connect(_recibe_respuesta_imagen)
	await _awaiting_request_get(url)
	$HTTPRequest.request_completed.connect(_recibe_respuesta_json)
	return textura


var codigo_respuesta: int
var textura: ImageTexture = ImageTexture.new()
func _recibe_respuesta_imagen(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	codigo_respuesta = response_code
	if result != HTTPRequest.RESULT_SUCCESS:
		assert(false,"codigo de error a get partidas: Error " + str(result))
	var imagen = Image.new()
	var err = imagen.load_png_from_buffer(body)
	if err == OK:
		print("Imagen cargada con éxito")		
		textura = null
		textura = ImageTexture.create_from_image(imagen)
		if textura:
			print("Textura creada.")
		else:
			print("Fallo al crear textura")
var json = JSON.new()
func _recibe_respuesta_json(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	print(result)
	codigo_respuesta = response_code
	if result != HTTPRequest.RESULT_SUCCESS:
		assert(false,"codigo de error a get partidas: Error " + str(result))
	if Error.OK != json.parse(body.get_string_from_utf8()):
		assert(false,"Error al leer cuerpo de get partidas")

@warning_ignore("shadowed_variable")
func _awaiting_request_get(url:String, header:PackedStringArray = PackedStringArray()):
	$HTTPRequest.request(url, header)
	await $HTTPRequest.request_completed

##Body puede ser diccionario o array, se convierte a string dentro de esta funcion
@warning_ignore("shadowed_variable")
func _awaiting_request(url:String, body, metodo:HTTPClient.Method, header:PackedStringArray = PackedStringArray(["Content-Type: application/json"])):
	print("POST ", url, ", Cuerpo: ",JSON.stringify(body), ", Cabecera: ",header)
	$HTTPRequest.request(url,header,metodo,JSON.stringify(body))
	await $HTTPRequest.request_completed


## acaba toma el valor de hacer get url y  debe devolver un bool que será true
## cuando se den las condiciones para acabar la espera
func _espera_a_resultado(acaba: Callable, url: String, polling_time: float = 0.5):
	await _awaiting_request_get(url)
	var timer = Timer.new()
	self.add_child(timer)
	while !acaba.call(json.data):
		timer.start(polling_time)
		await timer.timeout
		await _awaiting_request_get(url)
	timer.free()
	
func _respuesta_buena() -> bool:
	return codigo_respuesta >= 200 and codigo_respuesta < 300
#endregion
#region amigos
const nom_jugador = "nombre"
const url_jugador ="urlImgPerfil"
const amigos = "/api/amigos"
const amigos_de_jugador = "/api/amigos?jugadorId="
const perfiles_de_amigos = "/amigos/perfiles"
const amis1 = "jugador1Id"
const amis2 = "jugador2Id"
const amigo_nom = "nombre"
const amigo_icono = "urlImgPerfil"

## Campos return: "icono", "nombre", "conectado"
func get_amigos()->Array[Dictionary]:
	await _awaiting_request_get(base_url+jugadores+"/"+str(mi_id)+perfiles_de_amigos)
	if _respuesta_buena():
		@warning_ignore("shadowed_variable")
		var amigos: Array[Dictionary]
		amigos.assign(json.data)
		amigos.assign(amigos.map(func(amigo)->Dictionary:
			return {"icono":amigo[amigo_icono],"nombre":amigo[amigo_nom]}))#,"conectado":amigo[p]}))
		return amigos
	return []

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
	await _awaiting_request(base_url+jugadores,{login_nom_usuario:nombre,login_passw:contrasena},HTTPClient.METHOD_POST)
	if _respuesta_buena():
		print("Bien", json.data)
		return Error.OK
	else:
		printerr("Error al registrar",json.data)
		return Error.FAILED

func inicia_sesion(nombre: String, contrasena: String) -> Error:
	guarda_con = contrasena
	guarda_nom = nombre
	await _awaiting_request(base_url+inicio_sesion, {login_nom_usuario:nombre, login_passw:contrasena}, HTTPClient.METHOD_POST)
	if _respuesta_buena():
		var res = json.data
		
		mi_token = res[login_token]
		mi_id = res[login_jugador][login_id]

		var tiempo = Time.get_unix_time_from_datetime_string(res[login_expiracion]) - Time.get_unix_time_from_system()
		login_timer.start(tiempo)
		login_timer.timeout.connect(func(): inicia_sesion(guarda_con,guarda_nom))
		print(tiempo)
		print("Bien: ", json.data)
		return Error.OK
		
	else:
		printerr("Error al iniciar sesion",json.data)
		return Error.FAILED

#endregion
var ultimo_turno = -1
#region iniciar partida

func unirse_a_partida(id: int)-> Error:
	print("Busco partida: ", id)
	await _awaiting_request_get(base_url+partidas+"/"+str(id))
	var partida: Dictionary = json.data
	
	if (partida.get(id_partida) == id) \
			and partida[estado_partida] == ESTADO_PARTIDA_SIN_EMPEZAR:
		print("Me uno a partida")
		ultima_info_partida = partida
		var participacion = {id_jugador:mi_id, id_partida:partida[id_partida]}
		await _awaiting_request(base_url+participaciones,participacion,HTTPClient.METHOD_POST)
		if not _respuesta_buena():
			push_error("Falla envio de participacion: ", json.data)
			print(participacion)
			return Error.FAILED
		ultimo_turno = -1
		return Error.OK
	
	# casos de error
	elif partida[estado_partida] != ESTADO_PARTIDA_SIN_EMPEZAR:
		push_error("En unirse a partida, partida ya empezada")
		return Error.ERR_BUSY
	elif partida.find_key(id_partida) != id_partida or partida[id_partida] == id:
		push_error("En unirse a partida, Partida no existe")
		return Error.ERR_CANT_CONNECT
	
	return Error.ERR_BUG

func forzar_inicio_partida_set_true():
	forzar_inicio_partida = true

var maximos_jugadores: int = 4
var status_label: Label
func check_iniciar_partida(res): 
	var texto = "Oponentes en partida: "
	if res is Array: texto += str(res.size() - 1)
	else : texto += "0"
	status_label.text = texto
	return forzar_inicio_partida or (res is Array and res.size() == maximos_jugadores)

func espera_a_comienzo_partida(id: int,status_busqueda:Label, iniciar: Button,
			 max_jugadores: int=3,)->void:
	maximos_jugadores = max_jugadores
	status_label = status_busqueda
	if creado_partida:
		iniciar.visible = true
		iniciar.pressed.connect(forzar_inicio_partida_set_true)
		await _espera_a_resultado(check_iniciar_partida,\
			base_url+participiaciones_por_partida+str(id))
		status_label.text = "Iniciando partida"
		await _awaiting_request(base_url+partidas+"/"+str(id)+iniciar_partida,{},HTTPClient.METHOD_POST)
		status_label.text = "Partida iniciada"
		print(json.data)
		creado_partida = false
		forzar_inicio_partida = false
		iniciar.visible = false
		iniciar.pressed.disconnect(forzar_inicio_partida_set_true)
	else:
		print("espero, no he creado partida")
		await _espera_a_resultado(func(dic:Dictionary): return dic[partida_empezada] ,base_url+partidas+"/"+str(id)) 
	ultima_info_partida = json.data

##Busca partida y devuelve su id, que termine no asegura que la partida haya empezado
func get_partidas(status_busqueda:Label) -> int:
	await _awaiting_request_get(base_url+partidas)
	var body = json.data
	creado_partida = false
	if body is Array: # varias partidas
		for partida in body:
			print(partida)
			if !partida[partida_empezada]:
				print("encontrada partida ", partida[id_partida])
				status_busqueda.text = "Partida encontrada"
				ultima_info_partida = partida
				return ultima_info_partida[id_partida]
	elif body is Dictionary:# una partida
		print(body)
		if !body[partida_empezada]:
			print("encontrada partida ", body[id_partida])
			ultima_info_partida = body
			status_busqueda.text = "Partida encontrada"
			return ultima_info_partida[id_partida]
	elif body == null:
		status_busqueda.text = "No hay partidas libres"
		print("no hay partidas")
	else:
		assert(false, "body con estructura o tipo inesperado en get_partidas: " + str(body))
	
	ultima_info_partida = await crear_partida()
	status_busqueda.text = "Partida creada"
	print (ultima_info_partida)
	return ultima_info_partida[id_partida]

func crear_partida() -> Dictionary:
	creado_partida = true
	print("crear partida ")
	var partida = {fecha:Time.get_date_string_from_system()}
	await _awaiting_request(base_url+partidas,partida,HTTPClient.METHOD_POST)
	if not _respuesta_buena():
		printerr("Error creando partida, recibido:", json.data)
		assert(false, "Error creando partida")
	print("respuesta: ", json.data)
	return json.data

#endregion

#region partida
const partic_mano = "manoActual"
const partic_turno = "ordenTurno"
const partida_robar = "/robar"
const partida_jugar = "/jugar-avanzado"
const jugar_tipo = "moveType"
const jugar_tipo_cambio_tablero = "replace_board"
const jugar_tablero = "newBoard"
const partida_pasar = "/pasar"


##Devuelve la mano y el turno que tiene
##crea_ficha debe tomar como parametro 
func info_inicial(id: int, crea_ficha: Callable)->Dictionary:
	await _awaiting_request_get(base_url+participaciones+"/"+str(mi_id)+"/"+str(id))
	if _respuesta_buena():
		var campos = json.data

		var res:Dictionary={}
		res[turno]= campos[partic_turno]

		var cartas = campos[partic_mano]
		cartas = Array(cartas.split(","))
		var carta_arr: Array[Ficha]
		carta_arr.assign(cartas.map( func(s:String)->Ficha: 
			var dict = string_to_ficha(s)
			return crea_ficha.call(dict["color"],dict["numero"]) ))
		res["mano"]= carta_arr
		return res
	else:
		push_error("Error al obtener informacion inicial", json.data)
		return {}

func mano(id: int, crea_ficha: Callable)->Array[Ficha]:
	await _awaiting_request_get(base_url+participaciones+"/"+str(mi_id)+"/"+str(id))
	if _respuesta_buena():
		var campos = json.data
		
		var cartas = campos[partic_mano]
		cartas = Array(cartas.split(","))
		var carta_arr: Array[Ficha]
		carta_arr.assign(cartas.map( func(s:String)->Ficha: 
			var dict = string_to_ficha(s)
			return crea_ficha.call(dict["color"],dict["numero"]) ))
		return carta_arr
	else:
		return []

##Devuelve "turno" y "mesa"
## "mesa" es un array de arrays de fichas con los grupos que hay en el tablero 
func get_turno(id: int):
	await _espera_a_resultado(
		func(data)->bool:
			ultima_info_partida = data
			if data[turno] != ultimo_turno: 
				ultimo_turno = data[turno]
				return true
			else: 
				print(data[turno])
				print("esperando")
				return false,
		base_url+partidas+"/"+str(id), 0.3)
	var res={"turno"=ultimo_turno, "mesa" = string_to_grupos(json.data[mesa])};
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
	print(json.data)
	return _respuesta_buena()

func pasar_turno_servidor(id:int):
	await _awaiting_request(base_url+partidas+"/"+str(id)+partida_pasar,{},HTTPClient.METHOD_POST,header())
	
	
func robar_ficha(id: int)->Dictionary:
	var dict_id = {id_jugador: mi_id}
	await _awaiting_request(base_url+partidas+"/"+str(id)+partida_robar,dict_id,
	HTTPClient.METHOD_POST,header())
	assert(_respuesta_buena(),"Error al robar ficha-roba request: "+str(json.data))
	await _awaiting_request_get(base_url+participaciones+"/"+str(mi_id)+"/"+str(id))
	assert(_respuesta_buena(),"Error al robar ficha-mano request: "+str(json.data))
	var nueva_mano: String = json.data[fichas_mano]
	var aux = nueva_mano.split(",")
	aux.reverse()

	return string_to_ficha(aux[0])
	
func pasa_turno(_id:int):
	pass
	# BUG desde donde llame a esto, hacer ultimo_turno = mi_turno
#endregion
