extends Node2D

@export var manager_fichas: Node2D
@export var colision_mano: CollisionShape2D
@export var manager_juego: ManagerJuego
#Responsabilidad: Guardar estado (grupos de fichas puestos en mesa) al principio de turno
#					Durante el turno, lleva cuenta de qué fichas nuevas se colocan (para permitir al
#					manager devolverlas a la mano y de los grupos de fichas actualizados.
#					Puede comprobar si los grupos de fichas actualizados están en posiciones permitidas

var grupoFichas = preload("res://proyecto_rummikub/ficha/grupo_fichas.tscn")

var grupos: Array[Grupo_fichas] = []

func tablero_valido(abierto: bool) -> bool:
	var suma: int = 0
	for grupo in grupos:
		if not grupo.fijado():
			suma += grupo.suma_grupo()
			if !grupo.grupo_correcto(true): 
				print("AAAAAAA")
				return false
	if (not abierto) and ((suma < 30) or combinando_fijadas_y_no_fijadas()):
		print("suma: " + str(suma))
		return false
	return true

func anadir_grupo_fichas(grupo: Grupo_fichas) -> void:
	grupos.append(grupo)
	globales.apropiar_hijo(self, grupo)

func quitar_grupo_fichas(grupo: Grupo_fichas) -> void:
	grupos.erase(grupo)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#insertar_grupo(Grupo_fichas.Grupo_fichas([Ficha.ficha(Ficha.COLOR.ROJO,5),Ficha.ficha(Ficha.COLOR.ROJO,6),Ficha.ficha(Ficha.COLOR.ROJO,7)]),screen_top_left)
	#$AreaTablero.mouse_entered.connect(actualizar_estado_cursor_tablero)
	#$AreaTablero.mouse_exited.connect(actualizar_estado_cursor_limbo)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_guarda_pressed() -> void:
	pass
	#for ficha in fichas:
		#fichas_viejas[ficha] = ficha.position
		#print(fichas_viejas[ficha])


func _on_vuelve_pressed() -> void:
	pass	#for ficha in fichas_viejas.keys():
		#ficha.position = fichas_viejas[ficha]


func _on_robar_carta_pressed() -> void:
	pass # Replace with function body.


func actualizar_estado_cursor_limbo() -> void:
	print("sale de tablero")
	globales.estado_cursor = globales.ESTADO_CURSOR.LIMBO

func actualizar_estado_cursor_tablero() -> void:
	print("entra en tablero")
	globales.estado_cursor = globales.ESTADO_CURSOR.TABLERO

func alguna_recien_puesta() -> bool:
	for grupo in grupos:
		for ficha in grupo.fichas:
			if(ficha.estado == globales.ESTADO_FICHA.TABLERO_NO_FIJADA):
				return true
	return false

func fijar_tablero() -> void:
	for grupo in grupos:
		for ficha in grupo.fichas:
			if ficha.estado == globales.ESTADO_FICHA.TABLERO_NO_FIJADA:
				ficha.estado = globales.ESTADO_FICHA.TABLERO_FIJADA
				ficha.desresaltar_aura()
				manager_juego.puntuar_ficha(ficha.especial)

func insertar_tablero(misGrupos: Array[Grupo_fichas]):
	for grupo in grupos:
		grupo.free()
	grupos = []
	for grupo in misGrupos:
		anadir_grupo_fichas(grupo)

