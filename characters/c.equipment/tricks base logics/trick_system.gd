## TrickSystem — resolves input sequences into trick executions.
##
## Grind changes vs original:
##  • process() now accepts the current ObjectGrindable so it can be forwarded
##    to grind_started without TrickSystem holding a scene-tree reference.
##  • _on_sequence_resolved() uses a two-pass algorithm:
##      Pass 1 (only when can_grind): GrindTricks have absolute priority.
##      Pass 2:                       Air/non-grind tricks are the fallback.
##    This guarantees a player in a grind zone who inputs a grind sequence
##    always grinds, never accidentally fires an air trick instead.
##  • try_execute() emits EventBus.grind_started when the winning trick is a
##    GrindTrick, forwarding the grindable ref for the state-machine transition.
class_name TrickSystem
extends Node

var equipment:          EquipmentData
var _current_state:     Global.StateID
var _grind_opportunity: bool
var _current_grindable: ObjectGrindable  ## null when not overlapping a GrindArea


func _ready() -> void:
	EventBus.sequence_resolved.connect(_on_sequence_resolved)
	EventBus.equipment_changed.connect(_on_equipment_changed)


## Called every physics frame by Player._physics_process().
## Snapshot of the frame's context; used when a sequence resolves asynchronously.
func process(
		state_id:        Global.StateID,
		grind_opportunity: bool,
		grindable:       ObjectGrindable = null
) -> void:
	_current_state      = state_id
	_grind_opportunity  = grind_opportunity
	_current_grindable  = grindable


## Executes a trick and fires the appropriate EventBus events.
## If the trick is a GrindTrick, also emits grind_started so the player's
## _is_on_grinding handler can set the grind flag and prime the FSM.
func try_execute(context: TrickContext, trick: BaseTrick) -> void:
	EventBus.trick_detected.emit(
		trick.trick_data.trick_name if trick.trick_data else "Unknown"
	)
	EventBus.trick_started.emit(trick)

	# ── GRIND TRIGGER (Bug Fix #2) ────────────────────────────────────────
	# Emit grind_started BEFORE execute() so the character flag is set before
	# any execute() side-effects run. The grindable reference travels with it.
	if trick.is_grind_trick and _current_grindable != null:
		EventBus.grind_started.emit(_current_grindable)

	trick.execute(context)


# ---------------------------------------------------------------------------
# Private — sequence resolution
# ---------------------------------------------------------------------------

func _on_sequence_resolved(candidates: Array[BaseTrick], path: Array[Global.Direction]) -> void:
	var context := TrickContext.new()
	context.build_context(_current_state, _grind_opportunity, path)

	# ── PASS 1: Grind tricks (highest priority when in a grind zone) ──────
	# Only attempted when _grind_opportunity is true AND the player is airborne.
	# Being in a grind zone on the floor does not trigger a grind.
	if _grind_opportunity and _is_airborne():
		for trick in candidates:
			if trick.is_grind_trick and trick.can_execute(context):
				try_execute(context, trick)
				return
		# No grind trick matched — fall through to air tricks.
		# The player is still airborne and inside the area, so air tricks are
		# valid as a fallback (e.g. an ollie instead of a grind).

	# ── PASS 2: Non-grind (air) tricks ───────────────────────────────────
	for trick in candidates:
		if not trick.is_grind_trick and trick.can_execute(context):
			try_execute(context, trick)
			return


## True if the FSM is currently in a state that allows airborne trick input.
func _is_airborne() -> bool:
	return _current_state == Global.StateID.ON_AIR \
		or _current_state == Global.StateID.ON_FALLING


func _on_equipment_changed(new_equipment: EquipmentData, _new_tricks: Array[BaseTrick]) -> void:
	equipment = new_equipment
