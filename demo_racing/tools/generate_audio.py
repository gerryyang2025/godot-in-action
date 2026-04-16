#!/usr/bin/env python3

from __future__ import annotations

import math
import random
import wave
from array import array
from pathlib import Path

SAMPLE_RATE = 44_100
ROOT = Path(__file__).resolve().parents[1]
AUDIO_ROOT = ROOT / "assets" / "audio"
TAU = math.tau


def _ensure_parent(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)


def _clamp(value: float, low: float = -1.0, high: float = 1.0) -> float:
    return max(low, min(high, value))


def _soft_clip(value: float) -> float:
    return math.tanh(value * 1.35)


def _pan_gains(pan: float) -> tuple[float, float]:
    pan = _clamp(pan)
    angle = (pan + 1.0) * math.pi * 0.25
    return math.cos(angle), math.sin(angle)


def _phase_wave(kind: str, phase: float) -> float:
    phase = phase % 1.0
    if kind == "sine":
        return math.sin(TAU * phase)
    if kind == "triangle":
        return 1.0 - 4.0 * abs(phase - 0.5)
    if kind == "square":
        return 1.0 if phase < 0.5 else -1.0
    if kind == "saw":
        return 2.0 * phase - 1.0
    raise ValueError(f"Unsupported waveform: {kind}")


def _env(t: float, duration: float, attack: float, release: float) -> float:
    if t < 0.0 or t > duration:
        return 0.0
    if attack > 0.0 and t < attack:
        return t / attack
    if release > 0.0 and t > duration - release:
        return max(0.0, (duration - t) / release)
    return 1.0


def _make_stereo_buffer(duration: float) -> tuple[list[float], list[float]]:
    frames = int(duration * SAMPLE_RATE)
    return [0.0] * frames, [0.0] * frames


def _make_mono_buffer(duration: float) -> list[float]:
    return [0.0] * int(duration * SAMPLE_RATE)


def _normalize_stereo(left: list[float], right: list[float], target_peak: float = 0.92) -> None:
    peak = max(max(abs(v) for v in left), max(abs(v) for v in right), 1e-6)
    gain = target_peak / peak
    for index in range(len(left)):
        left[index] = _soft_clip(left[index] * gain)
        right[index] = _soft_clip(right[index] * gain)


def _normalize_mono(buffer: list[float], target_peak: float = 0.92) -> None:
    peak = max(max(abs(v) for v in buffer), 1e-6)
    gain = target_peak / peak
    for index in range(len(buffer)):
        buffer[index] = _soft_clip(buffer[index] * gain)


def _write_stereo_wav(path: Path, left: list[float], right: list[float]) -> None:
    _ensure_parent(path)
    frames = len(left)
    data = array("h")
    for index in range(frames):
        data.append(int(_clamp(left[index]) * 32767.0))
        data.append(int(_clamp(right[index]) * 32767.0))

    with wave.open(str(path), "wb") as handle:
        handle.setnchannels(2)
        handle.setsampwidth(2)
        handle.setframerate(SAMPLE_RATE)
        handle.writeframes(data.tobytes())


def _write_mono_wav(path: Path, buffer: list[float]) -> None:
    _ensure_parent(path)
    data = array("h", (int(_clamp(sample) * 32767.0) for sample in buffer))
    with wave.open(str(path), "wb") as handle:
        handle.setnchannels(1)
        handle.setsampwidth(2)
        handle.setframerate(SAMPLE_RATE)
        handle.writeframes(data.tobytes())


def _add_stereo_tone(
    left: list[float],
    right: list[float],
    start_time: float,
    duration: float,
    frequency: float,
    amplitude: float,
    waveform: str = "sine",
    pan: float = 0.0,
    attack: float = 0.01,
    release: float = 0.05,
) -> None:
    start_index = int(start_time * SAMPLE_RATE)
    frame_count = int(duration * SAMPLE_RATE)
    gain_l, gain_r = _pan_gains(pan)
    for offset in range(frame_count):
        index = start_index + offset
        if index >= len(left):
            break
        t = offset / SAMPLE_RATE
        sample = _phase_wave(waveform, frequency * t) * amplitude * _env(t, duration, attack, release)
        left[index] += sample * gain_l
        right[index] += sample * gain_r


def _add_mono_tone(
    buffer: list[float],
    start_time: float,
    duration: float,
    frequency: float,
    amplitude: float,
    waveform: str = "sine",
    attack: float = 0.005,
    release: float = 0.05,
) -> None:
    start_index = int(start_time * SAMPLE_RATE)
    frame_count = int(duration * SAMPLE_RATE)
    for offset in range(frame_count):
        index = start_index + offset
        if index >= len(buffer):
            break
        t = offset / SAMPLE_RATE
        sample = _phase_wave(waveform, frequency * t) * amplitude * _env(t, duration, attack, release)
        buffer[index] += sample


