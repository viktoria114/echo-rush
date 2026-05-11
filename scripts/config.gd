extends Node

# Resolución
const SCREEN_WIDTH := 1920
const SCREEN_HEIGHT := 1080

# Stats del jugador (Rael)
const PLAYER_MAX_HP := 100
const PLAYER_SPEED := 220.0
const PLAYER_ATTACK_DAMAGE := 25
const PLAYER_ATTACK_COOLDOWN := 0.5
const PLAYER_ATTACK_RANGE := 80.0

# Stats base de enemigos
const ENEMY_BASE_HP := 40
const ENEMY_BASE_SPEED := 90.0
const ENEMY_BASE_DAMAGE := 10
const ENEMY_ATTACK_COOLDOWN := 1.0

# Sistema de oleadas
const ENEMIES_PER_WAVE_BASE := 5
const WAVE_SCALING := 1.4
const ECHO_WAVE_INTERVAL := 5
const WAVES_PER_LEVEL := 5     # oleadas totales antes de abrir la tienda

# Economía
const COIN_DROP_VALUE := 10    # monedas que da cada moneda recogida
const ECHO_REROLL_COST := 50

# Keywords
const MAX_KEYWORDS := 3
const KEYWORD_SHIELD_HP := 30
const KEYWORD_SANGRE_HEAL := 5
const KEYWORD_RAYO_COOLDOWN_MULT := 0.5
const KEYWORD_FUEGO_INTERVAL := 5
const KEYWORD_FUEGO_DAMAGE := 40
const KEYWORD_FUEGO_RADIUS := 120.0
const KEYWORD_VENENO_DPS := 5.0
const KEYWORD_HIELO_SLOW := 0.4
