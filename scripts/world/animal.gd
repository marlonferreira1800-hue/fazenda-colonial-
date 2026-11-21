extends CharacterBody2D

@export_enum("chicken", "cow", "sheep", "pig") var animal_type: String = "chicken"
@export var wander_bounds: Rect2 = Rect2(456.0, 88.0, 112.0, 64.0)
@export var move_speed: float = 18.0

var collected_today: bool = false
var petted_today: bool = false
var hearts: int = 0

@onready var sprite: Sprite2D = $Sprite2D

var _frames: Array[AtlasTexture] = []
var _target_pos: Vector2 = Vector2.ZERO
var _state_timer: float = 0.0
var _is_walking: bool = false
var _anim_timer: float = 0.0
var _anim_index: int = 0
var _bob_time: float = 0.0
var _indicator: Node2D = null
var _indicator_fill: ColorRect = null
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	_bob_time = _rng.randf_range(0.0, TAU)
	_build_indicator()
	_load_frames()
	_update_indicator()
	_state_timer = _rng.randf_range(0.4, 2.0)
	_is_walking = false
	_target_pos = global_position


func setup(p_type: String, p_bounds: Rect2) -> void:
	animal_type = p_type
	wander_bounds = p_bounds
	match p_type:
		"chicken":
			move_speed = 22.0
		"pig":
			move_speed = 18.0
		"sheep":
			move_speed = 16.0
		_:
			move_speed = 13.0
	if is_node_ready():
		_load_frames()
		_update_indicator()


func can_collect() -> bool:
	return not collected_today


func can_pet() -> bool:
	return not petted_today


func get_hearts() -> int:
	return hearts


func pet() -> bool:
	if petted_today:
		return false
	petted_today = true
	hearts = mini(hearts + 1, 5)
	_play_happy_hop()
	return true


func reset_daily() -> void:
	collected_today = false
	petted_today = false
	_update_indicator()


func set_collected_today(value: bool) -> void:
	collected_today = value
	_update_indicator()


func collect_product() -> String:
	var info := collect_product_info()
	return str(info.get("id", ""))


func collect_product_info() -> Dictionary:
	if not can_collect():
		return {}
	collected_today = true
	_update_indicator()
	_play_happy_hop()

	var bonus_chance: float = clampf(float(hearts) * 0.14, 0.0, 0.70)
	var prod_id: String = "egg"
	var is_gold: bool = false

	match animal_type:
		"cow":
			prod_id = "milk"
			is_gold = _rng.randf() < bonus_chance
		"sheep":
			prod_id = "wool"
			is_gold = _rng.randf() < bonus_chance
		"pig":
			prod_id = "truffle"
			is_gold = _rng.randf() < bonus_chance
		_:
			if hearts >= 2 and _rng.randf() < bonus_chance:
				prod_id = "blue_egg"
				is_gold = hearts >= 4 and _rng.randf() < 0.35
			else:
				prod_id = "egg"
				is_gold = hearts >= 3 and _rng.randf() < (bonus_chance * 0.6)

	return {"id": prod_id, "gold": is_gold}


func export_state() -> Dictionary:
	return {
		"type": animal_type,
		"collected_today": collected_today,
		"petted_today": petted_today,
		"hearts": hearts,
	}


func restore_state(data: Dictionary) -> void:
	collected_today = bool(data.get("collected_today", false))
	petted_today = bool(data.get("petted_today", false))
	hearts = clampi(int(data.get("hearts", 0)), 0, 5)
	_update_indicator()


func get_display_name() -> String:
	match animal_type:
		"cow":
			return "Vaca"
		"sheep":
			return "Ovelha"
		"pig":
			return "Porco"
		_:
			return "Galinha"


func _build_indicator() -> void:
	_indicator = Node2D.new()
	_indicator.name = "ReadyIndicator"
	_indicator.position = Vector2(0.0, -16.0)
	_indicator.z_index = 4

	var border := ColorRect.new()
	border.size = Vector2(5.0, 5.0)
	border.position = Vector2(-2.5, -2.5)
	border.color = Color(0.24, 0.14, 0.06, 0.95)
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_indicator.add_child(border)

	_indicator_fill = ColorRect.new()
	_indicator_fill.size = Vector2(3.0, 3.0)
	_indicator_fill.position = Vector2(-1.5, -1.5)
	_indicator_fill.color = Color(1.0, 0.92, 0.38, 1.0)
	_indicator_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_indicator.add_child(_indicator_fill)

	add_child(_indicator)


