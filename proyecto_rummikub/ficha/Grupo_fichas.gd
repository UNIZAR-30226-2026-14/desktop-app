class_name Grupo_fichas extends Node2D

signal cursor_sobre_grupo
signal cursor_no_sobre_grupo


# Agrupación de cartas, usado para verificar correcta posición de la mesa
# y para hacer que la posición de las fichas en el mismo grupo sea contigua
# Se le pueden añadir y quitar fichas, puede partirse en dos (devolviendo el nuevo grupo de fichas creado)
# Posee dos area2D que permiten a manager_fichas darle una carta o cartas nuevas

# IMPORTANTE: procedimiento para modificar fichas en grupo_fichas
# 1. modificar lista de fichas
# 2. llamar a _recalcula_variables_grupo
# 3. Modificar parentesco, posición y/o existencia de fichas en lista

static var escena: PackedScene = preload("res://proyecto_rummikub/ficha/grupo_fichas.tscn")
static var tamano_extra: float = 1.5 * Ficha.tamano_ficha_static().x

var fichas : Array[Ficha] = []
var anchura_hitbox: float =  tamano_extra 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$izquierda/CollisionShape2D.shape.size.y = Ficha.tamano_ficha_static().y
	$derecha/CollisionShape2D.shape.size.y = Ficha.tamano_ficha_static().y
	$izquierda.mouse_entered.connect(_emitir_señal_entrada_izquierda)
	$izquierda.mouse_exited.connect(_emitir_señal_salida_izquierda)
	$derecha.mouse_entered.connect(_emitir_señal_entrada_derecha)
	$derecha.mouse_exited.connect(_emitir_señal_salida_derecha)
	_recalcula_anchura()

## Constructor
static func Grupo_fichas(listaFichas : Array[Ficha]) -> Grupo_fichas:
	var grupo: Grupo_fichas  = escena.instantiate()
	grupo.position.y = listaFichas[0].global_position.y
	grupo.anadir_grupo_fin(listaFichas)
	return grupo



func _calcula_posicion_grupo(en_base_a : globales.LADOS ) -> void:
	var distancia_inicio_a_centro = (anchura_hitbox - tamano_extra) / 2  
	if en_base_a == globales.LADOS.DERECHA:
		position.x = fichas[0].global_position.x - fichas[0].tamano_ficha().x /2 + distancia_inicio_a_centro
	else:
		position.x = fichas[-1].global_position.x + fichas[-1].tamano_ficha().x /2 - distancia_inicio_a_centro

func _recalcula_anchura() -> void:
	anchura_hitbox = tamano_extra
	fichas.map(func(f:Ficha): anchura_hitbox += f.tamano_ficha_static().x)
	$izquierda/CollisionShape2D.shape.size.x = (anchura_hitbox / 2)
	$derecha/CollisionShape2D.shape.size.x = (anchura_hitbox / 2)
	$izquierda/CollisionShape2D.position.x = (-anchura_hitbox / 4)
	$derecha/CollisionShape2D.position.x = anchura_hitbox / 4


## grupo_o_ficha puede ser una ficha, un grupo_fichas o un array de fichas
func anadir_grupo_fin(grupo_o_ficha) -> void:
	var lista: Array[Ficha]
	# modifica parametro de entrada
	if grupo_o_ficha is Grupo_fichas:
		lista = grupo_o_ficha.fichas
		grupo_o_ficha.queue_free()
	elif grupo_o_ficha is Ficha:
		lista.append(grupo_o_ficha)
	elif grupo_o_ficha is Array[Ficha]:
		lista = grupo_o_ficha
	else:
		push_error("Añadir grupo fin con parametro incorrecto")
	
	fichas.append_array(lista)
	_recalcula_anchura()
	_calcula_posicion_grupo(globales.LADOS.DERECHA)
	_posicionar_fichas()
	# comportamiento
	for ficha:Ficha in lista:
		ficha.position.y = 0
		globales.apropiar_hijo(self, ficha)
		ficha.set_grupo(self)

func anadir_grupo_principio(grupo_o_ficha)-> void:
	var lista: Array[Ficha]
	# modifica parametro de entrada
	if grupo_o_ficha is Grupo_fichas:
		lista = grupo_o_ficha.fichas
		grupo_o_ficha.queue_free()
	elif grupo_o_ficha is Ficha:
		lista.append(grupo_o_ficha)
	elif grupo_o_ficha is Array[Ficha]:
		lista = grupo_o_ficha
	else:
		push_error("Añadir grupo fin con parametro incorrecto")
	
	lista.append_array(fichas)
	fichas = lista
	_recalcula_anchura()
	_calcula_posicion_grupo(globales.LADOS.IZQUIERDA)
	_posicionar_fichas()
	# comportamiento
	for ficha in lista:
		ficha.position.y = 0
		globales.apropiar_hijo(self, ficha)
		ficha.set_grupo(self)



