extends Node
## Gerenciador procedural de efeitos sonoros (PCM 16-bit mono 22050Hz em memória).
## Compatível com Desktop, Web HTML5 single-threaded e modo --headless sem assets externos.

signal mute_changed(is_muted: bool)
signal music_mute_changed(is_muted: bool)

const SAMPLE_RATE: int = 22050
const POOL_SIZE: int = 6

var muted: bool = false
var music_muted: bool = false

var _streams: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _next_player_idx: int = 0
var _bgm_player: AudioStreamPlayer = null
var _bgm_stream: AudioStreamWAV = null


func _ready() -> void:
	_init_player_pool()
	_synthesize_all_sfx()
	_init_bgm()


func _exit_tree() -> void:
	if is_instance_valid(_bgm_player):
		_bgm_player.stop()
		_bgm_player.stream = null
	_bgm_stream = null
	for player in _players:
		if is_instance_valid(player):
			player.stop()
			player.stream = null
	_players.clear()
	_streams.clear()


func _init_player_pool() -> void:
	for i in range(POOL_SIZE):
		var player := AudioStreamPlayer.new()
		player.name = "SFXPlayer_%d" % i
		add_child(player)
		_players.append(player)


func _init_bgm() -> void:
	_bgm_stream = _make_cozy_bgm_loop()
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.name = "BGMPlayer"
	_bgm_player.stream = _bgm_stream
	_bgm_player.volume_db = -17.0
	add_child(_bgm_player)
	_sync_bgm_playback()


func _sync_bgm_playback() -> void:
	if _bgm_player == null or not is_instance_valid(_bgm_player) or _bgm_stream == null:
		return
	if DisplayServer.get_name() == "headless":
		return
	var should_play: bool = (not muted) and (not music_muted) and is_inside_tree()
	if should_play:
		if not _bgm_player.playing:
			_bgm_player.play()
	else:
		if _bgm_player.playing:
			_bgm_player.stop()


func _synthesize_all_sfx() -> void:
	_streams["hoe"] = _make_hoe_sfx()
	_streams["water"] = _make_water_sfx()
	_streams["plant"] = _make_plant_sfx()
	_streams["harvest"] = _make_harvest_sfx()
	_streams["coin"] = _make_coin_sfx()
	_streams["error"] = _make_error_sfx()
	_streams["click"] = _make_click_sfx()
	_streams["sleep"] = _make_sleep_sfx()
	_streams["chicken"] = _make_chicken_sfx()
	_streams["cow"] = _make_cow_sfx()
	_streams["sheep"] = _make_sheep_sfx()
	_streams["pig"] = _make_pig_sfx()
	_streams["upgrade"] = _make_upgrade_sfx()
	_streams["splash"] = _make_water_sfx()
	_streams["fish_catch"] = _make_fish_catch_sfx()
	_streams["machine"] = _make_machine_sfx()
	_streams["order_done"] = _make_order_done_sfx()
	_streams["season"] = _make_season_sfx()
	_streams["door"] = _make_door_sfx()
	_streams["cozy"] = _make_cozy_sfx()


func toggle_mute() -> bool:
	muted = not muted
	if muted:
		for player in _players:
			if is_instance_valid(player):
				player.stop()
	_sync_bgm_playback()
	mute_changed.emit(muted)
	if not muted:
		play_click()
	return muted


func set_muted(val: bool) -> void:
	if muted == val:
		return
	muted = val
	if muted:
		for player in _players:
			if is_instance_valid(player):
				player.stop()
	_sync_bgm_playback()
	mute_changed.emit(muted)


func toggle_music_mute() -> bool:
	music_muted = not music_muted
	_sync_bgm_playback()
	music_mute_changed.emit(music_muted)
	if not muted:
		play_click()
	return music_muted


func set_music_muted(val: bool) -> void:
	if music_muted == val:
		return
	music_muted = val
	_sync_bgm_playback()
	music_mute_changed.emit(music_muted)


func is_muted() -> bool:
	return muted


func is_music_muted() -> bool:
	return music_muted


func play_hoe() -> void:
	_play_sfx("hoe", -5.0)


func play_water() -> void:
	_play_sfx("water", -6.0)


