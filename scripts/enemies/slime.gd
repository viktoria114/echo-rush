extends "res://scripts/enemies/enemy_base.gd"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var barra: ProgressBar = $BarraVida

func _ready() -> void:
	super._ready()
	barra.max_value = Config.ENEMY_BASE_HP
	barra.value = Config.ENEMY_BASE_HP
	sprite.play("attack_south")

func _mover_hacia_jugador() -> void:
	super._mover_hacia_jugador()
	_actualizar_animacion()

func _actualizar_animacion() -> void:
	if jugador == null:
		return
	var dir := jugador.global_position - global_position
	var anim: String
	if abs(dir.x) >= abs(dir.y):
		anim = "attack_east" if dir.x > 0 else "attack_west"
	else:
		anim = "attack_south" if dir.y > 0 else "attack_north"
	if sprite.animation != anim:
		sprite.play(anim)

func recibir_dano(cantidad: int) -> void:
	super.recibir_dano(cantidad)
	if is_instance_valid(self):
		barra.value = vida
