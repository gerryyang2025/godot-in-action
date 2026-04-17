extends Node3D

const TRAFFIC_SCENE = preload("res://scenes/traffic_vehicle.tscn")
const PICKUP_SCENE = preload("res://scenes/powerup_pickup.tscn")
const STREETLIGHT_MESH = preload("res://assets/third_party/quaternius/modular_streets/Streetlight_Double.obj")
const TRAFFIC_LIGHT_MESH = preload("res://assets/third_party/quaternius/modular_streets/TrafficLight.obj")
const STOP_SIGN_MESH = preload("res://assets/third_party/quaternius/modular_streets/Sign_Stop.obj")
const WARNING_SIGN_MESH = preload("res://assets/third_party/quaternius/modular_streets/Sign_Triangle.obj")

const SAVE_PATH := "user://demo_racing_save.cfg"
const ROAD_SEGMENT_LENGTH := 32.0
const ROAD_SEGMENT_COUNT := 9
const ROAD_WIDTH := 12.8
const PLAYER_Z := 0.0
const MAX_FUEL := 100.0
const START_FUEL := 88.0
const COMBO_WINDOW := 2.3
const HIJACK_DURATION := 4.4
const STEALTH_DURATION := 5.4
const STEALTH_PICKUP_SCORE := 220
const PICKUP_DESPAWN_Z := 20.0
const PICKUP_START_DELAY := 7.2
const PICKUP_RESPAWN_MIN := 10.0
const PICKUP_RESPAWN_MAX := 16.0
const COMBO_OVERDRIVE_THRESHOLD := 5
const COMBO_OVERDRIVE_STEP := 0.34
const COLLISION_RECOVERY_DURATION := 1.15
const COLLISION_RECOVERY_ENTRY_SPEED := 4.6
const COLLISION_RECOVERY_VISUAL_GRACE := 0.72
const POST_HIJACK_INVULNERABILITY_DURATION := 0.95
const DESPAWN_Z := 24.0
const MAX_UPGRADE_LEVEL := 5
const TRAFFIC_ACTIVE_CAP_EASY := 8
const TRAFFIC_ACTIVE_CAP_HARD := 11
const TRAFFIC_SPAWN_INTERVAL_EASY := 1.34
const TRAFFIC_SPAWN_INTERVAL_HARD := 0.9
const TRAFFIC_SECONDARY_WAVE_MAX_CHANCE := 0.08
const TRAFFIC_LANE_SPACING_EASY := 26.0
const TRAFFIC_LANE_SPACING_HARD := 22.0
const LANE_X := [-4.8, -2.4, 0.0, 2.4, 4.8]
const DIVIDER_X := [-3.6, -1.2, 1.2, 3.6]
const VEHICLE_VARIANTS := {
	&"car": [&"normal_1", &"normal_2", &"taxi", &"cop"],
	&"van": [&"suv", &"ambulance"],
	&"truck": [&"bus", &"school_bus"],
}
const COMBO_CALLOUTS := [
	{
		"min_combo": 1,
		"text": "GOOD",
		"voice": "good",
		"color": Color(0.556863, 0.929412, 1.0, 1.0),
		"detail": "贴尾切线已接上",
	},
	{
		"min_combo": 2,
		"text": "COOL",
		"voice": "cool",
		"color": Color(0.392157, 0.976471, 0.733333, 1.0),
		"detail": "节奏正在抬起来",
	},
	{
		"min_combo": 3,
		"text": "GREAT",
		"voice": "great",
		"color": Color(0.980392, 0.760784, 0.298039, 1.0),
		"detail": "别松，继续把线走满",
	},
	{
		"min_combo": 4,
		"text": "PERFECT",
		"voice": "perfect",
		"color": Color(1.0, 0.584314, 0.278431, 1.0),
		"detail": "窗口咬得很准",
	},
	{
		"min_combo": 5,
		"text": "WELL DONE",
		"voice": "well_done",
		"color": Color(1.0, 0.466667, 0.364706, 1.0),
		"detail": "高连击开始节油",
	},
	{
		"min_combo": 6,
		"text": "WONDERFUL",
		"voice": "wonderful",
		"color": Color(0.968627, 0.458824, 0.843137, 1.0),
		"detail": "续航和分数都在飙升",
	},
	{
		"min_combo": 7,
		"text": "EXCELLENT",
		"voice": "excellent",
		"color": Color(0.764706, 0.482353, 1.0, 1.0),
		"detail": "这波可以直接冲榜",
	},
	{
		"min_combo": 8,
		"text": "AMAZING",
		"voice": "amazing",
		"color": Color(0.447059, 0.780392, 1.0, 1.0),
		"detail": "车流已经压不住你了",
	},
	{
		"min_combo": 9,
		"text": "UNBELIEVABLE",
		"voice": "unbelievable",
		"color": Color(1.0, 0.909804, 0.505882, 1.0),
		"detail": "神走线，继续拉满",
	},
	{
		"min_combo": 10,
		"text": "I LOVE YOU",
		"voice": "i_love_you",
		"color": Color(1.0, 0.552941, 0.72549, 1.0),
		"detail": "最高档喝彩已点亮",
	},
]
const VOICE_STREAM_PATHS := {
	"go_go_go": "res://assets/audio/voice/go_go_go.wav",
	"good": "res://assets/audio/voice/good.wav",
	"cool": "res://assets/audio/voice/cool.wav",
	"great": "res://assets/audio/voice/great.wav",
	"perfect": "res://assets/audio/voice/perfect.wav",
	"well_done": "res://assets/audio/voice/well_done.wav",
	"wonderful": "res://assets/audio/voice/wonderful.wav",
	"excellent": "res://assets/audio/voice/excellent.wav",
	"amazing": "res://assets/audio/voice/amazing.wav",
	"unbelievable": "res://assets/audio/voice/unbelievable.wav",
	"i_love_you": "res://assets/audio/voice/i_love_you.wav",
}

const RANKS := [
	{
		"id": "C",
		"name": "City Sprinter",
		"promotion_cost": 0,
		"speed_bonus": 0.0,
		"accel_bonus": 0.0,
		"eco_bonus": 0.0,
		"body": Color(0.227451, 0.788235, 0.917647, 1),
		"accent": Color(1, 0.67451, 0.184314, 1),
	},
	{
		"id": "B",
		"name": "Neon Pursuit",
		"promotion_cost": 900,
		"speed_bonus": 4.0,
		"accel_bonus": 1.4,
		"eco_bonus": 0.25,
		"body": Color(0.321569, 0.937255, 0.643137, 1),
		"accent": Color(0.952941, 0.298039, 0.505882, 1),
	},
	{
		"id": "A",
		"name": "Solar Arrow",
		"promotion_cost": 1800,
		"speed_bonus": 7.5,
		"accel_bonus": 2.7,
		"eco_bonus": 0.6,
		"body": Color(1, 0.670588, 0.239216, 1),
		"accent": Color(0.968627, 0.286275, 0.192157, 1),
	},
	{
		"id": "S",
		"name": "Overdrive Specter",
		"promotion_cost": 3400,
		"speed_bonus": 11.2,
		"accel_bonus": 4.2,
		"eco_bonus": 1.0,
		"body": Color(0.815686, 0.392157, 0.988235, 1),
		"accent": Color(0.247059, 0.803922, 1, 1),
	},
	{
		"id": "T",
		"name": "Titan Frame",
		"promotion_cost": 5200,
		"speed_bonus": 15.0,
		"accel_bonus": 5.8,
		"eco_bonus": 1.55,
		"body": Color(0.960784, 0.196078, 0.270588, 1),
		"accent": Color(1, 0.85098, 0.32549, 1),
	},
]

enum GameState {
	READY,
	PLAYING,
	GAME_OVER,
}

var _state := GameState.READY
var _rng := RandomNumberGenerator.new()
var _save_data: Dictionary = {}
var _road_segments: Array[Node3D] = []
var _traffic: Array = []
var _pickups: Array = []
var _voice_streams := {}

var _speed := 0.0
var _distance_m := 0.0
var _score := 0
var _score_accumulator := 0.0
var _fuel := START_FUEL
var _combo := 0
var _combo_timer := 0.0
var _best_combo := 0
var _combo_feedback_timer := 0.0
var _combo_feedback_duration := 0.0
var _combo_feedback_text := ""
var _combo_feedback_detail := ""
var _combo_feedback_color := Color(1, 1, 1, 1)
var _ram_hits := 0
var _stealth_timer := 0.0
var _combo_overdrive_timer := 0.0
var _collision_recovery_timer := 0.0
var _post_hijack_invulnerability_timer := 0.0
var _spawn_timer := 0.0
var _pickup_spawn_timer := PICKUP_START_DELAY
var _message_time := 0.0
var _message_text := ""
var _active_hijack_vehicle = null
var _last_wave_signature := ""
var _last_finish_reason := ""
var _last_credits_earned := 0
var _last_ram_hits := 0
var _shutdown_started := false

