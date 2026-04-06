extends Node

static var base_url: String = "http://localhost:8080"
static var base_jugadores: String = "/api/jugadores"
static var perfil: String = "/perfil"
static var partidas: String = "/api/partidas"
static var participaciones: String = "/api/participaciones"
static var participiaciones_por_partida: String = "/api/participaciones?partidaId="
static var amigos_por_jugador: String = "/api/amigos?jugadorId="
static var iniciar_partida: String = "/iniciar"
static var pasar_turno: String = "/siguiente-turno"

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
const ESTADO_PARTIDA_SIN_EMPEZAR="WAITING"
const ESTADO_PARTIDA_EMPEZADA="RUNNING"
const ESTADO_PARTIDA_TERMINADA="FINISHED"

## Indica que ha creado una partida que aún no ha empezado, uso interno
var creado_partida: bool = false
## Uso interno, ultima info de partida en la que estamos, debería ser un dict
var ultima_info_partida

var mi_id: int = -1
var mi_token = null

var forzar_inicio_partida: bool = false

func _ready() -> void:
	$HTTPRequest.request_completed.connect(_recibe_respuesta)

## Resultado con claves "color" y "numero"
func string_to_ficha(s:String) -> Dictionary:
	var res = {}
	match s[0]:
		ROJO_RED:
			res["color"] = Ficha.COLOR.ROJO
	
	res["numero"] = s.substr(1).to_int()
	return res

#region auxiliares
var json = JSON.new()
var codigo_respuesta: int
func _recibe_respuesta(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	print(result)
	codigo_respuesta = response_code
	if result != HTTPRequest.RESULT_SUCCESS:
		assert(false,"codigo de error a get partidas: Error " + str(result))
	if Error.OK != json.parse(body.get_string_from_utf8()):
		assert(false,"Error al leer cuerpo de get partidas")

func _awaiting_request_get(url:String, header:PackedStringArray = PackedStringArray()):
	$HTTPRequest.request(url, header)
	await $HTTPRequest.request_completed

##Body puede ser diccionario o array, se convierte a string dentro de esta funcion
func _awaiting_request(url:String, body, metodo:HTTPClient.Method, header:PackedStringArray = PackedStringArray()):
	print("POST ", url, " ,Cuerpo: ",JSON.stringify(body))
	$HTTPRequest.request(url,header,metodo,JSON.stringify(body))
	await $HTTPRequest.request_completed

## acaba_si_true toma el valor esperado de hacer get url y  debe devolver un bool que será true
## cuando se den las condiciones para acabar la espera
#TODO probar
func _espera_a_resultado(acaba: Callable, url: String, polling_time: float = 0.5):
	await _awaiting_request_get(url)
	var timer = Timer.new()
	while !acaba.call(json.data):
		timer.start(polling_time)
		await timer.timeout
		await _awaiting_request_get(url)
	timer.free()
#endregion

#region inicio sesion
const inicio_sesion = "/api/auth/login"
const nom_usuario = "nombre"
const passw = "password"

var guarda_nom:String
var guarda_con

func inicia_sesion(nombre: String, contrasena: String):
	guarda_con = contrasena
	guarda_nom = nombre
	 #guarda 
	var timer:Timer = Timer.new()#con tiempo hasta tiempo expiracion
	timer.start()
	timer.timeout.connect(func(): inicia_sesion(guarda_con,guarda_nom))

func registrar_usuario(nombre: String, contrasena: String):
	#registra
	inicia_sesion(nombre,contrasena)


#endregion

#region iniciar partida
#TODO probar
func crear_partida() -> Dictionary:
	creado_partida = true
	print("crear partida ")
	var partida = {fecha:Time.get_date_string_from_system()}
	await _awaiting_request(base_url+partidas,partida,HTTPClient.METHOD_POST)
	print("respuesta: ", json.data)
	return partida

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
		if codigo_respuesta < 200 or codigo_respuesta >= 300:
			push_error("Falla envio de participacion")
			return Error.FAILED
		print("Me he unido a partida")
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

func check_iniciar_partida(res): 
	return forzar_inicio_partida or (res is Array and res.size() >= 4)

#TODO probar
func espera_a_comienzo_partida(id: int, min_jugadores: int=3)->void:
	if creado_partida:
		## WARNING si se puede iniciar partidas con 1 jugador hay que cambiar este código
		await _espera_a_resultado(check_iniciar_partida,\
							base_url+participiaciones_por_partida+str(id))
		print("Partida comenzada")
		await _awaiting_request_get(base_url+partidas+"/"+str(id)+iniciar_partida)
		print(json.data)#WARNING print es para prueba
		creado_partida = false
		forzar_inicio_partida = false
	else:
		await _espera_a_resultado(func(dic:Dictionary): return dic[partida_empezada] ,base_url+partidas+"/"+str(id)) 
	ultima_info_partida = json.data

##Busca partida y devuelve su id, que termine no asegura que la partida haya empezado
func get_partidas() -> int:
	await _awaiting_request_get(base_url+partidas)
	var body = json.data
	var max_id: int = 5000
	creado_partida = false
	if body is Array: # varias partidas
		for partida in body:
			if !partida[partida_empezada]:
				print("encontrada partida ", partida[id_partida])
				ultima_info_partida = partida
				return ultima_info_partida[id_partida]
			else: max_id = max(max_id,partida[id_partida])
	elif body is Dictionary:# una partida
		if !body[partida_empezada]:
			print("encontrada partida ", body[id_partida])
			ultima_info_partida = body
			return ultima_info_partida[id_partida]
		else: max_id = body[id_partida]
	elif body == null:
		print("no hay partidas")
	else:
		assert(false, "body con estructura o tipo inesperado en get_partidas: " + str(body))
	
	ultima_info_partida = await crear_partida()
	return ultima_info_partida[id_partida]
#endregion