## ficha es la ficha en la cual se está partiendo
## quita del grupo todas las fichas a la izquierda de ficha, y las introduce en un nuevo grupo
## devuelve el nuevo grupo
## IMPORTANTE: asume que ficha está en el grupo y que el grupo no está vacío
func partir(ficha: Ficha) -> Grupo_fichas:
	var indice_ficha
	#encontrar indice
	for i in fichas.size():
		if fichas[i] == ficha: 
			indice_ficha = i
			break
	
	if indice_ficha == 0: return self
	
	#crear nuevas listas
	var lista_ficha_hasta_derecha = fichas.slice(indice_ficha,fichas.size())
	fichas = fichas.slice(0,indice_ficha)
	
	#crea grupo resultado
	var res = Grupo_fichas(lista_ficha_hasta_derecha)
	
	_recalcula_anchura()
	_calcula_posicion_grupo(globales.LADOS.IZQUIERDA)
	_posicionar_fichas()
	return res

func _posicionar_fichas() -> void:
	var indice = 0
	for ficha in fichas:
		#print(indice)
		ficha.position.x = ficha.tamano_ficha().x/2 + (ficha.tamano_ficha().x) * indice - (ficha.tamano_ficha().x*fichas.size())/2
		indice += 1

func grupo_correcto(abierto: bool) -> bool:
	if fichas.size() < 3: return false
	
	var esEscalera: bool = true 
	var colorEscalera: Ficha.COLOR
	var esperadoEscalera: int = -1
	
	var esMismoNumero: bool = fichas.size() <= Ficha.COLOR.size() - 1 # -1 porque el comodin no es un color distinto, sino q puede ser cualquier color
	var setColores: Array[Ficha.COLOR] = []
	var esperadoMismo: int = -1
	for ficha in fichas:
		if !abierto and ficha.estado != globales.ESTADO_FICHA.TABLERO_NO_FIJADA: return false #ha usado cartas de la mesa para abrir
		if esperadoEscalera == -1: #no se ha encontrado nungún no comodín
			if ficha.color != Ficha.COLOR.COMODIN: #primera carta para evaluar validez
				esperadoEscalera = ficha.numero + 1
				colorEscalera = ficha.color
				esperadoMismo = ficha.numero
				setColores.append(ficha.color)
			continue
		else:
			if esEscalera:
				esEscalera = (ficha.numero == esperadoEscalera and ficha.color == colorEscalera) or ficha.color == Ficha.COLOR.COMODIN
				esperadoEscalera += 1
			if esMismoNumero:
				esMismoNumero = (ficha.numero == esperadoMismo and setColores.find(ficha.color) == -1) or ficha.color == Ficha.COLOR.COMODIN # el color no está en setColores
				setColores.append(ficha.color)
			if !esEscalera and !esMismoNumero: return false
		
	if esperadoMismo == -1 and esperadoMismo == -1: return true # todo comodines
	if esEscalera:
		if ! abierto: return true
		else:
			var baseEscalera = esperadoEscalera - fichas.size()
			var numTotal = range(baseEscalera, esperadoEscalera).reduce(func(accum,number): return accum + number, 0)
			return numTotal >= 30
	if esMismoNumero:
		if ! abierto: return true
		else:
			var numTotal = esperadoMismo * fichas.size()
			return numTotal >= 30
		
	return false

func contengo_ficha_fijada() -> bool:
	for ficha in fichas:
		if ficha.estado == globales.ESTADO_FICHA.TABLERO_FIJADA:
			return true
	return false

func todas_son_fichas_fijadas() -> bool:
	for ficha in fichas:
		if ficha.estado != globales.ESTADO_FICHA.TABLERO_FIJADA:
			return false
	return true


func _emitir_señal_entrada_izquierda():
	cursor_sobre_grupo.emit(self, globales.LADOS.IZQUIERDA)

func _emitir_señal_salida_izquierda():
	cursor_no_sobre_grupo.emit(self, globales.LADOS.IZQUIERDA)

func _emitir_señal_entrada_derecha():
	cursor_sobre_grupo.emit(self, globales.LADOS.DERECHA)

func _emitir_señal_salida_derecha():
	cursor_no_sobre_grupo.emit(self, globales.LADOS.DERECHA)

func chocando_con_grupo() -> bool:
	for area: Node2D in $izquierda.get_overlapping_areas():
		if area != $derecha:
			return true
	
	for area: Node2D in $derecha.get_overlapping_areas():
		if area != $izquierda:
			return true
	return false
