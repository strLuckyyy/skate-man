extends BTAction

func _tick(delta: float) -> Status:
	# 1. Procura o componente no Blackboard
	var randomizer: RandomizerComponent = blackboard.get_var("randomizer_service", null)
	if not randomizer:
		return FAILURE
		
	# 2. Pede a decisão matemática pura ao componente
	var decisao: Global.AIDecision = randomizer.get_next_decision()
	
	# 3. Guarda o resultado no Blackboard para que as outras tarefas (nós irmãos) saibam o que foi decidido
	blackboard.set_var("current_decision", decisao)
	
	return SUCCESS
