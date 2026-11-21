extends Control
## Modal de Culinária Colonial no fogão de lenha da Casa-Grande.

signal close_requested()

const CookingDataScript := preload("res://scripts/data/cooking_data.gd")

var _list_vbox: VBoxContainer = null
var _status_label: Label = null


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
	panel.custom_minimum_size = Vector2(460.0, 250.0)
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

	var header := HBoxContainer.new()
	vbox.add_child(header)

	var title := Label.new()
	title.text = "Fogão de Lenha — Culinária Colonial"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 11)
	title.add_theme_color_override("font_color", Color("#3b2312"))
	header.add_child(title)

	var close_btn := Button.new()
	close_btn.text = "Fechar [ESC]"
	close_btn.add_theme_font_size_override("font_size", 9)
	close_btn.pressed.connect(func() -> void: close_requested.emit())
	header.add_child(close_btn)

	_status_label = Label.new()
	_status_label.text = "Prepare quitutes coloniais para recuperar energia ou vender por Réis!"
	_status_label.add_theme_font_size_override("font_size", 8)
	_status_label.add_theme_color_override("font_color", Color("#5c3d24"))
	vbox.add_child(_status_label)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	_list_vbox = VBoxContainer.new()
	_list_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list_vbox.add_theme_constant_override("separation", 4)
	scroll.add_child(_list_vbox)


func refresh() -> void:
	if _list_vbox == null:
		return
	for ch in _list_vbox.get_children():
		ch.queue_free()

	var gs: Node = get_node_or_null("/root/GameState")
	if gs == null:
		return

	var dishes_val: Variant = gs.get("cooked_dishes")
	var dishes: Dictionary = dishes_val if dishes_val is Dictionary else {}

	for r_id in CookingDataScript.RECIPE_ORDER:
		var rec: Dictionary = CookingDataScript.RECIPES[r_id]
		var can_cook: bool = bool(gs.call("can_cook_recipe", r_id))
		var owned_qty: int = int(dishes.get(r_id, 0))

		var row_panel := PanelContainer.new()
		var rs := StyleBoxFlat.new()
		rs.bg_color = Color("#efe0be")
		rs.border_color = Color("#a88254")
		rs.set_border_width_all(1)
		rs.set_corner_radius_all(4)
		rs.content_margin_left = 6.0
		rs.content_margin_right = 6.0
		rs.content_margin_top = 4.0
		rs.content_margin_bottom = 4.0
		row_panel.add_theme_stylebox_override("panel", rs)
		_list_vbox.add_child(row_panel)

		var hbox := HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 6)
		row_panel.add_child(hbox)

		var ing_parts: PackedStringArray = PackedStringArray()
		var ing_val: Variant = rec.get("ingredients", [])
		if ing_val is Array:
			for ing in (ing_val as Array):
				if ing is Dictionary:
					ing_parts.append(str((ing as Dictionary).get("label", "")))

		var info := Label.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.text = "%s (x%d)  |  %s  |  +%d Energia / Rs %d" % [
			str(rec["name"]),
			owned_qty,
			" + ".join(ing_parts),
			int(rec["energy"]),
			int(rec["sell_price"]),
		]
		info.add_theme_font_size_override("font_size", 8)
		info.add_theme_color_override("font_color", Color("#3b2312"))
		hbox.add_child(info)

		var cook_btn := Button.new()
		cook_btn.text = "Cozinhar"
		cook_btn.disabled = not can_cook
		cook_btn.add_theme_font_size_override("font_size", 8)
		cook_btn.pressed.connect(func() -> void:
			if bool(gs.call("cook_recipe", r_id)):
				_play_sfx("play_machine")
				refresh()
		)
		hbox.add_child(cook_btn)

		var eat_btn := Button.new()
		eat_btn.text = "Comer"
		eat_btn.disabled = owned_qty <= 0
		eat_btn.add_theme_font_size_override("font_size", 8)
		eat_btn.pressed.connect(func() -> void:
			if bool(gs.call("eat_cooked_dish", r_id)):
				_play_sfx("play_click")
				refresh()
		)
		hbox.add_child(eat_btn)

		var sell_btn := Button.new()
		sell_btn.text = "Vender"
		sell_btn.disabled = owned_qty <= 0
		sell_btn.add_theme_font_size_override("font_size", 8)
		sell_btn.pressed.connect(func() -> void:
			if bool(gs.call("sell_cooked_dish", r_id)):
				_play_sfx("play_coin")
				refresh()
		)
		hbox.add_child(sell_btn)


func _play_sfx(method_name: String) -> void:
	var audio: Node = get_node_or_null("/root/AudioManager")
	if audio != null and audio.has_method(method_name):
		audio.call(method_name)
