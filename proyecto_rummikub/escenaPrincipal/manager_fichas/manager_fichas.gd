extends Node2D
@export var mano: Node2D
@export var tablero: Node2D
@export var manager_juego: Node2D

# cuanto aumenta la escala del la carta al poner el cursor sobre ella
@export var escala_aumentada: Vector2 = Vector2(0.7,  0.7) 
# escalado por defecto de las cartas
@export var escala_por_defecto: Vector2 = Vector2(0.5,  0.5) 

@export var robarCarta: Button

@export var pasarTurno: Button
@export var devolverFichas: Button

const grupo = preload("res://proyecto_rummikub/ficha/grupo_fichas.tscn")

var max_fichas: int = 10 # es para debuggear

var clicando: bool = false # indica si se esta pulsando el clic izquierdo
var grupo_arrastrado: Grupo_fichas = null
var sobre_ficha: Ficha = null # porta el indice de la carta sobre la que esta el cursor, si no es nadie se pone un -1
var sobre_grupo: Grupo_fichas = null
var sobre_poder: Poder = null
var sobre_lado_grupo
var vengo_de_tablero: bool = false
var grupo_de_origen: Grupo_fichas
var posicion_original_grupo: Transform2D

var estado_cursor # puede ser: MANO, TABLERO, LIMBO
var posicion_clic: Vector2 # guarda la posiocion del cursor mientras esta pulsado el clic izquierdo

var lista_fichas: Array[Ficha] # lista de objetos carta
var indice_lista_fichas: int = 0 # numero de cartas en pantalla

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for ficha in mano.fichas_en_mano:
		conectar_ficha(ficha)

func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton) and (event.button_index == MOUSE_BUTTON_LEFT):
	# se entra cuando se pulsa o despulsa el clic iquierdo del raton
		if event.is_pressed() and sobre_poder != null:
			sobre_poder.ejecutar_poder()
		
		elif (sobre_ficha != null && not sobre_ficha.en_blanco) and event.is_pressed(): 
		# si se pulsa sobre un espacio no vacio 
			posicion_clic = get_global_mouse_position()
			clicando = true 
			click_izquierdo(sobre_ficha)
			grupo_arrastrado.z_index += 1 # se aumenta su prioridad para que aparezca sobre el resto de cartas

		elif event.is_released():
		# si se deja de clicar
			if(grupo_arrastrado != null && clicando): # se suelta un grupo
				grupo_arrastrado.z_index -= 1 
				if(globales.estado_cursor==globales.ESTADO_CURSOR.MANO 
					or globales.estado_cursor==globales.ESTADO_CURSOR.LIMBO
					or globales.estado_juego == globales.ESTADO_JUEGO.NO_MI_TURNO): # se suelta un grupo en la mano o en un lugar invalido
					print("Intento devolver", )
					desresaltar_grupo(grupo_arrastrado)
					if (not grupo_arrastrado.contengo_ficha_fijada()) and (not (vengo_de_tablero and (globales.ESTADO_CURSOR.LIMBO== globales.estado_cursor))):
						# cuando no se mete un grupo fijado ni se mete un grupo que vaya desde el tablero a una posicion invalida
						# se devuelve a la mano
						for ficha in grupo_arrastrado.fichas :
							print("Devuelvo a mano")
							if(sobre_ficha != null and sobre_ficha.en_blanco and grupo_arrastrado.fichas.size() == 1):
								mano.insertar_ficha(ficha, sobre_ficha)
							else:
								mano.devolver_ficha(ficha)
						grupo_arrastrado.queue_free()
						quitando_fichas()
					else:
						# se devuelve al tablero
						if(grupo_de_origen == null):
							# si el grupo de donde venia ya no existe se tiene que volver a conectar y meter
							grupo_arrastrado.transform = posicion_original_grupo
							grupo_arrastrado.cursor_sobre_grupo.connect(_entro_cursor_en_grupo)
							grupo_arrastrado.cursor_no_sobre_grupo.connect(_salio_cursor_en_grupo)
							$tablero.anadir_grupo_fichas(grupo_arrastrado)
							if not grupo_arrastrado.todas_son_fichas_fijadas():
								poniendo_fichas()
						else:
							# si sigue existiendo se conecta
							grupo_de_origen.anadir_grupo_fin(grupo_arrastrado)
						
				elif(sobre_grupo == null || sobre_grupo == grupo_arrastrado): # se arrastra sobre lugar del tablero vacio
					grupo_arrastrado.cursor_sobre_grupo.connect(_entro_cursor_en_grupo)
					grupo_arrastrado.cursor_no_sobre_grupo.connect(_salio_cursor_en_grupo)
					$tablero.anadir_grupo_fichas(grupo_arrastrado)
					if not grupo_arrastrado.todas_son_fichas_fijadas():
						poniendo_fichas()
				
				else: # arrastra en el tablero sobre un grupo
					if(sobre_lado_grupo == globales.LADOS.IZQUIERDA):
						sobre_grupo.anadir_grupo_principio(grupo_arrastrado)
					else:
						sobre_grupo.anadir_grupo_fin(grupo_arrastrado)
					if not grupo_arrastrado.todas_son_fichas_fijadas():
						poniendo_fichas()
			clicando = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (grupo_arrastrado != null) and clicando:
		# var movido = sobre_quien
		# if movido.get_grupo() != null: 
		# movido = movido.get_grupo()
		var posicion_raton = get_global_mouse_position()
		grupo_arrastrado.position += posicion_raton - posicion_clic
		posicion_clic = posicion_raton

