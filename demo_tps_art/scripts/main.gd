extends Node3D

const ENEMY_SCENE := preload("res://scenes/enemy.tscn")
const RADIO_ENEMY_SPOTTED := preload("res://assets/audio/radio/enemy_spotted.mp3")
const RADIO_ENEMY_DOWN := preload("res://assets/audio/radio/enemy_down.mp3")

const PLAYER_START := Vector3(0.0, 1.1, 13.2)
const ROUND_TIME := 90
const ENEMY_ROUTES := [
	{
		"a": Vector3(-16.5, 1.1, -12.5),
		"b": Vector3(-7.0, 1.1, -15.5),
	},
	{
		"a": Vector3(16.5, 1.1, -12.0),
		"b": Vector3(7.0, 1.1, -15.0),
	},
	{
		"a": Vector3(-15.0, 1.1, 8.5),
		"b": Vector3(-5.5, 1.1, 13.5),
	},
	{
		"a": Vector3(15.0, 1.1, 9.0),
		"b": Vector3(5.5, 1.1, 13.5),
	},
]

enum GameState {
	READY,
	PLAYING,
	WON,
	LOST,
}

enum FinishReason {
	NONE,
	SUCCESS,
	ARMOR,
	TIME,
	FELL,
}

var _state := GameState.READY
var _finish_reason := FinishReason.NONE
var _remaining_time := ROUND_TIME
var _enemies_left := ENEMY_ROUTES.size()
var _radio_menu_active := false
var _player_mouse_captured := false
var _pending_go_go_go_after_intro := false

@onready var _player = $Player
@onready var _music: AudioStreamPlayer = $Music
@onready var _intro_cue: AudioStreamPlayer = $IntroCue
@onready var _start_cue: AudioStreamPlayer = $StartCue
@onready var _counter_terrorists_win_cue: AudioStreamPlayer = $CounterTerroristsWinCue
@onready var _terrorists_win_cue: AudioStreamPlayer = $TerroristsWinCue
@onready var _radio_cue: AudioStreamPlayer = $RadioCue
@onready var _round_timer: Timer = $RoundTimer
@onready var _objective_label: Label = $CanvasLayer/ObjectiveLabel
@onready var _armor_label: Label = $CanvasLayer/ArmorLabel
@onready var _health_bar: ProgressBar = $CanvasLayer/HealthBar
@onready var _bots_label: Label = $CanvasLayer/BotsLabel
@onready var _time_label: Label = $CanvasLayer/TimeLabel
@onready var _message_label: Label = $CanvasLayer/MessageLabel
@onready var _hint_label: Label = $CanvasLayer/HintLabel
@onready var _start_screen: Control = $CanvasLayer/StartScreen
@onready var _end_screen: Control = $CanvasLayer/EndScreen
@onready var _end_screen_shade: ColorRect = $CanvasLayer/EndScreen/Shade
@onready var _result_tag_label: Label = $CanvasLayer/EndScreen/Padding/Center/Panel/Content/ResultTagLabel
@onready var _result_title_label: Label = $CanvasLayer/EndScreen/Padding/Center/Panel/Content/ResultTitleLabel
@onready var _result_summary_label: Label = $CanvasLayer/EndScreen/Padding/Center/Panel/Content/ResultSummaryLabel
@onready var _result_divider: ColorRect = $CanvasLayer/EndScreen/Padding/Center/Panel/Content/ResultDivider
@onready var _result_stats_label: Label = $CanvasLayer/EndScreen/Padding/Center/Panel/Content/ResultStatsLabel
@onready var _result_prompt_label: Label = $CanvasLayer/EndScreen/Padding/Center/Panel/Content/ResultPromptLabel


func _ready() -> void:
	_player.health_changed.connect(_on_player_health_changed)
	_player.died.connect(_on_player_died)
	_player.fell_out.connect(_on_player_fell_out)
	_player.mouse_capture_changed.connect(_on_player_mouse_capture_changed)
	_round_timer.timeout.connect(_on_round_timer_timeout)
	_intro_cue.finished.connect(_on_intro_cue_finished)
	if DisplayServer.get_name() != "headless":
		_music.play()
	_show_ready_screen()


