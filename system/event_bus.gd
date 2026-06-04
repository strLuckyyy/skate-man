extends Node

# --- Characters Events ---
@warning_ignore("unused_signal")
signal character_caught(character: BaseCharacter)

# --- Race Events ---
@warning_ignore("unused_signal")
signal race_started()
@warning_ignore("unused_signal")
signal race_ended()
@warning_ignore("unused_signal")
signal score_updated(new_score: float)

# --- Trick Events ---
@warning_ignore("unused_signal")
signal trick_detected(trick: BaseTrick)
@warning_ignore("unused_signal")
signal trick_failed(trick: BaseTrick)
