extends Node

# Bonus acumulados entre niveles
var dano_bonus: int = 0
var cooldown_reduccion: float = 0.0   # 0.2 = 20% más rápido
var vida_bonus: int = 0
var velocidad_bonus: float = 0.0      # 0.15 = 15% más rápido

func get_dano_melee() -> int:
	return Config.PLAYER_ATTACK_DAMAGE + dano_bonus

# El cooldown mínimo siempre es 0.1 para evitar bucles infinitos
func get_cooldown() -> float:
	return max(0.1, Config.PLAYER_ATTACK_COOLDOWN * (1.0 - cooldown_reduccion))

func get_vida_max() -> int:
	return Config.PLAYER_MAX_HP + vida_bonus

func get_velocidad() -> float:
	return Config.PLAYER_SPEED * (1.0 + velocidad_bonus)

func reiniciar() -> void:
	dano_bonus = 0
	cooldown_reduccion = 0.0
	vida_bonus = 0
	velocidad_bonus = 0.0
