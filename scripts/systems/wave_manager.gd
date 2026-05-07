extends Node

signal oleada_iniciada(numero: int)
signal oleada_completada(numero: int)
signal nivel_completado
signal boss_spawneado(boss)

@export var waves_per_level: int = 2
@export var escena_enemigo: PackedScene
@export var escena_boss: PackedScene

var oleada_actual: int = 0
var enemigos_vivos: int = 0
var puntos_spawn: Array = []
var contenedor_enemigos: Node2D

func iniciar_siguiente_oleada() -> void:
	oleada_actual += 1
	var es_ultima := oleada_actual >= waves_per_level
	emit_signal("oleada_iniciada", oleada_actual)

	if es_ultima and escena_boss:
		# Última oleada: boss + 3 esbirros
		enemigos_vivos = 4
		_spawnear_normales(3)
		_spawnear_boss()
	else:
		var cantidad := int(Config.ENEMIES_PER_WAVE_BASE * pow(Config.WAVE_SCALING, oleada_actual - 1))
		enemigos_vivos = cantidad
		_spawnear_normales(cantidad)

func _spawnear_normales(cantidad: int) -> void:
	# Mezclar spawn points para dispersión aleatoria
	var indices: Array = []
	for i in range(puntos_spawn.size()):
		indices.append(i)
	indices.shuffle()

	for i in range(cantidad):
		var punto: Node2D = puntos_spawn[indices[i % indices.size()]]
		var enemigo := escena_enemigo.instantiate() as CharacterBody2D
		contenedor_enemigos.add_child(enemigo)
		enemigo.global_position = punto.global_position + Vector2(randf_range(-80, 80), randf_range(-80, 80))
		enemigo.connect("enemigo_muerto", _en_enemigo_muerto)

func _spawnear_boss() -> void:
	var boss := escena_boss.instantiate()
	contenedor_enemigos.add_child(boss)
	# Boss aparece en el spawn point más lejano del centro
	var centro := Vector2(960, 540)
	var punto_boss: Vector2 = (puntos_spawn[0] as Node2D).global_position
	var max_dist := 0.0
	for p in puntos_spawn:
		var nodo := p as Node2D
		var d := centro.distance_to(nodo.global_position)
		if d > max_dist:
			max_dist = d
			punto_boss = nodo.global_position
	boss.global_position = punto_boss
	boss.connect("enemigo_muerto", _en_enemigo_muerto)
	emit_signal("boss_spawneado", boss)

func _en_enemigo_muerto() -> void:
	enemigos_vivos -= 1
	if enemigos_vivos <= 0:
		emit_signal("oleada_completada", oleada_actual)
		if oleada_actual >= waves_per_level:
			emit_signal("nivel_completado")
