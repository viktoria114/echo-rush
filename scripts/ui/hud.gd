extends CanvasLayer

@onready var barra_vida: ProgressBar = $MarginContainer/VBox/FilaVida/BarraVida
@onready var label_oleada: Label = $MarginContainer/VBox/LabelOleada
@onready var contenedor_keywords: HBoxContainer = $MarginContainer/VBox/FilaKeywords/Keywords

func _ready() -> void:
	barra_vida.max_value = Config.PLAYER_MAX_HP
	barra_vida.value = Config.PLAYER_MAX_HP
	label_oleada.text = "Oleada: 0"

# Llamado desde el jugador via señal
func actualizar_vida(nueva_vida: int) -> void:
	barra_vida.value = nueva_vida

# Llamado desde WaveManager via señal
func actualizar_oleada(numero: int) -> void:
	label_oleada.text = "Oleada: %d" % numero

# Llamado desde KeywordSystem via señal
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
		"FUEGO":   return Color(1.0, 0.4, 0.1)
		"SANGRE":  return Color(0.9, 0.1, 0.1)
		"ESCUDO":  return Color(0.3, 0.7, 1.0)
		"RAYO":    return Color(1.0, 1.0, 0.2)
		"VENENO":  return Color(0.4, 0.9, 0.2)
		"HIELO":   return Color(0.6, 0.9, 1.0)
	return Color.WHITE
