extends Node2D
@export var mano: Node2D
@export var tablero: Node2D

# cuanto aumenta la escala del la carta al poner el cursor sobre ella
@export var escala_aumentada: Vector2 = Vector2(1.2,  1.2) 
# escalado por defecto de las cartas
@export var escala_por_defecto: Vector2 = Vector2(1.0,  1.0) 

@export var robarCarta: Button

const grupo = preload("res://proyecto_rummikub/ficha/grupo_fichas.tscn")

var max_fichas: int = 10 # es para debuggear


var clicando: bool = false # indica si se esta pulsando el clic izquierdo
var sobre_quien: Node = null # porta el indice de la carta sobre la que esta el cursor, si no es nadie se pone un -1
var estado_cursor # puede ser: MANO, TABLERO, LIMBO
var posicion_clic: Vector2 # guarda la posiocion del cursor mientras esta pulsado el clic izquierdo

var sobre_grupo: Node = null
var sobre_lado_grupo
var lista_fichas: Array[Ficha] # lista de objetos carta
var indice_lista_fichas: int = 0 # numero de cartas en pantalla
var fichaVacia: Node2D = Ficha.ficha("blanco")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	robarCarta.pressed.connect(robar_carta)

func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton) and (event.button_index == MOUSE_BUTTON_LEFT):
	# se entra cuando se pulsa o despulsa el clic iquierdo del raton
		if (sobre_quien != null) and event.is_pressed() : 
		# si se pulsa sobre un espacio no vacio 
			posicion_clic = get_global_mouse_position()
			sobre_quien.z_index += 1 # se aumenta su prioridad para que aparezca sobre el resto de cartas
			clicando = true 
			sacar(sobre_quien)


		elif event.is_released():
		# si se deja de clicar 
			clicando = false
			
			#if(lista_fichas.size()!=0):
			if(sobre_quien != null):
				sobre_quien.z_index -= 1 # se le baja la prioridad a la carta
				#self.remove_child(sobre_quien)
				if(globales.estado_cursor==globales.ESTADO_CURSOR.MANO 
					or globales.estado_cursor==globales.ESTADO_CURSOR.LIMBO):
					print("Intento devolver")
					mano.devolver_ficha(sobre_quien)
				elif(sobre_grupo == null):
					var nuevo_grupo = Grupo_fichas.Grupo_fichas([sobre_quien])
					nuevo_grupo.cursor_sobre_grupo.connect(_entro_cursor_en_grupo)
					nuevo_grupo.cursor_no_sobre_grupo.connect(_salio_cursor_en_grupo)
					$tablero.anadir_grupo_fichas(nuevo_grupo)
				else:
					if(sobre_lado_grupo == globales.IZQUIERDA):
						sobre_grupo.anadir_ficha_principio(sobre_quien)
					else:
						sobre_grupo.anadir_ficha_fin(sobre_quien)
					

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (sobre_quien != null) and clicando:
		#var movido = sobre_quien
		#if movido.get_grupo() != null: 
		#	movido = movido.get_grupo()
		var posicion_raton = get_global_mouse_position()
		sobre_quien.position += posicion_raton - posicion_clic
		posicion_clic = posicion_raton

func _crear_ficha() -> Ficha:
	var posibles_fichas = ["corazones", "picas", "treboles", "diamantes"]
	var ficha: Ficha = Ficha.ficha(posibles_fichas[randi()%4])
	self.add_child(ficha)
	ficha.cursor_sobre_ficha.connect(_entro_cursor_en_ficha)
	ficha.cursor_no_sobre_ficha.connect(_salio_cursor_en_ficha)
	lista_fichas.insert(indice_lista_fichas, ficha)
	indice_lista_fichas += 1

	return ficha

func _entro_cursor_en_ficha(ficha: Ficha):
	if not clicando:
		if sobre_quien == null:
			sobre_quien = ficha
			resaltar(ficha)
		print("entraron en " + str(ficha.name))
		print()
		print("prioridad: " + str(ficha.z_index))
		sobre_quien = ficha
	elif sobre_quien != null:
		mano.intercambiar(ficha)

func _salio_cursor_en_ficha(ficha: Ficha):
	if not clicando:
		desresaltar(ficha)
		if sobre_quien == ficha :
			print("salio de " + str(ficha.name))
			sobre_quien = null
		elif ficha != null:
			resaltar(sobre_quien)

func resaltar(ficha: Ficha):
	ficha.scale = escala_aumentada

func desresaltar(ficha: Ficha):
	ficha.scale = escala_por_defecto

func robar_carta() -> void:
	var fich = _crear_ficha()
	mano.anadir_ficha(fich)
	#el ultimo objeto creado tiene mas z_index, esto arregla eso:
	fich.z_index = 0
	#if(indice_lista_fichas >= 1):
		#lista_fichas[indice_lista_fichas-1].z_index += 1

func sacar(ficha: Ficha) -> void:
	if(ficha.estado == globales.ESTADO_FICHA.MANO):
		mano.quitar_ficha(sobre_quien)
		globales.apropiar_hijo(self, ficha)

	else:
		var grupo_ficha = ficha.miGrupo
		globales.apropiar_hijo(self, sobre_quien)
		#sobre_quien = grupo_ficha.partir(sobre_quien)
		#var grupo_ficha = ficha.miGrupo
		ficha.position += grupo_ficha.position
		if(grupo_ficha.fichas.size()==1): # si solo les queda una ficha se elimina el grupo
			grupo_ficha.get_parent().remove_child(grupo_ficha)












#var unGrupo = null
#func _boton_prueba() -> void:
	#var ficha = _crear_ficha()
	#self.remove_child(ficha)
	#if unGrupo == null:
		#unGrupo = crea_grupo_fichas(ficha)
	#else: 
		#unGrupo.anadir_ficha(ficha)
#
#
#func crea_grupo_fichas(ficha : Ficha) -> Grupo_fichas:
	#var _grupo : Grupo_fichas = grupo.instantiate()
	#self.add_child(_grupo) 
	#_grupo.sobre_mi.connect(_sobre_grupo_fichas)
	#_grupo.no_sobre_mi.connect(_out_grupo_fichas)
	#_grupo.anadir_ficha(ficha)
	#return _grupo




func _entro_cursor_en_grupo(grupo_sobrepasado : Grupo_fichas, lado) -> void:
	sobre_lado_grupo = lado
	sobre_grupo = grupo_sobrepasado

func _salio_cursor_en_grupo(_grupo_sobrepasado : Grupo_fichas, _lado) -> void:
	sobre_grupo = null
