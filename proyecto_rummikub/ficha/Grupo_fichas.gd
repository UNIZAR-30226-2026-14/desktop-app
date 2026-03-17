class_name Grupo_fichas extends Node2D

signal cursor_sobre_grupo
signal cuersor_fuera_grupo


# Agrupación de cartas, usado para verificar correcta posición de la mesa
# y para hacer que la posición de las fichas en el mismo grupo sea contigua

var escena = preload("res://proyecto_rummikub/ficha/grupo_fichas.tscn")
const tamano_extra = 1.5

var fichas : Array[Ficha] = []
var anchura_hitbox = Ficha.tamano_ficha_static().x * tamano_extra

func recalcula_anchura() -> void:
	$izquierda/CollisionShape2D.shape.size.x = anchura_hitbox / 2
	$derecha/CollisionShape2D.shape.size.x = anchura_hitbox / 2
	$izquierda/CollisionShape2D.position.x = -anchura_hitbox / 4
	$derecha/CollisionShape2D.position.x = anchura_hitbox / 4


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$izquierda/CollisionShape2D.shape.size.y = Ficha.tamano_ficha_static().y
	$derecha/CollisionShape2D.shape.size.y = Ficha.tamano_ficha_static().y
	recalcula_anchura()

func anadir_ficha(ficha : Ficha) -> void:
	self.add_child(ficha)
	fichas.append(ficha)
	ficha.set_grupo(self)
	anchura_hitbox += ficha.tamano_ficha().x
	recalcula_anchura()
	ficha.transform = Transform2D()
	posicionar_fichas()


# ficha es la ficha en la cual se está partiendo
# quita del grupo todas las fichas a la izquierda de ficha, y las introduce en un nuevo grupo
# devuelve el nuevo grupo
# IMPORTANTE: asume que ficha está en el grupo y que el grupo no está vacío
func partir(ficha: Ficha) -> Grupo_fichas:
	var grupo: Grupo_fichas = escena.instantiate()
	for i in fichas.size():
		if fichas[i] == ficha: return grupo
		
		grupo.anadir_carta(fichas[i])
		fichas[i].set_grupo(grupo)
		fichas.remove_at(i)
	return grupo
	
func posicionar_fichas() -> void:
	var indice = 0
	for ficha in fichas:
		print(indice)
		ficha.position.x = ficha.tamano_ficha().x/2 + (ficha.tamano_ficha().x) * indice - (ficha.tamano_ficha().x*fichas.size())/2
		indice += 1

func grupo_correcto() -> bool:
	return true


func _on_area_2d_mouse_entered() -> void:
	emit_signal("sobre_mi",self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("no_sobre_mi",self)
