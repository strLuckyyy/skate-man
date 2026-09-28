
class_name CharacterAnimator
extends AnimatedSprite2D

signal trick_animation_finished

enum TrickPhase {
	NONE,
	IN,
	ING,
	OUT
}

var character:          BaseCharacter
var is_executing_trick: bool = false
var current_trick_anim: StringName = ""

var _trick_phase: TrickPhase = TrickPhase.NONE


func setup(character_ref: BaseCharacter) -> void:
	character   = character_ref
	
	animation_finished.connect(_on_animation_finished)
	character.state_machine.state_changed.connect(_on_state_changed)
	character.grind_component.grind_finished.connect(finish_trick)


func is_loop_animation(anim_name: StringName = "") -> bool:
	if anim_name == "":       anim_name = animation
	if sprite_frames == null: return false
	if sprite_frames.has_animation(anim_name):
		return sprite_frames.get_animation_loop(anim_name)
	
	return false


## Method to call a trick animation. If you need to call a normal animation, call play_animation() instead.
func play_trick(anim_path: StringName) -> void:
	if anim_path.is_empty():
		push_warning("A manobra '", anim_path, "' não tem nome de animação válido.")
		_cancel_trick_animation()
		return
	
	if character.state_machine.get_current_state_id() == Global.StateID.TRICK_FAIL:
		return

	is_executing_trick = true
	current_trick_anim = anim_path

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


## Method to call a normal animation. If you need to call a trick animation, call play_trick() instead.
func play_animation(anim_path: StringName, forced: bool = false) -> void:
	if character.state_machine.get_current_state_id() == Global.StateID.TRICK_FAIL:
		if anim_path != "trick_fail":
			return
	
	if is_executing_trick and not forced: return
	if forced and not is_loop_animation(current_trick_anim): return

	current_trick_anim = anim_path
	play(anim_path)


func finish_trick() -> void:
	if not is_executing_trick: return

	var composed := _get_composed_animation(current_trick_anim)
	var out_animation: StringName = composed["out"]

	if out_animation == "":
		_finish_trick()
		return

	_trick_phase = TrickPhase.OUT
	play(out_animation)
	

# ---------------------------------------------------------------------------
# Animation resolution
# ---------------------------------------------------------------------------

func _get_composed_animation(base_name: StringName) -> Dictionary:
	var result := {
		"in":  StringName(),
		"ing": StringName(),
		"out": StringName()
	}
	
	if sprite_frames == null:
		return result
	
	var in_name  := StringName(str(base_name) + "-in")
	var out_name := StringName(str(base_name) + "-out")
	var ing_name : StringName
	if base_name == "idle": ing_name = StringName("mommentum")
	else: ing_name = StringName(str(base_name) + "-ing")
	
	if sprite_frames.has_animation(in_name):
		result["in"] = in_name
	
	if sprite_frames.has_animation(ing_name):
		result["ing"] = ing_name
	
	if sprite_frames.has_animation(out_name):
		result["out"] = out_name
	
	return result


# ---------------------------------------------------------------------------
# Trick animation flow
# ---------------------------------------------------------------------------

func _on_animation_finished() -> void:
	if not is_executing_trick: return

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
		TrickPhase.OUT:
			_finish_trick()
		TrickPhase.NONE:
			_finish_trick()


func _finish_trick() -> void:
	is_executing_trick = false
	current_trick_anim = ""
	_trick_phase       = TrickPhase.NONE

	trick_animation_finished.emit()

	_update_base_animation(
		character.state_machine.get_current_state_id()
	)


func _cancel_trick_animation() -> void:
	if not is_executing_trick: return

	is_executing_trick = false
	current_trick_anim = ""
	_trick_phase       = TrickPhase.NONE

	stop()

	trick_animation_finished.emit()


# ---------------------------------------------------------------------------
# Gameplay state changes
# ---------------------------------------------------------------------------

func _on_state_changed(_old_state: Global.StateID, new_state: Global.StateID) -> void:
	if new_state == Global.StateID.TRICK_FAIL: 
		_cancel_trick_animation()
		_update_base_animation(new_state)
		return
	
	if new_state == Global.StateID.ON_AIR \
		or new_state == Global.StateID.ON_FALLING:
		if is_executing_trick:
			_cancel_trick_animation()

		_update_base_animation(new_state)
		return
	
	if is_executing_trick: return
	
	_update_base_animation(new_state)


# ---------------------------------------------------------------------------
# Grind
# ---------------------------------------------------------------------------

func _on_grind_finished(
	reason: Global.ReasonToExitGrind,
	_data: Dictionary
) -> void:

	if not is_executing_trick:
		return

	# Jumping off the grind is an interruption.
	if reason == Global.ReasonToExitGrind.JUMPED:
		_cancel_trick_animation()
		return

	# Reaching the end of the rail is a normal trick ending.
	if reason == Global.ReasonToExitGrind.END_OF_RAIL:
		finish_trick()


# ---------------------------------------------------------------------------
# Base animations
# ---------------------------------------------------------------------------

func _update_base_animation(state_id: Global.StateID) -> void:
	match state_id:
		Global.StateID.ON_FLOOR:
			play_animation("mommentum")
		Global.StateID.TRICK_FAIL:
			play_animation("trick_fail")
