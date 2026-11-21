extends Node2D

signal demo_mode_changed(active: bool)

const CropDataScript := preload("res://scripts/data/crop_data.gd")
const FarmCatalogScript := preload("res://scripts/data/farm_catalog.gd")
const SeasonDataScript := preload("res://scripts/data/season_data.gd")
const VillageDataScript := preload("res://scripts/data/village_data.gd")
const VillagerScript := preload("res://scripts/world/villager.gd")
const StoryDataScript := preload("res://scripts/data/story_data.gd")
const VillageWorldScript := preload("res://scripts/world/village_world.gd")

const TILE_SIZE: int = 16
const MAP_WIDTH: int = 68
const MAP_HEIGHT: int = 38

# Atlas coordinates in res://assets/sprites/terrain_tileset.png (4 cols x 2 rows)
const TILE_GRASS := Vector2i(0, 0)
const TILE_FLOWERS := Vector2i(1, 0)
const TILE_PATH := Vector2i(2, 0)
const TILE_WATER := Vector2i(3, 0)
const TILE_SOIL_DRY := Vector2i(0, 1)
const TILE_SOIL_WET := Vector2i(1, 1)
const TILE_FENCE := Vector2i(2, 1)
const TILE_SHIPPING_BIN := Vector2i(3, 1)

# Key world positions in tile coordinates
const ARABLE_RECT := Rect2i(12, 9, 12, 7)
const SHIPPING_BIN_TILE := Vector2i(10, 5)
const SHOP_SIGN_TILE := Vector2i(12, 5)
const ORDER_BOARD_TILE := Vector2i(13, 5)
const WELL_TILE := Vector2i(15, 5)
const VILLAGE_WELL_TILE := Vector2i(48, 13)
const VENDA_TILE := Vector2i(44, 7)
const FOUNTAIN_TILE := Vector2i(7, 10)
const CAPELA_TILE := Vector2i(4, 5)
const PAIOL_TILE := Vector2i(5, 16)
const CARRO_BOI_TILE := Vector2i(21, 20)
const CASA_FARINHA_TILE := Vector2i(25, 5)
const TROPEIRO_TILE := Vector2i(19, 20)
const TERREIRO_POS := Vector2(128.0, 292.0)
const HOUSE_DOOR_POS := Vector2(128.0, 96.0)
const HOUSE_EXIT_SPAWN_POS := Vector2(128.0, 102.0)
const HOUSE_DOOR_TILES: Array[Vector2i] = [
	Vector2i(7, 4),
	Vector2i(8, 4),
	Vector2i(7, 5),
	Vector2i(8, 5),
]
const HOUSE_ORIGIN := Vector2(2000.0, 0.0)
const VILLAGE_ORIGIN := Vector2(2800.0, 0.0)
const VILLAGE_EXIT_FARM_POS := Vector2(288.0, 520.0)
const SACI_POS := Vector2(158.0, 224.0)
const MULA_POS := Vector2(256.0, 332.0)
const CURUPIRA_POS := Vector2(312.0, 52.0)
const IARA_POS := Vector2(468.0, 266.0)
const ANIMAL_PEN_BOUNDS := Rect2(456.0, 88.0, 112.0, 64.0)

const FARM_GUIDE_TIPS: Array[String] = [
	"Guia Cap.1: Plante sementes na terra arada e regue todos os dias!",
	"Guia Cap.2: Colha cultivos maduros e venda na Caixa de Venda ($).",
	"Guia Cap.3: Galinhas, vacas, ovelhas e porcos produzem todos os dias.",
	"Guia Cap.4: Tome um Chá no fogão (+20 Energia) e durma na Cama!",
	"Guia Cap.5: Explore a Vila de São Sebastião (Leste) e o Vale do Ribeirão (Sul)!",
]

const REACH_TILES: int = 2
const ANIMAL_INTERACT_REACH: float = 28.0
const VILLAGER_INTERACT_REACH: float = 28.0

# Demo AI navigation waypoints & starter plots
const DEMO_CORRIDOR_Y: float = 104.0
const DEMO_GARDEN_BOUNDS_PX := Rect2(192.0, 144.0, 192.0, 112.0)
const DEMO_PEN_BOUNDS_PX := Rect2(448.0, 80.0, 128.0, 80.0)
const DEMO_GARDEN_CORRIDOR_WP := Vector2(280.0, 104.0)
const DEMO_GARDEN_ENTRY_WP := Vector2(280.0, 152.0)
const DEMO_PEN_CORRIDOR_WP := Vector2(424.0, 104.0)
const DEMO_PEN_ENTRY_WP := Vector2(456.0, 104.0)
const DEMO_WELL_WP := Vector2(248.0, 104.0)
const DEMO_BIN_WP := Vector2(168.0, 104.0)
const DEMO_SIGN_WP := Vector2(200.0, 104.0)
const DEMO_DOOR_WP := Vector2(136.0, 104.0)
const DEMO_PLOTS: Array[Vector2i] = [
	Vector2i(14, 10),
	Vector2i(15, 10),
	Vector2i(16, 10),
	Vector2i(17, 10),
	Vector2i(18, 10),
	Vector2i(19, 10),
	Vector2i(14, 12),
	Vector2i(15, 12),
	Vector2i(16, 12),
	Vector2i(17, 12),
	Vector2i(18, 12),
	Vector2i(19, 12),
]

@onready var ground_layer: TileMapLayer = $GroundLayer
@onready var soil_layer: TileMapLayer = $SoilLayer
@onready var obstacle_layer: TileMapLayer = $ObstacleLayer
@onready var day_night_modulate: CanvasModulate = $DayNightModulate
@onready var player: CharacterBody2D = $Player
@onready var tile_cursor: Line2D = $TileCursor
@onready var hud: CanvasLayer = get_node_or_null("HUD")

var demo_active: bool = false

var _game_state: Node = null
var _props_texture: Texture2D = null
var _crops_texture: Texture2D = null
var _turnip_texture: Texture2D = null
var _v13_props_texture: Texture2D = null
var _seasonal_terrain_textures: Dictionary = {}
var _seasonal_props_textures: Dictionary = {}
var _shared_atlas_source: TileSetAtlasSource = null
var _prop_atlases: Array[AtlasTexture] = []
var _season_particles: CPUParticles2D = null
var _firefly_particles: CPUParticles2D = null
var _current_season_id: String = "spring"
var _animal_scene: PackedScene = null
var _house_interior_scene: PackedScene = null
var _house_interior: Node2D = null
var _exterior_props: Array[Node] = []
var _current_location: String = "farm"
var _is_transitioning: bool = false
var _transition_rect: ColorRect = null
var _door_cooldown: float = 0.0
var _tea_used_today: bool = false
var _fountain_drank_today: bool = false
var _capela_blessed_today: bool = false
var _lamp_glows: Array[Sprite2D] = []
var _tropeiro_body: StaticBody2D = null
var _tropeiro_present: bool = false
var _village_world: Node2D = null
var _folklore_nodes: Dictionary = {}
var _guide_tip_index: int = 0
var _entered_house_once: bool = false
var _rng := RandomNumberGenerator.new()

# tile Vector2i -> { "crop_id": String, "days_grown": int, "stage": int, "sprite": Sprite2D }
var _crops: Dictionary = {}
# tile Vector2i -> Sprite2D
var _fertilized_tiles: Dictionary = {}
# tile Vector2i -> Sprite2D
var _sprinklers: Dictionary = {}
# machine_id -> { "body": StaticBody2D, "sprite": Sprite2D, "badge": Sprite2D, "tile": Vector2i }
var _machines: Dictionary = {}
var _animals: Array[CharacterBody2D] = []
var _villagers: Array[CharacterBody2D] = []
var _house_window_glows: Dictionary = {}
var _village_road_graph: Dictionary = {}
var _current_region: String = "fazenda"
var _social_check_timer: float = 0.0

var _order_badge: Sprite2D = null

var _mouse_active: bool = false
var _cursor_fill: ColorRect = null
var _extra_cursor_rects: Array[ColorRect] = []
var _prompt_label: Label = null
var _weather_fx: Node2D = null
var _festival_decor: Node2D = null
var _current_target_tile: Vector2i = Vector2i.ZERO
var _target_in_reach: bool = true

# Fishing minigame state
var _fishing_active: bool = false
var _fishing_phase: float = 0.0
var _fishing_speed: float = 1.9
var _fishing_zone_min: float = 0.36
var _fishing_zone_max: float = 0.64
var _fishing_ui: Node2D = null
var _fishing_zone_rect: ColorRect = null
var _fishing_marker: ColorRect = null
var _fishing_bobber: Sprite2D = null

var _demo_waypoints: Array[Vector2] = []
var _demo_action: String = ""
var _demo_target_tile: Vector2i = Vector2i.ZERO
var _demo_target_slot: int = -1
var _demo_target_animal: CharacterBody2D = null
var _demo_target_machine: String = ""
var _demo_pause_timer: float = 0.0
var _demo_stuck_timer: float = 0.0
var _demo_stuck_strikes: int = 0
var _demo_last_pos: Vector2 = Vector2.ZERO


class WeatherFxNode extends Node2D:
	const WORLD_W: float = 1088.0
	const WORLD_H: float = 608.0
	var is_rainy: bool = false
	var is_winter: bool = false
	var drops: Array[Dictionary] = []
	var sparkles: Array[Vector2] = [
		Vector2(484.0, 246.0),
		Vector2(522.0, 266.0),
		Vector2(496.0, 294.0),
		Vector2(548.0, 278.0),
		Vector2(114.0, 174.0),
		Vector2(126.0, 174.0),
		Vector2(544.0, 396.0),
		Vector2(566.0, 424.0),
		Vector2(536.0, 514.0),
		Vector2(574.0, 536.0),
	]
	var smoke_puffs: Array[Dictionary] = []
	var butterflies: Array[Dictionary] = []
	var _time_acc: float = 0.0
	var _smoke_timer: float = 0.0
	var _rng := RandomNumberGenerator.new()

	func _ready() -> void:
		z_index = 22
		_rng.seed = 13026
		for i in range(115):
			drops.append({
				"pos": Vector2(_rng.randf_range(0.0, WORLD_W), _rng.randf_range(0.0, WORLD_H)),
				"speed": _rng.randf_range(160.0, 230.0),
				"len": _rng.randf_range(5.0, 9.0),
			})
		var b_colors: Array[Color] = [
			Color(1.0, 0.86, 0.24, 0.92),
			Color(0.32, 0.76, 1.0, 0.92),
			Color(1.0, 0.44, 0.28, 0.92),
			Color(0.96, 0.94, 0.48, 0.92),
			Color(1.0, 0.78, 0.34, 0.92),
			Color(0.42, 0.84, 1.0, 0.92),
			Color(0.98, 0.54, 0.62, 0.92),
			Color(0.92, 0.96, 0.44, 0.92),
		]
		for i in range(b_colors.size()):
			butterflies.append({
				"pos": Vector2(_rng.randf_range(60.0, WORLD_W - 60.0), _rng.randf_range(70.0, WORLD_H - 70.0)),
				"vx": _rng.randf_range(10.0, 20.0) * (-1.0 if i % 2 == 0 else 1.0),
				"phase": _rng.randf_range(0.0, TAU),
				"color": b_colors[i],
			})

	func _process(delta: float) -> void:
		_time_acc += delta
		if is_rainy:
			var speed_mult: float = 0.42 if is_winter else 1.0
			for d in drops:
				var p: Vector2 = d["pos"]
				var spd: float = float(d["speed"]) * speed_mult
				var vx: float = (-0.18 * spd + sin(_time_acc * 2.4 + p.y * 0.05) * 14.0) if is_winter else (-0.25 * spd)
				p += Vector2(vx, spd) * delta
				if p.y > WORLD_H or p.x < -8.0:
					p = Vector2(_rng.randf_range(0.0, WORLD_W + 16.0), _rng.randf_range(-24.0, 0.0))
				d["pos"] = p
		elif not is_winter:
			for b in butterflies:
				var bp: Vector2 = b["pos"]
				var bvx: float = float(b["vx"])
				var bph: float = float(b["phase"])
				bp.x += bvx * delta
				bp.y += sin(_time_acc * 3.8 + bph) * 11.0 * delta
				if bp.x > WORLD_W - 30.0:
					bp.x = 30.0
				elif bp.x < 30.0:
					bp.x = WORLD_W - 30.0
				bp.y = clampf(bp.y, 60.0, WORLD_H - 50.0)
				b["pos"] = bp

		_smoke_timer += delta
		if _smoke_timer >= 0.65:
			_smoke_timer = 0.0
			var chimneys: Array[Vector2] = [
				Vector2(135.0, 62.0),
				Vector2(824.0, 74.0),
				Vector2(982.0, 261.0),
			]
			for ch in chimneys:
				smoke_puffs.append({
					"pos": Vector2(ch.x + _rng.randf_range(-1.5, 1.5), ch.y),
					"life": 0.0,
					"max_life": 2.1,
					"vx": _rng.randf_range(-3.0, 5.0),
				})

		for idx in range(smoke_puffs.size() - 1, -1, -1):
			var puff: Dictionary = smoke_puffs[idx]
			puff["life"] = float(puff["life"]) + delta
			if float(puff["life"]) >= float(puff["max_life"]):
				smoke_puffs.remove_at(idx)
			else:
				var pos: Vector2 = puff["pos"]
				pos += Vector2(float(puff["vx"]), -10.5) * delta
				puff["pos"] = pos
		queue_redraw()

	func _draw() -> void:
		# Water sparkles on pond & Chafariz basin
		for i in range(sparkles.size()):
			var phase: float = sin(_time_acc * 3.2 + float(i) * 1.7)
			if phase > 0.35:
				var sp: Vector2 = sparkles[i]
				var alpha: float = (phase - 0.35) * 1.15
				draw_rect(Rect2(sp.x, sp.y, 2.0, 1.0), Color(0.88, 0.98, 1.0, alpha))

		# Animated Chafariz Colonial water jets & splashes
		for jet_idx in range(2):
			var jx: float = 114.0 if jet_idx == 0 else 126.0
			var drop_y: float = 169.0 + fmod(_time_acc * 18.0 + float(jet_idx) * 3.0, 6.0)
			draw_rect(Rect2(jx, drop_y, 1.5, 2.0), Color(0.82, 0.96, 1.0, 0.85))
			var rip: float = 1.5 + absf(sin(_time_acc * 5.0 + float(jet_idx))) * 2.0
			draw_rect(Rect2(jx - rip * 0.5, 174.5, rip, 1.0), Color(0.86, 0.98, 1.0, 0.65))

		# Tropical butterflies in sunny weather
		if not is_rainy and not is_winter:
			for b in butterflies:
				var bp: Vector2 = b["pos"]
				var flap: float = absf(sin(_time_acc * 14.0 + float(b["phase"])))
				var col: Color = b["color"]
				var wing_w: float = 1.0 + flap * 1.5
				draw_rect(Rect2(bp.x - wing_w, bp.y, wing_w, 1.5), col)
				draw_rect(Rect2(bp.x + 0.5, bp.y, wing_w, 1.5), col)

		# Chimney smoke puffs
		for puff in smoke_puffs:
			var ratio: float = clampf(float(puff["life"]) / float(puff["max_life"]), 0.0, 1.0)
			var alpha: float = (1.0 - ratio) * 0.42
			var sz: float = lerpf(2.0, 5.0, ratio)
			var p: Vector2 = puff["pos"]
			draw_rect(Rect2(p.x - sz * 0.5, p.y - sz * 0.5, sz, sz), Color(0.95, 0.95, 0.96, alpha))

		# Rain droplets or Winter blizzard snowflakes
		if is_rainy:
			for d in drops:
				var p: Vector2 = d["pos"]
				if is_winter:
					draw_rect(Rect2(p.x, p.y, 2.0, 2.0), Color(0.96, 0.99, 1.0, 0.85))
				else:
					var l: float = float(d["len"])
					draw_line(p, p + Vector2(-0.25 * l, l), Color(0.72, 0.88, 1.0, 0.62), 1.0)


class FestivalDecorNode extends Node2D:
	var active: bool = false
	var show_bonfire: bool = false
	var banner_colors: Array[Color] = [
		Color("#ef5350"),
		Color("#ffee58"),
		Color("#42a5f5"),
		Color("#66bb6a"),
	]
	var _t: float = 0.0

	func _ready() -> void:
		z_index = 14
		visible = false

	func _process(delta: float) -> void:
		if not active:
			return
		_t += delta
		queue_redraw()

	func _draw() -> void:
		if not active:
			return
		# Cordões de bandeirinhas coloridas cruzando a Praça do Coreto
		var strings: Array[Array] = [
			[Vector2(760.0, 140.0), Vector2(916.0, 140.0)],
			[Vector2(760.0, 140.0), Vector2(916.0, 232.0)],
			[Vector2(916.0, 140.0), Vector2(760.0, 232.0)],
			[Vector2(760.0, 232.0), Vector2(916.0, 232.0)],
		]
		var c_count: int = maxi(banner_colors.size(), 1)
		for s_idx in range(strings.size()):
			var a: Vector2 = strings[s_idx][0]
			var b: Vector2 = strings[s_idx][1]
			draw_line(a, b, Color(0.26, 0.18, 0.12, 0.8), 1.0)
			var steps: int = 12
			for i in range(1, steps):
				var u: float = float(i) / float(steps)
				var sag: float = sin(u * PI) * 8.0
				var sway: float = sin(_t * 3.5 + float(i) + float(s_idx)) * 1.2
				var pt: Vector2 = a.lerp(b, u) + Vector2(sway, sag)
				var col: Color = banner_colors[(i + s_idx) % c_count]
				var tri := PackedVector2Array([
					pt + Vector2(-3.0, 0.0),
					pt + Vector2(3.0, 0.0),
					pt + Vector2(0.0, 5.5),
				])
				draw_colored_polygon(tri, col)

		# Fogueira animada na Festa Junina (em frente ao Coreto)
		if show_bonfire:
			var fc := Vector2(828.0, 234.0)
			# Lenha cruzada
			draw_line(fc + Vector2(-8.0, 3.0), fc + Vector2(8.0, -3.0), Color("#6d4123"), 3.0)
			draw_line(fc + Vector2(-8.0, -3.0), fc + Vector2(8.0, 3.0), Color("#543018"), 3.0)
			# Chamas oscilantes
			var flick: float = sin(_t * 12.0) * 2.0
			draw_circle(fc + Vector2(0.0, -5.0), 11.0 + flick * 0.4, Color(1.0, 0.56, 0.12, 0.25))
			draw_colored_polygon(PackedVector2Array([
				fc + Vector2(-6.0, 1.0),
				fc + Vector2(6.0, 1.0),
				fc + Vector2(flick * 0.4, -14.0 - absf(flick)),
			]), Color("#ff6d00"))
			draw_colored_polygon(PackedVector2Array([
				fc + Vector2(-3.5, 0.5),
				fc + Vector2(3.5, 0.5),
				fc + Vector2(-flick * 0.3, -9.5 - absf(flick) * 0.6),
			]), Color("#ffd600"))


func _ready() -> void:
	_rng.randomize()
	_game_state = get_node_or_null("/root/GameState")
	_props_texture = _load_texture_safe("res://assets/sprites/props_buildings.png")
	_crops_texture = _load_texture_safe("res://assets/sprites/crops_sheet.png")
	_turnip_texture = _load_texture_safe("res://assets/sprites/seasons/turnip_sheet.png")
	_v13_props_texture = _load_texture_safe("res://assets/sprites/v13_props_sheet.png")
	for s_id in SeasonDataScript.SEASON_ORDER:
		var s_def: Dictionary = SeasonDataScript.get_definition(s_id)
		var t_tex: Texture2D = _load_texture_safe(str(s_def.get("terrain_path", "")))
		if t_tex != null:
			_seasonal_terrain_textures[s_id] = t_tex
		var p_tex: Texture2D = _load_texture_safe(str(s_def.get("props_path", "")))
		if p_tex != null:
			_seasonal_props_textures[s_id] = p_tex
	_animal_scene = load("res://scenes/animal.tscn") as PackedScene
	_house_interior_scene = load("res://scenes/house_interior.tscn") as PackedScene

	var shared_tileset: TileSet = _build_tileset()
	ground_layer.tile_set = shared_tileset
	soil_layer.tile_set = shared_tileset
	obstacle_layer.tile_set = shared_tileset

	_setup_cursor()
	_setup_prompt_label()
	_setup_season_particles()
	_setup_transition_overlay()
	_setup_weather_fx()
	_setup_festival_decor()
	_setup_fishing_minigame()
	_build_farm_map()
	_spawn_colonial_ground_decals()
	_spawn_buildings_and_props()
	_spawn_animals()
	_spawn_villagers()
	_setup_house_interior()
	_setup_village_world()

	if player != null:
		player.global_position = Vector2(136.0, 118.0)
		if player.has_method("set_camera_limits"):
			player.call("set_camera_limits", Rect2i(0, 0, MAP_WIDTH * TILE_SIZE, MAP_HEIGHT * TILE_SIZE))

	_set_exterior_active(true)

	if _game_state != null:
		if _game_state.has_signal("day_advanced"):
			_game_state.day_advanced.connect(_on_day_advanced)
		if _game_state.has_signal("day_changed"):
			_game_state.day_changed.connect(_on_day_changed)
		if _game_state.has_signal("season_changed"):
			_game_state.season_changed.connect(_on_season_changed)
		if _game_state.has_signal("weather_changed"):
			_game_state.weather_changed.connect(_on_weather_changed)
		if _game_state.has_signal("machines_changed"):
			_game_state.machines_changed.connect(_refresh_machines)
		if _game_state.has_signal("orders_changed"):
			_game_state.orders_changed.connect(_refresh_order_badge)
		if _game_state.has_signal("animal_purchased"):
			_game_state.animal_purchased.connect(_on_animal_purchased)
		if _game_state.has_signal("game_reset"):
			_game_state.game_reset.connect(_on_game_reset)
		if _game_state.has_method("register_world_provider"):
			_game_state.call("register_world_provider", Callable(self, "export_world_state"))
		if _game_state.has_method("consume_pending_world_save"):
			var pending_save: Variant = _game_state.call("consume_pending_world_save")
			if pending_save is Dictionary and not (pending_save as Dictionary).is_empty():
				_restore_world_state(pending_save as Dictionary)

	var init_season: String = str(_game_state.get("current_season")) if _game_state != null else "spring"
	_apply_season_visuals(init_season if not init_season.is_empty() else "spring")
	_refresh_machines()
	_refresh_order_badge()
	_refresh_tropeiro_presence()
	_sync_villagers(true)
	_sync_weather_fx()
	_update_day_night_tint()


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


func is_fishing_active() -> bool:
	return _fishing_active


func _process(delta: float) -> void:
	_door_cooldown = maxf(0.0, _door_cooldown - delta)

	if _fishing_active:
		_tick_fishing_minigame(delta)

	var shop_open: bool = _is_shop_open()
	if player != null:
		player.set("can_move", not shop_open and not _fishing_active and not _is_transitioning)

	var manual_move: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var touch_dir_val: Variant = player.get("touch_input_dir") if player != null else Vector2.ZERO
	var touch_move: Vector2 = touch_dir_val if touch_dir_val is Vector2 else Vector2.ZERO
	if (manual_move.length_squared() > 0.01 or touch_move.length_squared() > 0.01) and not _fishing_active:
		_mouse_active = false
		if demo_active:
			set_demo_active(false)
			_show_toast("Modo manual ativado")

	if demo_active:
		_mouse_active = false

	if not shop_open and not _fishing_active and not _is_transitioning and not demo_active and _door_cooldown <= 0.0 and player != null:
		var moving_up: bool = Input.is_action_pressed("move_up") or touch_move.y < -0.35
		var moving_down: bool = Input.is_action_pressed("move_down") or touch_move.y > 0.35
		if _current_location == "farm":
			var p_pos: Vector2 = player.global_position
			if moving_up and absf(p_pos.x - HOUSE_DOOR_POS.x) <= 9.5 and p_pos.y <= 99.0 and p_pos.y >= 88.0:
				_enter_house()
			elif moving_down and absf(p_pos.x - 288.0) <= 24.0 and p_pos.y >= 544.0:
				_enter_village()
		elif _current_location == "house" and _house_interior != null:
			if moving_down and bool(_house_interior.call("is_at_exit_threshold", player.global_position)):
				_exit_house()
		elif _current_location == "village" and _village_world != null:
			if moving_up and bool(_village_world.call("is_at_exit_threshold", player.global_position)):
				_exit_village()

	if _current_location == "farm":
		_update_region_banner()
		_tick_villager_socializing(delta)

	_update_target_cursor(shop_open or _fishing_active)
	_update_prompt_label(shop_open or _fishing_active)
	_update_day_night_tint()