@onready var _camera: Camera3D = $Camera3D
@onready var _track_root: Node3D = $TrackRoot
@onready var _traffic_root: Node3D = $TrafficRoot
@onready var _pickup_root: Node3D = $PickupRoot
@onready var _player = $PlayerCar
@onready var _music: AudioStreamPlayer = $Music
@onready var _engine_loop: AudioStreamPlayer = $EngineLoop
@onready var _start_cue: AudioStreamPlayer = $StartCue
@onready var _jump_cue: AudioStreamPlayer = $JumpCue
@onready var _near_miss_cue: AudioStreamPlayer = $NearMissCue
@onready var _hijack_cue: AudioStreamPlayer = $HijackCue
@onready var _upgrade_cue: AudioStreamPlayer = $UpgradeCue
@onready var _promote_cue: AudioStreamPlayer = $PromoteCue
@onready var _crash_cue: AudioStreamPlayer = $CrashCue
@onready var _fuel_empty_cue: AudioStreamPlayer = $FuelEmptyCue
@onready var _stealth_cue: AudioStreamPlayer = $StealthCue
@onready var _voice_cue: AudioStreamPlayer = $VoiceCue
@onready var _metrics_label: Label = $CanvasLayer/MetricsLabel
@onready var _fuel_label: Label = $CanvasLayer/FuelLabel
@onready var _combo_label: Label = $CanvasLayer/ComboLabel
@onready var _rank_label: Label = $CanvasLayer/RankLabel
@onready var _message_label: Label = $CanvasLayer/MessageLabel
@onready var _combo_flash: ColorRect = $CanvasLayer/ComboFlash
@onready var _combo_burst_label: Label = $CanvasLayer/ComboBurstLabel
@onready var _combo_detail_label: Label = $CanvasLayer/ComboDetailLabel
@onready var _start_screen: Control = $CanvasLayer/StartScreen
@onready var _start_screen_shade: ColorRect = $CanvasLayer/StartScreen/Shade
@onready var _start_padding: MarginContainer = $CanvasLayer/StartScreen/Padding
@onready var _start_panel: PanelContainer = $CanvasLayer/StartScreen/Padding/Center/Panel
@onready var _start_content: VBoxContainer = $CanvasLayer/StartScreen/Padding/Center/Panel/Content
@onready var _start_tag_label: Label = $CanvasLayer/StartScreen/Padding/Center/Panel/Content/StartTagLabel
@onready var _start_title_label: Label = $CanvasLayer/StartScreen/Padding/Center/Panel/Content/StartTitleLabel
@onready var _start_summary_label: Label = $CanvasLayer/StartScreen/Padding/Center/Panel/Content/StartSummaryLabel
@onready var _start_divider: ColorRect = $CanvasLayer/StartScreen/Padding/Center/Panel/Content/StartDivider
@onready var _start_info_label: Label = $CanvasLayer/StartScreen/Padding/Center/Panel/Content/StartInfoLabel
@onready var _start_garage_label: Label = $CanvasLayer/StartScreen/Padding/Center/Panel/Content/StartGarageLabel
@onready var _start_prompt_label: Label = $CanvasLayer/StartScreen/Padding/Center/Panel/Content/StartPromptLabel
@onready var _author_label: Label = $CanvasLayer/StartScreen/AuthorLabel
@onready var _end_screen: Control = $CanvasLayer/EndScreen
@onready var _end_screen_shade: ColorRect = $CanvasLayer/EndScreen/Shade
@onready var _end_padding: MarginContainer = $CanvasLayer/EndScreen/Padding
@onready var _end_panel: PanelContainer = $CanvasLayer/EndScreen/Padding/Center/Panel
@onready var _end_content: VBoxContainer = $CanvasLayer/EndScreen/Padding/Center/Panel/Content
@onready var _result_tag_label: Label = $CanvasLayer/EndScreen/Padding/Center/Panel/Content/ResultTagLabel
@onready var _result_title_label: Label = $CanvasLayer/EndScreen/Padding/Center/Panel/Content/ResultTitleLabel
@onready var _result_summary_label: Label = $CanvasLayer/EndScreen/Padding/Center/Panel/Content/ResultSummaryLabel
@onready var _result_divider: ColorRect = $CanvasLayer/EndScreen/Padding/Center/Panel/Content/ResultDivider
@onready var _result_stats_label: Label = $CanvasLayer/EndScreen/Padding/Center/Panel/Content/ResultStatsLabel
@onready var _result_garage_label: Label = $CanvasLayer/EndScreen/Padding/Center/Panel/Content/ResultGarageLabel
@onready var _result_prompt_label: Label = $CanvasLayer/EndScreen/Padding/Center/Panel/Content/ResultPromptLabel


func _ready() -> void:
	_rng.randomize()
	call_deferred("_bring_window_to_front")
	_save_data = _default_save_data()
	_load_save()
	_build_track()
	_player.set_lane_positions(LANE_X)
	_player.lane_changed.connect(_on_player_lane_changed)
	if not get_viewport().size_changed.is_connected(_on_viewport_size_changed):
		get_viewport().size_changed.connect(_on_viewport_size_changed)
	_apply_rank_palette_to_player()
	_load_voice_streams()
	_configure_audio()
	_set_message("贴近前车尾流后再切线，就能拿到险超连击和燃油回补。", 2.8)
	_apply_front_screen_layout()
	_reset_combo_feedback_visuals()
	_refresh_front_screens()
	_show_start_screen()
	_update_hud()


func _bring_window_to_front() -> void:
	var window := get_window()
	if window != null:
		window.grab_focus()


func _on_viewport_size_changed() -> void:
	_apply_front_screen_layout()


func _apply_front_screen_layout() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	var compact_height := viewport_size.y < 860.0
	var tight_height := viewport_size.y < 760.0
	var horizontal_padding := 16.0 if viewport_size.x < 1120.0 else 24.0
	var vertical_padding := 12.0 if compact_height else 24.0
	var start_panel_width := clampf(viewport_size.x * 0.7, 620.0, 980.0)
	var end_panel_width := clampf(viewport_size.x * 0.66, 600.0, 920.0)

	if viewport_size.x < 760.0:
		start_panel_width = maxf(520.0, viewport_size.x - horizontal_padding * 2.0)
		end_panel_width = maxf(500.0, viewport_size.x - horizontal_padding * 2.0)

	_apply_screen_padding(_start_padding, horizontal_padding, vertical_padding)
	_apply_screen_padding(_end_padding, horizontal_padding, vertical_padding)

	_start_panel.custom_minimum_size = Vector2(start_panel_width, 0.0)
	_end_panel.custom_minimum_size = Vector2(end_panel_width, 0.0)
	_start_content.add_theme_constant_override("separation", 8 if tight_height else (10 if compact_height else 12))
	_end_content.add_theme_constant_override("separation", 8 if tight_height else (10 if compact_height else 12))

	_set_font_size(_start_tag_label, 14 if tight_height else 16)
	_set_font_size(_start_title_label, 28 if tight_height else (31 if compact_height else 34))
	_set_font_size(_start_summary_label, 17 if tight_height else (18 if compact_height else 19))
	_set_font_size(_start_info_label, 15 if tight_height else (16 if compact_height else 18))
	_set_font_size(_start_garage_label, 14 if tight_height else (15 if compact_height else 17))
	_set_font_size(_start_prompt_label, 16 if tight_height else (17 if compact_height else 18))
	_set_font_size(_author_label, 12 if tight_height else 14)

	_set_font_size(_result_tag_label, 14 if tight_height else 16)
	_set_font_size(_result_title_label, 28 if tight_height else (31 if compact_height else 34))
	_set_font_size(_result_summary_label, 17 if tight_height else (18 if compact_height else 19))
	_set_font_size(_result_stats_label, 15 if tight_height else (16 if compact_height else 18))
	_set_font_size(_result_garage_label, 14 if tight_height else (15 if compact_height else 17))
	_set_font_size(_result_prompt_label, 16 if tight_height else (17 if compact_height else 18))


func _apply_screen_padding(container: MarginContainer, horizontal_padding: float, vertical_padding: float) -> void:
	container.offset_left = horizontal_padding
	container.offset_top = vertical_padding
	container.offset_right = -horizontal_padding
	container.offset_bottom = -vertical_padding


func _set_font_size(label: Control, size: int) -> void:
	label.add_theme_font_size_override("font_size", size)


func _load_voice_streams() -> void:
	_voice_streams.clear()
	for key in VOICE_STREAM_PATHS.keys():
		var stream = load(String(VOICE_STREAM_PATHS[key]))
		if stream != null:
			_voice_streams[key] = stream


func _configure_audio() -> void:
	if not _audio_available():
		return

	if not _music.finished.is_connected(_on_music_finished):
		_music.finished.connect(_on_music_finished)

	_enable_forward_loop(_engine_loop.stream)
	_music.play()
	_engine_loop.pitch_scale = 0.72
	_engine_loop.play()


func _play_voice(key: String) -> void:
	if not _audio_available() or not is_instance_valid(_voice_cue):
		return
	if not _voice_streams.has(key):
		return

	_voice_cue.stream = _voice_streams[key]
	_voice_cue.pitch_scale = 1.0
	_voice_cue.stop()
	_voice_cue.play()


func _reset_combo_feedback_visuals() -> void:
	_combo_feedback_timer = 0.0
	_combo_feedback_duration = 0.0
	_combo_feedback_text = ""
	_combo_feedback_detail = ""
	_combo_flash.visible = false
	_combo_burst_label.visible = false
	_combo_detail_label.visible = false


