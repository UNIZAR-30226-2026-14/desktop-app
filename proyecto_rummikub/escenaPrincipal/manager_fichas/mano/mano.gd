extends Node2D

#Responsabilidad: Lleva cuenta de las fichas en la mano y les da su posición

@export var ordenarNumero: Button
@export var ordenarColor: Button

var centro_pantalla_x: float
var tamano_pantalla_y: float 
var distancia_entre_fichas_horizontal: float = 10.0
var distancia_entre_fichas_vertical: float = 5.0

var tamano_ficha: Vector2
var altura_mano: float
var fichas_por_fila: int = 5
var fichas_en_mano: Array[Node]

var ficha_en_blanco: Node2D = Ficha.ficha("blanco")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	altura_mano = get_viewport().size.y / 4
	centro_pantalla_x =  0.0
	ordenarNumero.pressed.connect(ordenar_por_numero)
	ordenarColor.pressed.connect(ordenar_por_color)
	$AreaMano.mouse_entered.connect(actualizar_estado_cursor_mano)
	$AreaMano.mouse_exited.connect(actualizar_estado_cursor_limbo)


func anadir_ficha(ficha:Node) -> void:
	globales.apropiar_hijo(self, ficha)
	ficha.estado = globales.ESTADO_FICHA.MANO
	fichas_en_mano.append(ficha)
	actualizar_posicion_mano()

func quitar_ficha(ficha:Node) -> void:
	#self.remove_child(ficha)
	var ficha_sacada: int = fichas_en_mano.find(ficha)
	fichas_en_mano.set(ficha_sacada,ficha_en_blanco)
	actualizar_posicion_mano()

func devolver_ficha(ficha:Node) -> void:
	globales.apropiar_hijo(self, ficha)
	var estaba_en: int = fichas_en_mano.find_custom(func(a): return a.en_blanco)
	print(estaba_en)
	print()
	fichas_en_mano.set(estaba_en,ficha)
	ficha.estado = globales.ESTADO_FICHA.MANO
	actualizar_posicion_mano()

func intercambiar(ficha:Node) -> void:
	var indice_donde_estaba: int = fichas_en_mano.find_custom(func(a): return a.en_blanco)
	var indice_ficha_intercambiar: int = fichas_en_mano.find(ficha)
	if(indice_donde_estaba < indice_ficha_intercambiar):
		fichas_en_mano.insert(indice_ficha_intercambiar+1,ficha_en_blanco)
		fichas_en_mano.remove_at(indice_donde_estaba)

	else:
		if (indice_ficha_intercambiar-1) < 0:
			fichas_en_mano.insert(0,ficha_en_blanco)
			fichas_en_mano.remove_at(indice_donde_estaba+1)
		else:
			fichas_en_mano.insert(indice_ficha_intercambiar-1,ficha_en_blanco)
			fichas_en_mano.remove_at(indice_donde_estaba+1)

	actualizar_posicion_mano()

func actualizar_posicion_mano() -> void:
	if fichas_en_mano.size() != 0:
		var anchura_ficha = fichas_en_mano[0].tamano_ficha().x
		var altura_ficha  = fichas_en_mano[0].tamano_ficha().y
		var tamano_mano  = (distancia_entre_fichas_horizontal + anchura_ficha) * min(fichas_en_mano.size(), fichas_por_fila)
		var indice:float = 0
		var fila:float = 0
		var altura_inicial: float = altura_mano
		for ficha in fichas_en_mano:
			ficha.position.x = anchura_ficha/2 + centro_pantalla_x + (distancia_entre_fichas_horizontal + anchura_ficha) * indice - tamano_mano/2
			ficha.position.y = altura_inicial + (distancia_entre_fichas_vertical + altura_ficha)*fila
			print("se pone en:" + str(ficha.position.x) + " "+ str(ficha.position.y))
			indice += 1
			if(indice == fichas_por_fila):
				indice = 0
				fila += 1

func ordenar_por_color() -> void:
	fichas_en_mano.sort_custom(func(a, b): return a.mi_indice > b.mi_indice)
	actualizar_posicion_mano()

func ordenar_por_numero() -> void:
	fichas_en_mano.sort_custom(func(a, b): return a.mi_indice <= b.mi_indice)
	actualizar_posicion_mano()

func actualizar_estado_cursor_limbo() -> void:
	globales.estado_cursor = globales.ESTADO_CURSOR.LIMBO

func actualizar_estado_cursor_mano() -> void:
	globales.estado_cursor = globales.ESTADO_CURSOR.MANO
