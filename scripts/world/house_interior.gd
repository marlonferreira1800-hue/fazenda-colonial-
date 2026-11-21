extends Node2D

const TILE_SIZE: int = 16
const ROOM_WIDTH: int = 18
const ROOM_HEIGHT: int = 12
const SHEET_PATH := "res://assets/sprites/house_interior.png"

const EXIT_LOCAL_POS := Vector2(144.0, 168.0)
const SPAWN_LOCAL_POS := Vector2(144.0, 158.0)
const BED_SPAWN_LOCAL_POS := Vector2(214.0, 62.0)

var _tex: Texture2D = null
var _floor_layer: TileMapLayer = null
var _wall_layer: TileMapLayer = null
var _fire_sprite: Sprite2D = null
var _fire_frames: Array[AtlasTexture] = []
var _fire_timer: float = 0.0
var _fire_frame_idx: int = 0
var _fire_glow: Sprite2D = null
var _lamp_glow: Sprite2D = null
var _glow_time: float = 0.0
var _interactables: Array[Dictionary] = []


func _ready() -> void:
	y_sort_enabled = true
	_tex = _load_texture_safe(SHEET_PATH)
	_build_backdrop()
	_build_tile_layers()
	_build_rugs_and_wall_decor()
	_build_furniture_and_interactables()


func _process(delta: float) -> void:
	if not visible:
		return
	_glow_time += delta
	if _fire_sprite != null and _fire_frames.size() > 0:
		_fire_timer += delta
		if _fire_timer >= 0.16:
			_fire_timer = 0.0
			_fire_frame_idx = (_fire_frame_idx + 1) % _fire_frames.size()
			_fire_sprite.texture = _fire_frames[_fire_frame_idx]
	if _fire_glow != null:
		var pulse: float = 0.92 + 0.08 * sin(_glow_time * 7.5) + 0.04 * cos(_glow_time * 13.0)
		_fire_glow.scale = Vector2(pulse, pulse)
		_fire_glow.modulate.a = 0.34 + 0.06 * sin(_glow_time * 9.0)
	if _lamp_glow != null:
		var l_pulse: float = 0.96 + 0.04 * sin(_glow_time * 3.2)
		_lamp_glow.scale = Vector2(l_pulse, l_pulse)


func get_room_pixel_size() -> Vector2i:
	return Vector2i(ROOM_WIDTH * TILE_SIZE, ROOM_HEIGHT * TILE_SIZE)


func get_camera_bounds() -> Rect2i:
	# Centra a casa (288x192) confortavelmente na janela de 320x180 (zoom 2x de 640x360)
	var ox: int = int(round(global_position.x))
	var oy: int = int(round(global_position.y))
	return Rect2i(ox - 16, oy, ROOM_WIDTH * TILE_SIZE + 32, ROOM_HEIGHT * TILE_SIZE)


func get_walk_bounds() -> Rect2:
	return Rect2(
		global_position.x + 20.0,
		global_position.y + 30.0,
		float(ROOM_WIDTH * TILE_SIZE) - 40.0,
		float(ROOM_HEIGHT * TILE_SIZE) - 42.0
	)


func get_spawn_world_pos() -> Vector2:
	return global_position + SPAWN_LOCAL_POS


func get_bed_wake_world_pos() -> Vector2:
	return global_position + BED_SPAWN_LOCAL_POS


func get_exit_waypoint() -> Vector2:
	return global_position + Vector2(144.0, 173.0)


func is_at_exit_threshold(world_pos: Vector2) -> bool:
	var local_pos: Vector2 = world_pos - global_position
	return absf(local_pos.x - 144.0) <= 15.0 and local_pos.y >= 170.5


func get_nearest_interactable(world_pos: Vector2) -> Dictionary:
	var best: Dictionary = {}
	var best_dist: float = INF
	for entry in _interactables:
		var target_pos: Vector2 = global_position + (entry["local_pos"] as Vector2)
		var max_r: float = float(entry.get("radius", 26.0))
		var d: float = world_pos.distance_to(target_pos)
		if d <= max_r and d < best_dist:
			best_dist = d
			best = entry.duplicate()
			best["world_pos"] = target_pos
			best["anchor_pos"] = global_position + (entry.get("anchor_offset", entry["local_pos"]) as Vector2)
	return best


