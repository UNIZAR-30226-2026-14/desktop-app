extends Panel

@export var menuInicio: Control

const ANCHURA_AVATAR: float = 133.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	$MarcoEditarPerfil/MenuSeleccionAvatar.visible = false

	var nuevoIcono: StyleBoxTexture = $MarcoEditarPerfil/PanelIconoBotonAmigos2/IconoJugador.get_theme_stylebox("panel").duplicate()
	var ratio: float = globales.avatar.get_size().y /  globales.avatar.get_size().x 
	nuevoIcono.texture = globales.avatar
	$MarcoEditarPerfil/PanelIconoBotonAmigos2/IconoJugador.add_theme_stylebox_override("panel",nuevoIcono)
	$MarcoEditarPerfil/PanelIconoBotonAmigos2/IconoJugador.size.y = ratio * ANCHURA_AVATAR
	$MarcoEditarPerfil/GridContainer2/id/RichTextLabel2.text = str(ConectorRed.get_id())
	$MarcoEditarPerfil/GridContainer2/NombreDeUsuario/EditarNombreUsuario.text = globales.nombre_usuario

func _on_boton_cerrar_pressed() -> void:
	$MarcoEditarPerfil/MenuSeleccionAvatar.visible = false
	self.visible = false
	for avatar: AvatarSeleccionable in $MarcoEditarPerfil/MenuSeleccionAvatar/ContenedorAvataresSeleccionables.get_children():
		avatar.queue_free()

	globales.nombre_usuario = $MarcoEditarPerfil/GridContainer2/NombreDeUsuario/EditarNombreUsuario.text
	menuInicio.actualizar_nombre_usuario()

func _on_boton_editar_avatar_pressed() -> void:
	$MarcoEditarPerfil/MenuSeleccionAvatar.visible = true
	for avatar: String in globales.LISTA_AVATARES:
		var nuevo_avatar_seleccionable: AvatarSeleccionable = AvatarSeleccionable.AvatarSeleccionable(avatar)
		nuevo_avatar_seleccionable.custom_toggled.connect(_on_avatar_seleccionable_toggled)
		globales.apropiar_hijo($MarcoEditarPerfil/MenuSeleccionAvatar/ContenedorAvataresSeleccionables, nuevo_avatar_seleccionable)
		if globales.LISTA_AVATARES[avatar] == globales.avatar:
			nuevo_avatar_seleccionable.marco.button_pressed = true

func _on_avatar_seleccionable_toggled(toggled_on: bool, avatar_seleccionado: AvatarSeleccionable)->void:
	if toggled_on:
		ConectorRed.cambia_perfil(avatar_seleccionado.nom_icono)
		menuInicio.actualizar_avatar()

func _on_volver_pressed() -> void:
	$MarcoEditarPerfil/MenuSeleccionAvatar.visible = false
	for avatar: AvatarSeleccionable in $MarcoEditarPerfil/MenuSeleccionAvatar/ContenedorAvataresSeleccionables.get_children():
		avatar.queue_free()

	var nuevoIcono: StyleBoxTexture = $MarcoEditarPerfil/PanelIconoBotonAmigos2/IconoJugador.get_theme_stylebox("panel").duplicate()
	var ratio: float = globales.avatar.get_size().y /  globales.avatar.get_size().x 
	nuevoIcono.texture = globales.avatar
	$MarcoEditarPerfil/PanelIconoBotonAmigos2/IconoJugador.add_theme_stylebox_override("panel",nuevoIcono)
	$MarcoEditarPerfil/PanelIconoBotonAmigos2/IconoJugador.size.y = ratio * ANCHURA_AVATAR
	
