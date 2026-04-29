# variables globales del proyecto:
extends Node

enum LADOS {IZQUIERDA, DERECHA}

enum ESTADO_FICHA {MANO, TABLERO_FIJADA, TABLERO_NO_FIJADA}

enum ESTADO_CURSOR {MANO, TABLERO, LIMBO}

enum ESTADO_JUEGO {NO_MI_TURNO, PONIENDO_FICHAS, NO_PONIENDO_FICHAS}

class datos_poder:
	var imagen: Texture2D
	var descripcion: String
	var precio: int
	
	func _init(imagen_in: Texture2D, descripcion_in: String, precio_in: int) -> void:
		imagen = imagen_in
		descripcion = descripcion_in
		precio = precio_in

static var estado_cursor: ESTADO_CURSOR
static var estado_juego: ESTADO_JUEGO

# sin uso aun pero quiero usarlo para devolver la ficha al tablero si el cursor 
# viene del tablero o a la mano si venia de la mano
static var estado_anterior_cursor: ESTADO_CURSOR

static var nombre_usuario: String = ""
static var contrasena: String = ""
static var avatar: Texture2D = preload("res://imagenes/avatares_posibles/Dani.png")

const LISTA_AVATARES: Dictionary[String,Texture2D] = {
	"alex": preload("res://imagenes/avatares_posibles/Alex.png"),
	"dani" : preload("res://imagenes/avatares_posibles/Dani.png"),
	"dian" : preload("res://imagenes/avatares_posibles/Dian.png"),
	"fernando" : preload("res://imagenes/avatares_posibles/Fernando.png"),
	"gonzalo" : preload("res://imagenes/avatares_posibles/Gonzalo.png"),
	"miguel" : preload("res://imagenes/avatares_posibles/Miguel.png"),
}
func set_avatar(av: String):
	if av != "": avatar = LISTA_AVATARES[av.to_lower()]
	else: avatar = LISTA_AVATARES["dani"]
func get_avatar(av: String):
	if av.to_lower() in LISTA_AVATARES.keys():
		return LISTA_AVATARES[av.to_lower()]
	else:
		return LISTA_AVATARES["dani"]


const colores: Dictionary[String,Color] = {
	"Verde": Color(0.059, 0.184, 0.122, 1.0),
	"Amarillo": Color(0.927, 0.927, 0.0, 1.0),
	"Azul marino": Color(0.0, 0.0, 0.126, 1.0),
	"Gris": Color(0.502, 0.502, 0.502, 1.0),
	"Rojo": Color(0.529, 0.0, 0.0, 1.0),
}


static var  skin_tablero_equipada: Color = colores["Verde"]
static var skin_ficha_equipada: Texture2D


func apropiar_hijo(nuevo_padre: Node, hijo: Node) -> void:
	if hijo.get_parent():
		hijo.get_parent().remove_child(hijo)
	nuevo_padre.add_child(hijo)
