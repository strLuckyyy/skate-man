# Documentação de Arquitetura — Jogo de Tricks com Carrinho de Mão (Hand Truck)

## Visão Geral do Projeto

Este é um jogo 2D desenvolvido em Godot 4, com GDScript, onde o jogador controla um personagem que utiliza um carrinho de mão (hand truck) para se mover e executar manobras (tricks). O jogo possui mecânicas de movimento baseadas em física, um sistema de estados para o personagem, um sistema de tricks ativadas por sequências de input, trocas de equipamento e plataformas móveis interativas (elevadores).

A arquitetura é dividida em cinco grandes subsistemas que se comunicam entre si:

1. Player (personagem e controle físico)
2. StateMachine + States (estados comportamentais do personagem)
3. TrickSystem + EquipmentManager (manobras e equipamentos)
4. InputBuffer (captura e gerenciamento de inputs para tricks)
5. Platform System (plataformas móveis e área de espera)

Existe também um sistema global de apoio composto por `Global` (enums compartilhados) e `GameManager` (gerenciador de cena).

---

## 1. Sistemas Globais de Apoio

### 1.1 Global (`global.gd`)

`Global` é uma classe estática que estende `RefCounted`. Ela não é instanciada nem adicionada à cena — serve exclusivamente como namespace de enums compartilhados por todos os sistemas.

**Enum `StateID`** — identifica cada estado possível do personagem:
- `DEAD` — personagem morto/pego
- `TRICK_FAIL` — falha ao executar uma trick
- `ON_FLOOR` — no chão
- `ON_AIR` — no ar (após pular ou sair de plataforma)
- `ON_FALLING` — caindo após tempo máximo no ar
- `ON_GRIDING` — em modo de grind (escorregando em superfície)
- `WAITING` — aguardando em plataforma móvel
- `NONE` — estado nulo/inválido

**Enum `Direction`** — representa as direções usadas como input para sequências de tricks:
- `UP`, `DOWN`, `RIGHT`, `LEFT`, `NONE`

Esses dois enums são usados em praticamente todos os outros sistemas como tipo de dado compartilhado.

---

### 1.2 GameManager (`game_manager.gd`)

`GameManager` estende `Node` e funciona como autoload (singleton de cena). Ele mantém uma referência ao objeto `Player` e ao `EquipmentData` padrão (`hand_truck_data.tres`), que é carregado via `preload` em tempo de compilação.

**Funcionamento:**
- `Player._ready()` se auto-registra no `GameManager`: `GameManager.player = self`
- Com isso, o `GameManager` recebe a referência ao player assim que ele entra na cena
- O `_ready()` do `GameManager` verifica se `player` não é null antes de chamar `player.equipment.equip(hand_truck)`, mas como o `_ready()` do `GameManager` (autoload) roda antes do `_ready()` do `Player`, esse check sempre falha na inicialização

**Nota importante:** A injeção de equipamento via `GameManager._ready()` nunca executa porque `player` ainda é null no momento em que o autoload inicializa. O equipamento padrão é, na prática, equipado pelo `EquipmentManager._ready()` via `@export var default_equipment`.

---

## 2. Sistema do Personagem (Player)

### 2.1 Hierarquia de cenas

O personagem é composto por duas cenas encadeadas:

**Cena base do personagem (`CharacterBody2D`):**
- `Sprite2D` — visual do personagem
- `CollisionShape2D` — hitbox
- `TrickSystem` — sistema de manobras
- `EquipmentManager` — gerencia o equipamento atual
- `Controller` — lógica de controle físico
- `AnimationPlayer` — reprodução de animações
- `AnimationTree` — máquina de estados de animação

**Cena do Player (herda a cena base, adiciona):**
- `InputBuffer` — captura e armazena sequências de direções
- `StateMachine` — máquina de estados comportamental
- `Camera2D` — câmera que segue o jogador

O script `player.gd` é atribuído à raiz da cena do Player (`CharacterBody2D`).

---

### 2.2 Player (`player.gd`)

`Player` estende `CharacterBody2D` e é o nó central que conecta todos os subsistemas. Ele gerencia a física do personagem frame a frame.

**Variáveis de estado público:**
- `is_caught: bool` — true quando o personagem foi capturado (ativa `DEAD`)
- `can_jump: bool` — controla se o pulo está disponível; modificado pelos estados
- `_is_jumping: bool` — flag interna
- `_jumped: int` — contador de pulos realizados (impede pulo duplo)
- `can_grind: bool` — ativo quando o personagem está sobre uma área de grind
- `_is_griding: bool` — flag interna de grind
- `can_move: bool` — habilita ou desabilita o movimento horizontal
- `_is_moving: bool` — true quando `abs(velocity.x) > 1.0`

