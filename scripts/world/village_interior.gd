extends Node2D
## Interiores jogáveis das 4 edificações principais da Vila de São Sebastião:
## Venda Secos & Molhados, Ferraria Colonial, Botica e Estalagem.

const ROOM_W: float = 288.0
const ROOM_H: float = 192.0
const SPAWN_LOCAL := Vector2(144.0, 160.0)
const EXIT_LOCAL := Vector2(144.0, 174.0)

var current_id: String = "venda"
var _interactables: Array[Dictionary] = []
var _t: float = 0.0


func _ready() -> void:
	z_index = 0
	configure("venda")


func configure(interior_id: String) -> void:
	current_id = interior_id
	_interactables.clear()
	match interior_id:
		"venda":
			_interactables = [
				{
					"id": "shop_counter",
					"prompt": "[F] Comprar Sementes & Itens (Loja)",
					"local_pos": Vector2(144.0, 88.0),
					"radius": 34.0,
				},
				{
					"id": "order_ledger",
					"prompt": "[F] Livro de Encomendas da Vila",
					"local_pos": Vector2(224.0, 96.0),
					"radius": 28.0,
				},
				{
					"id": "exit",
					"prompt": "[F] Sair para a Vila",
					"local_pos": EXIT_LOCAL,
					"radius": 24.0,
				},
			]
		"ferraria":
			_interactables = [
				{
					"id": "forge_upgrades",
					"prompt": "[F] Forja do Mestre Bento (Upgrades)",
					"local_pos": Vector2(144.0, 88.0),
					"radius": 34.0,
				},
				{
					"id": "anvil_info",
					"prompt": "[F] Bigorna (Vender Minérios +20%)",
					"local_pos": Vector2(216.0, 112.0),
					"radius": 30.0,
				},
				{
					"id": "exit",
					"prompt": "[F] Sair para a Vila",
					"local_pos": EXIT_LOCAL,
					"radius": 24.0,
				},
			]
		"botica":
			_interactables = [
				{
					"id": "buy_elixir",
					"prompt": "[F] Elixir de Ervas (Rs 65 -> +60 Energia)",
					"local_pos": Vector2(116.0, 92.0),
					"radius": 32.0,
				},
				{
					"id": "buy_tea",
					"prompt": "[F] Chá de Cidreira (Rs 35 -> +30 Energia)",
					"local_pos": Vector2(184.0, 92.0),
					"radius": 32.0,
				},
				{
					"id": "exit",
					"prompt": "[F] Sair para a Vila",
					"local_pos": EXIT_LOCAL,
					"radius": 24.0,
				},
			]
		"estalagem":
			_interactables = [
				{
					"id": "buy_meal",
					"prompt": "[F] Prato Feito Colonial (Rs 90 -> +70 Energia)",
					"local_pos": Vector2(116.0, 92.0),
					"radius": 32.0,
				},
				{
					"id": "buy_pao",
					"prompt": "[F] Pão de Queijo Quente (Rs 60 -> +45 Energia)",
					"local_pos": Vector2(188.0, 92.0),
					"radius": 32.0,
				},
				{
					"id": "exit",
					"prompt": "[F] Sair para a Vila",
					"local_pos": EXIT_LOCAL,
					"radius": 24.0,
				},
			]
	queue_redraw()


func _process(delta: float) -> void:
	if not visible:
		return
	_t += delta
	queue_redraw()


func get_camera_bounds() -> Rect2i:
	var ox: int = int(round(global_position.x))
	var oy: int = int(round(global_position.y))
	return Rect2i(ox - 16, oy, int(ROOM_W) + 32, int(ROOM_H))


func get_walk_bounds() -> Rect2:
	return Rect2(global_position.x + 22.0, global_position.y + 84.0, ROOM_W - 44.0, ROOM_H - 96.0)


func get_spawn_world_pos() -> Vector2:
	return global_position + SPAWN_LOCAL


func is_at_exit_threshold(world_pos: Vector2) -> bool:
	var lp: Vector2 = world_pos - global_position
	return absf(lp.x - 144.0) <= 18.0 and lp.y >= 168.0


func get_nearest_interactable(world_pos: Vector2) -> Dictionary:
	var best: Dictionary = {}
	var best_d: float = INF
	for entry in _interactables:
		var wp: Vector2 = global_position + (entry["local_pos"] as Vector2)
		var r: float = float(entry.get("radius", 28.0))
		var d: float = world_pos.distance_to(wp)
		if d <= r and d < best_d:
			best_d = d
			best = entry.duplicate()
			best["world_pos"] = wp
			best["anchor"] = wp + Vector2(0.0, -22.0)
	return best