func _show_combo_feedback(text: String, detail: String, color: Color, combo_count: int) -> void:
	_combo_feedback_text = text
	_combo_feedback_detail = detail
	_combo_feedback_color = color
	_combo_feedback_duration = 0.6 + minf(0.45, float(combo_count) * 0.04)
	_combo_feedback_timer = _combo_feedback_duration
	_combo_burst_label.text = text
	_combo_detail_label.text = "Combo x%d   %s" % [combo_count, detail]
	_combo_burst_label.modulate = color
	_combo_detail_label.modulate = Color(color.r, color.g, color.b, 0.94)
	_combo_burst_label.visible = true
	_combo_detail_label.visible = true
	_combo_flash.visible = true


func _update_combo_feedback(delta: float) -> void:
	if _combo_feedback_timer <= 0.0:
		if _combo_flash.visible:
			_reset_combo_feedback_visuals()
		return

	_combo_feedback_timer = maxf(0.0, _combo_feedback_timer - delta)
	var life_ratio := _combo_feedback_timer / maxf(0.01, _combo_feedback_duration)
	var ease_out := 1.0 - pow(1.0 - life_ratio, 2.0)
	_combo_flash.color = Color(_combo_feedback_color.r, _combo_feedback_color.g, _combo_feedback_color.b, 0.12 * ease_out)
	_combo_flash.visible = true
	_combo_burst_label.visible = true
	_combo_detail_label.visible = true
	_combo_burst_label.scale = Vector2.ONE * lerpf(1.05, 1.52, ease_out)
	_combo_detail_label.scale = Vector2.ONE * lerpf(1.0, 1.18, ease_out)
	_combo_burst_label.modulate = Color(_combo_feedback_color.r, _combo_feedback_color.g, _combo_feedback_color.b, ease_out)
	_combo_detail_label.modulate = Color(_combo_feedback_color.r, _combo_feedback_color.g, _combo_feedback_color.b, minf(0.98, ease_out * 1.1))


func _audio_available() -> bool:
	return DisplayServer.get_name() != "headless"


func _enable_forward_loop(stream: AudioStream) -> void:
	if stream is AudioStreamWAV:
		var wav_stream: AudioStreamWAV = stream
		wav_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD


func _play_cue(player: AudioStreamPlayer, pitch_scale: float = 1.0, restart: bool = true) -> void:
	if not _audio_available() or not is_instance_valid(player):
		return
	player.pitch_scale = pitch_scale
	if restart:
		player.stop()
	player.play()


func _update_engine_audio(delta: float) -> void:
	if not _audio_available():
		return

	var target_pitch := 0.72
	var target_volume := -26.0
	if _state == GameState.PLAYING:
		var speed_ratio := clampf(_speed / maxf(1.0, _target_speed_for_distance() + 4.0), 0.0, 1.2)
		target_pitch = lerpf(0.88, 1.42, speed_ratio)
		target_volume = lerpf(-14.0, -4.0, speed_ratio)
		if _player.is_hijacked():
			target_pitch += 0.08
			target_volume += 1.5

	_engine_loop.pitch_scale = lerpf(_engine_loop.pitch_scale, target_pitch, minf(1.0, delta * 5.0))
	_engine_loop.volume_db = lerpf(_engine_loop.volume_db, target_volume, minf(1.0, delta * 4.0))


func _on_music_finished() -> void:
	if _shutdown_started:
		return
	if _audio_available():
		_music.play()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		_shutdown_runtime_state()


func _exit_tree() -> void:
	_shutdown_runtime_state()


func _shutdown_runtime_state() -> void:
	if _shutdown_started:
		return

	_shutdown_started = true
	_active_hijack_vehicle = null
	_message_time = 0.0
	_combo_timer = 0.0
	_combo_overdrive_timer = 0.0
	_stealth_timer = 0.0
	_post_hijack_invulnerability_timer = 0.0
	_disconnect_audio_signals()
	_stop_and_release_audio_players()
	_clear_traffic(true)
	_clear_pickups(true)
	_clear_track_segments()


func _disconnect_audio_signals() -> void:
	if is_instance_valid(_music) and _music.finished.is_connected(_on_music_finished):
		_music.finished.disconnect(_on_music_finished)


func _stop_and_release_audio_players() -> void:
	for player in [_music, _engine_loop, _start_cue, _jump_cue, _near_miss_cue, _hijack_cue, _upgrade_cue, _promote_cue, _crash_cue, _fuel_empty_cue, _stealth_cue, _voice_cue]:
		if is_instance_valid(player):
			player.stop()
			player.stream = null


func _clear_track_segments() -> void:
	for segment in _road_segments:
		if is_instance_valid(segment):
			segment.free()
	_road_segments.clear()


func _process(delta: float) -> void:
	_update_track(delta)
	_update_camera(delta)
	_update_engine_audio(delta)
	_update_combo_feedback(delta)

	if _state == GameState.PLAYING:
		_update_run(delta)
	else:
		_player.set_stealth_visual(false)
		_message_time = maxf(0.0, _message_time - delta)
		_player.set_speed_ratio(0.32)
		_update_hud()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and (not event.pressed or event.echo):
		return

	if event.is_action_pressed(&"start_game"):
		if _state != GameState.PLAYING:
			_start_run()
			get_viewport().set_input_as_handled()
		return

	if _state == GameState.PLAYING:
		if event.is_action_pressed(&"move_left"):
			_player.request_lane_change(-1)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed(&"move_right"):
			_player.request_lane_change(1)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed(&"jump"):
			_attempt_jump_or_hijack()
			get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed(&"upgrade_accel"):
		_purchase_upgrade("upgrade_accel", "加速度")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"upgrade_speed"):
		_purchase_upgrade("upgrade_speed", "最高速")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"upgrade_efficiency"):
		_purchase_upgrade("upgrade_efficiency", "节油")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"promote_rank"):
		_promote_rank()
		get_viewport().set_input_as_handled()


func _start_run() -> void:
	_clear_traffic()
	_clear_pickups()
	_state = GameState.PLAYING
	_speed = 15.0
	_distance_m = 0.0
	_score = 0
	_score_accumulator = 0.0
	_fuel = _starting_fuel()
	_combo = 0
	_combo_timer = 0.0
	_best_combo = 0
	_combo_overdrive_timer = 0.0
	_stealth_timer = 0.0
	_pickup_spawn_timer = PICKUP_START_DELAY
	_ram_hits = 0
	_collision_recovery_timer = 0.0
	_post_hijack_invulnerability_timer = 0.0
	_spawn_timer = 0.7
	_active_hijack_vehicle = null
	_last_wave_signature = ""
	_last_finish_reason = ""
	_last_credits_earned = 0
	_player.reset_for_run(_current_rank()["body"], _current_rank()["accent"])
	_reset_combo_feedback_visuals()
	_hide_front_screens()
	_play_cue(_start_cue, 1.0 + _rng.randf_range(-0.02, 0.02))
	_play_voice("go_go_go")
	_set_message("高速模式启动。先贴尾补油，接上大车后就能变线冲开整列车流。", 2.0)
	_update_hud()


func _update_run(delta: float) -> void:
	_collision_recovery_timer = maxf(0.0, _collision_recovery_timer - delta)
	_post_hijack_invulnerability_timer = maxf(0.0, _post_hijack_invulnerability_timer - delta)
	_stealth_timer = maxf(0.0, _stealth_timer - delta)
	_combo_overdrive_timer = maxf(0.0, _combo_overdrive_timer - delta)
	_pickup_spawn_timer = maxf(0.0, _pickup_spawn_timer - delta)
	_player.set_stealth_visual(_stealth_timer > 0.0)

	if _active_hijack_vehicle != null and not _player.is_hijacked():
		_remove_vehicle(_active_hijack_vehicle)
		_active_hijack_vehicle = null
		_post_hijack_invulnerability_timer = POST_HIJACK_INVULNERABILITY_DURATION
		_player.begin_recovery_invulnerability(POST_HIJACK_INVULNERABILITY_DURATION)
		_set_message("脱离大车，落地护盾已启动。先缓一拍再重新贴尾切线。", 1.1)

	var target_speed := _target_speed_for_distance()
	if _player.is_hijacked():
		_speed = minf(target_speed + 5.2, _speed + _acceleration_stat() * 0.52 * delta)
	else:
		if _collision_recovery_timer > 0.0:
			var recovery_progress := 1.0 - (_collision_recovery_timer / COLLISION_RECOVERY_DURATION)
			var recovery_cap := lerpf(COLLISION_RECOVERY_ENTRY_SPEED, target_speed * 0.82, clampf(recovery_progress, 0.0, 1.0))
			var recovery_accel := lerpf(0.3, 0.82, clampf(recovery_progress * 1.15, 0.0, 1.0))
			_speed = minf(recovery_cap, _speed + _acceleration_stat() * recovery_accel * delta)
		else:
			_speed = minf(target_speed, _speed + _acceleration_stat() * delta)

		if _stealth_timer <= 0.0 and _combo_overdrive_timer <= 0.0:
			var burn_rate := _fuel_drain_stat() * (0.42 + _speed / maxf(1.0, target_speed + 11.0))
			_fuel = maxf(0.0, _fuel - burn_rate * delta)
			if _fuel <= 0.0:
				_finish_run("燃油耗尽。大车没接上时，要靠连击补油。")
				return

	_distance_m += _speed * delta * 1.9
	_score_accumulator += _speed * delta * (28.0 + float(_combo) * 10.0)
	_score = int(round(_score_accumulator))

	_spawn_timer -= delta
	while _spawn_timer <= 0.0:
		_spawn_wave()
		_spawn_timer += _next_spawn_interval()

	_update_pickups(delta)
	_update_traffic(delta)
	if _state != GameState.PLAYING:
		return

	if _combo_timer > 0.0:
		_combo_timer = maxf(0.0, _combo_timer - delta)
		if _combo_timer == 0.0:
			_combo = 0

	if _stealth_timer <= 0.0 and _pickup_spawn_timer <= 0.0:
		_spawn_stealth_pickup()
		_pickup_spawn_timer = _rng.randf_range(PICKUP_RESPAWN_MIN, PICKUP_RESPAWN_MAX)

	_message_time = maxf(0.0, _message_time - delta)
	_player.set_speed_ratio(_speed / maxf(1.0, target_speed + 3.5))
	_update_hud()


