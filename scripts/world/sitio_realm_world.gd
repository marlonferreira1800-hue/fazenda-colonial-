extends Node2D
## Cenários Mágicos do Sítio do Picapau Amarelo (acessados pelo Livro com Pó de Pirlimpimpim).
## Construído em REALM_ORIGIN (3600, 0) no mesmo padrão de village_world.gd.

const StoryDataScript := preload("res://scripts/data/story_data.gd")

const TILE_SIZE: int = 16
const REALM_WIDTH: int = 24
const REALM_HEIGHT: int = 16

const SPAWN_LOCAL_POS := Vector2(192.0, 186.0)
const PORTAL_LOCAL_POS := Vector2(192.0, 216.0)

var current_realm_id: String = ""
var _interactables: Array[Dictionary] = []
var _content_root: Node2D = null
var _pulse_time: float = 0.0
var _magic_sprite: Sprite2D = null
var _portal_sprite: Sprite2D = null


func _ready() -> void:
	y_sort_enabled = true
	_content_root = Node2D.new()
	_content_root.name = "RealmContent"
	_content_root.y_sort_enabled = true
	add_child(_content_root)
	_build_perimeter_walls()


func _process(delta: float) -> void:
	_pulse_time += delta
	if _magic_sprite != null and is_instance_valid(_magic_sprite):
		_magic_sprite.position.y = sin(_pulse_time * 3.0) * 1.8
	if _portal_sprite != null and is_instance_valid(_portal_sprite):
		var sc: float = 1.0 + sin(_pulse_time * 4.2) * 0.07
		_portal_sprite.scale = Vector2(sc, sc)
		_portal_sprite.rotation = sin(_pulse_time * 1.4) * 0.14


func get_camera_bounds() -> Rect2i:
	var ox: int = int(round(global_position.x))
	var oy: int = int(round(global_position.y))
	return Rect2i(ox, oy, REALM_WIDTH * TILE_SIZE, REALM_HEIGHT * TILE_SIZE)


func get_spawn_world_pos() -> Vector2:
	return global_position + SPAWN_LOCAL_POS


func is_at_exit_portal(world_pos: Vector2) -> bool:
	var local_pos: Vector2 = world_pos - global_position
	return local_pos.distance_to(PORTAL_LOCAL_POS) <= 22.0


func get_nearest_interactable(world_pos: Vector2) -> Dictionary:
	var best: Dictionary = {}
	var best_dist: float = INF
	for entry in _interactables:
		var target_pos: Vector2 = global_position + (entry["local_pos"] as Vector2)
		var max_r: float = float(entry.get("radius", 32.0))
		var d: float = world_pos.distance_to(target_pos)
		if d <= max_r and d < best_dist:
			best_dist = d
			best = entry.duplicate()
			best["world_pos"] = target_pos
			best["anchor"] = target_pos + Vector2(0.0, -24.0)
	return best


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


