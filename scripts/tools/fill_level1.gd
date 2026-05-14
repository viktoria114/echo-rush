@tool
extends Node

## Pinta las 3 capas del Nivel 1 con la distribución de aldea en ruinas.
## USO:
##   1. Adjuntá este script al nodo Fondo en el editor (Inspector → script).
##   2. Ajustá coord_pasto / coord_piedra / coord_tierra si los tiles se ven mal.
##   3. Hacé clic en "Fill Level" en el Inspector.
##   4. Guardá la escena (Ctrl+S) y quitá el script de Fondo.

## Tile sólido de pasto — centro del rango (0,0)-(4,11).
## Cambiá si el tile que aparece no es pasto sólido sin bordes.
@export var coord_pasto: Vector2i = Vector2i(2, 5)

## Tile sólido de piedra/camino — centro del rango (5,0)-(9,11).
@export var coord_piedra: Vector2i = Vector2i(7, 5)

## Tile sólido de tierra — centro del rango (10,0)-(14,11).
@export var coord_tierra: Vector2i = Vector2i(12, 5)

## ID del atlas source (0 si hay un solo source en el TileSet).
@export var source_id: int = 0

## Tamaño del nivel en tiles (96×96 = 1536×1536 px a 16 px/tile).
@export var tamanio_nivel: Vector2i = Vector2i(96, 96)

@export var fill_level: bool = false:
	set(value):
		if value and Engine.is_editor_hint():
			_pintar_nivel()
			fill_level = false

@export var clear_all: bool = false:
	set(value):
		if value and Engine.is_editor_hint():
			_limpiar_todo()
			clear_all = false


func _get_layer(nombre: String) -> TileMapLayer:
	if not has_node(nombre):
		push_error("[fill_level1] Nodo '%s' no encontrado como hijo de Fondo." % nombre)
		return null
	return get_node(nombre) as TileMapLayer


func _pintar_rect(capa: TileMapLayer, x0: int, y0: int, x1: int, y1: int, coord: Vector2i) -> int:
	var n := 0
	for x in range(x0, x1 + 1):
		for y in range(y0, y1 + 1):
			capa.set_cell(Vector2i(x, y), source_id, coord)
			n += 1
	return n


func _limpiar_todo() -> void:
	for nombre in ["CapaSuelo", "CapaCaminos", "CapaPiedra"]:
		var capa := _get_layer(nombre)
		if capa:
			capa.clear()
	print("[fill_level1] Todas las capas limpiadas.")


func _pintar_nivel() -> void:
	var suelo   := _get_layer("CapaSuelo")
	var caminos := _get_layer("CapaCaminos")
	var piedra  := _get_layer("CapaPiedra")
	if not suelo or not caminos or not piedra:
		return

	var nx := tamanio_nivel.x - 1  # 95
	var ny := tamanio_nivel.y - 1  # 95
	var total := 0

	# ── CapaSuelo: pasto base en toda el área ────────────────────────────────
	suelo.clear()
	total += _pintar_rect(suelo, 0, 0, nx, ny, coord_pasto)

	# ── CapaCaminos: caminos de piedra ────────────────────────────────────────
	caminos.clear()

	# Plaza central (12×12 tiles)
	total += _pintar_rect(caminos, 42, 42, 53, 53, coord_piedra)

	# Arteria principal N-S
	total += _pintar_rect(caminos, 45,  0, 50, 41, coord_piedra)  # norte
	total += _pintar_rect(caminos, 45, 54, 50, 95, coord_piedra)  # sur

	# Arteria principal E-O
	total += _pintar_rect(caminos,  0, 45, 41, 50, coord_piedra)  # oeste
	total += _pintar_rect(caminos, 54, 45, 95, 50, coord_piedra)  # este

	# Callejones verticales en cada cuadrante
	total += _pintar_rect(caminos, 16,  8, 20, 41, coord_piedra)  # NW
	total += _pintar_rect(caminos, 75,  8, 79, 41, coord_piedra)  # NE
	total += _pintar_rect(caminos, 16, 54, 20, 87, coord_piedra)  # SW
	total += _pintar_rect(caminos, 75, 54, 79, 87, coord_piedra)  # SE

	# Calles horizontales secundarias (unen los callejones)
	total += _pintar_rect(caminos, 20, 20, 75, 24, coord_piedra)  # superior
	total += _pintar_rect(caminos, 20, 71, 75, 75, coord_piedra)  # inferior

	# ── CapaPiedra: tierra/destrucción encima de los caminos y el pasto ───────
	piedra.clear()

	# Tramos de camino destruidos
	total += _pintar_rect(piedra, 45, 16, 47, 20, coord_tierra)  # N road — rotura 1
	total += _pintar_rect(piedra, 48, 30, 50, 34, coord_tierra)  # N road — rotura 2
	total += _pintar_rect(piedra, 46, 72, 50, 76, coord_tierra)  # S road — rotura
	total += _pintar_rect(piedra, 22, 45, 28, 48, coord_tierra)  # O road — rotura
	total += _pintar_rect(piedra, 68, 46, 74, 50, coord_tierra)  # E road — rotura

	# Manchas de escombros en zonas de pasto
	total += _pintar_rect(piedra,  3,  3,  9,  9, coord_tierra)  # rincón NO
	total += _pintar_rect(piedra, 86,  3, 92,  9, coord_tierra)  # rincón NE
	total += _pintar_rect(piedra,  3, 86,  9, 92, coord_tierra)  # rincón SO
	total += _pintar_rect(piedra, 86, 86, 92, 92, coord_tierra)  # rincón SE
	total += _pintar_rect(piedra, 28, 28, 35, 34, coord_tierra)  # cuadrante NO
	total += _pintar_rect(piedra, 60, 28, 68, 34, coord_tierra)  # cuadrante NE
	total += _pintar_rect(piedra, 28, 60, 35, 68, coord_tierra)  # cuadrante SO
	total += _pintar_rect(piedra, 60, 60, 68, 68, coord_tierra)  # cuadrante SE

	print("[fill_level1] Nivel pintado: %d celdas en 3 capas (CapaSuelo + CapaCaminos + CapaPiedra)." % total)
