# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# Echo Rush

Shooter roguelite top-down en 2D con 4 personajes estudiantiles.
Motor: **Godot 4.6.2** | Lenguaje: **GDScript únicamente** | Integración: **Claude API**
Studio: **Claude Code Game Studios v0.3.0**

---

## Technology Stack

- **Engine**: Godot 4.6.2
- **Language**: GDScript
- **Build System**: SCons (engine), Godot Export Templates
- **Asset Pipeline**: Godot Import System + custom resource pipeline

## Engine Version Reference

@docs/engine-reference/godot/VERSION.md

---

## Descripción del juego

Cuatro estudiantes caen a un mundo paralelo a través de un portal y deben
sobrevivir oleadas de monstruos. Entre oleadas aparece **Echo**, un mercader
misterioso cuyos diálogos se generan con Claude API. El jugador escribe en
lenguaje libre y Echo responde con keywords que activan habilidades reales.

---

## Estado actual del proyecto (2026-05-12)

El juego está en desarrollo activo con la mayoría del código implementado:

**Completo:**
- Scripts de todos los sistemas: `scripts/` tiene `player/`, `characters/`, `enemies/`, `systems/`, `ui/`, `items/`, `projectiles/`
- Escenas de todos los niveles: Level1–Level4, PrologueScene
- Escenas de UI: MainMenu, HUD, GameOver, Shop, EchoShop
- Escenas de enemigos: Enemy, Goblin, Slime, Troll, Mage, SkeletonArcher, Boss, BossGolem, BossPortal, BossFinal
- Escenas de personajes: Rael, Lena, Brom, Zari
- Autoloads: Config, Economy, KeywordSystem, EchoAPI, UpgradeSystem + AppConfig, SceneLoader, ProjectMusicController, ProjectUISoundController (del template Maaack's)

**Pendiente:**
- EchoAPI deshabilitada por defecto — requiere `user://api_key.txt` con clave de Anthropic
- Sprites de Lena y Brom — usando `Polygon2D` placeholder (azul/verde respectivamente)
- Animaciones de Zari — solo tiene rotaciones estáticas (8 dirs)
- Fondos en `assets/backgrounds/` — los ZIPs pueden no estar extraídos
- Audio, fuentes
- Modo Infinito, finales A y B

---

## Autoloads (Singletons globales)

Todos los autoloads están disponibles en cualquier script sin `@onready` ni `get_node()`:

| Singleton | Script | Responsabilidad |
|-----------|--------|-----------------|
| `Config` | `scripts/config.gd` | Todas las constantes del juego (HP, velocidades, cooldowns, keywords) |
| `Economy` | `scripts/systems/economy.gd` | Monedas del jugador; señal `monedas_cambiadas(total)` |
| `KeywordSystem` | `scripts/systems/keyword_system.gd` | Lista de keywords activas; aplica al jugador por grupo |
| `EchoAPI` | `scripts/systems/echo_api.gd` | Llamadas a Claude API; señales `respuesta_recibida`, `error_api`, `cargando` |
| `UpgradeSystem` | `scripts/systems/upgrade_system.gd` | Bonos de stats entre niveles; persiste al cambiar de escena |
| `AppConfig` | (addon) | Configuración de la app (opciones de video, audio, input) — del template Maaack's |
| `SceneLoader` | (addon) | Carga de escenas con pantalla de carga — usar en lugar de `change_scene_to_file()` directamente |
| `ProjectMusicController` | (addon) | Reproducción de música de fondo; `.play_stream(stream)` para cambiar pista |
| `ProjectUISoundController` | (addon) | Sonidos de UI (botones, menús) |

`Config` es la primera dependencia — todo lo demás lo referencia. Cualquier valor numérico balanceable va en `config.gd`, nunca hardcodeado.

`ProjectMusicController` se usa activamente en `level_manager.gd` para cambiar entre música de nivel y música de boss:
```gdscript
ProjectMusicController.play_stream(MUSICA_BOSS)    # al spawnearse el boss
ProjectMusicController.play_stream(MUSICA_NIVEL)   # al morir el boss
```

---

## Arquitectura de sistemas

### Coordinación de niveles (`level_manager.gd`)

`scripts/ui/level_manager.gd` es el nodo raíz de cada escena de nivel. Conecta:
- `WaveManager` (hijo de la escena) → señales de oleadas → HUD + lógica de transición
- `Jugador` (hijo de la escena) → `vida_cambiada`, `jugador_muerto`
- `Economy`, `KeywordSystem` (autoloads) → HUD
- Al completarse el nivel, abre `Shop.tscn` o `EchoShop.tscn` y luego cambia a `proxima_escena`

`WaveManager` es un nodo hijo de la escena de nivel, **no un autoload**. Sus referencias (`contenedor_enemigos`, `puntos_spawn`) se inyectan desde `level_manager._ready()`.

### Flujo de tiendas

Hay dos tiendas distintas:
- **`Shop.tscn`** (`scripts/ui/shop.gd`) — upgrades de stats permanentes (daño, velocidad, HP) usando `UpgradeSystem`
- **`EchoShop.tscn`** (`scripts/ui/echo_shop.gd`) — interacción con Echo vía Claude API para obtener keywords

`level_manager._abrir_tienda()` abre `Shop.tscn` siempre al completar el nivel. `EchoShop` se muestra según diseño narrativo (ver cada nivel).

### Keywords

Keywords se rastrean en dos lugares en paralelo:
1. `KeywordSystem` (autoload) — lista canónica, emite `keywords_actualizadas` para el HUD
2. `player.keywords_activas` (Array local) — usado en `_physics_process` para aplicar efectos por frame

`KeywordSystem.agregar_keyword()` sincroniza ambos llamando `jugador.agregar_keyword()` por grupo.

### Enemigos

Todos los enemigos extienden `enemy_base.gd`. El patrón de herencia:
```
enemy_base.gd
  ├── goblin.gd, slime.gd, troll.gd, mage.gd, skeleton_archer.gd
  └── boss.gd
		├── boss_golem.gd
		├── boss_portal.gd
		└── boss_final.gd
```

Los enemigos se identifican por el grupo `"enemigos"`, el jugador por `"jugador"`. Las señales `enemigo_muerto` y `boss_vida_cambiada` comunican estado al `WaveManager` y HUD.

### Compañeros autónomos

Brom, Lena y Zari son `CharacterBody2D` autónomos en la escena. Buscan enemigos con `get_tree().get_nodes_in_group("enemigos")` — no usan `NavigationAgent2D`.

### EchoAPI — activar Claude

Por defecto `_api_habilitada = false`. Para activar en producción o pruebas:
```gdscript
# Opción 1: archivo (persiste entre sesiones)
# Crear user://api_key.txt con la clave de Anthropic

# Opción 2: en runtime
EchoAPI.configurar_api_key("sk-ant-...")
```
Sin API key, `EchoAPI.preguntar()` emite un fallback con keyword `[FUEGO]` para no crashear el flujo.

---

## Personajes

| Personaje | Rol       | Control     |
|-----------|-----------|-------------|
| Rael      | Atacante  | Jugador (WASD + Z / click izquierdo) |
| Lena      | Maga      | Autónoma — ataca a distancia |
| Brom      | Tanque    | Autónomo — intercepta enemigos cercanos al jugador |
| Zari      | Arquera   | Autónoma — dispara flechas a distancia |

---

## Estructura del proyecto

```
/scenes/
  opening/      → opening.tscn (escena principal — arranca el juego)
  levels/       → Level1–Level4, PrologueScene (estructura original)
  game_scene/   → levels/level_1–3.tscn + tutorials/ (estructura nueva del template)
  ui/           → HUD, GameOver, EchoShop, Shop, MainMenu
  menus/        → main_menu/, options_menu/ (con tabs: audio, video, input, game), level_select_menu/
  windows/      → pause_menu, game_won_window, level_lost_window, level_won_window, credits windows
  loading_screen/ → loading_screen, level_loading_screen, loading_screen_with_shader_caching
  characters/   → Rael, Lena, Brom, Zari
  enemies/      → Enemy, Goblin, Slime, Troll, Mage, SkeletonArcher, Boss, BossGolem, BossPortal, BossFinal
  npcs/         → Echo
  projectiles/  → Arrow, EnemyArrow
  items/        → Coin
  credits/      → scrollable_credits, scrolling_credits, end_credits
/scripts/
  config.gd                     → Autoload: todas las constantes
  game_state.gd                 → Estado global de la partida (persiste entre escenas)
  level_state.gd                → Estado del nivel actual
  level_and_state_manager.gd    → Coordinación de nivel + estado (alternativa a level_manager)
  player/player.gd              → Movimiento 8 dirs, ataque melee, keywords
  characters/                   → brom.gd, lena.gd, zari.gd (IA autónoma)
  enemies/                      → enemy_base.gd + especializaciones
  systems/                      → wave_manager.gd, echo_api.gd, keyword_system.gd, economy.gd, upgrade_system.gd
  ui/                           → level_manager.gd, hud.gd, main_menu.gd, shop.gd, echo_shop.gd, game_over.gd, prologue_manager.gd
  projectiles/                  → arrow.gd, enemy_arrow.gd
  items/                        → coin.gd
  tools/                        → fill_floor.gd, fill_level1.gd (editor tools)
/assets/
  sprites/characters/rael/     → rotations/ (8 dirs) + animations/ (walk, attack, idle)
  sprites/characters/zari/     → rotations/ solo (sin animaciones)
  sprites/characters/lena/     → vacío (Polygon2D placeholder)
  sprites/characters/brom/     → vacío (Polygon2D placeholder)
  backgrounds/                 → ZIPs por nivel — extraer antes de usar
  audio/music/                 → boss.ogg, nivel.ogg (usados en level_manager)
```

**Nota sobre duplicación de escenas:** Existen dos estructuras paralelas — `scenes/levels/` (Level1.tscn etc., usada por `level_manager.gd`) y `scenes/game_scene/levels/` (level_1.tscn etc., del template). Confirmar cuál usa cada nivel antes de modificar.

---

## Assets disponibles

Todos los assets en `res://assets/`. Usar siempre ruta completa con `res://`.

### Fondos por nivel

| Nivel | Carpeta |
|-------|---------|
| Prólogo — Aula | `res://assets/backgrounds/school/` |
| Prólogo — Sótano | `res://assets/backgrounds/dark-lakes/` |
| Nivel 1 — Aldea | `res://assets/backgrounds/village/` |
| Nivel 2 — Ciudad | `res://assets/backgrounds/city/` |
| Nivel 3 — Dungeon | `res://assets/backgrounds/dungeon/` |
| Parallax general | `res://assets/backgrounds/parallax/` |

Los packs son ZIPs — extraer dentro de su carpeta correspondiente antes de referenciarlos.

### Sprites de Rael (92×92 px)

| Subcarpeta | Contenido |
|------------|-----------|
| `rotations/` | 8 sprites estáticos (S, SE, E, NE, N, NW, W, SW) |
| `animations/animation-75bd5ea5/` | Walk — 6 frames × dirs S, N, E |
| `animations/Walking-cf92d571/` | Walk — 6 frames × dir W |
| `animations/Cross_Punch-a4b41712/` | Ataque — 6 frames × dirs S, N, E, W |
| `animations/Fight_Stance_Idle-da976329/` | Idle — 8 frames × dir S |

### Reglas de assets

- Usar `preload()` al inicio del script, nunca strings sueltos en runtime.
- Audio solo en `.ogg`.
- Fondos: elegir variante **sin outline** cuando esté disponible.
- Parallax con `ParallaxBackground` + `ParallaxLayer`.

---

## Comandos

- **Correr el juego:** Godot 4 → F5 (escena principal: `scenes/opening/opening.tscn`)
- **Escena activa:** F6 en Godot corre la escena abierta
- **Exportar:** Godot → Proyecto → Exportar → Windows/Linux
- **Log de prompts:** registrar en `prompts_log.md` (requerido para expo)

---

## Sistema de Keywords

Echo siempre termina su respuesta con una keyword entre corchetes. `KeywordSystem` la aplica al jugador.

| Keyword     | Efecto | Implementación |
|-------------|--------|----------------|
| `[FUEGO]`   | Explosión en área cada 5to ataque | `_explosion_fuego()` en `player.gd` |
| `[SANGRE]`  | Cada golpe cura `KEYWORD_SANGRE_HEAL` HP | En hit loop de `player.gd` |
| `[ESCUDO]`  | +`KEYWORD_SHIELD_HP` escudo temporal | `escudo_restante` en `player.gd` |
| `[RAYO]`    | Cooldown × `KEYWORD_RAYO_COOLDOWN_MULT` | En `UpgradeSystem.get_cooldown()` — pendiente de integrar |
| `[VENENO]`  | DOT sobre enemigos golpeados | `aplicar_veneno()` en `enemy_base.gd` |
| `[HIELO]`   | Enemigos golpeados se ralentizan | `aplicar_hielo()` + `ralentizado` en `enemy_base.gd` |

Máximo `Config.MAX_KEYWORDS` (3) activas. Regex de extracción: `\[([A-Z]+)\]`.

---

## Estructura de niveles

| Nivel | Escenario | Jefe | Proxima escena |
|-------|-----------|------|----------------|
| 0 | Prólogo (Escuela) | — | Level1 |
| 1 | Aldea en ruinas | Boss (Goblin Cap.) | Level2 |
| 2 | Ciudad abandonada | BossGolem | Level3 |
| 3 | Dungeon | BossPortal | Level4 / Final |

---

## Reglas de código

- **SOLO GDScript.** Nunca C#.
- Scripts cortos y modulares. Una responsabilidad por script.
- Comentar cada función en **español**.
- Comunicación entre nodos exclusivamente por **señales**.
- Stats siempre en `Config` — nunca hardcodeados en scripts.
- Resolución fija: `Config.SCREEN_WIDTH` / `Config.SCREEN_HEIGHT`.
- Audio solo `.ogg`.

---

## Gotchas importantes

- `WaveManager` es nodo hijo de la escena, no autoload. Sus propiedades `contenedor_enemigos` y `puntos_spawn` se inyectan desde `level_manager._ready()`.
- `EchoAPI` arranca deshabilitado (`_api_habilitada = false`). Sin clave válida responde con fallback `[FUEGO]` — no crashea.
- La clave de API va en `user://api_key.txt`, **nunca** en el repositorio.
- `UpgradeSystem` NO se reinicia al cambiar de escena — sus bonos persisten entre niveles. Solo `UpgradeSystem.reiniciar()` los borra.
- Los enemigos llaman `call_deferred("queue_free")` al morir para evitar errores de physics. No llamar `queue_free()` directamente desde `recibir_dano()`.
- Los bosses tienen señal `boss_vida_cambiada(vida_actual, vida_max)` para la barra de HUD; conectar desde `level_manager._en_boss_spawneado()`.
- `aplicar_hielo()` usa `await get_tree().create_timer(3.0).timeout` — si el enemigo muere antes, puede generar errores si no se verifica `is_instance_valid(self)`.
- `prompts_log.md` debe actualizarse manualmente después de cada sesión.

---

## Checklist de entregables (expo 7/5/2026)

- [ ] Flujo completo: Menú → Prólogo → Nivel 1 → Nivel 2 → Nivel 3 → Final
- [ ] Echo funcional con Claude API en tiempo real
- [ ] Keywords activas visibles en HUD
- [ ] Game Over con stats (oleada, tiempo, kills)
- [ ] Finales A y B implementados
- [ ] `prompts_log.md` con evidencia de uso de IA
- [ ] `DEMO_CHECKLIST.md` con guía de 8 minutos para la presentación

---

## Equipo y roles

| Persona | Área principal |
|---------|---------------|
| Dev A   | Motor & Gameplay (movimiento, combate, oleadas, escenas) |
| Dev B   | IA & Backend (Claude API, sistema de keywords, Echo) |
| Dev C   | UI & Narrativa (menús, diálogos, tienda, guión) |

---

## Configuración del Studio (Claude Code Game Studios)

Este proyecto usa Claude Code Game Studios v0.3.0. Agentes y skills en `.claude/`.

### Agentes principales para este proyecto

- `godot-specialist` — decisiones de engine, escenas, nodos
- `godot-gdscript-specialist` — código GDScript, señales, autoloads
- `systems-designer` — WaveManager, KeywordSystem, EchoAPI
- `ui-programmer` — HUD, menús, Shop, EchoShop
- `narrative-director` — diálogos de Echo, guión
- `qa-tester` — bugs, edge cases, validación de keyword parsing

Usar **solo** el agente set de Godot 4. Los agentes de Unity y Unreal no aplican.

### Rutas para rules

| Rule | Ruta |
|------|------|
| gameplay | `scripts/player/`, `scripts/characters/`, `scripts/enemies/` |
| core/engine | `scripts/systems/` |
| ui | `scenes/ui/`, `scripts/ui/` |
| ai | `scripts/systems/echo_api.gd`, `scripts/systems/keyword_system.gd` |

### Lo que NO hacer

- No usar C# bajo ninguna circunstancia
- No hardcodear valores numéricos — siempre via `Config`
- No crear referencias directas entre nodos — solo señales
- No generar assets de audio en formatos distintos a `.ogg`
- No modificar `.tscn` existentes sin leer el estado actual primero
- No hacer `get_node()` a nodos de otra escena — usar grupos o señales
