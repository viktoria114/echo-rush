# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# Echo Rush

Shooter roguelite top-down en 2D con 4 personajes estudiantiles.
Motor: **Godot 4.6.2** | Lenguaje: **GDScript únicamente** | Integración: **Claude API**
Studio: **Claude Code Game Studios v0.3.0**
Stage: **En desarrollo activo** (ver Estado actual)

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

## Estado actual del proyecto (2026-04-25)

**Existe:**
- Escenas de personajes: `scenes/characters/Rael.tscn`, `Lena.tscn`, `Brom.tscn`, `Zari.tscn`
- Sprites de Rael completos: rotaciones (8 dir) + animaciones walk/punch/idle en `assets/sprites/characters/rael/`
- Sprites de Zari: solo rotaciones (8 dir) en `assets/sprites/characters/zari/` — sin animaciones aún
- Packs de fondos: descargados como ZIP en `assets/backgrounds/` — **no extraídos todavía**

**Pendiente (no existe código aún):**
- Toda la carpeta `/scripts/` (player, enemies, ui, systems)
- Escenas de niveles, UI, menús, enemigos
- `config.gd` (debe crearse antes de cualquier script que lo use)
- Audio, fuentes, sprites de Lena/Brom/enemies/ui

---

## Personajes

| Personaje | Rol       | Control     |
|-----------|-----------|-------------|
| Rael      | Atacante  | Jugador (WASD + Z / click izquierdo) |
| Lena      | Maga      | Autónoma — ataca a distancia |
| Brom      | Tanque    | Autónomo — se interpone entre jugador y enemigos |
| Zari      | Arquera   | Autónoma — flanquea enemigos |

---

## Estructura del proyecto

```
/scenes/
  levels/       → Level1, Level2, Level3, PrologueScene, InfiniteMode  [PENDIENTE]
  ui/           → HUD, GameOver, EchoShop, FinalChoice, MainMenu        [PENDIENTE]
  characters/   → Rael.tscn, Lena.tscn, Brom.tscn, Zari.tscn          [EXISTE]
  enemies/      → Enemy (base), GoblinCaptain, GolemGuardian, PortalGuardian [PENDIENTE]
/scripts/       → [PENDIENTE — crear esta carpeta con los primeros scripts]
  player/       → movimiento, ataque, stats de Rael
  enemies/      → IA básica de enemigos
  ui/           → lógica de pantallas
  systems/      → WaveManager, EchoAPI, KeywordSystem, DialogueSystem
/assets/
  sprites/characters/rael/     → rotaciones/ + animations/  [COMPLETO]
  sprites/characters/zari/     → rotaciones/ solo           [PARCIAL]
  sprites/characters/lena/     → vacío                      [PENDIENTE]
  sprites/characters/brom/     → vacío                      [PENDIENTE]
  backgrounds/                 → ZIPs descargados, sin extraer
  audio/music/ audio/sfx/      → vacíos
  fonts/                       → vacío
```

---

## Assets disponibles

Todos los assets están en `res://assets/`. Cuando uses un asset en una escena,
**siempre referenciá la ruta completa** con `res://` para que Godot la resuelva.

### Fondos por nivel

| Nivel | Carpeta | Pack |
|-------|---------|------|
| Prólogo — Aula | `res://assets/backgrounds/school/` | 2dClassroomAssetPackByStyloo |
| Prólogo — Sótano | `res://assets/backgrounds/dark-lakes/` | dark-lakes |
| Nivel 1 — Aldea | `res://assets/backgrounds/village/` | 2dvillageassetpackwithoutline |
| Nivel 2 — Ciudad | `res://assets/backgrounds/city/` | 2dcitywithoutoutline |
| Nivel 3 — Dungeon | `res://assets/backgrounds/dungeon/` | 2ddungeonassetpackwithoutline |
| Parallax general | `res://assets/backgrounds/parallax/` | RiverParallaxBackground + Forest&&Moon |

> Los packs de fondos son archivos ZIP. Extraerlos dentro de su carpeta correspondiente antes de referenciarlos en escenas.

### Sprites de Rael (92×92 px, Pixellab)

Organizados en `res://assets/sprites/characters/rael/`:

| Subcarpeta | Contenido |
|------------|-----------|
| `rotations/` | 8 sprites estáticos (S, SE, E, NE, N, NW, W, SW) |
| `animations/animation-75bd5ea5/` | Walk — 6 frames × 3 dirs (S, N, E) |
| `animations/Walking-cf92d571/` | Walk — 6 frames × dir W |
| `animations/Cross_Punch-a4b41712/` | Ataque — 6 frames × 4 dirs (S, N, E, W) |
| `animations/Fight_Stance_Idle-da976329/` | Idle — 8 frames × dir S |

