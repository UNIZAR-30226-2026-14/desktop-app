extends Node2D

var escala_aumentada: Vector2 = Vector2(1.2,  1.2) 
# cuanto aumenta la escala del la carta al poner el cursor sobre ella

var escala_por_defecto: Vector2 = Vector2(1.0,  1.0) 
# cuanto aumenta la escala del la carta al poner el cursor sobre ella

var clicando: bool = false # indica si se esta pulsando el clic izquierdo
var sobre_quien: int = -1 # porta el indice de la carta sobre la que esta el cursor
						  # si no es nadie se pone un -1
var posicion_clic: Vector2 # guarda la posiocion del cursor mientras esta pulsado el clic izquierdo

var lista_cartas: Array[Node] # lista de objetos carta
var indice_lista_cartas: int = 0 # numero de cartas en pantalla
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# esta funcion se realiza cada vez que hay una entrada de un periferico (creo)
func _input(event: InputEvent) -> void:

	if (event is InputEventMouseButton) and (event.button_index == MOUSE_BUTTON_LEFT):
	# se entra cuando se pulsa o despulsa el clic iquierdo del raton
		if (sobre_quien != -1) and event.is_pressed(): 
		# si se pulsa sobre un espacio no vacio 
			print("clicado sobre carta")
			posicion_clic = get_global_mouse_position()
			lista_cartas[sobre_quien].z_index += 1 # se aumenta su prioridad para que aparezca sobre el resto de cartas
			clicando = true 
		elif event.is_released():
		# si se deja de clicar 
			print("deja de clicar")
			lista_cartas[sobre_quien].z_index -= 1 # se le baja la prioridad a la carta
			clicando = false
		elif (sobre_quien == -1) and event.is_pressed():
		# si se pulsa sobre un lugar sin cartas se genera una carta nueva
			lista_cartas.insert(indice_lista_cartas,_crear_carta())
			lista_cartas[indice_lista_cartas].position = get_global_mouse_position()
			indice_lista_cartas += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (sobre_quien != -1) and clicando:
		var posicion_raton = get_global_mouse_position()
		lista_cartas[sobre_quien].position += posicion_raton - posicion_clic
		posicion_clic = posicion_raton

func _crear_carta() -> Node:
	var posibles_cartas = ["corazones", "picas", "treboles", "diamantes"]
	var carta: Node = Carta.carta(posibles_cartas[randi()%4])
	add_child(carta)
	carta.cursor_sobre_carta.connect(_entro_cursor_en_carta)
	carta.cursor_no_sobre_carta.connect(_salio_cursor_en_carta)
	return carta

func _entro_cursor_en_carta(id: int):
	if not clicando:
		if sobre_quien == -1:
			sobre_quien = id
			resaltar(id)
		print("entraron en " + str(id))
		sobre_quien = id

func _salio_cursor_en_carta(id: int):
	desresaltar(id)
	if not clicando:
		if sobre_quien == id :
			print("salio de " + str(id))
			sobre_quien = -1
			print(1)
		elif id != -1:
			resaltar(sobre_quien)

func resaltar(id: int):
	lista_cartas[id].scale = escala_aumentada

func desresaltar(id:int):
	lista_cartas[id].scale = escala_por_defecto