func _crear_ficha() -> Ficha:
	var posibles_fichas = [Ficha.COLOR.ROJO,Ficha.COLOR.AMARILLO,Ficha.COLOR.NEGRO,Ficha.COLOR.AZUL]
	var ficha: Ficha = Ficha.ficha(posibles_fichas[randi()%4],randi()%13 )
	self.add_child(ficha)
	conectar_ficha(ficha)
	# lista_fichas.insert(indice_lista_fichas, ficha)
	# indice_lista_fichas += 1
	return ficha

func _entro_cursor_en_ficha(ficha: Ficha):
	if(ficha.en_blanco):
		print("entraron en ficha blanca")
		sobre_ficha = ficha

	if (not clicando):
		sobre_ficha = ficha
		resaltar(ficha)
		print("entraron en " + str(ficha.name))
	else:
		if(not mano.hay_espacio()):
			mano.aumentar_tamano_mano()
		if(globales.estado_cursor == globales.ESTADO_CURSOR.MANO):
			mano.intercambiar(ficha)

func _salio_cursor_en_ficha(ficha: Ficha):
	if ((not clicando) or ficha.en_blanco):
		desresaltar(ficha)
		if sobre_ficha == ficha:
			print("salio de " + str(ficha.name))
			sobre_ficha = null

func resaltar(ficha: Ficha):
	ficha.z_index = 1
	ficha.scale = escala_aumentada

func desresaltar(ficha: Ficha):
	ficha.z_index = 0
	ficha.scale = escala_por_defecto

func desresaltar_grupo(grupo: Grupo_fichas):
	for ficha: Ficha in grupo.fichas:
		if ficha.scale == escala_aumentada:
			desresaltar(ficha)

