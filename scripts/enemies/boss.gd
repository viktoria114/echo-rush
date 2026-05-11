extends "res://scripts/enemies/enemy_base.gd"

signal boss_vida_cambiada(vida_actual: int, vida_max: int)

const BOSS_HP       := 400
const BOSS_VELOCIDAD := 65.0
const BOSS_DANO     := 20

var vida_max_boss: int = BOSS_HP

func _ready() -> void:
	super._ready()
	vida          = BOSS_HP
	vida_max_boss = BOSS_HP
	velocidad     = BOSS_VELOCIDAD
	dano          = BOSS_DANO
	rango_ataque  = 110.0
	_generar_visual()

# Estrella de 6 puntas para diferenciarlo claramente de los enemigos normales
func _generar_visual() -> void:
	var polygon := $Poligono as Polygon2D
	if not polygon:
		return
	var puntos := PackedVector2Array()
	var radio_ext := 40.0
	var radio_int := 18.0
	var puntas := 6
	for i in range(puntas * 2):
		var angulo := (PI * i) / float(puntas) - PI / 2.0
		var radio := radio_ext if i % 2 == 0 else radio_int
		puntos.append(Vector2(cos(angulo), sin(angulo)) * radio)
	polygon.polygon = puntos
	polygon.color = Color(0.85, 0.08, 0.08)

# Sobrescribir recibir_dano para emitir señal de HUD antes de morir
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
