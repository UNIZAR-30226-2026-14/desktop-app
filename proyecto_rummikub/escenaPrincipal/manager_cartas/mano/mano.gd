extends Node2D

var fichas_en_mano: Array[Node]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func anadir_ficha(ficha:Node) -> void:
	fichas_en_mano.append(ficha)

func quitar_carta(ficha:Node) -> void:
	fichas_en_mano.erase(ficha)
	
func ordenar_por_tipo() -> void:
	pass
	
func ordenar_por_numero() -> void:
	pass
