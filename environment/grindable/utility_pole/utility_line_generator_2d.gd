@tool
class_name UtilityLineGenerator2D
extends GrindableObject

@export_category("Assets")
@export var pole_scene: PackedScene:
	set(value): pole_scene = value; _request_editor_generate()

@export_category("Bake")
@export var auto_generate_in_editor: bool = false:
	set(value): auto_generate_in_editor = value; _request_editor_generate()
@export_tool_button("Gerar/Bakear postes")
var bake_line_button: Callable = generate_line
@export_tool_button("Limpar bake")
var clear_bake_button: Callable = clear_generated_line

@export_category("Distribuicao")
@export var min_distance: float = 200.0:
	set(value): min_distance = value; _request_editor_generate()
@export var max_distance: float = 350.0:
	set(value): max_distance = value; _request_editor_generate()
@export var max_poles: int = 30:
	set(value): max_poles = value; _request_editor_generate()
@export var generation_seed: int = 42:
	set(value): generation_seed = value; _request_editor_generate()

@export_category("Restricoes de Altura")
@export var use_min_height: bool = true:
	set(value): use_min_height = value; _request_editor_generate(true)
@export var min_pole_height: float = 100.0:
	set(value): min_pole_height = value; _request_editor_generate(true)
@export var use_max_height: bool = true:
	set(value): use_max_height = value; _request_editor_generate(true)
@export var max_pole_height: float = 500.0:
	set(value): max_pole_height = value; _request_editor_generate(true)

@export_category("Variacoes Visuais (RNG)")
@export var rotation_variation: float = 4.0:
	set(value): rotation_variation = value; _request_editor_generate()
@export var y_position_variation: float = 12.0:
	set(value): y_position_variation = value; _request_editor_generate()
@export var x_position_variation: float = 8.0:
	set(value): x_position_variation = value; _request_editor_generate()

@export_category("Configuracao do Cabo")
@export var sag_amount: float = 50.0:
	set(value): sag_amount = value; _request_editor_generate()
@export var wire_thickness: float = 6.0:
	set(value): wire_thickness = value; _request_editor_generate()

@onready var wire_start: Marker2D = $WireStart
@onready var wire_end: Marker2D = $WireEnd
@onready var poles_container: Node2D = $PolesContainer
@onready var line_path: Path2D = $Path2D
@onready var grind_area: Area2D = $GrindArea

func _ready() -> void:
	if not Engine.is_editor_hint():
		return
	
	if wire_start and not wire_start.item_rect_changed.is_connected(_on_generation_control_changed):
		wire_start.item_rect_changed.connect(_on_generation_control_changed)
	if wire_end and not wire_end.item_rect_changed.is_connected(_on_generation_control_changed):
		wire_end.item_rect_changed.connect(_on_generation_control_changed)
	
	queue_redraw()
	if auto_generate_in_editor:
		generate_line()

func generate_line() -> void:
	if not Engine.is_editor_hint():
		return
	if not pole_scene or not wire_start or not wire_end or not poles_container:
		return
	if not line_path or not grind_area:
		return
	
	_clear_old_poles()
	_clear_old_grind_collision()
	_clear_line_visual()
	
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
	
	var spawned_poles = LinePolePlacer.create_poles(
		pole_scene,
		poles_container,
		wire_start.position,
		wire_end.position,
		distribution_params,
		scene_root
	)
	if spawned_poles.is_empty():
		return
	
	var master_curve = LineCurveBuilder.build_single_curve(
		line_path,
		spawned_poles,
		wire_start,
		wire_end,
		sag_amount
	)
	if not master_curve:
		return
	
	if line_path.has_method("_update_line"):
		line_path.call("_update_line")
	
	LineCollisionGenerator.generate_single_grind_collision(
		grind_area,
		master_curve,
		wire_thickness,
		scene_root
	)

func clear_generated_line() -> void:
	if not Engine.is_editor_hint():
		return
	if not poles_container or not line_path or not grind_area:
		return
	
	_clear_old_poles()
	_clear_old_grind_collision()
	_clear_line_visual()
	
	queue_redraw()

func _clear_old_poles() -> void:
	for child in poles_container.get_children():
		poles_container.remove_child(child)
		child.free()

func _clear_old_grind_collision() -> void:
	for child in grind_area.get_children():
		if child is CollisionPolygon2D:
			grind_area.remove_child(child)
			child.free()

func _clear_line_visual() -> void:
	line_path.curve = Curve2D.new()
	
	var line := line_path.get_node_or_null("Line2D") as Line2D
	if line:
		line.points = PackedVector2Array()

func _request_editor_generate(redraw := false) -> void:
	if not Engine.is_editor_hint():
		return
	if redraw and is_inside_tree():
		queue_redraw()
	if not auto_generate_in_editor or not is_node_ready():
		return
	call_deferred("generate_line")

func _on_generation_control_changed() -> void:
	_request_editor_generate(true)

func _draw() -> void:
	if Engine.is_editor_hint():
		if use_min_height:
			var line_length := 3000.0
			var start_line := Vector2(-line_length, min_pole_height)
			var end_line := Vector2(line_length, min_pole_height)
			draw_line(start_line, end_line, Color(1, 0, 0, 0.4), 2.0)
		if use_max_height:
			var line_length := 3000.0
			var start_line := Vector2(-line_length, max_pole_height)
			var end_line := Vector2(line_length, max_pole_height)
			draw_line(start_line, end_line, Color(0, 0, 1, 0.4), 2.0)
