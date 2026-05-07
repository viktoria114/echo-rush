extends "res://scripts/enemies/enemy_base.gd"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var barra: ProgressBar = $BarraVida

func _ready() -> void:
	super._ready()
	barra.max_value = Config.ENEMY_BASE_HP
	barra.value = Config.ENEMY_BASE_HP
	sprite.play("running-south")

func _mover_hacia_jugador() -> void:
	super._mover_hacia_jugador()
	_actualizar_animacion()

func _actualizar_animacion() -> void:
	if jugador == null:
		return
	var dir := jugador.global_position - global_position
	var dist: float = dir.length()
	var prefijo := "attack" if dist < 55.0 else "running"
	var anim := prefijo + "-" + _sufijo_dir(dir.normalized())
	if sprite.animation != anim:
		sprite.play(anim)

func _sufijo_dir(dir: Vector2) -> String:
	var ax: float = abs(dir.x)
	var ay: float = abs(dir.y)
	if ax > 0.35 and ay > 0.35:
		return ("south" if dir.y > 0 else "north") + ("-east" if dir.x > 0 else "-west")
	elif ax >= ay:
		return "east" if dir.x > 0 else "west"
	else:
		return "south" if dir.y > 0 else "north"

func recibir_dano(cantidad: int) -> void:
	super.recibir_dano(cantidad)
	if is_instance_valid(self):
		barra.value = vida