func _physics_process(delta: float) -> void:
	if not demo_active or _is_shop_open() or _fishing_active or _is_transitioning or player == null:
		if player != null:
			player.set("external_input_dir", Vector2.ZERO)
		return
	_mouse_active = false
	_tick_demo_ai(delta)


func set_touch_move_dir(dir: Vector2) -> void:
	if player != null and player.has_method("set_touch_input_dir"):
		player.call("set_touch_input_dir", dir)
	if dir.length_squared() > 0.01 and demo_active:
		set_demo_active(false)
		_show_toast("Modo manual ativado")


func trigger_touch_use() -> void:
	if _is_transitioning:
		return
	if _fishing_active:
		_resolve_fishing_attempt()
		return
	if _is_shop_open() or player == null:
		return
	if _current_location == "house":
		_handle_house_interact(false)
		return
	_handle_use_on_tile(_get_keyboard_target_tile())


func trigger_touch_interact() -> void:
	if _is_transitioning:
		return
	if _fishing_active:
		_end_fishing_minigame(false, true)
		return
	if _is_shop_open() or player == null:
		return
	if _current_location == "house":
		_handle_house_interact(true)
		return
	_handle_interact()


func _unhandled_input(event: InputEvent) -> void:
	if _fishing_active:
		if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and (event as InputEventKey).keycode == KEY_ESCAPE):
			_end_fishing_minigame(false, true)
			get_viewport().set_input_as_handled()
			return
		var catch_press: bool = (
			event.is_action_pressed("action_use")
			or event.is_action_pressed("action_interact")
			or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed)
		)
		if catch_press:
			_resolve_fishing_attempt()
			get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseMotion:
		if not demo_active:
			_mouse_active = true
		return

	if _is_transitioning:
		return

	var is_demo_key: bool = (
		(InputMap.has_action("toggle_demo") and event.is_action_pressed("toggle_demo"))
		or (event is InputEventKey and event.pressed and not event.echo and (event as InputEventKey).keycode == KEY_P)
	)
	if is_demo_key:
		toggle_demo_mode()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("toggle_shop"):
		if hud != null and hud.has_method("toggle_shop"):
			hud.call("toggle_shop")
			get_viewport().set_input_as_handled()
		return

	if event is InputEventKey and event.pressed and not event.echo and (event as InputEventKey).keycode == KEY_J:
		if hud != null and hud.has_method("toggle_journal"):
			hud.call("toggle_journal")
			get_viewport().set_input_as_handled()
		return

	if _is_shop_open():
		if hud != null and hud.has_method("is_dialogue_open") and bool(hud.call("is_dialogue_open")):
			if event.is_action_pressed("action_interact") or event.is_action_pressed("action_use") or event.is_action_pressed("ui_accept"):
				hud.call("advance_dialogue")
				get_viewport().set_input_as_handled()
				return
		if event.is_action_pressed("ui_cancel") and hud != null:
			if hud.has_method("close_all_modals"):
				hud.call("close_all_modals")
			elif hud.has_method("toggle_shop"):
				hud.call("toggle_shop")
			get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("sleep_day"):
		if _game_state != null:
			_game_state.call("advance_day")
		get_viewport().set_input_as_handled()
		return

	if _current_location == "village":
		if event.is_action_pressed("action_interact") or event.is_action_pressed("action_use"):
			_handle_village_interact()
			get_viewport().set_input_as_handled()
			return
		return

	if _current_location == "house":
		if event.is_action_pressed("action_interact"):
			_handle_house_interact(true)
			get_viewport().set_input_as_handled()
			return
		if event.is_action_pressed("action_use"):
			_handle_house_interact(false)
			get_viewport().set_input_as_handled()
			return
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_handle_house_click(get_global_mouse_position())
			get_viewport().set_input_as_handled()
			return
		return

	if event.is_action_pressed("action_interact"):
		_handle_interact()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventKey and event.pressed and not event.echo and (event as InputEventKey).keycode == KEY_G:
		_gift_nearby_villager()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("action_use"):
		var tile: Vector2i = _get_keyboard_target_tile()
		_handle_use_on_tile(tile)
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var click_pos: Vector2 = get_global_mouse_position()
		var clicked_villager: CharacterBody2D = _find_villager_at_click(click_pos)
		if clicked_villager != null:
			if player != null and player.global_position.distance_to(clicked_villager.global_position) <= VILLAGER_INTERACT_REACH + 10.0:
				_interact_with_villager(clicked_villager)
			else:
				_show_toast("Aproxime-se mais para conversar!")
				_play_sfx("play_error")
			get_viewport().set_input_as_handled()
			return

		var clicked_animal: CharacterBody2D = _find_animal_at_click(click_pos)
		if clicked_animal != null:
			if player != null and player.global_position.distance_to(clicked_animal.global_position) <= ANIMAL_INTERACT_REACH + 4.0:
				_interact_with_animal(clicked_animal)
			else:
				_show_toast("Aproxime-se mais do animal!")
				_play_sfx("play_error")
			get_viewport().set_input_as_handled()
			return

		var mouse_tile: Vector2i = _world_to_tile(click_pos)
		if _is_tile_in_reach(mouse_tile):
			_handle_use_on_tile(mouse_tile)
		else:
			_show_toast("Aproxime-se mais para usar!")
			_play_sfx("play_error")
		get_viewport().set_input_as_handled()


func _build_tileset() -> TileSet:
	var tex: Texture2D = _seasonal_terrain_textures.get("spring", null) as Texture2D
	if tex == null:
		tex = _load_texture_safe("res://assets/sprites/terrain_tileset.png")
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	ts.add_physics_layer(0)
	ts.set_physics_layer_collision_layer(0, 1)
	ts.set_physics_layer_collision_mask(0, 1)

	var source := TileSetAtlasSource.new()
	source.texture = tex
	source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)

	for row in range(2):
		for col in range(4):
			source.create_tile(Vector2i(col, row))

	ts.add_source(source, 0)
	_shared_atlas_source = source

	var full_box := PackedVector2Array([
		Vector2(-8, -8),
		Vector2(8, -8),
		Vector2(8, 8),
		Vector2(-8, 8),
	])
	for solid_tile in [TILE_WATER, TILE_FENCE, TILE_SHIPPING_BIN]:
		var data: TileData = source.get_tile_data(solid_tile, 0)
		data.add_collision_polygon(0)
		data.set_collision_polygon_points(0, 0, full_box)

	return ts


func _setup_cursor() -> void:
	tile_cursor.points = PackedVector2Array([
		Vector2(0.5, 0.5),
		Vector2(15.5, 0.5),
		Vector2(15.5, 15.5),
		Vector2(0.5, 15.5),
	])
	tile_cursor.closed = true
	tile_cursor.width = 1.0
	tile_cursor.default_color = Color(1.0, 0.95, 0.4, 0.92)

	_cursor_fill = ColorRect.new()
	_cursor_fill.size = Vector2(TILE_SIZE, TILE_SIZE)
	_cursor_fill.color = Color(1.0, 0.96, 0.55, 0.14)
	_cursor_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile_cursor.add_child(_cursor_fill)

	for i in range(8):
		var extra := ColorRect.new()
		extra.size = Vector2(TILE_SIZE - 2, TILE_SIZE - 2)
		extra.color = Color(1.0, 0.96, 0.55, 0.20)
		extra.visible = false
		extra.z_index = 9
		extra.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(extra)
		_extra_cursor_rects.append(extra)


func _setup_prompt_label() -> void:
	_prompt_label = Label.new()
	_prompt_label.z_index = 25
	_prompt_label.visible = false
	_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt_label.add_theme_font_size_override("font_size", 8)
	_prompt_label.add_theme_color_override("font_color", Color(1.0, 0.98, 0.85))
	_prompt_label.add_theme_color_override("font_outline_color", Color(0.12, 0.08, 0.05, 0.95))
	_prompt_label.add_theme_constant_override("outline_size", 3)
	add_child(_prompt_label)


func _setup_season_particles() -> void:
	var map_center := Vector2(MAP_WIDTH * TILE_SIZE * 0.5, MAP_HEIGHT * TILE_SIZE * 0.5)
	var extents := Vector2(MAP_WIDTH * TILE_SIZE * 0.55, MAP_HEIGHT * TILE_SIZE * 0.55)

	_season_particles = CPUParticles2D.new()
	_season_particles.name = "SeasonParticles"
	_season_particles.position = map_center
	_season_particles.z_index = 18
	_season_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_season_particles.emission_rect_extents = extents
	_season_particles.preprocess = 2.5
	_season_particles.emitting = true
	add_child(_season_particles)

	_firefly_particles = CPUParticles2D.new()
	_firefly_particles.name = "SummerFireflies"
	_firefly_particles.position = map_center
	_firefly_particles.z_index = 20
	_firefly_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_firefly_particles.emission_rect_extents = extents
	_firefly_particles.amount = 20
	_firefly_particles.lifetime = 2.8
	_firefly_particles.direction = Vector2(0.0, -1.0)
	_firefly_particles.spread = 180.0
	_firefly_particles.gravity = Vector2(0.0, -2.0)
	_firefly_particles.initial_velocity_min = 3.0
	_firefly_particles.initial_velocity_max = 9.0
	_firefly_particles.scale_amount_min = 1.4
	_firefly_particles.scale_amount_max = 2.2
	_firefly_particles.color = Color(0.88, 1.0, 0.44, 0.95)
	var ff_grad := Gradient.new()
	ff_grad.offsets = PackedFloat32Array([0.0, 0.35, 0.75, 1.0])
	ff_grad.colors = PackedColorArray([
		Color(0.88, 1.0, 0.44, 0.0),
		Color(0.92, 1.0, 0.52, 0.95),
		Color(0.84, 0.98, 0.38, 0.75),
		Color(0.84, 0.98, 0.38, 0.0),
	])
	_firefly_particles.color_ramp = ff_grad
	_firefly_particles.emitting = false
	add_child(_firefly_particles)


func _setup_weather_fx() -> void:
	_weather_fx = WeatherFxNode.new()
	_weather_fx.name = "WeatherFX"
	add_child(_weather_fx)


func _setup_festival_decor() -> void:
	_festival_decor = FestivalDecorNode.new()
	_festival_decor.name = "FestivalDecor"
	add_child(_festival_decor)


func _setup_fishing_minigame() -> void:
	_fishing_ui = Node2D.new()
	_fishing_ui.name = "FishingMinigame"
	_fishing_ui.z_index = 40
	_fishing_ui.visible = false
	add_child(_fishing_ui)

	var bg := ColorRect.new()
	bg.size = Vector2(68.0, 10.0)
	bg.position = Vector2(-34.0, -5.0)
	bg.color = Color(0.14, 0.08, 0.04, 0.92)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fishing_ui.add_child(bg)

	var track := ColorRect.new()
	track.size = Vector2(64.0, 6.0)
	track.position = Vector2(-32.0, -3.0)
	track.color = Color(0.20, 0.34, 0.52, 1.0)
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fishing_ui.add_child(track)

	_fishing_zone_rect = ColorRect.new()
	_fishing_zone_rect.size = Vector2(18.0, 6.0)
	_fishing_zone_rect.position = Vector2(-9.0, -3.0)
	_fishing_zone_rect.color = Color(0.36, 0.85, 0.42, 0.95)
	_fishing_zone_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fishing_ui.add_child(_fishing_zone_rect)

	_fishing_marker = ColorRect.new()
	_fishing_marker.size = Vector2(3.0, 8.0)
	_fishing_marker.position = Vector2(-1.5, -4.0)
	_fishing_marker.color = Color(1.0, 0.94, 0.35, 1.0)
	_fishing_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fishing_ui.add_child(_fishing_marker)

	var hint := Label.new()
	hint.text = "[Espaço] Pescar!"
	hint.position = Vector2(-34.0, -17.0)
	hint.size = Vector2(68.0, 12.0)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 7)
	hint.add_theme_color_override("font_color", Color(1.0, 0.97, 0.85))
	hint.add_theme_color_override("font_outline_color", Color(0.1, 0.06, 0.03, 0.95))
	hint.add_theme_constant_override("outline_size", 2)
	_fishing_ui.add_child(hint)

	_fishing_bobber = Sprite2D.new()
	_fishing_bobber.z_index = 12
	_fishing_bobber.visible = false
	if _v13_props_texture != null:
		var b_atlas := AtlasTexture.new()
		b_atlas.atlas = _v13_props_texture
		b_atlas.region = Rect2(64, 16, 16, 16)
		_fishing_bobber.texture = b_atlas
	add_child(_fishing_bobber)


func _sync_weather_fx() -> void:
	if _weather_fx == null or _game_state == null:
		return
	var is_rain: bool = str(_game_state.get("weather")) == "rainy"
	_weather_fx.set("is_rainy", is_rain)
	_weather_fx.set("is_winter", _current_season_id == "winter")


func _on_weather_changed(_weather: String, _tomorrow: String) -> void:
	_sync_weather_fx()
	_sync_villagers(false)
	_update_day_night_tint()


func _on_game_reset() -> void:
	if demo_active:
		set_demo_active(false)
	if _fishing_active:
		_end_fishing_minigame(false, true)
	_tea_used_today = false
	_fountain_drank_today = false
	_capela_blessed_today = false
	_current_region = "fazenda"
	_apply_location_state("farm", Vector2(136.0, 118.0), Vector2i(0, 1))
	soil_layer.clear()
	for tile_var in _crops.keys():
		var spr: Variant = _crops[tile_var].get("sprite")
		if is_instance_valid(spr):
			(spr as Node).queue_free()
	_crops.clear()

	for f_var in _fertilized_tiles.values():
		if is_instance_valid(f_var):
			(f_var as Node).queue_free()
	_fertilized_tiles.clear()

	for tile_var in _sprinklers.keys():
		var spr_sp: Variant = _sprinklers[tile_var]
		if is_instance_valid(spr_sp):
			(spr_sp as Node).queue_free()
	_sprinklers.clear()

	_spawn_animals()
	_spawn_villagers()
	_refresh_machines()
	_refresh_order_badge()
	_refresh_tropeiro_presence()

	if player != null:
		player.global_position = Vector2(136.0, 118.0)
		if player.has_method("set_facing_toward"):
			player.call("set_facing_toward", Vector2(136.0, 134.0))

	var reset_season: String = str(_game_state.get("current_season")) if _game_state != null else "spring"
	_apply_season_visuals(reset_season if not reset_season.is_empty() else "spring")
	_sync_villagers(true)
	_sync_weather_fx()
	_update_day_night_tint()


func _build_farm_map() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42026

	# Base grass and wildflowers outside the tillable plot
	for y in range(MAP_HEIGHT):
		for x in range(MAP_WIDTH):
			var cell := Vector2i(x, y)
			var in_arable: bool = ARABLE_RECT.has_point(cell)
			var tile_coord: Vector2i = TILE_GRASS
			if not in_arable and rng.randf() < 0.14:
				tile_coord = TILE_FLOWERS
			ground_layer.set_cell(cell, 0, tile_coord)

	# Dirt paths connecting house, Capela, Chafariz, Paiol, shipping bin, shop sign, well, arable field, pen, Estrada Real, and pond
	for x in range(4, 29):
		ground_layer.set_cell(Vector2i(x, 6), 0, TILE_PATH)
	for y in range(6, 9):
		ground_layer.set_cell(Vector2i(17, y), 0, TILE_PATH)
		ground_layer.set_cell(Vector2i(18, y), 0, TILE_PATH)
	for y in range(6, 13):
		ground_layer.set_cell(Vector2i(26, y), 0, TILE_PATH)
	# Estrada Leste ligando a Fazenda à Vila de São Sebastião
	for x in range(26, 64):
		ground_layer.set_cell(Vector2i(x, 11), 0, TILE_PATH)
		ground_layer.set_cell(Vector2i(x, 12), 0, TILE_PATH)
	ground_layer.set_cell(Vector2i(8, 5), 0, TILE_PATH)
	# Pátio do Chafariz Colonial e acesso ao portão oeste da lavoura e ao Paiol
	for y in range(7, 13):
		ground_layer.set_cell(Vector2i(7, y), 0, TILE_PATH)
		ground_layer.set_cell(Vector2i(8, y), 0, TILE_PATH)
	for x in range(6, 11):
		ground_layer.set_cell(Vector2i(x, 11), 0, TILE_PATH)
		ground_layer.set_cell(Vector2i(x, 12), 0, TILE_PATH)
	for y in range(12, 18):
		ground_layer.set_cell(Vector2i(5, y), 0, TILE_PATH)
	# Estrada Real (saída sul da lavoura até o Vale do Ribeirão)
	for y in range(17, 34):
		ground_layer.set_cell(Vector2i(17, y), 0, TILE_PATH)
		ground_layer.set_cell(Vector2i(18, y), 0, TILE_PATH)

	# Ruas da Vila de São Sebastião (Leste: x=41..63, y=8..21)
	for x in range(41, 64):
		ground_layer.set_cell(Vector2i(x, 8), 0, TILE_PATH)
		ground_layer.set_cell(Vector2i(x, 9), 0, TILE_PATH)
		ground_layer.set_cell(Vector2i(x, 20), 0, TILE_PATH)
		ground_layer.set_cell(Vector2i(x, 21), 0, TILE_PATH)
	# Largo do Coreto (Praça da Vila)
	for y in range(9, 16):
		for x in range(47, 58):
			ground_layer.set_cell(Vector2i(x, y), 0, TILE_PATH)
	# Travessas verticais da Vila
	for y in range(8, 22):
		ground_layer.set_cell(Vector2i(41, y), 0, TILE_PATH)
		ground_layer.set_cell(Vector2i(42, y), 0, TILE_PATH)
		ground_layer.set_cell(Vector2i(48, y), 0, TILE_PATH)
		ground_layer.set_cell(Vector2i(49, y), 0, TILE_PATH)
		ground_layer.set_cell(Vector2i(56, y), 0, TILE_PATH)
		ground_layer.set_cell(Vector2i(57, y), 0, TILE_PATH)
		ground_layer.set_cell(Vector2i(62, y), 0, TILE_PATH)
		ground_layer.set_cell(Vector2i(63, y), 0, TILE_PATH)

	# Estrada do Vale do Ribeirão (Sul: liga Casa Paroquial, Estrada Real, Casa do Chico, Ponte e Vila)
	for x in range(9, 51):
		ground_layer.set_cell(Vector2i(x, 29), 0, TILE_PATH)
		ground_layer.set_cell(Vector2i(x, 30), 0, TILE_PATH)
	for y in range(21, 31):
		ground_layer.set_cell(Vector2i(48, y), 0, TILE_PATH)
		ground_layer.set_cell(Vector2i(49, y), 0, TILE_PATH)

	# Lake in farm bottom-right corner
	for y in range(14, 20):
		for x in range(29, 36):
			var is_corner: bool = (y == 14 or y == 19) and (x == 29 or x == 35)
			if not is_corner:
				ground_layer.set_cell(Vector2i(x, y), 0, TILE_WATER)

	# Ribeirão Colonial fluindo do lago para o Vale Sul (com ponte caminhável em y=29..30)
	for y in range(20, 36):
		if y == 29 or y == 30:
			continue
		var rx_start: int = 32 if y < 24 else 33
		var rx_end: int = 35 if y < 24 else 38
		for x in range(rx_start, rx_end):
			ground_layer.set_cell(Vector2i(x, y), 0, TILE_WATER)

	# Fenced border around the 12x7 arable garden (x=11..24, y=8..16) with 2-tile gates
	for x in range(11, 25):
		for y in range(8, 17):
			var on_edge: bool = (x == 11 or x == 24 or y == 8 or y == 16)
			if not on_edge:
				continue
			var is_gate: bool = (
				((y == 8 or y == 16) and (x == 17 or x == 18))
				or ((x == 11 or x == 24) and (y == 11 or y == 12))
			)
			if not is_gate:
				obstacle_layer.set_cell(Vector2i(x, y), 0, TILE_FENCE)

	# Fenced animal pen (x=27..36, y=4..10) with 2-tile gates at west (27, 6..7) and south (31..32, 10)
	for x in range(27, 37):
		for y in range(4, 11):
			var on_edge: bool = (x == 27 or x == 36 or y == 4 or y == 10)
			if not on_edge:
				continue
			if y == 10 and (x == 31 or x == 32):
				continue
			if x == 27 and (y == 6 or y == 7):
				continue
			obstacle_layer.set_cell(Vector2i(x, y), 0, TILE_FENCE)

	# Shipping bin next to house
	obstacle_layer.set_cell(SHIPPING_BIN_TILE, 0, TILE_SHIPPING_BIN)


func _spawn_colonial_ground_decals() -> void:
	# Calçamento pé-de-moleque no pátio da Casa-Grande, Capela, Chafariz e Praça da Vila
	var cobble_tex := _load_texture_safe("res://assets/sprites/colonial_buildings_px/pe_de_moleque.png")
	if cobble_tex != null:
		for gy in [6, 8, 10]:
			for gx in [4, 6, 8]:
				var spr := Sprite2D.new()
				spr.name = "PeDeMoleque_%d_%d" % [gx, gy]
				spr.texture = cobble_tex
				spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				spr.position = Vector2((gx + 1) * TILE_SIZE, (gy + 1) * TILE_SIZE)
				spr.z_index = -2
				add_child(spr)
				_exterior_props.append(spr)
		# Praça do Coreto na Vila de São Sebastião
		for gy in [9, 11, 13]:
			for gx in [48, 50, 52, 54]:
				var v_spr := Sprite2D.new()
				v_spr.name = "PracaVilaCobble_%d_%d" % [gx, gy]
				v_spr.texture = cobble_tex
				v_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				v_spr.position = Vector2((gx + 1) * TILE_SIZE, (gy + 1) * TILE_SIZE)
				v_spr.z_index = -2
				add_child(v_spr)
				_exterior_props.append(v_spr)

	# Terreiro de secagem de café e tabaco ao lado do Paiol
	var terreiro_tex := _load_texture_safe("res://assets/sprites/colonial_buildings_px/terreiro_secagem.png")
	if terreiro_tex != null:
		var t_spr := Sprite2D.new()
		t_spr.name = "TerreiroSecagem"
		t_spr.texture = terreiro_tex
		t_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		t_spr.position = TERREIRO_POS
		t_spr.z_index = -2
		add_child(t_spr)
		_exterior_props.append(t_spr)

	# Ponte colonial de madeira sobre o Ribeirão no Vale Sul
	var ponte_tex := _load_texture_safe("res://assets/sprites/colonial_buildings_px/ponte_madeira.png")
	if ponte_tex != null:
		var b_spr := Sprite2D.new()
		b_spr.name = "PonteRibeirao"
		b_spr.texture = ponte_tex
		b_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		b_spr.position = Vector2(35.5 * TILE_SIZE, 30.0 * TILE_SIZE)
		b_spr.z_index = -1
		add_child(b_spr)
		_exterior_props.append(b_spr)


