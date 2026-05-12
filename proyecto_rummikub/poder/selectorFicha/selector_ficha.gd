class_name SelectorFicha extends Panel

const DISTANCIA_HORIZONTAL: float = 11.2
signal ficha_seleccionada

var boton_pulsado: int = -1
var ficha_pulsada: int = -1
var cerrando: bool = false

var aumento_aux: float
var fichas_de_mas_aux:float

@export var ficha0: FichaVision
@export var ficha1: FichaVision
@export var ficha2: FichaVision

@export var manager_juego: ManagerJuego

func _ready() -> void:
	$GridContainer/FichaVision/Button0.toggled.connect(_boton0)
	$GridContainer/FichaVision2/Button1.toggled.connect(_boton1)
	$GridContainer/FichaVision3/Button2.toggled.connect(_boton2)
	$botonConfirmar.pressed.connect(_boton_confirmar)
	$BotonCerrar.pressed.connect(_boton_cerrar)
	manager_juego.termina_turno.connect(_boton_cerrar)
	self.visible = false


func _boton_cerrar()->void:
	cerrando = true
	ficha_seleccionada.emit()

## primero ficha adversario segundo ficha propia
func sacar_selector(lista_fichas: Array[Ficha]) -> Array[Ficha]:
	if lista_fichas[0] != null:
		ficha0.visible = true
		ficha0.cambiar_sprite(lista_fichas[0].color,lista_fichas[0].numero,lista_fichas[0].especial)
	else:
		ficha0.visible = false
	if lista_fichas[1] != null:
		ficha1.visible = true
		ficha1.cambiar_sprite(lista_fichas[1].color,lista_fichas[1].numero,lista_fichas[1].especial)
	else:
		ficha1.visible = false
	
	if lista_fichas[2] != null:
		ficha2.visible = true
		ficha2.cambiar_sprite(lista_fichas[2].color,lista_fichas[2].numero,lista_fichas[2].especial)
	else: 
		ficha2.visible = false
	
	ajustar_tablero()
	self.visible = true
	print("esperando ficha")
	await ficha_seleccionada
	print("ficha obtenida")
	# primero ficha propia segundo ficha adversario
	
	if not cerrando:
		var ficha_adversario: Ficha = lista_fichas[boton_pulsado]
		var ficha_propia: Ficha = manager_juego.get_fichas_mano()[ficha_pulsada]
		_quitar_selector()
		return [ficha_adversario, ficha_propia]
	else:
		_quitar_selector()
		return [null, null]

func _boton_confirmar() -> void:
	if boton_pulsado != -1 and ficha_pulsada != -1:
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

func _pulsacion_ficha(ficha:int) -> void:
	print("AAAAAAA")
	if ficha == -1:
		print("ES NULL al entrar")
	ficha_pulsada = ficha
	print("OOOOOO " + str(ficha_pulsada))

func ajustar_tablero()->void:
	var fichas_mano: Array[Ficha]  = manager_juego.get_fichas_mano()
	var fichas_de_mas: float = (fichas_mano.size()/2.0) -9
	@warning_ignore("integer_division")
	var aux: int = (fichas_mano.size()/2) -9
	if (fichas_de_mas-aux) > 0:
		fichas_de_mas += 0.5
	fichas_de_mas_aux = fichas_de_mas
	var aumento: float = (((fichas_mano[0].tamano_ficha().x + DISTANCIA_HORIZONTAL)*(fichas_de_mas) )) 
	$Panel.size.x += aumento
	aumento_aux = aumento
	$Panel.position.x -= aumento /2
	for ficha: FichaVision in $Panel/ContenedorFichas.get_children():
		ficha.queue_free()
	
	$Panel/ContenedorFichas.columns = 9+fichas_de_mas
	var i:int = 0
	for ficha: Ficha in fichas_mano:
		var ficha_aux: FichaVision = FichaVision.fichaVision(ficha.color,ficha.numero,ficha.especial)
		ficha_aux.desresaltar_aura()
		globales.apropiar_hijo($Panel/ContenedorFichas, ficha_aux)
		if ficha == null:
			print("ES NULL")
		var boton_aux: BotonSelector = BotonSelector.boton_selector(Vector2(24,33),i, Vector2(-1,-18))
		boton_aux.pulsacion.connect(_pulsacion_ficha)
		globales.apropiar_hijo(ficha_aux,boton_aux)
		i+= 1
	
	if fichas_de_mas_aux > 0:
		$Panel/ContenedorFichas.position += Vector2(fichas_de_mas_aux*DISTANCIA_HORIZONTAL/2,7.5)
		$Panel.size.y -= 15

func _quitar_selector() -> void:
	if fichas_de_mas_aux > 0:
		$Panel/ContenedorFichas.position -= Vector2(fichas_de_mas_aux*DISTANCIA_HORIZONTAL/2,7.5)
		$Panel.size.y += 15
	
	$Panel.size.x -= aumento_aux
	$Panel.position.x += aumento_aux /2
	self.visible = false
	match(boton_pulsado):
		0:
			$GridContainer/FichaVision/Button0.button_pressed = false
		1:
			$GridContainer/FichaVision2/Button1.button_pressed = false
		2:
			$GridContainer/FichaVision3/Button2.button_pressed = false
	boton_pulsado = -1
	ficha_pulsada = -1
	cerrando = false
	manager_juego.hacer_mano_visible()
