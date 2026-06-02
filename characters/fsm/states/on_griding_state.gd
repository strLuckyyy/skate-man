class_name OnGridingState
extends BaseState

# O quão forte é o "pulinho" automático ao sair do cano
var end_of_rail_boost_multiplier: float = 0.8
# Uma pequena elevação no eixo Y para não cair seco
var end_of_rail_lift: float = -100.0


func _init() -> void:
	state_id = Global.StateID.ON_GRIDING


@warning_ignore("shadowed_variable_base_class")
func enter(character: BaseCharacter, payload = null) -> void:
	self.character = character
	character.reset_jump()
	var rail = payload as GrindableObject
	
	if rail == null:
		emit_signal("transition_requested", Global.StateID.ON_AIR, null)
		return
	
	character.can_move = false
	
	character.grind_component.grind_finished.connect(_on_grind_finished)
	character.grind_component.start_grind(rail, character.velocity)


func update(delta: float) -> void:
	character.grind_component.process_grind(delta)


func exit() -> void:
	character.can_move = true
	character.grind_component.grind_finished.disconnect(_on_grind_finished)


func _on_grind_finished(reason: Global.ReasonToExitGrind, data: Dictionary) -> void:
	var direction: float = data.get("direction", 1.0)
	var speed:     float = data.get("speed",   300.0)
	
	if reason == Global.ReasonToExitGrind.JUMPED:
		character.velocity.y  = character.controller.apply_jump(character.equipment.current_equipment) * 1.1
		character.velocity.x  = speed * direction
		character._is_jumping = true
		
		emit_signal("transition_requested", Global.StateID.ON_AIR, null)
	
	elif reason == Global.ReasonToExitGrind.END_OF_RAIL:
		var velocity := Vector2((speed * direction) * end_of_rail_boost_multiplier, end_of_rail_lift)
		emit_signal("transition_requested", Global.StateID.TRICK_FAIL, velocity)
