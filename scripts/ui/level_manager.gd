extends Node2D

@onready var wave_manager: Node = $WaveManager
@onready var hud: CanvasLayer = $HUD
@onready var jugador: CharacterBody2D = $Jugador
@onready var enemigos: Node2D = $Enemigos
@onready var puntos_spawn: Node2D = $PuntosSpawn

const NIVEL_ANCHO := 3072
const NIVEL_ALTO := 3072

func _ready() -> void:
	_crear_paredes()
	_configurar_camara()

	wave_manager.contenedor_enemigos = enemigos
	wave_manager.puntos_spawn = puntos_spawn.get_children()

	wave_manager.connect("oleada_iniciada", hud.actualizar_oleada)
	wave_manager.connect("oleada_completada", _en_oleada_completada)
	jugador.connect("vida_cambiada", hud.actualizar_vida)
	jugador.connect("jugador_muerto", _game_over)

	await get_tree().process_frame
	wave_manager.iniciar_siguiente_oleada()

func _configurar_camara() -> void:
	var camara: Camera2D = jugador.get_node("Camara")
	camara.limit_left = 0
	camara.limit_top = 0
	camara.limit_right = NIVEL_ANCHO
	camara.limit_bottom = NIVEL_ALTO

func _crear_paredes() -> void:
	# Cuatro paredes invisibles en los bordes del nivel
	var bordes := [
		[Vector2(NIVEL_ANCHO / 2.0, -5), Vector2(NIVEL_ANCHO, 10)],
		[Vector2(NIVEL_ANCHO / 2.0, NIVEL_ALTO + 5), Vector2(NIVEL_ANCHO, 10)],
		[Vector2(-5, NIVEL_ALTO / 2.0), Vector2(10, NIVEL_ALTO)],
		[Vector2(NIVEL_ANCHO + 5, NIVEL_ALTO / 2.0), Vector2(10, NIVEL_ALTO)],
	]
	for b in bordes:
		var pared := StaticBody2D.new()
		pared.position = b[0]
		pared.collision_layer = 1
		pared.collision_mask = 0
		var cs := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = b[1]
		cs.shape = shape
		pared.add_child(cs)
		add_child(pared)

func _en_oleada_completada(numero: int) -> void:
	if numero % Config.ECHO_WAVE_INTERVAL == 0:
		# TODO: abrir EchoShop
		await get_tree().create_timer(1.5).timeout
	else:
		await get_tree().create_timer(2.0).timeout
	wave_manager.iniciar_siguiente_oleada()

func _game_over() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")
