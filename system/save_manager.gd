extends Node

signal saved
signal loaded

const SAVE_PATH := "user://game_data.save"
const SECRET_KEY := "skategame"

var game_data: Dictionary = {
	"global_settings": {
		"master_volume": 100.0
	},
	"levels": {}
}

func _ready() -> void:
	load_game()


func save_game() -> void:
	var file = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.WRITE, SECRET_KEY)
	if file:
		var json_string = JSON.stringify(game_data)
		file.store_string(json_string)
		file.close()
		print("Game saved!")
		saved.emit()
	else:
		print("Error: Cannot save.")

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		save_game()
		return
	
	var file = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.READ, SECRET_KEY)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		if json.parse(json_string) == OK:
			var loaded_data = json.get_data()
			if typeof(loaded_data) == TYPE_DICTIONARY:
				game_data.merge(loaded_data, true)
				print("Save loaded!")
				loaded.emit()
		else:
			print("Error: Cannot load the game.")


func update_level_progress(level_id: int, score: float, is_completed: bool, custom_data: Dictionary = {}) -> void:
	var lvl_id := str(level_id)
	if not game_data["levels"].has(lvl_id):
		game_data["levels"][lvl_id] = {
			"best_score": 0.0,
			"completed": false,
			"data": {}
		}
	
	var level_ref = game_data["levels"][lvl_id]
	
	if score > level_ref["best_score"]:
		level_ref["best_score"] = score
	
	if is_completed or level_ref["completed"]:
		level_ref["completed"] = true
	
	if not custom_data.is_empty():
		level_ref["data"].merge(custom_data, true)
	
	save_game()


func get_level_data(level_id: String) -> Dictionary:
	if game_data["levels"].has(level_id):
		return game_data["levels"][level_id]
	return {"best_score": 0.0, "completed": false, "data": {}}


func get_level_score(level_id: String) -> float:
	var data = get_level_data(level_id)
	return data.get("best_score")
