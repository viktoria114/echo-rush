extends "res://scripts/enemies/enemy_base.gd"

signal boss_vida_cambiada(vida_actual: int, vida_max: int)

const BOSS_HP: int        = 400
const BOSS_VELOCIDAD: float = 65.0
const BOSS_DANO: int      = 20

const ANIM_IDLE: Dictionary = {
	"south": "standing_south", "north": "standing_north",
	"east": "standing_east",   "west": "standing_west",
	"south-east": "standing_south-east", "south-west": "standing_south-west",
	"north-east": "standing_north-east", "north-west": "standing_north-west",
}
const ANIM_WALK: Dictionary = {
	"south":      "walking-south",     "north":      "walking-north",
	"east":       "walking-east",      "west":       "walking-west",
	"south-east": "walking-south-east","south-west": "walking-south-west",
	"north-east": "walking-north-east","north-west": "walking-north-west",
}
const ANIM_ATTACK: Dictionary = {
	"south":      "goblin_boss_raises_massive_club_high_overhead_with-south",
	"north":      "goblin_boss_raises_massive_club_high_overhead_with-north",
	"east":       "goblin_boss_raises_massive_club_high_overhead_with-east",
	"west":       "goblin_boss_raises_massive_club_high_overhead_with-west",
	"south-east": "goblin_boss_raises_massive_club_high_overhead_with-south-east",
	"south-west": "goblin_boss_raises_massive_club_high_overhead_with-south-west",
	"north-east": "goblin_boss_raises_massive_club_high_overhead_with-north-east",
	"north-west": "goblin_boss_raises_massive_club_high_overhead_with-north-west",
}
const ANIM_MUERTE: String = "goblin_boss_takes_devastating_final_blow_staggers-south"

var vida_max_boss: int = BOSS_HP
var _dir_actual: String = "south"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	super._ready()
	vida          = BOSS_HP
	vida_max_boss = BOSS_HP
	velocidad     = BOSS_VELOCIDAD
	dano          = BOSS_DANO
	rango_ataque  = 110.0
	_play_anim(ANIM_IDLE["south"] as String)

func _mover_hacia_jugador() -> void:
	super._mover_hacia_jugador()
	_actualizar_animacion()

func _actualizar_animacion() -> void:
	if jugador == null:
		_play_anim(ANIM_IDLE.get(_dir_actual, ANIM_IDLE["south"]) as String)
		return
	var dir: Vector2 = (jugador.global_position - global_position).normalized()
	_dir_actual = _sufijo_dir(dir)
	var dist: float = global_position.distance_to(jugador.global_position)
	if dist <= rango_ataque:
		_play_anim(ANIM_ATTACK.get(_dir_actual, ANIM_ATTACK["south"]) as String)
	else:
		_play_anim(ANIM_WALK.get(_dir_actual, ANIM_WALK["south"]) as String)

func _sufijo_dir(dir: Vector2) -> String:
	var ax: float = absf(dir.x)
	var ay: float = absf(dir.y)
	if ax > 0.35 and ay > 0.35:
		return ("south" if dir.y > 0.0 else "north") + "-" + ("east" if dir.x > 0.0 else "west")
	elif ax >= ay:
		return "east" if dir.x > 0.0 else "west"
	else:
		return "south" if dir.y > 0.0 else "north"

func _play_anim(anim: String) -> void:
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation(anim):
		if sprite.animation != anim:
			sprite.play(anim)

func _post_morir() -> void:
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation(ANIM_MUERTE):
		sprite.sprite_frames.set_animation_loop(ANIM_MUERTE, false)
		sprite.play(ANIM_MUERTE)
		sprite.animation_finished.connect(queue_free)
	else:
		queue_free()

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
