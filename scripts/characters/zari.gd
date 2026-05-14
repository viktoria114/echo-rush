extends CharacterBody2D

const MIN_DIST := 220.0
const MAX_DIST := 320.0
const VELOCIDAD := 200.0
const COOLDOWN_ATAQUE := 1.2
const ARROW_SCENE := preload("res://scenes/projectiles/Arrow.tscn")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var atacando: bool = false
var cooldown_ataque: float = 0.0
var ultima_dir: Vector2 = Vector2.DOWN

func _ready() -> void:
	_cargar_idle_rotations()
	sprite.play("idle_south")

func _cargar_idle_rotations() -> void:
	var sf: SpriteFrames = sprite.sprite_frames
	var dirs := ["south", "north", "east", "west", "south-east", "south-west", "north-east", "north-west"]
	for d in dirs:
		var nombre: String = "idle_" + d
		if sf.has_animation(nombre):
			continue
		sf.add_animation(nombre)
		sf.set_animation_loop(nombre, false)
		sf.set_animation_speed(nombre, 1.0)
		var tex: Texture2D = load("res://assets/sprites/characters/zari/rotations/" + d + ".png")
		if tex:
			sf.add_frame(nombre, tex)

func _idle_anim(dir: Vector2) -> String:
	var ax: float = abs(dir.x)
	var ay: float = abs(dir.y)
	var sufijo: String
	if ax > 0.35 and ay > 0.35:
		sufijo = ("south" if dir.y > 0 else "north") + ("-east" if dir.x > 0 else "-west")
	elif ax >= ay:
		sufijo = "east" if dir.x > 0 else "west"
	else:
		sufijo = "south" if dir.y > 0 else "north"
	return "idle_" + sufijo

func _physics_process(delta: float) -> void:
	if cooldown_ataque > 0.0:
		cooldown_ataque -= delta

	var enemigo := _buscar_enemigo_cercano()
	if enemigo == null:
		velocity = Vector2.ZERO
		if not atacando:
			sprite.play(_idle_anim(ultima_dir))
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
			sprite.play(_idle_anim(ultima_dir))

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
	ultima_dir = dir
	var anim: String = _anim_por_dir(dir, "run")
	if sprite.animation != anim:
		sprite.play(anim)

func _anim_por_dir(dir: Vector2, prefijo: String) -> String:
	var ax: float = abs(dir.x)
	var ay: float = abs(dir.y)
	var sufijo: String
	if ax > 0.35 and ay > 0.35:
		if dir.x > 0:
			sufijo = "south-east" if dir.y > 0 else "north-east"
		else:
			sufijo = "south-west" if dir.y > 0 else "north-west"
	elif ax >= ay:
		sufijo = "east" if dir.x > 0 else "west"
	else:
		sufijo = "south" if dir.y > 0 else "north"
	return prefijo + "_" + sufijo

func _disparar(dir: Vector2) -> void:
	ultima_dir = dir
	atacando = true
	cooldown_ataque = COOLDOWN_ATAQUE
	sprite.play(_anim_por_dir(dir, "attack"))

	# Disparar la flecha cuando el personaje suelta la cuerda (~frame 5 de 8 a 10fps)
	await get_tree().create_timer(0.5).timeout
	if not is_instance_valid(self):
		return
	var flecha: Area2D = ARROW_SCENE.instantiate()
	get_tree().current_scene.add_child(flecha)
	flecha.global_position = global_position
	flecha.iniciar(dir, Config.PLAYER_ATTACK_DAMAGE)

	await get_tree().create_timer(0.3).timeout
	sprite.play(_idle_anim(ultima_dir))
	atacando = false
