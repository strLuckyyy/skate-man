class_name UtilityContext
extends RefCounted

## Snapshot do estado do mundo, montado uma vez por _tick() de play_utility_action.
## Todas as Considerations leem deste objeto — nunca acessam _char diretamente,
## para que o cálculo de score seja 100% determinístico a partir de um único snapshot.

# --- Estado do personagem ---
var current_state:      Global.StateID = Global.StateID.NONE
var speed:               float = 0.0      # velocity.length() do personagem
var can_jump:            bool  = false    # _char.was_jumped() / pode pular agora

# --- Cooldowns / fadiga (em segundos desde a última ocorrência) ---
# INF significa "nunca aconteceu ainda" — útil para Considerations que tratam
# isso como "totalmente recuperado".
var time_since_last_jump:  float = INF
var time_since_last_trick: float = INF
var time_since_decision: Dictionary = {}  # Global.AIDecision -> float (segundos)

# --- Percepção do mundo (via AIPerceptionRadar) ---
# INF significa "nada detectado no range do radar".
var nearest_rail_distance: float = INF
var nearest_ramp_distance: float = INF


func get_time_since_decision(decision: Global.AIDecision) -> float:
	return time_since_decision.get(decision, INF)
