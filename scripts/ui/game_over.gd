extends Node2D

const SFX_GAME_OVER = preload("res://assets/audio/sfx/GameOver.ogg")

@onready var btn_reintentar: Button = $UI/Centro/VBox/BtnReintentar
@onready var btn_menu: Button = $UI/Centro/VBox/BtnMenu

func _ready() -> void:
	btn_reintentar.pressed.connect(_reintentar)
	btn_menu.pressed.connect(_ir_menu)
	var sfx := AudioStreamPlayer.new()
	sfx.stream = SFX_GAME_OVER
	sfx.volume_db = Config.SFX_VOL_GAME_OVER
	add_child(sfx)
	sfx.play()

func _reintentar() -> void:
	Economy.reiniciar()
	UpgradeSystem.reiniciar()
	get_tree().change_scene_to_file("res://scenes/levels/Level1.tscn")

func _ir_menu() -> void:
	Economy.reiniciar()
	UpgradeSystem.reiniciar()
	SceneLoader.load_scene("res://scenes/menus/main_menu/main_menu_with_animations.tscn")
