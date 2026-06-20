class_name Global
extends RefCounted

enum StateID {
	CAUGHT,
	TRICK_FAIL,
	ON_FLOOR,
	ON_AIR,
	ON_FALLING,
	ON_GRIDING,
	ON_PLATAFORM,
	NONE,
}

enum Direction {
	UP,
	DOWN,
	RIGHT,
	LEFT,
	NONE,
}


# --- TRICK ENUMs ---
enum TrickType {
	MOMENTARY, # Executa uma vez e termina
	CONTINUOUS, # Executa enquanto tecla é segurada
	CHARGED, # Carrega enquanto segura, executa ao soltar
}

enum ReasonToExitGrind {
	JUMPED,
	END_OF_RAIL
}


# --- OBSTACLES ENUMs ---
enum PlatformAnim {
	MOVE_UP,
	MOVE_DOWN,
	MOVE_LEFT,
	MOVE_RIGHT,
	IDLE,
}

enum TargetType {
	NONE,
	PLATAFORM,
	ELEVATOR,
	RAIL,
	RAMP,
	BARRIER,
	HOLE
}


# --- AI ENUMs ---
enum AIDecision {
	NOTHING,
	JUMP,
	TRICK,
	NONE
}

enum AIGoal {
	CRUISE,
	DO_TRICKS,
	SAFE_LANDING,
	GRIND_CHAIN
}

# Constantes para chaves do Blackboard para evitar erros de digitação
class BBKeys:
	const NEAREST_TARGET_TYPE = "nearest_target_type"
	const NEAREST_TARGET_DIST = "nearest_target_dist"
	const NEAREST_TARGET_NODE = "nearest_target_node"
	const HAS_TARGET_AHEAD    = "has_target_ahead"
