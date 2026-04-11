class_name SignalSweepAudioController
extends Node

const MIX_RATE := 22050
const SILENT_DB := -40.0
const BRIEFING_VOLUME_DB := -14.0
const GAMEPLAY_VOLUME_DB := -12.0
const AMBIENCE_VOLUME_DB := -22.0

var _briefing_stream: AudioStreamWAV
var _gameplay_stream: AudioStreamWAV
var _ambience_stream: AudioStreamWAV
var _deploy_stream: AudioStreamWAV
var _beacon_stream: AudioStreamWAV
var _hit_stream: AudioStreamWAV
var _spawn_stream: AudioStreamWAV
var _bounce_stream: AudioStreamWAV
var _warning_stream: AudioStreamWAV
var _result_success_stream: AudioStreamWAV
var _result_failure_stream: AudioStreamWAV
var _music_tween: Tween
var _last_warning_second := -1
var _last_bounce_time := -10.0
var _audio_enabled := true

@onready var _briefing_music: AudioStreamPlayer = $BriefingMusic
@onready var _gameplay_music: AudioStreamPlayer = $GameplayMusic
@onready var _ambience_player: AudioStreamPlayer = $AmbiencePlayer
@onready var _ui_player: AudioStreamPlayer = $UiPlayer
@onready var _beacon_player: AudioStreamPlayer = $BeaconPlayer
@onready var _impact_player: AudioStreamPlayer = $ImpactPlayer
@onready var _alert_player: AudioStreamPlayer = $AlertPlayer
@onready var _bounce_player: AudioStreamPlayer = $BouncePlayer
@onready var _warning_player: AudioStreamPlayer = $WarningPlayer
@onready var _result_player: AudioStreamPlayer = $ResultPlayer


func _ready() -> void:
	_audio_enabled = not _is_headless_runtime()
	if not _audio_enabled:
		return

	_build_streams()
	_briefing_music.stream = _briefing_stream
	_gameplay_music.stream = _gameplay_stream
	_ambience_player.stream = _ambience_stream
	_briefing_music.volume_db = SILENT_DB
	_gameplay_music.volume_db = SILENT_DB
	_ambience_player.volume_db = SILENT_DB


func _exit_tree() -> void:
	if not _audio_enabled:
		return

	if _music_tween and _music_tween.is_valid():
		_music_tween.kill()

	var players: Array[AudioStreamPlayer] = [
		_briefing_music,
		_gameplay_music,
		_ambience_player,
		_ui_player,
		_beacon_player,
		_impact_player,
		_alert_player,
		_bounce_player,
		_warning_player,
		_result_player,
	]

	for player in players:
		if player == null:
			continue
		player.stop()
		player.stream = null

	_briefing_stream = null
	_gameplay_stream = null
	_ambience_stream = null
	_deploy_stream = null
	_beacon_stream = null
	_hit_stream = null
	_spawn_stream = null
	_bounce_stream = null
	_warning_stream = null
	_result_success_stream = null
	_result_failure_stream = null


func play_briefing_music() -> void:
	if not _audio_enabled:
		return

	_last_warning_second = -1
	_ensure_ambience()
	_switch_music(_briefing_music, BRIEFING_VOLUME_DB, _gameplay_music)


func play_gameplay_music() -> void:
	if not _audio_enabled:
		return

	_last_warning_second = -1
	_ensure_ambience()
	_switch_music(_gameplay_music, GAMEPLAY_VOLUME_DB, _briefing_music)


func play_deploy_confirm() -> void:
	if not _audio_enabled:
		return

	_play_one_shot(_ui_player, _deploy_stream, 1.0, -3.5)


func play_beacon_collect(progress: float) -> void:
	if not _audio_enabled:
		return

	_play_one_shot(_beacon_player, _beacon_stream, 1.0 + progress * 0.16, -3.0)


func play_player_hit() -> void:
	if not _audio_enabled:
		return

	_play_one_shot(_impact_player, _hit_stream, randf_range(0.96, 1.04), -3.0)


func play_drone_spawn_alert(drone_count: int) -> void:
	if not _audio_enabled:
		return

	var pitch := minf(1.22, 0.96 + float(drone_count) * 0.025)
	_play_one_shot(_alert_player, _spawn_stream, pitch, -5.5)


