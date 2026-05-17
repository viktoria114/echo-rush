extends CanvasLayer

@onready var pause_menu = %PauseMenu

func _ready() -> void:
	pass

func _on_pause_menu_hidden() -> void:
	pass

# Solo abre el menú si no está visible — cuando está abierto,
# el propio PauseMenu maneja Escape para cerrarse.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not pause_menu.visible:
		pause_menu.show()
		get_viewport().set_input_as_handled()
