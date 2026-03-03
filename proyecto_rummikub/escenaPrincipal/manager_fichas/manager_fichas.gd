extends Node2D
@export var mano: Node2D
@export var tablero: Node2D

@export var escala_aumentada: Vector2 = Vector2(1.2,  1.2) 
@export var robarCarta: Button

var max_fichas: int = 10 # es para debuggear
# cuanto aumenta la escala del la carta al poner el cursor sobre ella

@export var escala_por_defecto: Vector2 = Vector2(1.0,  1.0) 
# escalado por defecto de las cartas

var clicando: bool = false # indica si se esta pulsando el clic izquierdo
var sobre_quien: int = -1 # porta el indice de la carta sobre la que esta el cursor
						  # si no es nadie se pone un -1
var posicion_clic: Vector2 # guarda la posiocion del cursor mientras esta pulsado el clic izquierdo

var lista_fichas: Array[Node] # lista de objetos carta
var indice_lista_fichas: int = 0 # numero de cartas en pantalla

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	robarCarta.pressed.connect(robar_carta)


# esta funcion se realiza cada vez que hay una entrada de un periferico (creo)
func _unhandled_input(event: InputEvent) -> void:

	if (event is InputEventMouseButton) and (event.button_index == MOUSE_BUTTON_LEFT):
	# se entra cuando se pulsa o despulsa el clic iquierdo del raton
		if (sobre_quien != -1) and event.is_pressed(): 
		# si se pulsa sobre un espacio no vacio 
			print("clicado sobre carta")
			posicion_clic = get_global_mouse_position()
			lista_fichas[sobre_quien].z_index += 1 # se aumenta su prioridad para que aparezca sobre el resto de cartas
			clicando = true 
			mano.quitar_carta(lista_fichas[sobre_quien])

		elif event.is_released():
		# si se deja de clicar 
			clicando = false
			print("deja de clicar")
			if(lista_fichas.size()!=0):
				lista_fichas[sobre_quien].z_index -= 1 # se le baja la prioridad a la carta
				if(sobre_quien != -1):
					mano.anadir_ficha(lista_fichas[sobre_quien])
			

		#elif (sobre_quien == -1) and event.is_pressed() and (indice_lista_fichas < max_fichas):
		## si se pulsa sobre un lugar sin cartas se genera una carta nueva
			#lista_fichas.insert(indice_lista_fichas,_crear_ficha())
			#mano.anadir_ficha(lista_fichas[indice_lista_fichas])
			##lista_fichas[indice_lista_fichas].position = get_global_mouse_position()
			#indice_lista_fichas += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (sobre_quien != -1) and clicando:
		var posicion_raton = get_global_mouse_position()
		lista_fichas[sobre_quien].position += posicion_raton - posicion_clic
		posicion_clic = posicion_raton

func _crear_ficha() -> Node:
	var posibles_fichas = ["corazones", "picas", "treboles", "diamantes"]
	var ficha: Node = Ficha.ficha(posibles_fichas[randi()%4])
	add_child(ficha)
	$tablero.fichas.append(ficha)
	ficha.cursor_sobre_ficha.connect(_entro_cursor_en_ficha)
	ficha.cursor_no_sobre_ficha.connect(_salio_cursor_en_ficha)
	return ficha

func _entro_cursor_en_ficha(id: int):
	if not clicando:
		if sobre_quien == -1:
			sobre_quien = id
			resaltar(id)
		print("entraron en " + str(id))
		print("prioridad: " + str(lista_fichas[id].z_index))
		sobre_quien = id

func _salio_cursor_en_ficha(id: int):
	if not clicando:
		desresaltar(id)
		if sobre_quien == id :
			print("salio de " + str(id))
			sobre_quien = -1
		elif id != -1:
			resaltar(sobre_quien)

func resaltar(id: int):
	lista_fichas[id].scale = escala_aumentada

func desresaltar(id:int):
	lista_fichas[id].scale = escala_por_defecto

func robar_carta() -> void:
	
	lista_fichas.insert(indice_lista_fichas,_crear_ficha())
	mano.anadir_ficha(lista_fichas[indice_lista_fichas])

	#el ultimo objeto creado tiene mas z_index, esto arregla eso:
	lista_fichas[indice_lista_fichas].z_index -= 1
	if(indice_lista_fichas > 1):
		lista_fichas[indice_lista_fichas-1].z_index += 1

	indice_lista_fichas += 1
