extends Panel

@export var menuInicio: Control

const ANCHURA_AVATAR: float = 133.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	$MarcoEditarPerfil/MenuSeleccionAvatar.visible = false

	var nuevoIcono: StyleBoxTexture = $MarcoEditarPerfil/PanelIconoBotonAmigos2/IconoJugador.get_theme_stylebox("panel").duplicate()
	var ratio: float = ConectorRed.avatar.get_size().y /  ConectorRed.avatar.get_size().x 
	nuevoIcono.texture = ConectorRed.avatar
	$MarcoEditarPerfil/PanelIconoBotonAmigos2/IconoJugador.add_theme_stylebox_override("panel",nuevoIcono)
	$MarcoEditarPerfil/PanelIconoBotonAmigos2/IconoJugador.size.y = ratio * ANCHURA_AVATAR


func _on_boton_cerrar_pressed() -> void:
	$MarcoEditarPerfil/MenuSeleccionAvatar.visible = false
	self.visible = false
	for avatar: AvatarSeleccionable in $MarcoEditarPerfil/MenuSeleccionAvatar/ContenedorAvataresSeleccionables.get_children():
		avatar.queue_free()

func _on_boton_editar_avatar_pressed() -> void:
	$MarcoEditarPerfil/MenuSeleccionAvatar.visible = true
	for avatar: Texture2D in globales.LISTA_AVATARES:
		var nuevo_avatar_seleccionable: AvatarSeleccionable = AvatarSeleccionable.AvatarSeleccionable(avatar)
		nuevo_avatar_seleccionable.custom_toggled.connect(_on_avatar_seleccionable_toggled)
		globales.apropiar_hijo($MarcoEditarPerfil/MenuSeleccionAvatar/ContenedorAvataresSeleccionables, nuevo_avatar_seleccionable)
		if avatar == ConectorRed.avatar:
			nuevo_avatar_seleccionable.marco.button_pressed = true

func _on_avatar_seleccionable_toggled(toggled_on: bool, avatar_seleccionado: AvatarSeleccionable)->void:
	if toggled_on:
		ConectorRed.avatar = avatar_seleccionado.mi_icono
		menuInicio.actualizar_avatar()

func _on_volver_pressed() -> void:
	$MarcoEditarPerfil/MenuSeleccionAvatar.visible = false
	for avatar: AvatarSeleccionable in $MarcoEditarPerfil/MenuSeleccionAvatar/ContenedorAvataresSeleccionables.get_children():
		avatar.queue_free()

	var nuevoIcono: StyleBoxTexture = $MarcoEditarPerfil/PanelIconoBotonAmigos2/IconoJugador.get_theme_stylebox("panel").duplicate()
	var ratio: float = ConectorRed.avatar.get_size().y /  ConectorRed.avatar.get_size().x 
	nuevoIcono.texture = ConectorRed.avatar
	$MarcoEditarPerfil/PanelIconoBotonAmigos2/IconoJugador.add_theme_stylebox_override("panel",nuevoIcono)
	$MarcoEditarPerfil/PanelIconoBotonAmigos2/IconoJugador.size.y = ratio * ANCHURA_AVATAR
