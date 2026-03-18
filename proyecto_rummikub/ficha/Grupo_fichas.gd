class_name Grupo_fichas extends Node2D

signal cursor_sobre_grupo
signal cursor_no_sobre_grupo


# Agrupación de cartas, usado para verificar correcta posición de la mesa
# y para hacer que la posición de las fichas en el mismo grupo sea contigua
# Se le pueden añadir y quitar fichas, puede partirse en dos (devolviendo el nuevo grupo de fichas creado)
# Posee dos area2D que permiten a manager_fichas darle una carta o cartas nuevas

static var escena: PackedScene = preload("res://proyecto_rummikub/ficha/grupo_fichas.tscn")
const tamano_extra = 1.5

var fichas : Array[Ficha] = []
var anchura_hitbox = Ficha.tamano_ficha_static().x * tamano_extra

static func Grupo_fichas(listaFichas : Array[Ficha]) -> Grupo_fichas:
	var grupo: Grupo_fichas  = escena.instantiate()

	if(listaFichas.size()==1):
		grupo.position = listaFichas[0].position
	elif(listaFichas.size()%2 == 0):
		grupo.position = listaFichas[(listaFichas.size()/2)+1].position
	else:
		grupo.position = listaFichas[(listaFichas.size()/2)].position
		#grupo.position += listaFichas[0].tamano_ficha().x / 2

	for ficha in listaFichas :
		ficha.position = Vector2(0.0,0.0)
		ficha.estado = globales.ESTADO_FICHA.TABLERO_NO_FIJADA
		grupo.anadir_ficha_fin(ficha)
	return grupo

func _recalcula_anchura() -> void:
	
	$izquierda/CollisionShape2D.shape.size.x = anchura_hitbox / 2
	$derecha/CollisionShape2D.shape.size.x = anchura_hitbox / 2
	$izquierda/CollisionShape2D.position.x = -anchura_hitbox / 4
	$derecha/CollisionShape2D.position.x = anchura_hitbox / 4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$izquierda/CollisionShape2D.shape.size.y = Ficha.tamano_ficha_static().y
	$derecha/CollisionShape2D.shape.size.y = Ficha.tamano_ficha_static().y
	$izquierda.mouse_entered.connect(_emitir_señal_entrada_izquierda)
	$izquierda.mouse_exited.connect(_emitir_señal_salida_izquierda)
	$derecha.mouse_entered.connect(_emitir_señal_entrada_derecha)
	$derecha.mouse_exited.connect(_emitir_señal_salida_derecha)
	#_recalcula_anchura()

func anadir_lista_fin() -> void:
	pass

func anadir_ficha_fin(ficha : Ficha) -> void:
	globales.apropiar_hijo(self, ficha)
	fichas.push_back(ficha)
	ficha.set_grupo(self)
	ficha.position.y = 0.0
	anchura_hitbox += ficha.tamano_ficha().x
	_recalcula_anchura()
	#ficha.transform = Transform2D()
	_posicionar_fichas()

func anadir_ficha_principio(ficha : Ficha)-> void:
	globales.apropiar_hijo(self, ficha)
	fichas.push_front(ficha)
	ficha.set_grupo(self)
	ficha.position.y = 0.0
	anchura_hitbox += ficha.tamano_ficha().x
	_recalcula_anchura()
	#ficha.transform = Transform2D()
	_posicionar_fichas()



# ficha es la ficha en la cual se está partiendo
# quita del grupo todas las fichas a la izquierda de ficha, y las introduce en un nuevo grupo
# devuelve el nuevo grupo
# IMPORTANTE: asume que ficha está en el grupo y que el grupo no está vacío
func partir(ficha: Ficha) -> Grupo_fichas:
	var grupo: Grupo_fichas = escena.instantiate()
	for i in fichas.size():
		if fichas[i] == ficha: return grupo
		grupo.anadir_ficha_fin(fichas[i])
		fichas[i].set_grupo(grupo)
		fichas.remove_at(i)
	return grupo
	
func _posicionar_fichas() -> void:
	var indice = 0
	for ficha in fichas:
		#print(indice)
		ficha.position.x = ficha.tamano_ficha().x/2 + (ficha.tamano_ficha().x) * indice - (ficha.tamano_ficha().x*fichas.size())/2
		indice += 1

func grupo_correcto() -> bool:
	return true


func _emitir_señal_entrada_izquierda():
	cursor_sobre_grupo.emit(self, globales.IZQUIERDA)

func _emitir_señal_salida_izquierda():
	cursor_no_sobre_grupo.emit(self, globales.IZQUIERDA)

func _emitir_señal_entrada_derecha():
	cursor_sobre_grupo.emit(self, globales.DERECHA)

func _emitir_señal_salida_derecha():
	cursor_no_sobre_grupo.emit(self, globales.DERECHA)
