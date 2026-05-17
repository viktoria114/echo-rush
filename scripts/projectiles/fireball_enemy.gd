extends Area2D

var velocidad: float = Config.MAGE_FIREBALL_SPEED
var dano: int = 0
var radio_explosion: float = Config.MAGE_FIREBALL_RADIUS
var direccion: Vector2 = Vector2.RIGHT
var vida_util: float = 3.0
var _explotando := false

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
		_explotar()

func _al_golpear(cuerpo: Node2D) -> void:
	if cuerpo.is_in_group("jugador"):
		_explotar()

func _explotar() -> void:
	if _explotando:
		return
	_explotando = true
	set_process(false)
	for nodo in get_tree().get_nodes_in_group("jugador"):
		if global_position.distance_to(nodo.global_position) <= radio_explosion:
			if nodo.has_method("recibir_dano"):
				nodo.recibir_dano(dano)
	queue_free()
