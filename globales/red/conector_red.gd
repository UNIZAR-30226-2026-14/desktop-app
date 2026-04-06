class_name conector_red extends Node

signal siguiente_turno(gruposNuevos: Array[Grupo_fichas], gruposEliminados: Array[Grupo_fichas])

const siguiente_turno_manual: bool = false
const num_cartas_inicial: int = 14



static var singleton_instance: conector_red = null

var id_partida: int = -1


var miTurno: bool

func _init() -> void:
	if singleton_instance == null:
		singleton_instance = self
	else:
		printerr("Trying to create another instance of MySingleton. Deleting it.")
		queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	miTurno = false

func espera_a_turno(receptor: Callable) -> void:
	siguiente_turno.connect(receptor)
	siguiente_turno.emit([],[])

func acabo_turno(receptor: Callable, tablero:Array[Grupo_fichas]):
	return receptor.call(true)

func robar(receptor: Callable):
	var posibles_fichas = [Ficha.COLOR.ROJO,Ficha.COLOR.AMARILLO,Ficha.COLOR.NEGRO,Ficha.COLOR.AZUL]
	return receptor.call(posibles_fichas[randi()%4],randi()%13 )

func buscar_partida():
	# get partidas, 
	# si hay una partida no empezada, 
	# 	guardar su id
	# 	anadirse como participante y cambiar corriendo a true
	# sino
	#	crear partida con corriendo = false
	#	anadirse como participante
	#	esperar a ???????
	print("hola")
	id_partida = await $red.get_partidas()
	await $red.espera_a_comienzo_partida(id_partida)
	get_tree().change_scene_to_file("res://proyecto_rummikub/escenaPrincipal/escenaprincipal.tscn")
	pass
	
func mano_inicial(func_crear_ficha: Callable) -> Array:
	var res = []
	var posibles_fichas = [Ficha.COLOR.ROJO,Ficha.COLOR.AMARILLO,Ficha.COLOR.NEGRO,Ficha.COLOR.AZUL]
	
	for i in range(num_cartas_inicial):
		res.append(func_crear_ficha.call(posibles_fichas[randi()%4],randi()%13))
	return res
	

func fin_partida():
	pass
