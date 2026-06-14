class_name ActionScorer
extends Resource

## Representa uma ação candidata dentro de um play_utility_action (ex: NOTHING,
## JUMP, ou uma categoria de TRICK). O score final é o produto de evaluate()
## de cada Consideration — qualquer fator 0.0 zera a ação inteira (veto).
##
## Para TRICK, várias instâncias podem coexistir (uma por categoria de trick,
## ex: "grind tricks", "air tricks"), cada uma com suas próprias Considerations.
## trick_category é opcional e serve apenas para o ActionScorer "se identificar"
## ao executar — play_utility_action decide o que isso significa.

## A decisão correspondente a esta ação (NOTHING, JUMP ou TRICK).
@export var decision: Global.AIDecision = Global.AIDecision.NOTHING

## Identificador opcional de categoria, usado quando decision == TRICK e há
## múltiplos ActionScorers de TRICK (ex: "grind", "air"). Vazio = sem distinção,
## play_utility_action usa o pool de tricks padrão do estado.
@export var trick_category: String = ""

## As perguntas que compõem o score desta ação. Produto de evaluate() de cada uma.
@export var considerations: Array[Consideration] = []

## Nome legível para debug (ex: "Pular", "Trick de Grind").
@export var debug_name: String = ""


## Calcula o score final: produto de evaluate() de cada Consideration.
## Lista vazia retorna 1.0 (neutro — nenhum fator restringe esta ação).
## Qualquer Consideration retornando 0.0 zera o produto inteiro (veto).
func compute_score(context: UtilityContext) -> float:
	if considerations.is_empty():
		return 1.0

	var score: float = 1.0
	for consideration in considerations:
		if consideration == null:
			push_warning("ActionScorer '%s': Consideration nula no array — ignorando." % _display_name())
			continue

		var factor: float = consideration.evaluate(context)
		score *= factor

		# Curto-circuito: se já zerou, não há razão para continuar calculando.
		if score == 0.0:
			break

	return score


func _display_name() -> String:
	return debug_name if not debug_name.is_empty() else Global.AIDecision.find_key(decision)