**Métodos públicos de leitura de estado:**
- `is_jumping() -> bool`
- `is_grinding() -> bool`
- `is_moving() -> bool`
- `reset_jump() -> void` — zera `_jumped`, chamado por `OnAirState` ao pousar

**`_ready()`:**
1. `GameManager.player = self` — injeta a referência no autoload
2. `state_machine.setup(self)` — inicializa a máquina de estados com referência ao player
3. `equipment.equipment_changed.connect(trick_system._on_equipment_changed)` — conecta o sinal de troca de equipamento ao trick system

**`_physics_process(delta)`** — loop principal de física, executado a cada frame físico:
1. Aplica gravidade se não estiver no chão: `velocity += get_gravity() * delta`
2. Atualiza `_is_moving` com base em `abs(velocity.x) > 1.0`
3. Se não `is_caught`:
   a. Chama `trick_system.process(input_buffer.consume_buffer(), can_grind, state_machine.get_current_state_id())` — processa tricks com o buffer consumido
   b. Chama `calculate_velocity()` — aplica movimento e pulo
4. Chama `move_and_slide()` — move o personagem com colisão

**`calculate_velocity()`** — delega para `movement()` e `jump()`

**`movement()`:**
- Se `can_move` for false, retorna imediatamente sem aplicar movimento horizontal
- Caso contrário: `velocity = controller.apply_movement(velocity, equipment.current_equipment)`

**`jump()`:**
- Verifica: input "jump" pressionado **E** `can_jump == true` **E** `_jumped == 0`
- Se todas as condições forem verdadeiras: aplica `velocity.y = controller.apply_jump(equipment.current_equipment)` e incrementa `_jumped`
- Isso implementa um sistema de pulo único — `_jumped` é zerado por `OnAirState` ao detectar que o personagem tocou o chão (`reset_jump()`)

**`player_caught()`:**
- Transiciona para `Global.StateID.DEAD`

**`enter_waiting(plataform: Path2D)`:**
- Chamado por `WaitingArea` quando o personagem entra na área de espera de uma plataforma
- Transiciona para `Global.StateID.WAITING` passando a referência da plataforma como payload
- Chama `controller.move(velocity, plataform.global_position)` para posicionar o personagem próximo à plataforma

**`on_grinding_area(_can_grind: bool, area: GrindArea)`:**
- Atualiza `can_grind` com base em sinal vindo de uma `GrindArea`

---

### 2.3 PlayerController (`player_controller.gd`)

`PlayerController` estende `Node2D` e contém exclusivamente lógica de física de movimento. Não tem estado próprio — todos os inputs são passados como parâmetros e o resultado é retornado.

**`@export var input_deadzone: float = 0.1`** — zona morta do analógico/teclado

**`move(velocity: Vector2, to: Vector2) -> Vector2`:**
- Aplica `lerp` na componente X da velocidade em direção à posição alvo `to.x`
- O fator de interpolação é `get_physics_process_delta_time()`, o que produz uma aproximação gradual
- Retorna o vetor modificado
- Usado exclusivamente em `enter_waiting` para guiar o player até a posição da plataforma

**`apply_movement(velocity: Vector2, equipment_data: EquipmentData) -> Vector2`:**
- Lê o eixo horizontal: `Input.get_axis("move_left", "move_right")`
- Calcula `target_speed = direction * equipment_data.max_speed`
- Calcula `accel` e `friction` como frações de `equipment_data.acceleration/friction * delta`, clampados a `[0.0, 1.0]` para uso direto como fator de `lerp`
- Se há input além da deadzone: `velocity.x = lerp(velocity.x, target_speed, accel)`
- Caso contrário (sem input): `velocity.x = lerp(velocity.x, 0.0, friction)`
- Retorna o vetor com a componente X modificada

**`apply_jump(equipment_data: EquipmentData) -> float`:**
- Retorna `-equipment_data.jump_modifier` (valor negativo porque Y cresce para baixo no Godot)

---

## 3. Máquina de Estados (StateMachine + States)

### 3.1 Arquitetura geral