func _spawn_buildings_and_props() -> void:
	# Casa-Grande Colonial (taipa, varanda e telha capa-canal) na entrada (128, 96)
	_spawn_colonial_building(
		"Farmhouse",
		"res://assets/sprites/colonial_buildings_px/casa_grande.png",
		Vector2(8.0 * TILE_SIZE, 92.0),
		Vector2(0.0, -24.0),
		Rect2(0.0, -14.0, 58.0, 26.0)
	)

	# Engenhoca / Moenda de Cana com roda d'água
	_spawn_colonial_building(
		"EngenhoMoenda",
		"res://assets/sprites/colonial_buildings_px/engenho_moenda.png",
		Vector2(20.0 * TILE_SIZE, 84.0),
		Vector2(0.0, -20.0),
		Rect2(0.0, -10.0, 52.0, 24.0)
	)

	# Casa de Farinha com forno de barro
	_spawn_colonial_building(
		"CasaDeFarinha",
		"res://assets/sprites/colonial_buildings_px/casa_farinha.png",
		Vector2(25.5 * TILE_SIZE, 84.0),
		Vector2(0.0, -16.0),
		Rect2(0.0, -8.0, 48.0, 22.0)
	)

	# Placa da Loja (16x16) at tile (12, 5)
	_spawn_prop_sprite(
		"ShopSign",
		Rect2(80, 16, 16, 16),
		Vector2(SHOP_SIGN_TILE.x * TILE_SIZE + 8.0, SHOP_SIGN_TILE.y * TILE_SIZE + 13.0),
		Vector2(0.0, -5.0),
		Rect2(0.0, -4.0, 12.0, 10.0)
	)

	# Quadro de Encomendas ao lado da Loja at tile (13, 5)
	var board_body := _spawn_prop_sprite(
		"OrderBoard",
		Rect2(16, 16, 16, 16),
		Vector2(ORDER_BOARD_TILE.x * TILE_SIZE + 8.0, ORDER_BOARD_TILE.y * TILE_SIZE + 13.0),
		Vector2(0.0, -5.0),
		Rect2(0.0, -4.0, 14.0, 10.0),
		_v13_props_texture
	)
	if board_body != null and _v13_props_texture != null:
		_order_badge = Sprite2D.new()
		var badge_atlas := AtlasTexture.new()
		badge_atlas.atlas = _v13_props_texture
		badge_atlas.region = Rect2(96, 16, 16, 16)
		_order_badge.texture = badge_atlas
		_order_badge.position = Vector2(0.0, -18.0)
		_order_badge.scale = Vector2(0.75, 0.75)
		_order_badge.z_index = 8
		_order_badge.visible = false
		board_body.add_child(_order_badge)

	# Poço de pedra colonial at tile (15, 5)
	_spawn_colonial_building(
		"WaterWell",
		"res://assets/sprites/colonial_buildings_px/poco_colonial.png",
		Vector2(WELL_TILE.x * TILE_SIZE + 8.0, WELL_TILE.y * TILE_SIZE + 13.0),
		Vector2(0.0, -10.0),
		Rect2(0.0, -4.0, 18.0, 12.0)
	)

	# Capela Rural Colonial (sineira, porta azul e telha capa-canal)
	_spawn_colonial_building(
		"CapelaColonial",
		"res://assets/sprites/colonial_buildings_px/capela_colonial.png",
		Vector2(CAPELA_TILE.x * TILE_SIZE + 8.0, CAPELA_TILE.y * TILE_SIZE + 4.0),
		Vector2(0.0, -22.0),
		Rect2(0.0, -10.0, 38.0, 22.0)
	)

	# Paiol / Armazém Colonial (sprite já existente no repositório)
	_spawn_colonial_building(
		"PaiolColonial",
		"res://assets/sprites/colonial_buildings_px/paiol.png",
		Vector2(PAIOL_TILE.x * TILE_SIZE + 8.0, PAIOL_TILE.y * TILE_SIZE + 8.0),
		Vector2(0.0, -16.0),
		Rect2(0.0, -8.0, 36.0, 20.0)
	)

	# Chafariz Colonial de pedra-sabão com carrancas e tanque
	_spawn_colonial_building(
		"ChafarizColonial",
		"res://assets/sprites/colonial_buildings_px/chafariz_colonial.png",
		Vector2(FOUNTAIN_TILE.x * TILE_SIZE + 8.0, FOUNTAIN_TILE.y * TILE_SIZE + 8.0),
		Vector2(0.0, -14.0),
		Rect2(0.0, -6.0, 34.0, 18.0)
	)

	# Carro de Boi estacionado na Estrada Real (entrada sul)
	_spawn_colonial_building(
		"CarroDeBoi",
		"res://assets/sprites/colonial_buildings_px/carro_de_boi.png",
		Vector2(CARRO_BOI_TILE.x * TILE_SIZE + 8.0, CARRO_BOI_TILE.y * TILE_SIZE + 8.0),
		Vector2(0.0, -8.0),
		Rect2(0.0, -4.0, 34.0, 14.0)
	)

	# Cruzeiro Colonial no adro da Capela
	_spawn_colonial_building(
		"CruzeiroColonial",
		"res://assets/sprites/colonial_buildings_px/cruzeiro_colonial.png",
		Vector2(2.6 * TILE_SIZE + 8.0, 5.4 * TILE_SIZE + 8.0),
		Vector2(0.0, -13.0),
		Rect2(0.0, -3.0, 10.0, 8.0)
	)

	# Barris de aguardente/melado e sacas de açúcar ao lado do Engenho
	_spawn_colonial_building(
		"BarrisEngenho",
		"res://assets/sprites/colonial_buildings_px/barris_engenho.png",
		Vector2(22.5 * TILE_SIZE + 8.0, 5.4 * TILE_SIZE + 4.0),
		Vector2(0.0, -6.0),
		Rect2(0.0, -3.0, 24.0, 10.0)
	)

	# Porteira rústica aberta na entrada da Estrada Real (sem colisão central para passagem livre)
	var porteira_tex := _load_texture_safe("res://assets/sprites/colonial_buildings_px/porteira_colonial.png")
	if porteira_tex != null:
		var p_spr := Sprite2D.new()
		p_spr.name = "PorteiraColonial"
		p_spr.texture = porteira_tex
		p_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		p_spr.position = Vector2(18.0 * TILE_SIZE, 22.8 * TILE_SIZE)
		p_spr.offset = Vector2(0.0, -6.0)
		add_child(p_spr)
		_exterior_props.append(p_spr)

	# Tropeiro Itinerante (aparece a cada 3 dias na Estrada Real pagando +25% em Réis)
	_tropeiro_body = _spawn_colonial_building(
		"TropeiroNPC",
		"res://assets/sprites/colonial_buildings_px/tropeiro_mula.png",
		Vector2(TROPEIRO_TILE.x * TILE_SIZE + 4.0, TROPEIRO_TILE.y * TILE_SIZE + 8.0),
		Vector2(0.0, -10.0),
		Rect2(0.0, -4.0, 26.0, 12.0)
	)
	if _tropeiro_body != null and _v13_props_texture != null:
		var t_badge := Sprite2D.new()
		var t_atlas := AtlasTexture.new()
		t_atlas.atlas = _v13_props_texture
		t_atlas.region = Rect2(96, 16, 16, 16)
		t_badge.texture = t_atlas
		t_badge.position = Vector2(-6.0, -24.0)
		t_badge.scale = Vector2(0.75, 0.75)
		t_badge.z_index = 8
		_tropeiro_body.add_child(t_badge)

	# Entidades do Folclore Brasileiro (aparecem conforme o horário do dia)
	var folklore_specs: Array[Dictionary] = [
		{"id": "saci", "tex": "res://assets/sprites/colonial_buildings_px/saci_perere.png", "pos": SACI_POS, "off": Vector2(0.0, -10.0), "col": Rect2(0.0, -4.0, 14.0, 10.0)},
		{"id": "mula", "tex": "res://assets/sprites/colonial_buildings_px/mula_sem_cabeca.png", "pos": MULA_POS, "off": Vector2(0.0, -12.0), "col": Rect2(0.0, -4.0, 24.0, 12.0)},
		{"id": "curupira", "tex": "res://assets/sprites/colonial_buildings_px/curupira.png", "pos": CURUPIRA_POS, "off": Vector2(0.0, -10.0), "col": Rect2(0.0, -4.0, 14.0, 10.0)},
		{"id": "iara", "tex": "res://assets/sprites/colonial_buildings_px/iara_lago.png", "pos": IARA_POS, "off": Vector2(0.0, -10.0), "col": Rect2(0.0, -4.0, 16.0, 10.0)},
	]
	_folklore_nodes.clear()
	for fs in folklore_specs:
		var fid: String = str(fs["id"])
		var f_body := _spawn_colonial_building("Folklore_%s" % fid, str(fs["tex"]), fs["pos"], fs["off"], fs["col"])
		if f_body != null:
			if _v13_props_texture != null:
				var fb := Sprite2D.new()
				var fa := AtlasTexture.new()
				fa.atlas = _v13_props_texture
				fa.region = Rect2(96, 16, 16, 16)
				fb.texture = fa
				fb.position = Vector2(0.0, -22.0)
				fb.scale = Vector2(0.7, 0.7)
				fb.z_index = 8
				f_body.add_child(fb)
			_folklore_nodes[fid] = f_body

	# Palmeiras Imperiais (símbolo das sedes de fazendas e praças coloniais)
	var palm_positions: Array[Vector2] = [
		Vector2(6.0 * TILE_SIZE + 4.0, 7.5 * TILE_SIZE),
		Vector2(10.0 * TILE_SIZE + 4.0, 7.5 * TILE_SIZE),
		Vector2(16.0 * TILE_SIZE + 4.0, 21.5 * TILE_SIZE),
		Vector2(19.5 * TILE_SIZE + 4.0, 21.5 * TILE_SIZE),
		Vector2(47.2 * TILE_SIZE, 10.2 * TILE_SIZE),
		Vector2(57.2 * TILE_SIZE, 10.2 * TILE_SIZE),
		Vector2(47.2 * TILE_SIZE, 15.6 * TILE_SIZE),
		Vector2(57.2 * TILE_SIZE, 15.6 * TILE_SIZE),
		Vector2(15.8 * TILE_SIZE, 28.4 * TILE_SIZE),
		Vector2(19.8 * TILE_SIZE, 28.4 * TILE_SIZE),
	]
	for idx in range(palm_positions.size()):
		_spawn_colonial_building(
			"PalmeiraImperial_%d" % idx,
			"res://assets/sprites/colonial_buildings_px/palmeira_imperial.png",
			palm_positions[idx],
			Vector2(0.0, -18.0),
			Rect2(0.0, -3.0, 10.0, 8.0)
		)

	# Casas e edificações da Vila de São Sebastião e do Vale do Ribeirão
	_house_window_glows.clear()
	for b_def in VillageDataScript.get_village_buildings():
		var b_tile: Vector2 = b_def["tile"]
		var b_body := _spawn_colonial_building(
			str(b_def["name"]),
			str(b_def["tex"]),
			Vector2(b_tile.x * TILE_SIZE, b_tile.y * TILE_SIZE),
			b_def["offset"] as Vector2,
			b_def["collider"] as Rect2
		)
		var owner_id: String = str(b_def.get("owner_id", ""))
		if b_body != null and not owner_id.is_empty():
			var w_glow := _create_window_glow(b_def.get("window_pos", Vector2(0.0, -14.0)) as Vector2)
			b_body.add_child(w_glow)
			_house_window_glows[owner_id] = w_glow

	# Poço Colonial da Praça da Vila
	_spawn_colonial_building(
		"VillageWell",
		"res://assets/sprites/colonial_buildings_px/poco_colonial.png",
		Vector2(VILLAGE_WELL_TILE.x * TILE_SIZE + 8.0, VILLAGE_WELL_TILE.y * TILE_SIZE + 13.0),
		Vector2(0.0, -10.0),
		Rect2(0.0, -4.0, 18.0, 12.0)
	)

	# Placas coloniais de direção (Fazenda <-> Vila / Vale)
	var sign_positions: Array[Vector2] = [
		Vector2(38.0 * TILE_SIZE, 10.4 * TILE_SIZE),
		Vector2(16.2 * TILE_SIZE, 28.2 * TILE_SIZE),
		Vector2(47.2 * TILE_SIZE, 28.2 * TILE_SIZE),
	]
	for idx in range(sign_positions.size()):
		_spawn_colonial_building(
			"PlacaDirecao_%d" % idx,
			"res://assets/sprites/colonial_buildings_px/placa_direcao.png",
			sign_positions[idx],
			Vector2(0.0, -10.0),
			Rect2(0.0, -3.0, 10.0, 8.0)
		)

	# Lampiões a óleo coloniais (Fazenda, Praça da Vila e Vale do Ribeirão)
	var lamp_positions: Array[Vector2] = [
		Vector2(9.5 * TILE_SIZE, 5.5 * TILE_SIZE),
		Vector2(5.5 * TILE_SIZE, 5.5 * TILE_SIZE),
		Vector2(9.2 * TILE_SIZE, 10.2 * TILE_SIZE),
		Vector2(16.2 * TILE_SIZE, 19.5 * TILE_SIZE),
		Vector2(40.5 * TILE_SIZE, 10.5 * TILE_SIZE),
		Vector2(47.5 * TILE_SIZE, 8.2 * TILE_SIZE),
		Vector2(57.5 * TILE_SIZE, 8.2 * TILE_SIZE),
		Vector2(47.5 * TILE_SIZE, 19.2 * TILE_SIZE),
		Vector2(57.5 * TILE_SIZE, 19.2 * TILE_SIZE),
		Vector2(31.5 * TILE_SIZE, 28.5 * TILE_SIZE),
		Vector2(39.5 * TILE_SIZE, 28.5 * TILE_SIZE),
		Vector2(13.5 * TILE_SIZE, 28.5 * TILE_SIZE),
	]
	for idx in range(lamp_positions.size()):
		_spawn_colonial_lamp("Lampiao_%d" % idx, lamp_positions[idx])

	# Perimeter and scenic grove trees (32x32) across the expanded 68x38 territory
	var tree_positions: Array[Vector2i] = [
		# Borda norte
		Vector2i(2, 2), Vector2i(5, 2), Vector2i(18, 2), Vector2i(22, 2),
		Vector2i(25, 2), Vector2i(39, 2), Vector2i(47, 2), Vector2i(56, 2),
		Vector2i(64, 2),
		# Borda oeste
		Vector2i(2, 6), Vector2i(2, 11), Vector2i(2, 16), Vector2i(2, 22),
		Vector2i(2, 28), Vector2i(2, 34), Vector2i(3, 14),
		# Borda leste (atrás da Vila)
		Vector2i(65, 6), Vector2i(65, 13), Vector2i(65, 20), Vector2i(65, 27),
		Vector2i(65, 34),
		# Borda sul (Vale do Ribeirão e pomar)
		Vector2i(6, 35), Vector2i(12, 35), Vector2i(22, 35), Vector2i(28, 35),
		Vector2i(42, 35), Vector2i(52, 35), Vector2i(60, 35),
		# Bosques decorativos internos (sem bloquear estradas)
		Vector2i(6, 24), Vector2i(13, 24), Vector2i(26, 17), Vector2i(28, 24),
		Vector2i(43, 25), Vector2i(55, 25), Vector2i(60, 26), Vector2i(58, 32),
	]
	for tp in tree_positions:
		_spawn_prop_sprite(
			"Tree_%d_%d" % [tp.x, tp.y],
			Rect2(32, 0, 32, 32),
			Vector2(tp.x * TILE_SIZE + 8.0, tp.y * TILE_SIZE + 13.0),
			Vector2(0.0, -13.0),
			Rect2(0.0, -4.0, 16.0, 10.0)
		)

	# Rocks (16x16)
	var rock_tiles: Array[Vector2i] = [
		Vector2i(2, 8), Vector2i(4, 10), Vector2i(8, 17),
		Vector2i(22, 5), Vector2i(28, 20), Vector2i(36, 16),
		Vector2i(31, 25), Vector2i(39, 25), Vector2i(45, 33),
		Vector2i(63, 15), Vector2i(14, 33),
	]
	for rt in rock_tiles:
		_spawn_prop_sprite(
			"Rock_%d_%d" % [rt.x, rt.y],
			Rect2(64, 0, 16, 16),
			Vector2(rt.x * TILE_SIZE + 8.0, rt.y * TILE_SIZE + 13.0),
			Vector2(0.0, -5.0),
			Rect2(0.0, -4.0, 12.0, 8.0)
		)

	# Bushes (16x16)
	var bush_tiles: Array[Vector2i] = [
		Vector2i(6, 5), Vector2i(9, 4), Vector2i(14, 4),
		Vector2i(9, 13), Vector2i(9, 18), Vector2i(15, 19),
		Vector2i(22, 18), Vector2i(27, 14), Vector2i(35, 13),
		Vector2i(43, 15), Vector2i(59, 14), Vector2i(64, 9),
		Vector2i(8, 32), Vector2i(21, 32), Vector2i(45, 26),
		Vector2i(54, 28), Vector2i(62, 24),
	]
	for bt in bush_tiles:
		_spawn_prop_sprite(
			"Bush_%d_%d" % [bt.x, bt.y],
			Rect2(80, 0, 16, 16),
			Vector2(bt.x * TILE_SIZE + 8.0, bt.y * TILE_SIZE + 13.0),
			Vector2(0.0, -5.0),
			Rect2(0.0, -4.0, 12.0, 8.0)
		)


func _spawn_prop_sprite(
	prop_name: String,
	region: Rect2,
	world_pos: Vector2,
	sprite_offset: Vector2,
	collider_rect: Rect2,
	atlas_tex: Texture2D = null
) -> StaticBody2D:
	var seasonal_prop_tex: Texture2D = _seasonal_props_textures.get(_current_season_id, _props_texture) as Texture2D
	var use_tex: Texture2D = atlas_tex if atlas_tex != null else seasonal_prop_tex
	if use_tex == null:
		return null
	var body := StaticBody2D.new()
	body.name = prop_name
	body.position = world_pos
	body.collision_layer = 1
	body.collision_mask = 0

	var spr := Sprite2D.new()
	var atlas := AtlasTexture.new()
	atlas.atlas = use_tex
	atlas.region = region
	spr.texture = atlas
	spr.offset = sprite_offset
	body.add_child(spr)
	if atlas_tex == null:
		_prop_atlases.append(atlas)

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = collider_rect.size
	col.shape = shape
	col.position = collider_rect.position
	body.add_child(col)

	add_child(body)
	_exterior_props.append(body)
	return body


func _spawn_colonial_building(
	prop_name: String,
	tex_path: String,
	world_pos: Vector2,
	sprite_offset: Vector2,
	collider_rect: Rect2
) -> StaticBody2D:
	var tex := _load_texture_safe(tex_path)
	if tex == null:
		return null
	var body := StaticBody2D.new()
	body.name = prop_name
	body.position = world_pos
	body.collision_layer = 1
	body.collision_mask = 0

	var spr := Sprite2D.new()
	spr.texture = tex
	spr.offset = sprite_offset
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	body.add_child(spr)

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = collider_rect.size
	col.shape = shape
	col.position = collider_rect.position
	body.add_child(col)

	add_child(body)
	_exterior_props.append(body)
	return body


func _spawn_colonial_lamp(prop_name: String, world_pos: Vector2) -> StaticBody2D:
	var body := _spawn_colonial_building(
		prop_name,
		"res://assets/sprites/colonial_buildings_px/lampiao_colonial.png",
		world_pos,
		Vector2(0.0, -9.0),
		Rect2(0.0, -2.0, 6.0, 6.0)
	)
	if body == null:
		return null
	var glow := Sprite2D.new()
	var grad := GradientTexture2D.new()
	grad.fill = GradientTexture2D.FILL_RADIAL
	grad.fill_from = Vector2(0.5, 0.5)
	grad.fill_to = Vector2(0.5, 0.0)
	grad.width = 48
	grad.height = 48
	var g := Gradient.new()
	g.colors = PackedColorArray([Color(1.0, 0.78, 0.36, 0.55), Color(1.0, 0.62, 0.22, 0.0)])
	grad.gradient = g
	glow.texture = grad
	glow.position = Vector2(0.0, -14.0)
	glow.z_index = 12
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	glow.material = mat
	glow.visible = false
	body.add_child(glow)
	_lamp_glows.append(glow)
	return body


func _create_window_glow(pos: Vector2) -> Sprite2D:
	var glow := Sprite2D.new()
	var grad := GradientTexture2D.new()
	grad.fill = GradientTexture2D.FILL_RADIAL
	grad.fill_from = Vector2(0.5, 0.5)
	grad.fill_to = Vector2(0.5, 0.0)
	grad.width = 44
	grad.height = 36
	var g := Gradient.new()
	g.colors = PackedColorArray([Color(1.0, 0.80, 0.38, 0.52), Color(1.0, 0.60, 0.18, 0.0)])
	grad.gradient = g
	glow.texture = grad
	glow.position = pos
	glow.z_index = 11
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	glow.material = mat
	glow.visible = false
	return glow


func _spawn_villagers() -> void:
	for v in _villagers:
		if is_instance_valid(v):
			v.queue_free()
	_villagers.clear()

	_village_road_graph = VillageDataScript.get_road_graph(TILE_SIZE)
	var specs: Array[Dictionary] = VillageDataScript.get_villager_specs(TILE_SIZE)
	for spec in specs:
		var v_node := VillagerScript.new() as CharacterBody2D
		if v_node == null:
			continue
		v_node.name = "Villager_%s" % str(spec.get("id", "npc"))
		add_child(v_node)
		if v_node.has_method("setup"):
			v_node.call("setup", spec, _village_road_graph)
		if v_node.has_signal("indoors_changed"):
			v_node.indoors_changed.connect(_on_villager_indoors_changed)
		_villagers.append(v_node)


func _get_active_festival() -> Dictionary:
	if _game_state == null:
		return {}
	var s_id: String = str(_game_state.get("current_season"))
	var d_of_s: int = int(_game_state.get("day_of_season"))
	return VillageDataScript.get_active_festival(s_id, d_of_s)


func _refresh_festival_decor() -> void:
	if _festival_decor == null or not is_instance_valid(_festival_decor):
		return
	var fest: Dictionary = _get_active_festival()
	var is_fest: bool = not fest.is_empty()
	_festival_decor.set("active", is_fest)
	_festival_decor.visible = (_current_location == "farm") and is_fest
	if is_fest:
		_festival_decor.set("show_bonfire", bool(fest.get("bonfire", false)))
		var cols_val: Variant = fest.get("banner_colors", [])
		if cols_val is Array:
			var typed_cols: Array[Color] = []
			for c in (cols_val as Array):
				if c is Color:
					typed_cols.append(c as Color)
			if not typed_cols.is_empty():
				_festival_decor.set("banner_colors", typed_cols)
	_festival_decor.queue_redraw()


func _sync_villagers(instant: bool = false) -> void:
	var mins: float = float(_game_state.get("time_minutes")) if _game_state != null else 360.0
	var is_rain: bool = _game_state != null and str(_game_state.get("weather")) == "rainy"
	var fest: Dictionary = _get_active_festival()
	for v in _villagers:
		if is_instance_valid(v) and v.has_method("sync_to_time"):
			var v_fest: Dictionary = {}
			if not fest.is_empty():
				v_fest = fest.duplicate()
				var vid: String = str(v.get("npc_id"))
				v_fest["spot"] = str(VillageDataScript.FESTIVAL_SPOTS.get(vid, "praca_s"))
			v.call("sync_to_time", mins, is_rain, instant, v_fest)
	_refresh_festival_decor()
	_refresh_window_glows()


