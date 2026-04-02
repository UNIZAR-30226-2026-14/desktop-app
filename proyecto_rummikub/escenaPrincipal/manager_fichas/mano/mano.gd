extends Node2D

#Responsabilidad: Lleva cuenta de las fichas en la mano y les da su posición

@export var ordenarNumero: Button
@export var ordenarColor: Button
@export var manager_fichas: Node2D
@export var hitbox_mano: CollisionShape2D

var centro_pantalla_x: float
var tamano_pantalla_y: float 
var distancia_entre_fichas_horizontal: float = 10.0
var distancia_entre_fichas_vertical: float = 5.0

var num_maximo_fichas: int = 10
var num_minimo_fichas: int = num_maximo_fichas
var num_filas: int = 2

var tamano_ficha: Vector2
var altura_mano: float
var fichas_por_fila: int = 5
var fichas_en_mano: Array[Node]

var ficha_en_blanco: Node2D = Ficha.ficha(Ficha.COLOR.BLANCO, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	altura_mano = get_viewport().size.y / 4
	centro_pantalla_x =  0.0
	ordenarNumero.pressed.connect(ordenar_por_numero)
	ordenarColor.pressed.connect(ordenar_por_color)
	$AreaMano.mouse_entered.connect(actualizar_estado_cursor_mano)
	$AreaMano.mouse_exited.connect(actualizar_estado_cursor_limbo)
	for i in num_maximo_fichas:
		print(i)
		anadir_ficha(Ficha.ficha(Ficha.COLOR.BLANCO, 0))

func anadir_ficha(ficha:Node) -> void:
	actualizar_espacio()
	globales.apropiar_hijo(self, ficha)
	ficha.estado = globales.ESTADO_FICHA.MANO
	fichas_en_mano.append(ficha)
	actualizar_posicion_mano()

func insertar_ficha(ficha_origen: Ficha, ficha_destino: Ficha) -> void:
	globales.apropiar_hijo(self, ficha_origen)
	var insertar_en: int = fichas_en_mano.find(ficha_destino)
	fichas_en_mano.set(insertar_en,ficha_origen)
	ficha_origen.estado = globales.ESTADO_FICHA.MANO
	ficha_destino.queue_free()
	actualizar_posicion_mano()

func quitar_ficha(ficha:Node) -> void:
	#self.remove_child(ficha)
	var ficha_sacada: int = fichas_en_mano.find(ficha)
	var ficha_blanca: Ficha = Ficha.ficha(Ficha.COLOR.BLANCO, 0) 
	globales.apropiar_hijo(self, ficha_blanca)
	fichas_en_mano.set(ficha_sacada,ficha_blanca)
	disminuir()
	actualizar_posicion_mano()

func devolver_ficha(ficha:Node) -> void:
	actualizar_espacio()
	globales.apropiar_hijo(self, ficha)
	var estaba_en: int = fichas_en_mano.find_custom(func(a): return a.en_blanco)
	fichas_en_mano.get(estaba_en).queue_free()
	fichas_en_mano.set(estaba_en,ficha)
	ficha.estado = globales.ESTADO_FICHA.MANO
	actualizar_posicion_mano()

func intercambiar(ficha:Node) -> void:
	if(ficha.en_blanco):
		return
	
	var indice_donde_estaba: int = fichas_en_mano.find_custom(func(a): return a.en_blanco)
	var indice_ficha_intercambiar: int = fichas_en_mano.find(ficha)
	var ficha_blanca: Ficha = Ficha.ficha(Ficha.COLOR.BLANCO, 0)
	var ficha_eliminar: Ficha
	globales.apropiar_hijo(self, ficha_blanca)
	if(indice_donde_estaba < indice_ficha_intercambiar):
		print("caso 1")
		fichas_en_mano.insert(indice_ficha_intercambiar+1,ficha_blanca)
		ficha_eliminar = fichas_en_mano.get(indice_donde_estaba)
		fichas_en_mano.remove_at(indice_donde_estaba)
	else:
		if (indice_ficha_intercambiar-1) < 0:
			print("caso 2")
			fichas_en_mano.insert(0,ficha_blanca)
			ficha_eliminar = fichas_en_mano.get(indice_donde_estaba+1)
			fichas_en_mano.remove_at(indice_donde_estaba+1)
		else:
			print("caso 3")
			fichas_en_mano.insert(indice_ficha_intercambiar-1,ficha_blanca)
			ficha_eliminar = fichas_en_mano.get(indice_donde_estaba+1)
			fichas_en_mano.remove_at(indice_donde_estaba+1)
			
	ficha_eliminar.queue_free()
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
			indice += 1
			if((indice == fichas_por_fila) and ((num_filas -1 ) > fila )):
				indice = 0
				fila += 1

func ordenar_por_color() -> void:
	fichas_en_mano.sort_custom(func(a, b): return ((b.en_blanco) || (a.numero < b.numero) || ( (a.numero == b.numero) && (a.color < b.color) )) && (not a.en_blanco) )
	actualizar_posicion_mano()

func ordenar_por_numero() -> void:
	fichas_en_mano.sort_custom(func(a, b): return ((b.en_blanco) || (a.color < b.color) || ( (a.color == b.color) && (a.numero < b.numero) ))&& (not a.en_blanco) )
	actualizar_posicion_mano()

func actualizar_estado_cursor_limbo() -> void:
	globales.estado_cursor = globales.ESTADO_CURSOR.TABLERO

func actualizar_estado_cursor_mano() -> void:
	print("entra en mano")
	globales.estado_cursor = globales.ESTADO_CURSOR.MANO


func hay_espacio() -> bool:
	return fichas_en_mano.any(func(a): return a.en_blanco) or (fichas_en_mano.size() == 0)


func aumentar_tamano_mano() -> void:
	fichas_por_fila += 1
	hitbox_mano.shape.size.x += (fichas_en_mano[0].tamano_ficha().x) + distancia_entre_fichas_horizontal
	num_maximo_fichas += num_filas
	for i in num_filas :
		print("poner blanca")
		var nueva_ficha_blanca: Ficha = Ficha.ficha(Ficha.COLOR.BLANCO, 0)
		globales.apropiar_hijo(self, nueva_ficha_blanca)
		manager_fichas.conectar_ficha(nueva_ficha_blanca)
		fichas_en_mano.push_back(nueva_ficha_blanca)
	actualizar_posicion_mano()


func actualizar_espacio() -> void:
	if( not hay_espacio()):
		print("aumentar")
		aumentar_tamano_mano()

func disminuir()->void:
	if((_contar_blancas()>=2) and (num_maximo_fichas > num_minimo_fichas)):
		num_maximo_fichas -=2
		hitbox_mano.shape.size.x -= (fichas_en_mano[0].tamano_ficha().x) + distancia_entre_fichas_horizontal
		fichas_por_fila -= 1
		for i in num_filas :
			var posicion_blanca_eliminar: int = fichas_en_mano.find_custom(func(a): return a.en_blanco)
			var blanca_eliminar: Ficha = fichas_en_mano[posicion_blanca_eliminar]
			manager_fichas.desconectar_ficha(blanca_eliminar)
			fichas_en_mano.erase(blanca_eliminar)
			blanca_eliminar.queue_free()
		actualizar_posicion_mano()


func _acumular_blancas(accum: int, ficha: Ficha) -> int:
	if(ficha.en_blanco):
		return accum +1
	else:
		return accum

func _contar_blancas() -> int:
	return fichas_en_mano.reduce(_acumular_blancas,0)
