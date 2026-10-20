extends CanvasLayer


@onready var character: Player = $".."

@onready var equipment_manager := %EquipmentManager
@onready var trick_system      := %TrickSystem
@onready var state_manager     := %StateMachine
@onready var score_manager     := %ScoreManager

@onready var total_pos     := %TotalPositions
@onready var current_pos   := %CurrentPosition
@onready var sequence      := %Sequence
@onready var trick_label   := %TrickName
@onready var score_label   := %Score
@onready var combo_bar     := %ComboBar
@onready var combo_counter := %ComboCounter

@onready var pos_anim           := %PositionAnim
@onready var combo_bar_anim     := %ComboBarAnim
@onready var score_anim         := %ScoreAnim
@onready var trick_name_anim    := %TrickNameAnim
@onready var sequence_anim      := %SequenceAnim
@onready var combo_count_anim   := %ComboCounterAnim
@onready var damage_screen_anim := %DamageScreenAnim

const DIRECTION = ["↑", "↓", "→", "←"]

var current_score: float = 0.0
var current_combo_amount: int = 0


func _ready() -> void:
	trick_system.trick_started.connect(_update_trick_label)
	score_manager.score_updated.connect(_score_updated)
	EventBus.direction_input.connect(_update_sequece)
	EventBus.trick_failed.connect(
		func(base_character: BaseCharacter, _trick: BaseTrick):
			if base_character == character:
				damage_screen_anim.play("damage_hud/damage")
	)


func _process(_delta: float) -> void:
	if get_tree().paused: visible = !get_tree().paused
	
	if score_manager.combo_amount > 0:
		combo_bar.value = score_manager.get_time_percent()
	elif combo_bar.value != 0.0:
		combo_bar.value = 0.0


@warning_ignore("unused_parameter")
func _update_sequece(direction: Global.Direction, pressed: bool) -> void:
	if not pressed: return
	if sequence.get_total_character_count() > 7: sequence.text = ""
	
	sequence.text += str(DIRECTION[direction], " ")


func _score_updated(score: float, combo_amount: int) -> void:
	current_score = score
	current_combo_amount = combo_amount
	_score_control()


func _update_trick_label(trick: BaseTrick):
	trick_label.text = str(trick.trick_data.trick_name)
	trick_name_anim.play("trick_name_hud/trick_detected")
	sequence_anim.play("sequence_hud/direction_detected")
	
	_score_control()


func _score_control() -> void:
	var combo_counter_text: String = str(current_combo_amount, "X")
	var combo_bar_value:    float  = 100.0
	
	if current_combo_amount == 0:
		combo_counter_text = ""
		combo_bar_value    = 0.
	
	score_label.text   = str("SCORE: ", current_score).pad_decimals(2)
	combo_bar.value    = combo_bar_value
	combo_counter.text = str(combo_counter_text)
	
	score_anim.play("score_hud/score_up")
	combo_count_anim.play("combo_counter_hud/combo_up")
	combo_bar_anim.play("combo_bar_hud/combo_bar_update")
