class_name Niebla extends ColorRect

var hay_bomba_de_humo: bool = false
var poniendo_niebla: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

func empezar_niebla() -> void:
	visible = true
	poniendo_niebla = true
	modulate = Color(1,1,1,0)
	while !hay_bomba_de_humo :
		await get_tree().physics_frame
		modulate += Color(0.0, 0.0, 0.0, 0.001)
		print(modulate)
		if modulate.a >= 0.412:
			hay_bomba_de_humo = true
			poniendo_niebla = false

func terminar_niebla() -> void:
	if !hay_bomba_de_humo:
		hay_bomba_de_humo = true
		await get_tree().physics_frame
	while hay_bomba_de_humo:
		await get_tree().physics_frame
		modulate -= Color(0,0,0,0.001)
		if modulate.a <= 0:
			visible = false
			hay_bomba_de_humo = false

func hay_humo() -> bool:
	return hay_bomba_de_humo or poniendo_niebla
