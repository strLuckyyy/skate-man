extends CollisionShape2D


@export var agent: OpponentAI
var _position: Vector2 = Vector2.ZERO
var _speed:    float   = 0.0

func _process(_delta: float) -> void: 
	if _speed != agent.get_velocity().x:
		_speed = agent.get_velocity().x
	
	if _speed > agent.get_velocity().x:
		_position.x -= _speed / 100
	else:
		_position.x = position.x + (_speed / 500)
	
	set_position(_position)
	
