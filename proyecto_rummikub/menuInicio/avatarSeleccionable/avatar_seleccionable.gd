extends Control
class_name AvatarSeleccionable

@export var marco: Button
@export var avatar: Panel

signal custom_toggled

static var escena_avatar_seleccionable: PackedScene = preload("res://proyecto_rummikub/menuInicio/avatarSeleccionable/avatarSeleccionable.tscn")
var mi_icono: Texture2D 
var nom_icono: String

const ANCHURA: float = 130.0
static func AvatarSeleccionable (icono: String) -> AvatarSeleccionable:
	var nuevo_avatar_seleccionable: AvatarSeleccionable = escena_avatar_seleccionable.instantiate()
	nuevo_avatar_seleccionable.nom_icono = icono
	nuevo_avatar_seleccionable.mi_icono = globales.LISTA_AVATARES[icono]
	
	var nuevo_icono: StyleBoxTexture = nuevo_avatar_seleccionable.avatar.get_theme_stylebox("panel").duplicate()
	var ratio: float = nuevo_avatar_seleccionable.mi_icono.get_size().y /  nuevo_avatar_seleccionable.mi_icono.get_size().x 
	nuevo_icono.texture = nuevo_avatar_seleccionable.mi_icono
	nuevo_avatar_seleccionable.avatar.add_theme_stylebox_override("panel",nuevo_icono)
	nuevo_avatar_seleccionable.avatar.size.y = ratio * ANCHURA

	return nuevo_avatar_seleccionable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _on_marco_toggled(toggled_on: bool) -> void:
	custom_toggled.emit(toggled_on, self)