func _draw() -> void:
	# Fundo escuro externo
	draw_rect(Rect2(-120.0, -80.0, ROOM_W + 240.0, ROOM_H + 160.0), Color("#150e0a"))

	var wall_col := Color("#e8dcc2")
	var floor_col := Color("#8c5e3c")
	var floor_alt := Color("#7d5232")
	var trim_col := Color("#54331d")
	var title := "Venda Secos & Molhados"

	match current_id:
		"ferraria":
			wall_col = Color("#8e877e")
			floor_col = Color("#5d5852")
			floor_alt = Color("#524d48")
			trim_col = Color("#3a2e28")
			title = "Ferraria do Mestre Bento"
		"botica":
			wall_col = Color("#cbe4d3")
			floor_col = Color("#966c49")
			floor_alt = Color("#875e3e")
			trim_col = Color("#38664b")
			title = "Botica da Dona Quitéria"
		"estalagem":
			wall_col = Color("#e6cba0")
			floor_col = Color("#7a4a2a")
			floor_alt = Color("#6c4023")
			trim_col = Color("#6e3124")
			title = "Estalagem do Zé do Cravo"

	# Paredes e piso de tábuas/pedra
	draw_rect(Rect2(8.0, 8.0, ROOM_W - 16.0, ROOM_H - 16.0), trim_col)
	draw_rect(Rect2(14.0, 14.0, ROOM_W - 28.0, 56.0), wall_col)
	draw_rect(Rect2(14.0, 70.0, ROOM_W - 28.0, ROOM_H - 84.0), floor_col)
	for py in range(74, int(ROOM_H) - 18, 12):
		draw_line(Vector2(14.0, float(py)), Vector2(ROOM_W - 14.0, float(py)), floor_alt, 1.0)

	# Tapete de saída
	draw_rect(Rect2(124.0, 162.0, 40.0, 16.0), Color("#b54634"))
	draw_rect(Rect2(127.0, 165.0, 34.0, 10.0), Color("#e2b857"), false, 1.0)

	# Balcão principal colonial
	draw_rect(Rect2(76.0, 62.0, 136.0, 20.0), Color("#422514"))
	draw_rect(Rect2(78.0, 64.0, 132.0, 14.0), Color("#a86c3e"))
	draw_rect(Rect2(78.0, 64.0, 132.0, 4.0), Color("#c98a52"))

	# Detalhes temáticos por interior
	if current_id == "venda":
		# Prateleiras de sacas e potes
		for sx in [30.0, 96.0, 180.0, 232.0]:
			draw_rect(Rect2(sx, 24.0, 34.0, 28.0), Color("#6b4022"))
			draw_rect(Rect2(sx + 4.0, 28.0, 10.0, 10.0), Color("#dfca94"))
			draw_rect(Rect2(sx + 18.0, 28.0, 10.0, 10.0), Color("#b84b34"))
			draw_rect(Rect2(sx + 6.0, 40.0, 22.0, 8.0), Color("#6d9e48"))
		# Mesa de encomendas
		draw_rect(Rect2(212.0, 82.0, 30.0, 20.0), Color("#8f5a34"))
		draw_rect(Rect2(218.0, 86.0, 16.0, 10.0), Color("#f6ebd2"))
	elif current_id == "ferraria":
		# Forja com brasa animada
		draw_rect(Rect2(30.0, 22.0, 46.0, 42.0), Color("#3c3634"))
		var fl: float = sin(_t * 10.0) * 2.0
		draw_rect(Rect2(38.0, 40.0, 30.0, 18.0), Color("#e65100"))
		draw_rect(Rect2(42.0, 44.0 - fl * 0.4, 22.0, 12.0), Color("#ffca28"))
		draw_circle(Vector2(53.0, 48.0), 22.0 + fl, Color(1.0, 0.55, 0.12, 0.22))
		# Bigorna
		draw_rect(Rect2(204.0, 102.0, 26.0, 12.0), Color("#373a40"))
		draw_rect(Rect2(210.0, 114.0, 14.0, 8.0), Color("#26282e"))
	elif current_id == "botica":
		# Frascos coloridos de ervas medicinais
		var potion_cols: Array[Color] = [Color("#43a047"), Color("#29b6f6"), Color("#ab47bc"), Color("#ffa726")]
		for i in range(4):
			var fx: float = 34.0 + float(i) * 60.0
			draw_rect(Rect2(fx, 24.0, 40.0, 24.0), Color("#5c3a21"))
			draw_rect(Rect2(fx + 6.0, 28.0, 8.0, 14.0), potion_cols[i])
			draw_rect(Rect2(fx + 22.0, 28.0, 8.0, 14.0), potion_cols[(i + 1) % 4])
		# Vasos de ervas no balcão
		draw_circle(Vector2(116.0, 70.0), 6.0, Color("#4caf50"))
		draw_circle(Vector2(184.0, 70.0), 6.0, Color("#ffee58"))
	elif current_id == "estalagem":
		# Lareira quente + mesas com canecas
		draw_rect(Rect2(26.0, 22.0, 40.0, 38.0), Color("#4e342e"))
		draw_circle(Vector2(46.0, 48.0), 12.0 + sin(_t * 8.0) * 1.5, Color(1.0, 0.65, 0.18, 0.45))
		draw_rect(Rect2(36.0, 42.0, 20.0, 14.0), Color("#ff8f00"))
		for tx in [48.0, 214.0]:
			draw_rect(Rect2(tx, 112.0, 34.0, 22.0), Color("#6d3f22"))
			draw_rect(Rect2(tx + 4.0, 115.0, 26.0, 16.0), Color("#9c6238"))
			draw_rect(Rect2(tx + 10.0, 119.0, 5.0, 6.0), Color("#ffd54f"))

	# Placa de título sutil no topo
	draw_rect(Rect2(88.0, 16.0, 112.0, 14.0), Color(0.22, 0.13, 0.08, 0.85))
	var fnt: Font = ThemeDB.fallback_font
	if fnt != null:
		draw_string(fnt, Vector2(94.0, 26.0), title, HORIZONTAL_ALIGNMENT_LEFT, 102.0, 8, Color("#f7e7c4"))
