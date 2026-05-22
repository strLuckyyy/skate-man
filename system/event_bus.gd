extends Node

# --- Player Events ---
@warning_ignore("unused_signal")
signal player_state_changed(old_state: Global.StateID, new_state: Global.StateID)
@warning_ignore("unused_signal")
signal player_lock_requested(body: CharacterBody2D)
@warning_ignore("unused_signal")
signal player_unlock_requested()
@warning_ignore("unused_signal")
signal player_caught()

# --- Input Events ---
@warning_ignore("unused_signal")
signal direction_input(direction: Global.Direction, pressed: bool)
@warning_ignore("unused_signal")
signal direction_held(direction: Global.Direction)
@warning_ignore("unused_signal")
signal direction_released(direction: Global.Direction)

# --- Trick Events ---
@warning_ignore("unused_signal")
signal sequence_resolved(candidates: Array[BaseTrick], path: Array[Global.Direction])
@warning_ignore("unused_signal")
signal trick_detected(trick_name: String)
@warning_ignore("unused_signal")
signal trick_started(trick: BaseTrick)
@warning_ignore("unused_signal")
signal trick_ended(trick: BaseTrick)
@warning_ignore("unused_signal")
signal trick_failed(trick: BaseTrick)

# --- Equipment Events ---
@warning_ignore("unused_signal")
signal equipment_changed(equipment: EquipmentData, tricks: Array[BaseTrick])

# --- Platform Events ---
@warning_ignore("unused_signal")
signal platform_lock_character(body: BaseCharacter)
@warning_ignore("unused_signal")
signal platform_unlock_character()
@warning_ignore("unused_signal")
signal platform_timeout()

# --- Grind Events ---
## Emitted by TrickSystem when a GrindTrick successfully resolves.
## Carries the ObjectGrindable the player will lock onto.
## REPLACES the old parameterless `is_on_griding` signal.
@warning_ignore("unused_signal")
signal grind_started(grindable: ObjectGrindable)

## Emitted by OnGridingState on a clean jump exit.
@warning_ignore("unused_signal")
signal grind_ended()

## Emitted by OnGridingState when the player falls off the end of the path.
@warning_ignore("unused_signal")
signal grind_failed()

## Legacy platform-style lock/unlock kept for other systems that still use them.
@warning_ignore("unused_signal")
signal grind_lock_character(body: BaseCharacter)
@warning_ignore("unused_signal")
signal grind_unlock_character()
