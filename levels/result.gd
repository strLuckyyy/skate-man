
class_name Result
extends Control


@onready var menu_scene = preload("res://levels/menu.tscn")

func result(position:int):
	var r = "GANHOU!" if position == 1 else "PERDEU."
	%Result.text = str("VOCÊ ", r)
	$VBoxContainer/Label.text = str("Posição: ", position)

func _on_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_packed(menu_scene)


func _on_button_3_pressed() -> void:
	get_tree().quit()
