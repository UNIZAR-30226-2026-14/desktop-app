class_name conector_red extends Node

var username:String = "placeholder"
var password:String = "placeholder"

const siguiente_turno_manual: bool = false
const num_cartas_inicial: int = 14

var crea_ficha: Callable

static var singleton_instance: conector_red = null
var id_partida: int = -1

var avatar: Texture2D = preload("res://imagenes/avatares_posibles/Fernando.png")

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
func get_amigos()->Array[Dictionary]:
	return await $red.get_amigos()
#endregion
#region DURANTE PARTIDA
var mi_turno: int
##recibe_cartas toma las cartas del tablero como parametro
func espera_a_turno(recibe_cartas: Callable) -> void:
	while true:
		var estado_partida = await $red.get_turno(id_partida)
		print("TABLERO: ", estado_partida["mesa"], " TURNO: ",estado_partida["turno"])
		recibe_cartas.call(estado_partida["mesa"])
		if estado_partida["turno"] == mi_turno:
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
	var dict = await $red.robar_ficha(id_partida)
	print(dict)
	$red.ultimo_turno = -1
	return receptor.call(dict["color"],dict["numero"] )

## devuelve mano inicial
func inicializar_partida(funcion_crea_fichas: Callable):
	crea_ficha = funcion_crea_fichas
	var info = await $red.info_inicial(id_partida, crea_ficha)
	mi_turno = info["turno"]
	return info["mano"]

func mano() -> Array[Ficha]:
	return  await $red.mano(id_partida)

#endregion
#region BUSCAR PARTIDA
func buscar_partida(status_busqueda:Label, iniciar: Button):
	id_partida = await $red.get_partidas(status_busqueda)
	await $red.unirse_a_partida(id_partida)
	await $red.espera_a_comienzo_partida(id_partida, status_busqueda, iniciar)

func forzar_inicio_partida(): $red.forzar_inicio_partida_set_true()
#endregion


func fin_partida():
	pass