def _add_kick(left: list[float], right: list[float], start_time: float, amplitude: float) -> None:
    duration = 0.22
    start_index = int(start_time * SAMPLE_RATE)
    frame_count = int(duration * SAMPLE_RATE)
    for offset in range(frame_count):
        index = start_index + offset
        if index >= len(left):
            break
        t = offset / SAMPLE_RATE
        env = math.exp(-10.0 * t)
        tone = math.sin(TAU * (118.0 * t + 0.5 * (42.0 - 118.0) * (t * t) / duration))
        click = math.sin(TAU * 1800.0 * t) * math.exp(-55.0 * t)
        sample = amplitude * (tone * env + click * 0.12)
        left[index] += sample
        right[index] += sample


def _add_snare(left: list[float], right: list[float], start_time: float, amplitude: float, rng: random.Random) -> None:
    duration = 0.18
    start_index = int(start_time * SAMPLE_RATE)
    frame_count = int(duration * SAMPLE_RATE)
    for offset in range(frame_count):
        index = start_index + offset
        if index >= len(left):
            break
        t = offset / SAMPLE_RATE
        env = math.exp(-15.0 * t)
        noise = (rng.uniform(-1.0, 1.0) * 0.8 + math.sin(TAU * 190.0 * t) * 0.24) * env
        left[index] += noise * amplitude * 0.95
        right[index] += noise * amplitude * 0.9


def _add_hat(left: list[float], right: list[float], start_time: float, amplitude: float, pan: float, rng: random.Random) -> None:
    duration = 0.055
    start_index = int(start_time * SAMPLE_RATE)
    frame_count = int(duration * SAMPLE_RATE)
    gain_l, gain_r = _pan_gains(pan)
    previous_noise = 0.0
    for offset in range(frame_count):
        index = start_index + offset
        if index >= len(left):
            break
        t = offset / SAMPLE_RATE
        env = math.exp(-42.0 * t)
        current_noise = rng.uniform(-1.0, 1.0)
        high_pass = current_noise - previous_noise * 0.74
        previous_noise = current_noise
        sample = high_pass * amplitude * env
        left[index] += sample * gain_l
        right[index] += sample * gain_r


def generate_music() -> None:
    bpm = 150.0
    beat = 60.0 / bpm
    bars = 16
    duration = bars * 4.0 * beat
    left, right = _make_stereo_buffer(duration)
    rng = random.Random(20260416)

    progression = [
        {"bass": 55.0, "chord": [220.0, 261.63, 329.63], "lead": [440.0, 523.25, 659.25]},
        {"bass": 43.65, "chord": [174.61, 220.0, 261.63], "lead": [349.23, 440.0, 523.25]},
        {"bass": 65.41, "chord": [196.0, 261.63, 329.63], "lead": [392.0, 523.25, 659.25]},
        {"bass": 49.0, "chord": [196.0, 246.94, 293.66], "lead": [392.0, 493.88, 587.33]},
    ]
    arp_pattern = [0, 1, 2, 1, 0, 2, 1, 2]

    for bar in range(bars):
        chord_data = progression[bar % len(progression)]
        bar_time = bar * 4.0 * beat

        for note_index, note in enumerate(chord_data["chord"]):
            pan = -0.35 + note_index * 0.35
            _add_stereo_tone(left, right, bar_time, 4.0 * beat, note, 0.06, waveform="saw", pan=pan, attack=0.06, release=0.24)
            _add_stereo_tone(left, right, bar_time, 4.0 * beat, note * 0.5, 0.02, waveform="sine", pan=0.0, attack=0.04, release=0.28)

        for beat_index in range(4):
            event_time = bar_time + beat_index * beat
            _add_kick(left, right, event_time, 0.55)
            if beat_index in (1, 3):
                _add_snare(left, right, event_time, 0.38, rng)

            _add_hat(left, right, event_time + beat * 0.5, 0.18, -0.2 if beat_index % 2 == 0 else 0.2, rng)
            _add_hat(left, right, event_time + beat * 0.75, 0.1, 0.25 if beat_index % 2 == 0 else -0.25, rng)

            bass_note = chord_data["bass"] * (1.5 if beat_index == 3 else 1.0)
            _add_stereo_tone(left, right, event_time, beat * 0.72, bass_note, 0.16, waveform="square", pan=-0.05, attack=0.004, release=0.08)
            _add_stereo_tone(left, right, event_time + beat * 0.22, beat * 0.28, bass_note * 2.0, 0.05, waveform="sine", pan=0.12, attack=0.002, release=0.04)

        for step in range(8):
            step_time = bar_time + step * beat * 0.5
            lead_note = chord_data["lead"][arp_pattern[step]]
            lead_amp = 0.05 if bar < bars * 0.5 else 0.072
            lead_pan = -0.42 if step % 2 == 0 else 0.42
            _add_stereo_tone(left, right, step_time, beat * 0.26, lead_note, lead_amp, waveform="triangle", pan=lead_pan, attack=0.003, release=0.045)
            if bar >= bars * 0.5:
                _add_stereo_tone(left, right, step_time + 0.045, beat * 0.18, lead_note * 0.5, 0.028, waveform="sine", pan=-lead_pan * 0.5, attack=0.002, release=0.03)

    _normalize_stereo(left, right, target_peak=0.88)
    _write_stereo_wav(AUDIO_ROOT / "music" / "highway_night_drive.wav", left, right)


