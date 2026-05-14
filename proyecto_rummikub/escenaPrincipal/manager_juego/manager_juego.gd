class_name ManagerJuego extends Node2D
#region vars
@export var robarCarta: Button
@export var pasarTurno: Button
@export var devolverFichas: Button
@export var miTurno: Button

@export var escena_principal: Node2D

@export var tablero: Node2D
@export var mano: Node2D
@export var manager_fichas: Node2D
@export var panel_contador_monedas: PanelContadorMonedas

@export var tienda: TiendaFueraPartida
@export var poder1: Poder 
@export var poder2: Poder
@export var poder3: Poder
var poderes = [poder1,poder2,poder3]

@export var niebla: Niebla
@export var bola_de_cristal: BolaDeCristal

@export var pantalla_partida_pausada: Control
@export var boton_volver_partida_pausada: Button

var partida_terminada = false

var es_arcade

signal empieza_turno
signal termina_turno

<<<<<<< HEAD
class GrupoGuardado:
=======
class GrupoGuardado extends Node2D:
>>>>>>> 6b8c28a6630d801cd83d387d2665a7b6e9ff080f
	var grupo: Array[Ficha]
	var posicion: Vector2
	var posiciones: Array[Vector2]
	
	func _init(mgrupo: Array[Ficha], mposicion: Vector2) -> void:
		posiciones = []
		for ficha in mgrupo:
			globales.apropiar_hijo(self, ficha)
		grupo = mgrupo
		posicion = mposicion
		for ficha:Ficha in mgrupo:
			posiciones.append(ficha.position)
	
	func creaGrupo()-> Grupo_fichas:
		var res = Grupo_fichas.Grupo_fichas(grupo)
		assert(grupo.all(func(fich):return fich != null))
<<<<<<< HEAD
		for ficha in grupo:
			ficha.cancel_free()
=======
		var i = 0
		for ficha in res.fichas:
			ficha.position = posiciones[i]
			i += 1
>>>>>>> 6b8c28a6630d801cd83d387d2665a7b6e9ff080f
		res.position = posicion
		return res

var poderes_disponibles_a_compra: Array[Poder.PODER] = [Poder.PODER.TRUEQUE, Poder.PODER.TECHO_CRISTAL, Poder.PODER.BOMBA_HUMO, Poder.PODER.BOLA_CRISTAL]

var fichas_en_mano_antes: Array[Ficha]
var grupos_en_tablero_antes: Array[GrupoGuardado]

enum EVENTO{DESCUENTO, SIN_COLOR, NO_EVENTO, ROBAR_OTRA_FICHA}

# la primera jugada tiene que sumar 30, esta variable cuenta si la primera jugada a ocurrido ya o no
var abierto: bool = false
var hay_techo_de_cristal: bool = false
var evento_ocurriendo: EVENTO = EVENTO.NO_EVENTO
var color_prohibido: Ficha.COLOR = Ficha.COLOR.BLANCO
#endregion
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	boton_volver_partida_pausada.pressed.connect(_volver_menu_inicio)
	globales.estado_cursor = globales.ESTADO_CURSOR.TABLERO
	fichas_en_mano_antes = []
	grupos_en_tablero_antes = []
	adversarios = await ConectorRed.get_adversarios()
	#botones
	robarCarta.pressed.connect(robar_carta)
	pasarTurno.pressed.connect(intenta_hacer_jugada)
	devolverFichas.pressed.connect(boton_devolver_fichas)
	@warning_ignore("shadowed_variable")
	var info_inicial:Dictionary = await ConectorRed.inicializar_partida(manager_fichas.crear_ficha)
	
	(info_inicial["mano"])
	if es_arcade:
		for poder in info_inicial["poderes"]:
			insertar_poder(poder)
		
	guardar_estado()
	$ContadorTiempoTurno.proceso_contador()
	terminar_turno()

#region gestion turnos
func intenta_hacer_jugada() -> bool:
	if  (tablero.tablero_valido(abierto and (not hay_techo_de_cristal))) and \
			(not(evento_ocurriendo == EVENTO.SIN_COLOR and tablero.detectar_color_sin_fijar(color_prohibido))):
		
		if(await ConectorRed.hacer_jugada(tablero.grupos)):
			abierto = true
			guardar_estado()
			terminar_turno()
		else:
			print("TABLERO NO VALIDO al subirlo")
		return true
	else:
		if tablero.combinando_fijadas_y_no_fijadas() and (not abierto):
			PopUp.popUp(" no se pueden usar fichas \n del tablero si no has abierto ",Vector2(-74.0, -300.0), escena_principal)
		elif tablero.combinando_fijadas_y_no_fijadas() and (hay_techo_de_cristal):
			PopUp.popUp(" no se pueden usar fichas del tablero \n porque te han lanzado techo de cristal ",Vector2(-74.0, -300.0), escena_principal)
		elif tablero.tablero_valido(true):
			PopUp.popUp(" las fichas tienen \n que sumar 30 ",Vector2(-74.0, -300.0), escena_principal)
		elif evento_ocurriendo == EVENTO.SIN_COLOR and tablero.detectar_color_sin_fijar(color_prohibido):
			PopUp.popUp(" este turno no se puede usar \n el color "+ Ficha.color_a_string(color_prohibido),Vector2(-74.0, -300.0), escena_principal)
		else:
			PopUp.popUp(" las fichas estan mal colocadas ",Vector2(-74.0, -300.0), escena_principal)
		return false