O sistema de estados segue o padrão State Machine com estados como objetos. Cada estado é uma classe que estende `BaseState`, que por sua vez estende `RefCounted` (não `Node`). Isso significa que os estados **não participam do ciclo de vida da SceneTree** — não recebem `_ready()`, `_process()`, nem `_physics_process()`. Todo o ciclo de vida é gerenciado manualmente pela `StateMachine`.

A comunicação entre estados e a máquina é feita por **sinal**: cada estado emite `transition_requested(state_id)` e a `StateMachine` escuta todos os estados.

---

### 3.2 BaseState (`base_state.gd`)

Classe abstrata base para todos os estados.

**`signal transition_requested(next_state_name: BaseState)`** — emitido pelo estado quando quer transicionar. O parâmetro é, na prática, um `Global.StateID`, não um `BaseState` (o nome do parâmetro é enganoso).

**Variáveis:**
- `character: CharacterBody2D = null` — referência ao player; injetada em `enter()`
- `state_id: Global.StateID = Global.StateID.NONE` — identificador do estado; definido em `_init()` de cada subclasse

**Métodos virtuais (todos com implementação vazia):**
- `enter(character, payload = null)` — chamado ao entrar no estado; recebe o player e um payload opcional
- `exit()` — chamado ao sair do estado
- `update(delta)` — chamado a cada frame físico pela `StateMachine`

---

### 3.3 StateMachine (`state_machine.gd`)

`StateMachine` estende `Node` e é filho do `Player`. Gerencia qual estado está ativo e roteia as atualizações.

**`_ready()`:**
- Instancia todos os estados com `.new()`: `DeadState`, `TrickFailState`, `OnFloorState`, `OnAirState`, `OnFallingState`, `OnGridingState`, `WaitingState`
- Armazena em `states: Dictionary` mapeando `Global.StateID → BaseState`
- Conecta o sinal `transition_requested` de cada estado ao método `_on_transition_requested`

**`setup(p: CharacterBody2D)`:**
- Chamado por `Player._ready()`
- Injeta a referência ao player
- Se já existe um `current_state`, chama `exit()` nele
- Define `current_state` como `OnFloorState` e chama `enter(character)`
- É o ponto de inicialização real da máquina — garante que `character` está disponível antes do primeiro `enter()`

**`transition_to(state_id, payload = null)`:**
- Guard: se `current_state.state_id == state_id`, ignora (sem transição para o mesmo estado)
- Busca o novo estado via `get_state(state_id)`; retorna se não encontrado
- Chama `current_state.exit()`
- Atualiza `current_state` para o novo estado
- Chama `current_state.enter(character, payload)`

**`_on_transition_requested(next_state_id, payload)`:**
- Receptor do sinal `transition_requested` de todos os estados
- Simplesmente delega para `transition_to(next_state_id, payload)`

**`_physics_process(delta)`:**
- A cada frame físico, chama `current_state.update(delta)` se `current_state` não for null
- É assim que os estados recebem processamento contínuo

**`get_current_state_id() -> Global.StateID`:**
- Retorna `current_state.state_id` ou `Global.StateID.NONE` com erro se não houver estado

**`get_state(state_id) -> BaseState`:**
- Busca no dicionário `states`; retorna null com `push_error` se não encontrado

---

### 3.4 Estados individuais

#### OnFloorState

**Identidade:** `Global.StateID.ON_FLOOR`

**`enter()`:**
- Armazena referência ao `character`
- Seta `character.can_jump = true` — o personagem pode pular quando está no chão

**`update()`:**
- Se `not character.is_on_floor()`: emite `transition_requested` para `ON_AIR`
- A transição é emitida a cada frame enquanto o personagem não estiver no chão

---

#### OnAirState

**Identidade:** `Global.StateID.ON_AIR`

**Constantes:**
- `COYOTE_TIMEOUT: float = 0.1` — 100ms de janela de coyote time (permite pulo mesmo após sair da borda)
- `FALL_TIMEOUT: float = 1.5` — após 1.5s no ar sem pousar, transiciona para `ON_FALLING`

**Variáveis internas:**
- `_coyote_elapsed: float` — acumulador de delta para o coyote timer
- `_fall_elapsed: float` — acumulador de delta para o fall timer

Ambos os acumuladores substituem o uso de `Timer` (que não funciona com `RefCounted` por estar fora da SceneTree).

**`enter()`:**
- Reseta `_coyote_elapsed = 0.0` e `_fall_elapsed = 0.0`
- Seta `character.can_jump = true` — ao entrar no estado de ar, o coyote time começa ativo

