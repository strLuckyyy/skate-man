class_name CharacterAnimator
extends AnimatedSprite2D

signal trick_animation_finished

enum TrickPhase { NONE, IN, ING, OUT }

var character:          BaseCharacter
var is_executing_trick: bool = false
var current_trick_anim: StringName = ""

var _trick_phase:      TrickPhase          = TrickPhase.NONE
var current_priority:  Global.AnimPriority = Global.AnimPriority.BACKGROUND


func setup(character_ref: BaseCharacter) -> void:
	character   = character_ref
	
	animation_finished.connect(_on_animation_finished)
	character.state_machine.state_changed.connect(_on_state_changed)
	character.grind_component.grind_finished.connect(_on_grind_finished)


func is_loop_animation(anim_name: StringName = "") -> bool:
	print("checking loop")
	if anim_name == "":       anim_name = animation
	if sprite_frames == null: return false
	
	var loop = sprite_frames.get_animation_loop_mode(anim_name)
	return loop > 0

# ---------------------------------------------------------------------------
# Core Play Methods
# ---------------------------------------------------------------------------

func play_trick(anim_path: StringName) -> void:	
	if anim_path.is_empty():
		push_warning("A manobra '", anim_path, "' não tem nome de animação válido.")
		return
	anim_path = StringName(str(anim_path).strip_edges().to_lower())
	print(anim_path, current_priority > Global.AnimPriority.TRICK)
	if current_priority > Global.AnimPriority.TRICK:
		return

	is_executing_trick = true
	current_trick_anim = anim_path
	current_priority   = Global.AnimPriority.TRICK

	var composed := _get_composed_animation(anim_path)
	if composed["in"] != "":
		_trick_phase = TrickPhase.IN
		play(composed["in"])
	elif composed["ing"] != "":
		_trick_phase = TrickPhase.ING
		play(composed["ing"])
	else:
		_trick_phase = TrickPhase.NONE
		play(anim_path)


func play_animation(
	anim_path: StringName, priority: Global.AnimPriority = Global.AnimPriority.ACTION) -> void:
	if priority < current_priority: 
		return
	anim_path = StringName(str(anim_path).strip_edges().to_lower())
	print(anim_path, priority)
	if is_executing_trick and priority > Global.AnimPriority.TRICK:
		is_executing_trick = false
		_trick_phase       = TrickPhase.NONE
		trick_animation_finished.emit()

	current_trick_anim = anim_path
	current_priority   = priority
	play(anim_path)
	
# ---------------------------------------------------------------------------
# Animation resolution
# ---------------------------------------------------------------------------

func _on_animation_finished() -> void:
	if is_executing_trick:
		var composed := _get_composed_animation(current_trick_anim)
		match _trick_phase:
			TrickPhase.IN:
				if composed["ing"] != "":
					_trick_phase = TrickPhase.ING
					play(composed["ing"])
				else:
					_finish_trick()
			TrickPhase.ING:
				if composed["out"] != "":
					_trick_phase = TrickPhase.OUT
					play(composed["out"])
				else:
					_finish_trick()
			TrickPhase.OUT, TrickPhase.NONE:
				_finish_trick()
	else:
		if current_priority == Global.AnimPriority.ACTION:
			current_priority = Global.AnimPriority.BACKGROUND
			_update_base_animation(character.state_machine.get_current_state_id())


func finish_trick() -> void:
	if not is_executing_trick: return

	var composed := _get_composed_animation(current_trick_anim)
	if composed["out"] != "":
		_trick_phase = TrickPhase.OUT
		play(composed["out"])
	else:
		_finish_trick()


func _finish_trick() -> void:
	is_executing_trick = false
	current_trick_anim = ""
	_trick_phase = TrickPhase.NONE
	current_priority = Global.AnimPriority.BACKGROUND
	
	trick_animation_finished.emit()
	_update_base_animation(character.state_machine.get_current_state_id())


func _cancel_trick_animation() -> void:
	if not is_executing_trick: return
	
	is_executing_trick = false
	current_trick_anim = ""
	_trick_phase = TrickPhase.NONE
	current_priority = Global.AnimPriority.BACKGROUND
	
	trick_animation_finished.emit()


func _get_composed_animation(base_name: StringName) -> Dictionary:
	var result := { "in": StringName(), "ing": StringName(), "out": StringName() }
	if sprite_frames == null: return result
	
	var in_name  := StringName(str(base_name) + "-in")
	var out_name := StringName(str(base_name) + "-out")
	var ing_name : StringName = StringName("mommentum") \
		if base_name == "idle" else StringName(str(base_name) + "-ing")
	
	if sprite_frames.has_animation(in_name): result["in"] = in_name
	if sprite_frames.has_animation(ing_name): result["ing"] = ing_name
	if sprite_frames.has_animation(out_name): result["out"] = out_name
	
	return result

# ---------------------------------------------------------------------------
# Gameplay state changes
# ---------------------------------------------------------------------------

func _on_state_changed(_old_state: Global.StateID, new_state: Global.StateID) -> void:
	if new_state == Global.StateID.TRICK_FAIL: 
		_cancel_trick_animation()
		play_animation("trick_fail", Global.AnimPriority.CRITICAL)
		return
	
	if new_state == Global.StateID.ON_AIR or new_state == Global.StateID.ON_FALLING:
		if is_executing_trick:
			_cancel_trick_animation()
		_update_base_animation(new_state)
		return
	
	_update_base_animation(new_state)


func _update_base_animation(state_id: Global.StateID) -> void:
	if current_priority > Global.AnimPriority.BACKGROUND: return
	match state_id:
		Global.StateID.ON_FLOOR:
			play_animation("mommentum", Global.AnimPriority.BACKGROUND)


func _on_grind_finished(
	reason: Global.ReasonToExitGrind,
	_data: Dictionary
) -> void:
	if not is_executing_trick: return
	if reason == Global.ReasonToExitGrind.JUMPED:
		_cancel_trick_animation()
	elif reason == Global.ReasonToExitGrind.END_OF_RAIL:
		finish_trick()