func find_interactable_at_click(click_world_pos: Vector2) -> Dictionary:
	var local_click: Vector2 = click_world_pos - global_position
	for entry in _interactables:
		var hit_rect: Rect2 = entry.get("hit_rect", Rect2())
		if hit_rect.has_point(local_click):
			var copy := entry.duplicate()
			copy["world_pos"] = global_position + (entry["local_pos"] as Vector2)
			copy["anchor_pos"] = global_position + (entry.get("anchor_offset", entry["local_pos"]) as Vector2)
			return copy
	return {}


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


func _make_atlas(region: Rect2) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = _tex
	atlas.region = region
	return atlas


func _build_backdrop() -> void:
	var bg := ColorRect.new()
	bg.name = "VoidBackdrop"
	bg.z_index = -10
	bg.position = Vector2(-96.0, -64.0)
	bg.size = Vector2(float(ROOM_WIDTH * TILE_SIZE) + 192.0, float(ROOM_HEIGHT * TILE_SIZE) + 128.0)
	bg.color = Color("#18110e")
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)


func _build_tileset() -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	ts.add_physics_layer(0)
	ts.set_physics_layer_collision_layer(0, 1)
	ts.set_physics_layer_collision_mask(0, 1)

	var source := TileSetAtlasSource.new()
	source.texture = _tex
	source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)

	for col in range(16):
		source.create_tile(Vector2i(col, 0))

	ts.add_source(source, 0)

	var full_box := PackedVector2Array([
		Vector2(-8, -8),
		Vector2(8, -8),
		Vector2(8, 8),
		Vector2(-8, 8),
	])
	for solid_col in [3, 4, 5, 6, 7, 8, 9, 10, 11]:
		var data: TileData = source.get_tile_data(Vector2i(solid_col, 0), 0)
		data.add_collision_polygon(0)
		data.set_collision_polygon_points(0, 0, full_box)

	return ts


func _build_tile_layers() -> void:
	var tileset: TileSet = _build_tileset()

	_floor_layer = TileMapLayer.new()
	_floor_layer.name = "InteriorFloorLayer"
	_floor_layer.z_index = -3
	_floor_layer.tile_set = tileset
	add_child(_floor_layer)

	_wall_layer = TileMapLayer.new()
	_wall_layer.name = "InteriorWallLayer"
	_wall_layer.z_index = -2
	_wall_layer.tile_set = tileset
	add_child(_wall_layer)

	# Piso principal (x=1..16, y=2..10)
	for y in range(2, 11):
		for x in range(1, 17):
			var cell := Vector2i(x, y)
			if x >= 1 and x <= 5 and y >= 2 and y <= 5:
				_floor_layer.set_cell(cell, 0, Vector2i(2, 0))
			else:
				var plank := Vector2i(0, 0) if (x + y) % 2 == 0 else Vector2i(1, 0)
				_floor_layer.set_cell(cell, 0, plank)

	# Quinas externas
	_wall_layer.set_cell(Vector2i(0, 0), 0, Vector2i(8, 0))
	_wall_layer.set_cell(Vector2i(17, 0), 0, Vector2i(9, 0))
	_wall_layer.set_cell(Vector2i(0, 11), 0, Vector2i(10, 0))
	_wall_layer.set_cell(Vector2i(17, 11), 0, Vector2i(11, 0))

	# Paredes norte, sul e porta de saída (x=8..9, y=11)
	for x in range(1, 17):
		_wall_layer.set_cell(Vector2i(x, 0), 0, Vector2i(3, 0))
		_wall_layer.set_cell(Vector2i(x, 1), 0, Vector2i(4, 0))
		if x == 8 or x == 9:
			_floor_layer.set_cell(Vector2i(x, 11), 0, Vector2i(12 + (x - 8), 0))
		else:
			_wall_layer.set_cell(Vector2i(x, 11), 0, Vector2i(7, 0))

	# Paredes laterais
	for y in range(1, 11):
		_wall_layer.set_cell(Vector2i(0, y), 0, Vector2i(5, 0))
		_wall_layer.set_cell(Vector2i(17, y), 0, Vector2i(6, 0))


