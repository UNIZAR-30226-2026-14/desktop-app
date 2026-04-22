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
var abierto: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	globales.estado_cursor = globales.ESTADO_CURSOR.TABLERO
	fichas_en_mano_antes = []
	grupos_en_tablero_antes = []
	printerr("Hay que modificar el uso de la variable abierto para que funcione con los datos llegados de otros jugadores")
	abierto = true
	
	#botones
	robarCarta.pressed.connect(robar_carta)
	pasarTurno.pressed.connect(hacer_jugada)
	devolverFichas.pressed.connect(boton_devolver_fichas)
	@warning_ignore("shadowed_variable")
	var mano_inicial:Array[Ficha] = await ConectorRed.inicializar_partida(manager_fichas.crear_ficha)
	mano.insertar_mano(mano_inicial)
	#miTurno.pressed.connect(iniciar_turno)
	guardar_estado()
	#$ContadorTiempoTurno.proceso_contador()
	terminar_turno()

#region gestion turnos

func terminar_turno() -> void:
	_devolver_fichas()
	#termina_turno.emit()
	globales.estado_juego = globales.ESTADO_JUEGO.NO_MI_TURNO
	robarCarta.disabled = true
	devolverFichas.disabled = true
	pasarTurno.disabled = true
	printerr("si hay bug nuevo al merge, mirar aquí (terminar_turno, manager_juego)")
	termina_turno.emit()
	await ConectorRed.espera_a_turno(llega_turno)
	iniciar_turno()

func iniciar_turno() -> void:
	guardar_estado()
	globales.estado_juego = globales.ESTADO_JUEGO.NO_PONIENDO_FICHAS
	robarCarta.disabled = false
	devolverFichas.disabled = true
	pasarTurno.disabled = true
	empieza_turno.emit()

## nuevo_tablero es Array de Array[FichasGuardar]
func llega_turno(nuevo_tablero: Array):
	var viejo_tablero: Array = tablero.grupos
	viejo_tablero.map(func(grupo): print(Grupo_fichas.hash_grupo(grupo)))
	nuevo_tablero.map(func(grupo): print(Grupo_fichas.hash_grupo(grupo)))
	
	var nuevos = [] ; var eliminados = []
	nuevo_tablero.sort_custom(
		func(grupo_a,grupo_b)-> bool: 
			return Grupo_fichas.hash_grupo(grupo_a) < Grupo_fichas.hash_grupo(grupo_b))
	viejo_tablero.sort_custom(
		func(grupo_a:Grupo_fichas,grupo_b:Grupo_fichas):
			return Grupo_fichas.hash_grupo(grupo_a) < Grupo_fichas.hash_grupo(grupo_b))
	var i_viejo = 0
	var i_nuevo = 0
	while i_viejo < viejo_tablero.size() and i_nuevo < nuevo_tablero.size():
		if Grupo_fichas.hash_grupo(nuevo_tablero[i_nuevo]) > Grupo_fichas.hash_grupo(viejo_tablero[i_viejo]):
			eliminados.append(viejo_tablero[i_viejo])
			i_viejo += 1
		elif Grupo_fichas.hash_grupo(nuevo_tablero[i_nuevo]) < Grupo_fichas.hash_grupo(viejo_tablero[i_viejo]) :
			nuevos.append(nuevo_tablero[i_nuevo])
			i_nuevo += 1
		else:
			i_nuevo += 1; i_viejo += 1
	if i_viejo < viejo_tablero.size():
		eliminados.append_array(viejo_tablero.slice(i_viejo))
	if i_nuevo < nuevo_tablero.size():
		nuevos.append_array(nuevo_tablero.slice(i_nuevo))
	#elimina los que hay que quitar
	eliminados.map(func(grupo:Grupo_fichas): tablero.quitar_grupo_fichas(grupo); grupo.queue_free())
	
	nuevos = nuevos.map(
		func(grupo:Array): 
		var array_fichas: Array[Ficha] = []
		array_fichas.assign(grupo.map(
			func(ficha)->Ficha: 
				return manager_fichas.crear_ficha(ficha.color,ficha.numero))
			)
		return Grupo_fichas.Grupo_fichas(array_fichas)
		)
	
	var aux:Array[Grupo_fichas]
	aux.assign(nuevos)
	#inserta fichas nuevas
	tablero.insertar_grupos_fichas(aux)
#endregion

#region estados
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
#endregion

#region volver estado anterior

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
	tablero.fijar_tablero()

func boton_devolver_fichas() -> void:
	globales.estado_juego = globales.ESTADO_JUEGO.NO_PONIENDO_FICHAS
	devolverFichas.disabled = true
	pasarTurno.disabled = true
	robarCarta.disabled = false
	
	_devolver_fichas()


func _devolver_fichas() -> void:
	var arrayGrupos: Array[Grupo_fichas] = []
	for grupo: GrupoGuardado in grupos_en_tablero_antes:
		var ungrupo: Grupo_fichas = grupo.creaGrupo()
		ungrupo.cursor_sobre_grupo.connect(manager_fichas._entro_cursor_en_grupo) 
		ungrupo.cursor_no_sobre_grupo.connect(manager_fichas._salio_cursor_en_grupo)
		arrayGrupos.append(ungrupo)
	tablero.insertar_tablero(arrayGrupos)
	mano.insertar_mano(fichas_en_mano_antes)
#endregion

#region avanza partida
func hacer_jugada():
	var valido:bool = tablero.tablero_valido(abierto)
	if valido: 
		valido = await ConectorRed.hacer_jugada(tablero.grupos)
		if(valido):
			abierto = true
			guardar_estado()
			terminar_turno()
		else:
			print("TABLERO NO VALIDO al subirlo")
	else:
		print("TABLERO NO VALIDO local")

func robar_carta() -> void:
	var fich: Ficha
	robarCarta.disabled = true
	fich = await ConectorRed.robar(manager_fichas.crear_ficha)
	mano.devolver_ficha(fich)
	fich.z_index = 0
	guardar_estado()
	terminar_turno()

#endregion

var adversarios: Array[Dictionary] = [{"nombre":"jose maria", "icono": load("res://imagenes/Fernando.png") },{"nombre":"maria jose", "icono": load("res://imagenes/Fernando.png")} ]

## cada diccionario tiene dos claves una con el valor: "nombre" asociada a un String con el nombre del adversario,
## y otra con el valor "icono" asociada a un Texture2D con el icono del adversario
func get_adversarios() -> Array[Dictionary]:
	push_error("manager_juego.get_adversarios sin terminar")
	return adversarios