func _update_track(delta: float) -> void:
	var scroll_speed := _speed if _state == GameState.PLAYING else 9.0
	for segment in _road_segments:
		segment.position.z += scroll_speed * delta
		if segment.position.z > ROAD_SEGMENT_LENGTH:
			segment.position.z -= ROAD_SEGMENT_LENGTH * ROAD_SEGMENT_COUNT


func _update_camera(delta: float) -> void:
	var ride_lift := 0.5 if _player.is_hijacked() else 0.0
	var follow_x: float = _player.position.x
	var focus_origin: Vector3 = _player.global_position
	if _player.is_hijacked() and is_instance_valid(_active_hijack_vehicle):
		follow_x = _active_hijack_vehicle.position.x
		focus_origin = _active_hijack_vehicle.global_position

	var desired_position := Vector3(follow_x * 0.28, 9.15 + ride_lift, 15.2)
	_camera.position = _camera.position.lerp(desired_position, minf(1.0, delta * 4.0))
	_camera.look_at(focus_origin + Vector3(0.0, 1.45 + ride_lift, -22.0), Vector3.UP)


func _update_pickups(delta: float) -> void:
	for index in range(_pickups.size() - 1, -1, -1):
		var pickup = _pickups[index]
		if not is_instance_valid(pickup):
			_pickups.remove_at(index)
			continue

		pickup.advance(delta, _speed)
		if not _player.is_hijacked() and pickup.can_be_collected(_player.get_lane_index(), PLAYER_Z):
			_collect_pickup(pickup)

		if pickup.should_despawn(PICKUP_DESPAWN_Z):
			pickup.queue_free()
			_pickups.remove_at(index)


func _spawn_stealth_pickup() -> void:
	if _state != GameState.PLAYING:
		return
	if _pickups.size() > 0:
		return

	var lane := _rng.randi_range(0, LANE_X.size() - 1)
	var start_z := -_rng.randf_range(64.0, 92.0)
	for vehicle in _traffic:
		if not is_instance_valid(vehicle):
			continue
		if vehicle.get_lane_index() == lane and vehicle.position.z < start_z + 12.0:
			start_z = minf(start_z, vehicle.position.z - 12.0)

	var pickup = PICKUP_SCENE.instantiate()
	_pickup_root.add_child(pickup)
	pickup.configure(&"stealth", lane, float(LANE_X[lane]), start_z)
	_pickups.append(pickup)


func _collect_pickup(pickup) -> void:
	if pickup == null or not is_instance_valid(pickup):
		return

	pickup.collect()
	_stealth_timer = maxf(_stealth_timer, STEALTH_DURATION)
	_combo_overdrive_timer = maxf(_combo_overdrive_timer, 1.6)
	_fuel = minf(MAX_FUEL, _fuel + 10.0)
	_score += STEALTH_PICKUP_SCORE + _combo * 40
	_score_accumulator = float(_score)
	_pickup_spawn_timer = _rng.randf_range(PICKUP_RESPAWN_MIN, PICKUP_RESPAWN_MAX)
	_player.set_stealth_visual(true)
	_play_cue(_stealth_cue, 1.0 + _rng.randf_range(-0.04, 0.05))
	_show_combo_feedback("INVISIBLE", "穿车连击窗口开启   燃油 +10", Color(0.427451, 0.956863, 1.0, 1.0), max(1, _combo))
	_set_message("吃到隐身道具。现在可以直接穿过车流，用 Combo 把分数和续航一起抬高。", 1.6)


func _update_traffic(delta: float) -> void:
	for index in range(_traffic.size() - 1, -1, -1):
		var vehicle = _traffic[index]
		if not is_instance_valid(vehicle):
			_traffic.remove_at(index)
			continue

		if vehicle == _active_hijack_vehicle:
			vehicle.ride_step(delta, _player.get_lane_index(), float(LANE_X[_player.get_lane_index()]), PLAYER_Z, _speed)
			_player.sync_hijack_proxy(Vector3(vehicle.position.x, 0.0, vehicle.position.z))
		else:
			vehicle.advance(delta, _speed)

		if vehicle != _active_hijack_vehicle and _player.is_hijacked() and is_instance_valid(_active_hijack_vehicle):
			if vehicle.can_be_ram_hit(_player.get_lane_index(), _active_hijack_vehicle.position.z):
				_ram_vehicle(vehicle)
				continue

		if vehicle != _active_hijack_vehicle and _stealth_timer > 0.0 and not _player.is_hijacked():
			if vehicle.can_be_stealth_combo(_player.get_lane_index(), PLAYER_Z):
				_award_phase_combo(vehicle)
				continue

		if vehicle != _active_hijack_vehicle and _player.is_airborne() and not _player.is_hijacked():
			if vehicle.can_be_hijacked(_player.get_lane_index(), PLAYER_Z):
				_complete_hijack(vehicle)
				return

		if vehicle != _active_hijack_vehicle and not _player.is_hijacked() and _stealth_timer <= 0.0 and _post_hijack_invulnerability_timer <= 0.0 and _collision_recovery_timer <= 0.0:
			if vehicle.get_lane_index() == _player.get_lane_index() and vehicle.is_collision_threat(PLAYER_Z):
				_handle_player_collision(vehicle)
				continue

		if vehicle.has_cleared_player(PLAYER_Z):
			_award_near_miss(vehicle)

		if vehicle.should_despawn(DESPAWN_Z):
			vehicle.queue_free()
			_traffic.remove_at(index)


func _on_player_lane_changed(from_lane: int, _to_lane: int) -> void:
	if _state != GameState.PLAYING or _player.is_hijacked():
		return

	var candidate = _find_near_miss_candidate(from_lane)
	if candidate != null:
		candidate.arm_near_miss()


func _attempt_jump_or_hijack() -> void:
	if _player.is_hijacked():
		_set_message("当前已经在控制一辆大车，先撞开车流，等接管结束后再找下一辆。", 0.8)
		return

	var truck = _find_hijack_truck()
	if truck != null:
		_complete_hijack(truck)
		return

	if _player.begin_jump():
		_play_cue(_jump_cue, 0.98 + _rng.randf_range(-0.05, 0.06))
		_set_message("已起跳。保持同车道贴近大车，接上后就能直接操控它清路。", 1.0)


func _complete_hijack(truck) -> void:
	if truck == null or not is_instance_valid(truck):
		return

	if _active_hijack_vehicle != null and _active_hijack_vehicle != truck:
		_remove_vehicle(_active_hijack_vehicle)
		_active_hijack_vehicle = null

	var hijack_anchor := Vector3(float(LANE_X[_player.get_lane_index()]), 0.0, PLAYER_Z)
	truck.position = hijack_anchor
	truck.begin_hijack()
	_active_hijack_vehicle = truck
	_player.begin_hijack(HIJACK_DURATION, hijack_anchor)
	_score += 320 + _combo * 90
	_score_accumulator = float(_score)
	_combo_timer = maxf(_combo_timer, 1.0)
	_play_cue(_hijack_cue, 1.0 + minf(0.12, float(_combo) * 0.02))
	_set_message("劫持成功。现在可左右变线并撞飞前车，期间不耗油。", 1.45)


func _ram_vehicle(vehicle) -> void:
	if not is_instance_valid(vehicle) or not is_instance_valid(_active_hijack_vehicle):
		return

	vehicle.begin_ram_knockback(_active_hijack_vehicle.position.x, _speed)
	_ram_hits += 1
	var ram_score := 180 + _combo * 35
	_score += ram_score
	_score_accumulator = float(_score)
	_player.extend_hijack(0.32)
	_play_cue(_crash_cue, 0.84 + _rng.randf_range(-0.06, 0.05), false)
	_set_message("冲撞清场 x%d  得分 +%d" % [_ram_hits, ram_score], 0.75)


func _find_near_miss_candidate(lane: int):
	var candidate = null
	var best_z := -1000000.0
	for vehicle in _traffic:
		if not is_instance_valid(vehicle):
			continue
		if vehicle.get_lane_index() != lane:
			continue
		if vehicle.can_arm_near_miss(PLAYER_Z) and vehicle.position.z > best_z:
			best_z = vehicle.position.z
			candidate = vehicle
	return candidate


func _find_hijack_truck():
	if _player.is_hijacked():
		return null

	var candidate = null
	var best_z := -1000000.0
	for vehicle in _traffic:
		if not is_instance_valid(vehicle):
			continue
		if vehicle.can_be_hijacked(_player.get_lane_index(), PLAYER_Z) and vehicle.position.z > best_z:
			best_z = vehicle.position.z
			candidate = vehicle
	return candidate


