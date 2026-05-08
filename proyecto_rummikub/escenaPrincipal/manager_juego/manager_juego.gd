extends Node2D

@export var robarCarta: Button
@export var pasarTurno: Button
@export var devolverFichas: Button
@export var miTurno: Button

@export var escena_principal: Node2D

@export var tablero: Node2D
@export var mano: Node2D
@export var manager_fichas: Node2D
@export var panel_contador_monedas: PanelContadorMonedas

@export var poder1: Poder
@export var poder2: Poder
@export var poder3: Poder

@export var pantalla_partida_pausada: Control
@export var boton_volver_partida_pausada: Button

var partida_terminada = false

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
<<<<<<< HEAD
var abierto: bool = true

=======
var abierto: bool = false
var hay_techo_de_cristal: bool = false
>>>>>>> offline
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	boton_volver_partida_pausada.pressed.connect(_volver_menu_inicio)
	globales.estado_cursor = globales.ESTADO_CURSOR.TABLERO
	fichas_en_mano_antes = []
	grupos_en_tablero_antes = []
	printerr("Hay que modificar el uso de la variable abierto para que funcione con los datos llegados de otros jugadores")
	abierto = true
	adversarios = await ConectorRed.get_adversarios()
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

<<<<<<< HEAD
#region gestion turnos
=======
func intenta_hacer_jugada() -> bool:
	if(tablero.tablero_valido(abierto and not hay_techo_de_cristal)):
		tablero.fijar_tablero()
		guardar_estado()
		terminar_turno()
		return true
	else:
		print("TABLERO NO VALIDO")
		return false
>>>>>>> offline

func terminar_turno() -> void:
	_devolver_fichas()
	#termina_turno.emit()
	globales.estado_juego = globales.ESTADO_JUEGO.NO_MI_TURNO
	robarCarta.disabled = true
	devolverFichas.disabled = true
	pasarTurno.disabled = true
<<<<<<< HEAD
	termina_turno.emit()
	await ConectorRed.espera_a_turno(llega_turno, terminar_partida)
	if not partida_terminada: iniciar_turno()
=======
	hay_techo_de_cristal = false
>>>>>>> offline

func iniciar_turno() -> void:
	guardar_estado()
	globales.estado_juego = globales.ESTADO_JUEGO.NO_PONIENDO_FICHAS
	robarCarta.disabled = false
	devolverFichas.disabled = true
	pasarTurno.disabled = true
	empieza_turno.emit()
	

<<<<<<< HEAD
## nuevo_tablero es Array de Array[FichasGuardar]
func llega_turno(nuevo_tablero: Array):
	var viejo_tablero: Array = tablero.grupos
	print("nuevo:")
	print(nuevo_tablero)
	print("viejo")
	viejo_tablero.map(func(grupo:Grupo_fichas): 
		print(grupo.fichas.reduce(func(accum, ficha:Ficha):
			return accum + str(ficha.color) + str(ficha.numero)+",","")))	
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
=======
func guardar_estado() -> void:
	print("GUARDANDO FICHAS")
	fichas_en_mano_antes = []
	var ficha_nueva: Ficha
	for ficha: Ficha in mano.fichas_en_mano:
		ficha_nueva = Ficha.ficha(ficha.color,ficha.numero, ficha.especial)
		globales.apropiar_hijo(self, ficha_nueva)
		fichas_en_mano_antes.append(ficha_nueva)
	var fichas_no_blancas: int = 0
	for ficha in fichas_en_mano_antes:
		if !ficha.en_blanco:
			fichas_no_blancas += 1
	print("Guardo "+ str(fichas_no_blancas))
>>>>>>> offline
	
	nuevos = nuevos.map(
		func(grupo:Array): 
		var array_fichas: Array[Ficha] = []
		array_fichas.assign(grupo.map(
			func(ficha)->Ficha: 
				return manager_fichas.crear_ficha(ficha.color,ficha.numero))
			)
		return Grupo_fichas.Grupo_fichas(array_fichas)
		)

<<<<<<< HEAD
	var aux:Array[Grupo_fichas]
	aux.assign(nuevos)
	#inserta fichas nuevas
	await tablero.insertar_grupos_fichas(aux)
	guardar_estado()

func terminar_partida(id_ganador, puntuacion):
	for jugador in adversarios:
		if jugador["id"] == id_ganador:
			$"../PantallaFinalPartida".sacar_pantalla_victoria(jugador["icono"],jugador["nombre"],puntuacion)
			return
	$"../PantallaFinalPartida".sacar_pantalla_victoria(globales.avatar,ConectorRed.username,puntuacion)
	partida_terminada = true

