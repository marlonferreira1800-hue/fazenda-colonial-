extends Node2D
## Mina / Gruta do Ouro Colonial — sala subterrânea iluminada por tochas
## com veios renováveis diariamente de Pedra, Ferro e Ouro Colonial.

const ROOM_W: float = 288.0
const ROOM_H: float = 192.0
const SPAWN_LOCAL := Vector2(144.0, 160.0)
const EXIT_LOCAL := Vector2(144.0, 174.0)

var _veins: Array[Dictionary] = []
var _t: float = 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	z_index = 0
	reset_daily()


func reset_daily() -> void:
	_veins.clear()
	var spots: Array[Vector2] = [
		Vector2(54.0, 74.0),
		Vector2(98.0, 62.0),
		Vector2(150.0, 56.0),
		Vector2(204.0, 64.0),
		Vector2(240.0, 82.0),
		Vector2(66.0, 118.0),
		Vector2(116.0, 108.0),
		Vector2(178.0, 106.0),
		Vector2(226.0, 124.0),
		Vector2(92.0, 142.0),
	]
	for i in range(spots.size()):
		var roll: float = _rng.randf()
		var ore_id: String = "pedra"
		var ore_name: String = "Pedra"
		var col := Color("#9e9e9e")
		if roll < 0.22:
			ore_id = "ouro_colonial"
			ore_name = "Ouro Colonial ★"
			col = Color("#ffd54f")
		elif roll < 0.56:
			ore_id = "ferro"
			ore_name = "Minério de Ferro"
			col = Color("#90a4ae")
		_veins.append({
			"idx": i,
			"local_pos": spots[i],
			"ore_id": ore_id,
			"ore_name": ore_name,
			"color": col,
			"mined": false,
		})
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
	return Rect2(global_position.x + 24.0, global_position.y + 44.0, ROOM_W - 48.0, ROOM_H - 56.0)


func get_spawn_world_pos() -> Vector2:
	return global_position + SPAWN_LOCAL


func is_at_exit_threshold(world_pos: Vector2) -> bool:
	var lp: Vector2 = world_pos - global_position
	return absf(lp.x - 144.0) <= 20.0 and lp.y >= 168.0


func get_nearest_interactable(world_pos: Vector2) -> Dictionary:
	var exit_wp: Vector2 = global_position + EXIT_LOCAL
	if world_pos.distance_to(exit_wp) <= 24.0:
		return {
			"id": "exit",
			"prompt": "[F] Sair da Mina do Ouro",
			"world_pos": exit_wp,
			"anchor": exit_wp + Vector2(0.0, -22.0),
		}
	var best: Dictionary = {}
	var best_d: float = 28.0
	for v in _veins:
		if bool(v["mined"]):
			continue
		var wp: Vector2 = global_position + (v["local_pos"] as Vector2)
		var d: float = world_pos.distance_to(wp)
		if d <= best_d:
			best_d = d
			best = {
				"id": "vein",
				"vein_idx": int(v["idx"]),
				"ore_id": str(v["ore_id"]),
				"ore_name": str(v["ore_name"]),
				"prompt": "[F] Minerar %s (-4 Energia)" % str(v["ore_name"]),
				"world_pos": wp,
				"anchor": wp + Vector2(0.0, -18.0),
			}
	return best


func mine_vein(vein_idx: int) -> Dictionary:
	if vein_idx < 0 or vein_idx >= _veins.size():
		return {}
	var v: Dictionary = _veins[vein_idx]
	if bool(v["mined"]):
		return {}
	v["mined"] = true
	queue_redraw()
	return v


func _draw() -> void:
	# Fundo rochoso escuro
	draw_rect(Rect2(-120.0, -80.0, ROOM_W + 240.0, ROOM_H + 160.0), Color("#0d0b0c"))
	# Paredes e chão da gruta
	draw_rect(Rect2(10.0, 10.0, ROOM_W - 20.0, ROOM_H - 20.0), Color("#2c2629"))
	draw_rect(Rect2(18.0, 34.0, ROOM_W - 36.0, ROOM_H - 48.0), Color("#463f42"))
	# Trilhos e vigas de madeira coloniais
	draw_rect(Rect2(124.0, 158.0, 40.0, 20.0), Color("#5c3a21"))
	draw_line(Vector2(132.0, 158.0), Vector2(132.0, 178.0), Color("#90a4ae"), 2.0)
	draw_line(Vector2(156.0, 158.0), Vector2(156.0, 178.0), Color("#90a4ae"), 2.0)

	# Tochas acesas nas paredes
	for tx in [40.0, 144.0, 248.0]:
		var fl: float = sin(_t * 11.0 + tx) * 1.5
		draw_rect(Rect2(tx - 2.0, 20.0, 4.0, 12.0), Color("#6d4123"))
		draw_circle(Vector2(tx, 19.0), 18.0 + fl, Color(1.0, 0.65, 0.20, 0.22))
		draw_circle(Vector2(tx, 19.0), 4.0 + fl * 0.3, Color("#ffab00"))

	# Veios mineráveis
	for v in _veins:
		var pos: Vector2 = v["local_pos"]
		if bool(v["mined"]):
			draw_circle(pos, 5.0, Color("#332d30"))
			continue
		var col: Color = v["color"]
		draw_circle(pos + Vector2(0.0, 2.0), 8.5, Color("#1f1a1c"))
		draw_circle(pos, 7.5, Color("#60585c"))
		draw_rect(Rect2(pos.x - 4.0, pos.y - 3.0, 4.0, 3.0), col)
		draw_rect(Rect2(pos.x + 1.0, pos.y - 1.0, 3.5, 3.5), col)
		if str(v["ore_id"]) == "ouro_colonial":
			var sp: float = 0.5 + 0.5 * sin(_t * 6.0 + pos.x)
			draw_circle(pos + Vector2(-2.0, -2.0), 2.0, Color(1.0, 0.96, 0.65, sp))

	var fnt: Font = ThemeDB.fallback_font
	if fnt != null:
		draw_string(fnt, Vector2(90.0, 26.0), "Mina do Ouro Colonial", HORIZONTAL_ALIGNMENT_LEFT, 120.0, 8, Color("#ffe082"))
