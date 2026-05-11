extends "res://scripts/enemies/boss.gd"

func _ready() -> void:
	super._ready()
	vida = 900
	vida_max_boss = 900
	velocidad = 60.0
	dano = 30
	rango_ataque = 110.0

# Estrella de 8 puntas violeta — Guardián del Portal
func _generar_visual() -> void:
	var polygon := $Poligono as Polygon2D
	if not polygon:
		return
	var puntos := PackedVector2Array()
	var radio_ext := 44.0
	var radio_int := 18.0
	var puntas := 8
	for i in range(puntas * 2):
		var angulo := (PI * i) / float(puntas) - PI / 2.0
		var radio := radio_ext if i % 2 == 0 else radio_int
		puntos.append(Vector2(cos(angulo), sin(angulo)) * radio)
	polygon.polygon = puntos
	polygon.color = Color(0.45, 0.10, 0.80)