func _build_rugs_and_wall_decor() -> void:
	var floor_decor := Node2D.new()
	floor_decor.name = "FloorDecor"
	floor_decor.z_index = -2
	add_child(floor_decor)

	# Capacho acolhedor na porta de saída (x=8..9, y=10)
	_add_sprite(floor_decor, "Doormat", Rect2(224, 0, 32, 16), Vector2(144.0, 168.0))
	# Tapete verde bordado na sala (48x48)
	_add_sprite(floor_decor, "LivingRug", Rect2(0, 16, 48, 48), Vector2(120.0, 88.0))
	# Tapete coral ao lado da cama (32x16)
	_add_sprite(floor_decor, "BedroomRug", Rect2(48, 16, 32, 16), Vector2(240.0, 86.0))
	# Passadeira na frente do balcão da cozinha (32x16)
	_add_sprite(floor_decor, "KitchenRug", Rect2(80, 16, 32, 16), Vector2(48.0, 58.0))

	var wall_decor := Node2D.new()
	wall_decor.name = "WallDecor"
	wall_decor.z_index = -1
	add_child(wall_decor)

	# Janelas com luz azul (cozinha e quarto)
	_add_sprite(wall_decor, "KitchenWindow", Rect2(112, 16, 32, 16), Vector2(48.0, 14.0))
	_add_sprite(wall_decor, "BedroomWindow", Rect2(112, 16, 32, 16), Vector2(240.0, 14.0))
	# Quadro paisagem + mapa na parede
	_add_sprite(wall_decor, "LandscapePicture", Rect2(144, 16, 16, 16), Vector2(152.0, 14.0))
	_add_sprite(wall_decor, "WallMap", Rect2(176, 16, 16, 16), Vector2(168.0, 15.0))
	# Cano da chaminé do fogão
	_add_sprite(wall_decor, "StovePipe", Rect2(192, 16, 16, 16), Vector2(88.0, 22.0))


