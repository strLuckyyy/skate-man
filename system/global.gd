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

enum ReasonToExitGrind {
	JUMPED,
	END_OF_RAIL
}

enum PlatformAnim {
	MOVE_UP,
	MOVE_DOWN,
	MOVE_LEFT,
	MOVE_RIGHT,
	IDLE,
}

enum TrickType {
	MOMENTARY, # Executa uma vez e termina
	CONTINUOUS, # Executa enquanto tecla é segurada
	CHARGED, # Carrega enquanto segura, executa ao soltar
}

enum AIDecision {
	NOTHING,
	JUMP,
	TRICK
}
