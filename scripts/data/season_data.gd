class_name SeasonData
extends Resource
## Definições das 4 estações do ano da Fazendinha 2D (28 dias por estação, 112 dias por ano).

const DAYS_PER_SEASON: int = 28
const SEASON_ORDER: Array[String] = ["spring", "summer", "autumn", "winter"]
const DAYS_PER_YEAR: int = DAYS_PER_SEASON * 4

const DEFINITIONS: Dictionary = {
	"spring": {
		"id": "spring",
		"name": "Primavera",
		"icon_col": 0,
		"badge_bg": Color("#e8f6df"),
		"badge_border": Color("#4d9938"),
		"badge_text": Color("#235c16"),
		"bonus_crops": ["strawberry", "wheat"],
		"bonus_crop_id": "strawberry",
		"bonus_crop_name": "Tabaco e Cana",
		"animal_price_mult": 1.0,
		"artisan_price_mult": 1.0,
		"terrain_path": "res://assets/sprites/seasons/terrain_spring.png",
		"props_path": "res://assets/sprites/seasons/props_spring.png",
		"ambient_tint": Color(1.0, 0.99, 1.0),
		"greeting": "Primavera chegou! Cana e Tabaco crescem mais rápido (+35%).",
	},
	"summer": {
		"id": "summer",
		"name": "Verão",
		"icon_col": 1,
		"badge_bg": Color("#fff4cc"),
		"badge_border": Color("#d99a1e"),
		"badge_text": Color("#7d4600"),
		"bonus_crops": ["corn", "tomato"],
		"bonus_crop_id": "tomato",
		"bonus_crop_name": "Milho e Feijão",
		"animal_price_mult": 1.0,
		"artisan_price_mult": 1.0,
		"terrain_path": "res://assets/sprites/seasons/terrain_summer.png",
		"props_path": "res://assets/sprites/seasons/props_summer.png",
		"ambient_tint": Color(1.0, 0.98, 0.91),
		"greeting": "Verão chegou! Sol forte acelera Milho e Feijão (+35%).",
	},
	"autumn": {
		"id": "autumn",
		"name": "Outono",
		"icon_col": 2,
		"badge_bg": Color("#fde8d4"),
		"badge_border": Color("#c76224"),
		"badge_text": Color("#7a2e08"),
		"bonus_crops": ["pumpkin", "carrot"],
		"bonus_crop_id": "pumpkin",
		"bonus_crop_name": "Algodão e Mandioca",
		"animal_price_mult": 1.0,
		"artisan_price_mult": 1.0,
		"terrain_path": "res://assets/sprites/seasons/terrain_autumn.png",
		"props_path": "res://assets/sprites/seasons/props_autumn.png",
		"ambient_tint": Color(1.0, 0.94, 0.86),
		"greeting": "Outono chegou! Colheita farta: Mandioca e Algodão rendem +35%.",
	},
	"winter": {
		"id": "winter",
		"name": "Inverno",
		"icon_col": 3,
		"badge_bg": Color("#e3f2fc"),
		"badge_border": Color("#3d7cb8"),
		"badge_text": Color("#1a4673"),
		"bonus_crops": ["turnip"],
		"bonus_crop_id": "turnip",
		"bonus_crop_name": "Café",
		"animal_price_mult": 1.20,
		"artisan_price_mult": 1.20,
		"terrain_path": "res://assets/sprites/seasons/terrain_winter.png",
		"props_path": "res://assets/sprites/seasons/props_winter.png",
		"ambient_tint": Color(0.91, 0.95, 1.0),
		"greeting": "Inverno chegou! Café (+35%), Animais e Engenho (+20%) em alta!",
	},
}


static func get_all_definitions() -> Dictionary:
	return DEFINITIONS.duplicate(true)


static func get_season_index_for_day(total_day: int) -> int:
	var zero_based: int = maxi(total_day, 1) - 1
	var season_step: int = floori(float(zero_based) / float(DAYS_PER_SEASON))
	return season_step % SEASON_ORDER.size()


static func get_season_id_for_day(total_day: int) -> String:
	var idx: int = get_season_index_for_day(total_day)
	return SEASON_ORDER[idx]


static func get_day_of_season(total_day: int) -> int:
	var zero_based: int = maxi(total_day, 1) - 1
	return (zero_based % DAYS_PER_SEASON) + 1


static func get_year_for_day(total_day: int) -> int:
	var zero_based: int = maxi(total_day, 1) - 1
	return floori(float(zero_based) / float(DAYS_PER_YEAR)) + 1


static func get_definition(season_id: String) -> Dictionary:
	if DEFINITIONS.has(season_id):
		return (DEFINITIONS[season_id] as Dictionary).duplicate(true)
	return (DEFINITIONS["spring"] as Dictionary).duplicate(true)


static func get_definition_for_day(total_day: int) -> Dictionary:
	return get_definition(get_season_id_for_day(total_day))