func _exit_tree() -> void:
	if is_instance_valid(_intro_cue):
		_intro_cue.stop()
		_intro_cue.stream = null
	if is_instance_valid(_radio_cue):
		_radio_cue.stop()
		_radio_cue.stream = null
	if is_instance_valid(_counter_terrorists_win_cue):
		_counter_terrorists_win_cue.stop()
		_counter_terrorists_win_cue.stream = null
	if is_instance_valid(_terrorists_win_cue):
		_terrorists_win_cue.stop()
		_terrorists_win_cue.stream = null
	if is_instance_valid(_start_cue):
		_start_cue.stop()
		_start_cue.stream = null
	if is_instance_valid(_music):
		_music.stop()
		_music.stream = null


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo:
		return

	if _state == GameState.PLAYING:
		if event.is_action_pressed(&"radio_menu"):
			_radio_menu_active = not _radio_menu_active
			if _radio_menu_active:
				_message_label.text = "Radio online. Press 1 for enemy spotted, 2 for enemy down."
			_refresh_hint_label()
			get_viewport().set_input_as_handled()
			return

		if _radio_menu_active and event.is_action_pressed(&"radio_slot_1"):
			_radio_menu_active = false
			_play_radio_callout(RADIO_ENEMY_SPOTTED, "Radio: Enemy spotted.")
			_refresh_hint_label()
			get_viewport().set_input_as_handled()
			return

		if _radio_menu_active and event.is_action_pressed(&"radio_slot_2"):
			_radio_menu_active = false
			_play_radio_callout(RADIO_ENEMY_DOWN, "Radio: Enemy down.")
			_refresh_hint_label()
			get_viewport().set_input_as_handled()
			return

	if event.is_action_pressed(&"start_game") and _state != GameState.PLAYING:
		new_game()
		get_viewport().set_input_as_handled()


func new_game() -> void:
	_clear_group(&"enemies")
	_clear_group(&"projectiles")

	_state = GameState.PLAYING
	_finish_reason = FinishReason.NONE
	_remaining_time = ROUND_TIME
	_enemies_left = ENEMY_ROUTES.size()
	_radio_menu_active = false
	_pending_go_go_go_after_intro = false

	_hide_start_screen()
	_hide_end_screen()
	_player.reset_for_round(PLAYER_START)
	_spawn_enemies()
	_round_timer.start()
	_intro_cue.stop()
	_radio_cue.stop()
	_play_start_intro_sequence()

	_message_label.text = "Counter-Terrorist shield active for 3 seconds. Eliminate all Terrorists before they take the site."
	_update_hud()


func _show_ready_screen() -> void:
	_state = GameState.READY
	_finish_reason = FinishReason.NONE
	_remaining_time = ROUND_TIME
	_enemies_left = ENEMY_ROUTES.size()
	_radio_menu_active = false
	_pending_go_go_go_after_intro = false
	_round_timer.stop()
	_intro_cue.stop()
	_clear_group(&"enemies")
	_clear_group(&"projectiles")
	_player.show_preview(PLAYER_START)
	_message_label.text = "Press Space or Enter to join the Counter-Terrorists. RMB or Q aims; LMB or F fires."
	_show_start_screen()
	_hide_end_screen()
	_update_hud()


func _spawn_enemies() -> void:
	for route in ENEMY_ROUTES:
		var enemy = ENEMY_SCENE.instantiate()
		add_child(enemy)
		enemy.configure(route["a"], route["b"], _player)
		enemy.destroyed.connect(_on_enemy_destroyed)