**`update(delta)`:**
- Incrementa ambos os acumuladores com `delta`
- Se `_coyote_elapsed >= 0.1`: `character.can_jump = false` — janela de coyote expirou
- Se `_fall_elapsed >= 1.5`: emite `transition_requested` para `ON_FALLING`
- Se `character.is_grinding()`: emite `transition_requested` para `ON_GRIDING`
- Se `character.is_on_floor()`: chama `character.reset_jump()` e emite para `ON_FLOOR`

---

#### OnFallingState

**Identidade:** `Global.StateID.ON_FALLING`

Estado ativado quando o personagem fica muito tempo no ar sem pousar (mais de 1.5s).

**`enter()`:**
- `character.can_jump = false` — não pode mais pular durante a queda

**`update()`:**
- Se `character.is_grinding()`: transiciona para `ON_GRIDING`
- Se `character.is_on_floor()`: transiciona para `ON_FLOOR`

---

#### OnGridingState

**Identidade:** `Global.StateID.ON_GRIDING`

Estado ativado quando o personagem está fazendo grind em uma superfície especial.

**`enter()`:**
- Armazena referência ao `character`

**`update()`:**
- Se não está no chão E não está mais fazendo grind: transiciona para `ON_AIR`
- Se está no chão: transiciona para `ON_FLOOR`

---

#### DeadState

**Identidade:** `Global.StateID.DEAD`

Estado ativado por `player_caught()`.

**`enter()`:**
- `character.is_caught = true` — bloqueia o loop principal do player (o `_physics_process` não chama `calculate_velocity` nem o trick system quando `is_caught` é true)

**`update()`:**
- Estado terminal; nenhuma transição automática implementada

---

#### TrickFailState

**Identidade:** `Global.StateID.TRICK_FAIL`

Estado ativado quando uma trick falha.

**`enter()`:**
- `character.velocity = Vector2.ZERO` — para o personagem imediatamente

**`update()`:**
- Estado em desenvolvimento; sem transições automáticas implementadas

---

#### WaitingState

**Identidade:** `Global.StateID.WAITING`

Estado ativado quando o personagem entra na área de uma plataforma móvel.

**Variável:** `plataform: Path2D = null` — referência à plataforma associada

**`enter(character, payload)`:**
- Se `character` é válido: `character.can_move = true` e armazena referência
- Valida que `payload` é um `BasePlataform`; emite `push_error` e retorna se não for
- Armazena `plataform = payload`
- Se a plataforma tem o método `start()`: chama `plataform.start()` e conecta o sinal `plataform_timeout` a `exit` (com `is_connected` para evitar dupla conexão)
- Se não tem `start()`: emite `push_error`

**`exit()`:**
- Se `plataform` é válido e o sinal está conectado: desconecta `plataform_timeout`
- Se `character` é válido: `character.can_move = true`
- Emite `transition_requested` para `ON_FLOOR`
- Reseta `plataform = null`

O `WaitingState` é o único estado que usa um payload para receber dados externos (a referência da plataforma).

---

## 4. Sistema de Tricks

O sistema de tricks é composto por quatro camadas: dados (`TrickData`), contexto de execução (`TrickContext`), comportamento base e específico (`BaseTrick`, subclasses), e orquestração (`TrickSystem`).

### 4.1 TrickData (`trick_data.gd`)

`TrickData` estende `Resource` — é um arquivo `.tres` que define os dados de uma trick específica, editável no Godot Inspector.

**Campos:**
- `trick_name: String` — nome legível da trick
- `sequence: Array[Global.Direction]` — sequência de direções que ativa a trick (ex: `[DOWN, RIGHT]`)
- `state_available: Array[Global.StateID]` — estados em que a trick pode ser executada incondicionalmente (ex: `[ON_AIR, ON_FALLING]`)
- `conditional_state_available: Array[Global.StateID]` — estados adicionais disponíveis somente se houver oportunidade de grind
- `boost: float = 1.5` — modificador de velocidade aplicado ao executar a trick
- `score_bonus: int = 100` — pontuação adicionada ao executar a trick
- `anim_id: StringName` — identificador da animação correspondente

**Exemplo — flip_back.tres:**
```
trick_name = "Back Flip"
sequence = [DOWN, RIGHT]          # Global.Direction 1 = DOWN, 3 = RIGHT
state_available = [ON_AIR, ON_FALLING]   # StateID 3 = ON_AIR, 4 = ON_FALLING
```

---

### 4.2 BaseTrick (`base_trick.gd`)

