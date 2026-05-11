class_name BolaDeCristal extends Panel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

var shader_para_bola: Material = preload("res://shaders/shader_para_bola.tres")

func mostrar_bola(fichas: Array[Ficha], poderes: Array[Poder.PODER]) -> void:
	$AreaBolaDeCristal.visible = false
	for ficha: FichaVision in $AreaBolaDeCristal/ContenedorFichas.get_children():
		ficha.queue_free()
		
	visible = true
	modulate = Color(1,1,1,0)
	
	while modulate.a < 0.8:
		await get_tree().physics_frame
		modulate += Color(0.0, 0.0, 0.0, 0.01)
	for ficha: Ficha in fichas:
		var ficha_vision: FichaVision = FichaVision.fichaVision(ficha.color, ficha.numero, ficha.especial)
		globales.apropiar_hijo($AreaBolaDeCristal/ContenedorFichas, ficha_vision)
	$AreaBolaDeCristal/Poder.cambiar_poder(poderes[0])
	$AreaBolaDeCristal/Poder2.cambiar_poder(poderes[1])
	$AreaBolaDeCristal/Poder3.cambiar_poder(poderes[2])
	material = shader_para_bola
	position = Vector2(-437, -300)
	$AreaBolaDeCristal.visible = true

func esconder_bola() -> void:
	$AreaBolaDeCristal.visible = false
	material = null
	position = Vector2(-342, -224)
	visible = false
