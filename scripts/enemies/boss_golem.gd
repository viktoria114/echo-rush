extends "res://scripts/enemies/boss.gd"

func _ready() -> void:
	super._ready()
	vida = 600
	vida_max_boss = 600
	velocidad = 55.0
	dano = 25
	rango_ataque = 95.0

# Estrella de 5 puntas gris acero — Guardián Gólem
func _generar_visual() -> void:
	var polygon := $Poligono as Polygon2D
	if not polygon:
		return
	var puntos := PackedVector2Array()
	var radio_ext := 46.0
	var radio_int := 20.0
	var puntas := 5
	for i in range(puntas * 2):
		var angulo := (PI * i) / float(puntas) - PI / 2.0
		var radio := radio_ext if i % 2 == 0 else radio_int
		puntos.append(Vector2(cos(angulo), sin(angulo)) * radio)
	polygon.polygon = puntos
	polygon.color = Color(0.55, 0.62, 0.72)
