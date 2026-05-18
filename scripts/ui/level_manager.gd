extends Node2D

@export var proxima_escena: String = ""

const SHOP_ESCENA := preload("res://scenes/ui/Shop.tscn")
const MUSICA_BOSS := preload("res://assets/audio/music/boss.ogg")
const MUSICA_NIVEL := preload("res://assets/audio/music/nivel.ogg")
const PAUSA_ESCENA := preload("res://scenes/windows/pause_menu_layer.tscn")

@onready var wave_manager: Node = $WaveManager
@onready var hud: CanvasLayer = $HUD
@onready var jugador: CharacterBody2D = $Jugador
@onready var puntos_spawn: Node2D = $PuntosSpawn

func _ready() -> void:
	# Música: arranca nivel.ogg si la escena no tiene BackgroundMusicPlayer propio
	if not get_node_or_null("BackgroundMusicPlayer"):
		ProjectMusicController.play_stream(MUSICA_NIVEL)

	# Pausa: añade la capa si la escena (p. ej. Level1) no la tiene
	if not get_node_or_null("PauseMenuLayer"):
		var capa := PAUSA_ESCENA.instantiate()
		capa.name = "PauseMenuLayer"
		add_child(capa)

	# Niveles con y_sort no tienen nodo Enemigos: los enemigos spawnan en la raíz
	# para participar en el ordenamiento por Y con edificios y personajes.
	var contenedor := get_node_or_null("Enemigos") as Node2D
	wave_manager.contenedor_enemigos = contenedor if contenedor != null else self
	wave_manager.puntos_spawn = puntos_spawn.get_children()

	hud.configurar_oleadas(wave_manager.waves_per_level)

	wave_manager.connect("oleada_iniciada",   hud.actualizar_oleada)
	wave_manager.connect("oleada_completada", _en_oleada_completada)
	wave_manager.connect("nivel_completado",  _en_nivel_completado)
	wave_manager.connect("boss_spawneado",    _en_boss_spawneado)
	jugador.connect("vida_cambiada",   hud.actualizar_vida)
	jugador.connect("jugador_muerto",  _game_over)
	Economy.connect("monedas_cambiadas",        hud.actualizar_monedas)
	KeywordSystem.connect("keywords_actualizadas", hud.actualizar_keywords)

	_crear_boton_debug()
	await get_tree().process_frame
	wave_manager.iniciar_siguiente_oleada()

func _crear_boton_debug() -> void:
	var btn := Button.new()
	btn.text = "Saltear nivel"
	btn.anchor_left   = 0.0
	btn.anchor_top    = 1.0
	btn.anchor_right  = 0.0
	btn.anchor_bottom = 1.0
	btn.offset_left   = 10.0
	btn.offset_right  = 160.0
	btn.offset_top    = -45.0
	btn.offset_bottom = -10.0
	hud.add_child(btn)
	btn.pressed.connect(_abrir_tienda)

func _en_oleada_completada(numero: int) -> void:
	if numero >= wave_manager.waves_per_level:
		return
	await get_tree().create_timer(2.0).timeout
	wave_manager.iniciar_siguiente_oleada()

func _en_nivel_completado() -> void:
	await get_tree().create_timer(1.5).timeout
	_abrir_tienda()

func _en_boss_spawneado(boss: Node) -> void:
	hud.mostrar_barra_boss(boss.get("vida_max_boss"))
	boss.connect("boss_vida_cambiada", hud.actualizar_barra_boss)
	boss.connect("enemigo_muerto", func() -> void:
		hud.ocultar_barra_boss()
		ProjectMusicController.play_stream(MUSICA_NIVEL)
	)
	ProjectMusicController.play_stream(MUSICA_BOSS)

func _abrir_tienda() -> void:
	var tienda := SHOP_ESCENA.instantiate()
	add_child(tienda)
	tienda.tienda_cerrada.connect(func() -> void:
		if proxima_escena.is_empty():
			get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
		else:
			get_tree().change_scene_to_file(proxima_escena)
	)

var _game_over_iniciado := false

func _game_over() -> void:
	if _game_over_iniciado:
		return
	_game_over_iniciado = true
	ProjectMusicController.stop()
	await get_tree().create_timer(1.0).timeout
	var canvas := CanvasLayer.new()
	canvas.layer = 100
	add_child(canvas)
	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	canvas.add_child(overlay)
	var tween := create_tween()
	tween.tween_property(overlay, "color:a", 1.0, 0.8)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")