func play_bounce(edge: StringName) -> void:
	if not _audio_enabled:
		return

	var now := float(Time.get_ticks_msec()) / 1000.0
	if now - _last_bounce_time < 0.08:
		return

	_last_bounce_time = now
	var pitch := 1.0
	match edge:
		&"north":
			pitch = 1.03
		&"south":
			pitch = 0.94
		&"west":
			pitch = 0.98
		&"east":
			pitch = 1.08

	_play_one_shot(_bounce_player, _bounce_stream, pitch, -12.0)


func play_countdown_warning(seconds_left: int) -> void:
	if not _audio_enabled:
		return
	if seconds_left > 10:
		return
	if seconds_left < 0:
		return
	if seconds_left != 10 and seconds_left > 5:
		return
	if _last_warning_second == seconds_left:
		return

	_last_warning_second = seconds_left
	var pitch := 1.0 + float(max(0, 10 - seconds_left)) * 0.045
	_play_one_shot(_warning_player, _warning_stream, pitch, -6.0)


func play_result(success: bool) -> void:
	if not _audio_enabled:
		return

	_last_warning_second = -1
	_stop_music_layers()
	_play_one_shot(_result_player, _result_success_stream if success else _result_failure_stream, 1.0, -1.5 if success else -2.0)


func _ensure_ambience() -> void:
	if not _ambience_player.playing:
		_ambience_player.volume_db = SILENT_DB
		_ambience_player.play()

	create_tween().tween_property(_ambience_player, "volume_db", AMBIENCE_VOLUME_DB, 0.5)


func _switch_music(target_player: AudioStreamPlayer, target_volume_db: float, other_player: AudioStreamPlayer) -> void:
	if _music_tween and _music_tween.is_valid():
		_music_tween.kill()

	if not target_player.playing:
		target_player.volume_db = SILENT_DB
		target_player.play()

	_music_tween = create_tween()
	_music_tween.set_parallel(true)
	_music_tween.tween_property(target_player, "volume_db", target_volume_db, 0.45)

	if other_player.playing:
		_music_tween.tween_property(other_player, "volume_db", SILENT_DB, 0.3)
		_music_tween.chain().tween_callback(Callable(other_player, "stop"))


func _stop_music_layers() -> void:
	if _music_tween and _music_tween.is_valid():
		_music_tween.kill()

	_music_tween = create_tween()
	_music_tween.set_parallel(true)
	if _briefing_music.playing:
		_music_tween.tween_property(_briefing_music, "volume_db", SILENT_DB, 0.25)
	if _gameplay_music.playing:
		_music_tween.tween_property(_gameplay_music, "volume_db", SILENT_DB, 0.25)
	_music_tween.chain().tween_callback(Callable(self, "_stop_music_players"))


func _stop_music_players() -> void:
	_briefing_music.stop()
	_gameplay_music.stop()


func _play_one_shot(player: AudioStreamPlayer, stream: AudioStreamWAV, pitch_scale: float, volume_db: float) -> void:
	player.stop()
	player.stream = stream
	player.pitch_scale = pitch_scale
	player.volume_db = volume_db
	player.play()


func _build_streams() -> void:
	_briefing_stream = _generate_briefing_music_stream()
	_gameplay_stream = _generate_gameplay_music_stream()
	_ambience_stream = _generate_ambience_stream()
	_deploy_stream = _generate_sequence_stream([72, 79], 0.11, 0.18)
	_beacon_stream = _generate_chirp_stream(0.22, 560.0, 1280.0, 0.32, 0.24, 0.01)
	_hit_stream = _generate_hit_stream()
	_spawn_stream = _generate_sequence_stream([52, 59, 64], 0.09, 0.16)
	_bounce_stream = _generate_chirp_stream(0.08, 880.0, 760.0, 0.1, 0.06, 0.02)
	_warning_stream = _generate_chirp_stream(0.1, 940.0, 1040.0, 0.16, 0.08, 0.0)
	_result_success_stream = _generate_sequence_stream([69, 73, 76], 0.13, 0.2)
	_result_failure_stream = _generate_sequence_stream([57, 53, 50], 0.14, 0.22)


