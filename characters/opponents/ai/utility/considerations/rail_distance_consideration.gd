class_name RailDistanceConsideration
extends Consideration

## "Tem rail por perto?" — lê a distância (em pixels) até o GrindableObject
## mais próximo detectado pelo AIPerceptionRadar.
##
## Tipicamente usada em ActionScorers de TRICK (categoria grind) ou JUMP:
## quanto mais perto o rail, maior a propensão a pular/preparar para grindar.
##
## Como distância MENOR = MAIS relevante, mas Considerations normalmente
## seguem "maior valor normalizado = mais utilidade", a curve deve ser
## DESCENDENTE: normalizado=0 (rail muito perto, distância <= input_min)
## -> fator alto (ex: 1.0); normalizado=1 (rail no limite do alcance do radar,
## distância >= input_max) -> fator baixo (ex: 0.0 ou próximo).
##
## SETUP:
##   - input_min: distância mínima considerada (geralmente 0.0).
##   - input_max: alcance do radar / distância a partir da qual "rail
##     próximo" não tem mais relevância (ex: igual ao raio da Area2D do radar).
##
## Quando nearest_rail_distance == INF (nada no alcance), o valor normalizado
## é clampado em 1.0 -> extremidade "rail longe/inexistente" da curve. Garanta
## que a curve em normalizado=1.0 retorne um fator que faça sentido para
## "sem rail detectado" (tipicamente baixo, mas não necessariamente 0.0 —
## 0.0 vetaria a ação inteira mesmo quando outros fatores são bons).


func _get_raw_value(context: UtilityContext) -> float:
	return context.nearest_rail_distance
