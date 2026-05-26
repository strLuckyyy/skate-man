extends Node

# --- Player Events ---
@warning_ignore("unused_signal")
signal player_lock_requested(body: CharacterBody2D)
@warning_ignore("unused_signal")
signal player_unlock_requested()
@warning_ignore("unused_signal")
signal player_caught()

# --- Opponent Events ---
@warning_ignore("unused_signal")
signal opponent_lock_requested(body: CharacterBody2D)
@warning_ignore("unused_signal")
signal opponent_unlock_requested()

# --- NPC Events ---

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

# --- Platform Events ---
@warning_ignore("unused_signal")
signal platform_lock_character(body: BaseCharacter)
@warning_ignore("unused_signal")
signal platform_unlock_character()
@warning_ignore("unused_signal")
signal platform_timeout()

# --- Grind Events ---
@warning_ignore("unused_signal")
signal grind_started(grindable: GrindableObject)
@warning_ignore("unused_signal")
signal grind_ended()
@warning_ignore("unused_signal")
signal grind_failed()
@warning_ignore("unused_signal")
signal grind_lock_character(body: BaseCharacter)
@warning_ignore("unused_signal")
signal grind_unlock_character()