func _generate_briefing_music_stream() -> AudioStreamWAV:
	var bpm := 86.0
	var bars := 4
	var sample_count := int(float(bars * 4) * 60.0 / bpm * MIX_RATE)
	var roots: Array[int] = [45, 48, 43, 41]
	var arp_pattern: Array[int] = [0, 7, 10, 7, 3, 7, 12, 10]
	var samples := PackedFloat32Array()
	samples.resize(sample_count)

	for i in range(sample_count):
		var t := float(i) / MIX_RATE
		var beat := t * bpm / 60.0
		var bar_index := int(floor(beat / 4.0)) % roots.size()
		var root: int = roots[bar_index]
		var bass_freq := _midi_to_freq(root - 12)
		var arp_index := int(floor(beat * 2.0)) % arp_pattern.size()
		var arp_step := fmod(beat * 2.0, 1.0)
		var arp_freq := _midi_to_freq(root + arp_pattern[arp_index])
		var bass := sin(TAU * t * bass_freq) * (0.13 + (0.5 + 0.5 * sin(TAU * t * 0.16)) * 0.03)
		var arp_env := pow(maxf(0.0, 1.0 - arp_step), 1.85)
		var arp := sin(TAU * t * arp_freq) * 0.095 * arp_env
		var glass := sin(TAU * t * arp_freq * 2.0) * 0.028 * arp_env
		var hum := sin(TAU * t * 0.08) * 0.04
		var dust := _hash_noise(float(i) * 0.31 + 4.0) * 0.02 * (0.5 + 0.5 * sin(TAU * t * 0.12))
		samples[i] = clampf((bass + arp + glass + hum + dust) * 0.82, -1.0, 1.0)

	return _samples_to_stream(samples, true)


func _generate_gameplay_music_stream() -> AudioStreamWAV:
	var bpm := 112.0
	var bars := 4
	var seconds_per_beat := 60.0 / bpm
	var sample_count := int(float(bars * 4) * seconds_per_beat * MIX_RATE)
	var roots: Array[int] = [45, 48, 50, 43]
	var bass_pattern: Array[int] = [0, 0, 7, 0, 0, 3, 7, 0]
	var lead_pattern: Array[int] = [12, 10, 7, 10, 14, 10, 7, 5]
	var samples := PackedFloat32Array()
	samples.resize(sample_count)

	for i in range(sample_count):
		var t := float(i) / MIX_RATE
		var beat := t * bpm / 60.0
		var bar_index := int(floor(beat / 4.0)) % roots.size()
		var root: int = roots[bar_index]
		var step_index := int(floor(beat * 2.0)) % bass_pattern.size()
		var step_phase := fmod(beat * 2.0, 1.0)
		var bass_freq := _midi_to_freq(root - 12 + bass_pattern[step_index])
		var bass_env := pow(maxf(0.0, 1.0 - step_phase * 1.35), 1.7)
		var bass := sin(TAU * t * bass_freq) * 0.16 * bass_env
		var lead_freq := _midi_to_freq(root + lead_pattern[step_index])
		var lead_env := pow(maxf(0.0, 1.0 - step_phase * 1.7), 1.8)
		var lead := sin(TAU * t * lead_freq) * 0.08 * lead_env
		var local_beat_time := fmod(t, seconds_per_beat)
		var pulse_window := seconds_per_beat * 0.42
		var pulse_ratio := clampf(local_beat_time / pulse_window, 0.0, 1.0)
		var pulse_env := pow(maxf(0.0, 1.0 - pulse_ratio), 3.0)
		var pulse_freq := lerpf(140.0, 56.0, pulse_ratio)
		var thump := sin(TAU * pulse_freq * local_beat_time) * 0.24 * pulse_env
		var tick_phase := fmod(beat * 4.0, 1.0)
		var tick_env := pow(maxf(0.0, 1.0 - tick_phase * 9.0), 2.4)
		var tick := _hash_noise(float(i) * 1.77 + 8.0) * 0.024 * tick_env
		var drive := sin(TAU * t * (bass_freq * 0.5)) * 0.024
		samples[i] = clampf((thump + bass + lead + tick + drive) * 0.94, -1.0, 1.0)

	return _samples_to_stream(samples, true)


