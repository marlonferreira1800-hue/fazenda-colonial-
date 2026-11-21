extends Node
## Autoload global de estado de jogo, inventário, economia, persistência e relógio diário.

const CropDataScript := preload("res://scripts/data/crop_data.gd")
const FarmCatalogScript := preload("res://scripts/data/farm_catalog.gd")
const SeasonDataScript := preload("res://scripts/data/season_data.gd")
const CookingDataScript := preload("res://scripts/data/cooking_data.gd")

signal money_changed(new_money: int)
signal day_changed(day: int, time_minutes: float)
signal inventory_changed()
signal tool_changed(slot_index: int)
signal stamina_changed(stamina: int, max_stamina: int)
signal water_changed(water: int, max_water: int)
signal toast_message(text: String)
signal day_advanced(new_day: int)
signal upgrades_changed()
signal weather_changed(weather: String, tomorrow_weather: String)
signal touch_mode_changed(mode: String)
signal orders_changed()
signal album_changed()
signal machines_changed()
signal animal_purchased(animal_type: String)
signal game_reset()
const StoryDataScript := preload("res://scripts/data/story_data.gd")
signal season_changed(season_id: String, year: int)
signal story_changed()

const SAVE_PATH := "user://savegame.json"
const MINUTES_PER_DAY: float = 1440.0
const START_OF_DAY_MINUTES: float = 360.0
const TIME_SCALE_MINUTES_PER_SECOND: float = 4.0

const WEATHER_SUNNY := "sunny"
const WEATHER_RAINY := "rainy"
const SPRINKLER_PRICE: int = 180

const HOTBAR_SLOTS: Array[Dictionary] = [
	{"id": "hoe", "name": "Enxada", "type": "tool", "sheet": "base", "icon_col": 0, "key_hint": "1"},
	{"id": "watering_can", "name": "Regador", "type": "tool", "sheet": "base", "icon_col": 1, "key_hint": "2"},
	{"id": "fishing_rod", "name": "Vara de Pesca", "type": "tool", "sheet": "v13", "icon_col": 0, "key_hint": "3"},
	{"id": "wheat_seed", "name": "Muda de Cana", "type": "seed", "crop_id": "wheat", "sheet": "base", "icon_col": 2, "key_hint": "4"},
	{"id": "carrot_seed", "name": "Maniva (Mandioca)", "type": "seed", "crop_id": "carrot", "sheet": "base", "icon_col": 3, "key_hint": "5"},
	{"id": "strawberry_seed", "name": "Sem. Tabaco", "type": "seed", "crop_id": "strawberry", "sheet": "base", "icon_col": 4, "key_hint": "6"},
	{"id": "corn_seed", "name": "Sem. Milho", "type": "seed", "crop_id": "corn", "sheet": "base", "icon_col": 8, "key_hint": "7"},
	{"id": "tomato_seed", "name": "Sem. Feijão", "type": "seed", "crop_id": "tomato", "sheet": "base", "icon_col": 9, "key_hint": "8"},
	{"id": "pumpkin_seed", "name": "Sem. Algodão", "type": "seed", "crop_id": "pumpkin", "sheet": "base", "icon_col": 10, "key_hint": "9"},
	{"id": "fertilizer", "name": "Adubo Orgânico", "type": "supply", "supply_id": "fertilizer", "sheet": "v13", "icon_col": 4, "key_hint": "0"},
	{"id": "sprinkler", "name": "Rega Canalizada", "type": "placeable", "sheet": "base", "icon_col": 11, "key_hint": "-"},
	{"id": "turnip_seed", "name": "Muda de Café", "type": "seed", "crop_id": "turnip", "sheet": "turnip", "icon_col": 0, "key_hint": "="},
]

var ANIMAL_PRODUCTS: Dictionary = FarmCatalogScript.ANIMAL_PRODUCTS
var FISH: Dictionary = FarmCatalogScript.FISH
var ARTISAN: Dictionary = FarmCatalogScript.ARTISAN

const UPGRADE_DEFS: Dictionary = {
	"hoe": {
		"name": "Enxada",
		"max_level": 3,
		"costs": [150, 350],
		"descriptions": ["Ara 1x1", "Ara 3x1 em linha", "Ara 3x3 em área"],
	},
	"can": {
		"name": "Regador",
		"max_level": 3,
		"costs": [150, 350],
		"descriptions": ["20 água (1x1)", "40 água (3x1)", "60 água (3x3)"],
	},
	"stamina": {
		"name": "Resistência",
		"max_level": 3,
		"costs": [120, 280],
		"descriptions": ["100 Energia", "140 Energia", "180 Energia"],
	},
}

var CROPS: Dictionary = CropDataScript.get_all_definitions()

var money: int = 100
var day: int = 1
var time_minutes: float = START_OF_DAY_MINUTES
var time_paused: bool = false
var time_speed_multiplier: float = 1.0
var stamina: int = 100
var max_stamina: int = 100
var water_level: int = 20
var max_water: int = 20
var selected_slot: int = 0

var hoe_level: int = 1
var can_level: int = 1
var stamina_level: int = 1
var sprinklers_owned: int = 0

var weather: String = WEATHER_SUNNY
var tomorrow_weather: String = WEATHER_SUNNY
var touch_mode: String = "auto"

## Calendário das 4 estações (derivado de `day`: 28 dias por estação, 112 por ano).
var current_season: String = "spring"
var day_of_season: int = 1
var year: int = 1

var seeds: Dictionary = {
	"wheat": 6,
	"carrot": 4,
	"strawberry": 2,
	"corn": 0,
	"tomato": 0,
	"pumpkin": 0,
	"turnip": 0,
}
var harvested: Dictionary = {
	"wheat": 0,
	"carrot": 0,
	"strawberry": 0,
	"corn": 0,
	"tomato": 0,
	"pumpkin": 0,
	"turnip": 0,
}
var animal_products: Dictionary = {
	"egg": 0,
	"blue_egg": 0,
	"milk": 0,
	"wool": 0,
	"truffle": 0,
}
var fish: Dictionary = {
	"tilapia": 0,
	"shrimp": 0,
	"trout": 0,
	"golden_carp": 0,
}
var artisan: Dictionary = {
	"cheese": 0,
	"bread": 0,
	"honey": 0,
	"farinha_mandioca": 0,
	"rolo_fumo": 0,
	"saca_cafe": 0,
}
var supplies: Dictionary = {
	"fertilizer": 2,
}
var cooked_dishes: Dictionary = {
	"caldo_cana": 0,
	"cafe_coado": 0,
	"bolo_fuba": 0,
	"peixe_assado": 0,
	"pao_de_queijo": 0,
}
var minerals: Dictionary = {
	"pedra": 0,
	"ferro": 0,
	"ouro_colonial": 0,
}
var unlocked_plots: Array[String] = []
var pet_type: String = ""
var story_quests: Dictionary = {}
var npc_hearts: Dictionary = {
	"padre": 0,
	"ferreiro": 0,
	"quiteria": 0,
}
var npc_talked_today: Dictionary = {}
var folklore_discovered: Array[String] = []
var book_chapters_read: Array[String] = []
var book_bonus_claimed_today: bool = false
var gold_items: Dictionary = {}

var owned_machines: Dictionary = {
	"cheese_press": false,
	"bakery_oven": false,
	"bee_hive": false,
}
# machine_id -> {"busy": bool, "ready": bool, "remaining": float, "output_id": String}
var machine_states: Dictionary = {}

var daily_orders: Array[Dictionary] = []
var album_discovered: Dictionary = {}
var animal_count: int = 5

var auto_save_enabled: bool = true

var _last_emitted_minute: int = int(START_OF_DAY_MINUTES)
var _world_state_provider: Callable = Callable()
var _pending_world_save: Dictionary = {}
var _weather_rng := RandomNumberGenerator.new()


func _ready() -> void:
	_weather_rng.randomize()
	var loaded := load_game()
	_sync_season_from_day()
	if not loaded or daily_orders.is_empty():
		_generate_daily_orders()


