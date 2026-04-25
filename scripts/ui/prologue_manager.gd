extends Node

signal prologo_terminado

const PANELES := [
	"Era un martes cualquiera en la secundaria.\nRael, Lena, Brom y Zari se preparaban para el recreo...",
	"De repente, un portal brillante apareció\nen medio del aula de ciencias.",
	"Antes de que pudieran reaccionar,\nlos cuatro fueron absorbidos hacia lo desconocido.",
	"Al despertar, se encontraron en una aldea en ruinas,\nrodeados de criaturas hostiles.",
	"No había retorno.\nSu única opción: sobrevivir juntos y encontrar el camino de regreso.",
]

var panel_actual: int = 0

@onready var label_texto: Label = $UI/Panel/VBox/Texto
@onready var boton: Button = $UI/Panel/VBox/Boton

func _ready() -> void:
	_mostrar_panel(0)
	boton.pressed.connect(_avanzar)

func _unhandled_key_input(event: InputEvent) -> void:
	if (event as InputEventKey).pressed and not (event as InputEventKey).echo:
		_avanzar()

func _avanzar() -> void:
	panel_actual += 1
	if panel_actual >= PANELES.size():
		emit_signal("prologo_terminado")
		get_tree().change_scene_to_file("res://scenes/levels/Level1.tscn")
	else:
		_mostrar_panel(panel_actual)

func _mostrar_panel(indice: int) -> void:
	label_texto.text = PANELES[indice]
	var es_ultimo := indice == PANELES.size() - 1
	boton.text = "¡Comenzar!" if es_ultimo else "Continuar →"
