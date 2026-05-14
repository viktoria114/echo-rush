@tool
extends TileMapLayer

## Herramienta de editor: rellena el suelo del nivel con tiles de Floors_Tiles.png.
## USO:
##   1. Adjuntá este script al nodo TileMapLayer dentro de Fondo en el editor.
##   2. En el Inspector, hacé clic en "Fill Floor" (aparece como exportación).
##   3. El suelo se pinta y guardás la escena (Ctrl+S).
##   4. Quitá este script del nodo (reemplazalo con null o borralo del Inspector).

## Coordenada de atlas para el tile de suelo sólido.
## Ajustá según lo que veas en Godot editor al abrir Floors_Tiles.png en el TileSet.
@export var atlas_coord: Vector2i = Vector2i(6, 1)

## ID del atlas source dentro del TileSet (siempre 0 si hay un solo source).
@export var source_id: int = 0

## Area a rellenar en tiles. El nivel es ~3072x3072 px a 16px/tile = 192x192 tiles.
## El jugador empieza en pixel (1536,1536) = tile (96,96).
## Spawn points en pixel ~(150,150) a (2920,2920) = tiles (9,9) a (182,182).
@export var area_inicio: Vector2i = Vector2i(0, 0)
@export var area_fin: Vector2i = Vector2i(191, 191)

@export var fill_floor: bool = false:
	set(value):
		if value and Engine.is_editor_hint():
			_rellenar_suelo()
			fill_floor = false

@export var clear_floor: bool = false:
	set(value):
		if value and Engine.is_editor_hint():
			clear()
			print("[fill_floor] Suelo limpiado.")
			clear_floor = false

## Rellena el área con el tile seleccionado.
func _rellenar_suelo() -> void:
	if not tile_set:
		push_error("[fill_floor] No hay TileSet asignado al TileMapLayer.")
		return

	var total := 0
	for x in range(area_inicio.x, area_fin.x + 1):
		for y in range(area_inicio.y, area_fin.y + 1):
			set_cell(Vector2i(x, y), source_id, atlas_coord)
			total += 1

	print("[fill_floor] Suelo pintado: %d tiles (%dx%d) con atlas_coord=%s source=%d" % [
		total,
		area_fin.x - area_inicio.x + 1,
		area_fin.y - area_inicio.y + 1,
		atlas_coord,
		source_id
	])
