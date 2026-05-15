extends Control
@export var manager_juego: ManagerJuego

signal s_adversario_elegido

var adversario_elegido: String

var lista_adversarios: Array[BotonAdversario] = []

func _ready() -> void:
	self.visible = false
	manager_juego.termina_turno.connect(_cerrar_eleccion)
	$iconoCerrar.pressed.connect(_cerrar_eleccion)

func sacar_selector_adversarios(poder: Poder.PODER) -> String:
	var nuevo_style_box: StyleBoxTexture = load("res://proyecto_rummikub/poder/selectorAdversario/icono_poder_selector_adversario.tres")
	nuevo_style_box.texture = Poder.LISTA_TEXTURAS_PODERES[poder]
	$iconoPoder.add_theme_stylebox_override("panel",nuevo_style_box)
	self.visible = true
	for adversario: BotonAdversario in lista_adversarios:
		adversario.queue_free()
	lista_adversarios = []

	for tupla: Dictionary in manager_juego.get_adversarios():
		var nuevo_boton: BotonAdversario = BotonAdversario.new(tupla["nombre"], tupla["icono"])
		lista_adversarios.append(nuevo_boton)
		globales.apropiar_hijo($VBoxContainer,nuevo_boton)
		nuevo_boton.adversario_pulsado.connect(_adversario_elegido)
	
	await s_adversario_elegido
	
	self.visible = false
	return adversario_elegido

func _adversario_elegido(adversario:String) -> void:
	adversario_elegido = adversario
	s_adversario_elegido.emit(adversario)

func _cerrar_eleccion() -> void:
	adversario_elegido = ""
	s_adversario_elegido.emit("")
