extends Area2D

const VALOR := 10
const RADIO := 8.0
const VIDA_UTIL := 8.0
const SONIDO_MONEDA := preload("res://assets/audio/sfx/recogerMoneda.ogg")

var _recogida := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(VIDA_UTIL).timeout.connect(_desvanecer)
	_generar_poligono()

# Dibuja un círculo dorado con Polygon2D (sin asset externo)
func _generar_poligono() -> void:
	var polygon := $Poligono as Polygon2D
	var puntos := PackedVector2Array()
	var lados := 14
	for i in range(lados):
		var angulo := (2.0 * PI * i) / float(lados)
		puntos.append(Vector2(cos(angulo), sin(angulo)) * RADIO)
	polygon.polygon = puntos

func _on_body_entered(cuerpo: Node2D) -> void:
	if _recogida:
		return
	if cuerpo.is_in_group("jugador"):
		_recogida = true
		Economy.ganar(VALOR)
		_reproducir_sonido()
		queue_free()

func _reproducir_sonido() -> void:
	var player := AudioStreamPlayer.new()
	player.stream = SONIDO_MONEDA
	player.bus = &"SFX"
	get_tree().root.add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func _desvanecer() -> void:
	if not _recogida:
		queue_free()