func _process(delta: float) -> void:
	tick_time(delta)


func _get_audio() -> Node:
	if not is_inside_tree():
		return null
	return get_node_or_null("/root/AudioManager")


func _sync_caps_from_levels() -> void:
	var stamina_caps := [100, 140, 180]
	var water_caps := [20, 40, 60]
	max_stamina = stamina_caps[clampi(stamina_level - 1, 0, stamina_caps.size() - 1)]
	max_water = water_caps[clampi(can_level - 1, 0, water_caps.size() - 1)]


func tick_time(delta: float) -> void:
	if time_paused or delta <= 0.0:
		return
	var adv_minutes: float = delta * TIME_SCALE_MINUTES_PER_SECOND * time_speed_multiplier
	time_minutes += adv_minutes
	_tick_machines(adv_minutes)
	if time_minutes >= MINUTES_PER_DAY:
		advance_day()
		return
	var current_minute: int = int(floor(time_minutes))
	if current_minute != _last_emitted_minute:
		_last_emitted_minute = current_minute
		day_changed.emit(day, time_minutes)


func _tick_machines(adv_minutes: float) -> void:
	var speed_mult: float = 1.3 if has_album_bonus("artisan") else 1.0
	var changed: bool = false
	for machine_id_var in machine_states.keys():
		var machine_id: String = str(machine_id_var)
		var st: Dictionary = machine_states[machine_id]
		if bool(st.get("busy", false)) and not bool(st.get("ready", false)):
			var rem: float = float(st.get("remaining", 0.0)) - adv_minutes * speed_mult
			if rem <= 0.0:
				st["remaining"] = 0.0
				st["busy"] = false
				st["ready"] = true
				changed = true
			else:
				st["remaining"] = rem
	if changed:
		machines_changed.emit()


func set_time_speed_multiplier(mult: float) -> void:
	time_speed_multiplier = clampf(mult, 0.5, 2.0)
	if auto_save_enabled:
		save_game(false)


func is_raining() -> bool:
	return weather == WEATHER_RAINY


func select_slot(idx: int) -> void:
	if idx < 0 or idx >= HOTBAR_SLOTS.size():
		return
	selected_slot = idx
	tool_changed.emit(selected_slot)


func get_selected_slot() -> Dictionary:
	if selected_slot >= 0 and selected_slot < HOTBAR_SLOTS.size():
		return HOTBAR_SLOTS[selected_slot]
	return HOTBAR_SLOTS[0]


func buy_seed(crop_id: String, qty: int = 1) -> bool:
	if qty <= 0 or not CROPS.has(crop_id):
		return false
	var crop: Dictionary = CROPS[crop_id]
	var cost: int = int(crop["seed_price"]) * qty
	var audio := _get_audio()
	if money < cost:
		if audio != null and audio.has_method("play_error"):
			audio.play_error()
		emit_toast("Réis insuficientes! Precisa de Rs %d." % cost)
		return false
	money -= cost
	seeds[crop_id] = int(seeds.get(crop_id, 0)) + qty
	money_changed.emit(money)
	inventory_changed.emit()
	if audio != null and audio.has_method("play_coin"):
		audio.play_coin()
	emit_toast("Comprou %dx Semente de %s (-$%d)" % [qty, str(crop["name"]), cost])
	if auto_save_enabled:
		save_game(false)
	return true


func get_upgrade_level(upgrade_id: String) -> int:
	match upgrade_id:
		"hoe":
			return hoe_level
		"can":
			return can_level
		"stamina":
			return stamina_level
	return 1


func get_upgrade_cost(upgrade_id: String) -> int:
	if not UPGRADE_DEFS.has(upgrade_id):
		return -1
	var def: Dictionary = UPGRADE_DEFS[upgrade_id]
	var lvl: int = get_upgrade_level(upgrade_id)
	var max_lvl: int = int(def["max_level"])
	if lvl >= max_lvl:
		return -1
	var costs: Array = def["costs"]
	var idx: int = lvl - 1
	if idx < 0 or idx >= costs.size():
		return -1
	return int(costs[idx])


func buy_upgrade(upgrade_id: String) -> bool:
	if not UPGRADE_DEFS.has(upgrade_id):
		return false
	var cost: int = get_upgrade_cost(upgrade_id)
	var audio := _get_audio()
	if cost < 0:
		emit_toast("Upgrade já está no nível máximo!")
		return false
	if money < cost:
		if audio != null and audio.has_method("play_error"):
			audio.play_error()
		emit_toast("Réis insuficientes! Precisa de Rs %d." % cost)
		return false

	money -= cost
	match upgrade_id:
		"hoe":
			hoe_level = mini(3, hoe_level + 1)
		"can":
			can_level = mini(3, can_level + 1)
			_sync_caps_from_levels()
			water_level = max_water
			water_changed.emit(water_level, max_water)
		"stamina":
			stamina_level = mini(3, stamina_level + 1)
			_sync_caps_from_levels()
			stamina = max_stamina
			stamina_changed.emit(stamina, max_stamina)

	_sync_caps_from_levels()
	money_changed.emit(money)
	upgrades_changed.emit()
	if audio != null and audio.has_method("play_upgrade"):
		audio.play_upgrade()
	elif audio != null and audio.has_method("play_coin"):
		audio.play_coin()
	var def: Dictionary = UPGRADE_DEFS[upgrade_id]
	var new_lvl: int = get_upgrade_level(upgrade_id)
	emit_toast("%s evoluída para Nv.%d! (-$%d)" % [str(def["name"]), new_lvl, cost])
	if auto_save_enabled:
		save_game(false)
	return true


func buy_sprinkler(qty: int = 1) -> bool:
	if qty <= 0:
		return false
	var cost: int = SPRINKLER_PRICE * qty
	var audio := _get_audio()
	if money < cost:
		if audio != null and audio.has_method("play_error"):
			audio.play_error()
		emit_toast("Réis insuficientes! Precisa de Rs %d." % cost)
		return false
	money -= cost
	sprinklers_owned += qty
	money_changed.emit(money)
	inventory_changed.emit()
	if audio != null and audio.has_method("play_coin"):
		audio.play_coin()
	emit_toast("Comprou %dx Aspersor (-$%d)! Selecione o slot '-'." % [qty, cost])
	if auto_save_enabled:
		save_game(false)
	return true


func _spend_money(cost: int) -> bool:
	var audio := _get_audio()
	if money < cost:
		if audio != null and audio.has_method("play_error"):
			audio.play_error()
		emit_toast("Réis insuficientes! Precisa de Rs %d." % cost)
		return false
	money -= cost
	money_changed.emit(money)
	if audio != null and audio.has_method("play_coin"):
		audio.play_coin()
	return true


func buy_supply(supply_id: String, qty: int = 1) -> bool:
	if qty <= 0 or not FarmCatalogScript.SUPPLIES.has(supply_id):
		return false
	var info: Dictionary = FarmCatalogScript.SUPPLIES[supply_id]
	var cost: int = int(info.get("buy_price", 15)) * qty
	if not _spend_money(cost):
		return false
	supplies[supply_id] = int(supplies.get(supply_id, 0)) + qty
	inventory_changed.emit()
	emit_toast("Comprou %dx %s (-$%d)" % [qty, str(info.get("name", supply_id)), cost])
	if auto_save_enabled:
		save_game(false)
	return true


func buy_machine(machine_id: String) -> bool:
	if not FarmCatalogScript.MACHINES.has(machine_id):
		return false
	if bool(owned_machines.get(machine_id, false)):
		emit_toast("Você já instalou esta máquina!")
		return false
	var m_def: Dictionary = FarmCatalogScript.MACHINES[machine_id]
	var cost: int = int(m_def.get("buy_price", 150))
	if not _spend_money(cost):
		return false
	owned_machines[machine_id] = true
	if machine_id == "bee_hive":
		machine_states[machine_id] = {"busy": false, "ready": true, "remaining": 0.0, "output_id": "honey"}
	else:
		machine_states[machine_id] = {"busy": false, "ready": false, "remaining": 0.0, "output_id": str(m_def.get("output_id", ""))}
	machines_changed.emit()
	emit_toast("%s instalada na fazenda!" % str(m_def.get("name", machine_id)))
	if auto_save_enabled:
		save_game(false)
	return true


