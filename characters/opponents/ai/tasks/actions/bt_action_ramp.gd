@tool
class_name BTActionRamp
extends BTAction

@export var interaction_distance: float = 80.0 # Distância para o pulo

func _tick(_delta: float) -> Status:
	var _char := agent as OpponentAI
	if not _char: return FAILURE
	
	var dist: float = blackboard.get_var(Global.BBKeys.NEAREST_TARGET_DIST, INF)
	
	# 1. Ainda está longe? Continua remando até a beirada.
	if dist > interaction_distance:
		if _char.is_on_floor(): _char.apply_push()
		return RUNNING
		
	# 2. IA já está executando algo (não interromper)
	if _char.trick_system.is_busy:
		return RUNNING
		
	# 3. Chegou na distância ideal, hora de pular!
	if _char.is_on_floor():
		if _char.ai_assessor.roll_success():
			_char.apply_jump()
		return RUNNING # Continua na task para aplicar o trick no próximo frame no ar
		
	# 4. Está no ar e em cima do corrimão: Hora da Manobra
	if blackboard.get_var("on_air", false):
		var pool = _char.equipment.get_trick_pool(Global.StateID.ON_AIR)
		var seq  = _char.ai_assessor.get_random_trick(pool, true) # true = Exige manobra de Grind
		
		if not seq.is_empty() and _char.ai_assessor.roll_success():
			_char.make_trick(seq)
		else:
			# IA errou o timing ou falhou no roll. Vai cair em cima do corrimão sem manobra.
			pass 
			
		return SUCCESS
		
	return FAILURE