func get_minimap_snapshot() -> Dictionary:
	var p_pos := Vector2(136.0, 118.0)
	if player != null and _current_location == "farm":
		p_pos = player.global_position
	elif _current_location == "house":
		p_pos = HOUSE_DOOR_POS
	var v_arr: Array[Dictionary] = []
	for v in _villagers:
		if is_instance_valid(v):
			v_arr.append({
				"id": str(v.get("npc_id")),
				"name": str(v.get("npc_name")),
				"role": str(v.get("role")),
				"pos": v.global_position,
				"hearts": int(v.get("hearts")),
				"indoors": bool(v.get("is_indoors")),
				"activity": str(v.get("current_activity")),
			})
	var fest: Dictionary = _get_active_festival()
	return {
		"player_pos": p_pos,
		"villagers": v_arr,
		"tropeiro_present": _tropeiro_present,
		"festival_name": str(fest.get("name", "")),
	}


func _gift_nearby_villager() -> void:
	if _game_state == null or player == null or _current_location != "farm":
		return
	var v: CharacterBody2D = _find_nearby_villager(player.global_position, VILLAGER_INTERACT_REACH + 4.0)
	if v == null:
		return
	if bool(v.get("gifted_today")):
		_show_toast("%s já recebeu presente hoje!" % str(v.get("npc_name")))
		_play_sfx("play_error")
		return

	var vid: String = str(v.get("npc_id"))
	var favs: Array[String] = VillageDataScript.get_favorite_gifts(vid)
	var chosen := _pick_and_consume_gift_item(favs)
	if chosen.is_empty():
		_show_toast("Sem itens na sacola para presentear! Colha, pesque ou produza algo.")
		_play_sfx("play_error")
		return

	var item_name: String = str(chosen["name"])
	var is_fav: bool = bool(chosen["favorite"])
	var res: Dictionary = v.call("receive_gift", item_name, player.global_position, is_fav)
	if bool(res.get("accepted", false)):
		_play_sfx("play_harvest" if is_fav else "play_click")
		_spawn_particles(v.global_position + Vector2(0.0, -8.0), Color(1.0, 0.42, 0.58))
		var h_lbl: String = "+2 ♥ Favorito!" if is_fav else "+1 ♥ Presente!"
		_spawn_floating_text(v.global_position + Vector2(0.0, -18.0), h_lbl, Color(1.0, 0.52, 0.65))
		_show_toast("%s: \"%s\"" % [str(res.get("npc_name", "")), str(res.get("line", ""))])


func _pick_and_consume_gift_item(favorites: Array[String]) -> Dictionary:
	if _game_state == null:
		return {}
	var buckets: Array[Dictionary] = [
		{"dict": _game_state.get("artisan"), "catalog": FarmCatalogScript.ARTISAN},
		{"dict": _game_state.get("fish"), "catalog": FarmCatalogScript.FISH},
		{"dict": _game_state.get("animal_products"), "catalog": FarmCatalogScript.ANIMAL_PRODUCTS},
		{"dict": _game_state.get("harvested"), "catalog": _game_state.CROPS},
	]
	# 1. Tenta primeiro um item favorito que o jogador tenha na sacola
	for fav_id in favorites:
		for b in buckets:
			var d_val: Variant = b["dict"]
			if d_val is Dictionary:
				var d := d_val as Dictionary
				if int(d.get(fav_id, 0)) > 0:
					d[fav_id] = int(d[fav_id]) - 1
					if _game_state.has_signal("inventory_changed"):
						_game_state.inventory_changed.emit()
					var cat: Dictionary = b["catalog"]
					var nm: String = str(cat.get(fav_id, {}).get("name", fav_id))
					return {"id": fav_id, "name": nm, "favorite": true}
	# 2. Caso contrário, entrega o primeiro item disponível da sacola
	for b in buckets:
		var d_val: Variant = b["dict"]
		if d_val is Dictionary:
			var d := d_val as Dictionary
			for k in d.keys():
				if int(d.get(k, 0)) > 0:
					d[k] = int(d[k]) - 1
					if _game_state.has_signal("inventory_changed"):
						_game_state.inventory_changed.emit()
					var cat: Dictionary = b["catalog"]
					var nm: String = str(cat.get(k, {}).get("name", str(k)))
					return {"id": str(k), "name": nm, "favorite": false}
	return {}


func _on_villager_indoors_changed(_npc_id: String, _inside: bool) -> void:
	_refresh_window_glows()


func _refresh_window_glows() -> void:
	if _house_window_glows.is_empty():
		return
	var mins: float = float(_game_state.get("time_minutes")) if _game_state != null else 360.0
	var is_evening_or_night: bool = (mins >= 1020.0 or mins < 420.0)
	var indoors_by_id: Dictionary = {}
	for v in _villagers:
		if is_instance_valid(v):
			indoors_by_id[str(v.get("npc_id"))] = bool(v.get("is_indoors"))
	for owner_id in _house_window_glows.keys():
		var glow_val: Variant = _house_window_glows[owner_id]
		if is_instance_valid(glow_val) and glow_val is Sprite2D:
			var is_in: bool = bool(indoors_by_id.get(owner_id, false))
			var show_glow: bool = (_current_location == "farm") and (is_evening_or_night or is_in)
			var g_spr := glow_val as Sprite2D
			g_spr.visible = show_glow
			g_spr.modulate.a = 0.95 if (is_in and is_evening_or_night) else (0.55 if is_evening_or_night else 0.35)


func _find_nearby_villager(world_pos: Vector2, max_dist: float) -> CharacterBody2D:
	var best: CharacterBody2D = null
	var best_dist: float = max_dist
	for v in _villagers:
		if not is_instance_valid(v) or not v.visible or bool(v.get("is_indoors")):
			continue
		var d: float = world_pos.distance_to(v.global_position)
		if d <= best_dist:
			best_dist = d
			best = v
	return best


func _find_villager_at_click(click_pos: Vector2) -> CharacterBody2D:
	var best: CharacterBody2D = null
	var best_dist: float = 16.0
	for v in _villagers:
		if not is_instance_valid(v) or not v.visible or bool(v.get("is_indoors")):
			continue
		var d: float = click_pos.distance_to(v.global_position + Vector2(0.0, -4.0))
		if d <= best_dist:
			best_dist = d
			best = v
	return best


func _interact_with_villager(villager: CharacterBody2D) -> void:
	if villager == null or not is_instance_valid(villager) or player == null:
		return
	var mins: float = float(_game_state.get("time_minutes")) if _game_state != null else 480.0
	var is_rain: bool = _game_state != null and str(_game_state.get("weather")) == "rainy"
	var res: Dictionary = villager.call("interact", player.global_position, mins, is_rain, _current_season_id)
	var v_id: String = str(res.get("npc_id", ""))
	var v_name: String = str(res.get("npc_name", "Morador"))
	var line: String = str(res.get("line", ""))
	var hearts: int = int(res.get("hearts", 0))
	var gained: bool = bool(res.get("gained_heart", false))

	_play_sfx("play_click")
	if gained:
		_spawn_particles(villager.global_position + Vector2(0.0, -8.0), Color(1.0, 0.48, 0.58))
		_spawn_floating_text(villager.global_position + Vector2(0.0, -18.0), "+1 ♥ Amizade", Color(1.0, 0.55, 0.65))

	# Benefícios diários únicos de cada morador da vila
	var perk_used: bool = bool(villager.get("perk_used_today"))
	if not perk_used and _game_state != null:
		if v_id == "quiteria":
			villager.set("perk_used_today", true)
			var cur_s: int = int(_game_state.get("stamina"))
			var max_s: int = int(_game_state.get("max_stamina"))
			var new_s: int = mini(max_s, cur_s + 15)
			_game_state.set("stamina", new_s)
			if _game_state.has_signal("stamina_changed"):
				_game_state.stamina_changed.emit(new_s, max_s)
			_spawn_floating_text(player.global_position + Vector2(0.0, -16.0), "+15 Energia (Chá)", Color(0.55, 0.96, 0.65))
			_show_toast("%s: \"%s\" (+15 Energia do Chá de Ervas!)" % [v_name, line])
			return
		elif v_id == "sinha" and hearts >= 2:
			villager.set("perk_used_today", true)
			var cur_s2: int = int(_game_state.get("stamina"))
			var max_s2: int = int(_game_state.get("max_stamina"))
			var new_s2: int = mini(max_s2, cur_s2 + 8)
			_game_state.set("stamina", new_s2)
			if _game_state.has_signal("stamina_changed"):
				_game_state.stamina_changed.emit(new_s2, max_s2)
			_spawn_floating_text(player.global_position + Vector2(0.0, -16.0), "+8 Energia (Doce)", Color(1.0, 0.85, 0.45))
			_show_toast("%s: \"%s\" (+8 Energia do doce caseiro!)" % [v_name, line])
			return
		elif v_id == "tiao" and hearts >= 3:
			villager.set("perk_used_today", true)
			if _game_state.has_method("add_fish"):
				_game_state.call("add_fish", "tilapia", 1, false)
			_spawn_floating_text(player.global_position + Vector2(0.0, -16.0), "+1 Tilápia Fresca", Color(0.55, 0.88, 1.0))
			_show_toast("%s: \"%s\" (Presenteou +1 Tilápia fresca!)" % [v_name, line])
			return

	_show_toast("%s: \"%s\"" % [v_name, line])


func _update_region_banner() -> void:
	if player == null:
		return
	var tile: Vector2i = _world_to_tile(player.global_position)
	var next_region: String = "fazenda"
	if tile.x >= 40 and tile.y <= 23:
		next_region = "vila"
	elif tile.y >= 24:
		next_region = "vale"
	if next_region != _current_region:
		_current_region = next_region
		match next_region:
			"vila":
				_show_toast("Vila de São Sebastião — Praça do Coreto, Venda, Ferraria e Botica")
			"vale":
				_show_toast("Vale do Ribeirão — Casa Paroquial, Ponte de Madeira e Estrada Real")
			_:
				_show_toast("Fazenda Colonial — Sede e Lavoura")


func _tick_villager_socializing(delta: float) -> void:
	_social_check_timer -= delta
	if _social_check_timer > 0.0:
		return
	_social_check_timer = 9.5
	var greetings: Array[String] = [
		"Ô compadre!",
		"Tudo em paz?",
		"Belo dia na vila!",
		"Como vai a lida?",
		"Saúde e fartura!",
	]
	for i in range(_villagers.size()):
		var va: CharacterBody2D = _villagers[i]
		if not is_instance_valid(va) or bool(va.get("is_indoors")):
			continue
		for j in range(i + 1, _villagers.size()):
			var vb: CharacterBody2D = _villagers[j]
			if not is_instance_valid(vb) or bool(vb.get("is_indoors")):
				continue
			if va.global_position.distance_to(vb.global_position) <= 28.0 and _rng.randf() < 0.35:
				if va.has_method("show_bubble"):
					va.call("show_bubble", greetings[_rng.randi() % greetings.size()], 2.4)
				if va.has_method("face_toward"):
					va.call("face_toward", vb.global_position)
				if vb.has_method("face_toward"):
					vb.call("face_toward", va.global_position)
				return


func _refresh_tropeiro_presence() -> void:
	var day_num: int = int(_game_state.get("day")) if _game_state != null else 1
	_tropeiro_present = (day_num % 3 == 1)
	if _tropeiro_body != null and is_instance_valid(_tropeiro_body):
		_tropeiro_body.visible = (_current_location == "farm") and _tropeiro_present
		for child in _tropeiro_body.get_children():
			if child is CollisionShape2D:
				(child as CollisionShape2D).disabled = not _tropeiro_present


func _is_folklore_active_now(fid: String, mins: float) -> bool:
	match fid:
		"saci":
			return mins >= 720.0 and mins < 1080.0
		"curupira":
			return mins >= 360.0 and mins < 1020.0
		"iara":
			return mins >= 960.0 and mins < 1200.0
		"mula":
			return mins >= 1140.0 or mins < 120.0
	return false


func _refresh_folklore_visibility() -> void:
	var mins: float = float(_game_state.get("time_minutes")) if _game_state != null else 480.0
	for fid_var in _folklore_nodes.keys():
		var fid: String = str(fid_var)
		var body: StaticBody2D = _folklore_nodes[fid] as StaticBody2D
		if body == null or not is_instance_valid(body):
			continue
		var show_it: bool = (_current_location == "farm") and _is_folklore_active_now(fid, mins)
		body.visible = show_it
		for child in body.get_children():
			if child is CollisionShape2D:
				(child as CollisionShape2D).disabled = not show_it


func _interact_with_story_entity(entity_id: String) -> void:
	if _game_state == null:
		return
	var res: Dictionary = _game_state.call("interact_story_entity", entity_id, _capela_blessed_today)
	if res.is_empty():
		return
	var speaker: String = str(res.get("speaker", entity_id))
	var lines: Array = res.get("lines", [])
	var open_shop: bool = bool(res.get("open_shop", false))
	if bool(res.get("quest_completed", false)) and player != null:
		_spawn_particles(player.global_position, Color(1.0, 0.90, 0.35))
	var on_close := Callable()
	if open_shop and hud != null and hud.has_method("toggle_shop"):
		on_close = Callable(hud, "toggle_shop")
	if hud != null and hud.has_method("show_dialogue"):
		hud.call("show_dialogue", speaker, lines, on_close)


func _spawn_animals() -> void:
	for a in _animals:
		if is_instance_valid(a):
			a.queue_free()
	_animals.clear()

	if _animal_scene == null:
		return
	var specs: Array[Dictionary] = [
		{"type": "chicken", "pos": Vector2(474.0, 106.0)},
		{"type": "chicken", "pos": Vector2(514.0, 128.0)},
		{"type": "cow", "pos": Vector2(546.0, 104.0)},
		{"type": "sheep", "pos": Vector2(490.0, 134.0)},
		{"type": "pig", "pos": Vector2(536.0, 138.0)},
	]
	for i in range(specs.size()):
		_spawn_single_animal(str(specs[i]["type"]), specs[i]["pos"], i)


func _spawn_single_animal(a_type: String, pos: Vector2, idx: int) -> CharacterBody2D:
	if _animal_scene == null:
		return null
	var animal := _animal_scene.instantiate() as CharacterBody2D
	if animal == null:
		return null
	animal.name = "Animal_%d" % idx
	animal.position = pos
	if animal.has_method("setup"):
		animal.call("setup", a_type, ANIMAL_PEN_BOUNDS)
	add_child(animal)
	_animals.append(animal)
	return animal


func _on_animal_purchased(animal_type: String) -> void:
	var pos := Vector2(
		_rng.randf_range(ANIMAL_PEN_BOUNDS.position.x + 8.0, ANIMAL_PEN_BOUNDS.end.x - 8.0),
		_rng.randf_range(ANIMAL_PEN_BOUNDS.position.y + 8.0, ANIMAL_PEN_BOUNDS.end.y - 8.0)
	)
	_spawn_single_animal(animal_type, pos, _animals.size())


func _refresh_machines() -> void:
	if _game_state == null or _v13_props_texture == null:
		return
	var owned: Dictionary = _game_state.get("owned_machines")
	var states: Dictionary = _game_state.get("machine_states")

	for m_id in FarmCatalogScript.MACHINE_ORDER:
		var is_owned: bool = bool(owned.get(m_id, false))
		var m_def: Dictionary = FarmCatalogScript.MACHINES[m_id]
		if not is_owned:
			if _machines.has(m_id):
				var old_body: Node = _machines[m_id].get("body")
				if is_instance_valid(old_body):
					old_body.queue_free()
				_machines.erase(m_id)
			continue

		if not _machines.has(m_id):
			var tile: Vector2i = m_def["tile"]
			var body := _spawn_prop_sprite(
				"Machine_%s" % m_id,
				Rect2(int(m_def["prop_col_idle"]) * 16, 0, 16, 16),
				Vector2(tile.x * TILE_SIZE + 8.0, tile.y * TILE_SIZE + 13.0),
				Vector2(0.0, -5.0),
				Rect2(0.0, -4.0, 14.0, 10.0),
				_v13_props_texture
			)
			if body == null:
				continue
			var spr: Sprite2D = body.get_child(0) as Sprite2D
			var badge := Sprite2D.new()
			var b_atlas := AtlasTexture.new()
			b_atlas.atlas = _v13_props_texture
			b_atlas.region = Rect2(96, 16, 16, 16)
			badge.texture = b_atlas
			badge.position = Vector2(0.0, -18.0)
			badge.scale = Vector2(0.75, 0.75)
			badge.z_index = 8
			badge.visible = false
			body.add_child(badge)
			_machines[m_id] = {"body": body, "sprite": spr, "badge": badge, "tile": tile}

		var entry: Dictionary = _machines[m_id]
		var m_state: Dictionary = states.get(m_id, {})
		var is_ready: bool = bool(m_state.get("ready", false))
		var is_busy: bool = bool(m_state.get("busy", false))
		var spr_node: Sprite2D = entry["sprite"]
		var badge_node: Sprite2D = entry["badge"]
		if is_instance_valid(spr_node) and spr_node.texture is AtlasTexture:
			var col_idx: int = int(m_def["prop_col_ready"]) if is_ready else int(m_def["prop_col_idle"])
			(spr_node.texture as AtlasTexture).region = Rect2(col_idx * 16, 0, 16, 16)
			spr_node.modulate = Color(1.0, 0.94, 0.84) if is_busy else Color.WHITE
		if is_instance_valid(badge_node):
			badge_node.visible = is_ready


func _refresh_order_badge() -> void:
	if _order_badge == null or _game_state == null:
		return
	_order_badge.visible = bool(_game_state.call("has_deliverable_order"))


func _handle_use_on_tile(target_tile: Vector2i) -> void:
	if _game_state == null or player == null:
		return

	if player.has_method("set_facing_toward"):
		player.call("set_facing_toward", _tile_center(target_tile))

	# 1. Harvest mature crop first regardless of held tool
	if _crops.has(target_tile) and int(_crops[target_tile]["stage"]) == 4:
		_harvest_crop(target_tile)
		return

	# 2. Direct click/use on interactable world objects
	if target_tile in HOUSE_DOOR_TILES and player.global_position.distance_to(HOUSE_DOOR_POS) <= 34.0:
		_enter_house()
		return
	if target_tile == SHIPPING_BIN_TILE:
		_sell_at_shipping_bin()
		return
	if target_tile == SHOP_SIGN_TILE:
		if hud != null and hud.has_method("toggle_shop"):
			hud.call("toggle_shop")
		return
	if target_tile == ORDER_BOARD_TILE:
		if hud != null and hud.has_method("toggle_journal"):
			hud.call("toggle_journal", 0)
		return
	for m_id in _machines.keys():
		if _machines[m_id]["tile"] == target_tile:
			_interact_with_machine(m_id)
			return

	var slot: Dictionary = _game_state.call("get_selected_slot")
	var slot_id: String = str(slot.get("id", ""))
	var slot_type: String = str(slot.get("type", ""))

	if slot_id == "hoe":
		_use_hoe(target_tile)
	elif slot_id == "watering_can":
		_use_watering_can(target_tile)
	elif slot_id == "fishing_rod":
		_use_fishing_rod(target_tile)
	elif slot_type == "seed":
		_plant_seed(target_tile, str(slot.get("crop_id", "")))
	elif slot_id == "fertilizer":
		_use_fertilizer(target_tile)
	elif slot_id == "sprinkler":
		_place_sprinkler(target_tile)


func _handle_interact() -> void:
	if _game_state == null or player == null:
		return

	var p_pos: Vector2 = player.global_position

	# Check nearby villager first so conversing with NPCs feels immediate
	var nearby_villager: CharacterBody2D = _find_nearby_villager(p_pos, VILLAGER_INTERACT_REACH)
	if nearby_villager != null:
		_interact_with_villager(nearby_villager)
		return

	# Check proximity to Shipping Bin
	if p_pos.distance_to(_tile_center(SHIPPING_BIN_TILE)) <= 28.0:
		_sell_at_shipping_bin()
		return

	# Check proximity to House Door -> Enter House Interior
	if p_pos.distance_to(HOUSE_DOOR_POS) <= 28.0:
		_enter_house()
		return

	# Check proximity to Shop Sign or Venda Secos & Molhados in the Village
	if p_pos.distance_to(_tile_center(SHOP_SIGN_TILE)) <= 28.0 or p_pos.distance_to(_tile_center(VENDA_TILE)) <= 32.0:
		if hud != null and hud.has_method("toggle_shop"):
			hud.call("toggle_shop")
		return

	# Check proximity to Poço da Vila
	if p_pos.distance_to(_tile_center(VILLAGE_WELL_TILE)) <= 30.0:
		_refill_watering_can()
		return

	# Check proximity to Order Board
	if p_pos.distance_to(_tile_center(ORDER_BOARD_TILE)) <= 28.0:
		if hud != null and hud.has_method("toggle_journal"):
			hud.call("toggle_journal", 0)
		return

	# Check nearby artisan machine
	var nearby_machine := _find_nearby_machine(p_pos)
	if not nearby_machine.is_empty():
		_interact_with_machine(nearby_machine)
		return

	# Check proximity to Chafariz Colonial -> refill water & drink once per day
	if p_pos.distance_to(_tile_center(FOUNTAIN_TILE)) <= 32.0:
		_refill_watering_can()
		if not _fountain_drank_today:
			_fountain_drank_today = true
			var cur_stam: int = int(_game_state.get("stamina"))
			var max_stam: int = int(_game_state.get("max_stamina"))
			var new_stam: int = mini(max_stam, cur_stam + 10)
			_game_state.set("stamina", new_stam)
			if _game_state.has_signal("stamina_changed"):
				_game_state.stamina_changed.emit(new_stam, max_stam)
			_play_sfx("play_splash")
			_spawn_floating_text(_tile_center(FOUNTAIN_TILE) + Vector2(0.0, -16.0), "+10 Energia", Color(0.55, 0.92, 1.0))
			_show_toast("Água fresca do Chafariz! (+10 Energia)")
		return

	# Check proximity to Capela Rural Colonial -> daily blessing (+15% Gold harvest) + bell
	if p_pos.distance_to(_tile_center(CAPELA_TILE)) <= 34.0:
		_play_sfx("play_bell")
		_spawn_particles(_tile_center(CAPELA_TILE), Color(1.0, 0.94, 0.65))
		if not _capela_blessed_today:
			_capela_blessed_today = true
			_spawn_floating_text(_tile_center(CAPELA_TILE) + Vector2(0.0, -20.0), "+15% Ouro ★", Color(1.0, 0.92, 0.35))
			_show_toast("Bênção da Capela! +15% chance de colheita Ouro ★ hoje.")
		else:
			_show_toast("Capela da Fazenda: Bênção já ativa hoje (+15% Ouro ★).")
		return

	# Check proximity to visible Brazilian Folklore entities
	for fid_var in _folklore_nodes.keys():
		var fid: String = str(fid_var)
		var f_body: StaticBody2D = _folklore_nodes[fid] as StaticBody2D
		if f_body != null and is_instance_valid(f_body) and f_body.visible:
			if p_pos.distance_to(f_body.global_position) <= 34.0:
				_interact_with_story_entity(fid)
				return

	# Check proximity to Tropeiro Itinerante -> sell basket (+50% Pedido da Corte / +25% resto)
	if _tropeiro_present and p_pos.distance_to(_tile_center(TROPEIRO_TILE)) <= 34.0:
		var feat: Dictionary = _game_state.call("get_tropeiro_featured_item")
		var feat_id: String = str(feat.get("id", ""))
		var earned: int = int(_game_state.call("sell_all_harvested", 1.25, "Tropeiro", feat_id, 1.5))
		if earned > 0:
			_spawn_particles(_tile_center(TROPEIRO_TILE), Color(1.0, 0.88, 0.25))
			_spawn_floating_text(_tile_center(TROPEIRO_TILE) + Vector2(0.0, -16.0), "+Rs %d" % earned, Color(1.0, 0.90, 0.25))
		return

	# Check proximity to Terreiro de Secagem -> 2 Tabaco -> Rolo de Fumo or 2 Café -> Saca de Café
	if p_pos.distance_to(TERREIRO_POS) <= 44.0:
		var res_t: String = str(_game_state.call("process_terreiro_secagem"))
		if res_t == "rolo_fumo":
			_play_sfx("play_machine")
			_spawn_particles(TERREIRO_POS, Color(0.86, 0.72, 0.32))
			_spawn_floating_text(TERREIRO_POS + Vector2(0.0, -16.0), "+1 Rolo de Fumo", Color(1.0, 0.92, 0.45))
			_show_toast("Terreiro: secou 1 Rolo de Fumo (Rs 260)!")
		elif res_t == "saca_cafe":
			_play_sfx("play_machine")
			_spawn_particles(TERREIRO_POS, Color(0.72, 0.46, 0.28))
			_spawn_floating_text(TERREIRO_POS + Vector2(0.0, -16.0), "+1 Saca de Café", Color(1.0, 0.88, 0.55))
			_show_toast("Terreiro: torrou 1 Saca de Café (Rs 190)!")
		else:
			_play_sfx("play_error")
			_show_toast("Terreiro precisa de 2 Tabacos ou 2 Cafés na sacola.")
		return

	# Check proximity to Casa de Farinha -> process 2 Mandioca into Farinha de Mandioca
	if p_pos.distance_to(_tile_center(CASA_FARINHA_TILE)) <= 36.0:
		var res_f: String = str(_game_state.call("process_casa_farinha"))
		if res_f == "ok":
			_play_sfx("play_machine")
			_spawn_particles(_tile_center(CASA_FARINHA_TILE), Color(0.98, 0.92, 0.72))
			_spawn_floating_text(_tile_center(CASA_FARINHA_TILE) + Vector2(0.0, -16.0), "+1 Farinha", Color(1.0, 0.95, 0.65))
			_show_toast("Casa de Farinha: produziu 1 Farinha de Mandioca (Rs 135)!")
		else:
			_play_sfx("play_error")
			_show_toast("Casa de Farinha precisa de 2 Mandiocas na sacola.")
		return

	# Check proximity to Paiol Colonial
	if p_pos.distance_to(_tile_center(PAIOL_TILE)) <= 34.0:
		_play_sfx("play_click")
		var total_stored: int = 0
		for dict_key in ["harvested", "animal_products", "fish", "artisan"]:
			var inv_val: Variant = _game_state.get(dict_key)
			if inv_val is Dictionary:
				for qty in (inv_val as Dictionary).values():
					total_stored += int(qty)
		_show_toast("Paiol Colonial: %d itens prontos na sacola." % total_stored)
		return

	# Check proximity to Well or Pond -> refill water
	if _is_near_water_source(p_pos, _get_keyboard_target_tile()):
		_refill_watering_can()
		return

	# Check nearby animal before crop tiles
	var nearby_animal: CharacterBody2D = _find_nearby_animal(p_pos, ANIMAL_INTERACT_REACH)
	if nearby_animal != null:
		_interact_with_animal(nearby_animal)
		return

	var target_tile: Vector2i = _get_active_target_tile()
	var player_tile: Vector2i = _world_to_tile(p_pos)

	# Check sprinkler pickup
	for check_tile in [target_tile, player_tile]:
		if _sprinklers.has(check_tile):
			_pickup_sprinkler(check_tile)
			return

	# Check crop on target tile or player's current tile
	for check_tile in [target_tile, player_tile]:
		if _crops.has(check_tile):
			var crop_info: Dictionary = _crops[check_tile]
			if int(crop_info["stage"]) == 4:
				_harvest_crop(check_tile)
			else:
				var crop_def: Dictionary = _game_state.CROPS.get(crop_info["crop_id"], {})
				var crop_name: String = str(crop_def.get("name", "Planta"))
				var days_needed: int = int(crop_def.get("days_to_grow", 2))
				var is_wet: bool = soil_layer.get_cell_source_id(check_tile) != -1 and soil_layer.get_cell_atlas_coords(check_tile) == TILE_SOIL_WET
				var water_state: String = "Regada" if is_wet else "Precisa água"
				_show_toast("%s: %d/%d dias (%s)" % [crop_name, int(crop_info["days_grown"]), days_needed, water_state])
			return


