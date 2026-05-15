class_name Poder extends Node2D


@export var escena_principal: Node2D
signal cursor_sobre_poder
signal cursor_no_sobre_poder

enum PODER {NINGUNO, ANGEL_GUARDA, BOLA_CRISTAL, TOQUE_MIDAS, MAS_CUATRO, TRUEQUE,
			GUANTE_BLANCO, BOMBA_HUMO, REDUCIR_TIEMPO, TECHO_CRISTAL}

const LISTA_PRECIOS_OBJETOS: Array[int] = [
	0,
	6,
	6,
	3,
	6,
	6,
	6,
	6,
	6,
	6,
]

const LISTA_DESCRIPCIONES_OBJETOS: Array[String] = [
	"",
	"proteccion ante otro objeto, tras bloquear uno este se gasta",
	"poder ver las fichas y objetos de un jugador",
	"convierte de 2 a 4 de tus fichas en fichas doradas (al azar)",
	"hacer que un oponente robe 4 fichas",
	"mira 3 fichas de un oponente, elige una de esas tres y una tuya, las intercambias",
	"permite robarle un objeto a un jugador",
	"hacer que un jugador no pueda ver las fichas puestas en tablero",
	"reducir a la mitad el tiempo del proximo turno de un jugador",
	"la siguiente jugada de un adversario tenga que ser de 30 o mas",
]


const LISTA_TEXTURAS_PODERES: Array[Texture] = [
	preload("res://imagenes/imagenes_poderes/mas.png"),
	preload("res://imagenes/imagenes_poderes/angel-de-la-guarda.png"),
	preload("res://imagenes/imagenes_poderes/bola-de-cristal.png"),
	preload("res://imagenes/imagenes_poderes/toque-de-midas.png"),
	preload("res://imagenes/imagenes_poderes/+4.png"),
	preload("res://imagenes/imagenes_poderes/intercambio.png"),
	preload("res://imagenes/imagenes_poderes/guante_blanco.png"),
	preload("res://imagenes/imagenes_poderes/bomba-de-humo.png"),
	preload("res://imagenes/imagenes_poderes/mitad-de-tiempo.png"),
	preload("res://imagenes/imagenes_poderes/techo_de_cristal.png"),
	]

static var indice = 0
var mi_indice

@export var area_poder: Area2D
@export var icono_poder: Sprite2D

@export var manager_fichas: Node2D
@export var manager_juego: ManagerJuego

@export var tienda_objetos: Node
@export var selector_adversario: Control
@export var selector_ficha: SelectorFicha
var poder: PODER

func cambiar_poder(nuevo_poder: PODER):
	icono_poder.texture = LISTA_TEXTURAS_PODERES[nuevo_poder]
	poder = nuevo_poder

func get_poder() -> PODER:
	return poder

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mi_indice = indice
	indice += 1
	area_poder.mouse_entered.connect(_actualizar_estado_cursor_entra)
	area_poder.mouse_exited.connect(_actualizar_estado_cursor_sale)
	manager_fichas.conectar_poder(self)
	cambiar_poder(Poder.PODER.NINGUNO)

func _actualizar_estado_cursor_entra() -> void:
	cursor_sobre_poder.emit(self)

func _actualizar_estado_cursor_sale() -> void:
	cursor_no_sobre_poder.emit(self)

func ejecutar_poder() -> void:
	if globales.estado_juego == globales.ESTADO_JUEGO.NO_MI_TURNO:
		PopUp.popUp(" solo puedes usar poderes en tu turno " ,Vector2(-74.0, -300.0), escena_principal)
		return
	match poder:
		PODER.NINGUNO:
			var resultado: PODER = await(tienda_objetos.abrir_tienda(self))
			cambiar_poder(resultado)
			
		PODER.ANGEL_GUARDA:
			pass
			
		PODER.BOLA_CRISTAL:
			var adversaro_elegido: String = await selector_adversario.sacar_selector_adversarios(poder)
			if adversaro_elegido != "":
				manager_juego.usar_bola_de_cristal(adversaro_elegido)
				cambiar_poder(PODER.NINGUNO)
			
		PODER.TOQUE_MIDAS:
			cambiar_poder(PODER.NINGUNO)
			manager_juego.toque_de_midas_mi()
			
		PODER.TRUEQUE:
			var adversaro_elegido: String = await selector_adversario.sacar_selector_adversarios(poder)
			if adversaro_elegido != "":
				var fichas_adversario: Array[Ficha] = await manager_juego.usar_trueque1(adversaro_elegido)
				var intercambio: Array[Ficha] = await selector_ficha.sacar_selector(fichas_adversario)
				if (intercambio[0]!=null) and (intercambio[1] != null):
					manager_juego.usar_trueque2(adversaro_elegido,intercambio[1],intercambio[0])
					cambiar_poder(PODER.NINGUNO)
			
		PODER.BOMBA_HUMO:
			var adversaro_elegido: String = await selector_adversario.sacar_selector_adversarios(poder)
			if adversaro_elegido != "":
				manager_juego.lanzar_maldicion(adversaro_elegido, PODER.BOMBA_HUMO)
				cambiar_poder(PODER.NINGUNO)
			
		PODER.REDUCIR_TIEMPO:
			var adversaro_elegido: String = await selector_adversario.sacar_selector_adversarios(poder)
			if adversaro_elegido != "":
				manager_juego.lanzar_maldicion(adversaro_elegido, PODER.REDUCIR_TIEMPO)
				cambiar_poder(PODER.NINGUNO)
			
		PODER.GUANTE_BLANCO:
			var adversaro_elegido: String = await selector_adversario.sacar_selector_adversarios(poder)
			if adversaro_elegido != "":
				var poder_robado: PODER = manager_juego.usar_guante_blanco(adversaro_elegido)
				cambiar_poder(poder_robado)
			
		PODER.TECHO_CRISTAL:
			var adversaro_elegido: String = await selector_adversario.sacar_selector_adversarios(poder)
			if adversaro_elegido != "":
				manager_juego.lanzar_maldicion(adversaro_elegido, PODER.TECHO_CRISTAL)
				cambiar_poder(PODER.NINGUNO)
		PODER.MAS_CUATRO:
			var adversaro_elegido: String = await selector_adversario.sacar_selector_adversarios(poder)
			if adversaro_elegido != "":
				manager_juego.lanzar_maldicion(adversaro_elegido, PODER.MAS_CUATRO)
				cambiar_poder(PODER.NINGUNO)

static func poder_a_string(poder_in: PODER) -> String:
	match(poder_in):
		PODER.NINGUNO:
			return "ninguno"
		PODER.ANGEL_GUARDA:
			return "angel de la guarda"
		PODER.BOLA_CRISTAL:
			return "bola de cristal"
		PODER.TOQUE_MIDAS:
			return "toque de midas"
		PODER.MAS_CUATRO:
			return "mas cuatro"
		PODER.TRUEQUE:
			return "trueque"
		PODER.GUANTE_BLANCO:
			return "guante blanco"
		PODER.BOMBA_HUMO:
			return "bomba de humo"
		PODER.REDUCIR_TIEMPO:
			return "reducir el tiempo"
		PODER.TECHO_CRISTAL:
			return "techo de cristal"
	return "error"
