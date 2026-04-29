extends Panel

@export var menuInicio: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	$MarcoEditarPerfil/MenuSeleccionAvatar.visible = false

func _on_boton_cerrar_pressed() -> void:
	#for avatar: AvatarSeleccionable in $MarcoEditarPerfil/MenuSeleccionAvatar/ContenedorAvataresSeleccionables.get_children():
	#	avatar.queue_free()
	self.visible = false

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
