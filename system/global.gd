class_name Global
extends RefCounted

enum StateID {
	CAUGHT,
	TRICK_FAIL,
	ON_FLOOR,
	ON_AIR,
	ON_FALLING,
	ON_GRIDING,
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

enum ObstacleType {
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
	TRICK
}

enum AIGoal {
	CRUISE,
	DO_TRICKS,
	SAFE_LANDING,
	GRIND_CHAIN
}
