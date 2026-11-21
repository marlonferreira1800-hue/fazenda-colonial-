extends CharacterBody2D
## Morador autônomo da Vila Colonial com rotina diária, navegação por estradas,
## falas contextuais, amizade e vida própria.

signal indoors_changed(npc_id: String, inside: bool)

const ANIM_FPS: float = 6.5

var npc_id: String = ""
var npc_name: String = ""
var role: String = ""
var home_node_id: String = ""
var home_door_pos: Vector2 = Vector2.ZERO
var sprite_path: String = ""
var move_speed: float = 30.0
var schedule: Array[Dictionary] = []
var dialogues: Dictionary = {}

var hearts: int = 0
var talked_today: bool = false
var gifted_today: bool = false
var perk_used_today: bool = false
var is_indoors: bool = false
var current_activity: String = ""

var _sprite: Sprite2D = null
var _bubble_panel: PanelContainer = null
var _bubble_label: Label = null
var _heart_badge: Label = null

var _road_graph: Dictionary = {}
var _current_node_id: String = ""
var _target_node_id: String = ""
var _target_indoors: bool = false
var _active_schedule_idx: int = -1
var _active_chatter: Array[String] = []
var _waypoints: Array[Vector2] = []
var _activity_anchor: Vector2 = Vector2.ZERO
var _wander_target: Vector2 = Vector2.ZERO
var _wander_wait_timer: float = 0.0
var _is_wandering: bool = false

var _facing_dir: Vector2i = Vector2i(0, 1)
var _anim_time: float = 0.0
var _talk_pause_timer: float = 0.0
var _bubble_timer: float = 0.0
var _chatter_timer: float = 6.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	collision_layer = 0
	collision_mask = 0
	y_sort_enabled = false
	z_index = 4

	_sprite = Sprite2D.new()
	_sprite.name = "Sprite2D"
	_sprite.hframes = 4
	_sprite.vframes = 4
	_sprite.offset = Vector2(0.0, -6.0)
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_sprite)

	_heart_badge = Label.new()
	_heart_badge.name = "HeartBadge"
	_heart_badge.visible = false
	_heart_badge.z_index = 22
	_heart_badge.position = Vector2(-14.0, -24.0)
	_heart_badge.size = Vector2(28.0, 10.0)
	_heart_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_heart_badge.add_theme_font_size_override("font_size", 6)
	_heart_badge.add_theme_color_override("font_color", Color(1.0, 0.42, 0.52))
	_heart_badge.add_theme_color_override("font_outline_color", Color(0.14, 0.08, 0.05, 0.95))
	_heart_badge.add_theme_constant_override("outline_size", 2)
	add_child(_heart_badge)

	_bubble_panel = PanelContainer.new()
	_bubble_panel.name = "SpeechBubble"
	_bubble_panel.visible = false
	_bubble_panel.z_index = 26
	_bubble_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.98, 0.95, 0.87, 0.95)
	style.border_color = Color(0.42, 0.28, 0.16, 0.95)
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.content_margin_left = 4.0
	style.content_margin_right = 4.0
	style.content_margin_top = 1.0
	style.content_margin_bottom = 1.0
	_bubble_panel.add_theme_stylebox_override("panel", style)
	add_child(_bubble_panel)

	_bubble_label = Label.new()
	_bubble_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_bubble_label.add_theme_font_size_override("font_size", 6)
	_bubble_label.add_theme_color_override("font_color", Color(0.20, 0.13, 0.08))
	_bubble_panel.add_child(_bubble_label)

	if not sprite_path.is_empty():
		_load_sprite()
	_chatter_timer = _rng.randf_range(5.0, 14.0)
	_update_animation(0.0, Vector2.ZERO)


func setup(spec: Dictionary, graph: Dictionary) -> void:
	npc_id = str(spec.get("id", ""))
	npc_name = str(spec.get("name", "Morador"))
	role = str(spec.get("role", "Aldeão"))
	home_node_id = str(spec.get("home_node", ""))
	var door_val: Variant = spec.get("home_door_pos", Vector2.ZERO)
	home_door_pos = door_val if door_val is Vector2 else Vector2.ZERO
	sprite_path = str(spec.get("sprite", ""))
	move_speed = float(spec.get("speed", 30.0))

	schedule.clear()
	var sched_val: Variant = spec.get("schedule", [])
	if sched_val is Array:
		for entry in (sched_val as Array):
			if entry is Dictionary:
				schedule.append(entry as Dictionary)

	var dlg_val: Variant = spec.get("dialogues", {})
	dialogues = dlg_val if dlg_val is Dictionary else {}
	_road_graph = graph

	_current_node_id = home_node_id
	_target_node_id = home_node_id
	_activity_anchor = home_door_pos
	global_position = home_door_pos

	if is_node_ready() and not sprite_path.is_empty():
		_load_sprite()