func click_izquierdo(ficha: Ficha) -> void:

	if(ficha.estado == globales.ESTADO_FICHA.MANO):
		vengo_de_tablero = false
		mano.quitar_ficha(sobre_ficha)
		ficha.estado = globales.ESTADO_FICHA.TABLERO_NO_FIJADA
		ficha.resaltar_aura()
		grupo_arrastrado = Grupo_fichas.Grupo_fichas([ficha])
		globales.apropiar_hijo(self, grupo_arrastrado)
	else:
		vengo_de_tablero = true
		var grupo_original = ficha.miGrupo
		grupo_arrastrado = grupo_original.partir(ficha)
		sobre_grupo = grupo_original
		if grupo_arrastrado == grupo_original: # nos llevamos todo el grupo
			posicion_original_grupo = grupo_original.transform
			grupo_de_origen = null
			$tablero.quitar_grupo_fichas(grupo_arrastrado)
		else: # nos llevamos solo parte
			grupo_de_origen = grupo_original
		
		globales.apropiar_hijo(self, grupo_arrastrado)
		
		
		#sobre_quien = grupo_ficha.partir(sobre_quien)
		#var grupo_ficha = ficha.miGrupo
		#ficha.position += grupo_ficha.position
		#if(grupo_ficha.fichas.size()==1): # si solo les queda una ficha se elimina el grupo
		#	grupo_ficha.get_parent().remove_child(grupo_ficha)


func _entro_cursor_en_grupo(grupo_sobrepasado : Grupo_fichas, lado) -> void:
	sobre_lado_grupo = lado
	sobre_grupo = grupo_sobrepasado

func _salio_cursor_en_grupo(_grupo_sobrepasado : Grupo_fichas, _lado) -> void:
	if sobre_grupo==_grupo_sobrepasado && sobre_lado_grupo==_lado:
		sobre_grupo = null

func conectar_ficha(ficha: Ficha):
	ficha.cursor_sobre_ficha.connect(_entro_cursor_en_ficha)
	ficha.cursor_no_sobre_ficha.connect(_salio_cursor_en_ficha)

func desconectar_ficha(ficha: Ficha):
	ficha.cursor_sobre_ficha.disconnect(_entro_cursor_en_ficha)
	ficha.cursor_no_sobre_ficha.disconnect(_salio_cursor_en_ficha)


func conectar_grupo(grupo_fichas: Grupo_fichas) -> void:
	grupo_fichas.cursor_sobre_grupo.connect(_entro_cursor_en_grupo)
	grupo_fichas.cursor_no_sobre_grupo.connect(_salio_cursor_en_grupo)

func desconectar_grupo(grupo_fichas: Grupo_fichas) -> void:
	grupo_fichas.cursor_sobre_grupo.disconnect(_entro_cursor_en_grupo)
	grupo_fichas.cursor_no_sobre_grupo.disconnect(_salio_cursor_en_grupo)

func conectar_poder(poder:Poder) -> void:
	poder.cursor_sobre_poder.connect(_entro_cursor_en_poder)
	poder.cursor_no_sobre_poder.connect(_salio_cursor_en_poder)

func desconectar_poder(poder:Poder) -> void:
	poder.cursor_sobre_poder.disconnect(_entro_cursor_en_poder)
	poder.cursor_no_sobre_poder.disconnect(_salio_cursor_en_poder)

func poniendo_fichas():
	manager_juego.poniendo_fichas()

func quitando_fichas():
	if(not tablero.alguna_recien_puesta() and _es_mi_turno()):
		manager_juego.no_poniendo_fichas()

func _es_mi_turno() -> bool:
	return (globales.estado_juego != globales.ESTADO_JUEGO.NO_MI_TURNO)

func _on_panel_contador_monedas_mouse_entered() -> void:
	globales.estado_cursor = globales.ESTADO_CURSOR.LIMBO

func _on_panel_contador_monedas_mouse_exited() -> void:
	globales.estado_cursor = globales.ESTADO_CURSOR.TABLERO

func _entro_cursor_en_poder(poder: Poder) -> void:
	globales.estado_cursor = globales.ESTADO_CURSOR.LIMBO
	sobre_poder = poder

func _salio_cursor_en_poder(_poder: Poder) -> void:
	globales.estado_cursor = globales.ESTADO_CURSOR.TABLERO
	sobre_poder = null
