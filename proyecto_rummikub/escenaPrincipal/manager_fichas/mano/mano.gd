extends Node2D

#Responsabilidad: Lleva cuenta de las fichas en la mano y les da su posición

@export var ordenarNumero: Button
@export var ordenarColor: Button
@export var manager_fichas: Node2D
@export var hitbox_mano: CollisionShape2D
@export var color_mano: Node
@export var tablero :Node2D

var centro_pantalla_x: float
var tamano_pantalla_y: float 
var distancia_entre_fichas_horizontal: float = 10.0
var distancia_entre_fichas_vertical: float = 5.0

var num_maximo_fichas: int = 18
var num_minimo_fichas: int = num_maximo_fichas
var num_filas: int = 2

var tamano_ficha: Vector2
var altura_mano: float
var fichas_por_fila: int = 9
var fichas_en_mano: Array[Ficha]

var ficha_en_blanco: Node2D = Ficha.ficha(Ficha.COLOR.BLANCO, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#altura_mano = $AreaMano/CollisionShapeMano.position.y + altura_ficha  #get_viewport().size.y / 3
	centro_pantalla_x =  0.0
	ordenarNumero.pressed.connect(ordenar_por_numero)
	ordenarColor.pressed.connect(ordenar_por_color)
	$AreaMano.mouse_entered.connect(actualizar_estado_cursor_mano)
	$AreaMano.mouse_exited.connect(actualizar_estado_cursor_limbo)
	for i in num_maximo_fichas:
		anadir_ficha(Ficha.ficha(Ficha.COLOR.BLANCO, 0))
	
	actualizar_posicion_mano()


func anadir_ficha(ficha:Node) -> void:
	actualizar_espacio()
	globales.apropiar_hijo(self, ficha)
	ficha.estado = globales.ESTADO_FICHA.MANO
	ficha.desresaltar_aura()
	fichas_en_mano.append(ficha)
	actualizar_posicion_mano()

func insertar_ficha(ficha_origen: Ficha, ficha_destino: Ficha) -> void:
	globales.apropiar_hijo(self, ficha_origen)
	var insertar_en: int = fichas_en_mano.find(ficha_destino)
	fichas_en_mano.set(insertar_en,ficha_origen)
	ficha_origen.estado = globales.ESTADO_FICHA.MANO
	ficha_origen.desresaltar_aura()
	ficha_destino.queue_free()
	actualizar_posicion_mano()

func quitar_ficha(ficha:Node) -> void:
	#self.remove_child(ficha)
	
	var ficha_sacada: int = fichas_en_mano.find(ficha)
	if ficha_sacada == -1:
		return
#	print("Quito: " + str(ficha_sacada))
	var ficha_blanca: Ficha = Ficha.ficha(Ficha.COLOR.BLANCO, 0) 
	globales.apropiar_hijo(self, ficha_blanca)
	manager_fichas.conectar_ficha(ficha_blanca)
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
	ficha.desresaltar_aura()
	actualizar_posicion_mano()

func intercambiar_desusado(ficha:Node) -> void:
	if(ficha.en_blanco):
		return
	print("INTERCAMBIAR")
	
	var indice_donde_estaba: int = fichas_en_mano.find_custom(func(a): return a.en_blanco)
	var indice_ficha_intercambiar: int = fichas_en_mano.find(ficha)
	
	var ficha_blanca: Ficha = Ficha.ficha(Ficha.COLOR.BLANCO, 0)
	manager_fichas.conectar_ficha(ficha_blanca)
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

func intercambiar(ficha:Ficha) -> void:
	if(ficha.en_blanco):
		return
	print("INTERCAMBIAR")
	
	var indice_nuevo_sitio: int = fichas_en_mano.find_custom(func(a): return a.en_blanco)
	var indice_ficha_intercambiar: int = fichas_en_mano.find(ficha)
	var ficha_blanca: Ficha = Ficha.ficha(Ficha.COLOR.BLANCO, 0)
	manager_fichas.conectar_ficha(ficha_blanca)
	globales.apropiar_hijo(self, ficha_blanca)
	var ficha_moviendo: Ficha = ficha_blanca
	var ficha_aux: Ficha
	if indice_nuevo_sitio < indice_ficha_intercambiar:
		for i in range(indice_ficha_intercambiar,-1,-1):
			print(i)
			if fichas_en_mano[i].en_blanco:
				fichas_en_mano[i].queue_free()
				fichas_en_mano[i] = ficha_moviendo
				actualizar_posicion_mano()
				break
			ficha_aux = fichas_en_mano[i]
			fichas_en_mano[i] = ficha_moviendo
			ficha_moviendo = ficha_aux
	else:
		for i in range(indice_ficha_intercambiar,fichas_en_mano.size(),+1):
			if fichas_en_mano[i].en_blanco:
				fichas_en_mano[i].queue_free()
				fichas_en_mano[i] = ficha_moviendo
				actualizar_posicion_mano()
				break
			ficha_aux = fichas_en_mano[i]
			fichas_en_mano[i] = ficha_moviendo
			ficha_moviendo = ficha_aux
	actualizar_posicion_mano()

func actualizar_posicion_mano() -> void:
	if fichas_en_mano.size() != 0:
		var anchura_ficha = fichas_en_mano[0].tamano_ficha().x
		var altura_ficha  = fichas_en_mano[0].tamano_ficha().y
		var tamano_mano  = (distancia_entre_fichas_horizontal + anchura_ficha) * min(fichas_en_mano.size(), fichas_por_fila)
		var indice: float = 0
		var fila: float = 0
		var altura_inicial: float = $AreaMano/CollisionShapeMano.position.y - altura_ficha + 2*distancia_entre_fichas_vertical
		for ficha in fichas_en_mano:
			ficha.position.x = anchura_ficha/2 + centro_pantalla_x + (distancia_entre_fichas_horizontal + anchura_ficha) * indice - tamano_mano/2
			ficha.position.y = altura_inicial + (distancia_entre_fichas_vertical + altura_ficha)*fila
			indice += 1
			if((indice == fichas_por_fila) and ((num_filas -1 ) > fila )):
				indice = 0
				fila += 1

func ordenar_por_color() -> void:
	fichas_en_mano.sort_custom(func(a, b): return ((b.en_blanco) || (a.color < b.color) || ( (a.color == b.color) && (a.numero < b.numero) ))&& (not a.en_blanco) )
	actualizar_posicion_mano()

func ordenar_por_numero() -> void:
	fichas_en_mano.sort_custom(func(a, b): return ((b.en_blanco) || (a.numero < b.numero) || ( (a.numero == b.numero) && (a.color < b.color) )) && (not a.en_blanco))
	actualizar_posicion_mano()

func actualizar_estado_cursor_limbo() -> void:
	print("entra en tablero")
	globales.estado_cursor = globales.ESTADO_CURSOR.TABLERO

func actualizar_estado_cursor_mano() -> void:
	print("entra en mano")
	globales.estado_cursor = globales.ESTADO_CURSOR.MANO


func hay_espacio() -> bool:
	return fichas_en_mano.any(func(a): return a.en_blanco) or (fichas_en_mano.size() == 0)

func aumentar_tamano_mano() -> void:
	fichas_por_fila += 1
	var aumento: float = (fichas_en_mano[0].tamano_ficha().x) + distancia_entre_fichas_horizontal
	hitbox_mano.shape.size.x += aumento
	$AreaMano/CollisionShapeMano/Panel.size = hitbox_mano.shape.size
	$AreaMano/CollisionShapeMano/Panel.position.x -= aumento / 2
	
	#$AreaMano/CollisionShapeMano/Panel.position = Vector2
	num_maximo_fichas += 2
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
		var disminucion: float = (fichas_en_mano[0].tamano_ficha().x) + distancia_entre_fichas_horizontal
		hitbox_mano.shape.size.x -= disminucion
		$AreaMano/CollisionShapeMano/Panel.size = hitbox_mano.shape.size
		$AreaMano/CollisionShapeMano/Panel.position.x += disminucion / 2
		
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

func insertar_mano(nueva_mano :Array[Ficha]) -> void:
	
	for ficha in fichas_en_mano:
		if !ficha.en_blanco:
			quitar_ficha(ficha)
			self.remove_child(ficha)
	
	for ficha in fichas_en_mano: 
		if !ficha.en_blanco:
			quitar_ficha(ficha)
			self.remove_child(ficha)
	
	for ficha in nueva_mano:
		if (not ficha.en_blanco):
			devolver_ficha(ficha)
			manager_fichas.conectar_ficha(ficha)

func vacia()-> bool:
	return fichas_en_mano.all(func(ficha)->bool:
		return ficha.en_blanco)