func buy_animal(animal_type: String) -> bool:
	if not FarmCatalogScript.ANIMAL_SHOP.has(animal_type):
		return false
	if animal_count >= FarmCatalogScript.MAX_FARM_ANIMALS:
		var audio := _get_audio()
		if audio != null and audio.has_method("play_error"):
			audio.play_error()
		emit_toast("Cercado cheio! (Máx. %d animais)" % FarmCatalogScript.MAX_FARM_ANIMALS)
		return false
	var def: Dictionary = FarmCatalogScript.ANIMAL_SHOP[animal_type]
	var cost: int = int(def.get("buy_price", 100))
	if not _spend_money(cost):
		return false
	animal_count += 1
	animal_purchased.emit(animal_type)
	emit_toast("Novo animal (%s) chegou ao cercado!" % str(def.get("name", animal_type)))
	if auto_save_enabled:
		save_game(false)
	return true


func add_sprinkler(qty: int = 1) -> void:
	if qty <= 0:
		return
	sprinklers_owned += qty
	inventory_changed.emit()


func consume_sprinkler_item() -> bool:
	if sprinklers_owned <= 0:
		return false
	sprinklers_owned -= 1
	inventory_changed.emit()
	return true


func add_harvested(crop_id: String, qty: int = 1, is_gold: bool = false) -> void:
	if qty <= 0 or not CROPS.has(crop_id):
		return
	harvested[crop_id] = int(harvested.get(crop_id, 0)) + qty
	if is_gold:
		gold_items[crop_id] = int(gold_items.get(crop_id, 0)) + qty
	discover_item(crop_id)
	inventory_changed.emit()
	orders_changed.emit()


func add_animal_product(product_id: String, qty: int = 1, is_gold: bool = false) -> void:
	if qty <= 0 or not ANIMAL_PRODUCTS.has(product_id):
		return
	animal_products[product_id] = int(animal_products.get(product_id, 0)) + qty
	if is_gold:
		gold_items[product_id] = int(gold_items.get(product_id, 0)) + qty
	discover_item(product_id)
	inventory_changed.emit()
	orders_changed.emit()


func add_fish(fish_id: String, qty: int = 1, is_gold: bool = false) -> void:
	if qty <= 0 or not FISH.has(fish_id):
		return
	fish[fish_id] = int(fish.get(fish_id, 0)) + qty
	if is_gold:
		gold_items[fish_id] = int(gold_items.get(fish_id, 0)) + qty
	discover_item(fish_id)
	inventory_changed.emit()
	orders_changed.emit()


func add_artisan(artisan_id: String, qty: int = 1, is_gold: bool = false) -> void:
	if qty <= 0 or not ARTISAN.has(artisan_id):
		return
	artisan[artisan_id] = int(artisan.get(artisan_id, 0)) + qty
	if is_gold:
		gold_items[artisan_id] = int(gold_items.get(artisan_id, 0)) + qty
	discover_item(artisan_id)
	inventory_changed.emit()
	orders_changed.emit()


func discover_item(item_id: String) -> void:
	if item_id.is_empty():
		return
	if not bool(album_discovered.get(item_id, false)):
		album_discovered[item_id] = true
		album_changed.emit()


func has_album_bonus(group_id: String) -> bool:
	if not FarmCatalogScript.ALBUM_GROUPS.has(group_id):
		return false
	var items: Array = FarmCatalogScript.ALBUM_GROUPS[group_id].get("items", [])
	for id_var in items:
		if not bool(album_discovered.get(str(id_var), false)):
			return false
	return not items.is_empty()


func get_album_progress() -> Dictionary:
	var total: int = 0
	var found: int = 0
	for group_id in FarmCatalogScript.ALBUM_GROUPS.keys():
		var items: Array = FarmCatalogScript.ALBUM_GROUPS[group_id].get("items", [])
		for id_var in items:
			total += 1
			if bool(album_discovered.get(str(id_var), false)):
				found += 1
	return {"found": found, "total": total}


func get_item_count(item_id: String) -> int:
	if harvested.has(item_id):
		return int(harvested.get(item_id, 0))
	if animal_products.has(item_id):
		return int(animal_products.get(item_id, 0))
	if fish.has(item_id):
		return int(fish.get(item_id, 0))
	if artisan.has(item_id):
		return int(artisan.get(item_id, 0))
	return 0


func consume_inventory_item(item_id: String, qty: int) -> bool:
	if qty <= 0 or get_item_count(item_id) < qty:
		return false
	var target_dict: Dictionary
	if harvested.has(item_id):
		target_dict = harvested
	elif animal_products.has(item_id):
		target_dict = animal_products
	elif fish.has(item_id):
		target_dict = fish
	elif artisan.has(item_id):
		target_dict = artisan
	else:
		return false

	var new_total: int = maxi(0, int(target_dict.get(item_id, 0)) - qty)
	target_dict[item_id] = new_total
	if gold_items.has(item_id):
		gold_items[item_id] = mini(int(gold_items[item_id]), new_total)
	inventory_changed.emit()
	orders_changed.emit()
	return true


func _compute_category_value(counts: Dictionary, defs: Dictionary, is_crop: bool) -> int:
	var crop_bonus: float = 1.15 if (is_crop and has_album_bonus("crops")) else 1.0
	var category: String = "harvested" if is_crop else ""
	if defs == ANIMAL_PRODUCTS:
		category = "animal_products"
	elif defs == ARTISAN:
		category = "artisan"
	var total: int = 0
	for id_var in counts.keys():
		var item_id: String = str(id_var)
		var qty: int = int(counts.get(item_id, 0))
		if qty <= 0 or not defs.has(item_id):
			continue
		var season_mult: float = get_season_sell_multiplier(item_id, category)
		var base_price: float = float(defs[item_id]["sell_price"]) * crop_bonus * season_mult
		var gold_qty: int = clampi(int(gold_items.get(item_id, 0)), 0, qty)
		var normal_qty: int = qty - gold_qty
		total += normal_qty * roundi(base_price) + gold_qty * roundi(base_price * 1.5)
	return total


func get_tropeiro_featured_item() -> Dictionary:
	var pool: Array[String] = ["bread", "farinha_mandioca", "rolo_fumo", "saca_cafe", "cheese"]
	var visit_idx: int = maxi(0, (day - 1) / 3)
	var item_id: String = pool[visit_idx % pool.size()]
	var info: Dictionary = ARTISAN.get(item_id, {})
	return {
		"id": item_id,
		"name": str(info.get("name", item_id)),
		"sell_price": int(info.get("sell_price", 80)),
	}


func sell_all_harvested(bonus_mult: float = 1.0, source_label: String = "", featured_id: String = "", featured_mult: float = 1.5) -> int:
	var total_items: int = get_total_basket_count()
	var audio := _get_audio()
	if total_items <= 0:
		if audio != null and audio.has_method("play_error"):
			audio.play_error()
		emit_toast("Cesta vazia! Nada para vender.")
		return 0

	var base_profit: int = get_total_basket_value()
	var saci_mult: float = 1.10 if has_saci_amulet() else 1.0
	var total_profit: int = roundi(float(base_profit) * maxf(1.0, bonus_mult) * saci_mult)
	var featured_bonus: int = 0
	if not featured_id.is_empty() and ARTISAN.has(featured_id):
		var feat_qty: int = int(artisan.get(featured_id, 0))
		if feat_qty > 0 and featured_mult > bonus_mult:
			featured_bonus = roundi(float(feat_qty * int(ARTISAN[featured_id]["sell_price"])) * (featured_mult - bonus_mult))
			total_profit += featured_bonus
	for k in harvested.keys():
		harvested[k] = 0
	for k in animal_products.keys():
		animal_products[k] = 0
	for k in fish.keys():
		fish[k] = 0
	for k in artisan.keys():
		artisan[k] = 0
	gold_items.clear()

	money += total_profit
	money_changed.emit(money)
	inventory_changed.emit()
	orders_changed.emit()
	if audio != null and audio.has_method("play_coin"):
		audio.play_coin()
	if source_label.is_empty():
		emit_toast("Vendeu %d item(ns) por +Rs %d!" % [total_items, total_profit])
	elif featured_bonus > 0:
		emit_toast("%s comprou %d item(ns) por +Rs %d (inclui Pedido da Corte +50%%)!" % [source_label, total_items, total_profit])
	else:
		emit_toast("%s comprou %d item(ns) por +Rs %d!" % [source_label, total_items, total_profit])
	if auto_save_enabled:
		save_game(false)
	return total_profit


