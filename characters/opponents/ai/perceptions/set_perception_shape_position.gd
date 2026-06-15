extends CollisionShape2D

@export var agent:     OpponentAI
@export var min_speed: float = 0.0
@export var smoothing: float = 8.0

var max_speed:  float
var min_offset: float
var max_offset: float


func _ready() -> void:
	min_offset = position.x
	max_offset = position.x * 5


func _physics_process(delta: float) -> void:
	if max_speed != agent.get_max_boost_speed():
		max_speed  = agent.get_max_boost_speed()
	
	var speed := agent.velocity.length()
	var target_offset := clampf(
		remap(speed, min_speed, max_speed, min_offset, max_offset),
		min_offset, max_offset
	)

	var direction = sign(agent.velocity.x) if agent.velocity.x != 0 else 1.0
	var target_x  = target_offset * direction

	position.x = lerp(position.x, target_x, delta * smoothing)
