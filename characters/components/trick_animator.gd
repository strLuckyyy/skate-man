class_name TrickAnimator
extends Node

@export var anim_player: AnimationPlayer
@export var character: BaseCharacter

var is_executing_trick: bool = false
var current_trick_anim: StringName = ""

func _ready() -> void:
	# Conecta aos eventos globais do seu jogo
	EventBus.player_state_changed.connect(_on_state_changed)
	EventBus.trick_started.connect(_on_trick_started)
	EventBus.trick_ended.connect(_on_trick_ended) # Assumindo que você dispare isso

# 1. Trata as animações de manobra (Prioridade Máxima)
func _on_trick_started(trick: BaseTrick) -> void:
	is_executing_trick = true
	current_trick_anim = trick.trick_data.anim_id
	anim_player.play(current_trick_anim)

func _on_trick_ended(_trick: BaseTrick) -> void:
	is_executing_trick = false
	# Ao fim da trick, reavalia a animação base com o estado atual da FSM
	_update_base_animation(character.state_machine.get_current_state_id())

# 2. Trata as animações base da State Machine
func _on_state_changed(_old_state: Global.StateID, new_state: Global.StateID) -> void:
	# Se estiver no meio de uma trick, ignora a mudança de estado visual
	if is_executing_trick:
		return
		
	_update_base_animation(new_state)

# 3. Lógica interna de mapeamento Estado -> Animação
func _update_base_animation(state_id: Global.StateID) -> void:
	match state_id:
		Global.StateID.ON_FLOOR:
			# Aqui você pode ler a velocidade do character para decidir entre Idle e Run
			if character.is_moving():
				anim_player.play("run")
			else:
				anim_player.play("idle")
		
		Global.StateID.ON_AIR:
			if character.velocity.y < 0:
				anim_player.play("jump_up")
			else:
				anim_player.play("jump_fall")
				
		Global.StateID.ON_FALLING:
			anim_player.play("jump_fall")
			
		Global.StateID.TRICK_FAIL:
			anim_player.play("bail_out")
			
		Global.StateID.ON_GRIDING:
			anim_player.play("grind_idle")