func _combo_callout_for_count(combo_count: int) -> Dictionary:
	var selected: Dictionary = COMBO_CALLOUTS[0]
	for callout in COMBO_CALLOUTS:
		if combo_count >= int(callout["min_combo"]):
			selected = callout
		else:
			break
	return selected


func _award_combo(vehicle, source: StringName) -> void:
	if vehicle == null or not is_instance_valid(vehicle):
		return

	if source == &"phase":
		vehicle.mark_stealth_combo_awarded()
	else:
		vehicle.mark_near_miss_awarded()

	if _combo_timer > 0.0:
		_combo += 1
	else:
		_combo = 1

	_combo_timer = COMBO_WINDOW + minf(0.7, float(_combo) * 0.04)
	_best_combo = max(_best_combo, _combo)

	var score_gain := 140 * _combo
	var fuel_gain := minf(30.0, 11.0 + float(_combo) * 2.4)
	if source == &"phase":
		score_gain = int(round(score_gain * 1.4))
		fuel_gain = minf(36.0, fuel_gain + 4.5 + float(_combo) * 0.5)
		_stealth_timer = minf(STEALTH_DURATION + 1.6, _stealth_timer + 0.18)

	if _combo >= COMBO_OVERDRIVE_THRESHOLD:
		_combo_overdrive_timer = maxf(_combo_overdrive_timer, 0.8 + float(_combo - COMBO_OVERDRIVE_THRESHOLD) * COMBO_OVERDRIVE_STEP)

	_fuel = minf(MAX_FUEL, _fuel + fuel_gain)
	_score += score_gain
	_score_accumulator = float(_score)

	var callout := _combo_callout_for_count(_combo)
	var detail := String(callout["detail"])
	if source == &"phase":
		detail = "隐身穿车 x%d   燃油 +%d" % [_combo, int(round(fuel_gain))]
	else:
		detail = "%s   燃油 +%d" % [detail, int(round(fuel_gain))]

	_show_combo_feedback(String(callout["text"]), detail, callout["color"], _combo)
	_play_cue(_near_miss_cue, 1.0 + minf(0.22, float(_combo - 1) * 0.04), false)
	_play_voice(String(callout["voice"]))
	if source == &"phase":
		_set_message("隐身穿车 x%d  得分 +%d  燃油 +%d" % [_combo, score_gain, int(round(fuel_gain))], 1.15)
	else:
		_set_message("险超连击 x%d  得分 +%d  燃油 +%d" % [_combo, score_gain, int(round(fuel_gain))], 1.2)


func _award_near_miss(vehicle) -> void:
	_award_combo(vehicle, &"near_miss")


func _award_phase_combo(vehicle) -> void:
	_award_combo(vehicle, &"phase")


func _handle_player_collision(vehicle) -> void:
	if _state != GameState.PLAYING or not is_instance_valid(vehicle):
		return

	var impact_speed := maxf(10.0, _speed)
	_collision_recovery_timer = COLLISION_RECOVERY_DURATION
	_speed = minf(_speed, COLLISION_RECOVERY_ENTRY_SPEED)
	_combo = 0
	_combo_timer = 0.0
	vehicle.begin_ram_knockback(_player.position.x, impact_speed)
	_player.begin_recovery_invulnerability(COLLISION_RECOVERY_VISUAL_GRACE)
	_play_cue(_crash_cue, 0.9 + _rng.randf_range(-0.05, 0.04), false)
	_set_message("发生碰撞，车速骤降。稳住车身，重新起步。", 1.0)


func _finish_run(reason: String) -> void:
	if _state != GameState.PLAYING:
		return

	_state = GameState.GAME_OVER
	_combo = 0
	_combo_timer = 0.0

	if _active_hijack_vehicle != null:
		_remove_vehicle(_active_hijack_vehicle)
		_active_hijack_vehicle = null
	_clear_pickups()
	_player.set_stealth_visual(false)
	_stealth_timer = 0.0
	_combo_overdrive_timer = 0.0

	var credits := _calculate_run_credits()
	_save_data["credits"] = int(_save_data["credits"]) + credits
	_save_data["best_distance"] = maxf(float(_save_data["best_distance"]), _distance_m)
	_save_data["best_score"] = max(int(_save_data["best_score"]), _score)
	_save_game()
	_apply_rank_palette_to_player()
	_last_finish_reason = reason
	_last_credits_earned = credits
	_last_ram_hits = _ram_hits
	if reason.contains("燃油"):
		_play_cue(_fuel_empty_cue)
	else:
		_play_cue(_crash_cue)
	_set_message(reason, 3.0)
	_refresh_front_screens()
	_show_end_screen()
	_update_hud()


func _calculate_run_credits() -> int:
	return max(60, int(round(_distance_m * 0.3 + float(_best_combo) * 90.0 + float(_ram_hits) * 42.0 + float(_score) * 0.018)))


func _purchase_upgrade(key: String, label: String) -> void:
	var level := int(_save_data[key])
	if level >= MAX_UPGRADE_LEVEL:
		_set_message("%s已经满级。" % label, 1.2)
		return

	var cost := _upgrade_cost(key, level)
	if int(_save_data["credits"]) < cost:
		_set_message("%s升级需要 %d credits。" % [label, cost], 1.2)
		return

	_save_data["credits"] = int(_save_data["credits"]) - cost
	_save_data[key] = level + 1
	_save_game()
	_refresh_front_screens()
	_update_hud()
	_play_cue(_upgrade_cue, 1.0 + _rng.randf_range(-0.04, 0.05))
	_set_message("%s提升到 Lv.%d。" % [label, level + 1], 1.2)


func _promote_rank() -> void:
	var current_rank_index := int(_save_data["rank_index"])
	if current_rank_index >= RANKS.size() - 1:
		_set_message("已经是最高的 T 级机甲。", 1.4)
		return

	var next_rank: Dictionary = RANKS[current_rank_index + 1]
	var cost := int(next_rank["promotion_cost"])
	if int(_save_data["credits"]) < cost:
		_set_message("晋升到 %s 需要 %d credits。" % [next_rank["id"], cost], 1.4)
		return

	_save_data["credits"] = int(_save_data["credits"]) - cost
	_save_data["rank_index"] = current_rank_index + 1
	_save_game()
	_apply_rank_palette_to_player()
	_refresh_front_screens()
	_update_hud()
	_play_cue(_promote_cue)
	_set_message("已晋升到 %s %s。" % [next_rank["id"], next_rank["name"]], 1.4)


func _upgrade_cost(key: String, level: int) -> int:
	var base_cost := 180
	if key == "upgrade_speed":
		base_cost = 220
	elif key == "upgrade_efficiency":
		base_cost = 200
	return base_cost + level * 120


func _apply_rank_palette_to_player() -> void:
	var rank := _current_rank()
	_player.apply_palette(rank["body"], rank["accent"])


func _current_rank() -> Dictionary:
	return RANKS[clampi(int(_save_data["rank_index"]), 0, RANKS.size() - 1)]


func _starting_fuel() -> float:
	return minf(MAX_FUEL, START_FUEL + float(_save_data["upgrade_efficiency"]) * 3.4 + float(_current_rank()["eco_bonus"]) * 8.0)


func _acceleration_stat() -> float:
	return 8.2 + float(_current_rank()["accel_bonus"]) + float(_save_data["upgrade_accel"]) * 1.2


func _target_speed_for_distance() -> float:
	var base_speed := 24.0 + float(_current_rank()["speed_bonus"]) + float(_save_data["upgrade_speed"]) * 2.9
	return base_speed + minf(16.0, _distance_m / 140.0)


func _fuel_drain_stat() -> float:
	return maxf(1.9, 6.1 - float(_current_rank()["eco_bonus"]) * 0.9 - float(_save_data["upgrade_efficiency"]) * 0.74)


func _difficulty_ratio() -> float:
	return clampf(_distance_m / 2400.0, 0.0, 1.0)


func _next_spawn_interval() -> float:
	var difficulty := _difficulty_ratio()
	return lerpf(TRAFFIC_SPAWN_INTERVAL_EASY, TRAFFIC_SPAWN_INTERVAL_HARD, difficulty) * _rng.randf_range(0.96, 1.18)


func _active_traffic_count() -> int:
	var count := 0
	for vehicle in _traffic:
		if is_instance_valid(vehicle) and vehicle != _active_hijack_vehicle:
			count += 1
	return count


