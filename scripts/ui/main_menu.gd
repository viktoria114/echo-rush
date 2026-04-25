extends Node

@onready var btn_jugar: Button = $UI/Centro/VBox/BtnJugar
@onready var btn_infinito: Button = $UI/Centro/VBox/BtnInfinito
@onready var btn_salir: Button = $UI/Centro/VBox/BtnSalir

func _ready() -> void:
	btn_jugar.pressed.connect(_jugar)
	btn_infinito.pressed.connect(_modo_infinito)
	btn_salir.pressed.connect(_salir)
	btn_infinito.disabled = true   # aún no implementado

func _jugar() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/PrologueScene.tscn")

func _modo_infinito() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/Level1.tscn")

func _salir() -> void:
	get_tree().quit()