func _generate_ambience_stream() -> AudioStreamWAV:
	var sample_count := int(6.0 * MIX_RATE)
	var samples := PackedFloat32Array()
	samples.resize(sample_count)

	for i in range(sample_count):
		var t := float(i) / MIX_RATE
		var rumble := sin(TAU * t * 48.0) * 0.06
		var radar_hum := sin(TAU * t * 92.0) * 0.04 * (0.5 + 0.5 * sin(TAU * t * 0.15))
		var hiss := _hash_noise(float(i) * 0.43 + 12.0) * 0.014 * (0.5 + 0.5 * sin(TAU * t * 0.1))
		samples[i] = clampf(rumble + radar_hum + hiss, -1.0, 1.0) * 0.72

	return _samples_to_stream(samples, true)


func _generate_chirp_stream(duration: float, start_freq: float, end_freq: float, amplitude: float, harmonic: float, noise_amount: float) -> AudioStreamWAV:
	var sample_count := maxi(1, int(duration * MIX_RATE))
	var samples := PackedFloat32Array()
	samples.resize(sample_count)
	var phase := 0.0

	for i in range(sample_count):
		var ratio := float(i) / float(max(1, sample_count - 1))
		var freq := lerpf(start_freq, end_freq, ratio)
		phase = fmod(phase + freq / MIX_RATE, 1.0)
		var env := pow(sin(ratio * PI), 1.25)
		var sample := sin(TAU * phase) * amplitude * env
		sample += sin(TAU * phase * 2.0) * amplitude * harmonic * env
		sample += _hash_noise(float(i) * 0.67 + 21.0) * noise_amount * env
		samples[i] = clampf(sample, -1.0, 1.0)

	return _samples_to_stream(samples, false)


func _generate_hit_stream() -> AudioStreamWAV:
	var duration := 0.34
	var sample_count := int(duration * MIX_RATE)
	var samples := PackedFloat32Array()
	samples.resize(sample_count)
	var phase := 0.0

	for i in range(sample_count):
		var ratio := float(i) / float(max(1, sample_count - 1))
		var freq := lerpf(220.0, 44.0, ratio * ratio)
		phase = fmod(phase + freq / MIX_RATE, 1.0)
		var env := pow(maxf(0.0, 1.0 - ratio), 3.0)
		var tonal := sin(TAU * phase) * 0.28 * env
		var crackle := _hash_noise(float(i) * 2.03 + 2.0) * 0.17 * env
		samples[i] = clampf(tonal + crackle, -1.0, 1.0)

	return _samples_to_stream(samples, false)


func _generate_sequence_stream(notes: Array[int], note_duration: float, amplitude: float) -> AudioStreamWAV:
	var total_duration := float(notes.size()) * note_duration + 0.04
	var sample_count := int(total_duration * MIX_RATE)
	var samples := PackedFloat32Array()
	samples.resize(sample_count)

	for note_index in range(notes.size()):
		var note: int = notes[note_index]
		var start_sample := int(float(note_index) * note_duration * MIX_RATE)
		var end_sample := mini(sample_count, start_sample + int(note_duration * MIX_RATE * 0.82))
		var phase := 0.0
		var freq := _midi_to_freq(note)

		for sample_index in range(start_sample, end_sample):
			var ratio := float(sample_index - start_sample) / float(max(1, end_sample - start_sample))
			var env := pow(sin(ratio * PI), 1.15)
			phase = fmod(phase + freq / MIX_RATE, 1.0)
			var sample := sin(TAU * phase) * amplitude * env
			sample += sin(TAU * phase * 2.0) * amplitude * 0.18 * env
			samples[sample_index] = clampf(samples[sample_index] + sample, -1.0, 1.0)

	return _samples_to_stream(samples, false)


func _samples_to_stream(samples: PackedFloat32Array, loop: bool) -> AudioStreamWAV:
	var data := PackedByteArray()
	data.resize(samples.size() * 2)

	for i in range(samples.size()):
		data.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 32767.0))

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = data

	if loop:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = samples.size()

	return stream


func _midi_to_freq(note: int) -> float:
	return 440.0 * pow(2.0, float(note - 69) / 12.0)


func _hash_noise(seed: float) -> float:
	return _fraction(sin(seed * 12.9898 + 78.233) * 43758.5453) * 2.0 - 1.0


func _fraction(value: float) -> float:
	return value - floor(value)


func _is_headless_runtime() -> bool:
	return OS.has_feature("headless") or DisplayServer.get_name() == "headless"