func _find_nearby_machine(world_pos: Vector2) -> String:
	var best: String = ""
	var best_dist: float = 28.0
	for m_id in _machines.keys():
		var m_tile: Vector2i = _machines[m_id]["tile"]
		var d: float = world_pos.distance_to(_tile_center(m_tile))
		if d <= best_dist:
			best_dist = d
			best = str(m_id)
	return best


func _interact_with_machine(machine_id: String) -> void:
	if _game_state == null or not FarmCatalogScript.MACHINES.has(machine_id):
		return
	var m_def: Dictionary = FarmCatalogScript.MACHINES[machine_id]
	var tile: Vector2i = m_def["tile"]
	if player != null and player.has_method("set_facing_toward"):
		player.call("set_facing_toward", _tile_center(tile))

	var res: String = str(_game_state.call("start_machine", machine_id))
	if res.begins_with("collected:"):
		var out_id: String = res.substr(10)
		var out_info: Dictionary = FarmCatalogScript.ARTISAN.get(out_id, {})
		var out_name: String = str(out_info.get("name", out_id))
		_play_sfx("play_machine")
		_spawn_particles(_tile_center(tile), Color(1.0, 0.90, 0.35))
		_spawn_floating_text(_tile_center(tile) + Vector2(0.0, -14.0), "+1 %s" % out_name, Color(1.0, 0.95, 0.55))
		_show_toast("Coletou 1 %s artesanal!" % out_name)
	elif res == "started":
		_play_sfx("play_machine")
		_spawn_particles(_tile_center(tile), Color(0.95, 0.72, 0.35))
		_show_toast("%s iniciou a produção!" % str(m_def.get("name", machine_id)))
	elif res == "busy":
		var st: Dictionary = _game_state.get("machine_states").get(machine_id, {})
		var mins_left: int = maxi(1, roundi(float(st.get("remaining", 0.0))))
		_show_toast("%s trabalhando (%d min restantes)" % [str(m_def.get("name", machine_id)), mins_left])
	elif res == "missing_input":
		var input_id: String = str(m_def.get("input_id", ""))
		var input_qty: int = int(m_def.get("input_qty", 1))
		var in_info := FarmCatalogScript.get_item_info(input_id, _game_state.CROPS)
		_play_sfx("play_error")
		_show_toast("Precisa de %dx %s!" % [input_qty, str(in_info.get("name", input_id))])
	elif res == "idle_auto":
		_show_toast("Apiário produz Mel automaticamente ao amanhecer!")


func _interact_with_animal(animal: CharacterBody2D) -> void:
	if animal == null or not is_instance_valid(animal):
		return
	if player != null and player.has_method("set_facing_toward"):
		player.call("set_facing_toward", animal.global_position)

	var a_type: String = str(animal.get("animal_type"))
	_play_sfx("play_animal", [a_type])

	var petted_now: bool = false
	if animal.has_method("pet"):
		petted_now = bool(animal.call("pet"))

	var ready: bool = animal.has_method("can_collect") and bool(animal.call("can_collect"))
	if ready and animal.has_method("collect_product_info"):
		var info: Dictionary = animal.call("collect_product_info")
		var prod: String = str(info.get("id", ""))
		var is_gold: bool = bool(info.get("gold", false))
		if not prod.is_empty():
			if _game_state != null and _game_state.has_method("add_animal_product"):
				_game_state.call("add_animal_product", prod, 1, is_gold)
			var p_def: Dictionary = FarmCatalogScript.ANIMAL_PRODUCTS.get(prod, {})
			var p_name: String = str(p_def.get("name", prod))
			var star_txt: String = " ★" if is_gold else ""
			var col: Color = Color(1.0, 0.88, 0.25) if is_gold else Color(1.0, 0.96, 0.62)
			_spawn_floating_text(animal.global_position + Vector2(0.0, -14.0), "+1 %s%s" % [p_name, star_txt], col)
			_spawn_particles(animal.global_position + Vector2(0.0, -6.0), col)
			if petted_now:
				var h: int = int(animal.call("get_hearts")) if animal.has_method("get_hearts") else 1
				_show_toast("Coletou %s%s! (Carinho ♥ %d/5)" % [p_name, star_txt, h])
			else:
				_show_toast("Coletou 1 %s%s!" % [p_name, star_txt])
			return

	var hearts_val: int = int(animal.call("get_hearts")) if animal.has_method("get_hearts") else 0
	if petted_now:
		_spawn_floating_text(animal.global_position + Vector2(0.0, -14.0), "♥ %d/5" % hearts_val, Color(1.0, 0.48, 0.65))
		_show_toast("Acariciou %s! (Amizade %d/5)" % [str(animal.call("get_display_name")), hearts_val])
	else:
		var already_msg: String = "%s já deu produto e carinho hoje! (♥ %d/5)" % [str(animal.call("get_display_name")), hearts_val]
		_show_toast(already_msg)
		_spawn_floating_text(animal.global_position + Vector2(0.0, -14.0), "♥", Color(1.0, 0.45, 0.6))


func _find_nearby_animal(world_pos: Vector2, max_dist: float) -> CharacterBody2D:
	var best: CharacterBody2D = null
	var best_dist: float = max_dist
	for animal in _animals:
		if not is_instance_valid(animal):
			continue
		var d: float = world_pos.distance_to(animal.global_position)
		if d <= best_dist:
			best_dist = d
			best = animal
	return best


func _find_animal_at_click(click_pos: Vector2) -> CharacterBody2D:
	var best: CharacterBody2D = null
	var best_dist: float = 16.0
	for animal in _animals:
		if not is_instance_valid(animal):
			continue
		var d: float = click_pos.distance_to(animal.global_position + Vector2(0.0, -5.0))
		if d <= best_dist:
			best_dist = d
			best = animal
	return best


func _get_tool_area_tiles(center_tile: Vector2i, level: int) -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	if level <= 1:
		if center_tile.x >= 0 and center_tile.x < MAP_WIDTH and center_tile.y >= 0 and center_tile.y < MAP_HEIGHT:
			tiles.append(center_tile)
		return tiles

	if level == 2:
		var dir_val: Variant = player.get("facing_dir") if player != null else Vector2i(0, 1)
		var facing: Vector2i = dir_val if dir_val is Vector2i else Vector2i(0, 1)
		var offsets: Array[Vector2i] = []
		if absi(facing.y) >= absi(facing.x):
			offsets = [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0)]
		else:
			offsets = [Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1)]
		for off in offsets:
			var t: Vector2i = center_tile + off
			if t.x >= 0 and t.x < MAP_WIDTH and t.y >= 0 and t.y < MAP_HEIGHT:
				tiles.append(t)
		return tiles

	for dy in range(-1, 2):
		for dx in range(-1, 2):
			var t: Vector2i = center_tile + Vector2i(dx, dy)
			if t.x >= 0 and t.x < MAP_WIDTH and t.y >= 0 and t.y < MAP_HEIGHT:
				tiles.append(t)
	return tiles


func _use_hoe(target_tile: Vector2i) -> void:
	var hoe_lvl: int = maxi(1, int(_game_state.get("hoe_level")))
	var candidate_tiles: Array[Vector2i] = _get_tool_area_tiles(target_tile, hoe_lvl)
	var valid_tiles: Array[Vector2i] = []
	for t in candidate_tiles:
		if not ARABLE_RECT.has_point(t):
			continue
		if obstacle_layer.get_cell_source_id(t) != -1 or _crops.has(t) or _sprinklers.has(t):
			continue
		if soil_layer.get_cell_source_id(t) != -1:
			continue
		valid_tiles.append(t)

	if valid_tiles.is_empty():
		if not ARABLE_RECT.has_point(target_tile):
			_show_toast("Are apenas dentro do canteiro cercado!")
			_play_sfx("play_error")
		return

	var cost: int = 2 if valid_tiles.size() == 1 else (3 if valid_tiles.size() <= 3 else 4)
	if not bool(_game_state.call("consume_stamina", cost)):
		return

	var is_rain: bool = str(_game_state.get("weather")) == "rainy"
	var soil_coord: Vector2i = TILE_SOIL_WET if is_rain else TILE_SOIL_DRY
	for t in valid_tiles:
		soil_layer.set_cell(t, 0, soil_coord)
		_spawn_particles(_tile_center(t), Color(0.58, 0.38, 0.22))
	_play_sfx("play_hoe")


func _use_watering_can(target_tile: Vector2i) -> void:
	var can_lvl: int = maxi(1, int(_game_state.get("can_level")))
	var is_soil_center: bool = soil_layer.get_cell_source_id(target_tile) != -1
	var is_water_target: bool = (
		target_tile == WELL_TILE
		or (ground_layer.get_cell_source_id(target_tile) != -1 and ground_layer.get_cell_atlas_coords(target_tile) == TILE_WATER)
	)
	if is_water_target or (not is_soil_center and _is_near_water_source(player.global_position, target_tile)):
		_refill_watering_can()
		return

	var candidate_tiles: Array[Vector2i] = _get_tool_area_tiles(target_tile, can_lvl)
	var dry_tiles: Array[Vector2i] = []
	var has_any_soil: bool = is_soil_center
	for t in candidate_tiles:
		if soil_layer.get_cell_source_id(t) != -1:
			has_any_soil = true
			if soil_layer.get_cell_atlas_coords(t) == TILE_SOIL_DRY:
				dry_tiles.append(t)

	if not has_any_soil:
		_show_toast("Use o regador em terra arada!")
		_play_sfx("play_error")
		return

	if dry_tiles.is_empty():
		return

	var water_avail: int = int(_game_state.get("water_level"))
	if water_avail <= 0:
		_show_toast("Regador vazio! Encha no poço ou lago.")
		_play_sfx("play_error")
		return

	if not bool(_game_state.call("consume_stamina", 1)):
		return

	var to_water: int = mini(dry_tiles.size(), water_avail)
	if bool(_game_state.call("use_water", to_water)):
		for i in range(to_water):
			var t: Vector2i = dry_tiles[i]
			soil_layer.set_cell(t, 0, TILE_SOIL_WET)
			_spawn_particles(_tile_center(t), Color(0.35, 0.72, 1.0))
		_play_sfx("play_water")


func _use_fishing_rod(target_tile: Vector2i) -> void:
	var water_tile := _find_water_tile_near(target_tile)
	if water_tile.x < 0:
		_show_toast("Mire na água do lago para pescar!")
		_play_sfx("play_error")
		return
	if not bool(_game_state.call("consume_stamina", 3)):
		return

	_play_sfx("play_splash")
	_spawn_particles(_tile_center(water_tile), Color(0.45, 0.85, 1.0))
	_start_fishing_minigame(water_tile)


func _find_water_tile_near(preferred: Vector2i) -> Vector2i:
	if _is_water_cell(preferred):
		return preferred
	var player_tile := _world_to_tile(player.global_position)
	for dy in range(-2, 3):
		for dx in range(-2, 3):
			var c := player_tile + Vector2i(dx, dy)
			if _is_water_cell(c):
				return c
	return Vector2i(-1, -1)


func _is_water_cell(cell: Vector2i) -> bool:
	if cell.x < 0 or cell.x >= MAP_WIDTH or cell.y < 0 or cell.y >= MAP_HEIGHT:
		return false
	return ground_layer.get_cell_source_id(cell) != -1 and ground_layer.get_cell_atlas_coords(cell) == TILE_WATER


func _start_fishing_minigame(water_tile: Vector2i) -> void:
	_fishing_active = true
	_fishing_phase = 0.0
	var bonus_wide: bool = _game_state != null and bool(_game_state.call("has_album_bonus", "fish"))
	var iara_wide: bool = _game_state != null and _game_state.has_method("has_iara_blessing") and bool(_game_state.call("has_iara_blessing"))
	var zone_width_frac: float = (0.38 if bonus_wide else 0.28) + (0.10 if iara_wide else 0.0)
	var center: float = _rng.randf_range(0.28, 0.72)
	_fishing_zone_min = clampf(center - zone_width_frac * 0.5, 0.05, 0.90)
	_fishing_zone_max = clampf(_fishing_zone_min + zone_width_frac, 0.15, 0.95)
	_fishing_speed = _rng.randf_range(1.75, 2.35)

	if _fishing_ui != null:
		_fishing_ui.global_position = player.global_position + Vector2(0.0, -28.0)
		_fishing_ui.visible = true
	if _fishing_zone_rect != null:
		_fishing_zone_rect.position.x = -32.0 + _fishing_zone_min * 64.0
		_fishing_zone_rect.size.x = (_fishing_zone_max - _fishing_zone_min) * 64.0
	if _fishing_bobber != null:
		_fishing_bobber.global_position = _tile_center(water_tile)
		_fishing_bobber.visible = true


func _tick_fishing_minigame(delta: float) -> void:
	_fishing_phase += delta * _fishing_speed
	var pos_frac: float = 0.5 - 0.5 * cos(_fishing_phase * PI)
	if _fishing_marker != null:
		_fishing_marker.position.x = -32.0 + pos_frac * 61.0
	if _fishing_ui != null and player != null:
		_fishing_ui.global_position = player.global_position + Vector2(0.0, -28.0)


func _resolve_fishing_attempt() -> void:
	var pos_frac: float = 0.5 - 0.5 * cos(_fishing_phase * PI)
	var success: bool = pos_frac >= (_fishing_zone_min - 0.03) and pos_frac <= (_fishing_zone_max + 0.03)
	_end_fishing_minigame(success, false)


func _end_fishing_minigame(success: bool, cancelled: bool) -> void:
	_fishing_active = false
	if _fishing_ui != null:
		_fishing_ui.visible = false
	if _fishing_bobber != null:
		_fishing_bobber.visible = false
	if cancelled:
		_show_toast("Pesca cancelada.")
		return
	if not success:
		_play_sfx("play_error")
		_show_toast("O peixe escapou! Tente novamente.")
		return

	var mins: float = float(_game_state.get("time_minutes")) if _game_state != null else 500.0
	var raining: bool = _game_state != null and bool(_game_state.call("is_raining"))
	var roll: float = _rng.randf()
	var fish_id: String = "tilapia"
	if raining or mins >= 1080.0:
		if roll < 0.22:
			fish_id = "golden_carp"
		elif roll < 0.56:
			fish_id = "trout"
		elif roll < 0.85:
			fish_id = "shrimp"
		else:
			fish_id = "tilapia"
	else:
		if roll < 0.06:
			fish_id = "golden_carp"
		elif roll < 0.34:
			fish_id = "trout"
		elif roll < 0.60:
			fish_id = "shrimp"
		else:
			fish_id = "tilapia"

	var is_gold: bool = _rng.randf() < (0.25 if raining else 0.14)
	if _game_state != null and _game_state.has_method("add_fish"):
		_game_state.call("add_fish", fish_id, 1, is_gold)
	_play_sfx("play_fish_catch")
	var f_name: String = str(FarmCatalogScript.FISH.get(fish_id, {}).get("name", fish_id))
	var star_txt: String = " ★" if is_gold else ""
	var col: Color = Color(1.0, 0.88, 0.25) if is_gold else Color(0.55, 0.92, 1.0)
	_spawn_particles(player.global_position + Vector2(0.0, -8.0), col)
	_spawn_floating_text(player.global_position + Vector2(0.0, -18.0), "+1 %s%s!" % [f_name, star_txt], col)
	_show_toast("Pescou 1 %s%s!" % [f_name, star_txt])


func _use_fertilizer(target_tile: Vector2i) -> void:
	if soil_layer.get_cell_source_id(target_tile) == -1:
		_show_toast("Are a terra antes de fertilizar!")
		_play_sfx("play_error")
		return
	if _fertilized_tiles.has(target_tile):
		_show_toast("Este solo já está fertilizado!")
		return
	var supplies: Dictionary = _game_state.get("supplies")
	var qty: int = int(supplies.get("fertilizer", 0))
	if qty <= 0:
		_show_toast("Sem fertilizante! Compre na Loja (B).")
		_play_sfx("play_error")
		return

	supplies["fertilizer"] = qty - 1
	if _game_state.has_signal("inventory_changed"):
		_game_state.inventory_changed.emit()
	_create_fertilizer_sprite(target_tile)
	_play_sfx("play_plant")
	_spawn_particles(_tile_center(target_tile), Color(0.65, 0.95, 0.35))


func _create_fertilizer_sprite(tile: Vector2i) -> void:
	if _fertilized_tiles.has(tile) or _v13_props_texture == null:
		return
	var spr := Sprite2D.new()
	var atlas := AtlasTexture.new()
	atlas.atlas = _v13_props_texture
	atlas.region = Rect2(32, 16, 16, 16)
	spr.texture = atlas
	spr.position = _tile_center(tile)
	spr.z_index = -1
	add_child(spr)
	_fertilized_tiles[tile] = spr


func _plant_seed(target_tile: Vector2i, crop_id: String) -> void:
	if crop_id.is_empty():
		return
	if _sprinklers.has(target_tile):
		_show_toast("Há um aspersor neste canteiro!")
		_play_sfx("play_error")
		return
	if soil_layer.get_cell_source_id(target_tile) == -1:
		_show_toast("Are a terra com a enxada antes de plantar!")
		_play_sfx("play_error")
		return
	if _crops.has(target_tile):
		_show_toast("Já existe uma planta aqui!")
		_play_sfx("play_error")
		return

	var seeds_dict: Dictionary = _game_state.get("seeds")
	var current_seeds: int = int(seeds_dict.get(crop_id, 0))
	if current_seeds <= 0:
		_show_toast("Sem sementes! Compre na Loja (B).")
		_play_sfx("play_error")
		return

	seeds_dict[crop_id] = current_seeds - 1
	if _game_state.has_signal("inventory_changed"):
		_game_state.inventory_changed.emit()

	var spr: Sprite2D = _create_crop_sprite(crop_id, 0, target_tile, true)
	_crops[target_tile] = {
		"crop_id": crop_id,
		"days_grown": 0,
		"stage": 0,
		"sprite": spr,
	}
	_play_sfx("play_plant")


func _place_sprinkler(target_tile: Vector2i) -> void:
	if not ARABLE_RECT.has_point(target_tile):
		_show_toast("Instale o aspersor dentro do canteiro!")
		_play_sfx("play_error")
		return
	if obstacle_layer.get_cell_source_id(target_tile) != -1 or _crops.has(target_tile) or _sprinklers.has(target_tile):
		_show_toast("Espaço ocupado neste canteiro!")
		_play_sfx("play_error")
		return
	if int(_game_state.get("sprinklers_owned")) <= 0:
		_show_toast("Sem aspersores! Compre na Loja (B -> Upgrades).")
		_play_sfx("play_error")
		return

	if not bool(_game_state.call("consume_sprinkler_item")):
		return

	var spr: Sprite2D = _create_sprinkler_sprite(target_tile, true)
	_sprinklers[target_tile] = spr
	_water_sprinkler_area(target_tile)
	_play_sfx("play_water")
	_spawn_floating_text(_tile_center(target_tile) + Vector2(0.0, -12.0), "Aspersor 3x3!", Color(0.55, 0.90, 1.0))
	if _game_state.get("auto_save_enabled"):
		_game_state.call("save_game", false)


func _pickup_sprinkler(target_tile: Vector2i) -> void:
	if not _sprinklers.has(target_tile):
		return
	var spr: Variant = _sprinklers[target_tile]
	if is_instance_valid(spr):
		(spr as Node).queue_free()
	_sprinklers.erase(target_tile)
	if _game_state != null and _game_state.has_method("add_sprinkler"):
		_game_state.call("add_sprinkler", 1)
	_play_sfx("play_click")
	_spawn_floating_text(_tile_center(target_tile) + Vector2(0.0, -10.0), "+1 Aspersor", Color(0.75, 0.92, 1.0))


