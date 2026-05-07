extends Area2D

var velocidad: float = 500.0
var dano: int = 0
var direccion: Vector2 = Vector2.RIGHT
var vida_util: float = 2.0

func _ready() -> void:
	body_entered.connect(_al_golpear)

func iniciar(dir: Vector2, dmg: int) -> void:
	direccion = dir.normalized()
	dano = dmg
	rotation = direccion.angle()

func _process(delta: float) -> void:
	position += direccion * velocidad * delta
	vida_util -= delta
	if vida_util <= 0.0:
		queue_free()

func _al_golpear(cuerpo: Node2D) -> void:
	if cuerpo.is_in_group("enemigos") and cuerpo.has_method("recibir_dano"):
		cuerpo.recibir_dano(dano)
		queue_free()
