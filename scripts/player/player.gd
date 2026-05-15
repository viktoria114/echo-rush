extends CharacterBody2D

signal vida_cambiada(nueva_vida: int)
signal jugador_muerto

var vida_actual: int
var ataque_cooldown: float = 0.0
var contador_ataques: int = 0
var atacando: bool = false
var direccion: String = "south"

var keywords_activas: Array[String] = []
var escudo_restante: int = 0

const SFX_GOLPE = preload("res://assets/audio/sfx/golpe.ogg")
var _sfx_golpe: AudioStreamPlayer

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $HitboxArea

const ANIM_WALK := {
	"south": "running_south",           "north": "running_north",
	"east": "running_east",             "west": "running_west",
	"south-east": "running_south-east", "south-west": "running_south-west",
	"north-east": "running_north-east", "north-west": "running_north-west"
}
const ANIM_ATTACK := {
	"south": "attack_south",           "north": "attack_north",
	"east": "attack_east",             "west": "attack_west",
	"south-east": "attack_south-east", "south-west": "attack_south-west",
	"north-east": "attack_north-east", "north-west": "attack_north-west"
}
const ANIM_IDLE := {
	"south": "idle_south",           "north": "idle_north",
	"east": "idle_east",             "west": "idle_west",
	"south-east": "idle_south-east", "south-west": "idle_south-west",
	"north-east": "idle_north-east", "north-west": "idle_north-west"
}

func _ready() -> void:
	add_to_group("jugador")
	vida_actual = UpgradeSystem.get_vida_max()
	_cargar_idle_rotations()
	sprite.play("idle_south")
	_sfx_golpe = AudioStreamPlayer.new()
	_sfx_golpe.stream = SFX_GOLPE
	add_child(_sfx_golpe)

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
		var tex: Texture2D = load("res://assets/sprites/characters/rael/rotations/" + d + ".png")
		if tex:
			sf.add_frame(nombre, tex)

func _physics_process(delta: float) -> void:
	if ataque_cooldown > 0.0:
		ataque_cooldown -= delta
	_manejar_movimiento()
	if not atacando and Input.is_action_just_pressed("attack") and ataque_cooldown <= 0.0:
		_ejecutar_ataque()
	move_and_slide()

func _manejar_movimiento() -> void:
	var dir := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	if Input.is_physical_key_pressed(KEY_A): dir.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D): dir.x += 1.0
	if Input.is_physical_key_pressed(KEY_W): dir.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S): dir.y += 1.0
	dir = dir.clamp(Vector2(-1.0, -1.0), Vector2(1.0, 1.0))
	if dir != Vector2.ZERO:
		dir = dir.normalized()
		_actualizar_direccion(dir)
		velocity = dir * UpgradeSystem.get_velocidad()
		if not atacando:
			sprite.play(ANIM_WALK.get(direccion, "walk_south"))
	else:
		velocity = Vector2.ZERO
		if not atacando:
			sprite.play(ANIM_IDLE.get(direccion, "idle_south"))

func _actualizar_direccion(dir: Vector2) -> void:
	var ax: float = abs(dir.x)
	var ay: float = abs(dir.y)
	if ax > 0.35 and ay > 0.35:
		if dir.x > 0:
			direccion = "south-east" if dir.y > 0 else "north-east"
		else:
			direccion = "south-west" if dir.y > 0 else "north-west"
	elif ax >= ay:
		direccion = "east" if dir.x > 0 else "west"
	else:
		direccion = "south" if dir.y > 0 else "north"

func _ejecutar_ataque() -> void:
	ataque_cooldown = UpgradeSystem.get_cooldown()
	atacando = true
	contador_ataques += 1

	_posicionar_hitbox()
	sprite.play(ANIM_ATTACK.get(direccion, "attack_south"))

	await get_tree().create_timer(0.15).timeout
	var golpeo_enemigo := false
	for cuerpo in hitbox.get_overlapping_bodies():
		if cuerpo.is_in_group("enemigos") and cuerpo.has_method("recibir_dano"):
			cuerpo.recibir_dano(UpgradeSystem.get_dano_melee())
			golpeo_enemigo = true
			if "SANGRE" in keywords_activas:
				curar(Config.KEYWORD_SANGRE_HEAL)
			if "VENENO" in keywords_activas:
				cuerpo.aplicar_veneno(Config.KEYWORD_VENENO_DPS)
			if "HIELO" in keywords_activas:
				cuerpo.aplicar_hielo(Config.KEYWORD_HIELO_SLOW)
	if golpeo_enemigo:
		_sfx_golpe.play()

	if "FUEGO" in keywords_activas and contador_ataques % Config.KEYWORD_FUEGO_INTERVAL == 0:
		_explosion_fuego()

	var n_frames: int = sprite.sprite_frames.get_frame_count(sprite.animation)
	var fps: float = sprite.sprite_frames.get_animation_speed(sprite.animation)
	await get_tree().create_timer(float(n_frames) / fps - 0.15).timeout
	sprite.play(ANIM_IDLE.get(direccion, "idle_south"))
	atacando = false

func _posicionar_hitbox() -> void:
	var r := Config.PLAYER_ATTACK_RANGE
	match direccion:
		"south": hitbox.position = Vector2(0, r)
		"north": hitbox.position = Vector2(0, -r)
		"east":  hitbox.position = Vector2(r, 0)
		"west":  hitbox.position = Vector2(-r, 0)

func _explosion_fuego() -> void:
	for e in get_tree().get_nodes_in_group("enemigos"):
		if global_position.distance_to(e.global_position) <= Config.KEYWORD_FUEGO_RADIUS:
			if e.has_method("recibir_dano"):
				e.recibir_dano(Config.KEYWORD_FUEGO_DAMAGE)

func recibir_dano(cantidad: int) -> void:
	if escudo_restante > 0:
		escudo_restante -= cantidad
		if escudo_restante < 0:
			cantidad = abs(escudo_restante)
			escudo_restante = 0
		else:
			return
	vida_actual = max(0, vida_actual - cantidad)
	emit_signal("vida_cambiada", vida_actual)
	if vida_actual <= 0:
		emit_signal("jugador_muerto")
		queue_free()

func curar(cantidad: int) -> void:
	vida_actual = min(UpgradeSystem.get_vida_max(), vida_actual + cantidad)
	emit_signal("vida_cambiada", vida_actual)

func agregar_keyword(kw: String) -> void:
	if kw in keywords_activas or keywords_activas.size() >= Config.MAX_KEYWORDS:
		return
	keywords_activas.append(kw)
	if kw == "ESCUDO":
		escudo_restante += Config.KEYWORD_SHIELD_HP
