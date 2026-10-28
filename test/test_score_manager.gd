extends GdUnitTestSuite

var sut: ScoreManager

func before_test() -> void:
	sut = auto_free(ScoreManager.new()) as ScoreManager


func test_trick_detected() -> void:
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


func test_trick_fail() -> void:
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
	
	var expected_score := 200.0 / 2.0
	assert_float(sut.score).is_equal(expected_score)
	assert_int(sut.combo_amount).is_equal(0)
	assert_float(sut.current_time).is_equal(0.0)
	assert_signal(sut).is_emitted("score_updated", expected_score, 0)


func test_trick_fail_other_character() -> void:
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


func test_combo_expiration() -> void:
	sut.score = 300.0
	sut.combo_amount = 2
	sut.current_time = 0.25

	monitor_signals(sut)
	sut._physics_process(0.3)

	assert_float(sut.current_time).is_equal(0.0)
	assert_int(sut.combo_amount).is_equal(0)
	assert_signal(sut).is_emitted("score_updated", 300.0, 0)
