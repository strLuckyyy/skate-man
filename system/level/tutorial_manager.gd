class_name TutorialManager
extends RaceManager


@export var actions_required_to_end: Dictionary[Global.RaceLoopConditions, bool]
@export var tricks_required_to_end: Dictionary[TrickData, bool]


func setup(character: BaseCharacter):
	character.action_detected.connect(_action_detected)
	character.trick_system.trick_started.connect(_trick_detected)


func get_countdown_label() -> Label:
	return %CountdownLabel


func check_race_conditions() -> bool:
	for action_key in actions_required_to_end:
		if not actions_required_to_end[action_key]:
			return false
	
	for trick_key in tricks_required_to_end:
		if not tricks_required_to_end[trick_key]:
			return false
	
	return true


func _action_detected(action: Global.RaceLoopConditions) -> void:
	if actions_required_to_end.has(action):
		actions_required_to_end[action] = true


func _trick_detected(trick: BaseTrick) -> void:
	var data: TrickData = trick.trick_data
	
	if tricks_required_to_end.has(data):
		tricks_required_to_end[data] = true
	
	if data and "trick_type" in data:
		_action_detected(data.trick_type)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not check_race_conditions():
		var offset: Vector2 = body.global_position - global_position
		body.global_position = spawner.global_position + offset
		return
		
	super._on_area_2d_body_entered(body)
