class_name OpponentAI
extends BaseCharacter

signal trick_sequence(candidates: Array[BaseTrick], path: Array[Global.Direction])


func _ready() -> void:
	super._ready()
	trick_system.setup(self, equipment, character_animator, trick_sequence)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	move_and_slide()


func make_trick(sequence: Array[Global.Direction]):
	trick_sequence.emit(equipment.get_tricks(), sequence)


func apply_jump() -> bool:
	var pre_vel: float = velocity.y
	velocity = controller.apply_jump(velocity, equipment.current_equipment)
	if pre_vel == velocity.y:
		return false
	return true


func get_caught() -> void:
	super.get_caught()
