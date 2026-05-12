extends Button


func _on_boton_entrar_partida_con_codigo_pressed() -> void:
	if $InsertadorCodigo.text.length() >= 5:
		var codigo: String = $InsertadorCodigo.text.substr(4)
		var res = await ConectorRed.unirse_a_partida_con_lobby(int(codigo))
		if res is Error:
			if res == Error.ERR_DOES_NOT_EXIST: PopUp.popUp("La partida no existe",Vector2(550,16),$"../../..")
			elif res: PopUp.popUp("Ha habido un error \nal unirse a la partida",Vector2(550,16),$"../../..")
		else:
			$"../../PanelCreacionPartidaPrivada".mostrar(false,res,int(codigo))
	else:
		PopUp.popUp("Codigo no valido",Vector2(123,16),$"..")