func _build_furniture_and_interactables() -> void:
	_interactables.clear()

	# 1. Cozinha: Balcão, Pia, Potes, Pratos, Fogão (x=1..5, y=2)
	var kitchen_regions: Array[Rect2] = [
		Rect2(0, 64, 16, 16),   # Balcão
		Rect2(16, 64, 16, 16),  # Pia
		Rect2(32, 64, 16, 16),  # Potes
		Rect2(48, 64, 16, 16),  # Pratos
		Rect2(64, 64, 16, 16),  # Fogão
	]
	for i in range(kitchen_regions.size()):
		var kx: float = (1.5 + float(i)) * TILE_SIZE
		_spawn_solid_prop(
			"Kitchen_%d" % i,
			kitchen_regions[i],
			Vector2(kx, 42.0),
			Vector2(0.0, -8.0),
			Rect2(0.0, -7.0, 16.0, 14.0)
		)
	_register_interactable(
		"stove",
		"[F] Chá da Fazenda (+20 Energia)",
		Vector2(88.0, 42.0),
		Vector2(88.0, 18.0),
		28.0,
		Rect2(76.0, 24.0, 24.0, 24.0)
	)

	# 2. Lareira de Tijolos com Chama Animada (x=7..8, y=1..2)
	var fireplace := _spawn_solid_prop(
		"Fireplace",
		Rect2(80, 64, 32, 48),
		Vector2(128.0, 50.0),
		Vector2(0.0, -24.0),
		Rect2(0.0, -8.0, 30.0, 16.0)
	)
	if fireplace != null and _tex != null:
		_fire_frames.clear()
		for fi in range(3):
			_fire_frames.append(_make_atlas(Rect2(192 + fi * 16, 112, 16, 16)))
		_fire_sprite = Sprite2D.new()
		_fire_sprite.name = "FireAnim"
		_fire_sprite.texture = _fire_frames[0]
		_fire_sprite.position = Vector2(0.0, -7.0)
		_fire_sprite.scale = Vector2(0.75, 0.72)
		fireplace.add_child(_fire_sprite)

		_fire_glow = _make_warm_glow(Vector2(0.0, -4.0), 46.0, Color(1.0, 0.62, 0.25, 0.36))
		fireplace.add_child(_fire_glow)

	_register_interactable(
		"fireplace",
		"[F] Aquecer-se na Lareira",
		Vector2(128.0, 48.0),
		Vector2(128.0, 12.0),
		28.0,
		Rect2(110.0, 8.0, 36.0, 44.0)
	)

	# 3. Planta Alta Florida (x=10, y=2)
	_spawn_solid_prop(
		"TallPlant",
		Rect2(96, 112, 16, 32),
		Vector2(168.0, 48.0),
		Vector2(0.0, -14.0),
		Rect2(0.0, -5.0, 12.0, 10.0)
	)

	# 4. Estante de Livros (x=11..13, y=1..2)
	_spawn_solid_prop(
		"Bookcase",
		Rect2(112, 64, 48, 32),
		Vector2(200.0, 48.0),
		Vector2(0.0, -16.0),
		Rect2(0.0, -7.0, 46.0, 14.0)
	)
	_register_interactable(
		"bookshelf",
		"[F] Ler Guia da Fazenda",
		Vector2(200.0, 48.0),
		Vector2(200.0, 18.0),
		28.0,
		Rect2(176.0, 16.0, 48.0, 34.0)
	)

	# 5. Cama de Casal (x=14..15, y=2..4)
	_spawn_solid_prop(
		"Bed",
		Rect2(160, 64, 32, 48),
		Vector2(240.0, 70.0),
		Vector2(0.0, -24.0),
		Rect2(0.0, -18.0, 30.0, 36.0)
	)
	_register_interactable(
		"bed",
		"[F] Dormir na Cama",
		Vector2(236.0, 58.0),
		Vector2(240.0, 26.0),
		34.0,
		Rect2(224.0, 22.0, 32.0, 48.0)
	)

	# 6. Criado-mudo com Abajur Aconchegante (x=16, y=2)
	var nightstand := _spawn_solid_prop(
		"Nightstand",
		Rect2(32, 144, 16, 16),
		Vector2(264.0, 46.0),
		Vector2(0.0, -8.0),
		Rect2(0.0, -6.0, 14.0, 12.0)
	)
	if nightstand != null and _tex != null:
		var lamp := Sprite2D.new()
		lamp.name = "BedsideLamp"
		lamp.texture = _make_atlas(Rect2(240, 112, 16, 16))
		lamp.position = Vector2(0.0, -14.0)
		nightstand.add_child(lamp)
		_lamp_glow = _make_warm_glow(Vector2(0.0, -14.0), 32.0, Color(1.0, 0.78, 0.40, 0.28))
		nightstand.add_child(_lamp_glow)

	# 7. Mesa de Jantar + Cadeiras + Pão e Maçã (x=2..4, y=6..7)
	var table := _spawn_solid_prop(
		"DiningTable",
		Rect2(0, 112, 32, 32),
		Vector2(48.0, 128.0),
		Vector2(0.0, -16.0),
		Rect2(0.0, -11.0, 30.0, 20.0)
	)
	if table != null and _tex != null:
		var bread := Sprite2D.new()
		bread.texture = _make_atlas(Rect2(160, 112, 16, 16))
		bread.position = Vector2(-7.0, -20.0)
		table.add_child(bread)
		var apple := Sprite2D.new()
		apple.texture = _make_atlas(Rect2(176, 112, 16, 16))
		apple.position = Vector2(7.0, -19.0)
		table.add_child(apple)

	_spawn_solid_prop("ChairLeft", Rect2(48, 112, 16, 16), Vector2(25.0, 122.0), Vector2(0.0, -8.0), Rect2(0.0, -5.0, 10.0, 10.0))
	_spawn_solid_prop("ChairRight", Rect2(64, 112, 16, 16), Vector2(71.0, 122.0), Vector2(0.0, -8.0), Rect2(0.0, -5.0, 10.0, 10.0))

	_register_interactable(
		"table",
		"[F] Mesa da Fazenda",
		Vector2(48.0, 122.0),
		Vector2(48.0, 96.0),
		28.0,
		Rect2(32.0, 96.0, 32.0, 32.0)
	)

	# 8. Baú de Madeira & Escrivaninha com Diário Aberto (x=13..15, y=8)
	_spawn_solid_prop(
		"StorageChest",
		Rect2(112, 112, 16, 16),
		Vector2(216.0, 138.0),
		Vector2(0.0, -8.0),
		Rect2(0.0, -6.0, 14.0, 11.0)
	)
	_register_interactable(
		"chest",
		"[F] Baú da Fazenda",
		Vector2(216.0, 138.0),
		Vector2(216.0, 118.0),
		24.0,
		Rect2(206.0, 124.0, 20.0, 20.0)
	)

	var desk := _spawn_solid_prop(
		"StudyDesk",
		Rect2(0, 144, 32, 16),
		Vector2(244.0, 138.0),
		Vector2(0.0, -8.0),
		Rect2(0.0, -6.0, 30.0, 12.0)
	)
	if desk != null and _tex != null:
		var diary := Sprite2D.new()
		diary.texture = _make_atlas(Rect2(128, 112, 16, 16))
		diary.position = Vector2(-7.0, -11.0)
		desk.add_child(diary)
		var herb := Sprite2D.new()
		herb.texture = _make_atlas(Rect2(48, 144, 16, 16))
		herb.position = Vector2(8.0, -14.0)
		desk.add_child(herb)

	_register_interactable(
		"desk",
		"[F] Salvar Jogo (Diário)",
		Vector2(244.0, 138.0),
		Vector2(244.0, 114.0),
		26.0,
		Rect2(228.0, 122.0, 34.0, 22.0)
	)

	# 9. Vasinhos de planta ladeando a saída (x=6, y=10 e x=11, y=10)
	_spawn_solid_prop("DoorPlantL", Rect2(208, 16, 16, 16), Vector2(104.0, 168.0), Vector2(0.0, -8.0), Rect2(0.0, -4.0, 10.0, 8.0))
	_spawn_solid_prop("DoorPlantR", Rect2(224, 16, 16, 16), Vector2(184.0, 168.0), Vector2(0.0, -8.0), Rect2(0.0, -4.0, 10.0, 8.0))

	# 10. Porta / Tapete de Saída (x=8..9, y=10..11)
	_register_interactable(
		"exit",
		"[F] Sair para Fazenda",
		EXIT_LOCAL_POS,
		Vector2(144.0, 146.0),
		26.0,
		Rect2(128.0, 158.0, 32.0, 26.0)
	)


