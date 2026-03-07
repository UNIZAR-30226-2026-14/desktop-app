extends Node2D

var ficha = preload("res://proyecto_rummikub/ficha/Ficha.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_agnade_carta_pressed() -> void:
	var fich = Ficha.ficha("diamantes")
	$grupo.anadir_ficha(fich)
