extends Node2D

@export var robarCarta: Button
@export var pasarTurno: Button
@export var devolverFichas: Button
@export var miTurno: Button


@export var tablero: Node2D
@export var mano: Node2D
@export var manager_fichas: Node2D

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
	fichas_en_mano_antes = []
	grupos_en_tablero_antes = []
	abierto = false
	robarCarta.pressed.connect(robar_carta)
	pasarTurno.pressed.connect(pasar_turno)
	devolverFichas.pressed.connect(devolver_fichas)
	miTurno.pressed.connect(iniciar_turno)

func pasar_turno():
	if(tablero.tablero_valido(abierto)):
		abierto = true
		globales.estado_juego = globales.ESTADO_JUEGO.NO_MI_TURNO
		tablero.fijar_tablero()
		robarCarta.disabled = true
		devolverFichas.disabled = true
		pasarTurno.disabled = true
	else:
		print("TABLERO NO VALIDO")


func iniciar_turno() -> void:
	guardar_estado()
	globales.estado_juego = globales.ESTADO_JUEGO.NO_PONIENDO_FICHAS
	
	robarCarta.disabled = false
	
	devolverFichas.disabled = true
	pasarTurno.disabled = true

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

func volver_estado_inicial() -> void:
	pass

func devolver_fichas() -> void:
	print("DEVOLVIENDO FICHAS")
	globales.estado_juego = globales.ESTADO_JUEGO.NO_PONIENDO_FICHAS
	
	devolverFichas.disabled = true
	pasarTurno.disabled = true
	robarCarta.disabled = false
	
	var arrayGrupos: Array[Grupo_fichas] = []
	for grupo: GrupoGuardado in grupos_en_tablero_antes:
		arrayGrupos.append(grupo.creaGrupo())
	tablero.insertar_tablero(arrayGrupos)
	
	mano.insertar_mano(fichas_en_mano_antes)

func robar_carta() -> void:
	var fich = manager_fichas._crear_ficha()
	mano.devolver_ficha(fich)
	#el ultimo objeto creado tiene mas z_index, esto arregla eso:
	fich.z_index = 0
	#if(indice_lista_fichas >= 1):
		#lista_fichas[indice_lista_fichas-1].z_index += 1
	pasar_turno()
