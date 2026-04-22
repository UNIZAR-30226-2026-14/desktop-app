extends Node2D

@export var robarCarta: Button
@export var pasarTurno: Button
@export var devolverFichas: Button
@export var miTurno: Button


@export var tablero: Node2D
@export var mano: Node2D
@export var manager_fichas: Node2D

signal empieza_turno
signal termina_turno

class GrupoGuardado:
	var grupo: Array[Ficha]
	var posicion: Vector2
	
	func _init(mgrupo: Array[Ficha], mposicion: Vector2) -> void:
		grupo = mgrupo
		posicion = mposicion
	
	func creaGrupo()-> Grupo_fichas:
		var res = Grupo_fichas.Grupo_fichas(grupo)
		res.position = posicion
		return res

var fichas_en_mano_antes: Array[Ficha]
var grupos_en_tablero_antes: Array[GrupoGuardado]

# la primera jugada tiene que sumar 30, esta variable cuenta si la primera jugada a ocurrido ya o no
var abierto: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	globales.estado_cursor = globales.ESTADO_CURSOR.TABLERO
	fichas_en_mano_antes = []
	grupos_en_tablero_antes = []
	abierto = false
	robarCarta.pressed.connect(robar_carta)
	pasarTurno.pressed.connect(intenta_hacer_jugada)
	devolverFichas.pressed.connect(_boton_devolver_fichas)
	miTurno.pressed.connect(iniciar_turno)

func intenta_hacer_jugada() -> bool:
	if(tablero.tablero_valido(abierto)):
		tablero.fijar_tablero()
		guardar_estado()
		terminar_turno()
		return true
	else:
		print("TABLERO NO VALIDO")
		return false

func terminar_turno() -> void:
	_devolver_fichas()
	termina_turno.emit()
	abierto = true
	globales.estado_juego = globales.ESTADO_JUEGO.NO_MI_TURNO
	robarCarta.disabled = true
	devolverFichas.disabled = true
	pasarTurno.disabled = true

func iniciar_turno() -> void:
	guardar_estado()
	globales.estado_juego = globales.ESTADO_JUEGO.NO_PONIENDO_FICHAS
	robarCarta.disabled = false
	
	devolverFichas.disabled = true
	pasarTurno.disabled = true
	empieza_turno.emit()

func guardar_estado() -> void:
	print("GUARDANDO FICHAS")
	fichas_en_mano_antes = []
	var ficha_nueva: Ficha
	for ficha in mano.fichas_en_mano:
		ficha_nueva = Ficha.ficha(ficha.color,ficha.numero)
		globales.apropiar_hijo(self, ficha_nueva)
		fichas_en_mano_antes.append(ficha_nueva)
	
	
	grupos_en_tablero_antes = []
	for grupo in tablero.grupos:
		grupos_en_tablero_antes.append(GrupoGuardado.new(grupo.fichas.duplicate(),grupo.position))


func no_poniendo_fichas() -> void:

	globales.estado_juego = globales.ESTADO_JUEGO.NO_PONIENDO_FICHAS

	devolverFichas.disabled = true
	pasarTurno.disabled = true
	robarCarta.disabled = false

func poniendo_fichas() -> void:
	globales.estado_juego = globales.ESTADO_JUEGO.PONIENDO_FICHAS
	
	devolverFichas.disabled = false
	pasarTurno.disabled = false
	
	robarCarta.disabled = true

func _boton_devolver_fichas() -> void:
	globales.estado_juego = globales.ESTADO_JUEGO.NO_PONIENDO_FICHAS
	
	devolverFichas.disabled = true
	pasarTurno.disabled = true
	robarCarta.disabled = false
	
	_devolver_fichas()


func _devolver_fichas() -> void:
	var arrayGrupos: Array[Grupo_fichas] = []
	for grupo: GrupoGuardado in grupos_en_tablero_antes:
		arrayGrupos.append(grupo.creaGrupo())
	tablero.insertar_tablero(arrayGrupos)
	
	mano.insertar_mano(fichas_en_mano_antes)

func robar_carta() -> void:
	var fich: Ficha = manager_fichas._crear_ficha()
	mano.devolver_ficha(fich)
	fich.z_index = 0
	guardar_estado()
	terminar_turno()

var adversarios: Array[Dictionary] = [{"nombre":"jose maria", "icono": load("res://imagenes/Fernando.png") },{"nombre":"maria jose", "icono": load("res://imagenes/Fernando.png")} ]

## cada diccionario tiene dos claves una con el valor: "nombre" asociada a un String con el nombre del adversario,
## y otra con el valor "icono" asociada a un Texture2D con el icono del adversario
func get_adversarios() -> Array[Dictionary]:
	return adversarios
