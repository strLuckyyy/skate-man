@abstract
class_name Consideration
extends Resource

## Uma Consideration representa "uma pergunta que a IA faz a si mesma"
## (ex: "estou rápido?", "tem rail por perto?", "acabei de pular?").
##
## O fluxo de evaluate() é sempre:
##   1. _get_raw_value(context)         -> valor bruto (qualquer escala)
##   2. normalizar para 0.0-1.0          usando input_min/input_max
##   3. curve.sample(valor_normalizado)  -> fator final 0.0-1.0
##
## O resultado é multiplicado com os de outras Considerations no ActionScorer.
## Um resultado 0.0 "veta" a ação inteira — use isso para cooldowns/condições
## impossíveis (ex: "JUMP" com cooldown ativo -> fator 0.0).

## Curve desenhada no editor. Eixo X = valor normalizado (0.0-1.0) do input,
## eixo Y = fator de utilidade (0.0-1.0) que essa Consideration retorna.
@export var curve: Curve

## Range esperado do valor bruto retornado por _get_raw_value().
## Usado para normalizar antes de consultar a curve.
## Ex: para "velocidade", input_min=0.0, input_max=velocidade_maxima_do_equipamento.
@export var input_min: float = 0.0
@export var input_max: float = 1.0

## Nome legível, usado em debug/print (ex: "Cooldown de Pulo").
@export var debug_name: String = ""


## Implementado por cada subclasse concreta: lê o valor bruto do contexto.
## Não faz normalização nem aplica curve — isso é feito por evaluate().
@abstract
func _get_raw_value(context: UtilityContext) -> float


## Normaliza o valor bruto para 0.0-1.0 e aplica a curve.
## Valores fora de [input_min, input_max] são clampados antes da curve.
func evaluate(context: UtilityContext) -> float:
	var raw: float = _get_raw_value(context)

	if curve == null:
		push_warning("Consideration '%s' sem curve definida — retornando 0.0 (veta a ação)." % _display_name())
		return 0.0

	var range_size: float = input_max - input_min
	var normalized: float

	if range_size == 0.0:
		# Range degenerado — evita divisão por zero. Trata como "no máximo".
		normalized = 1.0
	else:
		normalized = (raw - input_min) / range_size
		normalized = clampf(normalized, 0.0, 1.0)

	return curve.sample(normalized)


func _display_name() -> String:
	return debug_name if not debug_name.is_empty() else get_script().get_global_name()
