extends Node2D

@export var proxima_escena: String = ""

const SHOP_ESCENA := preload("res://scenes/ui/Shop.tscn")
const MUSICA_BOSS := preload("res://assets/audio/music/boss.ogg")
const MUSICA_NIVEL := preload("res://assets/audio/music/nivel.ogg")

@onready var wave_manager: Node = $WaveManager
@onready var hud: CanvasLayer = $HUD
@onready var jugador: CharacterBody2D = $Jugador
@onready var enemigos: Node2D = $Enemigos
@onready var puntos_spawn: Node2D = $PuntosSpawn

func _ready() -> void:
	wave_manager.contenedor_enemigos = enemigos
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

	await get_tree().process_frame
	wave_manager.iniciar_siguiente_oleada()

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

func _game_over() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")