func _spawn_wave() -> void:
	var difficulty := _difficulty_ratio()
	var active_traffic := _active_traffic_count()
	var traffic_cap := int(round(lerpf(TRAFFIC_ACTIVE_CAP_EASY, TRAFFIC_ACTIVE_CAP_HARD, difficulty)))
	if active_traffic >= traffic_cap:
		return

	var patterns := [
		[0],
		[1],
		[2],
		[3],
		[4],
		[1, 2],
		[2, 3],
		[0, 2],
		[2, 4],
		[0, 3],
		[1, 3],
		[1, 2, 3],
		[0, 2, 4],
	]

	if difficulty > 0.45:
		patterns.append([0, 1, 3])
		patterns.append([1, 3, 4])
		patterns.append([0, 2, 3])
		patterns.append([1, 2, 4])
		patterns.append([0, 1, 4])

	var max_lanes_per_wave := 2 if difficulty < 0.38 else 3
	if traffic_cap - active_traffic <= 2:
		max_lanes_per_wave = min(max_lanes_per_wave, 2)

	var eligible_patterns: Array = []
	for candidate in patterns:
		if candidate.size() <= max_lanes_per_wave:
			eligible_patterns.append(candidate)
	if eligible_patterns.is_empty():
		eligible_patterns = [[1], [2], [3]]

	var pattern: Array = eligible_patterns[_rng.randi_range(0, eligible_patterns.size() - 1)]
	var signature := str(pattern)
	if signature == _last_wave_signature and _rng.randf() < 0.5:
		pattern = eligible_patterns[_rng.randi_range(0, eligible_patterns.size() - 1)]
		signature = str(pattern)
	_last_wave_signature = signature

	var base_z := -_rng.randf_range(58.0, 82.0)
	for lane in pattern:
		_spawn_vehicle_for_lane(int(lane), base_z - _rng.randf_range(0.0, 6.0), difficulty)

	var secondary_chance := lerpf(0.0, TRAFFIC_SECONDARY_WAVE_MAX_CHANCE, difficulty)
	if difficulty > 0.5 and active_traffic <= traffic_cap - 3 and _rng.randf() < secondary_chance:
		var secondary_candidates: Array = []
		for candidate in eligible_patterns:
			if candidate.size() <= 2:
				secondary_candidates.append(candidate)
		if secondary_candidates.is_empty():
			secondary_candidates = [[1], [3]]

		var secondary_pattern: Array = secondary_candidates[_rng.randi_range(0, secondary_candidates.size() - 1)]
		if str(secondary_pattern) != signature:
			var secondary_z := base_z - _rng.randf_range(26.0, 38.0)
			for lane in secondary_pattern:
				_spawn_vehicle_for_lane(int(lane), secondary_z - _rng.randf_range(0.0, 5.0), difficulty * 0.9)


func _spawn_vehicle_for_lane(lane: int, desired_z: float, difficulty: float) -> void:
	var kind := _pick_vehicle_kind(difficulty)
	var start_z := desired_z
	var lane_spacing := lerpf(TRAFFIC_LANE_SPACING_EASY, TRAFFIC_LANE_SPACING_HARD, difficulty)
	var lane_backstep := maxf(18.0, lane_spacing - 2.0)

	for vehicle in _traffic:
		if not is_instance_valid(vehicle):
			continue
		if vehicle.get_lane_index() == lane and vehicle.position.z < start_z + lane_spacing:
			start_z = minf(start_z, vehicle.position.z - lane_backstep)

	var relative_speed := _rng.randf_range(0.72, 0.96 + difficulty * 0.12)
	if kind == &"truck":
		relative_speed = _rng.randf_range(0.5, 0.72 + difficulty * 0.05)
	elif kind == &"van":
		relative_speed = _rng.randf_range(0.6, 0.84 + difficulty * 0.08)

	var variant := _pick_vehicle_variant(kind)
	var palette := _pick_vehicle_palette(kind)
	var vehicle = TRAFFIC_SCENE.instantiate()
	_traffic_root.add_child(vehicle)
	vehicle.configure(kind, lane, float(LANE_X[lane]), start_z, relative_speed, palette[0], palette[1], variant)
	_traffic.append(vehicle)


func _pick_vehicle_kind(difficulty: float) -> StringName:
	var roll := _rng.randf()
	if roll < lerpf(0.2, 0.3, difficulty):
		return &"truck"
	if roll < lerpf(0.5, 0.64, difficulty):
		return &"van"
	return &"car"


func _pick_vehicle_variant(kind: StringName) -> StringName:
	var variants: Array = VEHICLE_VARIANTS.get(kind, VEHICLE_VARIANTS[&"car"])
	return variants[_rng.randi_range(0, variants.size() - 1)]


func _pick_vehicle_palette(kind: StringName) -> Array:
	var palettes := [
		[Color(0.85098, 0.278431, 0.247059, 1), Color(1, 0.807843, 0.352941, 1)],
		[Color(0.223529, 0.639216, 0.901961, 1), Color(0.980392, 0.556863, 0.247059, 1)],
		[Color(0.254902, 0.784314, 0.54902, 1), Color(0.984314, 0.341176, 0.439216, 1)],
		[Color(0.905882, 0.482353, 0.196078, 1), Color(0.996078, 0.901961, 0.478431, 1)],
	]

	if kind == &"truck":
		palettes = [
			[Color(0.431373, 0.505882, 0.878431, 1), Color(0.2, 0.937255, 0.890196, 1)],
			[Color(0.882353, 0.423529, 0.227451, 1), Color(1, 0.862745, 0.435294, 1)],
			[Color(0.196078, 0.729412, 0.678431, 1), Color(0.996078, 0.615686, 0.247059, 1)],
		]
	elif kind == &"van":
		palettes = [
			[Color(0.980392, 0.717647, 0.239216, 1), Color(0.227451, 0.94902, 0.831373, 1)],
			[Color(0.933333, 0.427451, 0.203922, 1), Color(1, 0.905882, 0.454902, 1)],
			[Color(0.917647, 0.909804, 0.870588, 1), Color(0.996078, 0.52549, 0.223529, 1)],
		]

	return palettes[_rng.randi_range(0, palettes.size() - 1)]


func _set_message(text: String, duration: float) -> void:
	_message_text = text
	_message_time = duration
	_message_label.text = text


func _refresh_front_screens() -> void:
	_refresh_start_screen()
	_refresh_end_screen()


func _refresh_start_screen() -> void:
	var rank := _current_rank()
	var body_color: Color = rank["body"]
	var accent_color: Color = rank["accent"]
	var title_color := body_color.lerp(Color(1.0, 1.0, 1.0, 1.0), 0.45)
	var info_lines := PackedStringArray([
		"目标：尽量跑得更远，用险超连击把燃油续住。",
		"险超：贴近前车尾流后再切线，成功可回补燃油并抬高分数倍率。",
		"碰撞：撞上前车只会重刹减速并清空当前连击，真正结束条件只有燃油见底。",
		"劫持：与大型车辆同车道接近时按 Space 起跳，接上后可直接控制它左右变线。",
		"隐身：吃到蓝色隐身道具后可直接穿车，期间不判定碰撞，穿车本身也会继续堆 Combo。",
		"缓冲：劫持结束落地时会触发短暂护盾，给你一点重新找线的时间。",
		"冲撞：劫持期间撞上同车道车辆会把它们甩飞，还会补一点劫持持续时间。",
		"高连击：Combo 越高，语音鼓励越强；5 连击后还会触发短暂节油窗口。",
		"操作：A / D 或方向键变线，Space 跳跃 / 劫持，Enter 发车，1 / 2 / 3 升级，P 晋升。",
	])

	_start_tag_label.text = "高速简报"
	_start_title_label.text = "Infinite Racer"
	_start_summary_label.text = "在五车道高速里贴尾切线、连击补油，并在劫持大型车辆后直接撞开密集封锁。"
	_start_info_label.text = "\n".join(info_lines)
	_start_garage_label.text = _garage_status_text("车库状态", true)
	_start_prompt_label.text = "按 Enter 发车。Space 只负责跳跃 / 劫持。"

	_start_tag_label.modulate = accent_color
	_start_title_label.modulate = title_color
	_start_divider.color = accent_color
	_start_prompt_label.modulate = accent_color
	_start_screen_shade.color = Color(accent_color.r * 0.1, accent_color.g * 0.11, accent_color.b * 0.16, 0.56)


func _refresh_end_screen() -> void:
	var rank := _current_rank()
	var body_color: Color = rank["body"]
	var accent_color: Color = rank["accent"]
	var title_color := body_color.lerp(Color(1.0, 1.0, 1.0, 1.0), 0.45)
	var report_title := "本局结束"
	var report_summary := "继续把 credits 投进车库，再试着把这段高速跑得更远。"

	if _last_finish_reason.contains("碰撞"):
		accent_color = Color(1.0, 0.427451, 0.356863, 1.0)
		title_color = Color(1.0, 0.843137, 0.780392, 1.0)
		report_title = "撞上前车"
		report_summary = "判断慢了一拍，没能在最后的切线窗口里从车流中脱身。"
	elif _last_finish_reason.contains("燃油"):
		accent_color = Color(1.0, 0.745098, 0.309804, 1.0)
		title_color = Color(1.0, 0.917647, 0.772549, 1.0)
		report_title = "燃油见底"
		report_summary = "险超补油链断掉以后，续航没能撑过这段更密集的车阵。"

	var report_lines := PackedStringArray([
		"结束原因：%s" % _last_finish_reason,
		"本局里程：%dm" % int(round(_distance_m)),
		"本局得分：%d" % _score,
		"最佳 Combo：x%d" % _best_combo,
		"冲撞清场：%d 次" % _last_ram_hits,
		"本局收入：%d credits" % _last_credits_earned,
		"当前库存：%d credits" % int(_save_data["credits"]),
		"历史最远：%dm   历史最高分：%d" % [int(round(float(_save_data["best_distance"]))), int(_save_data["best_score"])],
	])

	_result_tag_label.text = "本局结算"
	_result_title_label.text = report_title
	_result_summary_label.text = report_summary
	_result_stats_label.text = "\n".join(report_lines)
	_result_garage_label.text = _garage_status_text("下一趟出发前", false)
	_result_prompt_label.text = "按 Enter 再跑一局，或先按 1 / 2 / 3 / P 调整车库。"

	_result_tag_label.modulate = accent_color
	_result_title_label.modulate = title_color
	_result_divider.color = accent_color
	_result_prompt_label.modulate = accent_color
	_end_screen_shade.color = Color(accent_color.r * 0.11, accent_color.g * 0.11, accent_color.b * 0.16, 0.62)