`BaseTrick` estende `Node2D`. Cada trick no jogo é uma cena (`.tscn`) cujo nó raiz tem um script que estende `BaseTrick`. O `@export var trick_data: TrickData` é configurado no Inspector de cada cena de trick.

**`can_execute(context: TrickContext) -> bool`:**
1. Copia `trick_data.state_available` para uma variável local
2. Se `context.get_grind_opportunity()` for true: anexa `trick_data.conditional_state_available` à lista
3. Retorna `true` somente se o `state_id` do contexto estiver na lista **E** `match_input()` retornar true

**`execute(context: TrickContext) -> void`:**
- Implementação vazia na classe base — deve ser sobrescrita por cada subclasse

**`match_input(buffer: Array[Global.Direction]) -> bool`:**
- Verifica se os últimos `N` elementos do buffer correspondem à `trick_data.sequence`
- N = `sequence.size()`
- Compara elemento a elemento da direita para a esquerda: `buffer[buffer.size() - sequence.size() + i] == sequence[i]`
- Retorna `true` se todos os elementos corresponderem

**Subclasse exemplo — BackFlip (`flip_back.gd`):**
```
class_name BackFlip
extends BaseTrick

func execute(context: TrickContext) -> void:
    print("executing backflip", context)
```
Sobrescreve `execute()` com a lógica específica da trick (ainda em desenvolvimento).

---

### 4.3 TrickContext (`trick_context.gd`)

`TrickContext` estende `RefCounted`. É um Value Object — um snapshot do estado do jogo no momento em que uma trick foi detectada.

**Campos (todos privados, acessados por getters):**
- `_state_id: Global.StateID` — estado atual do personagem
- `_grind_opportunity: bool` — se há oportunidade de grind disponível
- `_input_buffer: Array[Global.Direction]` — cópia do buffer de input no momento

**`build_context(state_id, grind_opportunity, input_buffer)`:**
- Inicializa todos os campos de uma vez. Chamado pelo `TrickSystem` antes de `can_execute`/`execute`.

**`get_input_buffer() -> Array[Global.Direction]`:**
- Retorna `.duplicate()` do buffer — cópia, não referência

---

### 4.4 TrickSystem (`trick_system.gd`)

`TrickSystem` estende `Node` e é filho do Player. Orquestra a detecção e execução de tricks a cada frame.

**Variáveis:**
- `equipment: EquipmentData` — equipamento atual (sincronizado via sinal)
- `_tricks: Array[BaseTrick]` — lista de tricks disponíveis para o equipamento atual

**`_on_equipment_changed(new_equipment, new_tricks)`:**
- Receptor do sinal `equipment_changed` do `EquipmentManager`
- Atualiza `equipment` e `_tricks`
- É assim que o `TrickSystem` sabe quais tricks estão disponíveis

**`process(buffer, grind_opportunity, state_id)`:**
- Chamado a cada frame por `Player._physics_process()` com o buffer já consumido
- Chama `_find_matching_trick(buffer)` para encontrar uma trick cujo `sequence` final está no buffer
- Se encontrou: cria um `TrickContext`, chama `try_execute(context, trick)`

**`_find_matching_trick(buffer) -> BaseTrick`:**
- Itera por `_tricks` e retorna a primeira que satisfaz `trick.match_input(buffer)`

**`try_execute(context, trick)`:**
- Valida que nenhum dos parâmetros é null
- Chama `trick.can_execute(context)` — verifica estado e grind
- Se permitido: chama `trick.execute(context)`

---

### 4.5 EquipmentManager (`equipment_manager.gd`)

`EquipmentManager` estende `Node` e é filho do Player. Gerencia qual equipamento está ativo e quais tricks ele disponibiliza.

**`@export var default_equipment: EquipmentData`** — configurado no Inspector; equipamento padrão ao iniciar

**`signal equipment_changed(equipment: EquipmentData, tricks: Array[BaseTrick])`** — emitido sempre que o equipamento muda; ouvido pelo `TrickSystem`

**`_ready()`:**
- Se `current_equipment == null`: chama `equip(default_equipment)`
- Garante que o jogo começa com um equipamento ativo

**`equip(equipment: EquipmentData)`:**
- Valida que `equipment` não é null
- Seta `current_equipment = equipment`
- Chama `_build_tricks()` para instanciar as cenas de tricks
- Emite `equipment_changed` com o equipamento e a lista de tricks

