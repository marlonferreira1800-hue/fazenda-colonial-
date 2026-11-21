extends Node2D
## Vila Colonial explorável (acessada atravessando a Porteira da Estrada Real ao sul).
## Construída em VILLAGE_ORIGIN (2400, 0) no mesmo padrão limpo de house_interior.gd.

const TILE_SIZE: int = 16
const VILLAGE_WIDTH: int = 24
const VILLAGE_HEIGHT: int = 16

const SPAWN_LOCAL_POS := Vector2(192.0, 34.0)
const EXIT_LOCAL_POS := Vector2(192.0, 14.0)

var _interactables: Array[Dictionary] = []


func _ready() -> void:
	y_sort_enabled = true
	_build_ground()
	_build_buildings_and_npcs()
	_build_perimeter_walls()


func get_camera_bounds() -> Rect2i:
	var ox: int = int(round(global_position.x))
	var oy: int = int(round(global_position.y))
	return Rect2i(ox, oy, VILLAGE_WIDTH * TILE_SIZE, VILLAGE_HEIGHT * TILE_SIZE)


func get_spawn_world_pos() -> Vector2:
	return global_position + SPAWN_LOCAL_POS


func is_at_exit_threshold(world_pos: Vector2) -> bool:
	var local_pos: Vector2 = world_pos - global_position
	return absf(local_pos.x - 192.0) <= 28.0 and local_pos.y <= 22.0


func get_nearest_interactable(world_pos: Vector2) -> Dictionary:
	var best: Dictionary = {}
	var best_dist: float = INF
	for entry in _interactables:
		var target_pos: Vector2 = global_position + (entry["local_pos"] as Vector2)
		var max_r: float = float(entry.get("radius", 30.0))
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


func _build_ground() -> void:
	var w_px: float = float(VILLAGE_WIDTH * TILE_SIZE)
	var h_px: float = float(VILLAGE_HEIGHT * TILE_SIZE)

	# Fundo verde colonial ao redor da vila
	var grass := ColorRect.new()
	grass.size = Vector2(w_px, h_px)
	grass.color = Color(0.32, 0.56, 0.28, 1.0)
	grass.z_index = -4
	grass.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(grass)

	# Estrada de entrada ao norte (chegando da Fazenda)
	var road := ColorRect.new()
	road.position = Vector2(168.0, 0.0)
	road.size = Vector2(48.0, 90.0)
	road.color = Color(0.62, 0.50, 0.36, 1.0)
	road.z_index = -3
	road.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(road)

	# Praça central de calçamento pé-de-moleque
	var cobble_tex := _load_texture_safe("res://assets/sprites/colonial_buildings_px/pe_de_moleque.png")
	if cobble_tex != null:
		for gy in range(2, 7):
			for gx in range(2, 10):
				var spr := Sprite2D.new()
				spr.texture = cobble_tex
				spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				spr.position = Vector2(gx * 32.0 + 16.0, gy * 32.0 + 16.0)
				spr.z_index = -2
				add_child(spr)

	# Placa de retorno à Fazenda na entrada norte
	var exit_lbl := Label.new()
	exit_lbl.text = "↑ Fazenda"
	exit_lbl.position = Vector2(168.0, 4.0)
	exit_lbl.z_index = 6
	exit_lbl.add_theme_font_size_override("font_size", 7)
	exit_lbl.add_theme_color_override("font_color", Color(1.0, 0.96, 0.80))
	exit_lbl.add_theme_color_override("font_outline_color", Color(0.12, 0.08, 0.05, 0.95))
	exit_lbl.add_theme_constant_override("outline_size", 2)
	add_child(exit_lbl)


func _spawn_static(prop_name: String, tex_path: String, local_pos: Vector2, offset: Vector2, col_size: Vector2, col_offset: Vector2 = Vector2.ZERO) -> StaticBody2D:
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
		col.position = col_offset
		body.add_child(col)

	add_child(body)
	return body


