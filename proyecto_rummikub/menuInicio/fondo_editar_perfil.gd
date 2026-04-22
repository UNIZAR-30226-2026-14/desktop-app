extends Panel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false

func _on_boton_cerrar_pressed() -> void:
	self.visible = false
