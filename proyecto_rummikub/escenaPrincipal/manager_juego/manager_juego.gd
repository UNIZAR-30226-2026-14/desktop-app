class_name ManagerJuego extends Node2D

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

@export var niebla: Niebla
@export var bola_de_cristal: BolaDeCristal

@export var pantalla_partida_pausada: Control
@export var boton_volver_partida_pausada: Button

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

var poderes_disponibles_a_compra: Array[Poder.PODER] = [
	Poder.PODER.TRUEQUE, Poder.PODER.TECHO_CRISTAL, Poder.PODER.BOMBA_HUMO, Poder.PODER.BOLA_CRISTAL,
	]

var fichas_en_mano_antes: Array[Ficha]
var grupos_en_tablero_antes: Array[GrupoGuardado]

enum EVENTO{DESCUENTO, SIN_COLOR, NO_EVENTO, ROBAR_OTRA_FICHA}

# la primera jugada tiene que sumar 30, esta variable cuenta si la primera jugada a ocurrido ya o no
var abierto: bool = false
var hay_techo_de_cristal: bool = false
var evento_ocurriendo: EVENTO = EVENTO.NO_EVENTO
var color_prohibido: Ficha.COLOR = Ficha.COLOR.BLANCO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	boton_volver_partida_pausada.pressed.connect(_volver_menu_inicio)
	globales.estado_cursor = globales.ESTADO_CURSOR.TABLERO
	fichas_en_mano_antes = []
	grupos_en_tablero_antes = []
	robarCarta.pressed.connect(robar_carta)
	pasarTurno.pressed.connect(intenta_hacer_jugada)
	devolverFichas.pressed.connect(_boton_devolver_fichas)
	miTurno.pressed.connect(iniciar_turno)

func intenta_hacer_jugada() -> bool:
	
	if  (tablero.tablero_valido(abierto and (not hay_techo_de_cristal))) and (not(evento_ocurriendo == EVENTO.SIN_COLOR and tablero.detectar_color_sin_fijar(color_prohibido))):
		tablero.fijar_tablero()
		guardar_estado()
		terminar_turno()
		abierto = true
		return true
	else:
		if tablero.tablero_valido(true):
			PopUp.popUp("las fichas tienen \n que sumar 30 ",Vector2(-74.0, -300.0), escena_principal)
		elif evento_ocurriendo == EVENTO.SIN_COLOR and tablero.detectar_color_sin_fijar(color_prohibido):
			PopUp.popUp(" este turno no se puede usar \n el color "+ Ficha.color_a_string(color_prohibido),Vector2(-74.0, -300.0), escena_principal)
		else:
			PopUp.popUp(" las fichas estan mal colocadas ",Vector2(-74.0, -300.0), escena_principal)
		return false

func terminar_turno() -> void:
	_devolver_fichas()
	termina_turno.emit()
	globales.estado_juego = globales.ESTADO_JUEGO.NO_MI_TURNO
	robarCarta.disabled = true
	devolverFichas.disabled = true
	pasarTurno.disabled = true
	hay_techo_de_cristal = false
	if niebla.hay_humo():
		quitar_bomba_de_humo()
	reiniciar_eventos()

static var a:int = 0

func iniciar_turno() -> void:
	guardar_estado()
	globales.estado_juego = globales.ESTADO_JUEGO.NO_PONIENDO_FICHAS
	robarCarta.disabled = false
	
	devolverFichas.disabled = true
	pasarTurno.disabled = true
	
	#aplicar evento o poder de rival
	
	empieza_turno.emit()

func lanzar_evento(evento: EVENTO, color_no_permitido: Ficha.COLOR = Ficha.COLOR.BLANCO) ->void:
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
			# hacer cosas 
			PopUp.popUp(" te toca robar ficha \n mala suerte " + Ficha.color_a_string(color_no_permitido) + "!",Vector2(-74.0, -300.0), escena_principal, true)
			evento_ocurriendo = EVENTO.NO_EVENTO

func reiniciar_eventos() -> void:
	evento_ocurriendo=EVENTO.NO_EVENTO
	color_prohibido = Ficha.COLOR.BLANCO
	tienda.quitar_descuento()

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
	print("Guardar estado y terminar turno")
	guardar_estado()
	terminar_turno()

var adversarios: Array[Dictionary] = [{"nombre":"jose maria", "icono": load("res://imagenes/Fernando.png") },{"nombre":"maria jose", "icono": load("res://imagenes/Fernando.png")} ]

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

#region Aplicar a uno mismo
func toque_de_midas_mi() -> void:
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
	# hacer cosas

func bola_de_cristal_mi()->void:
	var fichas: Array[Ficha] = get_fichas_mano_no_blancas()
	var poderes: Array[Poder.PODER] = [poder1.get_poder(),poder2.get_poder(),poder3.get_poder()]
	# enviar a rival