#endregion

#region estados
=======
>>>>>>> offline
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
	print("Guardar estado y terminar turno")
	guardar_estado()
	terminar_turno()

#endregion

var adversarios: Array[Dictionary] = [{"nombre":"debug", "icono": load("res://imagenes/avatares_posibles/Fernando.png") },{"nombre":"maria jose", "icono": load("res://imagenes/avatares_posibles/Fernando.png")} ]

## cada diccionario tiene dos claves una con el valor: "nombre" asociada a un String con el nombre del adversario,
## y otra con el valor "icono" asociada a un Texture2D con el icono del adversario
func get_adversarios() -> Array[Dictionary]:
	return adversarios

func puntuar_ficha(especial: Ficha.ESPECIAL):
	match(especial):
		Ficha.ESPECIAL.NO:
			panel_contador_monedas.aumentar_dinero(1)
			
		Ficha.ESPECIAL.DORADO:
			panel_contador_monedas.aumentar_dinero(2)
			
		Ficha.ESPECIAL.ARCOIRIS:
			panel_contador_monedas.aumentar_dinero(1)
			var poder_elegido: Poder.PODER = randi_range(1, 8) as Poder.PODER 
			if poder1.get_poder() == Poder.PODER.NINGUNO:
				poder1.cambiar_poder(poder_elegido)
			elif poder2.get_poder() == Poder.PODER.NINGUNO:
				poder2.cambiar_poder(poder_elegido)
			elif poder3.get_poder() == Poder.PODER.NINGUNO:
				poder3.cambiar_poder(poder_elegido)
				
		Ficha.ESPECIAL.DORADARCOIRIS:
			panel_contador_monedas.aumentar_dinero(2)
			var poder_elegido: Poder.PODER = randi_range(1, 8) as Poder.PODER 
			if poder1.get_poder() == Poder.PODER.NINGUNO:
				poder1.cambiar_poder(poder_elegido)
			elif poder2.get_poder() == Poder.PODER.NINGUNO:
				poder2.cambiar_poder(poder_elegido)
			elif poder3.get_poder() == Poder.PODER.NINGUNO:
				poder3.cambiar_poder(poder_elegido)

func pausarPartida()->void:
	pantalla_partida_pausada.visible = true

func _volver_menu_inicio()->void:
	get_tree().change_scene_to_file.bind("res://proyecto_rummikub/menuInicio/menuInicio.tscn").call_deferred()

func toque_de_midas() -> void:
	var fichas_totales = mano.fichas_en_mano.size()
	var fichas_a_elegir: int = min(fichas_totales-mano.contar_blancas(), 4)
	var cartas_elegidas: Array[int] = []
	while cartas_elegidas.size() < fichas_a_elegir:
		var numero_elegido: int = randi_range(0,fichas_totales-1)
		if !cartas_elegidas.has(numero_elegido) and !mano.fichas_en_mano[numero_elegido].en_blanco:
			cartas_elegidas.append(numero_elegido)
	
	for carta: int in cartas_elegidas:
		mano.fichas_en_mano[carta].volver_dorada()

func angel_guarda_check() -> bool:
	if poder1.get_poder() == Poder.PODER.ANGEL_GUARDA:
		poder1.cambiar_poder(Poder.PODER.NINGUNO)
		PopUp.popUp("tu angel de la guarda\n te ha protegido!",Vector2(-74.0, -300.0), escena_principal)
		return true
	elif poder2.get_poder() == Poder.PODER.ANGEL_GUARDA:
		poder2.cambiar_poder(Poder.PODER.NINGUNO)
		PopUp.popUp("tu angel de la guarda\n te ha protegido!",Vector2(-74.0, -300.0), escena_principal)
		return true
	elif poder3.get_poder() == Poder.PODER.ANGEL_GUARDA:
		poder3.cambiar_poder(Poder.PODER.NINGUNO)
		PopUp.popUp("tu angel de la guarda\n te ha protegido!",Vector2(-74.0, -300.0), escena_principal)
		return true
	else: 
		return false

func guindilla_en_el_culo() -> void:
	$ContadorTiempoTurno.reducir_a_mitad_tiempo()
	PopUp.popUp("este turno tienes\n la mitad de tiempo!",Vector2(-74.0, -300.0), escena_principal)

func techo_de_cristal() -> void:
	PopUp.popUp("este turno la jugada\n tiene que sumar 30!",Vector2(-74.0, -300.0), escena_principal)
	hay_techo_de_cristal = true