Al configurar `AnimatedSprite2D` para Rael, combinar los frames de estas carpetas por dirección.

### Sprites de Zari (92×92 px, Pixellab)

Solo rotaciones en `res://assets/sprites/characters/zari/rotations/` (8 direcciones).
Animaciones de Zari aún no descargadas.

### Sprites de Lena y Brom (pendientes)

Generados con Pixellab. IDs para descargar cuando estén listos:
- **Lena:** `e4d0bf23-cee7-41b1-b13f-203f7bcfff7f`
- **Brom:** `b5394951-d8ca-4073-9a5f-649219bd2e0e`

Usar placeholder `Polygon2D` (Lena = azul, Brom = verde) hasta que los sprites estén disponibles.

### Reglas de uso de assets

- Nunca hardcodear rutas de assets como strings sueltos. Usar `preload()` al inicio del script.
- Ejemplo: `const SPRITE_RAEL = preload("res://assets/sprites/characters/rael/rotations/south.png")`
- Si un asset del pack tiene múltiples variantes, elegir la versión **sin outline** cuando esté disponible.
- Audio solo en formato `.ogg`. Si un efecto viene en otro formato, convertirlo antes de importar.
- Los fondos de parallax se implementan con nodos `ParallaxBackground` + `ParallaxLayer` de Godot.

---

## Comandos

- **Correr el juego:** abrir Godot 4 → F5 (o botón Play desde `MainMenu.tscn`)
- **Escena activa:** Godot → F6 corre la escena abierta
- **Exportar:** Godot → Proyecto → Exportar → Windows/Linux
- **Log de prompts:** guardar cada prompt usado en `prompts_log.md` (requerido para expo)

---

## Sistema de Keywords (Echo → Godot)

Echo siempre termina su respuesta con una keyword entre corchetes.
`KeywordSystem.gd` las parsea y aplica el efecto al jugador.

| Keyword     | Efecto |
|-------------|--------|
| `[FUEGO]`   | Explosión en área cada 5to ataque |
| `[SANGRE]`  | Cada golpe cura 5 HP |
| `[ESCUDO]`  | +30 HP de escudo temporal por oleada |
| `[RAYO]`    | Cooldown de ataque reducido a la mitad |
| `[VENENO]`  | Ataques aplican daño por tiempo |
| `[HIELO]`   | Enemigos cercanos se ralentizan al recibir daño |

Máximo 3 keywords activas simultáneamente. Mostrar en HUD.

---

## Claude API — Echo

- Modelo: `claude-sonnet-4-6`
- La llamada se hace desde `EchoAPI.gd` via `HTTPRequest` de Godot
- El system prompt define la personalidad de Echo y las keywords disponibles
- Parsear la keyword con regex: buscar patrón `\[([A-Z]+)\]` al final de la respuesta
- Emitir señal con texto de Echo + keyword detectada hacia `KeywordSystem.gd`

---

## Estructura de niveles

| Nivel | Escenario       | Jefe              | Desbloquea Echo |
|-------|-----------------|-------------------|-----------------|
| 0     | Prólogo (Escuela) | —               | No |
| 1     | Aldea en ruinas | Goblin Capitán    | Sí (cada 5 oleadas) |
| 2     | Ciudad abandonada | Golem Guardián  | Sí (cada 5 oleadas) |
| 3     | Dungeon         | Guardián del Portal | Sí (cada 5 oleadas) |
| —     | Modo Infinito   | —                 | Sí (cada 10 oleadas) |

---

## Reglas de código

- **SOLO GDScript.** Nunca C#.
- Scripts cortos y modulares. Una responsabilidad por script.
- Comentar cada función en **español**.
- Comunicación entre nodos exclusivamente por **señales** (no referencias directas).
- Stats siempre en `config.gd` — nunca hardcodeados en los scripts.
- Resolución fija: usar `config.SCREEN_WIDTH` y `config.SCREEN_HEIGHT`.
- Assets de audio: solo formato `.ogg`.

---

## Gotchas importantes