func _finish_game(finish_reason: int) -> void:
	_finish_reason = finish_reason
	var player_won := finish_reason == FinishReason.SUCCESS
	_state = GameState.WON if player_won else GameState.LOST
	_radio_menu_active = false
	_pending_go_go_go_after_intro = false
	_round_timer.stop()
	_intro_cue.stop()
	_player.stop_round()
	_clear_group(&"projectiles")

	for enemy in get_tree().get_nodes_in_group(&"enemies"):
		enemy.set_physics_process(false)

	if player_won:
		_play_counter_terrorists_win()
		_message_label.text = "Counter-Terrorists Win. Press Space to redeploy."
	elif finish_reason == FinishReason.ARMOR:
		_play_terrorists_win()
		_message_label.text = "Terrorists Win. Press Space to retry."
	elif finish_reason == FinishReason.TIME:
		_play_terrorists_win()
		_message_label.text = "Terrorists Win. Press Space to retry."
	elif finish_reason == FinishReason.FELL:
		_play_terrorists_win()
		_message_label.text = "Terrorists Win. Press Space to retry."
	else:
		_play_terrorists_win()
		_message_label.text = "Terrorists Win. Press Space to retry."

	_show_end_screen()
	_update_hud()


func _on_enemy_destroyed() -> void:
	if _state != GameState.PLAYING:
		return

	_enemies_left = max(0, _enemies_left - 1)
	_play_go_go_go()
	if _enemies_left == 0:
		_finish_game(FinishReason.SUCCESS)
	else:
		_message_label.text = "Target neutralized. Keep pushing."
		_update_hud()


func _on_player_health_changed(current_health: int, max_health: int) -> void:
	_armor_label.text = "Health: %d/%d" % [current_health, max_health]
	_health_bar.max_value = max_health
	_health_bar.value = current_health


func _on_player_died() -> void:
	if _state == GameState.PLAYING:
		_finish_game(FinishReason.ARMOR)


func _on_player_fell_out() -> void:
	if _state == GameState.PLAYING:
		_finish_game(FinishReason.FELL)


func _on_player_mouse_capture_changed(captured: bool) -> void:
	_player_mouse_captured = captured
	_refresh_hint_label()


func _on_round_timer_timeout() -> void:
	if _state != GameState.PLAYING:
		return

	_remaining_time -= 1
	if _remaining_time <= 0:
		_finish_game(FinishReason.TIME)
	else:
		_update_hud()


func _update_hud() -> void:
	_objective_label.text = "TACTICAL TRAINING GROUND | Eliminate %d sentry bots" % ENEMY_ROUTES.size()
	_bots_label.text = "Bots: %d/%d" % [_enemies_left, ENEMY_ROUTES.size()]
	_time_label.text = "Time: %d" % max(0, _remaining_time)
	_refresh_hint_label()


func _show_end_screen() -> void:
	_hide_start_screen()
	var accent_color := Color(0.576471, 1.0, 0.847059, 1.0) if _finish_reason == FinishReason.SUCCESS else Color(1.0, 0.423529, 0.415686, 1.0)
	var report_tag := "Counter-Terrorists Win" if _finish_reason == FinishReason.SUCCESS else "Terrorists Win"
	var report_title := ""
	var report_summary := ""
	var report_status := ""

	match _finish_reason:
		FinishReason.SUCCESS:
			report_title = "SITE SECURED"
			report_summary = "The Counter-Terrorists eliminated every Terrorist before the round timer expired."
			report_status = "Round result: Counter-Terrorists hold the site."
		FinishReason.ARMOR:
			report_title = "COUNTER-TERRORIST DOWN"
			report_summary = "The Terrorists cut down the Counter-Terrorist operator before the round could be secured."
			report_status = "Round result: Terrorists overwhelm the defense."
		FinishReason.TIME:
			report_title = "ROUND TIMER EXPIRED"
			report_summary = "The Counter-Terrorists ran out of time, so the Terrorists claim the round."
			report_status = "Round result: Terrorists survive the clock."
		FinishReason.FELL:
			report_title = "POSITION LOST"
			report_summary = "The Counter-Terrorist operator lost footing and the Terrorists take the round."
			report_status = "Round result: Terrorists control the site."
		_:
			report_title = "ROUND COMPLETE"
			report_summary = "The round has concluded."
			report_status = "Status: Awaiting redeploy."

	var report_lines := PackedStringArray([
		"Terrorists eliminated: %d/%d" % [ENEMY_ROUTES.size() - _enemies_left, ENEMY_ROUTES.size()],
		"Health remaining: %d/%d" % [max(0, _player.current_health), _player.max_health],
		"Round time remaining: %ds" % max(0, _remaining_time),
		report_status,
	])

	_result_tag_label.text = report_tag
	_result_title_label.text = report_title
	_result_summary_label.text = report_summary
	_result_stats_label.text = "\n".join(report_lines)
	_result_prompt_label.text = "Press Space or Enter to start the next round."

	_result_tag_label.modulate = accent_color
	_result_title_label.modulate = accent_color
	_result_divider.color = accent_color
	_end_screen_shade.color = Color(accent_color.r * 0.12, accent_color.g * 0.12, accent_color.b * 0.18, 0.66)
	_end_screen.visible = true
	_message_label.visible = false
	_hint_label.visible = false


