@tool
class_name BTActionCruise
extends BTAction

var _push_cd: float = 0.0

func _tick(delta: float) -> Status:
	var _char := agent as OpponentAI
	if not _char: return FAILURE
	
	if _push_cd > 0.0: _push_cd -= delta
	
	# 1. Tentar uma manobra aleatória no chão se a IA for agressiva
	if not _char.trick_system.is_busy and _char.is_on_floor():
		# Uma chance bem pequena por frame para não spammar manobras infinitamente
		if _char.ai_assessor.roll_aggression() and randf() < 0.02: 
			var pool = _char.equipment.get_trick_pool(_char.state_machine.get_current_state_id())
			var seq  = _char.ai_assessor.get_random_trick(pool, false)
			
			if not seq.is_empty():
				# Checa se ela consegue acertar ou se vai tropeçar no próprio skate
				if _char.ai_assessor.roll_success():
					_char.make_trick(seq)
				return SUCCESS
				
	# 2. Movimentação padrão (Push)
	if _push_cd <= 0.0 and _char.is_on_floor():
		_char.apply_push()
		# Variação de tempo entre remadas para parecer mais orgânico (0.4s a 0.8s)
		_push_cd = randf_range(0.4, 0.8)
		
	return SUCCESS
