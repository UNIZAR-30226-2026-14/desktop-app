class_name SelectorFicha extends Panel
signal ficha_seleccionada
var boton_pulsado: int = -1

func _ready() -> void:
	$GridContainer/FichaVision/Button0.toggled.connect(_boton0)
	$GridContainer/FichaVision/Button0.toggled.connect(_boton1)
	$GridContainer/FichaVision/Button0.toggled.connect(_boton2)

func sacar_selector(lista_fichas: Array[Ficha]) -> Ficha:
	$GridContainer/FichaVision.cambiar_sprite(lista_fichas[0].color,lista_fichas[0].numero,lista_fichas[0].especial)
	$GridContainer/FichaVision.cambiar_sprite(lista_fichas[1].color,lista_fichas[1].numero,lista_fichas[1].especial)
	$GridContainer/FichaVision.cambiar_sprite(lista_fichas[2].color,lista_fichas[2].numero,lista_fichas[2].especial)
	self.visible = true
	await ficha_seleccionada
	return lista_fichas[boton_pulsado]

func _boton_confirmar() -> void:
	if boton_pulsado != -1:
		ficha_seleccionada.emit()

func _boton0(toggled: bool) -> void:
	if toggled:
		boton_pulsado = 0
	
func _boton1(toggled: bool) -> void:
	if toggled:
		boton_pulsado = 1

func _boton2(toggled: bool) -> void:
	if toggled:
		boton_pulsado = 2
