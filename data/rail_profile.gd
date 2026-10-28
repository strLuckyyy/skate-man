class_name RailProfile2D
extends Resource

# =============================================================================
# RailProfile2D — a "receita" do trilho / fio.
#
# Este Resource NÃO calcula nem desenha nada sozinho: ele só guarda números.
# Quem lê estes valores é o GrindableObject quando você clica em "Bake rail":
#
#   Curva    -> RailBuilder2D         (forma da curva; é a base de tudo)
#   Visual   -> RailVisualBuilder     (gera os Line2D dentro do Path2D)
#   Colisão  -> RailCollisionBuilder  (gera o CollisionPolygon2D na GrindArea)
#   Assets   -> PropLineSpawner       (instancia prop_scene em GeneratedProps)
#
# IMPORTANTE: depois de mudar QUALQUER valor aqui, clique em "Bake rail" de novo
# no objeto. Nada é atualizado automaticamente.
#
# Os comentários "##" acima de cada variável aparecem como TOOLTIP no Inspector
# (passe o mouse sobre o nome da propriedade).
# =============================================================================


# -----------------------------------------------------------------------------
# CURVA — formato do fio entre RailStart e RailEnd.
# Visual e colisão são gerados a partir desta mesma curva.
# -----------------------------------------------------------------------------
@export_category("Curva")

## Quanto o fio "cai" no meio do vão, em pixels. 0 = fio reto (trilho rígido).
## Usado por: RailBuilder2D. Afeta visual e colisão (os dois seguem a mesma curva).
## A queda é aplicada para BAIXO no eixo Y LOCAL do Path2D (se o objeto estiver
## girado na hora do bake, o fio cai para o lado girado).
## O valor entra nos "handles" da Bézier, então a profundidade real no centro é
## ~75% do número digitado (50 vira ~37 px abaixo da reta start -> end).
## O valor é fixo: não diminui sozinho em vãos curtos (vão curto + sag alto = "U").
@export_range(0.0, 1000.0, 1.0) var sag_amount: float = 50.0

## Distância (px) entre os pontos em que a curva é amostrada (bake_interval).
## Mínimo efetivo: 2.
## Usado por: RailBuilder2D (define) e RailVisualBuilder / RailCollisionBuilder
## (usam os pontos amostrados).
## Menor = curva mais suave, porém mais pontos no Line2D e mais vértices no
## polígono de colisão (mais pesado). Maior = fio mais "quebrado"/angular.
## Também define a precisão de sample_baked() / get_closest_offset() no grind.
@export_range(2.0, 64.0, 1.0) var curve_bake_interval: float = 8.0


# -----------------------------------------------------------------------------
# VISUAL — aparência do fio (nós Line2D). Não afeta a colisão.
# -----------------------------------------------------------------------------
@export_category("Visual")

## Liga/desliga o desenho do fio (Line2D).
## Desligado: nenhuma linha é gerada (as antigas são removidas no bake), mas a
## curva e a colisão continuam existindo. Útil se o visual vem de sprite/tilemap.
@export var draw_line: bool = true

## Textura aplicada em TODOS os Line2D gerados. Vazio = linha de cor sólida.
## Veja também texture_mode.
## Obs.: no modo Tile a textura só repete de verdade se o Line2D tiver
## texture_repeat ativo, e o RailVisualBuilder atual não ativa isso.
@export var line_texture: Texture2D

## Espessura do desenho do fio, em pixels (Line2D.width). Vale para todas as
## linhas de visual_offsets.
## Só visual: NÃO muda a área de detecção do grind (isso é collision_thickness).
@export_range(0.5, 64.0, 0.5) var visual_width: float = 6.0

## Cor base do Line2D (default_color).
## Com line_texture, a cor MULTIPLICA a textura (branco = textura original).
## Sem textura, é a cor do fio.
@export var line_color: Color = Color.WHITE

## Como a textura é mapeada ao longo do fio:
## None = sem textura | Tile = repete a textura ao longo do comprimento (padrão;
## a textura é escalada pela largura da linha) | Stretch = estica UMA cópia da
## textura do início ao fim.
@export var texture_mode: Line2D.LineTextureMode = Line2D.LINE_TEXTURE_TILE

## z_index de cada Line2D gerado (relativo ao Path2D). Maior = desenhado na frente.
## Use para o fio passar atrás/à frente do personagem e do cenário. Só visual.
@export var visual_z_index: int = 0

