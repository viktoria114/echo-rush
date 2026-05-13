extends CharacterBody2D

const RANGO_ATAQUE := 75.0
const VELOCIDAD := 210.0
const COOLDOWN_ATAQUE := 0.8

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var placeholder: Polygon2D = $Placeholder

var atacando: bool = false
var cooldown_ataque: float = 0.0
var ultima_dir: Vector2 = Vector2.DOWN

func _ready() -> void:
	placeholder.visible = false
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
		var tex: Texture2D = load("res://assets/sprites/characters/brom/rotations/" + d + ".png")
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

	var objetivo := _buscar_enemigo_mas_peligroso()
	if objetivo == null:
		velocity = Vector2.ZERO
		if not atacando:
			sprite.play(_idle_anim(ultima_dir))
		move_and_slide()
		return

	var dist: float = global_position.distance_to(objetivo.global_position)
	var dir_objetivo: Vector2 = (objetivo.global_position - global_position).normalized()

	if dist > RANGO_ATAQUE:
		velocity = dir_objetivo * VELOCIDAD
		if not atacando:
			_play_run(dir_objetivo)
	else:
		velocity = Vector2.ZERO
		if not atacando and cooldown_ataque <= 0.0:
			_atacar(dir_objetivo)
		elif not atacando:
			sprite.play(_idle_anim(ultima_dir))

	move_and_slide()

func _buscar_enemigo_mas_peligroso() -> Node2D:
	var jugador: Node = get_tree().get_first_node_in_group("jugador")
	if jugador == null:
		return null
	var enemigos := get_tree().get_nodes_in_group("enemigos")
	var mas_cercano: Node2D = null
	var dist_min := INF
	for e in enemigos:
		var d: float = (jugador as Node2D).global_position.distance_to((e as Node2D).global_position)
		if d < dist_min:
			dist_min = d
			mas_cercano = e
	return mas_cercano

func _play_run(dir: Vector2) -> void:
	ultima_dir = dir
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

func _atacar(dir: Vector2) -> void:
	ultima_dir = dir
	atacando = true
	cooldown_ataque = COOLDOWN_ATAQUE
	sprite.play(_anim_por_dir(dir, "attack"))

	await get_tree().create_timer(0.33).timeout
	if not is_instance_valid(self):
		return
	for e in get_tree().get_nodes_in_group("enemigos"):
		var d: float = global_position.distance_to((e as Node2D).global_position)
		if d <= RANGO_ATAQUE and (e as Node).has_method("recibir_dano"):
			(e as Node).recibir_dano(Config.PLAYER_ATTACK_DAMAGE)

	await get_tree().create_timer(0.33).timeout
	sprite.play(_idle_anim(ultima_dir))
	atacando = false
