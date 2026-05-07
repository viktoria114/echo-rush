# Prompts Log — Echo Rush

Registro de uso de IA (requerido para expo 7/5).

---

## Sesión 2026-04-25 — Importación de sprites con Pixellab MCP (v1)

**Herramienta:** Pixellab MCP via Claude Code  
**Acción:** Descarga inicial de Rael y Zari

| Personaje | Animaciones | Estado |
|-----------|------------|--------|
| Rael | 9 (walk, cross-punch, fight-stance-idle) | ✓ Importado |
| Zari | 0 (solo rotaciones) | ✓ Importado |
| Lena | Placeholder azul | ✓ Placeholder |
| Brom | Placeholder verde | ✓ Placeholder |

---

## Sesión 2026-05-01 — Actualización completa de sprites (v2)

**Herramienta:** Pixellab MCP via Claude Code  
**Acción:** Descarga de sprites actualizados + Goblin enemigo

### Personajes/Enemigos descargados

| Nombre | ID Pixellab | Canvas | Animaciones | Notas |
|--------|-------------|--------|-------------|-------|
| **Rael** (actualizado) | `540ea6d4-f1d0-49d1-be5d-33d4a6b9e60f` | 92×92 | 16: Running (8 dirs), Baseball bat swing (8 dirs) | Reemplaza v1 |
| **Zari** (actualizado) | `0456ccff-756b-42b7-9141-8364be86642b` | 92×92 | 16: Running (8 dirs), Fluid archery attack (8 dirs) | Ahora con animaciones |
| **Lena** (nuevo) | `e4d0bf23-cee7-41b1-b13f-203f7bcfff7f` | 92×92 | 16: Running (8 dirs), Magical ranged attack (8 dirs) | Reemplaza placeholder |
| **Brom** (nuevo) | `b5394951-d8ca-4073-9a5f-649219bd2e0e` | 92×92 | 16: Running (8 dirs), Shield stance/lunge (8 dirs) | Reemplaza placeholder |
| **Goblin** (enemigo) | `a597dd17-7dbf-4fdc-8ad9-7cee34408472` | 92×92 | 18: Running (8 dirs), Frantic lunging attack (8 dirs) | Primer enemigo |

### Especificaciones uniformes
- Canvas: 92×92 px
- Vista: low top-down
- Estilo: pixel art, thick black outline, basic shading, medium detail
- Direcciones: 8 (S, SE, E, NE, N, NW, W, SW)

### Archivos importados

```
assets/sprites/characters/
  rael/
    rotations/             ← 8 PNGs
    animations/
      Running-eefd6131/    ← 8 dirs, 8 frames cada uno
      Baseball_bat_swing.../← 8 dirs, 8-9 frames cada uno
    metadata.json
  
  zari/
    rotations/             ← 8 PNGs
    animations/
      Running-6f6d8126/    ← 8 dirs, 8 frames
      Fluid_archery_attack/← 8 dirs, 8 frames
    metadata.json
  
  lena/
    rotations/             ← 8 PNGs
    animations/
      Running-f8408c7a/    ← 8 dirs, 8 frames
      Magical_ranged_attack/← 8 dirs, 8-9 frames
    metadata.json
  
  brom/
    rotations/             ← 8 PNGs
    animations/
      Running-05877101/    ← 8 dirs, 8 frames
      The_character_plants_their_feet.../← 8 dirs, 8 frames
    metadata.json
  
  goblin/
    rotations/             ← 8 PNGs
    animations/
      Running-de01345a/    ← 8 dirs, 8 frames
      Frantic_lunging_attack/← 8 dirs, 8 frames
    metadata.json

scenes/characters/
  Rael.tscn              ← CharacterBody2D + AnimatedSprite2D (actualizado)
  Zari.tscn              ← CharacterBody2D + AnimatedSprite2D (actualizado)
  Lena.tscn              ← CharacterBody2D + AnimatedSprite2D (reemplaza placeholder)
  Brom.tscn              ← CharacterBody2D + AnimatedSprite2D (reemplaza placeholder)

scenes/enemies/
  Goblin.tscn            ← CharacterBody2D + AnimatedSprite2D (nuevo)
```

---

## Sesión 2026-05-01 (continuación) — Echo NPC + Slime Enemy

**Archivos subidos manualmente (no desde Pixellab):**

### Echo — Mercader misterioso (NPC)

Tres variantes de imagen estática de Echo:
- `echo-merchant.png` — Versión principal
- `echo-dark-cloak.png` — Capa oscura (alternativa)
- `echo-floating-cloak.png` — Capa flotante (alternativa)

**Ubicación:** `assets/sprites/npcs/echo/`  
**Escena:** `scenes/npcs/Echo.tscn` (Node2D + Sprite2D)

### Slime — Enemigo gelatinoso (ENEMY)

- **Canvas:** 92×92 px
- **Animaciones:** 1 — Attack bounce (8 dirs, 16 frames cada uno)
- **Rotaciones:** 8 (S, SE, E, NE, N, NW, W, SW)

**Ubicación:** `assets/sprites/characters/slime/`  
**Escena:** `scenes/enemies/Slime.tscn` (CharacterBody2D + AnimatedSprite2D)

### Estructura actualizada

```
assets/sprites/
  characters/        → Rael, Zari, Lena, Brom, Goblin, Slime
  npcs/echo/         → echo-merchant.png, echo-dark-cloak.png, echo-floating-cloak.png

scenes/
  characters/        → Rael, Zari, Lena, Brom
  enemies/           → Goblin, Slime
  npcs/              → Echo
```

### Próximos pasos

1. **Conectar SpriteFrames en Godot editor** para cada personaje/enemigo (importación automática de PNGs)
2. **Conectar imagen de Echo** en el Sprite2D de `scenes/npcs/Echo.tscn` (elegir cuál de las 3)
3. **Crear scripts** para comportamiento de personajes (movimiento, IA, ataque)
4. **Sistema de diálogo Claude API** para interacción con Echo

### Archivos de log/documentación actualizados
- ✓ `prompts_log.md` (este archivo)
- ✓ `scenes/enemies/` (carpeta de enemigos)
- ✓ `scenes/npcs/` (nueva carpeta de NPCs)
- ✓ `assets/sprites/npcs/` (nueva carpeta de NPCs)
