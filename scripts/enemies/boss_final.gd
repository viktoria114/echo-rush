extends "res://scripts/enemies/enemy_base.gd"

signal boss_vida_cambiada(vida_actual: int, vida_max: int)

var vida_max_boss: int = 1500

func _ready() -> void:
	super._ready()
	vida = 1500
	vida_max_boss = 1500
	velocidad = 70.0
	dano = 40
	rango_ataque = 120.0
	_generar_visual()

# Estrella de 12 puntas casi negra — Jefe Final
func _generar_visual() -> void:
	var polygon := $Poligono as Polygon2D
	if not polygon:
		return
	var puntos := PackedVector2Array()
	var radio_ext := 50.0
	var radio_int := 22.0
	var puntas := 12
	for i in range(puntas * 2):
		var angulo := (PI * i) / float(puntas) - PI / 2.0
		var radio := radio_ext if i % 2 == 0 else radio_int
		puntos.append(Vector2(cos(angulo), sin(angulo)) * radio)
	polygon.polygon = puntos
	polygon.color = Color(0.15, 0.03, 0.10)

func recibir_dano(cantidad: int) -> void:
	vida -= cantidad
	if vida <= 0 and not _muerto:
		_morir()
	elif not _muerto:
		emit_signal("boss_vida_cambiada", vida, vida_max_boss)

func _actualizar_efectos(delta: float) -> void:
	if veneno_timer > 0.0:
		veneno_timer -= delta
		vida -= int(veneno_dps * delta)
		if vida <= 0 and not _muerto:
			_morir()
		elif not _muerto:
			emit_signal("boss_vida_cambiada", vida, vida_max_boss)
