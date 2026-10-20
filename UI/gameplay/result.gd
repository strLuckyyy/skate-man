class_name Result
extends Control

@onready var next_level_btn: Button = $VBoxContainer/NextLevel


func _ready() -> void:
	visible = false
	set_process(false)
	process_mode = Node.PROCESS_MODE_DISABLED


func result(_position:int):
	if _position == 0: _position = 1
	%Result.text = "You Win!" if _position == 1 else "You Lost."
	$VBoxContainer/Position.text = str("Position: ", _position)
	
	if !GameManager.get_has_next_level():
		next_level_btn.text = "Level Select"


func _on_next_level_pressed() -> void:
	get_tree().paused = false
	if GameManager.get_has_next_level():
		GameManager.load_next_level()
	else:
		GameManager.load_main_menu()


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	GameManager.load_main_menu()


func _on_exit_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()