func insertar_grupos_fichas(grupos_insertar: Array[Grupo_fichas]) -> void:
	var canvas_transform = get_viewport().get_canvas_transform()
	var esquina_superior_izquierda: Vector2 = -canvas_transform.origin 
	var esquina_superior_derecha:   Vector2 = Vector2(-esquina_superior_izquierda.x, esquina_superior_izquierda.y)
	
	var iterador_posicion: Vector2 = esquina_superior_izquierda + Ficha.tamano_ficha_static() 
	var separacion_entre_filas: float = Ficha.tamano_ficha_static().y * 1.1
	for grupo: Grupo_fichas in grupos_insertar:
		var tamano_grupo: Vector2 = _tamano_grupo(grupo)
		iterador_posicion.x += tamano_grupo.x/2
		print("tamano grupo="+str(tamano_grupo))
		if((iterador_posicion.x + (tamano_grupo.x/2) + Ficha.tamano_ficha_static().x) > esquina_superior_derecha.x): # se sale de la pantalla por la derecha
			iterador_posicion.x = esquina_superior_izquierda.x
			iterador_posicion.y += separacion_entre_filas
			iterador_posicion.x += (tamano_grupo.x/2) + Ficha.tamano_ficha_static().x
		iterador_posicion.x += 1 # para que no choque uno con el de al lado
		_insertar_grupo(grupo, iterador_posicion)
		iterador_posicion.x += tamano_grupo.x /2
		if is_inside_tree():
			await get_tree().physics_frame
		if is_inside_tree():
			await get_tree().physics_frame
		while(grupo.chocando_con_grupo()):
			grupo.position.x += Ficha.tamano_ficha_static().x / 2
			if((grupo.position.x + (tamano_grupo.x/2) + Ficha.tamano_ficha_static().x) > esquina_superior_derecha.x): # se sale de la pantalla por la derecha
				grupo.position.x = esquina_superior_izquierda.x
				grupo.position.y += separacion_entre_filas
				grupo.position.x += (tamano_grupo.x/2) + Ficha.tamano_ficha_static().x
			if is_inside_tree():
				await get_tree().physics_frame

func _adaptar_posicion_a_grupo(grupo_adaptar: Grupo_fichas, posicion_inicial: Vector2) -> Vector2:
	
	var posicion_devolver: Vector2 = Ficha.tamano_ficha_static() + posicion_inicial # para que el grupo entre con un margen de una ficha
	var tamano_grupo: Vector2 = _tamano_grupo(grupo_adaptar)
	posicion_devolver += tamano_grupo / 2
	
	return posicion_devolver

func _tamano_grupo(grupo: Grupo_fichas) -> Vector2:
	var tamano_grupo: Vector2 = Vector2(Ficha.tamano_ficha_static().x * grupo.fichas.size(), Ficha.tamano_ficha_static().y) # se suma el tamano de las fichas
	tamano_grupo.x += Grupo_fichas.tamano_extra   # se suma el tamano de las hitboxes 
	print("Tamano: " + str(grupo.fichas.size()))
	return tamano_grupo

func _insertar_grupo(grupo_insertar: Grupo_fichas, posicion: Vector2) -> void:
	var posicion_nueva = Vector2(posicion)
	anadir_grupo_fichas(grupo_insertar)
	grupo_insertar.position = posicion_nueva
	manager_fichas.conectar_grupo(grupo_insertar)
	for ficha: Ficha in grupo_insertar.fichas: 
		manager_fichas.conectar_ficha(ficha)
		ficha.estado = globales.ESTADO_FICHA.TABLERO_FIJADA

func ocultar_numeros() -> void:
	for grupo: Grupo_fichas in grupos:
		for ficha:Ficha in grupo.fichas:
			ficha.ocultar_ficha()

func revelar_numeros() -> void:
	for grupo: Grupo_fichas in grupos:
		for ficha:Ficha in grupo.fichas:
			ficha.revelar_ficha()

func detectar_color_sin_fijar(color: Ficha.COLOR) -> bool:
	for grupo: Grupo_fichas in grupos:
		for ficha: Ficha in grupo.fichas:
			if (ficha.color == color) and (ficha.estado == globales.ESTADO_FICHA.TABLERO_NO_FIJADA):
				return true
	return false

func combinando_fijadas_y_no_fijadas() -> bool:
	for grupo: Grupo_fichas in grupos:
		var ficha_fijada_encontrada: bool = false
		var ficha_no_fijada_encontrada: bool = false
		for ficha: Ficha in grupo.fichas:
			if ficha.estado == globales.ESTADO_FICHA.TABLERO_FIJADA:
				ficha_fijada_encontrada = true
			else:
				ficha_no_fijada_encontrada = true
		if ficha_fijada_encontrada and ficha_no_fijada_encontrada:
			return true
	return false
