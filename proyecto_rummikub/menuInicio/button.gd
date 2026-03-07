extends Button
@export var pestanaAmigos: ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pestanaAmigos.visible=false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_pressed() -> void:
	if(pestanaAmigos.visible):
		pestanaAmigos.visible=false
	else:
		pestanaAmigos.visible=true
