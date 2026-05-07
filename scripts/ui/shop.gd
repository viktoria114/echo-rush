extends CanvasLayer

signal tienda_cerrada

@onready var label_monedas: Label = $Centro/Panel/Margin/VBox/FilaMonedas/LabelMonedas
@onready var grid_mejoras: GridContainer = $Centro/Panel/Margin/VBox/GridMejoras
@onready var btn_continuar: Button = $Centro/Panel/Margin/VBox/BtnContinuar

const MEJORAS := [
	{
		"nombre": "Fuerza de Ataque",
		"desc": "+15 de daño por golpe",
		"icono": "[DMG]",
		"key": "dano_bonus",
		"valor": 15,
		"costo": 30,
		"color": Color(1.0, 0.4, 0.2)
	},
	{
		"nombre": "Velocidad de Ataque",
		"desc": "Ataca un 20% más rápido",
		"icono": "[ATK]",
		"key": "cooldown_reduccion",
		"valor": 0.20,
		"costo": 40,
		"color": Color(1.0, 1.0, 0.2)
	},
	{
		"nombre": "Resistencia",
		"desc": "+25 de vida máxima",
		"icono": "[VID]",
		"key": "vida_bonus",
		"valor": 25,
		"costo": 35,
		"color": Color(0.3, 1.0, 0.4)
	},
	{
		"nombre": "Agilidad",
		"desc": "Muévete un 15% más rápido",
		"icono": "[MOV]",
		"key": "velocidad_bonus",
		"valor": 0.15,
		"costo": 25,
		"color": Color(0.4, 0.8, 1.0)
	}
]

func _ready() -> void:
	Economy.connect("monedas_cambiadas", _actualizar_monedas)
	btn_continuar.pressed.connect(_on_btn_continuar)
	_actualizar_monedas(Economy.monedas)
	_crear_tarjetas()

func _actualizar_monedas(total: int) -> void:
	label_monedas.text = str(total)
	# Habilitar/deshabilitar botones según dinero disponible
	for tarjeta in grid_mejoras.get_children():
		if tarjeta.has_meta("btn_comprar") and not tarjeta.get_meta("comprado", false):
			var btn := tarjeta.get_meta("btn_comprar") as Button
			if is_instance_valid(btn):
				btn.disabled = not Economy.tiene(tarjeta.get_meta("costo"))

func _crear_tarjetas() -> void:
	for mejora in MEJORAS:
		grid_mejoras.add_child(_construir_tarjeta(mejora))

func _construir_tarjeta(mejora: Dictionary) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(210, 0)
	panel.set_meta("costo", mejora["costo"])
	panel.set_meta("comprado", false)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(vbox)

	var lbl_icono := Label.new()
	lbl_icono.text = mejora["icono"]
	lbl_icono.add_theme_font_size_override("font_size", 24)
	lbl_icono.add_theme_color_override("font_color", mejora["color"])
	lbl_icono.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_icono)

	var lbl_nombre := Label.new()
	lbl_nombre.text = mejora["nombre"]
	lbl_nombre.add_theme_font_size_override("font_size", 16)
	lbl_nombre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_nombre.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(lbl_nombre)

	var lbl_desc := Label.new()
	lbl_desc.text = mejora["desc"]
	lbl_desc.add_theme_font_size_override("font_size", 13)
	lbl_desc.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
	lbl_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(lbl_desc)

	var lbl_costo := Label.new()
	lbl_costo.text = "● %d monedas" % mejora["costo"]
	lbl_costo.add_theme_font_size_override("font_size", 14)
	lbl_costo.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	lbl_costo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_costo)

	var btn := Button.new()
	btn.text = "Comprar"
	btn.add_theme_font_size_override("font_size", 15)
	btn.disabled = not Economy.tiene(mejora["costo"])
	# Guardamos referencia directa para evitar búsqueda por ruta
	panel.set_meta("btn_comprar", btn)
	btn.pressed.connect(_on_comprar.bind(mejora, btn, panel))
	vbox.add_child(btn)

	return panel

func _on_comprar(mejora: Dictionary, btn: Button, panel: PanelContainer) -> void:
	if not Economy.gastar(mejora["costo"]):
		return
	UpgradeSystem.set(mejora["key"], UpgradeSystem.get(mejora["key"]) + mejora["valor"])
	btn.text = "Comprado!"
	btn.disabled = true
	panel.set_meta("comprado", true)
	_actualizar_monedas(Economy.monedas)

func _on_btn_continuar() -> void:
	emit_signal("tienda_cerrada")
	queue_free()