func load_realm(realm_id: String) -> bool:
	if not StoryDataScript.SITIO_REALMS.has(realm_id):
		return false
	current_realm_id = realm_id
	_interactables.clear()
	_magic_sprite = null
	_portal_sprite = null

	if _content_root != null:
		for child in _content_root.get_children():
			child.queue_free()

	var def: Dictionary = StoryDataScript.SITIO_REALMS[realm_id]
	var w_px: float = float(REALM_WIDTH * TILE_SIZE)
	var h_px: float = float(REALM_HEIGHT * TILE_SIZE)

	# Fundo principal do cenário
	var bg := ColorRect.new()
	bg.size = Vector2(w_px, h_px)
	bg.color = def.get("ground_color", Color(0.28, 0.50, 0.28, 1.0))
	bg.z_index = -5
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content_root.add_child(bg)

	# Moldura decorativa interna
	var border_outer := ColorRect.new()
	border_outer.position = Vector2(18.0, 22.0)
	border_outer.size = Vector2(w_px - 36.0, h_px - 40.0)
	border_outer.color = (def.get("plaza_color", Color(0.55, 0.45, 0.30, 1.0)) as Color).darkened(0.22)
	border_outer.z_index = -4
	border_outer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content_root.add_child(border_outer)

	# Praça / Tapete / Lago central mágico
	var plaza := ColorRect.new()
	plaza.position = Vector2(56.0, 56.0)
	plaza.size = Vector2(w_px - 112.0, h_px - 104.0)
	plaza.color = def.get("plaza_color", Color(0.65, 0.55, 0.38, 1.0))
	plaza.z_index = -3
	plaza.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content_root.add_child(plaza)

	# Caminho iluminado até o Portal de Pó de Pirlimpimpim
	var path_rect := ColorRect.new()
	path_rect.position = Vector2(168.0, 148.0)
	path_rect.size = Vector2(48.0, 82.0)
	path_rect.color = (def.get("plaza_color", Color(0.65, 0.55, 0.38, 1.0)) as Color).lightened(0.14)
	path_rect.z_index = -2
	path_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content_root.add_child(path_rect)

	# Placa com o nome do cenário no topo
	var title_lbl := Label.new()
	title_lbl.text = "✨ " + str(def.get("name", "Sítio Encantado")) + " ✨"
	title_lbl.position = Vector2(24.0, 6.0)
	title_lbl.custom_minimum_size = Vector2(w_px - 48.0, 16.0)
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.z_index = 8
	title_lbl.add_theme_font_size_override("font_size", 8)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.96, 0.78))
	title_lbl.add_theme_color_override("font_outline_color", Color(0.12, 0.08, 0.06, 0.95))
	title_lbl.add_theme_constant_override("outline_size", 2)
	_content_root.add_child(title_lbl)

	# Partículas mágicas ambientes do cenário
	var fx := CPUParticles2D.new()
	fx.position = Vector2(w_px * 0.5, h_px * 0.5)
	fx.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fx.emission_rect_extents = Vector2(w_px * 0.44, h_px * 0.42)
	fx.amount = 28
	fx.lifetime = 3.2
	fx.direction = Vector2(0.0, -1.0)
	fx.spread = 35.0
	fx.gravity = Vector2(0.0, -4.0)
	fx.initial_velocity_min = 4.0
	fx.initial_velocity_max = 12.0
	fx.scale_amount_min = 1.5
	fx.scale_amount_max = 3.0
	fx.color = def.get("particle_color", Color(1.0, 0.92, 0.52, 0.92))
	fx.z_index = 7
	_content_root.add_child(fx)

	# Props decorativos do cenário
	var props_arr = def.get("props", [])
	if props_arr is Array:
		var idx: int = 0
		for p in props_arr:
			if p is Dictionary:
				_spawn_static(
					"RealmProp_%d" % idx,
					str(p.get("sprite", "")),
					p.get("pos", Vector2(100.0, 100.0)),
					p.get("offset", Vector2(0.0, -12.0)),
					p.get("col", Vector2(16.0, 10.0))
				)
				idx += 1

	# Objeto Mágico Central (ativa o encantamento na Fazenda Colonial)
	var m_pos: Vector2 = def.get("magic_pos", Vector2(192.0, 128.0))
	var m_body := _spawn_static(
		"RealmMagicObject",
		str(def.get("magic_sprite", "")),
		m_pos,
		Vector2(0.0, -12.0),
		Vector2(20.0, 12.0)
	)
	if m_body != null:
		for c in m_body.get_children():
			if c is Sprite2D:
				_magic_sprite = c as Sprite2D
				break
	_interactables.append({
		"id": realm_id,
		"kind": "realm_magic",
		"local_pos": m_pos,
		"radius": 34.0,
		"prompt": str(def.get("magic_prompt", "[F] Ativar Magia do Sítio")),
	})

	# Personagens (NPCs) do Sítio
	var npcs_arr = def.get("npcs", [])
	if npcs_arr is Array:
		for n in npcs_arr:
			if n is Dictionary:
				var n_pos: Vector2 = n.get("pos", Vector2(150.0, 130.0))
				var n_name: String = str(n.get("name", "Personagem"))
				_spawn_static(
					"RealmNPC_" + str(n.get("id", "npc")),
					str(n.get("sprite", "")),
					n_pos,
					Vector2(0.0, -10.0),
					Vector2(12.0, 8.0)
				)
				_interactables.append({
					"id": str(n.get("id", "npc")),
					"kind": "realm_npc",
					"name": n_name,
					"lines": n.get("lines", []),
					"local_pos": n_pos,
					"radius": 32.0,
					"prompt": "[F] Conversar com %s" % n_name,
				})

	# Portal de Retorno (Pó de Pirlimpimpim)
	var portal_tex := _load_texture_safe("res://assets/sprites/sitio_px/portal_pirlimpimpim.png")
	if portal_tex != null:
		_portal_sprite = Sprite2D.new()
		_portal_sprite.texture = portal_tex
		_portal_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_portal_sprite.position = PORTAL_LOCAL_POS
		_portal_sprite.z_index = -1
		_content_root.add_child(_portal_sprite)

	var exit_lbl := Label.new()
	exit_lbl.text = "✨ Voltar à Fazenda ✨"
	exit_lbl.position = Vector2(128.0, 234.0)
	exit_lbl.custom_minimum_size = Vector2(128.0, 14.0)
	exit_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	exit_lbl.z_index = 8
	exit_lbl.add_theme_font_size_override("font_size", 7)
	exit_lbl.add_theme_color_override("font_color", Color(1.0, 0.95, 0.65))
	exit_lbl.add_theme_color_override("font_outline_color", Color(0.12, 0.08, 0.05, 0.95))
	exit_lbl.add_theme_constant_override("outline_size", 2)
	_content_root.add_child(exit_lbl)

	_interactables.append({
		"id": "exit_portal",
		"kind": "realm_exit",
		"local_pos": PORTAL_LOCAL_POS,
		"radius": 30.0,
		"prompt": "[F] Voltar para a Fazenda Colonial",
	})
	return true


func _spawn_static(prop_name: String, tex_path: String, local_pos: Vector2, offset: Vector2, col_size: Vector2) -> StaticBody2D:
	var tex := _load_texture_safe(tex_path)
	if tex == null:
		return null
	var body := StaticBody2D.new()
	body.name = prop_name
	body.position = local_pos
	body.collision_layer = 1
	body.collision_mask = 0

	var spr := Sprite2D.new()
	spr.texture = tex
	spr.offset = offset
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	body.add_child(spr)

	if col_size.x > 0.0 and col_size.y > 0.0:
		var col := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = col_size
		col.shape = shape
		col.position = Vector2(0.0, -3.0)
		body.add_child(col)

	_content_root.add_child(body)
	return body


func _build_perimeter_walls() -> void:
	var w_px: float = float(REALM_WIDTH * TILE_SIZE)
	var h_px: float = float(REALM_HEIGHT * TILE_SIZE)
	var walls := StaticBody2D.new()
	walls.name = "RealmWalls"
	walls.collision_layer = 1
	walls.collision_mask = 0
	var segments: Array[Rect2] = [
		Rect2(0.0, 12.0, w_px, 16.0),
		Rect2(0.0, h_px - 12.0, w_px, 16.0),
		Rect2(8.0, 0.0, 16.0, h_px),
		Rect2(w_px - 24.0, 0.0, 16.0, h_px),
	]
	for seg in segments:
		var col := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = seg.size
		col.shape = shape
		col.position = seg.position + seg.size * 0.5
		walls.add_child(col)
	add_child(walls)