func terminar_turno() -> void:
	_devolver_fichas() 
	guardar_estado()
	termina_turno.emit()
	globales.estado_juego = globales.ESTADO_JUEGO.NO_MI_TURNO
	robarCarta.disabled = true
	devolverFichas.disabled = true
	pasarTurno.disabled = true
	hay_techo_de_cristal = false
	if niebla.hay_humo():
		quitar_bomba_de_humo()
	reiniciar_eventos()
	await ConectorRed.espera_a_turno(llega_turno, terminar_partida,func():$"../PantallaPartidaPausada".visible = true)
	if not partida_terminada: iniciar_turno()


func iniciar_turno() -> void:
<<<<<<< HEAD
	if es_arcade:
		printerr("a")
		poderes_disponibles_a_compra = []
		var efectos: Array
		efectos = []
		var poderes_nuevo_turno: Array
		poderes_nuevo_turno = []
		panel_contador_monedas.set_dinero(str(await ConectorRed.poderes(poderes_disponibles_a_compra,efectos,poderes_nuevo_turno)))
		printerr("b")
		for poder in efectos: 
			if (angel_guarda_check()):
				ConectorRed.angel()
			else:
				recibir_efecto(poder)
		var evento = ConectorRed.evento_actual()
		printerr("c")
		lanzar_evento(evento[0],evento[1])
		printerr("d")
=======
	_devolver_fichas()
>>>>>>> 6b8c28a6630d801cd83d387d2665a7b6e9ff080f
	guardar_estado()
	printerr("e")
	globales.estado_juego = globales.ESTADO_JUEGO.NO_PONIENDO_FICHAS
	robarCarta.disabled = false
	devolverFichas.disabled = true
	pasarTurno.disabled = true
	#aplicar evento o poder de rival
	empieza_turno.emit()

func lanzar_evento(evento: EVENTO, color_no_permitido: Ficha.COLOR = Ficha.COLOR.BLANCO) -> void:
	evento_ocurriendo = evento
	match (evento):
		EVENTO.NO_EVENTO:
			pass
		EVENTO.DESCUENTO:
			PopUp.popUp(" este turno los objetos \n estan de descuento! ",Vector2(-74.0, -300.0), escena_principal)
			tienda.aplicar_descuento()
		EVENTO.SIN_COLOR:
			PopUp.popUp(" este turno no se puede usar \n el color " + Ficha.color_a_string(color_no_permitido) + "!",Vector2(-74.0, -300.0), escena_principal, true)
			color_prohibido = color_no_permitido
		EVENTO.ROBAR_OTRA_FICHA:
			var fich = await ConectorRed.robar_sin_pasar(manager_fichas.crear_ficha)
			mano.devolver_ficha(fich[0])
			fich[0].z_index = 0
			PopUp.popUp(" te toca robar ficha \n mala suerte " + Ficha.color_a_string(color_no_permitido) + "!",Vector2(-74.0, -300.0), escena_principal, true)
			evento_ocurriendo = EVENTO.NO_EVENTO

func reiniciar_eventos() -> void:
	evento_ocurriendo=EVENTO.NO_EVENTO
	color_prohibido = Ficha.COLOR.BLANCO
	tienda.quitar_descuento()

## nuevo_tablero es Array de Array[FichasGuardar]
func llega_turno(nuevo_tablero: Array):
	var viejo_tablero: Array = tablero.grupos
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
	await tablero.insertar_grupos_fichas(aux)
	guardar_estado()

func terminar_partida(id_ganador, puntuacion):
	print(puntuacion)
	for jugador in adversarios:
		if jugador["id"] == id_ganador:
			$"../PantallaFinalPartida".sacar_pantalla_victoria(jugador["icono"],jugador["nombre"],puntuacion)
			return
	$"../PantallaFinalPartida".sacar_pantalla_victoria(globales.avatar,ConectorRed.username,puntuacion)
	partida_terminada = true
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
	fichas_en_mano_antes = []
	tablero.fijar_tablero()
	print("GUARDANDO FICHAS")
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
<<<<<<< HEAD
	grupos_en_tablero_antes = []
	for grupo in tablero.grupos:
		grupos_en_tablero_antes.append(GrupoGuardado.new(grupo.fichas.duplicate(),grupo.position))