- El loop de oleadas vive en `WaveManager.gd`. No duplicar lógica de oleadas en los niveles.
- Los compañeros autónomos (Lena, Brom, Zari) usan `NavigationAgent2D` — requiere `NavigationRegion2D` en cada nivel.
- `EchoShop` solo aparece cuando `WaveManager` emite la señal `wave_completed` y el número de oleada es múltiplo de 5.
- La keyword se extrae con regex del **final** de la respuesta de Echo. Si no hay keyword, mostrar mensaje de error en UI sin crashear.
- El prólogo es solo texto + sprites estáticos. No tiene combate ni física activa.
- `config.gd` debe existir como Autoload antes de que cualquier otro script lo referencie.
- `prompts_log.md` debe actualizarse manualmente después de cada sesión de trabajo con Claude Code.

---

## Equipo y roles

| Persona | Área principal |
|---------|---------------|
| Dev A   | Motor & Gameplay (movimiento, combate, oleadas, escenas) |
| Dev B   | IA & Backend (Claude API, sistema de keywords, Echo) |
| Dev C   | UI & Narrativa (menús, diálogos, tienda, guión) |

---

## Checklist de entregables (expo 7/5)

- [ ] Flujo completo: Menú → Prólogo → Nivel 1 → Nivel 2 → Nivel 3 → Final
- [ ] Echo funcional con Claude API en tiempo real
- [ ] Keywords activas visibles en HUD
- [ ] Game Over con stats (oleada, tiempo, kills)
- [ ] Finales A y B implementados
- [ ] `prompts_log.md` con evidencia de uso de IA
- [ ] `DEMO_CHECKLIST.md` con guía de 8 minutos para la presentación


## Configuración del Studio (Claude Code Game Studios)

Este proyecto usa el framework Claude Code Game Studios.
Los agentes y skills están en `.claude/`.

### Rutas del proyecto (para agentes y rules)

Las rules en `.claude/rules/` aplican a estas rutas:

| Rule | Ruta en este proyecto |
|------|-----------------------|
| gameplay | `scenes/` y `scripts/player/`, `scripts/enemies/` |
| core/engine | `scripts/systems/` |
| ui | `scenes/ui/` y `scripts/ui/` |
| ai | `scripts/systems/EchoAPI.gd`, `scripts/systems/KeywordSystem.gd` |
| design/gdd | `design/` |
| tests | (no hay tests aún — pendiente) |
| prototypes | `prototypes/` |

### Motor y agentes activos

Usar **solo** el agente set de Godot 4. Los agentes de Unity y Unreal no aplican a este proyecto.

Agentes principales para este proyecto:
- `godot-specialist` — decisiones de engine, escenas, nodos
- `gdscript-programmer` — código GDScript, señales, autoloads
- `systems-designer` — WaveManager, KeywordSystem, EchoAPI
- `ui-programmer` — HUD, menús, EchoShop
- `narrative-director` — diálogos de Echo, guión
- `qa-tester` — bugs, edge cases, validación de keyword parsing

### Convenciones adicionales para agentes

- Los scripts de GDScript van siempre en `scripts/` con subcarpeta por dominio
- `config.gd` es Autoload — debe cargarse antes que cualquier otro script
- Las señales son el único mecanismo de comunicación entre nodos (sin referencias directas)
- Comentarios de funciones en **español**
- El modelo de Claude API a usar en `EchoAPI.gd` es `claude-sonnet-4-6`

## Contexto para el studio

### Deadline
Expo: **7 de mayo de 2026**. Flujo mínimo funcional: Menú → Prólogo → Nivel 1 → Nivel 2 → Nivel 3 → Final.

### Prioridad de desarrollo

1. `config.gd` (Autoload) — base de todo
2. Movimiento y ataque de Rael
3. Sistema de oleadas (`WaveManager.gd`)
4. Echo + Claude API (`EchoAPI.gd`, `KeywordSystem.gd`)
5. HUD con keywords activas
6. Enemigos, jefes, UI restante

### Lo que NO hacer (para agentes)

- No usar C# bajo ninguna circunstancia
- No hardcodear valores numéricos en scripts — siempre via `config.gd`
- No crear referencias directas entre nodos — solo señales
- No generar assets de audio en formatos distintos a `.ogg`
- No modificar archivos `.tscn` existentes en `scenes/characters/` sin revisar el estado actual primero

### Estado de assets al inicio de sesión

Antes de trabajar con sprites o fondos, verificar:
- Los ZIPs de fondos en `assets/backgrounds/` pueden no estar extraídos
- Zari solo tiene rotaciones, sin animaciones
- Lena y Brom usan `Polygon2D` como placeholder (azul y verde respectivamente)
- Rael es el único personaje con sprites y animaciones completas