class_name SpeedConsideration
extends Consideration

## "Estou rápido?" — lê a velocidade atual do personagem (em px/s).
##
## Tipicamente usada em ActionScorers de JUMP (curve ascendente: mais
## velocidade = mais propício a pular) ou NOTHING (curve descendente: pouca
## velocidade = mais propício a continuar acelerando em vez de pular/trickar).
##
## input_min/input_max devem ser configurados no .tres conforme a velocidade
## mínima/máxima esperada do equipamento (ex: 0.0 a max_speed do EquipmentData).


func _get_raw_value(context: UtilityContext) -> float:
	return context.speed
