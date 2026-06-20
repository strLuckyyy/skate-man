class_name Menu
extends Control


@onready var level = preload("res://levels/1_level/level-1.tscn")


func _on_button_pressed() -> void:
	%Label2.text = "AGUARDE..."
	if %Label2.text == "AGUARDE...":
		GameManager.start_level(level)


func _on_button_2_pressed() -> void:
	get_tree().quit()
