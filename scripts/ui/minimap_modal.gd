extends Control
## Minimapa colonial em pergaminho (tecla M) exibindo Fazenda, Vila de São Sebastião,
## Vale do Ribeirão, posição do jogador e rotina em tempo real dos 8 moradores.

signal close_requested()

const MAP_W_TILES: float = 68.0
const MAP_H_TILES: float = 38.0
const TILE_PX: float = 16.0
const MAP_DRAW_W: float = 340.0
const MAP_DRAW_H: float = 190.0

var _snapshot: Dictionary = {}
var _map_canvas: Control = null
var _roster_label: RichTextLabel = null
var _header_label: Label = null
var _pulse_time: float = 0.0


class MapCanvas extends Control:
	var snapshot: Dictionary = {}
	var pulse: float = 0.0

	func _draw() -> void:
		var sx: float = size.x / (MAP_W_TILES * TILE_PX)
		var sy: float = size.y / (MAP_H_TILES * TILE_PX)

		# Fundo de grama colonial
		draw_rect(Rect2(Vector2.ZERO, size), Color("#6fa34f"))

		# Divisórias sutis das 3 regiões
		draw_rect(Rect2(40.0 * TILE_PX * sx, 0.0, 28.0 * TILE_PX * sx, 24.0 * TILE_PX * sy), Color("#79ab58"))
		draw_rect(Rect2(0.0, 24.0 * TILE_PX * sy, size.x, 14.0 * TILE_PX * sy), Color("#639448"))

		# Canteiro arável (Fazenda)
		draw_rect(Rect2(12.0 * TILE_PX * sx, 9.0 * TILE_PX * sy, 12.0 * TILE_PX * sx, 7.0 * TILE_PX * sy), Color("#9d7042"))
		# Curral dos animais
		draw_rect(Rect2(27.0 * TILE_PX * sx, 4.0 * TILE_PX * sy, 9.0 * TILE_PX * sx, 6.0 * TILE_PX * sy), Color("#89a654"))

		# Estradas principais
		var road_col := Color("#c8a876")
		draw_rect(Rect2(4.0 * TILE_PX * sx, 6.0 * TILE_PX * sy, 25.0 * TILE_PX * sx, 1.4 * TILE_PX * sy), road_col)
		draw_rect(Rect2(26.0 * TILE_PX * sx, 11.0 * TILE_PX * sy, 38.0 * TILE_PX * sx, 2.0 * TILE_PX * sy), road_col)
		draw_rect(Rect2(17.0 * TILE_PX * sx, 17.0 * TILE_PX * sy, 2.0 * TILE_PX * sx, 17.0 * TILE_PX * sy), road_col)
		draw_rect(Rect2(9.0 * TILE_PX * sx, 29.0 * TILE_PX * sy, 42.0 * TILE_PX * sx, 2.0 * TILE_PX * sy), road_col)
		draw_rect(Rect2(48.0 * TILE_PX * sx, 8.0 * TILE_PX * sy, 2.0 * TILE_PX * sx, 23.0 * TILE_PX * sy), road_col)
		# Praça do Coreto (pedra pé-de-moleque)
		draw_rect(Rect2(47.0 * TILE_PX * sx, 9.0 * TILE_PX * sy, 11.0 * TILE_PX * sx, 7.0 * TILE_PX * sy), Color("#b4ada0"))

		# Lago + Ribeirão Colonial
		var water_col := Color("#3f88c5")
		draw_rect(Rect2(29.0 * TILE_PX * sx, 14.0 * TILE_PX * sy, 7.0 * TILE_PX * sx, 6.0 * TILE_PX * sy), water_col)
		draw_rect(Rect2(32.0 * TILE_PX * sx, 20.0 * TILE_PX * sy, 3.0 * TILE_PX * sx, 4.0 * TILE_PX * sy), water_col)
		draw_rect(Rect2(33.0 * TILE_PX * sx, 24.0 * TILE_PX * sy, 5.0 * TILE_PX * sx, 12.0 * TILE_PX * sy), water_col)
		# Ponte de madeira sobre o Ribeirão
		draw_rect(Rect2(33.0 * TILE_PX * sx, 29.0 * TILE_PX * sy, 5.0 * TILE_PX * sx, 2.0 * TILE_PX * sy), Color("#9a6234"))

		# Edificações (Fazenda + Vila + Vale)
		var buildings: Array[Rect2] = [
			Rect2(6.5, 4.0, 3.0, 2.0),   # Casa-Grande
			Rect2(3.5, 4.0, 2.0, 2.0),   # Capela
			Rect2(19.0, 4.0, 2.5, 1.8),  # Engenho
			Rect2(24.5, 4.0, 2.2, 1.8),  # Casa de Farinha
			Rect2(4.0, 15.0, 2.2, 1.8),  # Paiol
			Rect2(43.0, 5.5, 3.0, 2.0),  # Venda
			Rect2(51.0, 5.5, 3.0, 2.0),  # Ferraria
			Rect2(59.0, 5.5, 2.8, 2.0),  # Botica
			Rect2(51.3, 11.2, 2.4, 2.0), # Coreto
			Rect2(43.0, 17.5, 2.8, 2.0), # Casa Pescador
			Rect2(51.0, 17.5, 2.8, 2.0), # Casa Tecelã
			Rect2(59.0, 17.5, 3.0, 2.0), # Estalagem
			Rect2(9.0, 26.5, 2.8, 2.0),  # Casa Paroquial
			Rect2(23.0, 26.5, 2.8, 2.0), # Casa Roceiro
		]
		for br in buildings:
			var r := Rect2(br.position.x * TILE_PX * sx, br.position.y * TILE_PX * sy, br.size.x * TILE_PX * sx, br.size.y * TILE_PX * sy)
			draw_rect(r, Color("#b84b34"))
			draw_rect(r, Color("#3a2016"), false, 1.0)

		# Tropeiro (quando presente)
		if bool(snapshot.get("tropeiro_present", false)):
			var t_pos := Vector2(19.5 * TILE_PX * sx, 20.5 * TILE_PX * sy)
			draw_circle(t_pos, 3.2, Color("#ffd54f"))
			draw_circle(t_pos, 1.8, Color("#7c4dff"))

		# 8 Moradores em tempo real
		var v_list: Variant = snapshot.get("villagers", [])
		if v_list is Array:
			for v_var in (v_list as Array):
				if not (v_var is Dictionary):
					continue
				var vd := v_var as Dictionary
				var vp: Variant = vd.get("pos", Vector2.ZERO)
				if not (vp is Vector2):
					continue
				var pos2: Vector2 = vp as Vector2
				var mx: float = clampf(pos2.x * sx, 3.0, size.x - 3.0)
				var my: float = clampf(pos2.y * sy, 3.0, size.y - 3.0)
				var is_in: bool = bool(vd.get("indoors", false))
				var dot_col: Color = Color("#9e9e9e") if is_in else Color("#ff7043")
				draw_circle(Vector2(mx, my), 3.0, Color("#24150d"))
				draw_circle(Vector2(mx, my), 2.1, dot_col)

		# Posição do Fazendeiro (pulsante)
		var p_val: Variant = snapshot.get("player_pos", Vector2(136.0, 118.0))
		if p_val is Vector2:
			var pp: Vector2 = p_val as Vector2
			var px: float = clampf(pp.x * sx, 4.0, size.x - 4.0)
			var py: float = clampf(pp.y * sy, 4.0, size.y - 4.0)
			var rad: float = 4.2 + sin(pulse * 5.5) * 1.1
			draw_circle(Vector2(px, py), rad, Color(1.0, 0.94, 0.35, 0.45))
			draw_circle(Vector2(px, py), 3.2, Color("#1b120c"))
			draw_circle(Vector2(px, py), 2.2, Color("#ffe84d"))

		# Borda do mapa
		draw_rect(Rect2(Vector2.ZERO, size), Color("#4a2e1a"), false, 2.0)


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP

	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.06, 0.04, 0.03, 0.62)
	add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(540.0, 268.0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#f6ebd2")
	style.border_color = Color("#6b4423")
	style.set_border_width_all(3)
	style.set_corner_radius_all(6)
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	var top_bar := HBoxContainer.new()
	vbox.add_child(top_bar)

	_header_label = Label.new()
	_header_label.text = "Mapa da Freguesia — Fazenda, Vila de São Sebastião & Vale"
	_header_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_header_label.add_theme_font_size_override("font_size", 11)
	_header_label.add_theme_color_override("font_color", Color("#3b2312"))
	top_bar.add_child(_header_label)

	var close_btn := Button.new()
	close_btn.text = "Fechar [M]"
	close_btn.add_theme_font_size_override("font_size", 9)
	close_btn.pressed.connect(func() -> void: close_requested.emit())
	top_bar.add_child(close_btn)

	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 10)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(body)

	var map_holder := VBoxContainer.new()
	map_holder.add_theme_constant_override("separation", 3)
	body.add_child(map_holder)

	_map_canvas = MapCanvas.new()
	_map_canvas.custom_minimum_size = Vector2(MAP_DRAW_W, MAP_DRAW_H)
	map_holder.add_child(_map_canvas)

	var legend := Label.new()
	legend.text = "● Amarelo: Você   ● Laranja: Moradores   ● Cinza: Em casa   ● Dourado: Tropeiro"
	legend.add_theme_font_size_override("font_size", 8)
	legend.add_theme_color_override("font_color", Color("#5c3d24"))
	map_holder.add_child(legend)

	var roster_panel := PanelContainer.new()
	roster_panel.custom_minimum_size = Vector2(168.0, 206.0)
	roster_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var r_style := StyleBoxFlat.new()
	r_style.bg_color = Color("#efe0be")
	r_style.border_color = Color("#9b7244")
	r_style.set_border_width_all(1)
	r_style.set_corner_radius_all(4)
	r_style.content_margin_left = 6.0
	r_style.content_margin_right = 6.0
	r_style.content_margin_top = 4.0
	r_style.content_margin_bottom = 4.0
	roster_panel.add_theme_stylebox_override("panel", r_style)
	body.add_child(roster_panel)

	_roster_label = RichTextLabel.new()
	_roster_label.bbcode_enabled = true
	_roster_label.fit_content = false
	_roster_label.scroll_active = true
	_roster_label.add_theme_font_size_override("normal_font_size", 8)
	_roster_label.add_theme_color_override("default_color", Color("#3a2210"))
	roster_panel.add_child(_roster_label)


