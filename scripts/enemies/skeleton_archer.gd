extends "res://scripts/enemies/enemy_base.gd"

const SFX_MUERTE = preload("res://assets/audio/sfx/esqueletoMuerte.ogg")
const MIN_DIST := 180.0
const MAX_DIST := 320.0
const COOLDOWN_DISPARO := 2.0
const ENEMY_ARROW = preload("res://scenes/projectiles/EnemyArrow.tscn")
const ROTATION_PATH := "res://assets/sprites/enemies/skeleton_archer/states/arquero_esqueleto/rotations/"

const ANIM_RUN := {
	"south": "run_south", "north": "run_north",
	"east": "run_east", "west": "run_west",
	"south-east": "run_south-east", "south-west": "run_south-west",
	"north-east": "run_north-east", "north-west": "run_north-west"
}
const ANIM_ATTACK := {
	"south": "attack_south", "north": "attack_north",
	"east": "attack_east", "west": "attack_west",
	"south-east": "attack_south-east", "south-west": "attack_south-west",
	"north-east": "attack_north-east", "north-west": "attack_north-west"
}
const ANIM_IDLE := {
	"south": "idle_south", "north": "idle_north",
	"east": "idle_east", "west": "idle_west",
	"south-east": "idle_south-east", "south-west": "idle_south-west",
	"north-east": "idle_north-east", "north-west": "idle_north-west"
}

var disparo_cooldown: float = 0.0
var disparando: bool = false
var direccion: String = "south"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	super._ready()
	vida = 35
	velocidad = 85.0
	dano = 8
	var barra := get_node_or_null("BarraVida") as ProgressBar
	if barra:
		barra.max_value = vida
		barra.value = vida
	_cargar_idle_rotations()
	sprite.play("idle_south")

# Carga las rotations como animaciones idle de un frame para cada dirección
func _cargar_idle_rotations() -> void:
	var sf: SpriteFrames = sprite.sprite_frames
	var dirs := ["south", "north", "east", "west", "south-east", "south-west", "north-east", "north-west"]
	for d in dirs:
		var nombre: String = "idle_" + d
		if sf.has_animation(nombre):
			continue
		sf.add_animation(nombre)
		sf.set_animation_loop(nombre, true)
		sf.set_animation_speed(nombre, 1.0)
		var tex: Texture2D = load(ROTATION_PATH + d + ".png")
		if tex:
			sf.add_frame(nombre, tex)

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

func _actualizar_animacion() -> void:
	if disparando:
		sprite.play(ANIM_ATTACK.get(direccion, "attack_south"))
	elif velocity != Vector2.ZERO:
		sprite.play(ANIM_RUN.get(direccion, "run_south"))
	else:
		sprite.play(ANIM_IDLE.get(direccion, "idle_south"))

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

	_actualizar_direccion(dir_jugador)

	if dist < MIN_DIST:
		velocity = -dir_jugador * velocidad * vel_mod
	elif dist > MAX_DIST:
		velocity = dir_jugador * velocidad * vel_mod
	else:
		velocity = Vector2.ZERO
		if not disparando and disparo_cooldown <= 0.0:
			_disparar(dir_jugador)

	_actualizar_animacion()

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

func _post_morir() -> void:
	_reproducir_sonido_muerte(SFX_MUERTE)
	var anim := "muerte_" + direccion
	if sprite.sprite_frames.has_animation(anim):
		sprite.sprite_frames.set_animation_loop(anim, false)
		sprite.play(anim)
		sprite.animation_finished.connect(queue_free)
	else:
		queue_free()

func recibir_dano(cantidad: int) -> void:
	super.recibir_dano(cantidad)
	var barra := get_node_or_null("BarraVida") as ProgressBar
	if barra:
		barra.value = vida
