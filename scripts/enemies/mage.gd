extends "res://scripts/enemies/enemy_base.gd"

func _ready() -> void:
	super._ready()
	vida = 45
	velocidad = 80.0
	dano = 12
	_generar_visual()

# Hexágono violeta — placeholder de mago
func _generar_visual() -> void:
	var polygon := $Poligono as Polygon2D
	if not polygon:
		return
	var puntos := PackedVector2Array()
	var radio := 22.0
	for i in range(6):
		var angulo := (TAU * i) / 6.0
		puntos.append(Vector2(cos(angulo), sin(angulo)) * radio)
	polygon.polygon = puntos
	polygon.color = Color(0.55, 0.10, 0.75)
