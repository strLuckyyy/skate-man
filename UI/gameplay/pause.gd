extends Control

var pause_enabled: bool = true

func _ready():
	pause(false)
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	$TextureRect.material.set_shader_parameter("aspect", 0.5)


func pause(value: bool):
	if value and not pause_enabled:
		return
	get_tree().paused = value
	visible = value


func _process(_delta: float) -> void:
	if not pause_enabled:
		return
	if Input.is_action_just_pressed("pause"):
		if visible:
			pause(false)
		elif not get_tree().paused:
			pause(true)


func _on_continue_pressed() -> void:
	pause(false)


func _on_restart_pressed() -> void:
	pause(false)
	get_tree().reload_current_scene()


func _on_main_menu_pressed() -> void:
	pause(false)
	GameManager.load_main_menu()


func _on_exit_pressed() -> void:
	get_tree().quit()
