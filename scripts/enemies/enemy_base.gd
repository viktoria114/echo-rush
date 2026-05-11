extends CharacterBody2D

signal enemigo_muerto

const COIN_SCENE := preload("res://scenes/items/Coin.tscn")

var vida: int
var velocidad: float = Config.ENEMY_BASE_SPEED
var dano: int = Config.ENEMY_BASE_DAMAGE
var cooldown_ataque: float = 0.0
var rango_ataque: float = 50.0
var _muerto := false

# Efectos de keywords
var veneno_dps: float = 0.0
var veneno_timer: float = 0.0
var ralentizado: bool = false

@onready var jugador: CharacterBody2D = _buscar_jugador()

func _ready() -> void:
	add_to_group("enemigos")
	vida = Config.ENEMY_BASE_HP

func _buscar_jugador() -> CharacterBody2D:
	return get_tree().get_first_node_in_group("jugador")

func _physics_process(delta: float) -> void:
	if _muerto:
		return
	_actualizar_efectos(delta)
	if _muerto:
		return
	if jugador == null or not is_instance_valid(jugador):
		jugador = _buscar_jugador()
		return
	_mover_hacia_jugador()
	_intentar_ataque(delta)
	if is_inside_tree():
		move_and_slide()

func _mover_hacia_jugador() -> void:
	var dir := (jugador.global_position - global_position).normalized()
	var vel := velocidad * (Config.KEYWORD_HIELO_SLOW if ralentizado else 1.0)
	velocity = dir * vel

func _intentar_ataque(delta: float) -> void:
	cooldown_ataque -= delta
	if cooldown_ataque > 0.0:
		return
	var dist := global_position.distance_to(jugador.global_position)
	if dist < rango_ataque:
		cooldown_ataque = Config.ENEMY_ATTACK_COOLDOWN
		if jugador.has_method("recibir_dano"):
			jugador.recibir_dano(dano)

func recibir_dano(cantidad: int) -> void:
	vida -= cantidad
	if vida <= 0 and not _muerto:
		_morir()

func _morir() -> void:
	_muerto = true
	set_physics_process(false)
	emit_signal("enemigo_muerto")
	var pos := global_position
	call_deferred("_soltar_moneda", pos)
	call_deferred("queue_free")

func _soltar_moneda(pos: Vector2) -> void:
	var moneda := COIN_SCENE.instantiate()
	get_parent().add_child(moneda)
	moneda.global_position = pos

func aplicar_veneno(dps: float) -> void:
	veneno_dps = dps
	veneno_timer = 5.0

func aplicar_hielo(_factor: float) -> void:
	ralentizado = true
	await get_tree().create_timer(3.0).timeout
	ralentizado = false

func _actualizar_efectos(delta: float) -> void:
	if veneno_timer > 0.0:
		veneno_timer -= delta
		vida -= int(veneno_dps * delta)
		if vida <= 0 and not _muerto:
			_morir()
