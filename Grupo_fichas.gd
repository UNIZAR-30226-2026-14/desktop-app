class_name Grupo_fichas extends Node2D

# Agrupación de cartas, usado para verificar correcta posición de la mesa
# y para hacer que la posición de las fichas en el mismo grupo sea contigua

var escena = preload("res://proyecto_rummikub/ficha/grupo_fichas.tscn")

var fichas : Array[Ficha] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area2D/CollisionShape2D.shape.size.y = Ficha.tamano_ficha_static().y
	$Area2D/CollisionShape2D.shape.size.x = Ficha.tamano_ficha_static().x * 1.5

func anadir_carta(ficha : Ficha) -> void:
	self.add_child(ficha)

	fichas.append(ficha)
	ficha.set_grupo(self)

	$Area2D/CollisionShape2D.shape.size.x += ficha.tamano_ficha().x
	
	ficha.transform = Transform2D()


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
		ficha.position.x = ficha.tamano_ficha()/2 + (ficha.tamano_ficha()) * indice - (ficha.tamano_ficha()*fichas.size())/2
		indice += 1

func grupo_correcto() -> bool:
	return true
