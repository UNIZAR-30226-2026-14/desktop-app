extends Control
@export var circulo_progreso: RadialProgress
@export var texto_esperando_Oponente: Label

var tiempo_carga:float = 2.0
# Called when the node enters the scene tree for the first time.
var terminar:bool = false

func _ready() -> void:
	#actualizar_puntos_suspensivos()
	actualizar_circulo_carga()
	await get_tree().create_timer(5.0).timeout
	terminar = true
	get_tree().change_scene_to_file("res://proyecto_rummikub/escenaPrincipal/escenaprincipal.tscn")


func actualizar_puntos_suspensivos() -> void:
	while(!terminar):
		await get_tree().create_timer(1.0).timeout
		texto_esperando_Oponente.text = "Buscando oponentes.."
		
		await get_tree().create_timer(1.0).timeout
		texto_esperando_Oponente.text = "Buscando oponentes."
		
		await get_tree().create_timer(1.0).timeout
		texto_esperando_Oponente.text = "Buscando oponentes"
		
		await get_tree().create_timer(1.0).timeout
		texto_esperando_Oponente.text = "Buscando oponentes..."

func actualizar_circulo_carga() -> void:
		while(!terminar):
			circulo_progreso.animate(tiempo_carga,true,0)
			await get_tree().create_timer(tiempo_carga+0.2).timeout
			#circulo_progreso.animate(tiempo_carga,false,0)
			#await get_tree().create_timer(tiempo_carga+0.2).timeout



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