func _load_sprite() -> void:
	if _sprite == null or sprite_path.is_empty():
		return
	var tex: Texture2D = _load_texture_safe(sprite_path)
	if tex != null:
		_sprite.texture = tex


func _load_texture_safe(res_path: String) -> Texture2D:
	if FileAccess.file_exists(res_path + ".import") or not OS.has_feature("editor"):
		if ResourceLoader.exists(res_path):
			var res: Resource = load(res_path)
			if res is Texture2D:
				return res
	var abs_path: String = ProjectSettings.globalize_path(res_path)
	if FileAccess.file_exists(abs_path):
		var img: Image = Image.load_from_file(abs_path)
		if img != null and not img.is_empty():
			return ImageTexture.create_from_image(img)
	return null


func sync_to_time(time_minutes: float, is_rainy: bool, instant: bool = false, festival: Dictionary = {}) -> void:
	if schedule.is_empty():
		return

	var chosen_idx: int = 0
	for i in range(schedule.size()):
		var start_m: float = float(schedule[i].get("start_min", 0.0))
		if time_minutes >= start_m:
			chosen_idx = i

	var entry: Dictionary = schedule[chosen_idx]
	var want_node: String = str(entry.get("node", home_node_id))
	var want_indoors: bool = bool(entry.get("indoors", false))
	var act_name: String = str(entry.get("activity", "Passeando"))
	var use_chatter: Variant = entry.get("chatter", [])

	# Em dia de Festa Sazonal (10h às 21h), todos os moradores se reúnem na Praça do Coreto!
	if not festival.is_empty() and time_minutes >= 600.0 and time_minutes < 1260.0:
		chosen_idx = 99
		want_node = str(festival.get("spot", "praca_s"))
		want_indoors = false
		act_name = str(festival.get("name", "Festa na Praça"))
		use_chatter = festival.get("chatter", [])
	# Em dias de chuva, moradores que não estão trabalhando abrigam-se em casa à tarde/noite
	elif is_rainy and not want_indoors and bool(entry.get("shelter_in_rain", false)):
		want_node = home_node_id
		want_indoors = true
		act_name = "Abrigado da chuva"

	if not instant and chosen_idx == _active_schedule_idx and want_node == _target_node_id and want_indoors == _target_indoors:
		return

	_active_schedule_idx = chosen_idx
	_target_node_id = want_node
	_target_indoors = want_indoors
	current_activity = act_name
	_active_chatter.clear()
	if use_chatter is Array:
		for line in (use_chatter as Array):
			_active_chatter.append(str(line))

	var dest_pos: Vector2 = _get_node_pos(want_node)
	if want_indoors and home_door_pos != Vector2.ZERO:
		dest_pos = home_door_pos

	if instant:
		_waypoints.clear()
		_current_node_id = want_node
		_activity_anchor = dest_pos
		global_position = dest_pos
		_is_wandering = false
		_wander_wait_timer = _rng.randf_range(1.2, 3.5)
		_set_indoors(want_indoors)
		return

	# Se estava dentro de casa e agora precisa sair, aparece na porta
	if is_indoors and not want_indoors:
		global_position = home_door_pos
		_current_node_id = home_node_id
		_set_indoors(false)

	var path_nodes: Array[String] = _find_path(_current_node_id, want_node)
	_waypoints.clear()
	for idx in range(1, path_nodes.size()):
		_waypoints.append(_get_node_pos(path_nodes[idx]))
	if want_indoors and home_door_pos != Vector2.ZERO:
		_waypoints.append(home_door_pos)
	elif _waypoints.is_empty():
		_waypoints.append(dest_pos)

	_activity_anchor = dest_pos
	_is_wandering = false


func _set_indoors(inside: bool) -> void:
	if is_indoors == inside:
		if _sprite != null:
			_sprite.visible = not inside
		return
	is_indoors = inside
	if _sprite != null:
		_sprite.visible = not inside
	if inside and _bubble_panel != null:
		_bubble_panel.visible = false
	indoors_changed.emit(npc_id, inside)


