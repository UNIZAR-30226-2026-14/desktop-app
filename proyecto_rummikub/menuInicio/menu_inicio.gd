extends Control

@export var botonAmigos: Button
@export var botonCerrarPestanaAmigos: Button

class estadoAmigo:
	var conectado: bool
	var nombre: String
	var imagen
	
	func _init(nombre_: String, conectado_: bool) -> void:
		nombre = nombre_
		conectado = conectado_


static var estadoAmigos: Array[estadoAmigo] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$BarraSuperior/NombreUsuario.text = ConectorRed.username
	botonAmigos.pressed.connect(_sacar_amigos)
	botonCerrarPestanaAmigos.pressed.connect(_cerrar_amigos)
	estadoAmigos = [ estadoAmigo.new("Miguel", true), estadoAmigo.new("Dian", false),estadoAmigo.new("Miguel", true), estadoAmigo.new("Dian", false),estadoAmigo.new("Miguel", true), estadoAmigo.new("Dian", false),estadoAmigo.new("Miguel", true), estadoAmigo.new("Dian", false),estadoAmigo.new("Miguel", true), estadoAmigo.new("Dian", false)]
	for amigo in estadoAmigos:
		var nuevoAmigo: Amigo =  Amigo.amigo(amigo.conectado,amigo.nombre)
		globales.apropiar_hijo($MenuAmigos/ScrollContainer/contenedorAmigos,nuevoAmigo )

func _sacar_amigos() -> void:
	$MenuAmigos.visible = true

func _cerrar_amigos() -> void:
	$MenuAmigos.visible = false