## Linhas visuais paralelas à curva principal.
## Cada número é uma linha, deslocada em pixels PERPENDICULARMENTE à curva:
##   0.0 = a própria curva principal.
##   Positivo / negativo = lados opostos da curva. Num fio que vai da esquerda
##   para a direita, positivo fica ABAIXO e negativo ACIMA.
## Exemplo: [0.0, -20.0, 20.0] desenha três linhas (nomeadas RailLine_00, _01, _02).
## Lista vazia = o builder usa [0.0] (uma linha só).
## Apenas a curva principal (offset 0) é grindável: a colisão NÃO acompanha as
## linhas deslocadas. Se você tirar o 0.0 da lista, o fio grindável fica sem
## desenho visível.
@export var visual_offsets: PackedFloat32Array = PackedFloat32Array([0.0])


# -----------------------------------------------------------------------------
# COLISÃO — área de detecção que faz o personagem "pegar" o fio.
# -----------------------------------------------------------------------------
@export_category("Colisão")

## Liga/desliga a geração do CollisionPolygon2D dentro da GrindArea.
## Desligado: o bake remove o polígono antigo e não cria outro. A GrindArea fica
## sem formato e NÃO detecta o personagem (o trilho vira só decoração, sem grind).
@export var generate_collision: bool = true

## Largura TOTAL (px) da faixa de detecção em volta da curva (metade para cada
## lado; mínimo efetivo 1). É a "tolerância" para o personagem encostar e poder
## começar o grind.
## Maior = mais fácil de pegar o fio. Muito grande em curvas fechadas pode gerar
## um polígono inválido. É independente de visual_width.
@export_range(1.0, 128.0, 1.0) var collision_thickness: float = 6.0


# -----------------------------------------------------------------------------
# ASSETS REPETIDOS — props espalhados ao longo do trilho (postes, lâmpadas...).
# Usado por: PropLineSpawner. As instâncias ficam no nó filho "GeneratedProps".
# IMPORTANTE: os props são distribuídos na RETA entre RailStart e RailEnd e NÃO
# seguem a curva do sag.
# -----------------------------------------------------------------------------
@export_category("Distribuição de assets")

## Liga/desliga a geração de props repetidos. Só funciona se prop_scene estiver
## preenchida. Desligado: o bake remove os props existentes e não cria novos.
@export var spawn_props: bool = false

## Cena que será instanciada repetidamente (poste, lâmpada, isolador...).
## A raiz da cena PRECISA ser Node2D; se não for, o spawner avisa e interrompe.
@export var prop_scene: PackedScene

## Distância (px) de um prop até o próximo, medida na reta RailStart -> RailEnd.
## Mínimo efetivo 1. Menor = mais props (o bake tem trava de 4096 por rail).
@export_range(1.0, 2000.0, 1.0) var prop_spacing: float = 250.0

## Variação aleatória (± px) somada ao passo de cada prop, para o espaçamento
## ficar irregular. 0 = espaçamento perfeitamente regular.
## Obs.: a variação se ACUMULA passo a passo (o padrão vai "andando"). Mantenha
## bem menor que prop_spacing para não gerar props quase empilhados.
@export_range(0.0, 500.0, 1.0) var prop_spacing_jitter: float = 0.0

## Semente do sorteio do jitter. Mesma semente + mesmos parâmetros = mesmo
## resultado a cada bake. Mude o número para obter outra distribuição.
## Só tem efeito quando prop_spacing_jitter > 0.
@export var prop_seed: int = 42

## Distância (px) do início do trecho útil até o PRIMEIRO prop.
## 0 = primeiro prop logo no começo (já descontando prop_end_margin).
## Valores negativos são tratados como 0.
@export var prop_start_offset: float = 0.0

## Margem (px) livre nas DUAS pontas (início e fim) onde nenhum prop é criado.
## (Apesar do nome "end", vale para ambos os lados.) Limitada à metade do
## comprimento do trilho; se as duas margens cobrirem tudo, nenhum prop é gerado.
@export var prop_end_margin: float = 0.0

## Ligado: cada prop é girado para apontar na direção da reta RailStart -> RailEnd
## (útil para cercas/lâmpadas inclinadas). Não segue a tangente da curva.
## Desligado: o prop mantém a rotação herdada do objeto (sem rotação extra).
@export var align_props_to_segment: bool = false
