extends CanvasLayer

signal tienda_cerrada

@onready var label_echo: Label = $Centro/Panel/Margin/VBox/LabelEcho
@onready var label_monedas: Label = $Centro/Panel/Margin/VBox/FilaInfo/LabelMonedas
@onready var label_keywords: Label = $Centro/Panel/Margin/VBox/LabelKeywords
@onready var input_jugador: LineEdit = $Centro/Panel/Margin/VBox/HBoxInput/InputJugador
@onready var btn_preguntar: Button = $Centro/Panel/Margin/VBox/HBoxInput/BtnPreguntar
@onready var btn_reroll: Button = $Centro/Panel/Margin/VBox/BtnReroll
@onready var btn_continuar: Button = $Centro/Panel/Margin/VBox/BtnContinuar

var _esperando: bool = false

func _ready() -> void:
	EchoAPI.connect("respuesta_recibida", _on_respuesta)
	EchoAPI.connect("error_api", _on_error)
	EchoAPI.connect("cargando", _on_cargando)
	Economy.connect("monedas_cambiadas", _actualizar_monedas)

	btn_preguntar.pressed.connect(_on_btn_preguntar)
	btn_reroll.pressed.connect(_on_btn_reroll)
	btn_continuar.pressed.connect(_on_btn_continuar)
	input_jugador.text_submitted.connect(func(_t: String) -> void: _on_btn_preguntar())

	_actualizar_monedas(Economy.monedas)
	_actualizar_keywords()
	label_echo.text = "Echo: Bienvenido, viajero. El caos te rodea... ¿Qué buscas en este abismo?"

func _actualizar_monedas(total: int) -> void:
	label_monedas.text = str(total)
	btn_reroll.text = "Preguntar de nuevo (%d monedas)" % Config.ECHO_REROLL_COST
	btn_reroll.disabled = not Economy.tiene(Config.ECHO_REROLL_COST) or _esperando

func _actualizar_keywords() -> void:
	var kws := KeywordSystem.obtener_keywords()
	if kws.is_empty():
		label_keywords.text = "Sin poderes activos"
	else:
		var nombres := kws.map(func(k: String) -> String: return "[%s]" % k)
		label_keywords.text = "Poderes: " + ", ".join(nombres)

func _on_btn_preguntar() -> void:
	var texto := input_jugador.text.strip_edges()
	if texto.is_empty() or _esperando:
		return
	_esperando = true
	input_jugador.editable = false
	label_echo.text = "Echo: ..."
	EchoAPI.preguntar(texto)
	input_jugador.clear()

func _on_btn_reroll() -> void:
	if _esperando or not Economy.gastar(Config.ECHO_REROLL_COST):
		return
	_esperando = true
	btn_reroll.disabled = true
	label_echo.text = "Echo: ..."
	EchoAPI.preguntar("Ofréceme otro poder diferente")

func _on_respuesta(texto: String, keyword: String) -> void:
	_esperando = false
	input_jugador.editable = true
	label_echo.text = "Echo: " + texto
	if not keyword.is_empty():
		KeywordSystem.agregar_keyword(keyword)
		_actualizar_keywords()
	_actualizar_monedas(Economy.monedas)

func _on_error(mensaje: String) -> void:
	_esperando = false
	input_jugador.editable = true
	label_echo.text = "Echo: [Los susurros se pierden en el vacío...]\n(%s)" % mensaje
	_actualizar_monedas(Economy.monedas)

func _on_cargando(activo: bool) -> void:
	btn_preguntar.disabled = activo

func _on_btn_continuar() -> void:
	emit_signal("tienda_cerrada")
	queue_free()
