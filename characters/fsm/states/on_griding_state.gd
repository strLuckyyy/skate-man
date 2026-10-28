class_name OnGridingState
extends BaseState

# O quão forte é o "pulinho" automático ao sair do cano
var end_of_rail_boost_multiplier: float = 0.8
# Uma pequena elevação no eixo Y para não cair seco
var end_of_rail_lift: float = -100.0


func _init() -> void:
	state_id = Global.StateID.ON_GRIDING


@warning_ignore("shadowed_variable_base_class")
func enter(p_character: BaseCharacter, _payload = null) -> void:
	super.enter(p_character, _payload)
	
	var rail = _payload as GrindableObject
	if rail == null:
		emit_signal("transition_requested", Global.StateID.ON_AIR, null)
		return
	
	controller.set_permissions(true, true)
	controller.reset_jumped()
	
	if not character.grind_component.grind_finished.is_connected(_on_grind_finished):
		character.grind_component.grind_finished.connect(_on_grind_finished)

	if not character.grind_component.start_grind(rail, character.velocity):
		_disconnect_grind_finished()
		call_deferred("_request_air_transition")


func update(delta: float) -> void:
	character.grind_component.process_grind(delta)


func exit() -> void:
	_disconnect_grind_finished()


func _on_grind_finished(reason: Global.ReasonToExitGrind, data: Dictionary) -> void:
	var direction: float = data.get("direction", 1.0)
	var speed:     float = data.get("speed",   300.0)
	
	if reason == Global.ReasonToExitGrind.JUMPED:
		character.apply_jump(1.1)
		character.velocity.x  = speed * direction
		
		emit_signal("transition_requested", Global.StateID.ON_AIR, null)
	
	elif reason == Global.ReasonToExitGrind.END_OF_RAIL:
		var velocity := Vector2(
			(speed * direction) * end_of_rail_boost_multiplier, end_of_rail_lift)
		emit_signal("transition_requested", Global.StateID.TRICK_FAIL, velocity)


func _disconnect_grind_finished() -> void:
	if character == null or character.grind_component == null:
		return
	if character.grind_component.grind_finished.is_connected(_on_grind_finished):
		character.grind_component.grind_finished.disconnect(_on_grind_finished)


func _request_air_transition() -> void:
	if character == null:
		return
	if character.state_machine.get_current_state_id() == Global.StateID.ON_GRIDING:
		emit_signal("transition_requested", Global.StateID.ON_AIR, null)
