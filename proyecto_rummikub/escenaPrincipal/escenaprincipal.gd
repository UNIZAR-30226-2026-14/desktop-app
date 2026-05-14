extends Node2D

var es_arcade: bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Fondo.modulate = globales.get_color_tablero()
	$Fondo.visible = true
	$PantallaPartidaPausada.visible = false
	# dian tienes que llenar estas listas tienen valores placeholder:
	#var iconos_rivales: Array[Texture2D] = [preload("res://imagenes/avatares_posibles/Dian.png"), preload("res://imagenes/avatares_posibles/Miguel.png"), preload("res://imagenes/avatares_posibles/Dani.png")] 
	#var nombres_rivales: Array[String] = ["Dian", "Miguel", "Daniel"]
	
	#inicializar_rivales(iconos_rivales, nombres_rivales)
	
	if not es_arcade:
		activar_modo_clasico()

func completarJugada() -> void:
	pass

func inicializar_rivales(iconos: Array[Texture2D], nombres: Array[String]) -> void:
	$IconoRival.actualiar_icono_y_nombre(iconos[0], nombres[0])
	$IconoRival2.actualiar_icono_y_nombre(iconos[1], nombres[1])
	$IconoRival3.actualiar_icono_y_nombre(iconos[2], nombres[2])

func activar_modo_clasico() -> void:
	$Poder.visible  = false
	$Poder2.visible = false
	$Poder3.visible = false
	$panelContadorMonedas.visible = false