func play_plant() -> void:
	_play_sfx("plant", -6.0)


func play_harvest() -> void:
	_play_sfx("harvest", -5.0)


func play_coin() -> void:
	_play_sfx("coin", -5.0)


func play_upgrade() -> void:
	_play_sfx("upgrade", -5.0)


func play_error() -> void:
	_play_sfx("error", -7.0)


func play_click() -> void:
	_play_sfx("click", -8.0)


func play_sleep() -> void:
	_play_sfx("sleep", -5.0)


func play_splash() -> void:
	_play_sfx("splash", -6.0)


func play_fish_catch() -> void:
	_play_sfx("fish_catch", -4.0)


func play_machine() -> void:
	_play_sfx("machine", -5.0)


func play_order_done() -> void:
	_play_sfx("order_done", -4.0)


func play_season_change() -> void:
	_play_sfx("season", -4.0)


func play_door() -> void:
	_play_sfx("door", -5.0)


func play_cozy() -> void:
	_play_sfx("cozy", -5.0)


func play_animal(animal_type: String) -> void:
	match animal_type:
		"cow":
			_play_sfx("cow", -5.0)
		"sheep":
			_play_sfx("sheep", -5.5)
		"pig":
			_play_sfx("pig", -5.0)
		_:
			_play_sfx("chicken", -5.0)


func _play_sfx(key: String, volume_db: float = -6.0) -> void:
	if muted or not is_inside_tree():
		return
	if not _streams.has(key) or _players.is_empty():
		return
	var stream: AudioStreamWAV = _streams[key]
	if stream == null:
		return

	var chosen: AudioStreamPlayer = null
	for player in _players:
		if is_instance_valid(player) and player.is_inside_tree() and not player.playing:
			chosen = player
			break
	if chosen == null:
		var candidate := _players[_next_player_idx % _players.size()]
		_next_player_idx = (_next_player_idx + 1) % _players.size()
		if is_instance_valid(candidate) and candidate.is_inside_tree():
			chosen = candidate
	if chosen == null:
		return

	chosen.stream = stream
	chosen.volume_db = volume_db
	chosen.play()


func _build_wav(samples: PackedFloat32Array) -> AudioStreamWAV:
	var count: int = samples.size()
	var buf := PackedByteArray()
	buf.resize(count * 2)
	for i in range(count):
		var clamped: float = clampf(samples[i], -1.0, 1.0)
		var pcm16: int = int(round(clamped * 32767.0))
		buf.encode_s16(i * 2, pcm16)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = buf
	return wav


func _triangle(phase: float) -> float:
	var frac: float = phase - floor(phase)
	return 4.0 * absf(frac - 0.5) - 1.0


