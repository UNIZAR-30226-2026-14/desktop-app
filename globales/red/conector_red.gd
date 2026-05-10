class_name conector_red extends Node

signal siguiente_turno(gruposNuevos: Array[Grupo_fichas], gruposEliminados: Array[Grupo_fichas])
signal jugada_verificada(correcto: bool)
signal robado(num: int, color: Ficha.COLOR)
signal partida_encontrada(manoInicial: Array[Ficha], numJugadores: int)

static var singleton_instance: conector_red = null
var avatar: Texture2D = preload("res://imagenes/avatares_posibles/Fernando.png")
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


static var imagen1: Texture2D = preload("res://imagenes/avatares_posibles/Miguel.png")
static var imagen2: Texture2D = preload("res://imagenes/avatares_posibles/Dian.png")
static var partida1: PartidaSeleccionable =  PartidaSeleccionable.partida_seleccionable("11/09/2001",[imagen1,imagen2,imagen1,imagen2])
static var partida2: PartidaSeleccionable =  PartidaSeleccionable.partida_seleccionable("5/09/2005",[imagen2,imagen1,imagen2,imagen1])
static var mis_partidas_en_curso: Array[PartidaSeleccionable] = [partida1, partida2, partida1, partida2, partida1] 
static func get_partidas_en_curso() -> Array[PartidaSeleccionable]:
	return mis_partidas_en_curso

static var amigos: Array[Amigo] = [Amigo.amigo(preload("res://imagenes/avatares_posibles/Miguel.png"), "Miguel"), Amigo.amigo(preload("res://imagenes/avatares_posibles/Dian.png"), "Dian")]
static func get_amigos() -> Array[Amigo]:
	return amigos
