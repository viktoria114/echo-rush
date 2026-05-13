extends "res://scripts/enemies/enemy_base.gd"

signal boss_vida_cambiada(vida_actual: int, vida_max: int)

const BOSS_HP        := 400
const BOSS_VELOCIDAD := 65.0
const BOSS_DANO      := 20

var vida_max_boss: int = BOSS_HP

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	super._ready()
	vida          = BOSS_HP
	vida_max_boss = BOSS_HP
	velocidad     = BOSS_VELOCIDAD
	dano          = BOSS_DANO
	rango_ataque  = 110.0
	$Poligono.visible = false
	_play_anim("idle_south")

func _mover_hacia_jugador() -> void:
	super._mover_hacia_jugador()
	_actualizar_animacion()

func _actualizar_animacion() -> void:
	if jugador == null:
		_play_anim("idle_south")
		return
	var dir := (jugador.global_position - global_position).normalized()
	var anim: String = _anim_ataque(dir)
	if sprite.animation != anim:
		_play_anim(anim)

# Mapea la direccion a una de las 4 animaciones de ataque disponibles:
# attack_north-west ("norte"), attack_south ("sur"),
# attack_south-east ("este"), attack_south-west ("oeste")
func _anim_ataque(dir: Vector2) -> String:
	if dir.y < -0.3:
		return "attack_north-west"
	elif dir.x > 0.3:
		return "attack_south-east"
	elif dir.x < -0.3:
		return "attack_south-west"
	else:
		return "attack_south"

func _sufijo_dir(dir: Vector2) -> String:
	var ax: float = abs(dir.x)
	var ay: float = abs(dir.y)
	if ax > 0.35 and ay > 0.35:
		return ("south" if dir.y > 0 else "north") + "-" + ("east" if dir.x > 0 else "west")
	elif ax >= ay:
		return "east" if dir.x > 0 else "west"
	else:
		return "south" if dir.y > 0 else "north"

func _play_anim(anim: String) -> void:
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)

func _post_morir() -> void:
	sprite.sprite_frames.set_animation_loop("muerte_south-west", false)
	_play_anim("muerte_south-west")
	sprite.animation_finished.connect(queue_free)

func recibir_dano(cantidad: int) -> void:
	vida -= cantidad
	if vida <= 0 and not _muerto:
		_morir()
	elif not _muerto:
		emit_signal("boss_vida_cambiada", vida, vida_max_boss)

func _actualizar_efectos(delta: float) -> void:
	if veneno_timer > 0.0:
		veneno_timer -= delta
		vida -= int(veneno_dps * delta)
		if vida <= 0 and not _muerto:
			_morir()
		elif not _muerto:
			emit_signal("boss_vida_cambiada", vida, vida_max_boss)