func process_casa_farinha() -> String:
	var mandioca_qty: int = int(harvested.get("carrot", 0))
	if mandioca_qty < 2:
		return "no_input"
	harvested["carrot"] = mandioca_qty - 2
	add_artisan("farinha_mandioca", 1, false)
	if auto_save_enabled:
		save_game(false)
	return "ok"


func process_terreiro_secagem() -> String:
	var tabaco_qty: int = int(harvested.get("strawberry", 0))
	if tabaco_qty >= 2:
		harvested["strawberry"] = tabaco_qty - 2
		add_artisan("rolo_fumo", 1, false)
		if auto_save_enabled:
			save_game(false)
		return "rolo_fumo"
	var cafe_qty: int = int(harvested.get("turnip", 0))
	if cafe_qty >= 2:
		harvested["turnip"] = cafe_qty - 2
		add_artisan("saca_cafe", 1, false)
		if auto_save_enabled:
			save_game(false)
		return "saca_cafe"
	return "no_input"


func has_saci_amulet() -> bool:
	return str(story_quests.get("trato_do_redemoinho", "")) == "completed"


func has_iara_blessing() -> bool:
	return str(story_quests.get("canto_mae_dagua", "")) == "completed"


func _record_folklore_discovery(entity_id: String) -> void:
	if StoryDataScript.FOLKLORE_INFO.has(entity_id) and not folklore_discovered.has(entity_id):
		folklore_discovered.append(entity_id)
		story_changed.emit()


func _can_fulfill_quest(q_def: Dictionary, capela_blessed: bool) -> bool:
	var req_type: String = str(q_def.get("req_type", ""))
	var req_id: String = str(q_def.get("req_id", ""))
	var req_qty: int = int(q_def.get("req_qty", 1))
	match req_type:
		"artisan":
			return int(artisan.get(req_id, 0)) >= req_qty
		"capela_blessed":
			return capela_blessed
		"curupira_offering":
			return int(harvested.get("corn", 0)) >= 2 or int(artisan.get("honey", 0)) >= 1
		"any_fish":
			for qty in fish.values():
				if int(qty) >= 1:
					return true
			return false
	return false


func _consume_quest_requirement(q_def: Dictionary) -> void:
	var req_type: String = str(q_def.get("req_type", ""))
	var req_id: String = str(q_def.get("req_id", ""))
	var req_qty: int = int(q_def.get("req_qty", 1))
	match req_type:
		"artisan":
			artisan[req_id] = maxi(0, int(artisan.get(req_id, 0)) - req_qty)
		"curupira_offering":
			if int(harvested.get("corn", 0)) >= 2:
				harvested["corn"] = int(harvested["corn"]) - 2
			elif int(artisan.get("honey", 0)) >= 1:
				artisan["honey"] = int(artisan["honey"]) - 1
		"any_fish":
			for fk in fish.keys():
				if int(fish[fk]) >= 1:
					fish[fk] = int(fish[fk]) - 1
					break


func interact_story_entity(entity_id: String, capela_blessed: bool = false) -> Dictionary:
	var audio := _get_audio()
	_record_folklore_discovery(entity_id)

	var is_villager: bool = StoryDataScript.VILLAGERS.has(entity_id)
	var heart_gained: bool = false
	if is_villager and not bool(npc_talked_today.get(entity_id, false)):
		npc_talked_today[entity_id] = true
		npc_hearts[entity_id] = mini(5, int(npc_hearts.get(entity_id, 0)) + 1)
		heart_gained = true
		story_changed.emit()

	var quest_id: String = ""
	if is_villager:
		quest_id = str((StoryDataScript.VILLAGERS[entity_id] as Dictionary).get("quest_id", ""))
	elif StoryDataScript.FOLKLORE_INFO.has(entity_id):
		quest_id = str((StoryDataScript.FOLKLORE_INFO[entity_id] as Dictionary).get("quest_id", ""))

	if not quest_id.is_empty() and StoryDataScript.QUESTS.has(quest_id):
		var q_def: Dictionary = StoryDataScript.QUESTS[quest_id]
		var state: String = str(story_quests.get(quest_id, ""))
		var speaker: String = str(q_def.get("giver_name", entity_id))

		if state != "completed":
			if _can_fulfill_quest(q_def, capela_blessed):
				_consume_quest_requirement(q_def)
				story_quests[quest_id] = "completed"
				var rew_money: int = int(q_def.get("reward_money", 0))
				if rew_money > 0:
					money += rew_money
					money_changed.emit(money)
				if quest_id == "pao_da_matriz":
					npc_hearts["padre"] = mini(5, int(npc_hearts.get("padre", 0)) + 2)
				elif quest_id == "fogo_estrada_real":
					max_stamina += 15
					stamina = mini(max_stamina, stamina + 15)
					stamina_changed.emit(stamina, max_stamina)
				elif quest_id == "guardiao_da_mata":
					supplies["fertilizer"] = int(supplies.get("fertilizer", 0)) + 5
				inventory_changed.emit()
				story_changed.emit()
				if audio != null and audio.has_method("play_order_done"):
					audio.play_order_done()
				if auto_save_enabled:
					save_game(false)
				return {
					"speaker": speaker,
					"lines": q_def.get("complete_lines", []),
					"quest_completed": true,
					"open_shop": false,
				}
			elif state == "":
				story_quests[quest_id] = "active"
				story_changed.emit()
				if audio != null and audio.has_method("play_cozy"):
					audio.play_cozy()
				if auto_save_enabled:
					save_game(false)
				return {
					"speaker": speaker,
					"lines": q_def.get("intro_lines", []),
					"quest_completed": false,
					"open_shop": false,
				}
			else:
				if audio != null and audio.has_method("play_click"):
					audio.play_click()
				return {
					"speaker": speaker,
					"lines": q_def.get("reminder_lines", []),
					"quest_completed": false,
					"open_shop": false,
				}

	if is_villager:
		var v_def: Dictionary = StoryDataScript.VILLAGERS[entity_id]
		var hearts: int = int(npc_hearts.get(entity_id, 0))
		var v_lines: Array = v_def.get("lines", ["Olá, lavrador!"])
		var line_idx: int = clampi(hearts / 2, 0, v_lines.size() - 1)
		var out_lines: Array[String] = [str(v_lines[line_idx])]
		if heart_gained:
			out_lines.append("(Amizade com %s subiu para %d/5 ♥)" % [str(v_def["name"]), hearts])
		if audio != null and audio.has_method("play_cozy"):
			audio.play_cozy()
		if auto_save_enabled and heart_gained:
			save_game(false)
		return {
			"speaker": "%s (%d/5 ♥)" % [str(v_def["name"]), hearts],
			"lines": out_lines,
			"quest_completed": false,
			"open_shop": entity_id in ["ferreiro", "quiteria"],
		}

	if StoryDataScript.FOLKLORE_INFO.has(entity_id):
		var f_def: Dictionary = StoryDataScript.FOLKLORE_INFO[entity_id]
		if audio != null and audio.has_method("play_cozy"):
			audio.play_cozy()
		return {
			"speaker": str(f_def["name"]),
			"lines": ["Sua amizade com as lendas desta terra protege a fazenda colonial!"],
			"quest_completed": false,
			"open_shop": false,
		}
	return {}