func _physics_process(delta: float) -> void:
	if _bubble_timer > 0.0:
		_bubble_timer -= delta
		if _bubble_timer <= 0.0 and _bubble_panel != null:
			_bubble_panel.visible = false

	if is_indoors:
		return

	if _talk_pause_timer > 0.0:
		_talk_pause_timer -= delta
		_update_animation(delta, Vector2.ZERO)
		return

	# Caminhando pelos waypoints da estrada até o destino da rotina
	if not _waypoints.is_empty():
		var target: Vector2 = _waypoints[0]
		var diff: Vector2 = target - global_position
		var dist: float = diff.length()
		if dist <= 3.0:
			global_position = target
			_waypoints.remove_at(0)
			if _waypoints.is_empty():
				_current_node_id = _target_node_id
				if _target_indoors:
					_set_indoors(true)
					return
				_wander_wait_timer = _rng.randf_range(1.5, 4.0)
				_is_wandering = false
				if not _active_chatter.is_empty() and _rng.randf() < 0.45:
					show_bubble(_active_chatter[_rng.randi() % _active_chatter.size()], 2.6)
			_update_animation(delta, Vector2.ZERO)
			return

		var dir: Vector2 = diff / dist
		global_position += dir * move_speed * delta
		_update_facing(dir)
		_update_animation(delta, dir)
		return

	# No local de atividade: passeio suave em volta do ponto + falas ambientais ocasionais
	_chatter_timer -= delta
	if _chatter_timer <= 0.0:
		_chatter_timer = _rng.randf_range(10.0, 20.0)
		if not _active_chatter.is_empty() and _bubble_timer <= 0.0:
			show_bubble(_active_chatter[_rng.randi() % _active_chatter.size()], 2.6)

	if _is_wandering:
		var w_diff: Vector2 = _wander_target - global_position
		var w_dist: float = w_diff.length()
		if w_dist <= 2.5:
			_is_wandering = false
			_wander_wait_timer = _rng.randf_range(2.2, 5.2)
			_update_animation(delta, Vector2.ZERO)
		else:
			var w_dir: Vector2 = w_diff / w_dist
			global_position += w_dir * (move_speed * 0.58) * delta
			_update_facing(w_dir)
			_update_animation(delta, w_dir)
	else:
		_wander_wait_timer -= delta
		if _wander_wait_timer <= 0.0:
			var offset := Vector2(_rng.randf_range(-16.0, 16.0), _rng.randf_range(-10.0, 10.0))
			_wander_target = _activity_anchor + offset
			_is_wandering = true
		_update_animation(delta, Vector2.ZERO)


func show_bubble(text: String, duration: float = 2.8) -> void:
	if is_indoors or _bubble_panel == null or _bubble_label == null:
		return
	_bubble_label.text = text
	_bubble_panel.visible = true
	_bubble_panel.reset_size()
	_bubble_panel.position = Vector2(-_bubble_panel.size.x * 0.5, -28.0)
	_bubble_timer = duration


func face_toward(world_pos: Vector2) -> void:
	var diff: Vector2 = world_pos - global_position
	if diff.length_squared() > 0.5:
		_update_facing(diff.normalized())
		_update_animation(0.0, Vector2.ZERO)


func interact(player_pos: Vector2, time_minutes: float, is_rainy: bool, season_id: String) -> Dictionary:
	face_toward(player_pos)
	_talk_pause_timer = 3.2
	_is_wandering = false

	var gained_heart: bool = false
	if not talked_today:
		talked_today = true
		if hearts < 5:
			hearts += 1
			gained_heart = true

	var pool: Array[String] = []
	if is_rainy and dialogues.has("rainy"):
		pool = _to_string_array(dialogues["rainy"])
	elif hearts >= 3 and dialogues.has("friend") and _rng.randf() < 0.45:
		pool = _to_string_array(dialogues["friend"])
	elif time_minutes < 720.0 and dialogues.has("morning"):
		pool = _to_string_array(dialogues["morning"])
	elif time_minutes < 1050.0 and dialogues.has("afternoon"):
		pool = _to_string_array(dialogues["afternoon"])
	elif dialogues.has("evening"):
		pool = _to_string_array(dialogues["evening"])

	if pool.is_empty():
		pool = ["Bom dia, vizinho! Bela fazenda a sua!"]

	var chosen_line: String = pool[_rng.randi() % pool.size()]
	if season_id == "winter" and _rng.randf() < 0.25:
		chosen_line = "Que friozinho colonial! Bom tempo pra um café quente."
	elif season_id == "spring" and _rng.randf() < 0.20:
		chosen_line = "A primavera deixou a vila toda florida!"

	var short_bubble: String = chosen_line if chosen_line.length() <= 30 else (chosen_line.substr(0, 27) + "...")
	show_bubble(short_bubble, 3.2)

	if gained_heart and _heart_badge != null:
		_heart_badge.text = "♥"
		_heart_badge.visible = true
		_heart_badge.position = Vector2(-14.0, -24.0)
		_heart_badge.modulate.a = 1.0
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(_heart_badge, "position:y", -34.0, 0.9)
		tw.tween_property(_heart_badge, "modulate:a", 0.0, 0.9)
		tw.chain().tween_callback(func() -> void:
			if is_instance_valid(_heart_badge):
				_heart_badge.visible = false
		)

	return {
		"npc_id": npc_id,
		"npc_name": npc_name,
		"role": role,
		"line": chosen_line,
		"gained_heart": gained_heart,
		"hearts": hearts,
	}


