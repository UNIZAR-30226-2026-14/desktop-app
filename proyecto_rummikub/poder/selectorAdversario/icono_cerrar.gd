extends Button

signal cerrar_eleccion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_cerrar_eleccion)

func _cerrar_eleccion() -> void:
	cerrar_eleccion.emit("")
