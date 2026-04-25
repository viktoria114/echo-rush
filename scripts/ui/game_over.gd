extends Node2D

@onready var btn_reintentar: Button = $UI/Centro/VBox/BtnReintentar
@onready var btn_menu: Button = $UI/Centro/VBox/BtnMenu

func _ready() -> void:
	btn_reintentar.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/levels/Level1.tscn"))
	btn_menu.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn"))
