## LateralGrind — extends GrindTrick (was BaseTrick).
##
## The only change is the parent class. Everything else inherits correctly:
##   • is_grind_trick = true     (from GrindTrick._init)
##   • can_execute() grind guard (from GrindTrick.can_execute)
##   • execute() side-effects    (super chain handles EventBus emissions)
class_name LateralGrind
extends GrindTrick   # ← was: extends BaseTrick


func execute(_context: TrickContext) -> void:
	super.execute(_context)
