extends GdUnitTestSuite

var sut: InputBuffer

func before_test() -> void:
	print("\n--- INICIANDO TESTE ---")
	print("EventBus válido: ", is_instance_valid(EventBus))

	for node in get_tree().root.get_children():
		print(node.name, " | ", node.get_path())

	sut = InputBuffer.new()
	var timer := Timer.new()
	timer.name = "Timer"
	sut.add_child(timer)
	add_child(sut)


func after_test() -> void:
	print("\n--- FINALIZANDO TESTE ---")
	print("EventBus válido: ", is_instance_valid(EventBus))

	for node in get_tree().root.get_children():
		print(node.name, " | ", node.get_path())

	if is_instance_valid(sut):
		sut.queue_free()


func test_push_input_keeps_direction_in_buffer() -> void:
	sut._push_input(Global.Direction.LEFT)

	assert_array(sut.get_input_buffer()).is_equal([Global.Direction.LEFT])


func test_buffer_drops_oldest_input_when_capacity_is_exceeded() -> void:
	for i in range(InputBuffer.BUFFER_SIZE):
		sut._push_input(Global.Direction.LEFT)
	sut._push_input(Global.Direction.RIGHT)

	var buffer := sut.get_input_buffer()
	assert_int(buffer.size()).is_equal(InputBuffer.BUFFER_SIZE)
	assert_int(buffer[buffer.size() - 1]).is_equal(Global.Direction.RIGHT)
	assert_int(buffer.count(Global.Direction.LEFT)).is_equal(InputBuffer.BUFFER_SIZE - 1)


func test_get_input_buffer_returns_copy_not_internal_array() -> void:
	sut._push_input(Global.Direction.UP)
	var copy := sut.get_input_buffer()
	copy.clear()

	assert_array(sut.get_input_buffer()).is_equal([Global.Direction.UP])


func test_consume_buffer_returns_inputs_and_clears_original() -> void:
	sut._push_input(Global.Direction.LEFT)
	sut._push_input(Global.Direction.DOWN)

	var consumed := sut.consume_buffer()

	assert_array(consumed).is_equal([Global.Direction.LEFT, Global.Direction.DOWN])
	assert_array(sut.get_input_buffer()).is_empty()


func test_timer_timeout_clears_buffer() -> void:
	sut._push_input(Global.Direction.RIGHT)
	sut._on_timer_timeout()

	assert_array(sut.get_input_buffer()).is_empty()


func test_unhandled_input_pressed_emits_signal_and_stores_direction() -> void:
	var event := InputEventAction.new()
	event.action = "left"
	event.pressed = true
	sut._unhandled_input(event)
	
	assert_array(sut.get_input_buffer()).is_equal([Global.Direction.LEFT])
	assert_signal(EventBus).is_emitted("direction_input", Global.Direction.LEFT, true)


func test_unhandled_input_released_emits_release_signal() -> void:
	var event := InputEventAction.new()
	event.action = "right"
	event.pressed = false
	
	sut._unhandled_input(event)
	
	assert_signal(EventBus).is_emitted(
		"direction_released",
		Global.Direction.RIGHT
	)


func test_direction_held_emits_signal_while_key_is_pressed() -> void:
	monitor_signals(EventBus)

	# Simula a tecla direita sendo pressionada.
	Input.action_press("right")

	# Atualiza o estado das direções seguradas.
	sut._process(0.016)

	assert_signal(EventBus).is_emitted(
		"direction_held",
		Global.Direction.RIGHT
	)

	Input.action_release("right")


func test_direction_held_does_not_emit_signal_after_key_is_released() -> void:
	monitor_signals(EventBus)

	# Pressiona e depois solta a tecla.
	Input.action_press("right")
	Input.action_release("right")

	# Atualiza o estado das direções seguradas.
	sut._process(0.016)

	assert_signal(EventBus).is_not_emitted(
		"direction_held",
		Global.Direction.RIGHT
	)


func test_direction_held_emits_signal_on_consecutive_frames() -> void:
	monitor_signals(EventBus)

	Input.action_press("right")

	sut._process(0.016)
	sut._process(0.016)

	assert_signal(EventBus).is_emitted(
		"direction_held",
		Global.Direction.RIGHT
	)

	Input.action_release("right")