func is_book_chapter_unlocked(chapter_id: String) -> bool:
	if not StoryDataScript.BOOK_CHAPTERS.has(chapter_id):
		return false
	var ch: Dictionary = StoryDataScript.BOOK_CHAPTERS[chapter_id]
	var utype: String = str(ch.get("unlock_type", "always"))
	match utype:
		"always":
			return true
		"item":
			var req_item: String = str(ch.get("unlock_req", ""))
			return bool(album_discovered.get(req_item, false)) or int(harvested.get(req_item, 0)) > 0
		"folklore":
			var req_fk: String = str(ch.get("unlock_req", ""))
			return folklore_discovered.has(req_fk)
		"folklore_any":
			var req_arr = ch.get("unlock_req", [])
			if req_arr is Array:
				for fk in req_arr:
					if folklore_discovered.has(str(fk)):
						return true
			return false
		"quest_or_artisan":
			for st in story_quests.values():
				if str(st) == "completed":
					return true
			for a_id in artisan.keys():
				if bool(album_discovered.get(str(a_id), false)) or int(artisan.get(a_id, 0)) > 0:
					return true
			return false
	return false


func get_unlocked_book_count() -> int:
	var count: int = 0
	for cid in StoryDataScript.BOOK_CHAPTER_ORDER:
		if is_book_chapter_unlocked(cid):
			count += 1
	return count


func mark_book_chapter_read(chapter_id: String) -> Dictionary:
	if not is_book_chapter_unlocked(chapter_id):
		return {"bonus_granted": false, "first_read": false}
	var first_read: bool = false
	if not book_chapters_read.has(chapter_id):
		book_chapters_read.append(chapter_id)
		first_read = true
	var bonus_granted: bool = false
	if not book_bonus_claimed_today:
		book_bonus_claimed_today = true
		bonus_granted = true
		stamina = mini(max_stamina, stamina + 10)
		stamina_changed.emit(stamina, max_stamina)
		var audio := get_node_or_null("/root/AudioManager")
		if audio != null and audio.has_method("play_cozy"):
			audio.play_cozy()
		emit_toast("Leitura do Sítio! +10 Energia de aconchego.")
	if first_read or bonus_granted:
		story_changed.emit()
	return {"bonus_granted": bonus_granted, "first_read": first_read}


func start_machine(machine_id: String) -> String:
	if not bool(owned_machines.get(machine_id, false)) or not FarmCatalogScript.MACHINES.has(machine_id):
		return "not_owned"
	var m_def: Dictionary = FarmCatalogScript.MACHINES[machine_id]
	var st: Dictionary = machine_states.get(machine_id, {"busy": false, "ready": false, "remaining": 0.0, "output_id": str(m_def.get("output_id", ""))})

	if bool(st.get("ready", false)):
		var out_id: String = str(st.get("output_id", m_def.get("output_id", "")))
		add_artisan(out_id, 1, false)
		st["ready"] = false
		st["busy"] = false
		st["remaining"] = 0.0
		machine_states[machine_id] = st
		machines_changed.emit()
		if auto_save_enabled:
			save_game(false)
		return "collected:" + out_id

	if bool(st.get("busy", false)):
		return "busy"

	var input_id: String = str(m_def.get("input_id", ""))
	var input_qty: int = int(m_def.get("input_qty", 0))
	if input_id.is_empty() or input_qty <= 0:
		return "idle_auto"

	if not consume_inventory_item(input_id, input_qty):
		return "missing_input"

	st["busy"] = true
	st["ready"] = false
	st["remaining"] = float(m_def.get("duration_minutes", 180.0))
	st["output_id"] = str(m_def.get("output_id", ""))
	machine_states[machine_id] = st
	machines_changed.emit()
	if auto_save_enabled:
		save_game(false)
	return "started"


func can_deliver_order(index: int) -> bool:
	if index < 0 or index >= daily_orders.size():
		return false
	var ord: Dictionary = daily_orders[index]
	if bool(ord.get("completed", false)):
		return false
	return get_item_count(str(ord.get("item_id", ""))) >= int(ord.get("qty", 1))


func has_deliverable_order() -> bool:
	for i in range(daily_orders.size()):
		if can_deliver_order(i):
			return true
	return false


func deliver_order(index: int) -> bool:
	if not can_deliver_order(index):
		var audio_err := _get_audio()
		if audio_err != null and audio_err.has_method("play_error"):
			audio_err.play_error()
		return false
	var ord: Dictionary = daily_orders[index]
	var item_id: String = str(ord["item_id"])
	var qty: int = int(ord["qty"])
	var reward: int = int(ord["reward"])
	if not consume_inventory_item(item_id, qty):
		return false

	ord["completed"] = true
	daily_orders[index] = ord
	money += reward
	money_changed.emit(money)
	orders_changed.emit()
	var audio := _get_audio()
	if audio != null and audio.has_method("play_order_done"):
		audio.play_order_done()
	elif audio != null and audio.has_method("play_coin"):
		audio.play_coin()
	emit_toast("Encomenda entregue! +$%d" % reward)
	if auto_save_enabled:
		save_game(false)
	return true


func _generate_daily_orders() -> void:
	daily_orders.clear()
	var pool: Array[String] = ["wheat", "carrot", "egg", "milk", "tilapia"]
	if day >= 2:
		pool.append_array(["strawberry", "tomato", "wool", "truffle", "shrimp", "trout"])
	if day >= 3:
		pool.append_array(["corn", "pumpkin", "blue_egg", "golden_carp"])
	if bool(owned_machines.get("cheese_press", false)):
		pool.append("cheese")
	if bool(owned_machines.get("bakery_oven", false)):
		pool.append("bread")
	if bool(owned_machines.get("bee_hive", false)):
		pool.append("honey")

	var picked: Array[String] = []
	var attempts: int = 0
	while picked.size() < 3 and attempts < 30:
		attempts += 1
		var candidate: String = pool[_weather_rng.randi_range(0, pool.size() - 1)]
		if not picked.has(candidate):
			picked.append(candidate)

	for item_id in picked:
		var info := FarmCatalogScript.get_item_info(item_id, CROPS)
		if info.is_empty():
			continue
		var unit_price: int = int(info.get("sell_price", 25))
		var qty: int = 2 if unit_price <= 45 else 1
		if item_id == "wheat" or item_id == "tomato":
			qty = _weather_rng.randi_range(2, 3)
		var reward: int = roundi(float(unit_price * qty) * 1.45) + 15
		daily_orders.append({
			"item_id": item_id,
			"name": str(info.get("name", item_id)),
			"qty": qty,
			"reward": reward,
			"completed": false,
		})
	orders_changed.emit()


func refill_water() -> void:
	water_level = max_water
	water_changed.emit(water_level, max_water)
	var audio := _get_audio()
	if audio != null and audio.has_method("play_water"):
		audio.play_water()
	emit_toast("Regador reabastecido! (%d/%d)" % [water_level, max_water])


func consume_stamina(amount: int) -> bool:
	if amount <= 0:
		return true
	if stamina < amount:
		var audio := _get_audio()
		if audio != null and audio.has_method("play_error"):
			audio.play_error()
		emit_toast("Sem energia! Durma na casinha ou aperte N.")
		return false
	stamina -= amount
	stamina_changed.emit(stamina, max_stamina)
	return true


func use_water(amount: int = 1) -> bool:
	if amount <= 0:
		return true
	if water_level < amount:
		var audio := _get_audio()
		if audio != null and audio.has_method("play_error"):
			audio.play_error()
		emit_toast("Regador vazio! Encha no lago ou no poço.")
		return false
	water_level -= amount
	water_changed.emit(water_level, max_water)
	return true