func _add_sprite(parent: Node2D, spr_name: String, region: Rect2, local_pos: Vector2) -> Sprite2D:
	var spr := Sprite2D.new()
	spr.name = spr_name
	if _tex != null:
		spr.texture = _make_atlas(region)
	spr.position = local_pos
	parent.add_child(spr)
	return spr


func _spawn_solid_prop(
	prop_name: String,
	region: Rect2,
	local_pos: Vector2,
	sprite_offset: Vector2,
	collider_rect: Rect2
) -> StaticBody2D:
	if _tex == null:
		return null
	var body := StaticBody2D.new()
	body.name = prop_name
	body.position = local_pos
	body.collision_layer = 1
	body.collision_mask = 0

	var spr := Sprite2D.new()
	spr.texture = _make_atlas(region)
	spr.offset = sprite_offset
	body.add_child(spr)

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = collider_rect.size
	col.shape = shape
	col.position = collider_rect.position
	body.add_child(col)

	add_child(body)
	return body


func _make_warm_glow(local_pos: Vector2, radius_px: float, tint: Color) -> Sprite2D:
	var grad := Gradient.new()
	grad.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	grad.offsets = PackedFloat32Array([0.0, 1.0])

	var gtex := GradientTexture2D.new()
	gtex.gradient = grad
	gtex.fill = GradientTexture2D.FILL_RADIAL
	gtex.fill_from = Vector2(0.5, 0.5)
	gtex.fill_to = Vector2(0.5, 0.0)
	gtex.width = int(radius_px * 2.0)
	gtex.height = int(radius_px * 2.0)

	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD

	var glow := Sprite2D.new()
	glow.texture = gtex
	glow.position = local_pos
	glow.z_index = 2
	glow.modulate = tint
	glow.material = mat
	return glow


func _register_interactable(
	id: String,
	prompt: String,
	local_pos: Vector2,
	anchor_offset: Vector2,
	radius: float,
	hit_rect: Rect2
) -> void:
	_interactables.append({
		"id": id,
		"prompt": prompt,
		"local_pos": local_pos,
		"anchor_offset": anchor_offset,
		"radius": radius,
		"hit_rect": hit_rect,
	})
