class_name CooldownConsideration
extends Consideration

## "Já posso fazer isso de novo?" — lê o tempo (em segundos) desde a última
## vez que uma ação específica foi executada, e retorna um fator que
## tipicamente é 0.0 enquanto em cooldown e 1.0 após o cooldown terminar.
##
## Veto: se a curve mapear "tempo < cooldown_duration" para 0.0, qualquer
## ActionScorer com esta Consideration terá score 0 (totalmente proibido)
## até o cooldown acabar — sem precisar de `if` separado em play_utility_action.
##
## SETUP:
##   - tracked_decision define QUAL ação está sendo monitorada
##     (ex: Global.AIDecision.JUMP para um cooldown de pulo).
##   - input_max deve ser igual à duração do cooldown desejado, em segundos
##     (ex: 2.0 para "2 segundos de cooldown").
##   - A curve recomendada para um cooldown "hard" (proibido até acabar,
##     depois liberado) é um degrau: 0.0 do início até x=1.0 (que corresponde
##     a time = input_max), depois 1.0. Como a normalização clampa em 1.0,
##     basta a curve ir de (0,0) a (1,0) e ter (1,1) — ou seja, valor 0 até
##     normalizado=1, e 1 exatamente em normalizado=1. Para um cooldown "soft"
##     (recuperação gradual), use uma curve ascendente suave em vez de degrau —
##     veja FatigueConsideration para esse caso, que é o uso mais comum.
##
## Quando time_since_* é INF (ação nunca ocorreu), o valor normalizado será
## clampado em 1.0 — ou seja, "nunca fiz isso" é tratado como "totalmente
## liberado", o que é o comportamento esperado (sem cooldown na primeira vez).

## Qual ação rastrear o cooldown. Use JUMP ou TRICK conforme o ActionScorer.
@export var tracked_decision: Global.AIDecision = Global.AIDecision.JUMP


func _get_raw_value(context: UtilityContext) -> float:
	match tracked_decision:
		Global.AIDecision.JUMP:
			return context.time_since_last_jump
		Global.AIDecision.TRICK:
			return context.time_since_last_trick
		_:
			# NOTHING não tem cooldown dedicado no contexto atual.
			return context.get_time_since_decision(tracked_decision)
