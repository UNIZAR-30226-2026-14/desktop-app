extends Control

@export var dinero: RichTextLabel
@export var botonAmigos: Button
@export var botonCerrarPestanaAmigos: Button

const ANCHURA_AVATAR_MOSTRAR: float = 85.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$BarraSuperior/NombreUsuario.text = ConectorRed.username
	
	var nuevoIcono: StyleBoxTexture = $BarraSuperior/BotonIconoAvatarUsuario/IconoAvatarUsuario.get_theme_stylebox("panel").duplicate()
	var ratio: float = globales.avatar.get_size().y /  globales.avatar.get_size().x 
	nuevoIcono.texture = globales.avatar
	$BarraSuperior/BotonIconoAvatarUsuario/IconoAvatarUsuario.add_theme_stylebox_override("panel",nuevoIcono)
	$BarraSuperior/BotonIconoAvatarUsuario/IconoAvatarUsuario.size.y = ratio * ANCHURA_AVATAR_MOSTRAR
<<<<<<< HEAD
=======
	set_dinero(10)
	print("DINERO: " + str(get_dinero()))
>>>>>>> origin/offline

const ANCHURA_AVATAR_EDITAR: float = 133.5

func _on_icono_avatar_usuario_pressed() -> void:
	$FondoEditarPerfil.visible = true
	var nuevoIcono: StyleBoxTexture = $FondoEditarPerfil/MarcoEditarPerfil/PanelIconoBotonAmigos2/IconoJugador.get_theme_stylebox("panel").duplicate()
	var ratio: float = globales.avatar.get_size().y /  globales.avatar.get_size().x 
	nuevoIcono.texture = globales.avatar
	$FondoEditarPerfil/MarcoEditarPerfil/PanelIconoBotonAmigos2/IconoJugador.add_theme_stylebox_override("panel",nuevoIcono)
	$FondoEditarPerfil/MarcoEditarPerfil/PanelIconoBotonAmigos2/IconoJugador.size.y = ratio * ANCHURA_AVATAR_EDITAR

func actualizar_avatar()->void:
	var nuevoIcono: StyleBoxTexture = $BarraSuperior/BotonIconoAvatarUsuario/IconoAvatarUsuario.get_theme_stylebox("panel").duplicate()
	var ratio: float = globales.avatar.get_size().y /  globales.avatar.get_size().x 
	nuevoIcono.texture = globales.avatar
	$BarraSuperior/BotonIconoAvatarUsuario/IconoAvatarUsuario.add_theme_stylebox_override("panel",nuevoIcono)
	$BarraSuperior/BotonIconoAvatarUsuario/IconoAvatarUsuario.size.y = ratio * ANCHURA_AVATAR_MOSTRAR

func set_dinero(nueva_cantidad: int)-> void:
	dinero.text = str(nueva_cantidad) + "      "

func get_dinero() -> int:
	return int(dinero.text)
