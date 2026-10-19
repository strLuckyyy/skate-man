extends GdUnitTestSuite

# Este teste assume que SaveManager é um Autoload chamado "SaveManager".
# Como o script fornecido não declara class_name, obter o Autoload evita chutar
# um caminho res:// que depende da organização do projeto.
var sut: Node
var original_file_existed := false
var original_file_bytes := PackedByteArray()
var original_game_data: Dictionary = {}

func before_test() -> void:
	sut = get_node_or_null("/root/SaveManager") as SaveManager
	assert_object(sut).is_not_null()

	original_game_data = sut.game_data.duplicate(true)
	original_file_existed = FileAccess.file_exists(sut.SAVE_PATH)
	if original_file_existed:
		var file := FileAccess.open(sut.SAVE_PATH, FileAccess.READ)
		if file:
			original_file_bytes = file.get_buffer(file.get_length())
			file.close()


func after_test() -> void:
	if not is_instance_valid(sut):
		return

	# Restaura o estado do Autoload e o save do usuário após cada teste.
	sut.game_data = original_game_data.duplicate(true)
	if original_file_existed:
		var file := FileAccess.open(sut.SAVE_PATH, FileAccess.WRITE)
		if file:
			file.store_buffer(original_file_bytes)
			file.close()
	else:
		if FileAccess.file_exists(sut.SAVE_PATH):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(sut.SAVE_PATH))


func test_update_level_progress_creates_level_and_stores_values() -> void:
	var level_id := 987654
	sut.update_level_progress(level_id, 450.0, true, {"deaths": 2})
	var level = sut.get_level_data(str(level_id))

	assert_float(level["best_score"]).is_equal(450.0)
	assert_bool(level["completed"]).is_true()
	assert_that(level["data"]["deaths"]).is_equal(2)


func test_update_level_progress_keeps_best_score_and_completed_state() -> void:
	var level_id := 987655
	sut.update_level_progress(level_id, 500.0, true)
	sut.update_level_progress(level_id, 120.0, false)
	var level = sut.get_level_data(str(level_id))

	assert_float(level["best_score"]).is_equal(500.0)
	assert_bool(level["completed"]).is_true()


func test_get_level_data_returns_default_for_unknown_level() -> void:
	var level = sut.get_level_data("987656")

	assert_float(level["best_score"]).is_equal(0.0)
	assert_bool(level["completed"]).is_false()
	assert_dict(level["data"]).is_empty()


func test_save_and_load_restore_saved_game_data_and_emit_signals() -> void:
	var level_id := 987657
	sut.game_data["levels"][str(level_id)] = {
		"best_score": 777.0,
		"completed": true,
		"data": {"collectibles": 3}
	}
	monitor_signals(sut)
	sut.save_game()
	assert_signal(sut).is_emitted("saved")

	sut.game_data["levels"].clear()
	sut.load_game()

	assert_float(sut.get_level_score(str(level_id))).is_equal(777.0)
	assert_bool(sut.get_level_data(str(level_id))["completed"]).is_true()
	assert_signal(sut).is_emitted("loaded")
