class_name Titulo extends RichTextLabel

static var escena_titulo_tienda: PackedScene = preload("res://proyecto_rummikub/tiendaObjetosFueraPartida/titulo.tscn")


static func Titulo(texto:String) -> Titulo:
	var nuevo_titulo_tienda: Titulo = escena_titulo_tienda.instantiate()
	nuevo_titulo_tienda.text = texto
	return nuevo_titulo_tienda

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
