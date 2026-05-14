extends Button




func _on_pressed() -> void:
	self.visible = false
	ConectorRed.parar_partida()
	get_tree().change_scene_to_file("res://proyecto_rummikub/menuInicio/menuInicio.tscn")