func _create_sprinkler_sprite(tile: Vector2i, animate_pop: bool) -> Sprite2D:
	var spr := Sprite2D.new()
	if _props_texture != null:
		var atlas := AtlasTexture.new()
		atlas.atlas = _props_texture
		atlas.region = Rect2(32, 48, 16, 16)
		spr.texture = atlas
	spr.position = Vector2(tile.x * TILE_SIZE + 8.0, tile.y * TILE_SIZE + 13.0)
	spr.offset = Vector2(0.0, -5.0)
	add_child(spr)
	if animate_pop:
		spr.scale = Vector2(0.55, 0.55)
		var tw := create_tween()
		tw.tween_property(spr, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return spr


func _water_sprinkler_area(center_tile: Vector2i) -> void:
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			var c: Vector2i = center_tile + Vector2i(dx, dy)
			if soil_layer.get_cell_source_id(c) != -1 and soil_layer.get_cell_atlas_coords(c) == TILE_SOIL_DRY:
				soil_layer.set_cell(c, 0, TILE_SOIL_WET)
				_spawn_particles(_tile_center(c), Color(0.45, 0.80, 1.0))


func _create_crop_sprite(crop_id: String, stage: int, tile: Vector2i, animate_pop: bool) -> Sprite2D:
	var crop_def: Dictionary = _game_state.CROPS.get(crop_id, {})
	var row: int = int(crop_def.get("row", 0))
	var sheet_path: String = str(crop_def.get("sheet_path", "res://assets/sprites/crops_sheet.png"))
	var h_frames: int = maxi(int(crop_def.get("hframes", 5)), 1)
	var v_frames: int = maxi(int(crop_def.get("vframes", 6)), 1)

	var spr := Sprite2D.new()
	if sheet_path.ends_with("turnip_sheet.png") and _turnip_texture != null:
		spr.texture = _turnip_texture
	elif _crops_texture != null:
		spr.texture = _crops_texture
	spr.hframes = h_frames
	spr.vframes = v_frames
	spr.frame_coords = Vector2i(clampi(stage, 0, h_frames - 1), clampi(row, 0, v_frames - 1))
	spr.position = Vector2(tile.x * TILE_SIZE + 8.0, tile.y * TILE_SIZE + 13.0)
	spr.offset = Vector2(0.0, -5.0)
	add_child(spr)

	if animate_pop:
		spr.scale = Vector2(0.55, 0.55)
		var tw := create_tween()
		tw.tween_property(spr, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	return spr


func _compute_crop_stage(crop_id: String, days_grown: int) -> int:
	var days_to_grow: int = maxi(CropDataScript.get_effective_days_to_grow(crop_id, _current_season_id), 1)
	var progress: float = clampf(float(days_grown) / float(days_to_grow), 0.0, 1.0)
	return 4 if days_grown >= days_to_grow else clampi(roundi(progress * 4.0), 0, 3)


func _harvest_crop(target_tile: Vector2i) -> void:
	if not _crops.has(target_tile):
		return
	var crop_info: Dictionary = _crops[target_tile]
	var crop_id: String = str(crop_info["crop_id"])
	var crop_def: Dictionary = _game_state.CROPS.get(crop_id, {})
	var regrow_days: int = int(crop_def.get("regrow_days", 0))
	var days_to_grow: int = maxi(CropDataScript.get_effective_days_to_grow(crop_id, _current_season_id), 1)
	var is_fertilized: bool = _fertilized_tiles.has(target_tile)
	var gold_chance: float = (0.45 if is_fertilized else 0.10) + (0.15 if _capela_blessed_today else 0.0)
	var is_gold: bool = _rng.randf() < gold_chance

	var spr_var: Variant = crop_info.get("sprite")
	if regrow_days > 0:
		var new_days: int = maxi(0, days_to_grow - regrow_days)
		var new_stage: int = mini(_compute_crop_stage(crop_id, new_days), 3)
		crop_info["days_grown"] = new_days
		crop_info["stage"] = new_stage
		if is_instance_valid(spr_var):
			var spr := spr_var as Sprite2D
			spr.frame_coords = Vector2i(new_stage, clampi(int(crop_def.get("row", 0)), 0, spr.vframes - 1))
			spr.scale = Vector2(1.18, 0.85)
			var tw := create_tween()
			tw.tween_property(spr, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		if is_instance_valid(spr_var):
			(spr_var as Node).queue_free()
		_crops.erase(target_tile)
		if is_fertilized:
			var f_spr: Variant = _fertilized_tiles[target_tile]
			if is_instance_valid(f_spr):
				(f_spr as Node).queue_free()
			_fertilized_tiles.erase(target_tile)

	_game_state.call("add_harvested", crop_id, 1, is_gold)
	_play_sfx("play_harvest")
	var crop_name: String = str(crop_def.get("name", crop_id))
	var star_txt: String = " ★" if is_gold else ""
	var center: Vector2 = _tile_center(target_tile)
	var col: Color = Color(1.0, 0.88, 0.25) if is_gold else Color(1.0, 0.94, 0.35)
	_spawn_particles(center, col)
	_spawn_floating_text(center + Vector2(0.0, -10.0), "+1 %s%s" % [crop_name, star_txt], col)


func _sell_at_shipping_bin() -> void:
	if _game_state == null:
		return
	var earned: int = int(_game_state.call("sell_all_harvested"))
	if earned > 0:
		_spawn_floating_text(_tile_center(SHIPPING_BIN_TILE) + Vector2(0.0, -12.0), "+Rs %d" % earned, Color(1.0, 0.88, 0.2))


func _refill_watering_can() -> void:
	if _game_state == null:
		return
	_game_state.call("refill_water")
	var well_center: Vector2 = _tile_center(WELL_TILE)
	var center: Vector2 = well_center if player.global_position.distance_to(well_center) <= 36.0 else player.global_position
	_spawn_particles(center, Color(0.35, 0.78, 1.0))
	_spawn_floating_text(center + Vector2(0.0, -14.0), "Água cheia!", Color(0.55, 0.88, 1.0))


func _on_day_advanced(_new_day: int) -> void:
	_tea_used_today = false
	_fountain_drank_today = false
	_capela_blessed_today = false
	_refresh_tropeiro_presence()
	if _game_state != null:
		var gs_season: String = str(_game_state.get("current_season"))
		if not gs_season.is_empty():
			_current_season_id = gs_season

	for tile in _crops.keys():
		if soil_layer.get_cell_source_id(tile) == -1:
			continue
		if soil_layer.get_cell_atlas_coords(tile) != TILE_SOIL_WET:
			continue

		var crop_info: Dictionary = _crops[tile]
		var crop_id: String = str(crop_info["crop_id"])
		var crop_def: Dictionary = _game_state.CROPS.get(crop_id, {})
		var row: int = int(crop_def.get("row", 0))

		var days_grown: int = int(crop_info["days_grown"]) + 1
		crop_info["days_grown"] = days_grown
		var stage: int = maxi(int(crop_info.get("stage", 0)), _compute_crop_stage(crop_id, days_grown))
		crop_info["stage"] = stage

		var spr: Sprite2D = crop_info.get("sprite")
		if is_instance_valid(spr):
			spr.frame_coords = Vector2i(stage, clampi(row, 0, spr.vframes - 1))

	var is_rain: bool = _game_state != null and str(_game_state.get("weather")) == "rainy"
	for cell in soil_layer.get_used_cells():
		if is_rain:
			soil_layer.set_cell(cell, 0, TILE_SOIL_WET)
		elif soil_layer.get_cell_atlas_coords(cell) == TILE_SOIL_WET:
			soil_layer.set_cell(cell, 0, TILE_SOIL_DRY)

	if not is_rain:
		for sp_tile in _sprinklers.keys():
			_water_sprinkler_area(sp_tile as Vector2i)

	for animal in _animals:
		if is_instance_valid(animal) and animal.has_method("reset_daily"):
			animal.call("reset_daily")

	for villager in _villagers:
		if is_instance_valid(villager) and villager.has_method("reset_daily"):
			villager.call("reset_daily")

	_sync_villagers(true)
	var today_fest: Dictionary = _get_active_festival()
	if not today_fest.is_empty():
		_show_toast("HOJE É DIA DE FESTA! %s na Praça do Coreto (10h–21h)!" % str(today_fest.get("name", "")))
	_sync_weather_fx()
	_update_day_night_tint()


func _on_day_changed(_day: int, _time_minutes: float) -> void:
	_sync_villagers(false)
	_update_day_night_tint()


func _on_season_changed(new_season_id: String, _new_year: int) -> void:
	_apply_season_visuals(new_season_id)


func _apply_season_visuals(season_id: String) -> void:
	_current_season_id = season_id if SeasonDataScript.DEFINITIONS.has(season_id) else "spring"

	var terrain_tex: Texture2D = _seasonal_terrain_textures.get(_current_season_id, null) as Texture2D
	if terrain_tex != null and _shared_atlas_source != null:
		_shared_atlas_source.texture = terrain_tex
		ground_layer.queue_redraw()
		soil_layer.queue_redraw()
		obstacle_layer.queue_redraw()

	var props_tex: Texture2D = _seasonal_props_textures.get(_current_season_id, _props_texture) as Texture2D
	if props_tex != null:
		for atlas in _prop_atlases:
			if atlas != null:
				atlas.atlas = props_tex

	if _season_particles != null:
		var grad := Gradient.new()
		grad.offsets = PackedFloat32Array([0.0, 0.15, 0.85, 1.0])
		match _current_season_id:
			"spring":
				_season_particles.amount = 36
				_season_particles.lifetime = 5.5
				_season_particles.direction = Vector2(0.55, 1.0)
				_season_particles.spread = 28.0
				_season_particles.gravity = Vector2(3.0, 6.0)
				_season_particles.initial_velocity_min = 8.0
				_season_particles.initial_velocity_max = 16.0
				_season_particles.scale_amount_min = 1.4
				_season_particles.scale_amount_max = 2.4
				_season_particles.color = Color(1.0, 0.76, 0.85, 0.90)
				grad.colors = PackedColorArray([
					Color(1.0, 0.76, 0.85, 0.0),
					Color(1.0, 0.82, 0.90, 0.88),
					Color(1.0, 0.95, 0.96, 0.72),
					Color(1.0, 0.95, 0.96, 0.0),
				])
			"summer":
				_season_particles.amount = 20
				_season_particles.lifetime = 4.5
				_season_particles.direction = Vector2(0.8, 0.3)
				_season_particles.spread = 35.0
				_season_particles.gravity = Vector2(2.0, 2.0)
				_season_particles.initial_velocity_min = 6.0
				_season_particles.initial_velocity_max = 12.0
				_season_particles.scale_amount_min = 1.0
				_season_particles.scale_amount_max = 1.6
				_season_particles.color = Color(1.0, 0.94, 0.58, 0.55)
				grad.colors = PackedColorArray([
					Color(1.0, 0.94, 0.58, 0.0),
					Color(1.0, 0.94, 0.58, 0.50),
					Color(1.0, 0.94, 0.58, 0.45),
					Color(1.0, 0.94, 0.58, 0.0),
				])
			"autumn":
				_season_particles.amount = 44
				_season_particles.lifetime = 4.5
				_season_particles.direction = Vector2(-0.7, 1.0)
				_season_particles.spread = 25.0
				_season_particles.gravity = Vector2(-6.0, 14.0)
				_season_particles.initial_velocity_min = 12.0
				_season_particles.initial_velocity_max = 22.0
				_season_particles.scale_amount_min = 1.6
				_season_particles.scale_amount_max = 2.8
				_season_particles.color = Color(0.95, 0.50, 0.20, 0.92)
				grad.colors = PackedColorArray([
					Color(0.96, 0.56, 0.22, 0.0),
					Color(0.95, 0.50, 0.20, 0.92),
					Color(0.82, 0.30, 0.16, 0.82),
					Color(0.82, 0.30, 0.16, 0.0),
				])
			"winter":
				_season_particles.amount = 72
				_season_particles.lifetime = 5.5
				_season_particles.direction = Vector2(-0.2, 1.0)
				_season_particles.spread = 22.0
				_season_particles.gravity = Vector2(-2.0, 12.0)
				_season_particles.initial_velocity_min = 8.0
				_season_particles.initial_velocity_max = 18.0
				_season_particles.scale_amount_min = 1.2
				_season_particles.scale_amount_max = 2.4
				_season_particles.color = Color(0.95, 0.98, 1.0, 0.94)
				grad.colors = PackedColorArray([
					Color(0.95, 0.98, 1.0, 0.0),
					Color(0.96, 0.99, 1.0, 0.92),
					Color(0.84, 0.93, 1.0, 0.80),
					Color(0.84, 0.93, 1.0, 0.0),
				])
		_season_particles.color_ramp = grad
		_season_particles.emitting = true

	for tile in _crops.keys():
		var crop_info: Dictionary = _crops[tile]
		var crop_id: String = str(crop_info.get("crop_id", ""))
		var days_grown: int = int(crop_info.get("days_grown", 0))
		var new_stage: int = maxi(int(crop_info.get("stage", 0)), _compute_crop_stage(crop_id, days_grown))
		crop_info["stage"] = new_stage
		var crop_def: Dictionary = _game_state.CROPS.get(crop_id, {}) if _game_state != null else {}
		var row: int = int(crop_def.get("row", 0))
		var spr: Sprite2D = crop_info.get("sprite")
		if is_instance_valid(spr):
			spr.frame_coords = Vector2i(new_stage, clampi(row, 0, spr.vframes - 1))

	_sync_weather_fx()
	_update_day_night_tint()


func export_world_state() -> Dictionary:
	var tilled_dry: Array = []
	var tilled_wet: Array = []
	for cell in soil_layer.get_used_cells():
		var atlas: Vector2i = soil_layer.get_cell_atlas_coords(cell)
		if atlas == TILE_SOIL_WET:
			tilled_wet.append([cell.x, cell.y])
		elif atlas == TILE_SOIL_DRY:
			tilled_dry.append([cell.x, cell.y])

	var crops_arr: Array = []
	for tile_var in _crops.keys():
		var tile: Vector2i = tile_var as Vector2i
		var info: Dictionary = _crops[tile]
		crops_arr.append({
			"x": tile.x,
			"y": tile.y,
			"crop_id": str(info.get("crop_id", "")),
			"days_grown": int(info.get("days_grown", 0)),
		})

	var fert_arr: Array = []
	for f_tile_var in _fertilized_tiles.keys():
		var f_tile := f_tile_var as Vector2i
		fert_arr.append([f_tile.x, f_tile.y])

	var sprinklers_arr: Array = []
	for tile_var in _sprinklers.keys():
		var tile: Vector2i = tile_var as Vector2i
		sprinklers_arr.append([tile.x, tile.y])

	var animals_arr: Array = []
	var animals_collected: Array = []
	for animal in _animals:
		if is_instance_valid(animal):
			animals_collected.append(bool(animal.get("collected_today")))
			if animal.has_method("export_state"):
				animals_arr.append(animal.call("export_state"))
		else:
			animals_collected.append(false)

	var villagers_arr: Array = []
	for villager in _villagers:
		if is_instance_valid(villager) and villager.has_method("export_state"):
			villagers_arr.append(villager.call("export_state"))

	var p_pos := Vector2(136.0, 118.0)
	if player != null:
		p_pos = player.global_position

	return {
		"tilled_dry": tilled_dry,
		"tilled_wet": tilled_wet,
		"crops": crops_arr,
		"fertilized": fert_arr,
		"sprinklers": sprinklers_arr,
		"animals": animals_arr,
		"animals_collected": animals_collected,
		"villagers": villagers_arr,
		"location": _current_location,
		"player_pos": [p_pos.x, p_pos.y],
		"tea_used_today": _tea_used_today,
		"fountain_drank_today": _fountain_drank_today,
		"capela_blessed_today": _capela_blessed_today,
	}


func _restore_world_state(data: Dictionary) -> void:
	soil_layer.clear()
	for tile_var in _crops.keys():
		var spr: Variant = _crops[tile_var].get("sprite")
		if is_instance_valid(spr):
			(spr as Node).queue_free()
	_crops.clear()

	for f_var in _fertilized_tiles.values():
		if is_instance_valid(f_var):
			(f_var as Node).queue_free()
	_fertilized_tiles.clear()

	for tile_var in _sprinklers.keys():
		var sp_spr: Variant = _sprinklers[tile_var]
		if is_instance_valid(sp_spr):
			(sp_spr as Node).queue_free()
	_sprinklers.clear()

	var dry_list: Variant = data.get("tilled_dry", [])
	if dry_list is Array:
		for pair in dry_list:
			if pair is Array and (pair as Array).size() >= 2:
				var cell := Vector2i(int(pair[0]), int(pair[1]))
				soil_layer.set_cell(cell, 0, TILE_SOIL_DRY)

	var wet_list: Variant = data.get("tilled_wet", [])
	if wet_list is Array:
		for pair in wet_list:
			if pair is Array and (pair as Array).size() >= 2:
				var cell := Vector2i(int(pair[0]), int(pair[1]))
				soil_layer.set_cell(cell, 0, TILE_SOIL_WET)

	var fert_list: Variant = data.get("fertilized", [])
	if fert_list is Array:
		for pair in fert_list:
			if pair is Array and (pair as Array).size() >= 2:
				_create_fertilizer_sprite(Vector2i(int(pair[0]), int(pair[1])))

	var crop_list: Variant = data.get("crops", [])
	if crop_list is Array and _game_state != null:
		for entry in crop_list:
			if not (entry is Dictionary):
				continue
			var entry_dict := entry as Dictionary
			var tile := Vector2i(int(entry_dict.get("x", 0)), int(entry_dict.get("y", 0)))
			var crop_id: String = str(entry_dict.get("crop_id", ""))
			if crop_id.is_empty() or not _game_state.CROPS.has(crop_id):
				continue
			if soil_layer.get_cell_source_id(tile) == -1:
				soil_layer.set_cell(tile, 0, TILE_SOIL_DRY)
			var days_grown: int = maxi(int(entry_dict.get("days_grown", 0)), 0)
			var stage: int = _compute_crop_stage(crop_id, days_grown)
			var spr: Sprite2D = _create_crop_sprite(crop_id, stage, tile, false)
			_crops[tile] = {
				"crop_id": crop_id,
				"days_grown": days_grown,
				"stage": stage,
				"sprite": spr,
			}

	var sprinkler_list: Variant = data.get("sprinklers", [])
	if sprinkler_list is Array:
		for pair in sprinkler_list:
			if pair is Array and (pair as Array).size() >= 2:
				var sp_tile := Vector2i(int(pair[0]), int(pair[1]))
				if ARABLE_RECT.has_point(sp_tile) and not _crops.has(sp_tile):
					_sprinklers[sp_tile] = _create_sprinkler_sprite(sp_tile, false)

	var animals_data: Variant = data.get("animals", [])
	if animals_data is Array and not (animals_data as Array).is_empty():
		for a in _animals:
			if is_instance_valid(a):
				a.queue_free()
		_animals.clear()
		var arr := animals_data as Array
		for i in range(arr.size()):
			if not (arr[i] is Dictionary):
				continue
			var d := arr[i] as Dictionary
			var pos := Vector2(
				_rng.randf_range(ANIMAL_PEN_BOUNDS.position.x + 8.0, ANIMAL_PEN_BOUNDS.end.x - 8.0),
				_rng.randf_range(ANIMAL_PEN_BOUNDS.position.y + 8.0, ANIMAL_PEN_BOUNDS.end.y - 8.0)
			)
			var animal := _spawn_single_animal(str(d.get("type", "chicken")), pos, i)
			if animal != null and animal.has_method("restore_state"):
				animal.call("restore_state", d)
	else:
		var collected_list: Variant = data.get("animals_collected", [])
		if collected_list is Array:
			var arr_c := collected_list as Array
			for i in range(mini(_animals.size(), arr_c.size())):
				var animal: CharacterBody2D = _animals[i]
				if is_instance_valid(animal):
					var val: bool = bool(arr_c[i])
					if animal.has_method("set_collected_today"):
						animal.call("set_collected_today", val)
					else:
						animal.set("collected_today", val)

	var villagers_data: Variant = data.get("villagers", [])
	if villagers_data is Array:
		var by_id: Dictionary = {}
		for entry in (villagers_data as Array):
			if entry is Dictionary:
				var ed := entry as Dictionary
				by_id[str(ed.get("id", ""))] = ed
		for v in _villagers:
			if is_instance_valid(v) and v.has_method("restore_state"):
				var vid: String = str(v.get("npc_id"))
				if by_id.has(vid):
					v.call("restore_state", by_id[vid])

	_tea_used_today = bool(data.get("tea_used_today", false))
	_fountain_drank_today = bool(data.get("fountain_drank_today", false))
	_capela_blessed_today = bool(data.get("capela_blessed_today", false))
	var saved_loc: String = str(data.get("location", "farm"))
	var saved_pos_var: Variant = data.get("player_pos", [])
	var target_pos := Vector2(136.0, 118.0)
	if saved_pos_var is Array and (saved_pos_var as Array).size() >= 2:
		var cand := Vector2(float((saved_pos_var as Array)[0]), float((saved_pos_var as Array)[1]))
		if saved_loc == "house" or (cand.x >= 24.0 and cand.y >= 24.0 and cand.x <= (MAP_WIDTH - 1) * TILE_SIZE and cand.y <= (MAP_HEIGHT - 1) * TILE_SIZE):
			target_pos = cand
	elif saved_loc == "house" and _house_interior != null:
		target_pos = _house_interior.call("get_spawn_world_pos")

	if saved_loc == "house" and _house_interior != null:
		_apply_location_state("house", target_pos, Vector2i(0, -1))
	else:
		_apply_location_state("farm", target_pos, Vector2i(0, 1))
	_sync_villagers(true)


func _update_day_night_tint() -> void:
	if day_night_modulate == null or _game_state == null:
		return
	var mins: float = float(_game_state.get("time_minutes"))
	if _current_location == "house":
		if mins >= 1110.0:
			var t_in: float = clampf((mins - 1110.0) / 300.0, 0.0, 1.0)
			day_night_modulate.color = Color(1.0, 0.98, 0.94).lerp(Color(0.92, 0.85, 0.78), t_in)
		else:
			day_night_modulate.color = Color(1.0, 0.98, 0.94)
		return
	var color := Color.WHITE
	if mins < 480.0:
		var t: float = clampf((mins - 360.0) / 120.0, 0.0, 1.0)
		color = Color(0.92, 0.90, 1.0).lerp(Color.WHITE, t)
	elif mins < 960.0:
		color = Color.WHITE
	elif mins < 1110.0:
		var t: float = clampf((mins - 960.0) / 150.0, 0.0, 1.0)
		color = Color.WHITE.lerp(Color(1.0, 0.78, 0.62), t)
	elif mins < 1260.0:
		var t: float = clampf((mins - 1110.0) / 150.0, 0.0, 1.0)
		color = Color(1.0, 0.78, 0.62).lerp(Color(0.56, 0.58, 0.84), t)
	else:
		var t: float = clampf((mins - 1260.0) / 180.0, 0.0, 1.0)
		color = Color(0.56, 0.58, 0.84).lerp(Color(0.42, 0.45, 0.72), t)

	var season_def: Dictionary = SeasonDataScript.get_definition(_current_season_id)
	var ambient: Color = season_def.get("ambient_tint", Color.WHITE)
	color = color * ambient
	if str(_game_state.get("weather")) == "rainy":
		color = color * Color(0.84, 0.90, 1.0)
	day_night_modulate.color = color

	if _firefly_particles != null:
		var want_fireflies: bool = (_current_season_id == "summer" and mins >= 1050.0 and str(_game_state.get("weather")) != "rainy")
		if _firefly_particles.emitting != want_fireflies:
			_firefly_particles.emitting = want_fireflies

	var want_lamps: bool = (mins >= 1020.0 or mins < 400.0)
	var lamp_alpha: float = clampf((mins - 1020.0) / 120.0, 0.25, 1.0) if mins >= 1020.0 else 0.75
	for glow in _lamp_glows:
		if is_instance_valid(glow):
			glow.visible = want_lamps
			glow.modulate.a = lamp_alpha
	_refresh_window_glows()
	_refresh_folklore_visibility()


func _update_target_cursor(shop_open: bool) -> void:
	if tile_cursor == null or player == null:
		return
	if shop_open or _current_location == "house" or _current_location == "village" or _is_transitioning:
		tile_cursor.visible = false
		for extra in _extra_cursor_rects:
			extra.visible = false
		return

	tile_cursor.visible = true
	_current_target_tile = _get_active_target_tile()
	_target_in_reach = _is_tile_in_reach(_current_target_tile)
	tile_cursor.global_position = Vector2(_current_target_tile.x * TILE_SIZE, _current_target_tile.y * TILE_SIZE)

	if _target_in_reach:
		tile_cursor.default_color = Color(1.0, 0.95, 0.4, 0.92)
		if _cursor_fill != null:
			_cursor_fill.color = Color(1.0, 0.96, 0.55, 0.14)
	else:
		tile_cursor.default_color = Color(1.0, 0.42, 0.42, 0.55)
		if _cursor_fill != null:
			_cursor_fill.color = Color(1.0, 0.35, 0.35, 0.08)

	# Multi-tile preview for upgraded Hoe / Watering Can
	for extra in _extra_cursor_rects:
		extra.visible = false
	if _target_in_reach and _game_state != null:
		var slot: Dictionary = _game_state.call("get_selected_slot")
		var slot_id: String = str(slot.get("id", ""))
		var area_lvl: int = 1
		if slot_id == "hoe":
			area_lvl = int(_game_state.get("hoe_level"))
		elif slot_id == "watering_can":
			area_lvl = int(_game_state.get("can_level"))
		if area_lvl >= 2:
			var area_tiles: Array[Vector2i] = _get_tool_area_tiles(_current_target_tile, area_lvl)
			var idx: int = 0
			for t in area_tiles:
				if t == _current_target_tile or idx >= _extra_cursor_rects.size():
					continue
				if not ARABLE_RECT.has_point(t):
					continue
				var rect_box: ColorRect = _extra_cursor_rects[idx]
				rect_box.global_position = Vector2(t.x * TILE_SIZE + 1, t.y * TILE_SIZE + 1)
				rect_box.color = Color(0.45, 0.85, 1.0, 0.22) if slot_id == "watering_can" else Color(1.0, 0.92, 0.45, 0.20)
				rect_box.visible = true
				idx += 1


func _update_prompt_label(shop_open: bool) -> void:
	if _prompt_label == null or player == null:
		return
	if shop_open or _is_transitioning:
		_prompt_label.visible = false
		return

	var p_pos: Vector2 = player.global_position
	var hint: String = ""
	var anchor: Vector2 = p_pos + Vector2(0.0, -24.0)

	if _current_location == "village":
		if _village_world != null:
			var near_v: Dictionary = _village_world.call("get_nearest_interactable", p_pos)
			if not near_v.is_empty():
				hint = str(near_v.get("prompt", ""))
				anchor = near_v.get("anchor", p_pos + Vector2(0.0, -24.0))
		if hint.is_empty():
			_prompt_label.visible = false
		else:
			_prompt_label.visible = true
			_prompt_label.text = hint
			_prompt_label.reset_size()
			_prompt_label.global_position = anchor - Vector2(_prompt_label.size.x * 0.5, 0.0)
		return

	if _current_location == "house":
		if _house_interior != null:
			var near_obj: Dictionary = _house_interior.call("get_nearest_interactable", p_pos)
			if not near_obj.is_empty():
				hint = str(near_obj.get("prompt", ""))
				anchor = near_obj.get("anchor", p_pos + Vector2(0.0, -20.0))
		if hint.is_empty():
			_prompt_label.visible = false
		else:
			_prompt_label.visible = true
			_prompt_label.text = hint
			_prompt_label.reset_size()
			_prompt_label.global_position = anchor - Vector2(_prompt_label.size.x * 0.5, 0.0)
		return

	var nearby_villager: CharacterBody2D = _find_nearby_villager(p_pos, VILLAGER_INTERACT_REACH)
	var nearby_animal: CharacterBody2D = _find_nearby_animal(p_pos, ANIMAL_INTERACT_REACH)
	var nearby_machine: String = _find_nearby_machine(p_pos)

	var nearby_folklore_id: String = ""
	var nearby_folklore_pos: Vector2 = Vector2.ZERO
	for fid_var in _folklore_nodes.keys():
		var fid: String = str(fid_var)
		var f_body: StaticBody2D = _folklore_nodes[fid] as StaticBody2D
		if f_body != null and is_instance_valid(f_body) and f_body.visible:
			if p_pos.distance_to(f_body.global_position) <= 34.0:
				nearby_folklore_id = fid
				nearby_folklore_pos = f_body.global_position
				break

	if nearby_villager != null:
		var v_name: String = str(nearby_villager.get("npc_name"))
		var v_role: String = str(nearby_villager.get("role"))
		var h_txt: String = str(nearby_villager.call("get_hearts_text")) if nearby_villager.has_method("get_hearts_text") else ""
		var suffix: String = (" " + h_txt) if not h_txt.is_empty() else ""
		var gift_part: String = " | [G] Presentear" if not bool(nearby_villager.get("gifted_today")) else ""
		hint = "[F] %s (%s)%s%s" % [v_name, v_role, suffix, gift_part]
		anchor = nearby_villager.global_position + Vector2(0.0, -24.0)
	elif not nearby_folklore_id.is_empty():
		var f_info: Dictionary = StoryDataScript.FOLKLORE_INFO.get(nearby_folklore_id, {})
		hint = "[F] Conversar com %s" % str(f_info.get("name", nearby_folklore_id))
		anchor = nearby_folklore_pos + Vector2(0.0, -24.0)
	elif p_pos.distance_to(HOUSE_DOOR_POS) <= 28.0:
		hint = "[F] Entrar na Casa"
		anchor = HOUSE_DOOR_POS + Vector2(0.0, -24.0)
	elif p_pos.distance_to(_tile_center(SHIPPING_BIN_TILE)) <= 28.0:
		hint = "[F] Vender"
		anchor = _tile_center(SHIPPING_BIN_TILE) + Vector2(0.0, -20.0)
	elif p_pos.distance_to(_tile_center(SHOP_SIGN_TILE)) <= 28.0:
		hint = "[F] Loja"
		anchor = _tile_center(SHOP_SIGN_TILE) + Vector2(0.0, -20.0)
	elif p_pos.distance_to(_tile_center(VENDA_TILE)) <= 32.0:
		hint = "[F] Venda Secos & Molhados"
		anchor = _tile_center(VENDA_TILE) + Vector2(0.0, -26.0)
	elif p_pos.distance_to(_tile_center(VILLAGE_WELL_TILE)) <= 30.0:
		hint = "[F] Poço da Vila (Encher Água)"
		anchor = _tile_center(VILLAGE_WELL_TILE) + Vector2(0.0, -22.0)
	elif p_pos.distance_to(_tile_center(ORDER_BOARD_TILE)) <= 28.0:
		hint = "[F] Encomendas"
		anchor = _tile_center(ORDER_BOARD_TILE) + Vector2(0.0, -20.0)
	elif not nearby_machine.is_empty():
		var m_def: Dictionary = FarmCatalogScript.MACHINES[nearby_machine]
		var st: Dictionary = _game_state.get("machine_states").get(nearby_machine, {})
		if bool(st.get("ready", false)):
			hint = "[F] Coletar %s" % str(m_def.get("name", ""))
		elif bool(st.get("busy", false)):
			hint = "Produzindo..."
		elif nearby_machine == "bee_hive":
			hint = "Apiário (Manhã)"
		else:
			hint = "[F] Usar %s" % str(m_def.get("name", ""))
		anchor = _tile_center(m_def["tile"]) + Vector2(0.0, -20.0)
	elif p_pos.distance_to(_tile_center(WELL_TILE)) <= 28.0:
		hint = "[F] Encher Água"
		anchor = _tile_center(WELL_TILE) + Vector2(0.0, -20.0)
	elif p_pos.distance_to(_tile_center(FOUNTAIN_TILE)) <= 32.0:
		hint = "[F] Beber / Encher Água" if not _fountain_drank_today else "[F] Encher Água"
		anchor = _tile_center(FOUNTAIN_TILE) + Vector2(0.0, -24.0)
	elif p_pos.distance_to(_tile_center(CAPELA_TILE)) <= 34.0:
		hint = "[F] Bênção da Capela (+15% Ouro)" if not _capela_blessed_today else "[F] Orar na Capela"
		anchor = _tile_center(CAPELA_TILE) + Vector2(0.0, -28.0)
	elif absf(p_pos.x - 288.0) <= 26.0 and p_pos.y >= 336.0:
		hint = "[↓] Atravessar Porteira -> Vila Colonial"
		anchor = Vector2(288.0, 340.0)
	elif _tropeiro_present and p_pos.distance_to(_tile_center(TROPEIRO_TILE)) <= 34.0:
		var feat: Dictionary = _game_state.call("get_tropeiro_featured_item") if _game_state != null else {}
		var feat_name: String = str(feat.get("name", "Artesanal"))
		hint = "[F] Tropeiro: +50%% %s (+25%% resto)" % feat_name
		anchor = _tile_center(TROPEIRO_TILE) + Vector2(0.0, -24.0)
	elif p_pos.distance_to(TERREIRO_POS) <= 44.0:
		var harv_val: Variant = _game_state.get("harvested") if _game_state != null else {}
		var harv: Dictionary = harv_val if harv_val is Dictionary else {}
		if int(harv.get("strawberry", 0)) >= 2:
			hint = "[F] Secar Tabaco -> Rolo de Fumo"
		elif int(harv.get("turnip", 0)) >= 2:
			hint = "[F] Secar Café -> Saca de Café"
		else:
			hint = "[F] Terreiro (2 Tabaco ou 2 Café)"
		anchor = TERREIRO_POS + Vector2(0.0, -24.0)
	elif p_pos.distance_to(_tile_center(CASA_FARINHA_TILE)) <= 36.0:
		hint = "[F] Fazer Farinha (2 Mandioca)"
		anchor = _tile_center(CASA_FARINHA_TILE) + Vector2(0.0, -24.0)
	elif p_pos.distance_to(_tile_center(PAIOL_TILE)) <= 34.0:
		hint = "[F] Ver Paiol"
		anchor = _tile_center(PAIOL_TILE) + Vector2(0.0, -24.0)
	elif nearby_animal != null:
		if nearby_animal.has_method("can_collect") and bool(nearby_animal.call("can_collect")):
			var a_type: String = str(nearby_animal.get("animal_type"))
			match a_type:
				"cow":
					hint = "[F] Ordenhar Vaca"
				"sheep":
					hint = "[F] Tosquiar Lã"
				"pig":
					hint = "[F] Coletar Trufa"
				_:
					hint = "[F] Coletar Ovo"
		else:
			hint = "[F] Acariciar"
		anchor = nearby_animal.global_position + Vector2(0.0, -24.0)
	elif _sprinklers.has(_current_target_tile) and _target_in_reach:
		hint = "[F] Recolher Aspersor"
		anchor = _tile_center(_current_target_tile) + Vector2(0.0, -18.0)
	elif _crops.has(_current_target_tile) and int(_crops[_current_target_tile]["stage"]) == 4 and _target_in_reach:
		hint = "[E/F] Colher"
		anchor = _tile_center(_current_target_tile) + Vector2(0.0, -18.0)

	if hint.is_empty():
		_prompt_label.visible = false
	else:
		_prompt_label.visible = true
		_prompt_label.text = hint
		_prompt_label.reset_size()
		_prompt_label.global_position = anchor - Vector2(_prompt_label.size.x * 0.5, 0.0)


func _get_active_target_tile() -> Vector2i:
	if _mouse_active:
		var mouse_tile: Vector2i = _world_to_tile(get_global_mouse_position())
		if _is_tile_in_reach(mouse_tile):
			return mouse_tile
	return _get_keyboard_target_tile()


func _get_keyboard_target_tile() -> Vector2i:
	var player_tile: Vector2i = _world_to_tile(player.global_position)
	var dir_val: Variant = player.get("facing_dir")
	var facing: Vector2i = dir_val if dir_val is Vector2i else Vector2i(0, 1)
	var candidate: Vector2i = player_tile + facing
	return Vector2i(
		clampi(candidate.x, 0, MAP_WIDTH - 1),
		clampi(candidate.y, 0, MAP_HEIGHT - 1)
	)


func _is_tile_in_reach(tile: Vector2i) -> bool:
	if tile.x < 0 or tile.x >= MAP_WIDTH or tile.y < 0 or tile.y >= MAP_HEIGHT:
		return false
	var player_tile: Vector2i = _world_to_tile(player.global_position)
	var diff: Vector2i = tile - player_tile
	return absi(diff.x) <= REACH_TILES and absi(diff.y) <= REACH_TILES


func _is_near_water_source(world_pos: Vector2, target_tile: Vector2i) -> bool:
	if (
		world_pos.distance_to(_tile_center(WELL_TILE)) <= 30.0
		or world_pos.distance_to(_tile_center(VILLAGE_WELL_TILE)) <= 30.0
		or world_pos.distance_to(_tile_center(FOUNTAIN_TILE)) <= 32.0
	):
		return true
	if target_tile == WELL_TILE or target_tile == VILLAGE_WELL_TILE or target_tile == FOUNTAIN_TILE:
		return true
	var player_tile: Vector2i = _world_to_tile(world_pos)
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			var c: Vector2i = player_tile + Vector2i(dx, dy)
			if ground_layer.get_cell_source_id(c) != -1 and ground_layer.get_cell_atlas_coords(c) == TILE_WATER:
				return true
	return false


func _world_to_tile(world_pos: Vector2) -> Vector2i:
	return ground_layer.local_to_map(ground_layer.to_local(world_pos))


func _tile_center(tile: Vector2i) -> Vector2:
	return Vector2(tile.x * TILE_SIZE + TILE_SIZE * 0.5, tile.y * TILE_SIZE + TILE_SIZE * 0.5)


func _is_shop_open() -> bool:
	return hud != null and hud.has_method("is_shop_open") and bool(hud.call("is_shop_open"))


func _show_toast(msg: String) -> void:
	if _game_state != null and _game_state.has_method("emit_toast"):
		_game_state.call("emit_toast", msg)


func _play_sfx(method_name: String, args: Array = []) -> void:
	var audio: Node = get_node_or_null("/root/AudioManager")
	if audio != null and audio.has_method(method_name):
		audio.callv(method_name, args)


func _spawn_floating_text(world_pos: Vector2, text: String, color: Color) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.z_index = 30
	lbl.add_theme_font_size_override("font_size", 8)
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_color_override("font_outline_color", Color(0.1, 0.07, 0.04, 0.95))
	lbl.add_theme_constant_override("outline_size", 3)
	add_child(lbl)
	lbl.reset_size()
	lbl.global_position = world_pos - Vector2(lbl.size.x * 0.5, 0.0)

	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(lbl, "position:y", lbl.position.y - 14.0, 0.85).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.85).set_delay(0.2)
	tw.chain().tween_callback(lbl.queue_free)


func _spawn_particles(world_pos: Vector2, color: Color) -> void:
	var p := CPUParticles2D.new()
	p.global_position = world_pos
	p.z_index = 15
	p.emitting = true
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = 7
	p.lifetime = 0.35
	p.direction = Vector2(0, -1)
	p.spread = 150.0
	p.gravity = Vector2(0, 90)
	p.initial_velocity_min = 18.0
	p.initial_velocity_max = 38.0
	p.scale_amount_min = 1.5
	p.scale_amount_max = 2.5
	p.color = color
	add_child(p)
	get_tree().create_timer(0.5).timeout.connect(p.queue_free)


# --- Casa do Personagem (Entrada, Saída e Interações no Interior) ---

func is_inside_house() -> bool:
	return _current_location == "house"


func _setup_transition_overlay() -> void:
	var layer := CanvasLayer.new()
	layer.name = "TransitionLayer"
	layer.layer = 20
	add_child(layer)

	_transition_rect = ColorRect.new()
	_transition_rect.name = "FadeOverlay"
	_transition_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_transition_rect.color = Color(0.05, 0.03, 0.02, 1.0)
	_transition_rect.modulate.a = 0.0
	_transition_rect.visible = false
	_transition_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_transition_rect)


func _setup_house_interior() -> void:
	if _house_interior_scene == null:
		return
	var instance := _house_interior_scene.instantiate() as Node2D
	if instance == null:
		return
	instance.name = "HouseInterior"
	instance.position = HOUSE_ORIGIN
	add_child(instance)
	_house_interior = instance


func _set_exterior_active(active: bool) -> void:
	ground_layer.visible = active
	soil_layer.visible = active
	obstacle_layer.visible = active
	ground_layer.collision_enabled = active
	obstacle_layer.collision_enabled = active

	for prop in _exterior_props:
		if is_instance_valid(prop) and prop is Node2D:
			(prop as Node2D).visible = active
			prop.process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED

	if _tropeiro_body != null and is_instance_valid(_tropeiro_body):
		_tropeiro_body.visible = active and _tropeiro_present

	for tile_var in _crops.keys():
		var spr: Variant = _crops[tile_var].get("sprite")
		if is_instance_valid(spr) and spr is Node2D:
			(spr as Node2D).visible = active

	for f_spr in _fertilized_tiles.values():
		if is_instance_valid(f_spr) and f_spr is Node2D:
			(f_spr as Node2D).visible = active

	for sp_spr in _sprinklers.values():
		if is_instance_valid(sp_spr) and sp_spr is Node2D:
			(sp_spr as Node2D).visible = active

	for m_entry in _machines.values():
		var m_body: Variant = m_entry.get("body")
		if is_instance_valid(m_body) and m_body is Node2D:
			(m_body as Node2D).visible = active
			m_body.process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED

	if _weather_fx != null and is_instance_valid(_weather_fx):
		_weather_fx.visible = active
	if _festival_decor != null and is_instance_valid(_festival_decor):
		_festival_decor.visible = active and bool(_festival_decor.get("active"))
	if _season_particles != null and is_instance_valid(_season_particles):
		_season_particles.visible = active
	if _firefly_particles != null and is_instance_valid(_firefly_particles):
		_firefly_particles.visible = active

	for animal in _animals:
		if is_instance_valid(animal):
			animal.visible = active
			animal.process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED

	for villager in _villagers:
		if is_instance_valid(villager):
			villager.visible = active
			villager.process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED

	if _house_interior != null and is_instance_valid(_house_interior):
		var show_house: bool = (_current_location == "house")
		_house_interior.visible = show_house
		_house_interior.process_mode = Node.PROCESS_MODE_INHERIT if show_house else Node.PROCESS_MODE_DISABLED


func _apply_location_state(loc: String, target_pos: Vector2, facing: Vector2i) -> void:
	_current_location = loc
	var inside_house: bool = (loc == "house")
	var in_village: bool = (loc == "village")
	_set_exterior_active(loc == "farm")
	if _village_world != null and is_instance_valid(_village_world):
		_village_world.visible = in_village
		_village_world.process_mode = Node.PROCESS_MODE_INHERIT if in_village else Node.PROCESS_MODE_DISABLED

	if player != null:
		var target_parent: Node = self
		if inside_house and _house_interior != null:
			target_parent = _house_interior
		elif in_village and _village_world != null:
			target_parent = _village_world
		if player.get_parent() != target_parent:
			player.reparent(target_parent, true)
		player.global_position = target_pos
		player.set("facing_dir", facing)
		if player.has_method("_update_animation"):
			player.call("_update_animation", 0.0, Vector2.ZERO)
		if inside_house and _house_interior != null:
			var cam_b: Rect2i = _house_interior.call("get_camera_bounds")
			var walk_b: Rect2 = _house_interior.call("get_walk_bounds")
			if player.has_method("set_camera_and_walk_bounds"):
				player.call("set_camera_and_walk_bounds", cam_b, walk_b)
		elif in_village and _village_world != null:
			var v_cam: Rect2i = _village_world.call("get_camera_bounds")
			if player.has_method("set_camera_limits"):
				player.call("set_camera_limits", v_cam)
		elif player.has_method("set_camera_limits"):
			player.call("set_camera_limits", Rect2i(0, 0, MAP_WIDTH * TILE_SIZE, MAP_HEIGHT * TILE_SIZE))
		if player.has_method("snap_camera"):
			player.call("snap_camera")

	_update_day_night_tint()


func _setup_village_world() -> void:
	if _village_world != null and is_instance_valid(_village_world):
		_village_world.queue_free()
	_village_world = VillageWorldScript.new()
	_village_world.name = "VillageWorld"
	_village_world.position = VILLAGE_ORIGIN
	_village_world.visible = false
	_village_world.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(_village_world)


func _enter_village(instant: bool = false) -> void:
	if _village_world == null or (_is_transitioning and not instant):
		return
	var spawn_pos: Vector2 = _village_world.call("get_spawn_world_pos")
	if instant:
		_apply_location_state("village", spawn_pos, Vector2i(0, 1))
		_door_cooldown = 0.45
		return
	if _current_location == "village":
		return
	_play_sfx("play_door")
	_run_fade_transition(func() -> void:
		_apply_location_state("village", spawn_pos, Vector2i(0, 1))
		_show_toast("Bem-vindo à Vila Colonial! Converse com os moradores com [F].")
	)


func _exit_village(instant: bool = false) -> void:
	if _is_transitioning and not instant:
		return
	if instant:
		_apply_location_state("farm", VILLAGE_EXIT_FARM_POS, Vector2i(0, -1))
		_door_cooldown = 0.45
		return
	if _current_location != "village":
		return
	_play_sfx("play_door")
	_run_fade_transition(func() -> void:
		_apply_location_state("farm", VILLAGE_EXIT_FARM_POS, Vector2i(0, -1))
	)


func _handle_village_interact() -> void:
	if _village_world == null or player == null:
		return
	var near_v: Dictionary = _village_world.call("get_nearest_interactable", player.global_position)
	if near_v.is_empty():
		return
	var kind: String = str(near_v.get("kind", ""))
	var obj_id: String = str(near_v.get("id", ""))
	if kind == "npc":
		_interact_with_story_entity(obj_id)
	elif kind == "fountain":
		_refill_watering_can()


func _run_fade_transition(on_midpoint: Callable) -> void:
	if _transition_rect == null or not is_inside_tree():
		on_midpoint.call()
		return
	_is_transitioning = true
	if player != null:
		player.set("can_move", false)
		player.set("external_input_dir", Vector2.ZERO)

	_transition_rect.visible = true
	_transition_rect.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_transition_rect, "modulate:a", 1.0, 0.14)
	tw.tween_callback(on_midpoint)
	tw.tween_interval(0.05)
	tw.tween_property(_transition_rect, "modulate:a", 0.0, 0.16)
	tw.tween_callback(func() -> void:
		_transition_rect.visible = false
		_is_transitioning = false
		_door_cooldown = 0.45
	)


