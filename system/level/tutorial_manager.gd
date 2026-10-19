class_name TutorialManager
extends RaceManager

signal tutorial_restart

@export var actions_required_to_end: Dictionary[Global.RaceLoopConditions, ColorRect]
@export var tricks_required_to_end:  Dictionary[TrickData, ColorRect]

@onready var marker_to_tele: Marker2D = $Marker2D


func setup(character: BaseCharacter):
	character.action_detected.connect(_action_detected)
	character.trick_system.trick_started.connect(_trick_detected)


func get_countdown_label() -> Label:
	return %CountdownLabel


func check_race_conditions() -> bool:
	var race_cond  := _check_race_conditions(actions_required_to_end)
	var trick_cond := _check_race_conditions(tricks_required_to_end)
	return race_cond and trick_cond


func _check_race_conditions(required: Dictionary) -> bool:
	if !required.is_empty():
		for action_key in required:
			if !required[action_key].visible:
				return false
	return true


func _action_detected(action: Global.RaceLoopConditions) -> void:
	print("action detected")
	_detected(actions_required_to_end, action)


func _trick_detected(trick: BaseTrick) -> void:
	print("trick detected")
	var data: TrickData = trick.trick_data
	_detected(tricks_required_to_end, data)


func _detected(required: Dictionary, value) -> void:
	if required.has(value): 
		required[value].visible = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is not BaseCharacter: return
	if not check_race_conditions():
		body.velocity = Vector2.ZERO
		body.set_deferred("global_position", marker_to_tele.global_position)
		tutorial_restart.emit()
		return
	super._on_area_2d_body_entered(body)
