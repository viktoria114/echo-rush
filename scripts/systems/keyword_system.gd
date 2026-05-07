extends Node

signal keywords_actualizadas(lista: Array)

var keywords_activas: Array[String] = []

func agregar_keyword(kw: String) -> bool:
	if kw in keywords_activas or keywords_activas.size() >= Config.MAX_KEYWORDS:
		return false
	keywords_activas.append(kw)
	# Aplicar al jugador si ya existe en la escena
	for jugador in get_tree().get_nodes_in_group("jugador"):
		if jugador.has_method("agregar_keyword"):
			jugador.agregar_keyword(kw)
	emit_signal("keywords_actualizadas", keywords_activas.duplicate())
	return true

func obtener_keywords() -> Array:
	return keywords_activas.duplicate()

func reiniciar() -> void:
	keywords_activas.clear()
	emit_signal("keywords_actualizadas", [])
