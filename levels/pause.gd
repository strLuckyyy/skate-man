extends Control


@onready var menu_scene = preload("res://levels/menu.tscn")

var pause_enabled: bool = true

func _ready():
	pause(false)
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS


func set_pause_enabled(enabled: bool) -> void:
	pause_enabled = enabled
	if not pause_enabled:
		visible = false


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


func _on_button_pressed() -> void:
	pause(false)


func _on_button_2_pressed() -> void:
	pause(false)
	get_tree().reload_current_scene()


func _on_button_3_pressed() -> void:
	pause(false)
	get_tree().change_scene_to_packed(menu_scene)


func _on_button_4_pressed() -> void:
	get_tree().quit()
