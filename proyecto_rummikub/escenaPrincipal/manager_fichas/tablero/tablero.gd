extends Node2D

#Responsabilidad: Guardar estado (grupos de fichas puestos en mesa) al principio de turno
#					Durante el turno, lleva cuenta de qué fichas nuevas se colocan (para permitir al
#					manager devolverlas a la mano y de los grupos de fichas actualizados.
#					Puede comprobar si los grupos de fichas actualizados están en posiciones permitidas

var grupoFichas = preload("res://proyecto_rummikub/ficha/grupo_fichas.tscn")

var grupos: Array[Grupo_fichas] = []
var gruposViejos = {}

func anadir_grupo_fichas(grupo: Grupo_fichas) -> void:
	grupos.append(grupo)
	globales.apropiar_hijo(self, grupo)

func quitar_grupo_fichas(grupo: Grupo_fichas) -> void:
	grupos.erase(grupo)
	#self.remove_child(grupo)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AreaTablero.mouse_entered.connect(actualizar_estado_cursor_tablero)
	$AreaTablero.mouse_exited.connect(actualizar_estado_cursor_limbo)

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
	globales.estado_cursor = globales.ESTADO_CURSOR.LIMBO

func actualizar_estado_cursor_tablero() -> void:
	globales.estado_cursor = globales.ESTADO_CURSOR.TABLERO
