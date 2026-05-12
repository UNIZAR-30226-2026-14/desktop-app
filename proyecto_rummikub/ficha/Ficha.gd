class_name Ficha extends Node2D
@export var area2d: Area2D

# Responabilidad: Emitir señales cuando pasas por encima, verse, tener color y número

signal cursor_sobre_ficha
signal cursor_no_sobre_ficha

enum COLOR{ROJO=0, NEGRO=1, AZUL=2, AMARILLO=3, BLANCO=4, COMODIN=5}
enum ESPECIAL{NO, ARCOIRIS, DORADO, DORADARCOIRIS}
const shader_arcoiris: Shader = preload("res://shaders/efectoArcoiris.gdshader")
const shader_metalico: Shader = preload("res://shaders/efectoMetalico.gdshader")

static var escena_ficha: PackedScene = preload("res://proyecto_rummikub/ficha/Ficha.tscn")
static var indice: int = -1
const tamano_fichas : Vector2 = Vector2(35.0, 49.0)

var mi_indice : int
# estado puede ser: MANO, TABLERO_FIJADA, TABLERO_NO_FIJADA
var estado : globales.ESTADO_FICHA

var miGrupo : Grupo_fichas
## jugada o en la mano
var jugada: bool
var en_blanco : bool
var color: COLOR
var numero: int
var especial: ESPECIAL

class GuardaFicha:
	var numero: int
	var color: Color
	func _init(num:int=0, col:Ficha.COLOR=Ficha.COLOR.BLANCO) -> void:
		numero = num ;  color = col
	func equiv(ficha: Ficha.GuardaFicha)->bool:
		return numero == ficha.numero && color == ficha.color


## toma ficha o GuardaFicha
@warning_ignore("shadowed_variable")
static func hash_ficha(ficha)->int:
	return hash(ficha.numero) ^ hash(ficha.color)


static func ficha(color_in: COLOR, numero_in: int, especial_in: ESPECIAL =  ESPECIAL.NO) -> Node2D:
	var ficha_creada: Node2D = escena_ficha.instantiate()
	ficha_creada.z_index = 0
	ficha_creada.estado = globales.ESTADO_FICHA.MANO
	ficha_creada.name = str((indice +1 ))
	ficha_creada.cambiar_sprite(color_in, numero_in, especial_in)
	ficha_creada.get_child(3).get_child(0).shape.size = tamano_fichas
	ficha_creada.jugada = false;
	ficha_creada.color = color_in
	ficha_creada.numero = numero_in
	ficha_creada.especial = especial_in
	return ficha_creada

func set_grupo(grupo: Grupo_fichas):
	miGrupo = grupo
	
func get_grupo() -> Grupo_fichas:
	return miGrupo

# devuelve el tamaño por defecto de las fichas
static func tamano_ficha_static() -> Vector2:
	return tamano_fichas

# devuelve el tamaño de una ficha
func tamano_ficha() -> Vector2:
	return Vector2($Area2D/CollisionShape2D.shape.get_size())

