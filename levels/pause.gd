extends Control


@onready var menu_scene = preload("res://levels/menu.tscn")

func _ready():
	pause(false)
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS


func pause(value: bool):
	get_tree().paused = value
	visible = !value


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			pause(false)
		else:
			pause(true)


func _on_button_pressed() -> void:
	pause(false)


func _on_button_2_pressed() -> void:
	get_tree().reload_current_scene()


func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_packed(menu_scene)


func _on_button_4_pressed() -> void:
	get_tree().quit()
