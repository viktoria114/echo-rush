extends "res://scripts/enemies/enemy_base.gd"

const SFX_MUERTE = preload("res://assets/audio/sfx/slimeMuerte.ogg")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var barra: ProgressBar = $BarraVida

func _ready() -> void:
	super._ready()
	barra.max_value = Config.ENEMY_BASE_HP
	barra.value = Config.ENEMY_BASE_HP
	_play_anim("idle_south")

func _mover_hacia_jugador() -> void:
	super._mover_hacia_jugador()
	_actualizar_animacion()

func _actualizar_animacion() -> void:
	if jugador == null:
		_play_anim("idle_south")
		return
	var dir := jugador.global_position - global_position
	var anim := "attack_" + _sufijo_dir(dir.normalized())
	if sprite.animation != anim:
		_play_anim(anim)

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
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)
	elif sprite.sprite_frames and sprite.sprite_frames.has_animation("default"):
		sprite.play("default")

func _post_morir() -> void:
	_reproducir_sonido_muerte(SFX_MUERTE)
	var dir := Vector2.DOWN
	if jugador != null and is_instance_valid(jugador):
		dir = (jugador.global_position - global_position).normalized()
	var anim := "muerte_" + _sufijo_dir(dir)
	sprite.sprite_frames.set_animation_loop(anim, false)
	_play_anim(anim)
	sprite.animation_finished.connect(queue_free)

func recibir_dano(cantidad: int) -> void:
	super.recibir_dano(cantidad)
	if is_instance_valid(self):
		barra.value = vida