**`_build_tricks() -> Array[BaseTrick]`:**
- Itera por `current_equipment.tricks` (que é `Array[PackedScene]`)
- Para cada `PackedScene`: chama `.instantiate() as BaseTrick`
- Se o cast falhar (nó raiz não é `BaseTrick`): emite `push_error` e pula
- Retorna array de instâncias de `BaseTrick` polimórficas

**Exemplo — hand_truck_data.tres:**
O equipamento `hand_truck` referencia 12 cenas de tricks: `brake`, `flip_back`, `flip_front`, `grind_lateral`, `grind_normal`, `grind_point`, `jump_and_walk`, `one_wheel`, `spin_back`, `spin_floor`, `spin_front`, `surf`.

---

## 5. Sistema de Input (InputBuffer)

### 5.1 InputBuffer (`input_buffer.gd`)

`InputBuffer` estende `Node` e é filho do Player. Captura inputs direcionais e os armazena em um buffer circular com timeout.

**Constantes:**
- `BUFFER_TIMEOUT: float = 0.5` — após 0.5 segundos sem input, o buffer é limpo automaticamente
- `BUFFER_SIZE: int = 8` — máximo de 8 entradas; a mais antiga é removida quando excedido

**`_ready()`:**
- Busca o filho `$Timer` e configura `wait_time = BUFFER_TIMEOUT`

**`_unhandled_input(event: InputEvent)`:**
- Recebe todos os eventos de input não consumidos pela UI
- Filtra para aceitar apenas: `InputEventJoypadButton`, `InputEventJoypadMotion`, `InputEventAction`, `InputEventScreenDrag`, `InputEventScreenTouch`
- Para cada direção (`up`, `down`, `right`, `left`): se a ação foi pressionada, chama `_push_input()` com a direção correspondente
- Cobre teclado (via `InputEventAction`), joystick (via `InputEventJoypadButton/Motion`) e touch (via `InputEventScreenTouch/Drag`)

**`_push_input(dir: Global.Direction)`:**
- Adiciona `dir` ao final de `_input_buffer`
- Se o tamanho excede `BUFFER_SIZE`: remove o primeiro elemento (`pop_front()`)
- Reinicia o timer de timeout (`_buffer_time.start()`)

**`_on_timer_timeout()`:**
- Limpa `_input_buffer` completamente

**`get_input_buffer() -> Array[Global.Direction]`:**
- Retorna `.duplicate()` do buffer (cópia, não referência)

**`consume_buffer() -> Array[Global.Direction]`:**
- Copia o buffer, limpa o original, retorna a cópia
- Chamado pelo `Player._physics_process()` a cada frame — garante que o mesmo input não ative duas tricks em frames consecutivos

---

## 6. Sistema de Plataformas

O sistema de plataformas é composto por uma hierarquia de cenas e scripts que gerenciam plataformas móveis que o personagem pode usar para se locomover.

### 6.1 Hierarquia de cena — BasePlatform

```
Path2D (base_plataform.gd)
├── PathFollow2D
│   ├── RemoteTransform2D → AnimatableBody2D  (sincroniza posição física)
│   └── RemoteTransform2D → WaitingArea       (sincroniza posição da área de detecção)
├── AnimatableBody2D                           (corpo físico que colide com o player)
│   ├── Sprite2D
│   └── CollisionShape2D
├── WaitingArea (waiting_area.gd)              (Area2D que detecta o player)
│   └── CollisionShape2D
└── AnimationPlayer                            (controla as animações de movimento)
```

O `PathFollow2D` lê o progresso ao longo da curva `Path2D` e usa dois `RemoteTransform2D` para mover simultaneamente o `AnimatableBody2D` (corpo físico) e a `WaitingArea` (área de detecção). Assim, a plataforma física e sua área de espera se movem juntas ao longo do caminho.

---

### 6.2 BasePlataform (`base_plataform.gd`)

`BasePlataform` estende `Path2D` e define a interface base para todas as plataformas.

**`@onready` nodes:**
- `_path_follow: PathFollow2D`
- `_anima_body: AnimatableBody2D`
- `_wait_area: WaitingArea`
- `_anim_player: AnimationPlayer`

**`_ready()`:**
- Chama `set_enable(false)` — plataforma inicia desativada
- Chama `_wait_area.propagate_call("set_process", [true])` — mas a `WaitingArea` permanece ativa para detectar o player

**`start()`:**
- Chama `set_enable(true)` — ativa a plataforma

**`exit()`:**
- Chama `_wait_area.propagate_call("set_process", [false])` — desativa a detecção após o uso