func set_weather(today_w: String, next_w: String = "") -> void:
	weather = WEATHER_RAINY if today_w == WEATHER_RAINY else WEATHER_SUNNY
	if not next_w.is_empty():
		tomorrow_weather = WEATHER_RAINY if next_w == WEATHER_RAINY else WEATHER_SUNNY
	weather_changed.emit(weather, tomorrow_weather)


func get_weather_label(w: String = weather) -> String:
	if w == WEATHER_RAINY:
		return "Neve" if current_season == "winter" else "Chuva"
	return "Sol"


func set_touch_mode(mode: String) -> void:
	if mode not in ["auto", "on", "off"]:
		return
	if touch_mode == mode:
		return
	touch_mode = mode
	touch_mode_changed.emit(touch_mode)
	if auto_save_enabled:
		save_game(false)


func advance_day() -> void:
	npc_talked_today.clear()
	book_bonus_claimed_today = false
	day += 1
	time_minutes = START_OF_DAY_MINUTES
	_last_emitted_minute = int(time_minutes)
	stamina = max_stamina

	weather = tomorrow_weather
	var rain_chance: float = 0.14 if weather == WEATHER_RAINY else 0.30
	tomorrow_weather = WEATHER_RAINY if _weather_rng.randf() < rain_chance else WEATHER_SUNNY

	for m_id_var in owned_machines.keys():
		var m_id: String = str(m_id_var)
		if not bool(owned_machines[m_id]):
			continue
		if m_id == "bee_hive":
			machine_states[m_id] = {"busy": false, "ready": true, "remaining": 0.0, "output_id": "honey"}
		elif machine_states.has(m_id) and bool(machine_states[m_id].get("busy", false)):
			machine_states[m_id]["busy"] = false
			machine_states[m_id]["ready"] = true
			machine_states[m_id]["remaining"] = 0.0

	var previous_season: String = current_season
	_sync_season_from_day()
	var season_switched: bool = previous_season != current_season

	_generate_daily_orders()
	if season_switched:
		season_changed.emit(current_season, year)
	weather_changed.emit(weather, tomorrow_weather)
	day_advanced.emit(day)
	day_changed.emit(day, time_minutes)
	stamina_changed.emit(stamina, max_stamina)
	machines_changed.emit()

	var audio := _get_audio()
	if audio != null and audio.has_method("play_sleep"):
		audio.play_sleep()
	if season_switched:
		if audio != null and audio.has_method("play_season_change"):
			audio.play_season_change()
		emit_toast(str(get_season_definition().get("greeting", "Nova estação!")))
	elif weather == WEATHER_RAINY:
		if current_season == "winter":
			emit_toast("Dia %d começou com neve! Canteiros umedecidos automaticamente." % day_of_season)
		else:
			emit_toast("Dia %d começou com chuva! Canteiros regados automaticamente." % day_of_season)
	else:
		emit_toast("Bom dia! %s, dia %d/%d — energia restaurada." % [get_season_name(), day_of_season, SeasonDataScript.DAYS_PER_SEASON])
	if auto_save_enabled:
		save_game(false)


# --- 4 Estações do Ano ---

func advance_season() -> void:
	var current_block: int = (maxi(day, 1) - 1) / SeasonDataScript.DAYS_PER_SEASON
	day = (current_block + 1) * SeasonDataScript.DAYS_PER_SEASON + 1
	time_minutes = START_OF_DAY_MINUTES
	_last_emitted_minute = int(time_minutes)
	stamina = max_stamina

	weather = tomorrow_weather
	var rain_chance: float = 0.14 if weather == WEATHER_RAINY else 0.30
	tomorrow_weather = WEATHER_RAINY if _weather_rng.randf() < rain_chance else WEATHER_SUNNY

	_sync_season_from_day()
	_generate_daily_orders()
	season_changed.emit(current_season, year)
	weather_changed.emit(weather, tomorrow_weather)
	day_advanced.emit(day)
	day_changed.emit(day, time_minutes)
	stamina_changed.emit(stamina, max_stamina)
	machines_changed.emit()

	var audio := _get_audio()
	if audio != null and audio.has_method("play_season_change"):
		audio.play_season_change()
	emit_toast(str(get_season_definition().get("greeting", "Nova estação!")))
	if auto_save_enabled:
		save_game(false)


func _sync_season_from_day() -> void:
	current_season = SeasonDataScript.get_season_id_for_day(day)
	day_of_season = SeasonDataScript.get_day_of_season(day)
	year = SeasonDataScript.get_year_for_day(day)


func get_current_season() -> String:
	return current_season


func get_season_definition() -> Dictionary:
	return SeasonDataScript.get_definition(current_season)


func get_season_name(season_id: String = current_season) -> String:
	return str(SeasonDataScript.get_definition(season_id).get("name", "Primavera"))


func get_days_per_season() -> int:
	return SeasonDataScript.DAYS_PER_SEASON


func get_effective_days_to_grow(crop_id: String) -> int:
	return CropDataScript.get_effective_days_to_grow(crop_id, current_season)


func get_effective_crop_price(crop_id: String) -> int:
	return CropDataScript.get_effective_sell_price(crop_id, current_season)


func is_crop_in_season(crop_id: String) -> bool:
	return CropDataScript.is_in_preferred_season(crop_id, current_season)


## Multiplicador sazonal de venda: +35% cultivos da estação, +20% animais/artesanais no Inverno.
func get_season_sell_multiplier(item_id: String, category: String) -> float:
	var def := get_season_definition()
	if category == "harvested":
		return CropDataScript.get_season_price_multiplier(item_id, current_season)
	if category == "animal_products":
		return float(def.get("animal_price_mult", 1.0))
	if category == "artisan":
		return float(def.get("artisan_price_mult", 1.0))
	return 1.0


func emit_toast(msg: String) -> void:
	toast_message.emit(msg)


func get_formatted_time() -> String:
	var total_mins: int = clampi(int(floor(time_minutes)), 0, 1439)
	var hours: int = total_mins / 60
	var mins: int = total_mins % 60
	return "%02d:%02d" % [hours, mins]


func get_total_harvested() -> int:
	var total: int = 0
	for qty_var in harvested.values():
		total += int(qty_var)
	return total


func get_total_basket_count() -> int:
	var total: int = get_total_harvested()
	for qty_var in animal_products.values():
		total += int(qty_var)
	for qty_var in fish.values():
		total += int(qty_var)
	for qty_var in artisan.values():
		total += int(qty_var)
	return total


func get_total_basket_value() -> int:
	var total: int = 0
	total += _compute_category_value(harvested, CROPS, true)
	total += _compute_category_value(animal_products, ANIMAL_PRODUCTS, false)
	total += _compute_category_value(fish, FISH, false)
	total += _compute_category_value(artisan, ARTISAN, false)
	return total


func register_world_provider(provider: Callable) -> void:
	_world_state_provider = provider


