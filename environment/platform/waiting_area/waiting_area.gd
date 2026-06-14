class_name WaitingArea
extends Area2D

signal character_entered(body: BaseCharacter)
signal character_exited(body: BaseCharacter)

var target_character: BasePlatform.TargetCharacter = BasePlatform.TargetCharacter.ANY

func _on_body_entered(body: Node2D) -> void:
	if body is not BaseCharacter: return
	if not _matches_target(body): return
	character_entered.emit(body)

func _on_body_exited(body: Node2D) -> void:
	if body is not BaseCharacter: return
	if not _matches_target(body): return
	character_exited.emit(body)

func _matches_target(body: BaseCharacter) -> bool:
	match target_character:
		BasePlatform.TargetCharacter.PLAYER:   return body is Player
		BasePlatform.TargetCharacter.OPPONENT: return body is OpponentAI
		_: return true
