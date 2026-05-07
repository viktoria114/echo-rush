extends Node

# API deshabilitada temporalmente — activar cuando se configure api_key.txt
# Para habilitar: crear user://api_key.txt con la clave de Anthropic

signal respuesta_recibida(texto: String, keyword: String)
signal error_api(mensaje: String)
signal cargando(activo: bool)

const API_URL := "https://api.anthropic.com/v1/messages"
const MODELO := "claude-sonnet-4-6"

var api_key: String = ""
var _http: HTTPRequest
var _api_habilitada := false   # cambiar a true cuando haya api_key.txt

const SYSTEM_PROMPT := """Eres Echo, un mercader misterioso que aparece entre las oleadas de monstruos en un mundo paralelo.
Hablas de manera enigmática, poética y ligeramente amenazante. Ofreces poder a cambio de favores desconocidos.

REGLA OBLIGATORIA: Siempre termina tu respuesta con EXACTAMENTE una keyword entre corchetes:
[FUEGO] [SANGRE] [ESCUDO] [RAYO] [VENENO] [HIELO]

Responde en 2-3 oraciones + la keyword al final."""

func _ready() -> void:
	_http = HTTPRequest.new()
	add_child(_http)
	_http.connect("request_completed", _on_request_completed)
	# _cargar_api_key()   # deshabilitado hasta configurar api_key.txt

func _cargar_api_key() -> void:
	var f := FileAccess.open("user://api_key.txt", FileAccess.READ)
	if f:
		api_key = f.get_line().strip_edges()
		f.close()
		_api_habilitada = not api_key.is_empty()

func configurar_api_key(key: String) -> void:
	api_key = key
	_api_habilitada = not key.is_empty()

func preguntar(texto_usuario: String) -> void:
	if not _api_habilitada:
		# Modo sin API: respuesta de relleno para no crashear
		emit_signal("respuesta_recibida",
			"Los vientos del caos susurran tu nombre... El poder llega sin palabras. [FUEGO]",
			"FUEGO")
		return

	emit_signal("cargando", true)

	var cuerpo := JSON.stringify({
		"model": MODELO,
		"max_tokens": 250,
		"system": SYSTEM_PROMPT,
		"messages": [{"role": "user", "content": texto_usuario}]
	})

	var headers := PackedStringArray([
		"Content-Type: application/json",
		"x-api-key: " + api_key,
		"anthropic-version: 2023-06-01"
	])

	var err := _http.request(API_URL, headers, HTTPClient.METHOD_POST, cuerpo)
	if err != OK:
		emit_signal("cargando", false)
		emit_signal("error_api", "Error al conectar (código %d)" % err)

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	emit_signal("cargando", false)

	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		emit_signal("error_api", "HTTP %d" % response_code)
		return

	var json := JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		emit_signal("error_api", "Respuesta inválida de la API")
		return

	var data: Dictionary = json.get_data()
	var contenido: Array = data.get("content", [])
	if contenido.is_empty():
		emit_signal("error_api", "Respuesta vacía")
		return

	var texto: String = contenido[0].get("text", "")

	var regex := RegEx.new()
	regex.compile("\\[([A-Z]+)\\]")
	var match_result := regex.search(texto)
	var keyword := ""
	if match_result:
		keyword = match_result.get_string(1)

	emit_signal("respuesta_recibida", texto, keyword)