func _garage_status_text(title: String, include_records: bool) -> String:
	var rank := _current_rank()
	var lines := PackedStringArray([
		title,
		"Credits %d   Rank %s %s" % [int(_save_data["credits"]), rank["id"], rank["name"]],
		_upgrade_status_line("upgrade_accel", "1", "加速度"),
		_upgrade_status_line("upgrade_speed", "2", "最高速"),
		_upgrade_status_line("upgrade_efficiency", "3", "节油"),
		_promotion_status_line(),
	])

	if include_records:
		lines.append("最佳里程 %dm   最佳分数 %d" % [int(round(float(_save_data["best_distance"]))), int(_save_data["best_score"])])

	return "\n".join(lines)


func _upgrade_status_line(key: String, hotkey: String, label: String) -> String:
	var level := int(_save_data[key])
	if level >= MAX_UPGRADE_LEVEL:
		return "%s %s Lv.%d   已满级" % [hotkey, label, level]
	return "%s %s Lv.%d   花费 %d" % [hotkey, label, level, _upgrade_cost(key, level)]


func _promotion_status_line() -> String:
	var current_rank_index := int(_save_data["rank_index"])
	if current_rank_index >= RANKS.size() - 1:
		return "P 晋升：已达最高 T 级"

	var next_rank: Dictionary = RANKS[current_rank_index + 1]
	return "P 晋升到 %s %s   花费 %d" % [next_rank["id"], next_rank["name"], int(next_rank["promotion_cost"])]


func _show_start_screen() -> void:
	_start_screen.visible = true
	_end_screen.visible = false
	_message_label.visible = false


func _show_end_screen() -> void:
	_start_screen.visible = false
	_end_screen.visible = true
	_message_label.visible = false


func _hide_front_screens() -> void:
	_start_screen.visible = false
	_end_screen.visible = false
	_message_label.visible = true


func _update_hud() -> void:
	var display_speed := int(round(_speed * 8.4))
	_metrics_label.text = "Speed %03d km/h   Distance %04d m   Score %d   Credits %d" % [
		display_speed,
		int(round(_distance_m)),
		_score,
		int(_save_data["credits"]),
	]

	_fuel_label.text = "Fuel %s %d%%" % [_make_meter(_fuel / MAX_FUEL, 20), int(round(_fuel))]
	if _stealth_timer > 0.0:
		_fuel_label.text += "   Stealth %.1fs" % _stealth_timer
	elif _combo_overdrive_timer > 0.0:
		_fuel_label.text += "   Fuel Save %.1fs" % _combo_overdrive_timer

	var hijack_state := "SEARCH"
	if _player.is_hijacked():
		hijack_state = "RAMPAGE"
	elif _collision_recovery_timer > 0.0:
		hijack_state = "RECOVER"
	elif _post_hijack_invulnerability_timer > 0.0:
		hijack_state = "SHIELD"
	elif _state == GameState.PLAYING and _find_hijack_truck() != null:
		hijack_state = "READY"

	var combo_title := "IDLE"
	if _combo > 0:
		combo_title = String(_combo_callout_for_count(_combo)["text"])
	_combo_label.text = "Combo x%d %s   Best x%d   Ram x%d   Hijack %s" % [_combo, combo_title, _best_combo, _ram_hits, hijack_state]

	var rank := _current_rank()
	_rank_label.text = "Rank %s %s   Accel %d   Speed %d   Eco %d" % [
		rank["id"],
		rank["name"],
		int(_save_data["upgrade_accel"]),
		int(_save_data["upgrade_speed"]),
		int(_save_data["upgrade_efficiency"]),
	]

	if _message_time <= 0.0:
		if _state == GameState.PLAYING:
			if _collision_recovery_timer > 0.0:
				_message_label.text = "碰撞恢复中，先稳住当前车道，等车速重新爬起来再继续贴尾。"
			elif _stealth_timer > 0.0:
				_message_label.text = "隐身穿车中，直接走同车道吃车流，把 Combo 一路往上堆。"
			elif _combo_overdrive_timer > 0.0:
				_message_label.text = "高连击节油生效中，趁这段窗口继续贴尾抬分。"
			elif _post_hijack_invulnerability_timer > 0.0:
				_message_label.text = "落地护盾生效中，先调整车道和节奏，再继续贴尾补油。"
			else:
				_message_label.text = "先贴近前车切尾补油；就算失误撞上也只是掉速，真正失败只有燃油见底。"
		elif _state == GameState.READY:
			_message_label.text = "车库可在开局前消费 credits；升级会直接影响续航和速度上限。"
		else:
			_message_label.text = "先花 credits 升级，再继续冲更远的距离。"
	else:
		_message_label.text = _message_text


func _make_meter(ratio: float, length: int) -> String:
	var clamped_ratio := clampf(ratio, 0.0, 1.0)
	var filled := int(round(clamped_ratio * length))
	var meter := ""
	for index in range(length):
		meter += "#" if index < filled else "-"
	return meter