func _build_buildings_and_npcs() -> void:
	# Igreja Matriz barroca (centro-norte-oeste da praça)
	_spawn_static(
		"IgrejaMatriz",
		"res://assets/sprites/colonial_buildings_px/igreja_matriz.png",
		Vector2(104.0, 96.0),
		Vector2(0.0, -28.0),
		Vector2(56.0, 26.0),
		Vector2(0.0, -10.0)
	)

	# Ferraria do Joaquim (lado leste)
	_spawn_static(
		"FerrariaColonial",
		"res://assets/sprites/colonial_buildings_px/ferraria_colonial.png",
		Vector2(292.0, 98.0),
		Vector2(0.0, -18.0),
		Vector2(42.0, 20.0),
		Vector2(0.0, -8.0)
	)

	# Venda da Dona Quitéria (sul-oeste)
	_spawn_static(
		"VendaColonial",
		"res://assets/sprites/colonial_buildings_px/venda_colonial.png",
		Vector2(104.0, 206.0),
		Vector2(0.0, -18.0),
		Vector2(42.0, 20.0),
		Vector2(0.0, -8.0)
	)

	# Chafariz da Praça (centro da praça)
	_spawn_static(
		"ChafarizPraca",
		"res://assets/sprites/colonial_buildings_px/chafariz_colonial.png",
		Vector2(192.0, 148.0),
		Vector2(0.0, -14.0),
		Vector2(32.0, 16.0),
		Vector2(0.0, -6.0)
	)

	# Palmeiras Imperiais e Lampiões na Praça
	for p_pos in [Vector2(44.0, 74.0), Vector2(340.0, 74.0), Vector2(44.0, 224.0), Vector2(340.0, 224.0)]:
		_spawn_static(
			"VilaPalmeira",
			"res://assets/sprites/colonial_buildings_px/palmeira_imperial.png",
			p_pos,
			Vector2(0.0, -18.0),
			Vector2(10.0, 8.0),
			Vector2(0.0, -3.0)
		)

	# NPCs da Vila Colonial
	var padre_pos := Vector2(104.0, 122.0)
	_spawn_static("NPCPadre", "res://assets/sprites/colonial_buildings_px/npc_padre.png", padre_pos, Vector2(0.0, -9.0), Vector2(12.0, 8.0), Vector2(0.0, -2.0))
	_interactables.append({
		"id": "padre",
		"kind": "npc",
		"local_pos": padre_pos,
		"radius": 30.0,
		"prompt": "[F] Conversar com Padre Antônio",
	})

	var ferreiro_pos := Vector2(288.0, 124.0)
	_spawn_static("NPCFerreiro", "res://assets/sprites/colonial_buildings_px/npc_ferreiro.png", ferreiro_pos, Vector2(0.0, -9.0), Vector2(12.0, 8.0), Vector2(0.0, -2.0))
	_interactables.append({
		"id": "ferreiro",
		"kind": "npc",
		"local_pos": ferreiro_pos,
		"radius": 30.0,
		"prompt": "[F] Ferreiro Joaquim (Forja & Conversa)",
	})

	var quiteria_pos := Vector2(126.0, 218.0)
	_spawn_static("NPCQuiteria", "res://assets/sprites/colonial_buildings_px/npc_quiteria.png", quiteria_pos, Vector2(0.0, -9.0), Vector2(12.0, 8.0), Vector2(0.0, -2.0))
	_interactables.append({
		"id": "quiteria",
		"kind": "npc",
		"local_pos": quiteria_pos,
		"radius": 30.0,
		"prompt": "[F] Dona Quitéria (Venda & Conversa)",
	})

	# Chafariz da Praça também permite encher regador
	_interactables.append({
		"id": "chafariz_praca",
		"kind": "fountain",
		"local_pos": Vector2(192.0, 148.0),
		"radius": 32.0,
		"prompt": "[F] Encher Água no Chafariz",
	})


func _build_perimeter_walls() -> void:
	var w_px: float = float(VILLAGE_WIDTH * TILE_SIZE)
	var h_px: float = float(VILLAGE_HEIGHT * TILE_SIZE)
	var walls := StaticBody2D.new()
	walls.name = "VillageWalls"
	walls.collision_layer = 1
	walls.collision_mask = 0
	var segments: Array[Rect2] = [
		Rect2(0.0, -8.0, 164.0, 16.0),           # Topo esquerdo (deixa passagem central)
		Rect2(220.0, -8.0, w_px - 220.0, 16.0),  # Topo direito
		Rect2(0.0, h_px - 8.0, w_px, 16.0),      # Fundo
		Rect2(-8.0, 0.0, 16.0, h_px),            # Esquerda
		Rect2(w_px - 8.0, 0.0, 16.0, h_px),      # Direita
	]
	for seg in segments:
		var col := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = seg.size
		col.shape = shape
		col.position = seg.position + seg.size * 0.5
		walls.add_child(col)
	add_child(walls)
