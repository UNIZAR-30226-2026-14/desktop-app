class_name ContadorTiempo extends Node2D

@export var manager_juego: Node2D

signal termina_turno

enum MODO {MI_TURNO, ESPERANDO_TURNO}

const TIEMPO_TURNO: int = 30
var tiempo: int
var mitad_de_tiempo: bool = false

var modo: MODO = MODO.ESPERANDO_TURNO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	manager_juego.empieza_turno.connect(_empieza_turno)
	manager_juego.termina_turno.connect(_termina_turno)

func proceso_contador() -> void:
	modo = MODO.ESPERANDO_TURNO
	while true:
		match modo:
			MODO.MI_TURNO:
				$relojArena.rotation = 0
				if tiempo == 0:
					termina_turno.emit()
					manager_juego.robar_carta()
				await get_tree().create_timer(1.0).timeout
				tiempo -= 1
				$contadorTiempo.text = str(tiempo)
			MODO.ESPERANDO_TURNO:
				$contadorTiempo.text = ""
				if is_inside_tree():
					await get_tree().physics_frame
				if $relojArena.rotation == 360:
					$relojArena.rotation = 0
				$relojArena.rotation += 0.05

func _empieza_turno() -> void:
	$relojArena.rotation = 0
	modo = MODO.MI_TURNO
	tiempo = TIEMPO_TURNO
	if mitad_de_tiempo:
		tiempo /= 2
	$contadorTiempo.text = str(tiempo)


func _termina_turno() -> void:
	modo = MODO.ESPERANDO_TURNO
	$contadorTiempo.text = ""
	mitad_de_tiempo = false

func reducir_a_mitad_tiempo() -> void:
	mitad_de_tiempo = true
