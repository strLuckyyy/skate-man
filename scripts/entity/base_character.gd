class_name BaseCharacter
extends CharacterBody2D

## Indica a velocidade máxima conquistada levando em consideração o boost
const MAX_ABSOLUTE_SPEED: float = 800.
## Indica a velocidade máxima consquistada sem considerar o boost
const MAX_SIMPLE_SPEED:   float = 300.
const ACCELERATION:       float = .25
const FRICTION:           float = .05

## Indica o máximo de boost acumulável
const MAX_BOST_AMOUNT:    int = 15
## Indica a quantidade acumulada de boost atual
var current_boost_amount: int = 0

var direction: Vector2 = Vector2.ZERO

const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	move()


## função abstrata: movimento
func move() -> void:
	pass
