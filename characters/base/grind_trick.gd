class_name GrindTrick
extends BaseTrick


func _init() -> void:
	is_grind_trick = true


func can_execute(context: TrickContext) -> bool:
	if not super.can_execute(context):
		return false
	return context.get_grind_opportunity()
