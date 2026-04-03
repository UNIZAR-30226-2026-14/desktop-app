class_name conector_red extends Node

signal siguiente_turno(gruposNuevos: Array[Grupo_fichas], gruposEliminados: Array[Grupo_fichas])
signal jugada_verificada(correcto: bool)
signal robado(num: int, color: Ficha.COLOR)

const siguiente_turno_manual: bool = false

static var singleton_instance: conector_red = null

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

func acabo_turno(receptor: Callable):
	return receptor.call(true)

func robar(receptor: Callable):
	var posibles_fichas = [Ficha.COLOR.ROJO,Ficha.COLOR.AMARILLO,Ficha.COLOR.NEGRO,Ficha.COLOR.AZUL]
	return receptor.call(posibles_fichas[randi()%4],randi()%13 )

func buscar_partida():
	await get_tree().create_timer(5.0).timeout
	get_tree().change_scene_to_file("res://proyecto_rummikub/escenaPrincipal/escenaprincipal.tscn")
	#pasar info a manager_juego
	pass

#func get_info_inicio_partida():
	#pass

func fin_partida():
	pass
