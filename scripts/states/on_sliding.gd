class_name OnSlide
extends State

func enter(_character: BaseCharacter) -> void:
	super.enter(_character)
	print("slide")

func update(_delta: float) -> void:
	character.apply_jump()

func exit() -> void:
	print("out slide")
