class_name OnPlatformState
extends BaseState

func enter(p_character: BaseCharacter, _payload = null) -> void:
	super.enter(p_character, _payload)
	character.velocity = Vector2.ZERO
	controller.is_locked = true

func exit() -> void:
	controller.is_locked = false

func update(_delta: float) -> void:
	# A movimentação é controlada pela plataforma, não aqui.
	pass

func handle_input(_event: InputEvent) -> void:
	# Ignora todos os inputs do jogador.
	pass
