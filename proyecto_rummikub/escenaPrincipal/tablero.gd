extends Node2D

var grupoFichas = preload("res://proyecto_rummikub/ficha/grupo_fichas.tscn")

var fichas = []
var fichas_viejas = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


var grupo 
func _on_guarda_pressed() -> void:
	grupo = grupoFichas.instantiate()
	self.add_child(grupo)
	#for ficha in fichas:
		#fichas_viejas[ficha] = ficha.position
		#print(fichas_viejas[ficha])


func _on_vuelve_pressed() -> void:
	grupo.anadir_carta(fichas[0])
	#for ficha in fichas_viejas.keys():
		#ficha.position = fichas_viejas[ficha]