func _enter_house(instant: bool = false) -> void:
	if _house_interior == null or (_is_transitioning and not instant):
		return
	var spawn_pos: Vector2 = _house_interior.call("get_spawn_world_pos")
	if instant:
		_apply_location_state("house", spawn_pos, Vector2i(0, -1))
		_door_cooldown = 0.45
		return
	if _current_location == "house":
		return
	_play_sfx("play_door")
	_run_fade_transition(func() -> void:
		_apply_location_state("house", spawn_pos, Vector2i(0, -1))
		if not _entered_house_once:
			_entered_house_once = true
			_show_toast("Bem-vindo à sua casa! Use F nos móveis ou saia pela porta.")
	)


func _exit_house(instant: bool = false) -> void:
	if _is_transitioning and not instant:
		return
	if instant:
		_apply_location_state("farm", HOUSE_EXIT_SPAWN_POS, Vector2i(0, 1))
		_door_cooldown = 0.45
		return
	if _current_location == "farm":
		return
	_play_sfx("play_door")
	_run_fade_transition(func() -> void:
		_apply_location_state("farm", HOUSE_EXIT_SPAWN_POS, Vector2i(0, 1))
	)


func _sleep_in_bed() -> void:
	if _game_state == null or _house_interior == null or _is_transitioning:
		return
	var wake_pos: Vector2 = _house_interior.call("get_bed_wake_world_pos")
	_run_fade_transition(func() -> void:
		_game_state.call("advance_day")
		if player != null:
			player.global_position = wake_pos
			player.set("facing_dir", Vector2i(0, 1))
			if player.has_method("_update_animation"):
				player.call("_update_animation", 0.0, Vector2.ZERO)
			if player.has_method("snap_camera"):
				player.call("snap_camera")
	)


