class_name FatigueConsideration
extends Consideration

## "Acabei de fazer isso?" — implementa a fadiga de escolha: penaliza
## temporariamente uma ação que acabou de ser escolhida, recuperando
## gradualmente ao longo do tempo.
##
## Diferente de CooldownConsideration (veto duro, tipicamente 0.0/1.0), esta
## Consideration é pensada para uma curve de RECUPERAÇÃO GRADUAL:
##   - normalizado próximo de 0 (acabou de escolher)  -> fator baixo (ex: 0.1)
##   - normalizado próximo de 1 (tempo suficiente passou) -> fator alto (ex: 1.0)
##
## Isso é o que garante variedade em escolha determinística (maior score
## vence): se TRICK venceu agora, seu fator de fadiga cai, então nos próximos
## ticks score(TRICK) = score_base x fator_fadiga_baixo provavelmente perde
## para outras ações com fadiga em 1.0 — mesmo que score_base(TRICK) continue
## sendo o maior "base".
##
## SETUP:
##   - tracked_decision: qual decisão esta fadiga rastreia.
##   - input_max: quantos segundos até a fadiga estar totalmente recuperada
##     (ex: 4.0 segundos).
##   - curve recomendada: ascendente suave de (0, ~0.1) até (1, 1.0) — nunca
##     exatamente 0.0 aqui, pois 0.0 seria um VETO permanente (a ação nunca
##     mais poderia vencer até o tempo passar, o que é o comportamento de
##     CooldownConsideration, não deste). Se quiser que a ação fique
##     impossível por um tempo fixo, use CooldownConsideration; use esta
##     para "menos provável por um tempo".
##
## time_since_decision == INF (nunca escolhida) é clampado para normalizado=1.0
## -> fator máximo, ou seja, sem penalidade na primeira escolha possível.

## Qual decisão esta fadiga rastreia (NOTHING, JUMP ou TRICK).
@export var tracked_decision: Global.AIDecision = Global.AIDecision.TRICK


func _get_raw_value(context: UtilityContext) -> float:
	return context.get_time_since_decision(tracked_decision)
