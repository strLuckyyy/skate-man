extends Node

var active_boosts: Dictionary = {}

func _ready() -> void:
	EventBus.request_boost.connect(_on_request_boost)
	EventBus.request_boost_reset.connect(_on_request_boost_reset)

func _on_request_boost(boost_amount: float, character: BaseCharacter) -> void:
	if not is_instance_valid(character):
		return
	
	if not active_boosts.has(character):
		active_boosts[character] = 0.0
		character.tree_exited.connect(_on_character_exited.bind(character))
	
	var max_boost: float = character.get_max_boost_speed()
	var current_accumulated: float = active_boosts[character]
	
	var new_boost: float = clamp(current_accumulated + boost_amount, 0.0, max_boost)
	
	active_boosts[character] = new_boost
	character.current_boost_speed = new_boost
	
	#EventBus.boost_updated.emit(character, new_boost, max_boost)

func _on_request_boost_reset(character: BaseCharacter) -> void:
	if not is_instance_valid(character) or not active_boosts.has(character):
		return
	
	var max_boost: float = character.get_max_boost_speed()
	
	active_boosts[character] = 0.0
	character.current_boost_speed = 0.0
	
	#EventBus.boost_updated.emit(character, 0.0, max_boost)

func _on_character_exited(character: BaseCharacter) -> void:
	active_boosts.erase(character)
