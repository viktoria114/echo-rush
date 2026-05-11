extends Node

signal monedas_cambiadas(total: int)

var monedas: int = 0

func ganar(cantidad: int) -> void:
	monedas += cantidad
	emit_signal("monedas_cambiadas", monedas)

func gastar(cantidad: int) -> bool:
	if monedas < cantidad:
		return false
	monedas -= cantidad
	emit_signal("monedas_cambiadas", monedas)
	return true

func tiene(cantidad: int) -> bool:
	return monedas >= cantidad

func reiniciar() -> void:
	monedas = 0
	emit_signal("monedas_cambiadas", monedas)
