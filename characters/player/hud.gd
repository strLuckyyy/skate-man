extends CanvasLayer

@onready var character: Player = $".."
@onready var eq = %EquipmentManager
@onready var trick_system: TrickSystem = %TrickSystem
@onready var sm: StateMachine = %StateMachine
@onready var speed_label = %ProgressBar
@onready var trick_label = %trick
@onready var score       = %score
var current_score: float = 0.0


func _ready() -> void:
	trick_system.trick_started.connect(update_trick_label)
	await eq.ready
	
	speed_label.max_value = eq.current_equipment.max_boost_speed


func _physics_process(_delta: float) -> void:
	speed_label.value = character.velocity.length()
	if sm.current_state.state_id == Global.StateID.TRICK_FAIL:
		score.text = str(0.0)


func update_trick_label(trick: BaseTrick):
	trick_label.text = str("TRICK: ", trick.trick_data.trick_name)
	current_score = current_score + trick.trick_data.score_bonus
	score.text = str("SCORE: ", current_score)
