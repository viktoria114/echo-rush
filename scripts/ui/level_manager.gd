extends Node2D

@onready var wave_manager: Node = $WaveManager
@onready var hud: CanvasLayer = $HUD
@onready var jugador: CharacterBody2D = $Jugador
@onready var enemigos: Node2D = $Enemigos
@onready var puntos_spawn: Node2D = $PuntosSpawn

func _ready() -> void:
	# Configurar WaveManager con referencias de la escena
	wave_manager.contenedor_enemigos = enemigos
	wave_manager.puntos_spawn = puntos_spawn.get_children()

	wave_manager.connect("oleada_iniciada", hud.actualizar_oleada)
	wave_manager.connect("oleada_completada", _en_oleada_completada)
	jugador.connect("vida_cambiada", hud.actualizar_vida)
	jugador.connect("jugador_muerto", _game_over)

	await get_tree().process_frame
	wave_manager.iniciar_siguiente_oleada()

func _en_oleada_completada(numero: int) -> void:
	if numero % Config.ECHO_WAVE_INTERVAL == 0:
		# TODO: abrir EchoShop
		await get_tree().create_timer(1.5).timeout
	else:
		await get_tree().create_timer(2.0).timeout
	wave_manager.iniciar_siguiente_oleada()

func _game_over() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")