func _make_hoe_sfx() -> AudioStreamWAV:
	var duration: float = 0.11
	var count: int = int(duration * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var rng := RandomNumberGenerator.new()
	rng.seed = 101
	var phase: float = 0.0
	var prev_noise: float = 0.0
	for i in range(count):
		var t: float = float(i) / float(SAMPLE_RATE)
		var u: float = float(i) / float(count)
		var freq: float = lerpf(190.0, 62.0, u)
		phase += freq / float(SAMPLE_RATE)
		var raw_noise: float = rng.randf_range(-1.0, 1.0)
		prev_noise = lerpf(prev_noise, raw_noise, 0.25)
		var env: float = minf(1.0, t / 0.008) * exp(-u * 5.2)
		samples[i] = (0.65 * _triangle(phase) + 0.35 * prev_noise) * env * 0.75
	return _build_wav(samples)


func _make_water_sfx() -> AudioStreamWAV:
	var duration: float = 0.19
	var count: int = int(duration * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var rng := RandomNumberGenerator.new()
	rng.seed = 202
	var bubble_phase: float = 0.0
	var lp_noise: float = 0.0
	for i in range(count):
		var t: float = float(i) / float(SAMPLE_RATE)
		var u: float = float(i) / float(count)
		var bubble_freq: float = lerpf(420.0, 820.0, u) + 90.0 * sin(t * 55.0)
		bubble_phase += bubble_freq / float(SAMPLE_RATE)
		var raw_noise: float = rng.randf_range(-1.0, 1.0)
		lp_noise = lerpf(lp_noise, raw_noise, 0.35)
		var env: float = sin(PI * minf(1.0, u)) * exp(-u * 1.4)
		samples[i] = (0.45 * lp_noise + 0.35 * sin(TAU * bubble_phase)) * env * 0.65
	return _build_wav(samples)


func _make_plant_sfx() -> AudioStreamWAV:
	var duration: float = 0.095
	var count: int = int(duration * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var phase: float = 0.0
	for i in range(count):
		var t: float = float(i) / float(SAMPLE_RATE)
		var u: float = float(i) / float(count)
		var freq: float = lerpf(310.0, 560.0, pow(u, 0.7))
		phase += freq / float(SAMPLE_RATE)
		var env: float = minf(1.0, t / 0.006) * exp(-u * 4.5)
		samples[i] = (0.75 * sin(TAU * phase) + 0.25 * _triangle(phase)) * env * 0.65
	return _build_wav(samples)


func _make_harvest_sfx() -> AudioStreamWAV:
	var notes: Array[float] = [523.25, 659.25, 783.99]
	var note_dur: float = 0.065
	var note_samples: int = int(note_dur * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(note_samples * notes.size())
	var idx: int = 0
	for n in notes:
		for j in range(note_samples):
			var u: float = float(j) / float(note_samples)
			var t: float = float(j) / float(SAMPLE_RATE)
			var env: float = minf(1.0, t / 0.006) * exp(-u * 3.0)
			var val: float = 0.7 * sin(TAU * n * t) + 0.3 * _triangle(n * t)
			samples[idx] = val * env * 0.6
			idx += 1
	return _build_wav(samples)


func _make_coin_sfx() -> AudioStreamWAV:
	var dur1: int = int(0.06 * SAMPLE_RATE)
	var dur2: int = int(0.16 * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(dur1 + dur2)
	for i in range(dur1):
		var t: float = float(i) / float(SAMPLE_RATE)
		var u: float = float(i) / float(dur1)
		var env: float = minf(1.0, t / 0.004) * exp(-u * 2.5)
		samples[i] = (0.8 * sin(TAU * 987.77 * t) + 0.2 * sin(TAU * 1975.53 * t)) * env * 0.6
	for j in range(dur2):
		var t: float = float(j) / float(SAMPLE_RATE)
		var u: float = float(j) / float(dur2)
		var env: float = minf(1.0, t / 0.004) * exp(-u * 4.5)
		samples[dur1 + j] = (0.8 * sin(TAU * 1318.51 * t) + 0.2 * sin(TAU * 2637.02 * t)) * env * 0.6
	return _build_wav(samples)


func _make_error_sfx() -> AudioStreamWAV:
	var duration: float = 0.17
	var count: int = int(duration * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var phase: float = 0.0
	for i in range(count):
		var t: float = float(i) / float(SAMPLE_RATE)
		var u: float = float(i) / float(count)
		var freq: float = 215.0 if u < 0.48 else 160.0
		phase += freq / float(SAMPLE_RATE)
		var env: float = minf(1.0, t / 0.008) * (1.0 - u)
		samples[i] = (0.6 * _triangle(phase) + 0.4 * sin(TAU * phase)) * env * 0.55
	return _build_wav(samples)


func _make_click_sfx() -> AudioStreamWAV:
	var duration: float = 0.036
	var count: int = int(duration * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var phase: float = 0.0
	for i in range(count):
		var t: float = float(i) / float(SAMPLE_RATE)
		var u: float = float(i) / float(count)
		var freq: float = lerpf(780.0, 440.0, u)
		phase += freq / float(SAMPLE_RATE)
		var env: float = minf(1.0, t / 0.003) * exp(-u * 5.5)
		samples[i] = sin(TAU * phase) * env * 0.55
	return _build_wav(samples)


func _make_sleep_sfx() -> AudioStreamWAV:
	var notes: Array[float] = [329.63, 392.00, 523.25]
	var note_samples: int = int(0.14 * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(note_samples * notes.size())
	var idx: int = 0
	for n in notes:
		for j in range(note_samples):
			var t: float = float(j) / float(SAMPLE_RATE)
			var u: float = float(j) / float(note_samples)
			var env: float = minf(1.0, t / 0.015) * exp(-u * 2.8)
			samples[idx] = (0.85 * sin(TAU * n * t) + 0.15 * sin(TAU * n * 2.0 * t)) * env * 0.55
			idx += 1
	return _build_wav(samples)


func _make_chicken_sfx() -> AudioStreamWAV:
	var duration: float = 0.22
	var count: int = int(duration * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var phase: float = 0.0
	for i in range(count):
		var u: float = float(i) / float(count)
		var active: bool = (u < 0.36) or (u > 0.50 and u < 0.92)
		var local_u: float = (u / 0.36) if u < 0.36 else ((u - 0.50) / 0.42)
		var freq: float = 640.0 + 260.0 * sin(PI * clampf(local_u, 0.0, 1.0))
		phase += freq / float(SAMPLE_RATE)
		if active:
			var env: float = sin(PI * clampf(local_u, 0.0, 1.0))
			samples[i] = (0.65 * _triangle(phase) + 0.35 * sin(TAU * phase)) * env * 0.58
		else:
			samples[i] = 0.0
	return _build_wav(samples)


func _make_cow_sfx() -> AudioStreamWAV:
	var duration: float = 0.38
	var count: int = int(duration * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var phase: float = 0.0
	var smooth: float = 0.0
	for i in range(count):
		var t: float = float(i) / float(SAMPLE_RATE)
		var u: float = float(i) / float(count)
		var freq: float = lerpf(150.0, 122.0, u) + 18.0 * sin(PI * u)
		phase += freq / float(SAMPLE_RATE)
		var raw: float = 0.55 * _triangle(phase) + 0.45 * sin(TAU * phase)
		smooth = lerpf(smooth, raw, 0.32)
		var env: float = minf(1.0, t / 0.045) * minf(1.0, (duration - t) / 0.08)
		samples[i] = smooth * env * 0.65
	return _build_wav(samples)


func _make_sheep_sfx() -> AudioStreamWAV:
	var duration: float = 0.30
	var count: int = int(duration * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var phase: float = 0.0
	for i in range(count):
		var t: float = float(i) / float(SAMPLE_RATE)
		var u: float = float(i) / float(count)
		var vibrato: float = 1.0 + 0.14 * sin(t * 52.0)
		var freq: float = lerpf(325.0, 265.0, u) * vibrato
		phase += freq / float(SAMPLE_RATE)
		var amp_mod: float = 0.82 + 0.18 * sin(t * 52.0)
		var env: float = minf(1.0, t / 0.025) * minf(1.0, (duration - t) / 0.06)
		samples[i] = (0.55 * _triangle(phase) + 0.45 * sin(TAU * phase)) * amp_mod * env * 0.55
	return _build_wav(samples)


func _make_pig_sfx() -> AudioStreamWAV:
	var duration: float = 0.24
	var count: int = int(duration * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var phase: float = 0.0
	for i in range(count):
		var u: float = float(i) / float(count)
		var active: bool = (u < 0.38) or (u > 0.52 and u < 0.94)
		var local_u: float = (u / 0.38) if u < 0.38 else ((u - 0.52) / 0.42)
		var freq: float = lerpf(160.0, 235.0, clampf(local_u, 0.0, 1.0))
		phase += freq / float(SAMPLE_RATE)
		if active:
			var env: float = sin(PI * clampf(local_u, 0.0, 1.0))
			var rough: float = 0.65 * _triangle(phase) + 0.35 * sin(TAU * phase * 2.0)
			samples[i] = rough * env * 0.55
		else:
			samples[i] = 0.0
	return _build_wav(samples)


func _make_upgrade_sfx() -> AudioStreamWAV:
	var notes: Array[float] = [523.25, 659.25, 783.99, 1046.50]
	var note_samples: int = int(0.075 * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(note_samples * notes.size())
	var idx: int = 0
	for n in notes:
		for j in range(note_samples):
			var t: float = float(j) / float(SAMPLE_RATE)
			var u: float = float(j) / float(note_samples)
			var env: float = minf(1.0, t / 0.006) * exp(-u * 2.6)
			samples[idx] = (0.75 * sin(TAU * n * t) + 0.25 * _triangle(n * t)) * env * 0.62
			idx += 1
	return _build_wav(samples)


func _add_bgm_note(
	samples: PackedFloat32Array,
	total_samples: int,
	start_sec: float,
	dur_sec: float,
	freq: float,
	amp: float,
	decay: float
) -> void:
	var start_idx: int = int(round(start_sec * float(SAMPLE_RATE)))
	var note_count: int = int(round(dur_sec * float(SAMPLE_RATE)))
	for j in range(note_count):
		var t: float = float(j) / float(SAMPLE_RATE)
		var attack: float = minf(1.0, t / 0.018)
		var release: float = minf(1.0, (dur_sec - t) / 0.035)
		var env: float = attack * release * exp(-t * decay)
		var val: float = (0.82 * sin(TAU * freq * t) + 0.18 * sin(TAU * freq * 2.0 * t)) * env * amp
		var target_idx: int = (start_idx + j) % total_samples
		samples[target_idx] = clampf(samples[target_idx] + val, -0.95, 0.95)


func _make_cozy_bgm_loop() -> AudioStreamWAV:
	# 16 tempos a 90 BPM = 10.6667s em loop contínuo (Fmaj7 -> G6 -> Em7 -> Am7)
	var beat: float = 60.0 / 90.0
	var loop_dur: float = 16.0 * beat
	var total_samples: int = int(round(loop_dur * float(SAMPLE_RATE)))
	var samples := PackedFloat32Array()
	samples.resize(total_samples)

	var chords: Array[Dictionary] = [
		{"bass": 174.61, "arp": [349.23, 440.00, 523.25, 659.25]}, # Fmaj7
		{"bass": 196.00, "arp": [392.00, 493.88, 587.33, 659.25]}, # G6
		{"bass": 164.81, "arp": [329.63, 392.00, 493.88, 587.33]}, # Em7
		{"bass": 220.00, "arp": [440.00, 523.25, 659.25, 783.99]}, # Am7
	]
	var melody_bars: Array[Array] = [
		[[0.0, 659.25, 0.9], [1.5, 587.33, 0.7], [2.5, 523.25, 0.9]],
		[[0.0, 587.33, 0.9], [1.5, 659.25, 0.7], [2.5, 493.88, 0.9]],
		[[0.0, 493.88, 0.9], [1.5, 587.33, 0.7], [2.5, 440.00, 0.9]],
		[[0.0, 523.25, 1.0], [1.5, 659.25, 0.7], [2.5, 783.99, 0.9]],
	]

	for bar_idx in range(4):
		var bar_start: float = float(bar_idx) * 4.0 * beat
		var chord: Dictionary = chords[bar_idx]
		var bass_freq: float = float(chord["bass"])
		var arp: Array = chord["arp"]
		_add_bgm_note(samples, total_samples, bar_start, 3.85 * beat, bass_freq, 0.16, 0.55)
		for step in range(4):
			var arp_freq: float = float(arp[step % arp.size()])
			_add_bgm_note(samples, total_samples, bar_start + float(step) * beat, 1.35 * beat, arp_freq, 0.10, 1.6)
		for mel in melody_bars[bar_idx]:
			var m_offset: float = float(mel[0]) * beat
			var m_freq: float = float(mel[1])
			var m_dur: float = float(mel[2]) * beat
			_add_bgm_note(samples, total_samples, bar_start + m_offset, m_dur, m_freq, 0.13, 1.3)

	var wav := _build_wav(samples)
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = total_samples
	return wav


func _make_fish_catch_sfx() -> AudioStreamWAV:
	var notes: Array[float] = [587.33, 783.99, 1046.50]
	var note_samples: int = int(0.075 * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(note_samples * notes.size())
	var idx: int = 0
	for n in notes:
		for j in range(note_samples):
			var t: float = float(j) / float(SAMPLE_RATE)
			var u: float = float(j) / float(note_samples)
			var env: float = minf(1.0, t / 0.005) * exp(-u * 2.5)
			samples[idx] = (0.75 * sin(TAU * n * t) + 0.25 * _triangle(n * t)) * env * 0.62
			idx += 1
	return _build_wav(samples)


func _make_machine_sfx() -> AudioStreamWAV:
	var duration: float = 0.14
	var count: int = int(duration * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var phase: float = 0.0
	for i in range(count):
		var t: float = float(i) / float(SAMPLE_RATE)
		var u: float = float(i) / float(count)
		var freq: float = 440.0 if u < 0.4 else 660.0
		phase += freq / float(SAMPLE_RATE)
		var env: float = minf(1.0, t / 0.005) * exp(-u * 3.8)
		samples[i] = (0.7 * _triangle(phase) + 0.3 * sin(TAU * phase)) * env * 0.58
	return _build_wav(samples)


func _make_order_done_sfx() -> AudioStreamWAV:
	var notes: Array[float] = [523.25, 659.25, 783.99, 1046.50]
	var note_samples: int = int(0.08 * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(note_samples * notes.size())
	var idx: int = 0
	for n in notes:
		for j in range(note_samples):
			var t: float = float(j) / float(SAMPLE_RATE)
			var u: float = float(j) / float(note_samples)
			var env: float = minf(1.0, t / 0.006) * exp(-u * 2.4)
			samples[idx] = (0.7 * sin(TAU * n * t) + 0.3 * sin(TAU * n * 2.0 * t)) * env * 0.6
			idx += 1
	return _build_wav(samples)


func _make_season_sfx() -> AudioStreamWAV:
	# Carrilhão suave de troca de estação (G5 -> C6 -> E6 -> G6 com brilho de sino)
	var notes: Array[float] = [783.99, 1046.50, 1318.51, 1567.98]
	var note_step: int = int(0.11 * SAMPLE_RATE)
	var tail: int = int(0.45 * SAMPLE_RATE)
	var total: int = note_step * notes.size() + tail
	var samples := PackedFloat32Array()
	samples.resize(total)
	for n_idx in range(notes.size()):
		var n: float = notes[n_idx]
		var start: int = n_idx * note_step
		var ring: int = total - start
		for j in range(ring):
			var t: float = float(j) / float(SAMPLE_RATE)
			var env: float = minf(1.0, t / 0.004) * exp(-t * 5.5)
			var val: float = (0.65 * sin(TAU * n * t) + 0.25 * sin(TAU * n * 2.01 * t) + 0.10 * sin(TAU * n * 3.0 * t)) * env * 0.32
			samples[start + j] = clampf(samples[start + j] + val, -0.95, 0.95)
	return _build_wav(samples)


func _make_door_sfx() -> AudioStreamWAV:
	var duration: float = 0.16
	var count: int = int(duration * SAMPLE_RATE)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var rng := RandomNumberGenerator.new()
	rng.seed = 424242
	var phase: float = 0.0
	for i in range(count):
		var t: float = float(i) / float(SAMPLE_RATE)
		var u: float = float(i) / float(count)
		var freq: float = lerpf(160.0, 230.0, u) if u < 0.55 else 310.0
		phase += freq / float(SAMPLE_RATE)
		var click_latch: float = exp(-absf(u - 0.58) * 38.0) * 0.45
		var env: float = exp(-u * 5.2) + click_latch
		var tone: float = 0.65 * _triangle(phase) + 0.35 * rng.randf_range(-1.0, 1.0) * exp(-u * 9.0)
		samples[i] = tone * env * 0.55
	return _build_wav(samples)


func _make_cozy_sfx() -> AudioStreamWAV:
	var notes: Array[float] = [440.0, 554.37, 659.25]
	var note_samples: int = int(0.085 * SAMPLE_RATE)
	var total: int = note_samples * notes.size()
	var samples := PackedFloat32Array()
	samples.resize(total)
	var idx: int = 0
	for n_idx in range(notes.size()):
		var freq: float = notes[n_idx]
		for j in range(note_samples):
			var t: float = float(j) / float(SAMPLE_RATE)
			var u: float = float(j) / float(note_samples)
			var env: float = minf(1.0, t / 0.008) * exp(-u * 2.4)
			var wave: float = 0.72 * sin(TAU * freq * t) + 0.28 * _triangle(freq * t)
			samples[idx] = wave * env * 0.58
			idx += 1
	return _build_wav(samples)