=======
	for grupo: Grupo_fichas in tablero.grupos:
		var grupo_aux: GrupoGuardado = GrupoGuardado.new(grupo.fichas,grupo.position)
		globales.apropiar_hijo(self, grupo_aux)
		grupos_en_tablero_antes.append(grupo_aux)

>>>>>>> 6b8c28a6630d801cd83d387d2665a7b6e9ff080f

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
func robar_carta() -> void:
	var fich: Ficha
	globales.estado_juego = globales.ESTADO_JUEGO.NO_MI_TURNO
	robarCarta.disabled = true
	$ContadorTiempoTurno._termina_turno()
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

func insertar_poder(poder:Poder.PODER):
	if poder1.get_poder() == Poder.PODER.NINGUNO:
		poder1.cambiar_poder(poder)
	elif poder2.get_poder() == Poder.PODER.NINGUNO:
		poder2.cambiar_poder(poder)
	elif poder3.get_poder() == Poder.PODER.NINGUNO:
		poder3.cambiar_poder(poder)

func puntuar_ficha(especial: Ficha.ESPECIAL):
	match(especial):
		Ficha.ESPECIAL.NO:
			panel_contador_monedas.aumentar_dinero(1)
			
		Ficha.ESPECIAL.DORADO:
			panel_contador_monedas.aumentar_dinero(2)
			
		Ficha.ESPECIAL.ARCOIRIS:
			panel_contador_monedas.aumentar_dinero(1)
			
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

#region Aplicar a uno mismo
func recibir_efecto(poder: Poder.PODER):
	match poder:
		Poder.PODER.TRUEQUE:
			trueque_mi()
		Poder.PODER.GUANTE_BLANCO:
			guante_blanco_mi()
		Poder.PODER.MAS_CUATRO:
			mas_cuatro_mi()
		Poder.PODER.BOMBA_HUMO:
			bomba_de_humo_mi()
		Poder.PODER.REDUCIR_TIEMPO:
			guindilla_en_el_culo_mi()
		Poder.PODER.TECHO_CRISTAL:
			techo_de_cristal_mi()

func toque_de_midas_mi() -> void:
	var mano_dorada : Array[Ficha] = await ConectorRed.midas()
	mano.insertar_mano(mano_dorada)

func angel_guarda_check() -> bool:
	if poder1.get_poder() == Poder.PODER.ANGEL_GUARDA:
		poder1.cambiar_poder(Poder.PODER.NINGUNO)
		PopUp.popUp(" tu angel de la guarda \n te ha protegido! ",Vector2(-74.0, -300.0), escena_principal)
		return true
	elif poder2.get_poder() == Poder.PODER.ANGEL_GUARDA:
		poder2.cambiar_poder(Poder.PODER.NINGUNO)
		PopUp.popUp(" tu angel de la guarda \n te ha protegido! ",Vector2(-74.0, -300.0), escena_principal)
		return true
	elif poder3.get_poder() == Poder.PODER.ANGEL_GUARDA:
		poder3.cambiar_poder(Poder.PODER.NINGUNO)
		PopUp.popUp(" tu angel de la guarda \n te ha protegido! ",Vector2(-74.0, -300.0), escena_principal)
		return true
	else: 
		return false

func guindilla_en_el_culo_mi() -> void:
	$ContadorTiempoTurno.reducir_a_mitad_tiempo()
	PopUp.popUp(" este turno tienes \n la mitad de tiempo! ",Vector2(-74.0, -300.0), escena_principal)

func techo_de_cristal_mi() -> void:
	PopUp.popUp(" este turno la jugada \n tiene que sumar 30! ",Vector2(-74.0, -300.0), escena_principal)
	hay_techo_de_cristal = true

func bomba_de_humo_mi() -> void:
	PopUp.popUp(" te han lanzado una \n bomba de humo! ",Vector2(-74.0, -300.0), escena_principal)
	niebla.empezar_niebla()
	await get_tree().create_timer(3.5).timeout
	tablero.ocultar_numeros()

func mas_cuatro_mi() -> void:
	PopUp.popUp(" otro jugador te ha hecho \n robar 4 cartas! ",Vector2(-74.0, -300.0), escena_principal)
	var fichs = await ConectorRed.robar_sin_pasar(manager_fichas.crear_ficha,4)
	for fich in fichs:
		mano.devolver_ficha(fich)
		fich.z_index = 0

func bola_de_cristal_mi()->void:
	pass #esta bien

func trueque_mi()->void:
	mano.insertar_mano(await ConectorRed.mano())

func guante_blanco_mi()->void:
	pass #esta terminado

