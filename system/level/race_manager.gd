class_name RaceManager
extends Node2D

enum RaceState { INIT, RACING, FINISHED }

@export var spawner: Spawner


var state: RaceState = RaceState.INIT
var finished_racers: Array = []
var _player: Player
var _opponent: OpponentAI


func is_racing() -> bool: return state == RaceState.RACING

func get_countdown_label() -> Label:
	return %CountdownLabel


func _ready() -> void:
	EventBus.characters_spawned.connect(
		func(racers: Array[BaseCharacter]):
			for i in range(racers.size()):
				if racers[i] is Player: 
					_player = racers.pop_at(i)
					break
			_opponent = racers.pop_back()
	)


func _physics_process(_delta: float) -> void:
	if !_player or !_opponent: return
	if _player.race_ended or _opponent.race_ended: 
		return
	
	var player_x: float = _player.get_x_position()
	var opponent_x: float = _opponent.get_x_position()
	
	if _player.race_position == 1 and opponent_x > player_x:
		_player.race_position = 2
	elif _player.race_position == 2 and opponent_x < player_x:
		_player.race_position = 1


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body is BaseCharacter: return
	var b = body as BaseCharacter
	
	if b in finished_racers: return
	
	finished_racers.append(b)
	b.end_race()
	
	if body is Player:
		var pos = finished_racers.find(b) + 1
		EventBus.race_finished.emit(pos)
