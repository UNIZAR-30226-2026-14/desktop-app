class_name PanelContadorMonedas extends Panel

func reducir_dinero(cantidad: int)-> void:
	$contadorMonedas.text = str(int($contadorMonedas.text) - cantidad)

func aumentar_dinero(cantidad: int)-> void:
	$contadorMonedas.text = str(int($contadorMonedas.text) + cantidad)

func get_dinero() -> int:
	return int($contadorMonedas.text)

func set_imagen(nueva_imagen: Texture2D)-> void:
	$IconoMoneda.texture = nueva_imagen

func set_dinero(cantidad: String) -> void:
	$contadorMonedas.text = cantidad

func _ready() -> void:
	set_dinero("0")
