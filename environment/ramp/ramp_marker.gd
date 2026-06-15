class_name RampMarker
extends Area2D

## Marcação mínima para identificar "rampas" no nível para fins de percepção da IA.
##
## Não implementa nenhuma lógica de gameplay — é apenas um identificador de tipo
## (`is RampMarker`) que AIPerceptionRadar usa para distinguir rampas de outros
## corpos/áreas detectados via overlap.
##
## Como usar:
##   1. Adicione um Area2D na cena do nível, na posição da rampa
##      (ex: no topo/início da subida, onde a IA deveria "ver" a rampa).
##   2. Anexe este script a ele e adicione um CollisionShape2D filho cobrindo
##      a região que deve ser percebida como "rampa".
##   3. Configure collision_layer/collision_mask para que o AIPerceptionRadar
##      (Area2D) consiga detectá-lo via get_overlapping_areas().
##   4. AIPerceptionRadar lerá este nó automaticamente como "rampa próxima".
##
## monitoring = false porque este nó nunca precisa detectar nada por conta
## própria — ele só precisa ser detectado pelo radar do oponente.
## monitorable permanece true (default) para que o radar consiga vê-lo.

func _ready() -> void:
	monitoring = false
