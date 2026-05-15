extends "res://scripts/enemies/enemy_base.gd"

const MIN_DIST := 180.0
const MAX_DIST := 320.0
const COOLDOWN_DISPARO := 2.0
const ENEMY_ARROW = preload("res://scenes/projectiles/EnemyArrow.tscn")

var disparo_cooldown: float = 0.0
var disparando: bool = false

func _ready() -> void:
	super._ready()
	vida = 35
	velocidad = 85.0
	dano = 8
	var barra := get_node_or_null("BarraVida") as ProgressBar
	if barra:
		barra.max_value = vida
		barra.value = vida
	_generar_visual()

# Reemplaza el _physics_process de la base: gestiona distancia y disparo
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
	disparo_cooldown = COOLDOWN_DISPARO
	await get_tree().create_timer(0.4).timeout
	if not is_instance_valid(self) or _muerto:
		return
	var flecha: Area2D = ENEMY_ARROW.instantiate()
	get_tree().current_scene.add_child(flecha)
	flecha.global_position = global_position
	flecha.iniciar(dir, dano)
	disparando = false

func recibir_dano(cantidad: int) -> void:
	super.recibir_dano(cantidad)
	var barra := get_node_or_null("BarraVida") as ProgressBar
	if barra:
		barra.value = vida

# La escena no tiene nodo Poligono — se crea como hijo en tiempo de ejecución
func _generar_visual() -> void:
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array([
		Vector2(0, -26), Vector2(18, 0), Vector2(0, 26), Vector2(-18, 0)
	])
	polygon.color = Color(0.88, 0.88, 0.75)
	add_child(polygon)