func _handle_house_interact(allow_exit: bool) -> void:
	if _house_interior == null or player == null:
		return
	var near_obj: Dictionary = _house_interior.call("get_nearest_interactable", player.global_position)
	if near_obj.is_empty():
		return
	var obj_id: String = str(near_obj.get("id", ""))
	if obj_id == "exit" and not allow_exit:
		return
	_interact_with_house_object(near_obj)


func _handle_house_click(click_pos: Vector2) -> void:
	if _house_interior == null or player == null:
		return
	var clicked_obj: Dictionary = _house_interior.call("find_interactable_at_click", click_pos)
	if clicked_obj.is_empty():
		return
	var world_pos: Vector2 = clicked_obj.get("world_pos", click_pos)
	var reach: float = float(clicked_obj.get("radius", 30.0)) + 12.0
	if player.global_position.distance_to(world_pos) <= reach:
		_interact_with_house_object(clicked_obj)
	else:
		_show_toast("Aproxime-se mais!")
		_play_sfx("play_error")


func _interact_with_house_object(obj: Dictionary) -> void:
	if _game_state == null or player == null:
		return
	var obj_id: String = str(obj.get("id", ""))
	var world_pos: Vector2 = obj.get("world_pos", player.global_position)
	if player.has_method("set_facing_toward"):
		player.call("set_facing_toward", world_pos)

	match obj_id:
		"exit":
			_exit_house()
		"bed":
			_sleep_in_bed()
		"stove":
			if _tea_used_today:
				_play_sfx("play_cozy")
				_show_toast("Você já tomou o chá da fazenda hoje!")
			else:
				_tea_used_today = true
				var cur_stam: int = int(_game_state.get("stamina"))
				var max_stam: int = int(_game_state.get("max_stamina"))
				var new_stam: int = mini(max_stam, cur_stam + 20)
				_game_state.set("stamina", new_stam)
				if _game_state.has_signal("stamina_changed"):
					_game_state.stamina_changed.emit(new_stam, max_stam)
				_play_sfx("play_cozy")
				_spawn_particles(world_pos + Vector2(0.0, -8.0), Color(1.0, 0.85, 0.45))
				_spawn_floating_text(world_pos + Vector2(0.0, -16.0), "+20 Energia", Color(0.65, 1.0, 0.58))
				_show_toast("Chá quentinho da fazenda! +20 Energia.")
		"fireplace":
			_play_sfx("play_cozy")
			_spawn_particles(world_pos + Vector2(0.0, -8.0), Color(1.0, 0.58, 0.22))
			_spawn_floating_text(world_pos + Vector2(0.0, -18.0), "♥ Aconchego!", Color(1.0, 0.65, 0.35))
			_show_toast("Lareira quentinha crepitando...")
		"bookshelf":
			_play_sfx("play_click")
			if hud != null and hud.has_method("open_storybook"):
				hud.call("open_storybook")
			else:
				_show_toast(FARM_GUIDE_TIPS[_guide_tip_index])
				_guide_tip_index = (_guide_tip_index + 1) % FARM_GUIDE_TIPS.size()
		"desk":
			_play_sfx("play_cozy")
			_game_state.call("save_game", true)
			_spawn_floating_text(world_pos + Vector2(0.0, -14.0), "Salvo!", Color(1.0, 0.94, 0.55))
		"chest":
			_play_sfx("play_click")
			var seeds_dict: Dictionary = _game_state.get("seeds")
			var total_seeds: int = 0
			for q in seeds_dict.values():
				total_seeds += int(q)
			var basket_cnt: int = int(_game_state.call("get_total_basket_count"))
			var basket_val: int = int(_game_state.call("get_total_basket_value"))
			_show_toast("Baú: %d sementes | Cesta: %d itens ($%d)" % [total_seeds, basket_cnt, basket_val])
		"table":
			_play_sfx("play_cozy")
			_spawn_floating_text(world_pos + Vector2(0.0, -16.0), "♥ Pão & Maçã", Color(1.0, 0.92, 0.55))
			_show_toast("Mesa posta com pão caseiro e maçãs frescas!")


# --- Demo IA / Auto-Farmer Mode (P) ---

func is_demo_active() -> bool:
	return demo_active


func set_demo_active(active: bool) -> void:
	if demo_active == active:
		return
	demo_active = active
	if demo_active:
		if _is_shop_open() and hud != null:
			if hud.has_method("close_all_modals"):
				hud.call("close_all_modals")
			elif hud.has_method("toggle_shop"):
				hud.call("toggle_shop")
		_mouse_active = false
		_reset_demo_ai_state()
		_show_toast("Modo Auto (Demo IA) ativado! (P para sair)")
	else:
		if player != null:
			player.set("external_input_dir", Vector2.ZERO)
		_reset_demo_ai_state()
	demo_mode_changed.emit(demo_active)


func toggle_demo_mode() -> bool:
	set_demo_active(not demo_active)
	return demo_active


func _reset_demo_ai_state() -> void:
	_demo_waypoints.clear()
	_demo_action = ""
	_demo_target_slot = -1
	_demo_target_animal = null
	_demo_target_machine = ""
	_demo_pause_timer = 0.0
	_demo_stuck_timer = 0.0
	_demo_stuck_strikes = 0
	_demo_last_pos = player.global_position if player != null else Vector2.ZERO


func _tick_demo_ai(delta: float) -> void:
	if _demo_pause_timer > 0.0:
		_demo_pause_timer -= delta
		player.set("external_input_dir", Vector2.ZERO)
		return

	if _demo_action.is_empty():
		_plan_next_demo_task()
		if _demo_action.is_empty():
			player.set("external_input_dir", Vector2.ZERO)
			return

	if _demo_action == "animal":
		if not is_instance_valid(_demo_target_animal):
			_demo_waypoints.clear()
			_demo_action = ""
			return
		if _demo_waypoints.size() == 1:
			_demo_waypoints[0] = _demo_target_animal.global_position
			if player.global_position.distance_to(_demo_target_animal.global_position) <= 22.0:
				_demo_waypoints.clear()

	if not _demo_waypoints.is_empty():
		var wp: Vector2 = _demo_waypoints[0]
		var diff: Vector2 = wp - player.global_position
		if diff.length() <= 4.5:
			_demo_waypoints.remove_at(0)
			_demo_stuck_strikes = 0
		else:
			player.set("external_input_dir", diff.normalized())
			var moved: float = player.global_position.distance_to(_demo_last_pos)
			if moved < 15.0 * delta:
				_demo_stuck_timer += delta
				if _demo_stuck_timer >= 1.1:
					_demo_stuck_strikes += 1
					if _demo_stuck_strikes >= 2:
						var nudge: Vector2 = Vector2(DEMO_GARDEN_CORRIDOR_WP.x, DEMO_CORRIDOR_Y) - player.global_position
						if nudge.length_squared() > 1.0:
							player.set("external_input_dir", nudge.normalized())
						_demo_stuck_strikes = 0
					_demo_waypoints.clear()
					_demo_action = ""
					_demo_target_slot = -1
					_demo_target_animal = null
					_demo_target_machine = ""
					_demo_stuck_timer = 0.0
					_demo_pause_timer = 0.14
			else:
				_demo_stuck_timer = 0.0
			_demo_last_pos = player.global_position
			if not _demo_waypoints.is_empty():
				return

	player.set("external_input_dir", Vector2.ZERO)
	_execute_demo_action()
	_demo_action = ""
	_demo_target_slot = -1
	_demo_target_animal = null
	_demo_target_machine = ""
	_demo_stuck_timer = 0.0
	_demo_stuck_strikes = 0
	_demo_pause_timer = 0.22


func _plan_next_demo_task() -> void:
	if _game_state == null or player == null:
		return

	var p_pos: Vector2 = player.global_position
	if _current_location == "house":
		_demo_action = "exit_house"
		if _house_interior != null:
			_demo_waypoints = [_house_interior.call("get_exit_waypoint")]
		else:
			_demo_waypoints = []
		return
	var stamina: int = int(_game_state.get("stamina"))
	var water_level: int = int(_game_state.get("water_level"))
	var money: int = int(_game_state.get("money"))
	var seeds_dict: Dictionary = _game_state.get("seeds")
	var raining: bool = bool(_game_state.call("is_raining"))

	# 1. Harvest mature crops (stage == 4)
	var mature_tile := _find_closest_crop_tile(p_pos, true, false)
	if mature_tile.x >= 0:
		_demo_action = "harvest"
		_demo_target_tile = mature_tile
		_demo_waypoints = _build_demo_path(p_pos, _garden_stand_pos(mature_tile), "garden")
		return

	# Check if DEMO_PLOTS still has pending hoe/plant work before watering newly planted stage-0 seeds
	var pending_hoe_tile := _find_demo_plot_to_hoe(p_pos, stamina)
	var pending_plant: Dictionary = _find_demo_plot_to_plant(p_pos, seeds_dict)
	var has_pending_farm_setup: bool = (pending_hoe_tile.x >= 0) or (not pending_plant.is_empty())

	# 2. Water existing planted dry crops (skipped when raining!)
	if not raining:
		var dry_crop_tile := _find_closest_crop_tile(p_pos, false, true, has_pending_farm_setup)
		if dry_crop_tile.x >= 0 and stamina >= 1:
			if water_level <= 2:
				_demo_action = "refill"
				_demo_target_tile = WELL_TILE
				_demo_target_slot = 1
				_demo_waypoints = _build_demo_path(p_pos, DEMO_WELL_WP, "outside")
				return
			_demo_action = "water"
			_demo_target_tile = dry_crop_tile
			_demo_target_slot = 1
			_demo_waypoints = _build_demo_path(p_pos, _garden_stand_pos(dry_crop_tile), "garden")
			return

	# 3. Collect ready machines or start idle machines with available ingredients
	var ready_m := _find_demo_machine_task()
	if not ready_m.is_empty():
		var m_def: Dictionary = FarmCatalogScript.MACHINES[ready_m]
		var m_tile: Vector2i = m_def["tile"]
		_demo_action = "machine"
		_demo_target_machine = ready_m
		_demo_target_tile = m_tile
		_demo_waypoints = _build_demo_path(p_pos, Vector2(float(m_tile.x) * TILE_SIZE + 8.0, DEMO_CORRIDOR_Y), "outside")
		return

	# 4. Collect / pet ready animals (Ovo / Leite / Lã / Trufa)
	var ready_animal := _find_closest_ready_animal(p_pos)
	if ready_animal != null:
		_demo_action = "animal"
		_demo_target_animal = ready_animal
		_demo_waypoints = _build_demo_path(p_pos, ready_animal.global_position, "pen")
		return

	# 5. Till & plant up to 12 starter plots in DEMO_PLOTS
	if stamina >= 10:
		if pending_hoe_tile.x >= 0:
			_demo_action = "hoe"
			_demo_target_tile = pending_hoe_tile
			_demo_target_slot = 0
			_demo_waypoints = _build_demo_path(p_pos, _garden_stand_pos(pending_hoe_tile), "garden")
			return
		if not pending_plant.is_empty():
			var plant_tile: Vector2i = pending_plant["tile"]
			_demo_action = "plant"
			_demo_target_tile = plant_tile
			_demo_target_slot = int(pending_plant["slot"])
			_demo_waypoints = _build_demo_path(p_pos, _garden_stand_pos(plant_tile), "garden")
			return

	# After setup finishes, catch any remaining dry crops
	if not raining:
		var remaining_dry := _find_closest_crop_tile(p_pos, false, true, false)
		if remaining_dry.x >= 0 and stamina >= 1:
			if water_level <= 2:
				_demo_action = "refill"
				_demo_target_tile = WELL_TILE
				_demo_target_slot = 1
				_demo_waypoints = _build_demo_path(p_pos, DEMO_WELL_WP, "outside")
				return
			_demo_action = "water"
			_demo_target_tile = remaining_dry
			_demo_target_slot = 1
			_demo_waypoints = _build_demo_path(p_pos, _garden_stand_pos(remaining_dry), "garden")
			return

	# 6. Sell basket items at Shipping Bin
	if _game_state.has_method("get_total_basket_count") and int(_game_state.call("get_total_basket_count")) > 0:
		_demo_action = "sell"
		_demo_target_tile = SHIPPING_BIN_TILE
		_demo_waypoints = _build_demo_path(p_pos, DEMO_BIN_WP, "outside")
		return

	# 7. Buy missing seeds at Shop Sign if affordable
	if money >= 30 and _needs_any_seed(seeds_dict, money):
		_demo_action = "buy_seeds"
		_demo_target_tile = SHOP_SIGN_TILE
		_demo_waypoints = _build_demo_path(p_pos, DEMO_SIGN_WP, "outside")
		return

	# 8. Sleep at farmhouse door to advance to the next day
	_demo_action = "sleep"
	_demo_target_tile = Vector2i(8, 5)
	_demo_waypoints = _build_demo_path(p_pos, DEMO_DOOR_WP, "outside")


func _find_demo_machine_task() -> String:
	var owned: Dictionary = _game_state.get("owned_machines")
	var states: Dictionary = _game_state.get("machine_states")
	for m_id in FarmCatalogScript.MACHINE_ORDER:
		if not bool(owned.get(m_id, false)):
			continue
		var st: Dictionary = states.get(m_id, {})
		if bool(st.get("ready", false)):
			return m_id
		if not bool(st.get("busy", false)) and m_id != "bee_hive":
			var m_def: Dictionary = FarmCatalogScript.MACHINES[m_id]
			var in_id: String = str(m_def.get("input_id", ""))
			var in_qty: int = int(m_def.get("input_qty", 1))
			if int(_game_state.call("get_item_count", in_id)) >= in_qty:
				return m_id
	return ""


func _execute_demo_action() -> void:
	if _game_state == null or player == null:
		return

	if _demo_target_slot >= 0 and _game_state.has_method("select_slot"):
		_game_state.call("select_slot", _demo_target_slot)

	match _demo_action:
		"harvest":
			if _crops.has(_demo_target_tile) and int(_crops[_demo_target_tile]["stage"]) == 4:
				if player.has_method("set_facing_toward"):
					player.call("set_facing_toward", _tile_center(_demo_target_tile))
				_harvest_crop(_demo_target_tile)
		"hoe", "plant", "water":
			_handle_use_on_tile(_demo_target_tile)
		"refill":
			if player.has_method("set_facing_toward"):
				player.call("set_facing_toward", _tile_center(WELL_TILE))
			_refill_watering_can()
		"machine":
			if not _demo_target_machine.is_empty():
				_interact_with_machine(_demo_target_machine)
		"animal":
			if is_instance_valid(_demo_target_animal):
				_interact_with_animal(_demo_target_animal)
		"sell":
			if player.has_method("set_facing_toward"):
				player.call("set_facing_toward", _tile_center(SHIPPING_BIN_TILE))
			_sell_at_shipping_bin()
		"buy_seeds":
			if player.has_method("set_facing_toward"):
				player.call("set_facing_toward", _tile_center(SHOP_SIGN_TILE))
			_demo_buy_needed_seeds()
		"exit_house":
			_exit_house(true)
		"sleep":
			if player.has_method("set_facing_toward"):
				player.call("set_facing_toward", HOUSE_DOOR_POS)
			_game_state.call("advance_day")


func _get_demo_seed_priority() -> Array[String]:
	var season_def: Dictionary = SeasonDataScript.get_definition(_current_season_id)
	var order: Array[String] = []
	for bonus_var in season_def.get("bonus_crops", []):
		var b_id: String = str(bonus_var)
		if not order.has(b_id):
			order.append(b_id)
	for cid in ["corn", "tomato", "pumpkin", "strawberry", "turnip", "carrot", "wheat"]:
		if not order.has(cid):
			order.append(cid)
	return order


func _demo_buy_needed_seeds() -> void:
	var seeds_dict: Dictionary = _game_state.get("seeds")
	var priority := _get_demo_seed_priority()
	for idx in range(priority.size()):
		var crop_id: String = priority[idx]
		var target_qty: int = 3 if CropDataScript.is_in_preferred_season(crop_id, _current_season_id) else 2
		while int(seeds_dict.get(crop_id, 0)) < target_qty:
			var crop_def: Dictionary = _game_state.CROPS.get(crop_id, {})
			var price: int = int(crop_def.get("seed_price", 10))
			if int(_game_state.get("money")) < price:
				break
			if not bool(_game_state.call("buy_seed", crop_id, 1)):
				break
			seeds_dict = _game_state.get("seeds")


func _needs_any_seed(seeds_dict: Dictionary, available_money: int = 999999) -> bool:
	for crop_id in _get_demo_seed_priority():
		var target_qty: int = 3 if CropDataScript.is_in_preferred_season(crop_id, _current_season_id) else 2
		if int(seeds_dict.get(crop_id, 0)) < target_qty:
			var crop_def: Dictionary = _game_state.CROPS.get(crop_id, {})
			var price: int = int(crop_def.get("seed_price", 10))
			if available_money >= price:
				return true
	return false


func _find_closest_crop_tile(from_pos: Vector2, want_mature: bool, want_dry: bool, only_older_than_today: bool = false) -> Vector2i:
	var best := Vector2i(-1, -1)
	var best_dist: float = INF
	for tile_var in _crops.keys():
		var tile: Vector2i = tile_var as Vector2i
		var info: Dictionary = _crops[tile]
		var stage: int = int(info.get("stage", 0))
		if want_mature and stage != 4:
			continue
		if want_dry:
			if stage == 4:
				continue
			if only_older_than_today and int(info.get("days_grown", 0)) <= 0:
				continue
			if soil_layer.get_cell_source_id(tile) == -1 or soil_layer.get_cell_atlas_coords(tile) != TILE_SOIL_DRY:
				continue
		var d: float = from_pos.distance_to(_tile_center(tile))
		if d < best_dist:
			best_dist = d
			best = tile
	return best


func _find_closest_ready_animal(from_pos: Vector2) -> CharacterBody2D:
	var best: CharacterBody2D = null
	var best_dist: float = INF
	for animal in _animals:
		if not is_instance_valid(animal):
			continue
		var ready: bool = (
			(animal.has_method("can_collect") and bool(animal.call("can_collect")))
			or (animal.has_method("can_pet") and bool(animal.call("can_pet")))
		)
		if ready:
			var d: float = from_pos.distance_to(animal.global_position)
			if d < best_dist:
				best_dist = d
				best = animal
	return best


func _find_demo_plot_to_hoe(from_pos: Vector2, stamina: int) -> Vector2i:
	if stamina < 10:
		return Vector2i(-1, -1)
	var best := Vector2i(-1, -1)
	var best_dist: float = INF
	for t in DEMO_PLOTS:
		if soil_layer.get_cell_source_id(t) == -1 and obstacle_layer.get_cell_source_id(t) == -1 and not _crops.has(t) and not _sprinklers.has(t):
			var d: float = from_pos.distance_to(_tile_center(t))
			if d < best_dist:
				best_dist = d
				best = t
	return best


func _find_demo_plot_to_plant(from_pos: Vector2, seeds_dict: Dictionary) -> Dictionary:
	var slot_by_crop: Dictionary = {
		"wheat": 3,
		"carrot": 4,
		"strawberry": 5,
		"corn": 6,
		"tomato": 7,
		"pumpkin": 8,
		"turnip": 11,
	}
	var seed_cycle: Array[Dictionary] = []
	for cid in _get_demo_seed_priority():
		if slot_by_crop.has(cid):
			seed_cycle.append({"crop_id": cid, "slot": int(slot_by_crop[cid])})
	var best_tile := Vector2i(-1, -1)
	var best_idx: int = -1
	var best_dist: float = INF
	for i in range(DEMO_PLOTS.size()):
		var t: Vector2i = DEMO_PLOTS[i]
		if soil_layer.get_cell_source_id(t) != -1 and not _crops.has(t) and not _sprinklers.has(t):
			var d: float = from_pos.distance_to(_tile_center(t))
			if d < best_dist:
				best_dist = d
				best_tile = t
				best_idx = i
	if best_idx < 0:
		return {}

	for offset in range(seed_cycle.size()):
		var entry: Dictionary = seed_cycle[(best_idx + offset) % seed_cycle.size()]
		if int(seeds_dict.get(entry["crop_id"], 0)) > 0:
			return {"tile": best_tile, "slot": int(entry["slot"])}
	return {}


func _garden_stand_pos(tile: Vector2i) -> Vector2:
	var stand_tile: Vector2i = tile + Vector2i(0, 1)
	if not ARABLE_RECT.has_point(stand_tile) or _sprinklers.has(stand_tile):
		stand_tile = tile + Vector2i(0, -1)
	return _tile_center(stand_tile)


func _get_demo_zone(pos: Vector2) -> String:
	if DEMO_GARDEN_BOUNDS_PX.has_point(pos):
		return "garden"
	if DEMO_PEN_BOUNDS_PX.has_point(pos):
		return "pen"
	return "outside"


func _build_demo_path(from_pos: Vector2, dest_pos: Vector2, dest_zone: String) -> Array[Vector2]:
	var path: Array[Vector2] = []
	var from_zone: String = _get_demo_zone(from_pos)

	if from_zone == dest_zone and (from_zone == "garden" or from_zone == "pen"):
		path.append(dest_pos)
		return path

	if from_zone == "outside" and dest_zone == "outside" and absf(from_pos.y - DEMO_CORRIDOR_Y) <= 18.0:
		path.append(dest_pos)
		return path

	# Step 1: Exit current zone safely onto main dirt path corridor (y = 104)
	if from_zone == "garden":
		path.append(DEMO_GARDEN_ENTRY_WP)
		path.append(DEMO_GARDEN_CORRIDOR_WP)
	elif from_zone == "pen":
		path.append(DEMO_PEN_ENTRY_WP)
		path.append(DEMO_PEN_CORRIDOR_WP)
	else:
		if from_pos.x >= 272.0 and from_pos.x <= 304.0 and from_pos.y >= 120.0 and from_pos.y <= 146.0:
			path.append(DEMO_GARDEN_CORRIDOR_WP)
		elif from_pos.x >= 430.0 and from_pos.x <= 450.0 and from_pos.y >= 94.0 and from_pos.y <= 130.0:
			path.append(DEMO_PEN_CORRIDOR_WP)
		elif from_pos.y > 256.0:
			if from_pos.x <= 392.0:
				path.append(Vector2(280.0, 276.0))
				path.append(Vector2(280.0, 232.0))
				path.append(DEMO_GARDEN_ENTRY_WP)
				path.append(DEMO_GARDEN_CORRIDOR_WP)
			else:
				path.append(Vector2(408.0, 240.0))
				path.append(Vector2(408.0, DEMO_CORRIDOR_Y))
		elif from_pos.y > 120.0:
			if from_pos.x < 192.0:
				path.append(Vector2(152.0, DEMO_CORRIDOR_Y))
			else:
				path.append(Vector2(408.0, DEMO_CORRIDOR_Y))
		else:
			path.append(Vector2(clampf(from_pos.x, 128.0, 424.0), DEMO_CORRIDOR_Y))

	# Step 2: Enter destination zone from main corridor
	if dest_zone == "garden":
		path.append(DEMO_GARDEN_CORRIDOR_WP)
		path.append(DEMO_GARDEN_ENTRY_WP)
		path.append(dest_pos)
	elif dest_zone == "pen":
		path.append(DEMO_PEN_CORRIDOR_WP)
		path.append(DEMO_PEN_ENTRY_WP)
		path.append(dest_pos)
	else:
		path.append(dest_pos)

	return path