func consume_pending_world_save() -> Dictionary:
	var copy: Dictionary = _pending_world_save.duplicate(true)
	_pending_world_save.clear()
	return copy


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_game(show_toast: bool = true) -> bool:
	var world_data: Dictionary = {}
	if _world_state_provider.is_valid():
		var provided = _world_state_provider.call()
		if provided is Dictionary:
			world_data = provided

	var audio := _get_audio()
	var sfx_muted: bool = bool(audio.get("muted")) if audio != null and audio.get("muted") != null else false
	var bgm_muted: bool = bool(audio.get("music_muted")) if audio != null and audio.get("music_muted") != null else false

	var payload: Dictionary = {
		"version": 2,
		"money": money,
		"day": day,
		"time_minutes": time_minutes,
		"time_speed_multiplier": time_speed_multiplier,
		"stamina": stamina,
		"water_level": water_level,
		"selected_slot": selected_slot,
		"hoe_level": hoe_level,
		"can_level": can_level,
		"stamina_level": stamina_level,
		"sprinklers_owned": sprinklers_owned,
		"weather": weather,
		"tomorrow_weather": tomorrow_weather,
		"touch_mode": touch_mode,
		"muted": sfx_muted,
		"music_muted": bgm_muted,
		"seeds": seeds.duplicate(true),
		"harvested": harvested.duplicate(true),
		"animal_products": animal_products.duplicate(true),
		"fish": fish.duplicate(true),
		"artisan": artisan.duplicate(true),
		"supplies": supplies.duplicate(true),
		"cooked_dishes": cooked_dishes.duplicate(true),
		"minerals": minerals.duplicate(true),
		"unlocked_plots": unlocked_plots.duplicate(true),
		"pet_type": pet_type,
		"gold_items": gold_items.duplicate(true),
		"owned_machines": owned_machines.duplicate(true),
		"machine_states": machine_states.duplicate(true),
		"daily_orders": daily_orders.duplicate(true),
		"album_discovered": album_discovered.duplicate(true),
		"story_quests": story_quests.duplicate(true),
		"npc_hearts": npc_hearts.duplicate(true),
		"folklore_discovered": folklore_discovered.duplicate(true),
		"book_chapters_read": book_chapters_read.duplicate(true),
		"book_bonus_claimed_today": book_bonus_claimed_today,
		"animal_count": animal_count,
		"world": world_data,
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		if show_toast:
			emit_toast("Erro ao salvar o jogo.")
		return false
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()

	if show_toast:
		emit_toast("Jogo salvo! (Dia %d)" % day)
	return true


func _load_dict_int_keys(target: Dictionary, raw: Variant) -> void:
	if not (raw is Dictionary):
		return
	for key_var in target.keys():
		var k: String = str(key_var)
		if (raw as Dictionary).has(k):
			target[k] = maxi(0, int(raw[k]))


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var text: String = file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(text)
	if not (parsed is Dictionary):
		return false
	var data: Dictionary = parsed

	money = maxi(0, int(data.get("money", 100)))
	day = maxi(1, int(data.get("day", 1)))
	time_minutes = clampf(float(data.get("time_minutes", START_OF_DAY_MINUTES)), 0.0, MINUTES_PER_DAY - 1.0)
	_last_emitted_minute = int(floor(time_minutes))
	time_speed_multiplier = clampf(float(data.get("time_speed_multiplier", 1.0)), 0.5, 2.0)

	hoe_level = clampi(int(data.get("hoe_level", 1)), 1, 3)
	can_level = clampi(int(data.get("can_level", 1)), 1, 3)
	stamina_level = clampi(int(data.get("stamina_level", 1)), 1, 3)
	sprinklers_owned = maxi(0, int(data.get("sprinklers_owned", 0)))
	_sync_caps_from_levels()

	stamina = clampi(int(data.get("stamina", max_stamina)), 0, max_stamina)
	water_level = clampi(int(data.get("water_level", max_water)), 0, max_water)
	selected_slot = clampi(int(data.get("selected_slot", 0)), 0, HOTBAR_SLOTS.size() - 1)
	animal_count = clampi(int(data.get("animal_count", 5)), 1, FarmCatalogScript.MAX_FARM_ANIMALS)

	var loaded_weather: String = str(data.get("weather", WEATHER_SUNNY))
	weather = WEATHER_RAINY if loaded_weather == WEATHER_RAINY else WEATHER_SUNNY
	var loaded_tomorrow: String = str(data.get("tomorrow_weather", WEATHER_SUNNY))
	tomorrow_weather = WEATHER_RAINY if loaded_tomorrow == WEATHER_RAINY else WEATHER_SUNNY

	var loaded_touch: String = str(data.get("touch_mode", "auto"))
	if loaded_touch in ["auto", "on", "off"]:
		touch_mode = loaded_touch

	var audio := _get_audio()
	if audio != null:
		if data.has("muted") and audio.has_method("set_muted"):
			audio.call("set_muted", bool(data["muted"]))
		if data.has("music_muted") and audio.has_method("set_music_muted"):
			audio.call("set_music_muted", bool(data["music_muted"]))

	_load_dict_int_keys(seeds, data.get("seeds", {}))
	_load_dict_int_keys(harvested, data.get("harvested", {}))
	_load_dict_int_keys(animal_products, data.get("animal_products", {}))
	_load_dict_int_keys(fish, data.get("fish", {}))
	_load_dict_int_keys(artisan, data.get("artisan", {}))
	_load_dict_int_keys(supplies, data.get("supplies", {}))
	_load_dict_int_keys(cooked_dishes, data.get("cooked_dishes", {}))
	_load_dict_int_keys(minerals, data.get("minerals", {}))
	unlocked_plots.clear()
	var loaded_plots: Variant = data.get("unlocked_plots", [])
	if loaded_plots is Array:
		for pid in (loaded_plots as Array):
			unlocked_plots.append(str(pid))
	pet_type = str(data.get("pet_type", ""))

	story_quests.clear()
	var loaded_sq = data.get("story_quests", {})
	if loaded_sq is Dictionary:
		for sk in loaded_sq.keys():
			story_quests[str(sk)] = str(loaded_sq[sk])
	_load_dict_int_keys(npc_hearts, data.get("npc_hearts", {}))
	npc_talked_today.clear()
	folklore_discovered.clear()
	var loaded_fk = data.get("folklore_discovered", [])
	if loaded_fk is Array:
		for fid in loaded_fk:
			folklore_discovered.append(str(fid))
	book_chapters_read.clear()
	var loaded_br = data.get("book_chapters_read", [])
	if loaded_br is Array:
		for bid in loaded_br:
			book_chapters_read.append(str(bid))
	book_bonus_claimed_today = bool(data.get("book_bonus_claimed_today", false))
	if str(story_quests.get("fogo_estrada_real", "")) == "completed":
		max_stamina += 15
		stamina = clampi(stamina, 0, max_stamina)

	gold_items.clear()
	var loaded_gold = data.get("gold_items", {})
	if loaded_gold is Dictionary:
		for g_k in loaded_gold.keys():
			var g_qty := maxi(0, int(loaded_gold[g_k]))
			if g_qty > 0:
				gold_items[str(g_k)] = g_qty

	var loaded_owned = data.get("owned_machines", {})
	if loaded_owned is Dictionary:
		for m_k in owned_machines.keys():
			if (loaded_owned as Dictionary).has(m_k):
				owned_machines[m_k] = bool(loaded_owned[m_k])

	machine_states.clear()
	var loaded_m_states = data.get("machine_states", {})
	if loaded_m_states is Dictionary:
		for m_k in loaded_m_states.keys():
			if loaded_m_states[m_k] is Dictionary:
				machine_states[str(m_k)] = (loaded_m_states[m_k] as Dictionary).duplicate(true)

	daily_orders.clear()
	var loaded_orders = data.get("daily_orders", [])
	if loaded_orders is Array:
		for o_var in loaded_orders:
			if o_var is Dictionary:
				daily_orders.append((o_var as Dictionary).duplicate(true))

	album_discovered.clear()
	var loaded_album = data.get("album_discovered", {})
	if loaded_album is Dictionary:
		for a_k in loaded_album.keys():
			if bool(loaded_album[a_k]):
				album_discovered[str(a_k)] = true

	var world_dict = data.get("world", {})
	if world_dict is Dictionary:
		_pending_world_save = world_dict.duplicate(true)
	else:
		_pending_world_save = {}

	money_changed.emit(money)
	day_changed.emit(day, time_minutes)
	stamina_changed.emit(stamina, max_stamina)
	water_changed.emit(water_level, max_water)
	tool_changed.emit(selected_slot)
	upgrades_changed.emit()
	_sync_season_from_day()
	season_changed.emit(current_season, year)
	weather_changed.emit(weather, tomorrow_weather)
	touch_mode_changed.emit(touch_mode)
	machines_changed.emit()
	orders_changed.emit()
	album_changed.emit()
	inventory_changed.emit()
	return true


func reset_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

	money = 100
	day = 1
	time_minutes = START_OF_DAY_MINUTES
	_last_emitted_minute = int(START_OF_DAY_MINUTES)
	time_speed_multiplier = 1.0
	hoe_level = 1
	can_level = 1
	stamina_level = 1
	sprinklers_owned = 0
	_sync_caps_from_levels()
	stamina = max_stamina
	water_level = max_water
	selected_slot = 0
	animal_count = 5
	weather = WEATHER_SUNNY
	tomorrow_weather = WEATHER_SUNNY
	seeds = {
		"wheat": 6,
		"carrot": 4,
		"strawberry": 2,
		"corn": 0,
		"tomato": 0,
		"pumpkin": 0,
		"turnip": 0,
	}
	harvested = {
		"wheat": 0,
		"carrot": 0,
		"strawberry": 0,
		"corn": 0,
		"tomato": 0,
		"pumpkin": 0,
		"turnip": 0,
	}
	animal_products = {
		"egg": 0,
		"blue_egg": 0,
		"milk": 0,
		"wool": 0,
		"truffle": 0,
	}
	fish = {
		"tilapia": 0,
		"shrimp": 0,
		"trout": 0,
		"golden_carp": 0,
	}
	artisan = {
		"cheese": 0,
		"bread": 0,
		"honey": 0,
		"farinha_mandioca": 0,
		"rolo_fumo": 0,
		"saca_cafe": 0,
	}
	supplies = {
		"fertilizer": 2,
	}
	cooked_dishes = {
		"caldo_cana": 0,
		"cafe_coado": 0,
		"bolo_fuba": 0,
		"peixe_assado": 0,
		"pao_de_queijo": 0,
	}
	minerals = {
		"pedra": 0,
		"ferro": 0,
		"ouro_colonial": 0,
	}
	unlocked_plots.clear()
	pet_type = ""
	story_quests.clear()
	npc_hearts = {"padre": 0, "ferreiro": 0, "quiteria": 0}
	npc_talked_today.clear()
	folklore_discovered.clear()
	book_chapters_read.clear()
	book_bonus_claimed_today = false
	gold_items.clear()
	owned_machines = {
		"cheese_press": false,
		"bakery_oven": false,
		"bee_hive": false,
	}
	machine_states.clear()
	album_discovered.clear()
	_pending_world_save.clear()
	_sync_season_from_day()
	_generate_daily_orders()

	money_changed.emit(money)
	day_changed.emit(day, time_minutes)
	stamina_changed.emit(stamina, max_stamina)
	water_changed.emit(water_level, max_water)
	tool_changed.emit(selected_slot)
	upgrades_changed.emit()
	season_changed.emit(current_season, year)
	weather_changed.emit(weather, tomorrow_weather)
	machines_changed.emit()
	album_changed.emit()
	inventory_changed.emit()
	game_reset.emit()
	emit_toast("Fazenda reiniciada para o Dia 1!")


# --- Culinária Colonial, Lojas da Vila, Mineração e Lotes ---

func _get_bucket_dict(bucket_name: String) -> Dictionary:
	match bucket_name:
		"harvested":
			return harvested
		"animal_products":
			return animal_products
		"fish":
			return fish
		"artisan":
			return artisan
		"minerals":
			return minerals
		_:
			return {}


func can_cook_recipe(recipe_id: String) -> bool:
	if not CookingDataScript.RECIPES.has(recipe_id):
		return false
	var rec: Dictionary = CookingDataScript.RECIPES[recipe_id]
	var ing_val: Variant = rec.get("ingredients", [])
	if not (ing_val is Array):
		return false
	for ing_var in (ing_val as Array):
		if not (ing_var is Dictionary):
			continue
		var ing := ing_var as Dictionary
		var d: Dictionary = _get_bucket_dict(str(ing.get("bucket", "")))
		var need: int = int(ing.get("qty", 1))
		if int(d.get(str(ing.get("id", "")), 0)) < need:
			return false
	return true


func cook_recipe(recipe_id: String) -> bool:
	if not can_cook_recipe(recipe_id):
		emit_toast("Ingredientes insuficientes para esta receita!")
		return false
	var rec: Dictionary = CookingDataScript.RECIPES[recipe_id]
	var ing_val: Variant = rec.get("ingredients", [])
	if ing_val is Array:
		for ing_var in (ing_val as Array):
			if not (ing_var is Dictionary):
				continue
			var ing := ing_var as Dictionary
			var d: Dictionary = _get_bucket_dict(str(ing.get("bucket", "")))
			var k: String = str(ing.get("id", ""))
			d[k] = maxi(0, int(d.get(k, 0)) - int(ing.get("qty", 1)))
	cooked_dishes[recipe_id] = int(cooked_dishes.get(recipe_id, 0)) + 1
	inventory_changed.emit()
	emit_toast("Preparou %s no fogão de lenha!" % str(rec.get("name", recipe_id)))
	return true


func eat_cooked_dish(recipe_id: String) -> bool:
	if int(cooked_dishes.get(recipe_id, 0)) <= 0 or not CookingDataScript.RECIPES.has(recipe_id):
		return false
	var rec: Dictionary = CookingDataScript.RECIPES[recipe_id]
	cooked_dishes[recipe_id] = int(cooked_dishes[recipe_id]) - 1
	var gain: int = int(rec.get("energy", 25))
	stamina = mini(max_stamina, stamina + gain)
	stamina_changed.emit(stamina, max_stamina)
	inventory_changed.emit()
	emit_toast("Delícia! Comeu %s (+%d Energia)." % [str(rec.get("name", recipe_id)), gain])
	return true


func sell_cooked_dish(recipe_id: String) -> bool:
	if int(cooked_dishes.get(recipe_id, 0)) <= 0 or not CookingDataScript.RECIPES.has(recipe_id):
		return false
	var rec: Dictionary = CookingDataScript.RECIPES[recipe_id]
	cooked_dishes[recipe_id] = int(cooked_dishes[recipe_id]) - 1
	var price: int = int(rec.get("sell_price", 50))
	money += price
	money_changed.emit(money)
	inventory_changed.emit()
	emit_toast("Vendeu %s por Rs %d!" % [str(rec.get("name", recipe_id)), price])
	return true


func buy_instant_energy(cost: int, energy_gain: int, label_name: String) -> bool:
	if money < cost:
		emit_toast("Réis insuficientes! Precisa de Rs %d." % cost)
		return false
	money -= cost
	stamina = mini(max_stamina, stamina + energy_gain)
	money_changed.emit(money)
	stamina_changed.emit(stamina, max_stamina)
	emit_toast("Comprou %s! (+%d Energia)" % [label_name, energy_gain])
	return true


func add_mineral(mineral_id: String, qty: int = 1) -> void:
	minerals[mineral_id] = int(minerals.get(mineral_id, 0)) + qty
	inventory_changed.emit()


func sell_all_minerals(bonus_mult: float = 1.0) -> int:
	var prices: Dictionary = {"pedra": 18, "ferro": 55, "ouro_colonial": 165}
	var total: int = 0
	for k in minerals.keys():
		var q: int = int(minerals.get(k, 0))
		if q > 0:
			total += int(round(float(q * int(prices.get(k, 15))) * bonus_mult))
			minerals[k] = 0
	if total <= 0:
		emit_toast("Sem minérios na sacola! Visite a Mina do Ouro Colonial.")
		return 0
	money += total
	money_changed.emit(money)
	inventory_changed.emit()
	emit_toast("Vendeu minérios por Rs %d!" % total)
	return total


func buy_farm_plot(plot_id: String, cost: int, plot_name: String) -> bool:
	if plot_id in unlocked_plots:
		return false
	if money < cost:
		emit_toast("Réis insuficientes para %s (Rs %d)." % [plot_name, cost])
		return false
	money -= cost
	unlocked_plots.append(plot_id)
	money_changed.emit(money)
	emit_toast("Escritura assinada! %s desbloqueado para plantio!" % plot_name)
	if auto_save_enabled:
		save_game(false)
	return true