func _update_indicator() -> void:
	if _indicator == null:
		return
	_indicator.visible = not collected_today
	if _indicator_fill != null:
		match animal_type:
			"cow":
				_indicator_fill.color = Color(0.84, 0.96, 1.0, 1.0)
			"sheep":
				_indicator_fill.color = Color(1.0, 1.0, 1.0, 1.0)
			"pig":
				_indicator_fill.color = Color(1.0, 0.68, 0.80, 1.0)
			_:
				_indicator_fill.color = Color(1.0, 0.92, 0.38, 1.0)


func _play_happy_hop() -> void:
	if sprite == null:
		return
	sprite.position = Vector2.ZERO
	sprite.scale = Vector2(1.15, 0.85)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(sprite, "position:y", -5.0, 0.10).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(sprite, "scale", Vector2(0.92, 1.12), 0.10)
	tw.chain().set_parallel(true)
	tw.tween_property(sprite, "position:y", 0.0, 0.14).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tw.tween_property(sprite, "scale", Vector2.ONE, 0.14)


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


func _load_frames() -> void:
	var tex: Texture2D = _load_texture_safe("res://assets/sprites/props_buildings.png")
	_frames.clear()
	if tex == null:
		return

	var regions: Array[Rect2]
	match animal_type:
		"cow":
			regions = [Rect2(32, 32, 16, 16), Rect2(48, 32, 16, 16)]
		"sheep":
			regions = [Rect2(64, 32, 16, 16), Rect2(80, 32, 16, 16)]
		"pig":
			regions = [Rect2(0, 48, 16, 16), Rect2(16, 48, 16, 16)]
		_:
			regions = [Rect2(0, 32, 16, 16), Rect2(16, 32, 16, 16)]

	for r in regions:
		var atlas := AtlasTexture.new()
		atlas.atlas = tex
		atlas.region = r
		_frames.append(atlas)

	if not _frames.is_empty():
		sprite.texture = _frames[0]


func _physics_process(delta: float) -> void:
	_state_timer -= delta
	_bob_time += delta

	if _indicator != null and _indicator.visible:
		_indicator.position.y = -16.0 + sin(_bob_time * 4.0) * 1.2

	if _is_walking:
		var to_target: Vector2 = _target_pos - global_position
		if to_target.length() <= 3.0 or _state_timer <= 0.0:
			_enter_idle()
		else:
			var dir: Vector2 = to_target.normalized()
			velocity = dir * move_speed
			move_and_slide()
			_clamp_to_bounds()
			if absf(velocity.x) > 1.0:
				sprite.flip_h = velocity.x > 0.0
	else:
		velocity = Vector2.ZERO
		if _state_timer <= 0.0:
			_enter_walk()

	_update_anim(delta)


func _enter_idle() -> void:
	_is_walking = false
	_state_timer = _rng.randf_range(1.2, 3.6)
	_anim_index = 0
	if not _frames.is_empty():
		sprite.texture = _frames[0]


func _enter_walk() -> void:
	_is_walking = true
	_state_timer = _rng.randf_range(1.0, 2.8)
	_target_pos = Vector2(
		_rng.randf_range(wander_bounds.position.x, wander_bounds.end.x),
		_rng.randf_range(wander_bounds.position.y, wander_bounds.end.y)
	)


func _clamp_to_bounds() -> void:
	global_position = Vector2(
		clampf(global_position.x, wander_bounds.position.x, wander_bounds.end.x),
		clampf(global_position.y, wander_bounds.position.y, wander_bounds.end.y)
	)


func _update_anim(delta: float) -> void:
	if _frames.size() < 2:
		return
	var interval: float = (0.20 if animal_type == "chicken" else 0.30) if _is_walking else 0.95
	_anim_timer += delta
	if _anim_timer >= interval:
		_anim_timer = 0.0
		_anim_index = 1 - _anim_index
		sprite.texture = _frames[_anim_index]