**`set_enable(is_enable: bool)`:**
- Propaga `set_process(is_enable)` para si mesmo, para o `_path_follow`, para o `_anima_body` e para o `_anim_player`
- Controla se a plataforma está processando (se está se movendo e sendo física)

---

### 6.3 ElevatorPlataform (`elevator_plataform.gd`)

`ElevatorPlataform` estende `BasePlataform`. Implementa uma plataforma elevador que sobe e desce automaticamente, depois notifica o jogador que o transporte terminou.

**`signal plataform_timeout`** — emitido quando o ciclo de animação completo (subida + descida) termina; ouvido por `WaitingState.exit()`

**`enum _animName { MOVE_UP, MOVE_DOWN }`** — enum privado para os dois estados de animação

**`elevator_animation_names: Dictionary`** — mapeia o enum para o nome da animação no `AnimationPlayer`:
- `MOVE_UP → "elevator/move_up"`
- `MOVE_DOWN → "elevator/move_down"`

**`start(_dir: _animName = _animName.MOVE_UP)`:**
- Chama `super.start()` para ativar a plataforma via `BasePlataform.start()`
- Reproduz a animação correspondente a `_dir` no `_anim_player`
- Registra `current_anim = _dir`

**`exit()`:**
- Chama `super.exit()` para desativar a `WaitingArea`
- Chama `set_enable(false)` para desativar a plataforma
- Reseta `_path_follow.progress_ratio = 0.0` para reutilização futura
- Emite `plataform_timeout` para notificar o `WaitingState`

**`_on_animation_player_animation_finished(anim_name)`:**
- Conectado ao sinal do `AnimationPlayer` na cena
- Verifica se a animação terminada é a que estava sendo reproduzida
- Se terminou `MOVE_UP`: chama `start(MOVE_DOWN)` — inicia a descida automaticamente
- Se terminou `MOVE_DOWN`: chama `exit()` — ciclo completo, notifica o player
- Else: emite `push_error` (estado inconsistente)

---

### 6.4 WaitingArea (`waiting_area.gd`)

`WaitingArea` estende `Area2D` e é o ponto de detecção do player para a plataforma.

**`@export var plataform: Path2D`** — configurado no Inspector; aponta para o `Path2D` pai (ou para outra plataforma)

**`_on_body_entered(body: CharacterBody2D)`:**
- Sinal conectado na cena
- Verifica se `body` tem o método `enter_waiting`
- Se sim: chama `body.enter_waiting(plataform)` — passa a referência da plataforma para o player

---

## 7. Fluxo Completo — Uso de uma Plataforma Elevador

A seguir, o fluxo passo a passo do momento em que o player entra na `WaitingArea` até retornar ao chão:

1. O player se move horizontalmente e entra na `CollisionShape2D` da `WaitingArea`
2. `WaitingArea._on_body_entered(player)` dispara
3. Como `player` tem o método `enter_waiting`, chama `player.enter_waiting(plataform)`
4. `Player.enter_waiting()` chama `state_machine.transition_to(WAITING, plataform)`
5. `StateMachine.transition_to()` chama `current_state.exit()` (ex: `OnFloorState.exit()`) e depois `WaitingState.enter(character, plataform)`
6. `WaitingState.enter()`: valida o payload, armazena `plataform`, chama `plataform.start()` e conecta `plataform.plataform_timeout → WaitingState.exit`
7. `ElevatorPlataform.start()` ativa a plataforma e inicia a animação `MOVE_UP`
8. O `AnimationPlayer` move o `PathFollow2D` para cima via keyframes; os `RemoteTransform2D` sincronizam `AnimatableBody2D` e `WaitingArea`
9. O player está sobre o `AnimatableBody2D` e é arrastado para cima por colisão física
10. Quando `MOVE_UP` termina, `_on_animation_player_animation_finished` detecta e chama `start(MOVE_DOWN)`
11. A plataforma desce com a animação `MOVE_DOWN`
12. Quando `MOVE_DOWN` termina, `exit()` é chamado: desativa a plataforma, reseta `progress_ratio = 0.0`, emite `plataform_timeout`
13. `WaitingState.exit()` é chamado via o sinal conectado: desconecta o sinal, `character.can_move = true`, emite `transition_requested(ON_FLOOR)`
14. `StateMachine` recebe o sinal e chama `transition_to(ON_FLOOR)`: `WaitingState.exit()` é finalizado, `OnFloorState.enter()` é chamado com `can_jump = true`
15. O player retoma controle normal

---

## 8. Fluxo Completo — Execução de uma Trick