func cambiar_sprite(color_in: COLOR, numero_in: int, especial_in: ESPECIAL):
	en_blanco = false
	$Numero.text = str(numero_in) + "\n"
	$auraFicha.visible = false
	$caraJoker.visible = false
	match color_in:
		COLOR.ROJO:
			$Numero.text += "♡"
			$Numero.modulate = "b92300"
			$fondoFicha.texture = load("res://imagenes/imagenes_carta/carta.svg")
			$auraFicha.texture = load("res://imagenes/imagenes_carta/circulo.png")
		
		COLOR.NEGRO: 
			$Numero.text += "♤"
			$Numero.modulate = "000000"
			$fondoFicha.texture = load("res://imagenes/imagenes_carta/carta.svg")
			$auraFicha.texture = load("res://imagenes/imagenes_carta/circulo.png")
		
		COLOR.AZUL:
			$Numero.text += "♢"
			$Numero.modulate = "00aeaf"
			$fondoFicha.texture = load("res://imagenes/imagenes_carta/carta.svg")
			$auraFicha.texture = load("res://imagenes/imagenes_carta/circulo.png")
		
		COLOR.AMARILLO:
			$Numero.text += "♧"
			$Numero.modulate = "cfce00"
			$fondoFicha.texture = load("res://imagenes/imagenes_carta/carta.svg")
			$auraFicha.texture = load("res://imagenes/imagenes_carta/circulo.png")
		
		COLOR.BLANCO:
			en_blanco = true
			$Numero.text = ""
		COLOR.COMODIN:
			$Numero.text = ""
			$fondoFicha.texture = load("res://imagenes/imagenes_carta/carta.svg")
			$auraFicha.texture = load("res://imagenes/imagenes_carta/circulo.png")
			$caraJoker.visible = true
	match especial_in:
		ESPECIAL.NO:
			pass
		ESPECIAL.ARCOIRIS:
			var my_mat = ShaderMaterial.new()
			my_mat.shader = shader_arcoiris
			#$fondoFicha.material = my_mat
			$auraFicha.material = my_mat
			$caraJoker.material = my_mat
			$Numero.material = my_mat
			#$Numero.text = "[rainbow freq=0.5 sat=0.8 val=1]" + $Numero.text
		ESPECIAL.DORADO:
			var my_mat = ShaderMaterial.new()
			if (color_in == COLOR.AMARILLO):
				$Numero.modulate = "929200"
			my_mat.shader = shader_metalico
			$fondoFicha.material = my_mat
			$fondoFicha.texture = load("res://imagenes/imagenes_carta/carta_dorada.png")
		
		ESPECIAL.DORADARCOIRIS:
			var my_mat = ShaderMaterial.new()
			if (color_in == COLOR.AMARILLO):
				$Numero.modulate = "929200"
			my_mat.shader = shader_metalico
			$fondoFicha.material = my_mat
			$fondoFicha.texture = load("res://imagenes/imagenes_carta/carta_dorada.png")
			my_mat.shader = shader_arcoiris
			$auraFicha.material = my_mat
			$caraJoker.material = my_mat
			$Numero.material = my_mat

##Compara si numero y color es igual a Ficha o GuardaFicha
@warning_ignore("shadowed_variable")
func equiv(ficha:Ficha)->bool:
	return numero == ficha.numero && color == ficha.color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	indice += 1
	mi_indice = indice 
	area2d.mouse_entered.connect(_emitir_señal_entrada)
	area2d.mouse_exited.connect(_emitir_señal_salida)

func _emitir_señal_entrada():
	cursor_sobre_ficha.emit(self)

func _emitir_señal_salida():
	cursor_no_sobre_ficha.emit(self)

func resaltar_aura():
	$auraFicha.visible = true

func desresaltar_aura():
	$auraFicha.visible = false

func volver_dorada()->void:
	var my_mat = ShaderMaterial.new()
	if (color == COLOR.AMARILLO):
		$Numero.modulate = "929200"
	my_mat.shader = shader_metalico
	$fondoFicha.material = my_mat
	$fondoFicha.texture = load("res://imagenes/imagenes_carta/carta_dorada.png")
	if especial == ESPECIAL.ARCOIRIS:
		especial = ESPECIAL.DORADARCOIRIS
		
	else:
		especial = ESPECIAL.DORADO

func ocultar_ficha() -> void:
	if color == COLOR.COMODIN:
		$caraJoker.visible = false
	else:
		$Numero.visible = false

func revelar_ficha() -> void:
	if color == COLOR.COMODIN:
		$caraJoker.visible = true
	else:
		$Numero.visible = true

static func color_a_string(color_in: COLOR) -> String:
	match(color_in):
		COLOR.BLANCO:
			return "blanco"
		COLOR.COMODIN:
			return "comodin"
		COLOR.ROJO:
			return "rojo"
		COLOR.NEGRO:
			return "negro"
		COLOR.AZUL:
			return "azul"
		COLOR.AMARILLO:
			return "amarillo"
	return "ERROR"
