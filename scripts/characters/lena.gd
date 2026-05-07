extends CharacterBody2D

const MIN_DIST := 250.0
const MAX_DIST := 380.0
const VELOCIDAD := 190.0
const COOLDOWN_ATAQUE := 1.5
const PROYECTIL = preload("res://scenes/projectiles/Arrow.tscn")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var placeholder: Polygon2D = $Placeholder

var atacando: bool = false
var cooldown_ataque: float = 0.0

func _ready() -> void:
	placeholder.visible = false

func _physics_process(delta: float) -> void:
	if cooldown_ataque > 0.0:
		cooldown_ataque -= delta

	var enemigo := _buscar_enemigo_cercano()
	if enemigo == null:
		velocity = Vector2.ZERO
		if not atacando:
			sprite.stop()
		move_and_slide()
		return

	var dist: float = global_position.distance_to(enemigo.global_position)
	var dir_enemigo: Vector2 = (enemigo.global_position - global_position).normalized()

	if dist < MIN_DIST:
		var dir_escape: Vector2 = -dir_enemigo
		velocity = dir_escape * VELOCIDAD
		if not atacando:
			_play_run(dir_escape)
	elif dist > MAX_DIST:
		velocity = dir_enemigo * VELOCIDAD
		if not atacando:
			_play_run(dir_enemigo)
	else:
		velocity = Vector2.ZERO
		if not atacando and cooldown_ataque <= 0.0:
			_disparar(dir_enemigo)
		elif not atacando:
			sprite.stop()

	move_and_slide()

func _buscar_enemigo_cercano() -> Node2D:
	var enemigos := get_tree().get_nodes_in_group("enemigos")
	var mas_cercano: Node2D = null
	var dist_min := INF
	for e in enemigos:
		var d: float = global_position.distance_to((e as Node2D).global_position)
		if d < dist_min:
			dist_min = d
			mas_cercano = e
	return mas_cercano

func _play_run(dir: Vector2) -> void:
	var anim: String = _anim_por_dir(dir, "running")
	if sprite.animation != anim:
		sprite.play(anim)

func _anim_por_dir(dir: Vector2, prefijo: String) -> String:
	var ax: float = abs(dir.x)
	var ay: float = abs(dir.y)
	var sufijo: String
	if ax > 0.35 and ay > 0.35:
		sufijo = ("south" if dir.y > 0 else "north") + ("-east" if dir.x > 0 else "-west")
	elif ax >= ay:
		sufijo = "east" if dir.x > 0 else "west"
	else:
		sufijo = "south" if dir.y > 0 else "north"
	return prefijo + "-" + sufijo

func _disparar(dir: Vector2) -> void:
	atacando = true
	cooldown_ataque = COOLDOWN_ATAQUE
	sprite.play(_anim_por_dir(dir, "attack"))

	await get_tree().create_timer(0.5).timeout
	if not is_instance_valid(self):
		return
	var proyectil: Area2D = PROYECTIL.instantiate()
	get_tree().current_scene.add_child(proyectil)
	proyectil.global_position = global_position
	proyectil.iniciar(dir, Config.PLAYER_ATTACK_DAMAGE)

	await get_tree().create_timer(0.25).timeout
	sprite.stop()
	atacando = false
