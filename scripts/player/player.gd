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

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $HitboxArea

const ANIM_WALK := {
	"south": "walk_south", "north": "walk_north",
	"east": "walk_east",   "west": "walk_west"
}
const ANIM_PUNCH := {
	"south": "punch_south", "north": "punch_north",
	"east": "punch_east",   "west": "punch_west"
}

func _ready() -> void:
	add_to_group("jugador")
	vida_actual = Config.PLAYER_MAX_HP
	_configurar_animaciones()

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
	if dir != Vector2.ZERO:
		dir = dir.normalized()
		_actualizar_direccion(dir)
		velocity = dir * Config.PLAYER_SPEED
		if not atacando:
			sprite.play(ANIM_WALK.get(direccion, "walk_south"))
	else:
		velocity = Vector2.ZERO
		if not atacando:
			sprite.play("idle")

func _actualizar_direccion(dir: Vector2) -> void:
	if abs(dir.x) >= abs(dir.y):
		direccion = "east" if dir.x > 0 else "west"
	else:
		direccion = "south" if dir.y > 0 else "north"

func _ejecutar_ataque() -> void:
	var cooldown := Config.PLAYER_ATTACK_COOLDOWN
	if "RAYO" in keywords_activas:
		cooldown *= Config.KEYWORD_RAYO_COOLDOWN_MULT
	ataque_cooldown = cooldown
	atacando = true
	contador_ataques += 1

	_posicionar_hitbox()
	sprite.play(ANIM_PUNCH.get(direccion, "punch_south"))

	# Detectar golpe a mitad de la animación
	await get_tree().create_timer(0.15).timeout
	for cuerpo in hitbox.get_overlapping_bodies():
		if cuerpo.is_in_group("enemigos") and cuerpo.has_method("recibir_dano"):
			cuerpo.recibir_dano(Config.PLAYER_ATTACK_DAMAGE)
			if "SANGRE" in keywords_activas:
				curar(Config.KEYWORD_SANGRE_HEAL)
			if "VENENO" in keywords_activas:
				cuerpo.aplicar_veneno(Config.KEYWORD_VENENO_DPS)
			if "HIELO" in keywords_activas:
				cuerpo.aplicar_hielo(Config.KEYWORD_HIELO_SLOW)

	if "FUEGO" in keywords_activas and contador_ataques % Config.KEYWORD_FUEGO_INTERVAL == 0:
		_explosion_fuego()

	await sprite.animation_finished
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
	vida_actual = min(Config.PLAYER_MAX_HP, vida_actual + cantidad)
	emit_signal("vida_cambiada", vida_actual)

func agregar_keyword(kw: String) -> void:
	if kw in keywords_activas or keywords_activas.size() >= Config.MAX_KEYWORDS:
		return
	keywords_activas.append(kw)
	if kw == "ESCUDO":
		escudo_restante += Config.KEYWORD_SHIELD_HP

func _configurar_animaciones() -> void:
	var sf := SpriteFrames.new()
	sf.remove_animation("default")
	_agregar_anim(sf, "walk_south", "animation-75bd5ea5/south",          6, 10.0, true)
	_agregar_anim(sf, "walk_north", "animation-75bd5ea5/north",          6, 10.0, true)
	_agregar_anim(sf, "walk_east",  "animation-75bd5ea5/east",           6, 10.0, true)
	_agregar_anim(sf, "walk_west",  "Walking-cf92d571/west",             6, 10.0, true)
	_agregar_anim(sf, "punch_south","Cross_Punch-a4b41712/south",        6, 12.0, false)
	_agregar_anim(sf, "punch_north","Cross_Punch-a4b41712/north",        6, 12.0, false)
	_agregar_anim(sf, "punch_east", "Cross_Punch-a4b41712/east",         6, 12.0, false)
	_agregar_anim(sf, "punch_west", "Cross_Punch-a4b41712/west",         6, 12.0, false)
	_agregar_anim(sf, "idle",       "Fight_Stance_Idle-da976329/south",  8,  8.0, true)
	sprite.sprite_frames = sf
	sprite.play("idle")

func _agregar_anim(sf: SpriteFrames, nombre: String, subcarpeta: String, n: int, fps: float, loop: bool) -> void:
	sf.add_animation(nombre)
	sf.set_animation_speed(nombre, fps)
	sf.set_animation_loop(nombre, loop)
	for i in range(n):
		var ruta := "res://assets/sprites/characters/rael/animations/%s/frame_%03d.png" % [subcarpeta, i]
		sf.add_frame(nombre, load(ruta))
