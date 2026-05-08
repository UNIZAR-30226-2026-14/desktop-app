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
var hay_techo_de_cristal: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	boton_volver_partida_pausada.pressed.connect(_volver_menu_inicio)
	globales.estado_cursor = globales.ESTADO_CURSOR.TABLERO
	fichas_en_mano_antes = []
	grupos_en_tablero_antes = []
	abierto = false
	robarCarta.pressed.connect(robar_carta)
	pasarTurno.pressed.connect(intenta_hacer_jugada)
	devolverFichas.pressed.connect(_boton_devolver_fichas)
	miTurno.pressed.connect(iniciar_turno)

func intenta_hacer_jugada() -> bool:
	if(tablero.tablero_valido(abierto and not hay_techo_de_cristal)):
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
	hay_techo_de_cristal = false

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