func _build_track() -> void:
	var road_material := _make_material(Color(0.372549, 0.403922, 0.45098, 1), 0.08)
	var shoulder_material := _make_material(Color(0.686275, 0.764706, 0.741176, 1), 0.14)
	var divider_material := _make_material(Color(0.996078, 0.92549, 0.639216, 1), 0.22)
	var skyline_materials := [
		_make_material(Color(0.541176, 0.709804, 0.894118, 1), 0.1),
		_make_material(Color(0.921569, 0.760784, 0.631373, 1), 0.08),
		_make_material(Color(0.623529, 0.901961, 0.811765, 1), 0.09),
		_make_material(Color(0.960784, 0.592157, 0.654902, 1), 0.1),
	]
	var skyline_trim_materials := [
		_make_material(Color(0.992157, 0.94902, 0.803922, 1), 0.16),
		_make_material(Color(0.368627, 0.87451, 0.984314, 1), 0.18),
		_make_material(Color(1.0, 0.780392, 0.337255, 1), 0.15),
	]
	var skyline_window_materials := [
		_make_glow_material(Color(0.964706, 0.964706, 0.862745, 1), 0.34),
		_make_glow_material(Color(0.505882, 0.937255, 1.0, 1), 0.42),
		_make_glow_material(Color(1.0, 0.654902, 0.827451, 1), 0.36),
	]
	var roadside_panel_materials := [
		_make_glow_material(Color(1.0, 0.694118, 0.356863, 1), 0.34),
		_make_glow_material(Color(0.411765, 0.882353, 0.976471, 1), 0.38),
		_make_glow_material(Color(0.996078, 0.529412, 0.662745, 1), 0.34),
	]
	var roadside_trim_materials := [
		_make_glow_material(Color(0.992157, 0.964706, 0.768627, 1), 0.28),
		_make_glow_material(Color(0.686275, 0.94902, 0.894118, 1), 0.26),
	]
	var half_road := ROAD_WIDTH * 0.5
	var shoulder_width := 0.55
	var roadside_x := half_road + 1.15
	var signal_x := half_road + 1.9
	var skyline_x := half_road + 3.35
	var billboard_x := half_road + 2.75

	for segment_index in range(ROAD_SEGMENT_COUNT):
		var segment := Node3D.new()
		segment.position = Vector3(0.0, 0.0, -ROAD_SEGMENT_LENGTH * float(segment_index))
		_track_root.add_child(segment)
		_road_segments.append(segment)

		_add_box(segment, Vector3(ROAD_WIDTH, 0.12, ROAD_SEGMENT_LENGTH), Vector3(0.0, -0.08, 0.0), road_material)
		_add_box(segment, Vector3(shoulder_width, 0.16, ROAD_SEGMENT_LENGTH), Vector3(-half_road - 0.32, 0.02, 0.0), shoulder_material)
		_add_box(segment, Vector3(shoulder_width, 0.16, ROAD_SEGMENT_LENGTH), Vector3(half_road + 0.32, 0.02, 0.0), shoulder_material)

		for divider_x in DIVIDER_X:
			for marker_index in range(4):
				var marker_z := -ROAD_SEGMENT_LENGTH * 0.5 + 4.0 + float(marker_index) * 8.0
				_add_box(segment, Vector3(0.22, 0.04, 3.0), Vector3(float(divider_x), 0.02, marker_z), divider_material)

		for prop_index in range(4):
			var prop_z := -ROAD_SEGMENT_LENGTH * 0.5 + 4.2 + float(prop_index) * 7.4
			_add_mesh_prop(segment, STREETLIGHT_MESH, Vector3(-roadside_x, 0.0, prop_z - 0.25), Vector3(0, 0, 0), Vector3(2.25, 2.25, 2.25))
			_add_mesh_prop(segment, STREETLIGHT_MESH, Vector3(roadside_x, 0.0, prop_z + 0.25), Vector3(0, 180, 0), Vector3(2.25, 2.25, 2.25))

			var roadside_left_material: StandardMaterial3D = roadside_panel_materials[(segment_index + prop_index) % roadside_panel_materials.size()]
			var roadside_right_material: StandardMaterial3D = roadside_panel_materials[(segment_index + prop_index + 1) % roadside_panel_materials.size()]
			_add_box(segment, Vector3(0.34, 0.03, 2.45), Vector3(-half_road - 0.9, 0.045, prop_z + 0.1), roadside_left_material)
			_add_box(segment, Vector3(0.34, 0.03, 2.45), Vector3(half_road + 0.9, 0.045, prop_z - 0.1), roadside_right_material)
			_add_box(segment, Vector3(0.16, 0.08, 2.55), Vector3(-half_road - 0.62, 0.08, prop_z + 0.1), roadside_trim_materials[prop_index % roadside_trim_materials.size()])
			_add_box(segment, Vector3(0.16, 0.08, 2.55), Vector3(half_road + 0.62, 0.08, prop_z - 0.1), roadside_trim_materials[(prop_index + 1) % roadside_trim_materials.size()])

			if prop_index % 2 == 0:
				_add_mesh_prop(segment, TRAFFIC_LIGHT_MESH, Vector3(-signal_x, 0.0, prop_z + 1.2), Vector3(0, 90, 0), Vector3(4.4, 4.4, 4.4))
				_add_mesh_prop(segment, STOP_SIGN_MESH, Vector3(signal_x - 0.24, 0.0, prop_z - 1.1), Vector3(0, -90, 0), Vector3(4.8, 4.8, 4.8))
			else:
				_add_mesh_prop(segment, WARNING_SIGN_MESH, Vector3(-signal_x + 0.28, 0.0, prop_z + 1.0), Vector3(0, 90, 0), Vector3(5.0, 5.0, 5.0))
				_add_mesh_prop(segment, TRAFFIC_LIGHT_MESH, Vector3(signal_x, 0.0, prop_z - 1.35), Vector3(0, -90, 0), Vector3(4.4, 4.4, 4.4))

			var billboard_material: StandardMaterial3D = roadside_panel_materials[(segment_index + prop_index + 2) % roadside_panel_materials.size()]
			var billboard_trim: StandardMaterial3D = roadside_trim_materials[(segment_index + prop_index) % roadside_trim_materials.size()]
			if prop_index % 2 == 0:
				_add_roadside_billboard(segment, Vector3(-billboard_x, 0.0, prop_z + 0.55), billboard_material, billboard_trim)
			else:
				_add_roadside_billboard(segment, Vector3(billboard_x, 0.0, prop_z - 0.55), billboard_material, billboard_trim)

			for block_index in range(3):
				var skyline_z := -ROAD_SEGMENT_LENGTH * 0.5 + 5.0 + float(block_index) * 10.0
				var skyline_height := 2.4 + float((segment_index + block_index) % 3) * 1.4
				var right_height := skyline_height + 0.8
				var left_size := Vector3(2.4, skyline_height, 2.6)
				var right_size := Vector3(2.1, right_height, 2.2)
				var left_position := Vector3(-skyline_x, skyline_height * 0.5, skyline_z)
				var right_position := Vector3(skyline_x - 0.2, right_height * 0.5, skyline_z - 3.2)
				var left_material: StandardMaterial3D = skyline_materials[(segment_index + block_index) % skyline_materials.size()]
				var right_material: StandardMaterial3D = skyline_materials[(segment_index + block_index + 2) % skyline_materials.size()]
				var left_trim: StandardMaterial3D = skyline_trim_materials[(segment_index + block_index) % skyline_trim_materials.size()]
				var right_trim: StandardMaterial3D = skyline_trim_materials[(segment_index + block_index + 1) % skyline_trim_materials.size()]
				var left_window: StandardMaterial3D = skyline_window_materials[(segment_index + block_index) % skyline_window_materials.size()]
				var right_window: StandardMaterial3D = skyline_window_materials[(segment_index + block_index + 1) % skyline_window_materials.size()]
				var left_neon: StandardMaterial3D = skyline_window_materials[(segment_index + block_index + 2) % skyline_window_materials.size()]
				var right_neon: StandardMaterial3D = skyline_window_materials[(segment_index + block_index) % skyline_window_materials.size()]

				_add_arcade_building(segment, left_size, left_position, left_material, left_trim, left_window, left_neon, -1.0)
				_add_arcade_building(segment, right_size, right_position, right_material, right_trim, right_window, right_neon, 1.0)


func _make_material(albedo_color: Color, emission_energy: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = albedo_color
	material.roughness = 0.55
	material.emission_enabled = true
	material.emission = albedo_color
	material.emission_energy_multiplier = emission_energy
	return material


func _make_glow_material(albedo_color: Color, emission_energy: float, alpha: float = 1.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(albedo_color.r, albedo_color.g, albedo_color.b, alpha)
	material.roughness = 0.08
	material.metallic = 0.02
	material.emission_enabled = true
	material.emission = albedo_color
	material.emission_energy_multiplier = emission_energy
	if alpha < 0.999:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material


func _add_arcade_building(parent: Node3D, size: Vector3, position: Vector3, body_material: StandardMaterial3D, trim_material: StandardMaterial3D, window_material: StandardMaterial3D, neon_material: StandardMaterial3D, edge_sign: float) -> void:
	_add_box(parent, size, position, body_material)
	_add_box(parent, Vector3(size.x + 0.08, 0.18, size.z + 0.08), Vector3(position.x, position.y + size.y * 0.5 + 0.09, position.z), trim_material)
	_add_box(parent, Vector3(size.x * 0.88, 0.16, 0.14), Vector3(position.x, position.y + size.y * 0.08, position.z + size.z * 0.5 + 0.05), trim_material)

	var front_z := position.z + size.z * 0.5 + 0.06
	var window_rows := clampi(int(floor(size.y / 1.45)), 2, 4)
	var bottom_y := position.y - size.y * 0.5
	var top_padding := 0.8
	var bottom_padding := 0.7
	var usable_height := maxf(0.8, size.y - top_padding - bottom_padding)
	var row_step := usable_height / float(window_rows)
	for row_index in range(window_rows):
		var window_y := bottom_y + bottom_padding + row_step * float(row_index) + 0.18
		_add_box(parent, Vector3(size.x * 0.72, 0.12, 0.08), Vector3(position.x, window_y, front_z), window_material)

	_add_box(parent, Vector3(0.14, size.y * 0.74, 0.08), Vector3(position.x + edge_sign * size.x * 0.34, bottom_y + size.y * 0.48, front_z), neon_material)
	_add_box(parent, Vector3(size.x * 0.34, 0.14, 0.08), Vector3(position.x, position.y + size.y * 0.18, front_z), neon_material)


func _add_roadside_billboard(parent: Node3D, base_position: Vector3, panel_material: StandardMaterial3D, trim_material: StandardMaterial3D) -> void:
	_add_box(parent, Vector3(0.12, 2.0, 0.12), Vector3(base_position.x, 1.0, base_position.z), trim_material)
	_add_box(parent, Vector3(0.12, 1.0, 1.72), Vector3(base_position.x, 2.15, base_position.z), panel_material)
	_add_box(parent, Vector3(0.12, 0.14, 1.84), Vector3(base_position.x, 2.62, base_position.z), trim_material)
	_add_box(parent, Vector3(0.12, 0.12, 1.56), Vector3(base_position.x, 1.85, base_position.z), trim_material)


func _add_box(parent: Node3D, size: Vector3, position: Vector3, material: StandardMaterial3D) -> void:
	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh.mesh = box_mesh
	mesh.position = position
	mesh.material_override = material
	parent.add_child(mesh)


func _add_mesh_prop(parent: Node3D, mesh_resource: Mesh, position: Vector3, rotation_degrees: Vector3, scale: Vector3) -> void:
	var mesh := MeshInstance3D.new()
	mesh.mesh = mesh_resource
	mesh.position = position
	mesh.rotation_degrees = rotation_degrees
	mesh.scale = scale
	parent.add_child(mesh)


func _clear_traffic(immediate: bool = false) -> void:
	for vehicle in _traffic:
		if is_instance_valid(vehicle):
			if immediate:
				vehicle.free()
			else:
				vehicle.queue_free()
	_traffic.clear()


func _clear_pickups(immediate: bool = false) -> void:
	for pickup in _pickups:
		if is_instance_valid(pickup):
			if immediate:
				pickup.free()
			else:
				pickup.queue_free()
	_pickups.clear()


func _remove_vehicle(vehicle) -> void:
	if vehicle == null:
		return
	if is_instance_valid(vehicle):
		vehicle.queue_free()
	_traffic.erase(vehicle)


func _default_save_data() -> Dictionary:
	return {
		"credits": 0,
		"best_distance": 0.0,
		"best_score": 0,
		"rank_index": 0,
		"upgrade_accel": 0,
		"upgrade_speed": 0,
		"upgrade_efficiency": 0,
	}


func _load_save() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return

	for key in _save_data.keys():
		_save_data[key] = config.get_value("garage", key, _save_data[key])


func _save_game() -> void:
	var config := ConfigFile.new()
	for key in _save_data.keys():
		config.set_value("garage", key, _save_data[key])
	config.save(SAVE_PATH)
