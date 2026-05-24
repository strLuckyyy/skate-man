## base_trick.gd — ADDITIONS ONLY
##
## Add the following property to your existing BaseTrick class.
## No other changes are required to the existing BaseTrick logic.
##
## ─────────────────────────────────────────────────────────────────────────────
## INSERT into your existing base_trick.gd:
## ─────────────────────────────────────────────────────────────────────────────
##
##   ## When true, TrickSystem Pass 1 will try this trick before any air tricks.
##   ## Set to true by GrindTrick._init() — never set manually on air tricks.
##   var is_grind_trick: bool = false
##
## ─────────────────────────────────────────────────────────────────────────────
## Everything else in BaseTrick remains unchanged.
## ─────────────────────────────────────────────────────────────────────────────


## ═════════════════════════════════════════════════════════════════════════════
## grind_trick.gd — NEW FILE
## Base class for every grind trick (LateralGrind, NoseGrind, etc.)
##
## Inherits from BaseTrick and adds:
##   • is_grind_trick = true  — signals TrickSystem Pass 1.
##   • can_execute() guard    — requires grind_opportunity from context.
## ═════════════════════════════════════════════════════════════════════════════
class_name GrindTrick
extends BaseTrick


func _init() -> void:
	is_grind_trick = true


## A GrindTrick can only execute when:
##   1. The base class conditions are met (state_available, cooldown, etc.)
##   2. The TrickContext reports a grind opportunity (player is over a GrindArea).
##
## Condition 2 is checked here rather than in TrickData so the data asset stays
## a pure value object with no execution logic.
func can_execute(context: TrickContext) -> bool:
	if not super.can_execute(context):
		return false
	return context.get_grind_opportunity()
