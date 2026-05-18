# Echo Rush

> **Shooter roguelite top-down 2D** — Cuatro estudiantes atrapados en un mundo paralelo deben sobrevivir oleadas de monstruos con la ayuda (o el precio) de un mercader misterioso impulsado por IA.

![Godot](https://img.shields.io/badge/Godot-4.6.2-478CBF?logo=godotengine&logoColor=white)
![GDScript](https://img.shields.io/badge/Lenguaje-GDScript-478CBF)
![Claude API](https://img.shields.io/badge/IA-Claude%20Sonnet%204.6-blueviolet?logo=anthropic)
![Plataforma](https://img.shields.io/badge/Plataforma-Windows%20%7C%20Linux-lightgrey)
![Estado](https://img.shields.io/badge/Estado-En%20desarrollo-yellow)

---

## Concepto

Un portal interdimensional absorbe a cuatro estudiantes y los lanza a un mundo paralelo invadido por monstruos. Entre oleadas aparece **Echo**, un mercader enigmático cuya sabiduría — o maldición — se genera en tiempo real con la **API de Claude**. El jugador escribe en lenguaje libre; Echo responde con frases crípticas que terminan en una **keyword** que activa poderes reales en combate.

---

## Características principales

| Feature | Detalle |
|---|---|
| Combate top-down | Movimiento en 8 direcciones, ataque melee y proyectiles |
| Sistema de oleadas | Escalado progresivo; última oleada de cada nivel invoca un Boss |
| Sistema de Keywords | Hasta 3 poderes activos simultáneos obtenidos vía Echo |
| Tienda entre oleadas | Mejoras permanentes de daño, velocidad, HP y cadencia |
| IA generativa | Echo responde usando Claude Sonnet 4.6 en tiempo real |
| Compañeros autónomos | 3 aliados con comportamiento propio sin NavigationAgent2D |
| Progresión persistente | Los upgrades sobreviven el cambio de escena vía `UpgradeSystem` |
| Pantalla de opciones | Video, audio, input y controles remapeable (Maaack's template) |

---

## Personajes

### Jugador

| Personaje | Rol | Control |
|---|---|---|
| **Rael** | Atacante cuerpo a cuerpo | Jugador — Flechas + Z / clic izquierdo |

### Compañeros autónomos

| Personaje | Rol | Comportamiento |
|---|---|---|
| **Lena** | Maga | Ataca a distancia con proyectiles mágicos |
| **Brom** | Tanque | Intercepta enemigos que se acercan al jugador |
| **Zari** | Arquera | Dispara flechas a distancia con rotación en 8 dirs |

---

## Sistema de Keywords

Echo siempre termina su respuesta con una keyword entre corchetes. `KeywordSystem` la aplica automáticamente al jugador. Máximo **3 keywords activas** simultáneas.

| Keyword | Efecto en combate |
|---|---|
| `[FUEGO]` | Explosión en área cada 5.º ataque |
| `[SANGRE]` | Cada golpe cura al jugador |
| `[ESCUDO]` | Escudo temporal de HP adicional |
| `[RAYO]` | Reduce el cooldown de ataque |
| `[VENENO]` | Aplica daño por segundo a los enemigos golpeados |
| `[HIELO]` | Ralentiza a los enemigos golpeados durante 3 segundos |

---

## Estructura de niveles

```
Prólogo  →  Nivel 1  →  Nivel 2  →  Nivel 3  →  Final
(Escuela)   (Aldea)     (Ciudad)    (Dungeon)
```

| Nivel | Escenario | Jefe |
|---|---|---|
| Prólogo | Escuela / Sótano | — |
| Nivel 1 | Aldea en ruinas | Boss Goblin Cap. |
| Nivel 2 | Ciudad abandonada | Boss Golem |
| Nivel 3 | Dungeon | Boss Portal |
| Nivel 4 | Final | Boss Final |

Cada nivel termina con una tienda de upgrades. Echo aparece según el diseño narrativo de cada nivel.

---

## Arquitectura de sistemas

```
AutoLoads (Singletons)
├── Config              → todas las constantes del juego
├── Economy             → monedas; señal monedas_cambiadas
├── KeywordSystem       → lista canónica de keywords activas
├── EchoAPI             → llamadas a Claude API
├── UpgradeSystem       → bonos de stats entre niveles
├── SceneLoader         → transiciones con pantalla de carga animada
├── ProjectMusicController → música persistente entre escenas
└── ProjectUISoundController → sonidos de UI

Nodos por escena
└── LevelManager (raíz del nivel)
    ├── WaveManager     → spawn y conteo de oleadas
    ├── HUD             → vida, monedas, keywords, barra de boss
    └── Jugador         → Rael (CharacterBody2D)
```

---

## Enemigos

```
enemy_base.gd
├── goblin.gd
├── slime.gd
├── troll.gd
├── mage.gd          ← dispara bolas de fuego
├── skeleton_archer.gd
└── boss.gd
    ├── boss_golem.gd
    ├── boss_portal.gd
    └── boss_final.gd
```

---

## Requisitos

| Requisito | Versión / Detalle |
|---|---|
| [Godot Engine](https://godotengine.org/download) | **4.6.2** (obligatorio — no compatible con versiones anteriores) |
| Sistema operativo | Windows 10/11 o Linux |
| RAM | 4 GB mínimo |
| API key de Anthropic | Opcional — solo para activar los diálogos de Echo en tiempo real |

> Sin API key, Echo responde con un fallback local (`[FUEGO]`) para no interrumpir el juego.

---

## Instalación y ejecución

### 1. Clonar el repositorio

```bash
git clone https://github.com/Spawn070/echo-rush.git
cd echo-rush
```

### 2. Abrir en Godot 4.6.2

1. Abre **Godot 4.6.2**
2. Click en **Importar proyecto**
3. Selecciona la carpeta `echo-rush/`
4. Espera a que Godot importe todos los assets (primera vez puede tardar ~30 segundos)

### 3. Ejecutar

- **F5** — corre el juego desde la escena principal (`scenes/opening/opening.tscn`)
- **F6** — corre la escena que tengas abierta en el editor

---

## Activar Echo con Claude API (opcional)

Por defecto `EchoAPI` está deshabilitado. Para activar los diálogos generativos:

**Opción A — archivo persistente (recomendado):**
```
# Crear el archivo en la carpeta de datos de usuario de Godot:
# Windows: %APPDATA%\Godot\app_userdata\echo-rush\api_key.txt
# Linux:   ~/.local/share/godot/app_userdata/echo-rush/api_key.txt

# Contenido del archivo:
sk-ant-XXXXXXXXXXXXXXXXX
```

**Opción B — en runtime desde el editor:**
```gdscript
EchoAPI.configurar_api_key("sk-ant-XXXXXXXXXXXXXXXXX")
```

> La clave **nunca** debe commitearse al repositorio. El archivo `api_key.txt` está en `user://` (fuera del proyecto).

---

## Controles

| Acción | Teclado | Alternativa |
|---|---|---|
| Moverse | `WASD` | Flechas direccionales |
| Atacar | `Z` | Clic izquierdo |
| Pausa | `Escape` | — |
| Interactuar con Echo | Campo de texto libre | — |

Los controles son **remapeables** desde el menú de opciones → pestaña Input.

---

## Estructura del proyecto

```
echo-rush/
├── scenes/
│   ├── opening/          # Escena de arranque
│   ├── levels/           # Level1–Level4, PrologueScene
│   ├── characters/       # Rael, Lena, Brom, Zari
│   ├── enemies/          # Enemy, Goblin, Slime, Troll, Mage, Boss…
│   ├── ui/               # HUD, GameOver, Shop, EchoShop, MainMenu
│   ├── menus/            # MainMenu con animaciones, OptionsMenu, LevelSelect
│   ├── windows/          # PauseMenu, GameWon, LevelLost, Credits
│   ├── npcs/             # Echo
│   ├── projectiles/      # Arrow, EnemyArrow, FireballEnemy
│   └── items/            # Coin
│
├── scripts/
│   ├── config.gd                  # Autoload — todas las constantes
│   ├── player/player.gd           # Movimiento, combate, keywords
│   ├── characters/                # brom.gd, lena.gd, zari.gd
│   ├── enemies/                   # enemy_base.gd + especializaciones
│   ├── systems/
│   │   ├── wave_manager.gd        # Spawn y conteo de oleadas
│   │   ├── echo_api.gd            # Claude API integration
│   │   ├── keyword_system.gd      # Keywords activas
│   │   ├── economy.gd             # Monedas del jugador
│   │   └── upgrade_system.gd      # Bonos persistentes
│   └── ui/
│       ├── level_manager.gd       # Coordinación del nivel
│       ├── hud.gd
│       ├── shop.gd
│       ├── echo_shop.gd
│       └── game_over.gd
│
├── assets/
│   ├── sprites/characters/rael/   # 8 dirs × walk, attack, idle
│   ├── backgrounds/               # Village, city, dungeon, school…
│   └── audio/
│       ├── music/                 # menu.ogg, nivel.ogg, boss.ogg
│       └── sfx/                   # golpe, recibirGolpe, bossMuerte…
│
└── addons/
    └── maaacks_game_template/     # SceneLoader, MusicController, UI base
```

---

## Audio

| Categoría | Archivos |
|---|---|
| Música | `menu.ogg` · `nivel.ogg` · `boss.ogg` |
| SFX combate | `golpe.ogg` · `recibirGolpe.ogg` · `personajeMuerte.ogg` |
| SFX enemigos | `goblinMuerte.ogg` · `slimeMuerte.ogg` · `trollMuerte.ogg` · `magoMuerte.ogg` · `esqueletoMuerte.ogg` · `bossMuerte.ogg` |
| SFX UI | `clickBoton.ogg` · `hoverBoton.ogg` · `recogerMoneda.ogg` · `GameOver.ogg` |

---

## Estado del desarrollo

- [x] Flujo completo de escenas: Menú → Prólogo → Nivel 1 → 2 → 3 → Game Over
- [x] Sistema de oleadas con escalado y bosses
- [x] Keywords activas con efectos en combate
- [x] Tienda de upgrades permanentes
- [x] EchoShop con integración a Claude API
- [x] HUD (vida, monedas, keywords, barra de boss)
- [x] Sistema de audio completo (música + SFX)
- [x] Fade y transición animada al Game Over
- [x] Menú de opciones (video, audio, input)
- [x] Sprites de Lena y Brom (actualmente Polygon2D placeholder)
- [x] Animaciones completas de Zari
- [ ] Modo Infinito
- [ ] Finales A y B
- [ ] Pantalla de stats en Game Over (oleada, tiempo, kills)

---

## Equipo

| Persona | Área |
|---|---|
| Dev A | Motor & Gameplay — movimiento, combate, oleadas |
| Dev B | IA & Backend — Claude API, keyword system, Echo |
| Dev C | UI & Narrativa — menús, diálogos, tienda, guión |

---

## Tecnología

| Capa | Tecnología |
|---|---|
| Engine | Godot 4.6.2 |
| Lenguaje | GDScript (100%) |
| IA generativa | Claude Sonnet 4.6 (Anthropic API) |
| UI base | Maaack's Game Template |
| Build | Godot Export Templates (Windows / Linux) |
| Assets 2D | Sprites 92×92 px, fondos tileset |
| Audio | OGG Vorbis |

---

## Licencia

Proyecto académico — uso educativo y de exposición.
Assets de terceros bajo sus respectivas licencias (ver carpeta `addons/`).
