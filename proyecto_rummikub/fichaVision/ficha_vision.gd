class_name FichaVision extends Control

# Responabilidad: Emitir señales cuando pasas por encima, verse, tener color y número

const shader_arcoiris: Shader = preload("res://shaders/efectoArcoiris.gdshader")
const shader_metalico: Shader = preload("res://shaders/efectoMetalico.gdshader")

static var escena_ficha: PackedScene = preload("res://proyecto_rummikub/fichaVision/FichaVision.tscn")
static var indice: int = -1
const tamano_fichas : Vector2 = Vector2(35.0, 49.0)

var mi_indice : int
# estado puede ser: MANO, TABLERO_FIJADA, TABLERO_NO_FIJADA
var estado : globales.ESTADO_FICHA

## jugada o en la mano
var jugada: bool
var en_blanco : bool
var color: Ficha.COLOR
var numero: int
var especial: Ficha.ESPECIAL

static func fichaVision(color_in: Ficha.COLOR, numero_in: int, especial_in: Ficha.ESPECIAL =  Ficha.ESPECIAL.NO) -> FichaVision:
	var ficha_creada: FichaVision = escena_ficha.instantiate()
	ficha_creada.z_index = 0
	ficha_creada.name = str((indice +1 ))
	ficha_creada.cambiar_sprite(color_in, numero_in, especial_in)
	ficha_creada.jugada = false;
	ficha_creada.color = color_in
	ficha_creada.numero = numero_in
	ficha_creada.especial = especial_in
	ficha_creada.resaltar_aura()
	return ficha_creada


func cambiar_sprite(color_in: Ficha.COLOR, numero_in: int, especial_in: Ficha.ESPECIAL):
	self.color = color_in
	self.numero = numero_in
	self.especial = especial_in
	
	en_blanco = false
	$Numero.text = str(numero_in) + "\n"
	$auraFicha.visible = false
	$caraJoker.visible = false
	match color_in:
		Ficha.COLOR.ROJO:
			$Numero.text += "♡"
			$Numero.modulate = "b92300"
			$fondoFicha.texture = load("res://imagenes/imagenes_carta/carta.svg")
			$auraFicha.texture = load("res://imagenes/imagenes_carta/circulo.png")
		
		Ficha.COLOR.NEGRO: 
			$Numero.text += "♤"
			$Numero.modulate = "000000"
			$fondoFicha.texture = load("res://imagenes/imagenes_carta/carta.svg")
			$auraFicha.texture = load("res://imagenes/imagenes_carta/circulo.png")
		
		Ficha.COLOR.AZUL:
			$Numero.text += "♢"
			$Numero.modulate = "00aeaf"
			$fondoFicha.texture = load("res://imagenes/imagenes_carta/carta.svg")
			$auraFicha.texture = load("res://imagenes/imagenes_carta/circulo.png")
		
		Ficha.COLOR.AMARILLO:
			$Numero.text += "♧"
			$Numero.modulate = "cfce00"
			$fondoFicha.texture = load("res://imagenes/imagenes_carta/carta.svg")
			$auraFicha.texture = load("res://imagenes/imagenes_carta/circulo.png")
		
		Ficha.COLOR.BLANCO:
			en_blanco = true
			$Numero.text = ""
		
		Ficha.COLOR.COMODIN:
			$Numero.text = ""
			$fondoFicha.texture = load("res://imagenes/imagenes_carta/carta.svg")
			$auraFicha.texture = load("res://imagenes/imagenes_carta/circulo.png")
			$caraJoker.visible = true
	
	match especial_in:
		Ficha.ESPECIAL.NO:
			pass
		Ficha.ESPECIAL.ARCOIRIS:
			var my_mat = ShaderMaterial.new()
			my_mat.shader = shader_arcoiris
			#$fondoFicha.material = my_mat
			$auraFicha.material = my_mat
			$caraJoker.material = my_mat
			$Numero.material = my_mat
			#$Numero.text = "[rainbow freq=0.5 sat=0.8 val=1]" + $Numero.text
		Ficha.ESPECIAL.DORADO:
			var my_mat = ShaderMaterial.new()
			if (color_in == Ficha.COLOR.AMARILLO):
				$Numero.modulate = "929200"
			my_mat.shader = shader_metalico
			$fondoFicha.material = my_mat
			$fondoFicha.texture = load("res://imagenes/imagenes_carta/carta_dorada.png")
		
		Ficha.ESPECIAL.DORADARCOIRIS:
			var my_mat = ShaderMaterial.new()
			if (color_in == Ficha.COLOR.AMARILLO):
				$Numero.modulate = "929200"
			my_mat.shader = shader_metalico
			$fondoFicha.material = my_mat
			$fondoFicha.texture = load("res://imagenes/imagenes_carta/carta_dorada.png")
			my_mat.shader = shader_arcoiris
			$auraFicha.material = my_mat
			$caraJoker.material = my_mat
			$Numero.material = my_mat

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func resaltar_aura():
	$auraFicha.visible = true

func desresaltar_aura():
	$auraFicha.visible = false
