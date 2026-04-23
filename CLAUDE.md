# Echo Rush

Shooter roguelite top-down en 2D con 4 personajes estudiantiles.
Motor: **Godot 4** | Lenguaje: **GDScript únicamente** | Integración: **Claude API**

---

## Descripción del juego

Cuatro estudiantes caen a un mundo paralelo a través de un portal y deben
sobrevivir oleadas de monstruos. Entre oleadas aparece **Echo**, un mercader
misterioso cuyos diálogos se generan con Claude API. El jugador escribe en
lenguaje libre y Echo responde con keywords que activan habilidades reales.

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
  levels/       → Level1, Level2, Level3, PrologueScene, InfiniteMode
  ui/           → HUD, GameOver, EchoShop, FinalChoice, MainMenu
  characters/   → Player (Rael), Lena, Brom, Zari
  enemies/      → Enemy (base), GoblinCaptain, GolemGuardian, PortalGuardian
/scripts/
  player/       → movimiento, ataque, stats de Rael
  enemies/      → IA básica de enemigos
  ui/           → lógica de pantallas
  systems/      → WaveManager, EchoAPI, KeywordSystem, DialogueSystem
/assets/
  sprites/      → personajes, enemigos, fondos
  audio/        → música y efectos
  fonts/        → tipografías del juego
```

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

- Modelo: `claude-sonnet-4-20250514`
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
- Los compañeros autónomos (Lena, Brom, Zari) usan NavigationAgent2D — requiere NavigationRegion2D en cada nivel.
- `EchoShop` solo aparece cuando `WaveManager` emite la señal `wave_completed` y el número de oleada es múltiplo de 5.
- La keyword se extrae con regex del **final** de la respuesta de Echo. Si no hay keyword, mostrar mensaje de error en UI sin crashear.
- El prólogo es solo texto + sprites estáticos. No tiene combate ni física activa.
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
