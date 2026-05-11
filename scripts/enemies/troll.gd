extends "res://scripts/enemies/enemy_base.gd"

func _ready() -> void:
	super._ready()
	vida = 120
	velocidad = 55.0
	dano = 18
	rango_ataque = 65.0
	_generar_visual()

# Pentágono verde oscuro grande — placeholder de troll
func _generar_visual() -> void:
	var polygon := $Poligono as Polygon2D
	if not polygon:
		return
	var puntos := PackedVector2Array()
	var radio := 36.0
	for i in range(5):
		var angulo := (TAU * i) / 5.0 - PI / 2.0
		puntos.append(Vector2(cos(angulo), sin(angulo)) * radio)
	polygon.polygon = puntos
	polygon.color = Color(0.18, 0.42, 0.18)
