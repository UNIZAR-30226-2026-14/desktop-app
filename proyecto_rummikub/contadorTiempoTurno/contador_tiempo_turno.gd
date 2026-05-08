extends Node2D

@export var manager_juego: Node2D

enum MODO {MI_TURNO, ESPERANDO_TURNO}

const TIEMPO_TURNO: int = 60
var tiempo: int
var mitad_de_tiempo: bool = false

var modo: MODO = MODO.MI_TURNO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	manager_juego.empieza_turno.connect(_empieza_turno)
	manager_juego.termina_turno.connect(_termina_turno)
	_proceso_contador()

func _proceso_contador() -> void:
	while true:
		match modo:
			MODO.MI_TURNO:
				$relojArena.rotation = 0
				if tiempo == 0:
					manager_juego.terminar_turno()
				await get_tree().create_timer(1.0).timeout
				tiempo -= 1
				$contadorTiempo.text = str(tiempo)
			MODO.ESPERANDO_TURNO:
				$contadorTiempo.text = ""
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