func receive_gift(item_name: String, player_pos: Vector2, is_favorite: bool) -> Dictionary:
	face_toward(player_pos)
	_talk_pause_timer = 3.2
	_is_wandering = false
	if gifted_today:
		show_bubble("Já recebi presente hoje!", 2.4)
		return {"accepted": false, "gained": 0, "hearts": hearts, "npc_name": npc_name, "line": "Já recebi seu presente hoje, muito obrigado!"}

	gifted_today = true
	var delta_hearts: int = 2 if is_favorite else 1
	var old_hearts: int = hearts
	hearts = mini(5, hearts + delta_hearts)
	var actual_gain: int = hearts - old_hearts

	var line: String = ""
	if is_favorite:
		line = "Nossa, %s é o meu favorito! Muito obrigado, vizinho!" % item_name
		show_bubble("Amei o %s! ♥♥" % item_name, 3.2)
	else:
		line = "Que gentileza! Muito obrigado por este %s!" % item_name
		show_bubble("Obrigado pelo %s! ♥" % item_name, 3.0)

	if _heart_badge != null:
		_heart_badge.text = "♥♥" if is_favorite else "♥"
		_heart_badge.visible = true
		_heart_badge.position = Vector2(-14.0, -24.0)
		_heart_badge.modulate.a = 1.0
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(_heart_badge, "position:y", -36.0, 0.95)
		tw.tween_property(_heart_badge, "modulate:a", 0.0, 0.95)
		tw.chain().tween_callback(func() -> void:
			if is_instance_valid(_heart_badge):
				_heart_badge.visible = false
		)

	return {
		"accepted": true,
		"is_favorite": is_favorite,
		"gained": actual_gain,
		"hearts": hearts,
		"npc_name": npc_name,
		"line": line,
	}


func get_hearts_text() -> String:
	var out: String = ""
	for i in range(hearts):
		out += "♥"
	return out


func reset_daily() -> void:
	talked_today = false
	gifted_today = false
	perk_used_today = false


func export_state() -> Dictionary:
	return {
		"id": npc_id,
		"hearts": hearts,
		"talked_today": talked_today,
		"gifted_today": gifted_today,
		"perk_used_today": perk_used_today,
	}


func restore_state(data: Dictionary) -> void:
	hearts = clampi(int(data.get("hearts", 0)), 0, 5)
	talked_today = bool(data.get("talked_today", false))
	gifted_today = bool(data.get("gifted_today", false))
	perk_used_today = bool(data.get("perk_used_today", false))


func _to_string_array(val: Variant) -> Array[String]:
	var out: Array[String] = []
	if val is Array:
		for item in (val as Array):
			out.append(str(item))
	return out


func _get_node_pos(node_id: String) -> Vector2:
	if _road_graph.has(node_id):
		var entry: Dictionary = _road_graph[node_id]
		var p: Variant = entry.get("pos", Vector2.ZERO)
		if p is Vector2:
			return p
	return home_door_pos


func _find_path(start_id: String, goal_id: String) -> Array[String]:
	if start_id == goal_id or not _road_graph.has(start_id) or not _road_graph.has(goal_id):
		return [goal_id]
	var queue: Array[String] = [start_id]
	var came_from: Dictionary = {start_id: ""}
	while not queue.is_empty():
		var cur: String = queue.pop_front()
		if cur == goal_id:
			break
		var node_data: Dictionary = _road_graph.get(cur, {})
		var neigh_val: Variant = node_data.get("neighbors", [])
		if neigh_val is Array:
			for n_var in (neigh_val as Array):
				var n_id: String = str(n_var)
				if not came_from.has(n_id) and _road_graph.has(n_id):
					came_from[n_id] = cur
					queue.append(n_id)
	if not came_from.has(goal_id):
		return [goal_id]
	var rev: Array[String] = []
	var step: String = goal_id
	while not step.is_empty():
		rev.append(step)
		step = str(came_from.get(step, ""))
	rev.reverse()
	return rev


func _update_facing(dir: Vector2) -> void:
	if absf(dir.x) > absf(dir.y):
		_facing_dir = Vector2i(1 if dir.x > 0.0 else -1, 0)
	else:
		_facing_dir = Vector2i(0, 1 if dir.y > 0.0 else -1)


func _update_animation(delta: float, move_dir: Vector2) -> void:
	if _sprite == null:
		return
	var row: int = 0
	if _facing_dir == Vector2i(0, 1):
		row = 0
	elif _facing_dir == Vector2i(0, -1):
		row = 1
	elif _facing_dir == Vector2i(-1, 0):
		row = 2
	elif _facing_dir == Vector2i(1, 0):
		row = 3

	var col: int = 0
	if move_dir.length_squared() > 0.01:
		_anim_time += delta * ANIM_FPS
		col = int(_anim_time) % 4
	else:
		_anim_time = 0.0
		col = 0
	_sprite.frame_coords = Vector2i(col, row)
