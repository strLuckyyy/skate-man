class_name RampDistanceConsideration
extends Consideration

## "Tem rampa por perto?" — lê a distância (em pixels) até o RampMarker
## mais próximo detectado pelo AIPerceptionRadar.
##
## Tipicamente usada em ActionScorers de JUMP: quanto mais perto a rampa,
## maior a propensão a pular (para aproveitar o impulso da rampa).
##
## Mesma lógica de normalização/curve que RailDistanceConsideration: curve
## DESCENDENTE (rampa perto = normalizado baixo = fator alto).
##
## SETUP:
##   - input_min: distância mínima considerada (geralmente 0.0).
##   - input_max: alcance do radar / distância a partir da qual "rampa
##     próxima" não tem mais relevância.
##
## Quando nearest_ramp_distance == INF (nenhum RampMarker no alcance), o
## valor normalizado é clampado em 1.0 -> extremidade "sem rampa" da curve.


func _get_raw_value(context: UtilityContext) -> float:
	return context.nearest_ramp_distance