func _show_start_screen() -> void:
	_start_screen.visible = true
	_message_label.visible = false
	_hint_label.visible = false


func _hide_start_screen() -> void:
	_start_screen.visible = false
	if not _end_screen.visible:
		_message_label.visible = true
		_hint_label.visible = true


func _hide_end_screen() -> void:
	_end_screen.visible = false
	if not _start_screen.visible:
		_message_label.visible = true
		_hint_label.visible = true


func _clear_group(group_name: StringName) -> void:
	for node in get_tree().get_nodes_in_group(group_name):
		node.queue_free()


func _play_start_intro_sequence() -> void:
	if DisplayServer.get_name() == "headless":
		return
	_pending_go_go_go_after_intro = true
	_start_cue.stop()
	_intro_cue.stop()
	_intro_cue.play()


func _play_go_go_go() -> void:
	if DisplayServer.get_name() == "headless":
		return
	_pending_go_go_go_after_intro = false
	_intro_cue.stop()
	_start_cue.stop()
	_start_cue.play()


func _play_counter_terrorists_win() -> void:
	if DisplayServer.get_name() == "headless":
		return
	_intro_cue.stop()
	_start_cue.stop()
	_radio_cue.stop()
	_terrorists_win_cue.stop()
	_counter_terrorists_win_cue.stop()
	_counter_terrorists_win_cue.play()


func _play_terrorists_win() -> void:
	if DisplayServer.get_name() == "headless":
		return
	_intro_cue.stop()
	_start_cue.stop()
	_radio_cue.stop()
	_counter_terrorists_win_cue.stop()
	_terrorists_win_cue.stop()
	_terrorists_win_cue.play()


func _play_radio_callout(stream: AudioStream, message: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	_radio_cue.stop()
	_radio_cue.stream = stream
	_radio_cue.play()
	_message_label.text = message


func _on_intro_cue_finished() -> void:
	if not _pending_go_go_go_after_intro:
		return
	if _state != GameState.PLAYING:
		_pending_go_go_go_after_intro = false
		return
	_pending_go_go_go_after_intro = false
	_start_cue.stop()
	_start_cue.play()


func _refresh_hint_label() -> void:
	if _state == GameState.PLAYING and _radio_menu_active:
		_hint_label.text = "Radio open | 1 Enemy spotted | 2 Enemy down | Z cancel"
		return

	if _state == GameState.READY:
		_hint_label.text = "Space/Enter start | WASD move | Space jump | Q aim | F fire | Z radio"
	elif _state != GameState.PLAYING:
		_hint_label.text = "Space/Enter redeploy | Esc releases the mouse during play"
	elif _player_mouse_captured:
		_hint_label.text = "RMB/Q aim | LMB/F fire | Z radio | Esc release mouse"
	else:
		_hint_label.text = "Click, Q, or F to recapture | Z radio"