func trueque1_mi()->void:
	var mis_fichas: Array[Ficha] = get_fichas_mano_no_blancas()
	var fichas_a_tomar: int = min(mis_fichas.size(),3)
	var indice1 = -1
	var indice2 = -1
	var indice3 = -1
	
	match(fichas_a_tomar):
		1:
			indice1 = randi_range(0, mis_fichas.size()-1)
		2:
			while((indice1 == indice2) or (indice1 == -1 or indice2 == -1)):
				indice1 = randi_range(0, mis_fichas.size()-1)
				indice2 = randi_range(0, mis_fichas.size()-1)
		3:
			while(indice1 == indice2 or indice2 == indice3 or indice3 == indice1 or (indice1 == -1 or indice2 == -1 or indice3 == -1)):
				indice1 = randi_range(0, mis_fichas.size()-1)
				indice2 = randi_range(0, mis_fichas.size()-1)
				indice3 = randi_range(0, mis_fichas.size()-1)
	
	var fichas_devolver: Array[Ficha] = []
	
	fichas_devolver.append(get_fichas_mano_no_blancas()[indice1])
	if indice2 != -1:
		fichas_devolver.append(get_fichas_mano_no_blancas()[indice2])
	if indice3 != -1:
		fichas_devolver.append(get_fichas_mano_no_blancas()[indice3])
	# enviar fichas_devolver

func trueque2_mi()->void:
	# get ficha suya que me quedo (siguiente linea de placeholder)
	var ficha_suya: Ficha = Ficha.ficha(Ficha.COLOR.ROJO, 10, Ficha.ESPECIAL.ARCOIRIS)
	# get ficha mia que se va (siguiente linea de placeholder)
	var ficha_nuestra_se_va: Ficha = get_fichas_mano()[0]
	
	manager_fichas.conectar_ficha(ficha_suya)
	mano.insertar_ficha(ficha_suya, ficha_nuestra_se_va)

func guante_blanco_mi()->void:
	# get poder que se va
	var poder_robado: Poder.PODER = Poder.PODER.ANGEL_GUARDA
	PopUp.popUp(" te han robado \n un " + Poder.poder_a_string(poder_robado) + "! " ,Vector2(-74.0, -300.0), escena_principal)
	if poder1.get_poder() == poder_robado:
		poder1.cambiar_poder(Poder.PODER.NINGUNO)
	elif poder2.get_poder() == poder_robado:
		poder2.cambiar_poder(Poder.PODER.NINGUNO)
	elif poder3.get_poder() == poder_robado:
		poder3.cambiar_poder(Poder.PODER.NINGUNO)

#endregion

func quitar_bomba_de_humo() -> void:
	PopUp.popUp("el humo se disipa\n",Vector2(-74.0, -300.0), escena_principal)
	niebla.terminar_niebla()
	await get_tree().create_timer(3.5).timeout
	tablero.revelar_numeros()

#region Aplicar a los demas
func usar_bola_de_cristal(_adversario: String) -> void:
	# get_cartas_adversario (siguientes dos lineas de placeholder)
	var cartas_adversario: Array[Ficha] = [Ficha.ficha(Ficha.COLOR.ROJO,10,Ficha.ESPECIAL.NO), Ficha.ficha(Ficha.COLOR.NEGRO,3,Ficha.ESPECIAL.DORADO), Ficha.ficha(Ficha.COLOR.AMARILLO,8,Ficha.ESPECIAL.ARCOIRIS), Ficha.ficha(Ficha.COLOR.NEGRO,4,Ficha.ESPECIAL.NO)]
	var poderes_adversario: Array[Poder.PODER] = [Poder.PODER.NINGUNO,Poder.PODER.ANGEL_GUARDA,Poder.PODER.TOQUE_MIDAS] 
	
	await bola_de_cristal.mostrar_bola(cartas_adversario, poderes_adversario)
	await  get_tree().create_timer(7.0).timeout
	bola_de_cristal.esconder_bola()

## Usada para techo de cristal, bomba de humo, reducir tiempo y mas 4
func lanzar_maldicion(adversario: String, maldicion: Poder.PODER) -> void:
	match(maldicion):
		# enviar mensaje a los demas
		Poder.PODER.TECHO_CRISTAL:
			pass
		Poder.PODER.BOMBA_HUMO:
			pass
		Poder.PODER.REDUCIR_TIEMPO:
			pass
		Poder.PODER.MAS_CUATRO:
			pass

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
func usar_trueque1(_adversaro: String) -> Array[Ficha]:
	# get_fichas de adversario
	# pongo unas fichas de ejemplo:
	mano.visible=false
	return [Ficha.ficha(Ficha.COLOR.NEGRO,2), Ficha.ficha(Ficha.COLOR.ROJO,3,Ficha.ESPECIAL.ARCOIRIS), Ficha.ficha(Ficha.COLOR.AZUL,4,Ficha.ESPECIAL.DORADO)]

# esta funcion intercambia una ficha propia con una ficha del rival
func usar_trueque2(_adversario: String, _ficha_propia: Ficha, _ficha_rival: Ficha) -> void:
	manager_fichas.conectar_ficha(_ficha_rival)
	mano.insertar_ficha(_ficha_rival, _ficha_propia)
	# set_ficha al adversario
	pass

#endregion

func get_fichas_mano() -> Array[Ficha]:
	return mano.fichas_en_mano

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
