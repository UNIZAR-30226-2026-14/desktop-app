# variables globales del proyecto:
extends Node

enum {IZQUIERDA, DERECHA}

enum ESTADO_FICHA {MANO, TABLERO_FIJADA, TABLERO_NO_FIJADA}


enum ESTADO_CURSOR {MANO, TABLERO, LIMBO}

static var estado_cursor

# sin uso aun pero quiero usarlo para devolver la ficha al tablero si el cursor 
# viene del tablero o a la mano si venia de la mano
static var estado_anterior_cursor

func apropiar_hijo(nuevo_padre: Node, hijo: Node) -> void:
	if hijo.get_parent():
		hijo.get_parent().remove_child(hijo)
	nuevo_padre.add_child(hijo)