def generate_engine_loop() -> None:
    duration = 1.0
    left, right = _make_stereo_buffer(duration)
    for index in range(len(left)):
        t = index / SAMPLE_RATE
        pulse = 0.86 + 0.14 * math.sin(TAU * 5.0 * t)
        base = (
            math.sin(TAU * 45.0 * t) * 0.55
            + math.sin(TAU * 90.0 * t + 0.35) * 0.24
            + math.sin(TAU * 135.0 * t + 1.1) * 0.12
            + math.sin(TAU * 180.0 * t + 0.82) * 0.08
        )
        left[index] = _soft_clip(base * pulse * 0.66 + math.sin(TAU * 12.0 * t) * 0.018)
        right[index] = _soft_clip(base * (0.92 + 0.08 * math.sin(TAU * 5.0 * t + 0.4)) * 0.66 + math.sin(TAU * 13.0 * t + 0.2) * 0.016)
    _write_stereo_wav(AUDIO_ROOT / "gameplay" / "engine_loop.wav", left, right)


def generate_jump() -> None:
    duration = 0.28
    buffer = _make_mono_buffer(duration)
    rng = random.Random(31)
    for index in range(len(buffer)):
        t = index / SAMPLE_RATE
        sweep = math.sin(TAU * (260.0 * t + 0.5 * (760.0 - 260.0) * (t * t) / duration))
        noise = rng.uniform(-1.0, 1.0) * math.exp(-18.0 * t)
        env = _env(t, duration, 0.002, 0.14)
        buffer[index] = (sweep * 0.72 + noise * 0.2) * env
    _normalize_mono(buffer, target_peak=0.9)
    _write_mono_wav(AUDIO_ROOT / "gameplay" / "jump.wav", buffer)


def generate_near_miss() -> None:
    duration = 0.18
    buffer = _make_mono_buffer(duration)
    rng = random.Random(77)
    for index in range(len(buffer)):
        t = index / SAMPLE_RATE
        chirp = math.sin(TAU * (920.0 * t + 0.5 * (1680.0 - 920.0) * (t * t) / duration))
        whoosh = rng.uniform(-1.0, 1.0) * math.exp(-24.0 * t)
        env = _env(t, duration, 0.001, 0.09)
        buffer[index] = (chirp * 0.74 + whoosh * 0.18) * env
    _normalize_mono(buffer, target_peak=0.92)
    _write_mono_wav(AUDIO_ROOT / "gameplay" / "near_miss.wav", buffer)


def generate_hijack() -> None:
    duration = 0.72
    buffer = _make_mono_buffer(duration)
    rng = random.Random(211)
    for index in range(len(buffer)):
        t = index / SAMPLE_RATE
        impact = math.sin(TAU * (110.0 * t + 0.5 * (44.0 - 110.0) * (t * t) / 0.18)) * math.exp(-12.0 * t)
        rise = math.sin(TAU * (180.0 * t + 0.5 * (940.0 - 180.0) * (t * t) / duration)) * _env(t, duration, 0.01, 0.18)
        shimmer = rng.uniform(-1.0, 1.0) * math.exp(-8.5 * t)
        buffer[index] = impact * 0.55 + rise * 0.52 + shimmer * 0.09
    _normalize_mono(buffer, target_peak=0.9)
    _write_mono_wav(AUDIO_ROOT / "gameplay" / "hijack.wav", buffer)


def generate_stealth_pickup() -> None:
    duration = 0.52
    buffer = _make_mono_buffer(duration)
    shimmer_notes = [
        (0.00, 0.10, 560.0, 0.22),
        (0.07, 0.12, 740.0, 0.24),
        (0.15, 0.16, 980.0, 0.28),
        (0.26, 0.20, 1320.0, 0.24),
    ]
    for start_time, note_duration, frequency, amplitude in shimmer_notes:
        _add_mono_tone(buffer, start_time, note_duration, frequency, amplitude, waveform="triangle", attack=0.002, release=0.08)
        _add_mono_tone(buffer, start_time + 0.01, note_duration * 0.9, frequency * 0.5, amplitude * 0.42, waveform="sine", attack=0.002, release=0.07)

    rng = random.Random(512)
    for index in range(len(buffer)):
        t = index / SAMPLE_RATE
        sparkle = rng.uniform(-1.0, 1.0) * math.exp(-11.0 * t) * 0.045
        sweep = math.sin(TAU * (420.0 * t + 0.5 * (1120.0 - 420.0) * (t * t) / duration)) * _env(t, duration, 0.01, 0.12)
        buffer[index] += sparkle + sweep * 0.08

    _normalize_mono(buffer, target_peak=0.9)
    _write_mono_wav(AUDIO_ROOT / "gameplay" / "stealth_pickup.wav", buffer)


