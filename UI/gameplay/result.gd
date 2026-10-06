class_name Result
extends Control



func result(_position:int):
	%Result.text = "You Win!" if _position == 1 else "You Lost."
	$VBoxContainer/Position.text = str("Position: ", _position)


func _on_next_level_pressed() -> void:
	pass # Replace with function body.

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	GameManager.load_main_menu()


func _on_exit_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()
