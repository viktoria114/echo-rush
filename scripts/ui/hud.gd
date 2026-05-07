extends CanvasLayer

@onready var barra_vida: ProgressBar       = $MarginContainer/VBox/FilaVida/BarraVida
@onready var label_oleada: Label           = $MarginContainer/VBox/LabelOleada
@onready var contenedor_keywords: HBoxContainer = $MarginContainer/VBox/FilaKeywords/Keywords
@onready var label_monedas: Label          = $MonedaHUD/FilaMonedas/LabelMonedas
@onready var boss_hud: Control             = $BossHUD
@onready var barra_boss: ProgressBar       = $BossHUD/VBox/BarraBoss
@onready var label_boss_nombre: Label      = $BossHUD/VBox/LabelBoss

var oleadas_total: int = 1

func _ready() -> void:
	var vida_max := UpgradeSystem.get_vida_max()
	barra_vida.max_value = vida_max
	barra_vida.value     = vida_max
	label_oleada.text    = "Oleada: 0 / %d" % oleadas_total
	label_monedas.text   = str(Economy.monedas)
	boss_hud.visible     = false

func configurar_oleadas(total: int) -> void:
	oleadas_total = total

func actualizar_vida(nueva_vida: int) -> void:
	barra_vida.value = nueva_vida

func actualizar_oleada(numero: int) -> void:
	label_oleada.text = "Oleada: %d / %d" % [numero, oleadas_total]

func actualizar_monedas(total: int) -> void:
	label_monedas.text = str(total)

func mostrar_barra_boss(vida_max: int) -> void:
	boss_hud.visible      = true
	barra_boss.max_value  = vida_max
	barra_boss.value      = vida_max

func actualizar_barra_boss(vida_actual: int, _vida_max: int) -> void:
	barra_boss.value = vida_actual

func ocultar_barra_boss() -> void:
	boss_hud.visible = false

func actualizar_keywords(lista: Array) -> void:
	for child in contenedor_keywords.get_children():
		child.queue_free()
	for kw in lista:
		var label := Label.new()
		label.text = "[%s]" % kw
		label.add_theme_color_override("font_color", _color_keyword(kw))
		contenedor_keywords.add_child(label)

func _color_keyword(kw: String) -> Color:
	match kw:
		"FUEGO":  return Color(1.0, 0.4, 0.1)
		"SANGRE": return Color(0.9, 0.1, 0.1)
		"ESCUDO": return Color(0.3, 0.7, 1.0)
		"RAYO":   return Color(1.0, 1.0, 0.2)
		"VENENO": return Color(0.4, 0.9, 0.2)
		"HIELO":  return Color(0.6, 0.9, 1.0)
	return Color.WHITE
