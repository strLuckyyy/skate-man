extends GdUnitTestSuite

# ScoreManager tem class_name, então pode ser instanciado diretamente.
# Os testes chamam os handlers internos para isolar a lógica dos sinais externos.
var sut: ScoreManager

func before_test() -> void:
	sut = auto_free(ScoreManager.new()) as ScoreManager


func test_trick_detected_adds_bonus_increments_combo_resets_timer_and_emits_signal() -> void:
	# BaseTrick real evita um mock incompatível com o parâmetro tipado do handler.
	var trick := auto_free(BaseTrick.new()) as BaseTrick
	var trick_data := auto_free(TrickData.new()) as TrickData
	trick.trick_data = trick_data
	
	assert_object(trick).is_not_null()
	assert_object(trick.trick_data).is_not_null()

	trick.trick_data.score_bonus = 125
	sut.score = 50.0
	sut.combo_amount = 2
	sut.current_time = 1.0

	monitor_signals(sut)
	sut._trick_detected(trick)

	assert_float(sut.score).is_equal(175.0)
	assert_int(sut.combo_amount).is_equal(3)
	assert_float(sut.current_time).is_equal(ScoreManager.TIME)
	assert_signal(sut).is_emitted("score_updated", 175.0, 3)


func test_trick_fail_for_current_character_halves_score_and_clears_combo() -> void:
	# O handler ignora falhas de outros personagens; aqui usamos o mesmo objeto
	# como referência e como personagem que falhou.
	var character := auto_free(BaseCharacter.new()) as BaseCharacter
	sut.character = character
	sut.score = 200.0
	sut.combo_amount = 4
	sut.current_time = 2.5
	
	var trick := auto_free(BaseTrick.new()) as BaseTrick
	var trick_data := auto_free(TrickData.new()) as TrickData
	trick.trick_data = trick_data
	
	monitor_signals(sut)
	sut._trick_fail(character, trick)
	
	assert_float(sut.score).is_equal(100.0)
	assert_int(sut.combo_amount).is_equal(0)
	assert_float(sut.current_time).is_equal(0.0)
	assert_signal(sut).is_emitted("score_updated", 100.0, 0)


func test_trick_fail_from_another_character_does_not_change_score() -> void:
	var own_character := auto_free(BaseCharacter.new()) as BaseCharacter
	var other_character := auto_free(BaseCharacter.new()) as BaseCharacter
	
	sut.character = own_character
	sut.score = 200.0
	sut.combo_amount = 2
	sut.current_time = 3.0

	monitor_signals(sut)
	sut._trick_fail(other_character, auto_free(BaseTrick.new()))

	assert_float(sut.score).is_equal(200.0)
	assert_int(sut.combo_amount).is_equal(2)
	assert_float(sut.current_time).is_equal(3.0)
	assert_signal(sut).wait_until(50).is_not_emitted("score_updated")


func test_physics_process_expires_combo_and_emits_updated_score() -> void:
	sut.score = 300.0
	sut.combo_amount = 2
	sut.current_time = 0.25

	monitor_signals(sut)
	sut._physics_process(0.3)

	assert_float(sut.current_time).is_equal(0.0)
	assert_int(sut.combo_amount).is_equal(0)
	assert_signal(sut).is_emitted("score_updated", 300.0, 0)
