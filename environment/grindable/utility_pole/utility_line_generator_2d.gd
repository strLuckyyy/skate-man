@tool
class_name UtilityLineGenerator2D
extends GrindableObject

@export_category("Assets")
@export var pole_scene: PackedScene:
	set(value): pole_scene = value; generate_line()

@export_category("Distribuição")
@export var min_distance: float = 200.0:
	set(value): min_distance = value; generate_line()
@export var max_distance: float = 350.0:
	set(value): max_distance = value; generate_line()
@export var max_poles: int = 30:
	set(value): max_poles = value; generate_line()
@export var generation_seed: int = 42:
	set(value): generation_seed = value; generate_line()

@export_category("Restrições de Altura")
@export var use_min_height: bool = true:
	set(value): use_min_height = value; generate_line(); queue_redraw()
@export var min_pole_height: float = 100.0:
	set(value): min_pole_height = value; generate_line(); queue_redraw()
@export var use_max_height: bool = true:
	set(value): use_max_height = value; generate_line(); queue_redraw()
@export var max_pole_height: float = 500.0:
	set(value): max_pole_height = value; generate_line(); queue_redraw()

@export_category("Variações Visuais (RNG)")
@export var rotation_variation: float = 4.0:
	set(value): rotation_variation = value; generate_line()
@export var y_position_variation: float = 12.0:
	set(value): y_position_variation = value; generate_line()
@export var x_position_variation: float = 8.0:
	set(value): x_position_variation = value; generate_line()

@export_category("Configuração do Cabo")
@export var sag_amount: float = 50.0:
	set(value): sag_amount = value; generate_line()
@export var wire_thickness: float = 6.0:
	set(value): wire_thickness = value; generate_line()

@onready var wire_start:    Marker2D = $WireStart
@onready var wire_end:      Marker2D = $WireEnd
@onready var poles_container: Node2D = $PolesContainer
@onready var line_path:     Path2D   = $Path2D
@onready var grind_area:    Area2D   = $GrindArea  

func _ready() -> void:
	if Engine.is_editor_hint():
		if wire_start and not wire_start.item_rect_changed.is_connected(generate_line):
			wire_start.item_rect_changed.connect(generate_line)
		if wire_end and not wire_end.item_rect_changed.is_connected(generate_line):
			wire_end.item_rect_changed.connect(generate_line)
	generate_line()
	queue_redraw()

func generate_line() -> void:
	if not pole_scene or not wire_start or not wire_end or not poles_container:
		return
	if not line_path or not grind_area:
		return
	
	_clear_old_poles()
	
	var scene_root = get_tree().edited_scene_root if Engine.is_editor_hint() else null
	
	var distribution_params = {
		"min_distance": min_distance,
		"max_distance": max_distance,
		"max_poles": max_poles,
		"generation_seed": generation_seed,
		"x_var": x_position_variation,
		"y_var": y_position_variation,
		"rot_var": rotation_variation,
		"use_min_height": use_min_height,
		"min_pole_height": min_pole_height,
		"use_max_height": use_max_height,
		"max_pole_height": max_pole_height
	}
	
	# Passo 1: Posicionar postes (como antes)
	var spawned_poles = LinePolePlacer.create_poles(
		pole_scene, poles_container,
		wire_start.position, wire_end.position,
		distribution_params, scene_root
	)
	if spawned_poles.is_empty(): return
	
	# Passo 2: Construir a curva mestre no Path2D do gerador
	var master_curve = LineCurveBuilder.build_single_curve(
		line_path, spawned_poles, wire_start, wire_end, sag_amount
	)
	if not master_curve: return
	
	# Passo 3: Atualizar visual (Line2D)
	if line_path.has_method("_update_line"):
		line_path.call("_update_line")
	
	# Passo 4: Gerar colisão única para toda a linha
	LineCollisionGenerator.generate_single_grind_collision(
		grind_area, master_curve, wire_thickness, scene_root
	)


func _clear_old_poles() -> void:
	for child in poles_container.get_children():
		poles_container.remove_child(child)
		child.free()

func _draw() -> void:
	if Engine.is_editor_hint():
		if use_min_height:
			var line_length := 3000.0
			var start_line  := Vector2(-line_length, min_pole_height)
			var end_line    := Vector2(line_length, min_pole_height)
			draw_line(start_line, end_line, Color(1, 0, 0, 0.4), 2.0)
		if use_max_height:
			var line_length := 3000.0
			var start_line  := Vector2(-line_length, max_pole_height)
			var end_line    := Vector2(line_length, max_pole_height)
			draw_line(start_line, end_line, Color(0, 0, 1, 0.4), 2.0)