1. Player pressiona `DOWN` seguido de `RIGHT` (sequência do Back Flip)
2. `InputBuffer._unhandled_input()` captura cada pressionamento e chama `_push_input(DOWN)` e depois `_push_input(RIGHT)`
3. O buffer agora contém `[..., DOWN, RIGHT]`; o timeout é reiniciado
4. Em `Player._physics_process()`: `trick_system.process(input_buffer.consume_buffer(), can_grind, state_machine.get_current_state_id())` é chamado
5. `consume_buffer()` retorna `[..., DOWN, RIGHT]` e limpa o buffer
6. `TrickSystem.process()` chama `_find_matching_trick([..., DOWN, RIGHT])`
7. Itera por `_tricks`; chega no `BackFlip` cuja `trick_data.sequence = [DOWN, RIGHT]`
8. `BackFlip.match_input()`: verifica os últimos 2 elementos do buffer — encontra `[DOWN, RIGHT]` — retorna `true`
9. `_find_matching_trick` retorna a instância `BackFlip`
10. `TrickSystem` cria `TrickContext` com `state_id = ON_AIR`, `grind_opportunity = false`, `input_buffer = [DOWN, RIGHT]`
11. `try_execute(context, backflip)` é chamado
12. `BackFlip.can_execute(context)`: verifica se `ON_AIR` está em `state_available = [ON_AIR, ON_FALLING]` — sim. Verifica `match_input` novamente — sim. Retorna `true`
13. `BackFlip.execute(context)` é chamado — lógica da trick é executada

---

## 9. Diagrama de Dependências entre Scripts

```
Global (enums)
    └── usado por todos os scripts abaixo

GameManager (autoload)
    └── referencia Player

Player
    ├── PlayerController     (aplica física de movimento)
    ├── StateMachine         (gerencia estados comportamentais)
    │   ├── OnFloorState
    │   ├── OnAirState
    │   ├── OnFallingState
    │   ├── OnGridingState
    │   ├── WaitingState     ──→ BasePlataform / ElevatorPlataform
    │   ├── DeadState
    │   └── TrickFailState
    ├── InputBuffer          (captura sequências direcionais)
    ├── TrickSystem          (detecta e executa tricks)
    │   ├── TrickContext     (snapshot imutável do frame)
    │   └── BaseTrick        (polimorfismo via PackedScene)
    │       └── BackFlip, Brake, FlipFront, ... (subclasses)
    └── EquipmentManager     (gerencia equipamento e suas tricks)
        └── EquipmentData    (Resource com dados do equipamento)
            └── TrickData    (Resource com dados de cada trick)

BasePlataform (Path2D)
    └── WaitingArea          (detecta player → chama enter_waiting)
    └── ElevatorPlataform    (herda BasePlataform)
```

---

## 10. Convenções e Padrões Arquiteturais

**Padrão State Machine:** Estados como objetos `RefCounted` com ciclo de vida manual (`enter`, `exit`, `update`). Comunicação por sinal (`transition_requested`). A máquina centraliza transições e garante que `exit` do estado anterior sempre roda antes do `enter` do novo.

**Padrão Value Object (TrickContext):** O contexto é construído uma vez por frame e passado por valor para `can_execute` e `execute`. Imutável após `build_context`.

**Padrão Resource para dados:** `TrickData` e `EquipmentData` são `Resource` (arquivos `.tres`), separando dados de comportamento. Facilita criação de novos equipamentos e tricks no editor sem alterar código.

**Padrão Component:** `PlayerController`, `InputBuffer`, `TrickSystem`, `EquipmentManager` e `StateMachine` são nós filhos do Player com responsabilidades isoladas. O `Player` orquestra mas não implementa lógica específica de nenhum subsistema.

**Herança de cenas:** A cena base do personagem define a estrutura comum; a cena do Player herda e adiciona os nós específicos de gameplay. `ElevatorPlataform` herda `BasePlataform` da mesma forma.

**Polimorfismo via PackedScene:** Tricks são cenas instanciadas em runtime. `EquipmentManager._build_tricks()` instancia cada `PackedScene` e faz cast para `BaseTrick`. Subclasses sobrescrevem `execute()` sem alterar o sistema de detecção.

**Propagação via sinal:** A troca de equipamento (`equipment_changed`) desacopla `EquipmentManager` de `TrickSystem`. O `WaitingState` usa sinal para ser notificado pelo elevador (`plataform_timeout`) sem acoplar a plataforma ao sistema de estados.
