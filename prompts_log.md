# Prompts Log — Echo Rush

Registro de uso de IA (requerido para expo 7/5).

---

## Sesión 2026-04-25 — Importación de sprites con Pixellab MCP

**Herramienta:** Pixellab MCP via Claude Code  
**Acción:** Descarga e importación de sprites de personajes al proyecto Godot

### Personajes descargados

| Personaje | ID Pixellab | Archivos |
|-----------|-------------|---------|
| Rael | `540ea6d4-f1d0-49d1-be5d-33d4a6b9e60f` | 8 rotaciones + 9 animaciones (walk, cross-punch, fight-stance-idle) |
| Zari | `0456ccff-756b-42b7-9141-8364be86642b` | 8 rotaciones |

### Especificaciones de sprites
- Canvas: 92×92 px
- Vista: low top-down
- Estilo: pixel art, thick black outline, basic shading, medium detail
- Direcciones: 8 (S, SE, E, NE, N, NW, W, SW)

### Estructura generada
```
assets/sprites/characters/
  rael/
    rotations/         ← 8 PNGs de dirección
    animations/        ← walk (N/S/E/W), cross-punch (N/S/E/W), fight-stance-idle (S)
    metadata.json
  zari/
    rotations/         ← 8 PNGs de dirección
    metadata.json
  lena/                ← pendiente sprite final
  brom/                ← pendiente sprite final

scenes/characters/
  Rael.tscn            ← CharacterBody2D + AnimatedSprite2D (sprites a conectar en editor)
  Zari.tscn            ← CharacterBody2D + AnimatedSprite2D (sprites a conectar en editor)
  Lena.tscn            ← Placeholder azul (Polygon2D)
  Brom.tscn            ← Placeholder verde (Polygon2D)
```

### Próximos pasos con Pixellab
- Descargar Lena (`e4d0bf23-cee7-41b1-b13f-203f7bcfff7f`) cuando esté lista
- Descargar Brom (`b5394951-d8ca-4073-9a5f-649219bd2e0e`) cuando esté listo
- Conectar `SpriteFrames` en los nodos `AnimatedSprite2D` de cada escena
