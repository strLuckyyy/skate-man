class_name AIAssessor
extends Node

var profile: AIProfileData

func setup(p_profile: AIProfileData) -> void:
	profile = p_profile

# --- Rolagens de Probabilidade (RNG) ---

## Define se a IA vai executar a ação com sucesso ou se vai hesitar/falhar.
func roll_success() -> bool:
	if profile == null: return true
	return randf() <= profile.perfection_chance

## Define se a IA vai tomar uma atitude arriscada (ex: mandar manobra no chão plano).
func roll_aggression() -> bool:
	if profile == null: return false
	return randf() <= profile.aggression

## Define se a IA vai optar pelo caminho mais difícil/rápido (ex: pular pro corrimão).
func roll_optimal_path() -> bool:
	if profile == null: return false
	return randf() <= profile.optimal_path_chance

# --- Seleção de Manobras ---

## Seleciona uma manobra aleatória do pool disponível.
func get_random_trick(trick_pool: Array[TrickData], requires_grind: bool = false) -> Array[Global.Direction]:
	if trick_pool.is_empty():
		return []
	
	var valid_tricks: Array[TrickData] = trick_pool
	
	# Filtra apenas manobras de grind se necessário
	if requires_grind:
		valid_tricks = trick_pool.filter(_is_grind_trick)
		# Fallback de segurança caso não ache manobras de grind
		if valid_tricks.is_empty(): 
			valid_tricks = trick_pool
			
	var selected_trick: TrickData = valid_tricks.pick_random()
	return selected_trick.sequence

## Função auxiliar para identificar se a TrickData suporta Grind
func _is_grind_trick(trick: TrickData) -> bool:
	var grind_state = Global.StateID.ON_GRIDING
	return grind_state in trick.state_available or grind_state in trick.conditional_state_available
