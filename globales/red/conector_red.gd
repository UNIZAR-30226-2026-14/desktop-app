class_name conector_red extends Node

signal siguiente_turno(gruposNuevos: Array[Grupo_fichas], gruposEliminados: Array[Grupo_fichas])
signal jugada_verificada(correcto: bool)
signal robado(num: int, color: Ficha.COLOR)
signal partida_encontrada(manoInicial: Array[Ficha], numJugadores: int)

static var singleton_instance: conector_red = null

func _init() -> void:
	if singleton_instance == null:
		singleton_instance = self
	else:
		printerr("Trying to create another instance of MySingleton. Deleting it.")
		queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func completar_jugada(conectar: Callable):
	pass

func robar(conectar: Callable):
	robado.connect(conectar)
	var posibles_fichas = [Ficha.COLOR.ROJO,Ficha.COLOR.AMARILLO,Ficha.COLOR.NEGRO,Ficha.COLOR.AZUL]
	robado.emit(posibles_fichas[randi()%4],randi()%13 )
	robado.disconnect(conectar)

func buscar_partida(conectar: Callable):
	partida_encontrada.connect(conectar)
	pass

func get_info_jugadores_en_partida(conectar: Callable):
	pass

func fin_partida():
	pass
