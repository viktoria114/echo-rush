extends Node

signal oleada_iniciada(numero: int)
signal oleada_completada(numero: int)

var oleada_actual: int = 0
var enemigos_vivos: int = 0

@export var escena_enemigo: PackedScene
var puntos_spawn: Array = []
var contenedor_enemigos: Node2D

func iniciar_siguiente_oleada() -> void:
	oleada_actual += 1
	var cantidad := int(Config.ENEMIES_PER_WAVE_BASE * pow(Config.WAVE_SCALING, oleada_actual - 1))
	enemigos_vivos = cantidad
	emit_signal("oleada_iniciada", oleada_actual)
	_spawnear_enemigos(cantidad)

func _spawnear_enemigos(cantidad: int) -> void:
	for i in range(cantidad):
		var punto: Node2D = puntos_spawn[i % puntos_spawn.size()]
		var enemigo := escena_enemigo.instantiate() as CharacterBody2D
		contenedor_enemigos.add_child(enemigo)
		enemigo.global_position = punto.global_position + Vector2(randf_range(-40, 40), randf_range(-40, 40))
		enemigo.connect("enemigo_muerto", _en_enemigo_muerto)

func _en_enemigo_muerto() -> void:
	enemigos_vivos -= 1
	if enemigos_vivos <= 0:
		emit_signal("oleada_completada", oleada_actual)