func _process(delta: float) -> void:
	if not visible:
		return
	_pulse_time += delta
	if _map_canvas != null:
		_map_canvas.set("pulse", _pulse_time)
		_map_canvas.queue_redraw()


func update_snapshot(data: Dictionary) -> void:
	_snapshot = data
	if _map_canvas != null:
		_map_canvas.set("snapshot", data)
		_map_canvas.queue_redraw()

	if _header_label != null:
		var fest_name: String = str(data.get("festival_name", ""))
		if not fest_name.is_empty():
			_header_label.text = "Mapa da Freguesia — HOJE: %s na Praça!" % fest_name
		else:
			_header_label.text = "Mapa da Freguesia — Fazenda, Vila de São Sebastião & Vale"

	if _roster_label != null:
		var lines: PackedStringArray = PackedStringArray()
		lines.append("[b]Moradores da Vila[/b]")
		var v_list: Variant = data.get("villagers", [])
		if v_list is Array:
			for v_var in (v_list as Array):
				if not (v_var is Dictionary):
					continue
				var vd := v_var as Dictionary
				var vname: String = str(vd.get("name", ""))
				var hearts: int = int(vd.get("hearts", 0))
				var act: String = str(vd.get("activity", ""))
				var h_str: String = ""
				for i in range(hearts):
					h_str += "♥"
				var h_part: String = (" [color=#c62828]" + h_str + "[/color]") if not h_str.is_empty() else ""
				lines.append("[b]%s[/b]%s\n[color=#6e4e2e]%s[/color]" % [vname, h_part, act])
		_roster_label.text = "\n".join(lines)