def generate_start_run() -> None:
    duration = 0.62
    buffer = _make_mono_buffer(duration)
    note_events = [
        (0.00, 0.11, 520.0),
        (0.16, 0.11, 660.0),
        (0.32, 0.18, 840.0),
    ]
    for start_time, note_duration, frequency in note_events:
        _add_mono_tone(buffer, start_time, note_duration, frequency, 0.42, waveform="sine", attack=0.002, release=0.05)
        _add_mono_tone(buffer, start_time, note_duration * 0.8, frequency * 0.5, 0.18, waveform="triangle", attack=0.001, release=0.04)
    _normalize_mono(buffer, target_peak=0.88)
    _write_mono_wav(AUDIO_ROOT / "ui" / "start_run.wav", buffer)


def generate_upgrade() -> None:
    duration = 0.34
    buffer = _make_mono_buffer(duration)
    _add_mono_tone(buffer, 0.00, 0.12, 660.0, 0.42, waveform="triangle", attack=0.002, release=0.04)
    _add_mono_tone(buffer, 0.10, 0.16, 880.0, 0.48, waveform="triangle", attack=0.002, release=0.06)
    _normalize_mono(buffer, target_peak=0.88)
    _write_mono_wav(AUDIO_ROOT / "ui" / "upgrade.wav", buffer)


def generate_promote() -> None:
    duration = 0.74
    buffer = _make_mono_buffer(duration)
    notes = [
        (0.00, 0.12, 523.25),
        (0.10, 0.12, 659.25),
        (0.20, 0.14, 783.99),
        (0.34, 0.24, 1046.5),
    ]
    for start_time, note_duration, frequency in notes:
        _add_mono_tone(buffer, start_time, note_duration, frequency, 0.38, waveform="triangle", attack=0.002, release=0.06)
        _add_mono_tone(buffer, start_time, note_duration * 0.9, frequency * 0.5, 0.16, waveform="sine", attack=0.001, release=0.05)
    _normalize_mono(buffer, target_peak=0.9)
    _write_mono_wav(AUDIO_ROOT / "ui" / "promote.wav", buffer)


def generate_crash() -> None:
    duration = 0.66
    buffer = _make_mono_buffer(duration)
    rng = random.Random(909)
    for index in range(len(buffer)):
        t = index / SAMPLE_RATE
        drop = math.sin(TAU * (180.0 * t + 0.5 * (48.0 - 180.0) * (t * t) / duration)) * math.exp(-6.8 * t)
        grit = rng.uniform(-1.0, 1.0) * math.exp(-9.0 * t)
        metallic = math.sin(TAU * 1240.0 * t) * math.exp(-18.0 * t)
        buffer[index] = drop * 0.68 + grit * 0.36 + metallic * 0.12
    _normalize_mono(buffer, target_peak=0.94)
    _write_mono_wav(AUDIO_ROOT / "ui" / "crash.wav", buffer)


def generate_fuel_empty() -> None:
    duration = 0.84
    buffer = _make_mono_buffer(duration)
    warning_events = [
        (0.02, 0.16, 420.0),
        (0.26, 0.16, 360.0),
        (0.52, 0.22, 220.0),
    ]
    for start_time, note_duration, frequency in warning_events:
        _add_mono_tone(buffer, start_time, note_duration, frequency, 0.4, waveform="square", attack=0.001, release=0.08)
        _add_mono_tone(buffer, start_time, note_duration * 0.9, frequency * 0.5, 0.12, waveform="sine", attack=0.001, release=0.06)
    _normalize_mono(buffer, target_peak=0.86)
    _write_mono_wav(AUDIO_ROOT / "ui" / "fuel_empty.wav", buffer)


def main() -> None:
    generate_music()
    generate_engine_loop()
    generate_jump()
    generate_near_miss()
    generate_hijack()
    generate_stealth_pickup()
    generate_start_run()
    generate_upgrade()
    generate_promote()
    generate_crash()
    generate_fuel_empty()

    generated = sorted(str(path.relative_to(ROOT)) for path in AUDIO_ROOT.rglob("*.wav"))
    print("Generated audio assets:")
    for path in generated:
        print(f"- {path}")


if __name__ == "__main__":
    main()