#endregion
func quitar_bomba_de_humo() -> void:
	PopUp.popUp("el humo se disipa\n",Vector2(-74.0, -300.0), escena_principal)
	niebla.terminar_niebla()
	await get_tree().create_timer(3.5).timeout
	tablero.revelar_numeros()

#region Aplicar a los demas
func usar_bola_de_cristal(adversario: String) -> void:
	# get_cartas_adversario (siguientes dos lineas de placeholder)
	var dict = await ConectorRed.bola_de_cristal(get_id_adversario(adversario))
	var cartas_adversario: Array[Ficha]
	cartas_adversario.assign(dict["fichas"])
	var poderes_adversario: Array[Poder.PODER]
	poderes_adversario.assign(dict["fichas"])
	await bola_de_cristal.mostrar_bola(cartas_adversario, poderes_adversario)
	await  get_tree().create_timer(7.0).timeout
	bola_de_cristal.esconder_bola()

## Usada para techo de cristal, bomba de humo, reducir tiempo y mas 4
func lanzar_maldicion(adversario: String, maldicion: Poder.PODER) -> void:
	match(maldicion):
		# enviar mensaje a los demas
		Poder.PODER.TECHO_CRISTAL:
			ConectorRed.techo(get_id_adversario(adversario))
		Poder.PODER.BOMBA_HUMO:
			ConectorRed.bomba_de_humo(get_id_adversario(adversario))
		Poder.PODER.REDUCIR_TIEMPO:
			ConectorRed.guindilla(get_id_adversario(adversario))
		Poder.PODER.MAS_CUATRO:
			ConectorRed.mas_cuatro(get_id_adversario(adversario))

func usar_guante_blanco(_adversario: String) -> Poder.PODER:
	print(_adversario)
	var poder_robado: Poder.PODER = Poder.PODER.ANGEL_GUARDA
	# cosas que devuelven el poder robado
	if poder_robado == Poder.PODER.NINGUNO:
		PopUp.popUp(" el jugador al que has intentado robar \n no tiene ningun poder D: ",Vector2(-74.0, -300.0), escena_principal)
	else:
		PopUp.popUp(" has conseguido robar \n un " + Poder.poder_a_string(poder_robado) + "! " ,Vector2(-74.0, -300.0), escena_principal)
	return poder_robado

# esta funcion devuelve un array con 3 fichas de las cuales el jugador eligira una
# sera entonces cuando se llame a usar_trueque2
# si el adversario tiene menos de 3 fichas rellenar con nulls
func usar_trueque1(adversario: String) -> Array[Ficha]:
	var fichas = await ConectorRed.trueque(get_id_adversario(adversario))
	mano.visible=false
	var fichas_a_tomar: int = min(fichas.size(),3)
	var indice1 = -1
	var indice2 = -1
	var indice3 = -1
	match(fichas_a_tomar):
		1:
			indice1 = randi_range(0, fichas.size()-1)
		2:
			while((indice1 == indice2) or (indice1 == -1 or indice2 == -1)):
				indice1 = randi_range(0, fichas.size()-1)
				indice2 = randi_range(0, fichas.size()-1)
		3:
			while(indice1 == indice2 or indice2 == indice3 or indice3 == indice1 or (indice1 == -1 or indice2 == -1 or indice3 == -1)):
				indice1 = randi_range(0, fichas.size()-1)
				indice2 = randi_range(0, fichas.size()-1)
				indice3 = randi_range(0, fichas.size()-1)
	var fichas_devolver: Array[Ficha] = []
	fichas_devolver.append(get_fichas_mano_no_blancas()[indice1])
	if indice2 != -1:
		fichas_devolver.append(get_fichas_mano_no_blancas()[indice2])
	if indice3 != -1:
		fichas_devolver.append(get_fichas_mano_no_blancas()[indice3])
	return fichas_devolver

# esta funcion intercambia una ficha propia con una ficha del rival
func usar_trueque2(adversario: String, ficha_propia: Ficha, ficha_rival: Ficha) -> void:
	ConectorRed.confirma_trueque(get_id_adversario(adversario),ficha_propia,ficha_rival)
	manager_fichas.conectar_ficha(ficha_rival)
	mano.insertar_ficha(ficha_rival, ficha_propia)

#endregnion

func get_fichas_mano() -> Array[Ficha]:
	return mano.fichas_en_mano
func get_id_adversario(s:String):
	for adv in adversarios:
		if s == adv["nombre"]:
			return adv["id"]
	assert(false,"pero keeeeee")
func get_fichas_mano_no_blancas() -> Array[Ficha]:
	var fichas: Array[Ficha] = []
	for ficha: Ficha in get_fichas_mano():
		if not ficha.en_blanco:
			fichas.append(ficha)
	return fichas

func hacer_mano_visible()->void:
	mano.visible=true

func get_poderes_comprar() -> Array[Poder.PODER]:
	return poderes_disponibles_a_compra
