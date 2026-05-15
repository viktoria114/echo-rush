extends "res://scripts/enemies/enemy_base.gd"

const SFX_MUERTE = preload("res://assets/audio/sfx/magoMuerte.ogg")
const FIREBALL = preload("res://scenes/projectiles/FireballEnemy.tscn")

const MIN_DIST := 160.0
const MAX_DIST := 300.0

var disparo_cooldown: float = 1.0
var disparando: bool = false

func _ready() -> void:
	super._ready()
	vida = 45
	velocidad = 80.0
	dano = Config.MAGE_FIREBALL_DAMAGE
	_generar_visual()

func _physics_process(delta: float) -> void:
	if _muerto:
		return
	_actualizar_efectos(delta)
	if _muerto:
		return

	if disparo_cooldown > 0.0:
		disparo_cooldown -= delta

	if jugador == null or not is_instance_valid(jugador):
		jugador = _buscar_jugador()
		return

	var dist := global_position.distance_to(jugador.global_position)
	var dir_jugador := (jugador.global_position - global_position).normalized()
	var vel_mod := Config.KEYWORD_HIELO_SLOW if ralentizado else 1.0

	if dist < MIN_DIST:
		velocity = -dir_jugador * velocidad * vel_mod
	elif dist > MAX_DIST:
		velocity = dir_jugador * velocidad * vel_mod
	else:
		velocity = Vector2.ZERO
		if not disparando and disparo_cooldown <= 0.0:
			_disparar(dir_jugador)

	if is_inside_tree():
		move_and_slide()

func _disparar(dir: Vector2) -> void:
	disparando = true
	disparo_cooldown = Config.MAGE_FIREBALL_COOLDOWN
	await get_tree().create_timer(0.5).timeout
	if not is_instance_valid(self) or _muerto:
		return
	var bola: Area2D = FIREBALL.instantiate()
	get_tree().current_scene.add_child(bola)
	bola.global_position = global_position
	bola.iniciar(dir, dano)
	disparando = false

func _post_morir() -> void:
	_reproducir_sonido_muerte(SFX_MUERTE)
	queue_free()

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
