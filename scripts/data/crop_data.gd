class_name CropData
extends Resource
## Definições de cultivos do projeto Fazendinha 2D.
## Cada linha (row) corresponde exatamente a res://assets/sprites/crops_sheet.png (5 cols x 6 rows de 16x16).
## O Nabo (turnip) de Inverno usa sua própria folha res://assets/sprites/seasons/turnip_sheet.png (5 cols x 1 row).

@export var id: String = ""
@export var crop_name: String = ""
@export var row: int = 0
@export var days_to_grow: int = 2
@export var regrow_days: int = 0
@export var seed_price: int = 10
@export var sell_price: int = 25
@export var preferred_season: String = "spring"

## Bônus de estação ideal: cresce 1 dia mais rápido (mín. 1) e vende por +35%.
const SEASON_BONUS_MULTIPLIER: float = 1.35

const SEASON_LABELS: Dictionary = {
	"spring": "Primavera",
	"summer": "Verão",
	"autumn": "Outono",
	"winter": "Inverno",
}

const CROP_ORDER: Array[String] = [
	"wheat",
	"carrot",
	"strawberry",
	"corn",
	"tomato",
	"pumpkin",
	"turnip",
]

const DEFINITIONS: Dictionary = {
	"wheat": {
		"id": "wheat",
		"name": "Cana-de-Açúcar",
		"row": 0,
		"days_to_grow": 2,
		"regrow_days": 0,
		"seed_price": 10,
		"sell_price": 25,
		"icon_sheet": "base",
		"icon_col": 2,
		"preferred_season": "spring",
	},
	"carrot": {
		"id": "carrot",
		"name": "Mandioca",
		"row": 1,
		"days_to_grow": 3,
		"regrow_days": 0,
		"seed_price": 20,
		"sell_price": 55,
		"icon_sheet": "base",
		"icon_col": 3,
		"preferred_season": "autumn",
	},
	"strawberry": {
		"id": "strawberry",
		"name": "Tabaco",
		"row": 2,
		"days_to_grow": 4,
		"regrow_days": 2,
		"seed_price": 35,
		"sell_price": 110,
		"icon_sheet": "base",
		"icon_col": 4,
		"preferred_season": "spring",
	},
	"corn": {
		"id": "corn",
		"name": "Milho",
		"row": 3,
		"days_to_grow": 3,
		"regrow_days": 2,
		"seed_price": 30,
		"sell_price": 90,
		"icon_sheet": "base",
		"icon_col": 8,
		"preferred_season": "summer",
	},
	"tomato": {
		"id": "tomato",
		"name": "Feijão",
		"row": 4,
		"days_to_grow": 4,
		"regrow_days": 2,
		"seed_price": 45,
		"sell_price": 145,
		"icon_sheet": "base",
		"icon_col": 9,
		"preferred_season": "summer",
	},
	"pumpkin": {
		"id": "pumpkin",
		"name": "Algodão",
		"row": 5,
		"days_to_grow": 5,
		"regrow_days": 0,
		"seed_price": 65,
		"sell_price": 220,
		"icon_sheet": "base",
		"icon_col": 10,
		"preferred_season": "autumn",
	},
	"turnip": {
		"id": "turnip",
		"name": "Café",
		"row": 0,
		"days_to_grow": 3,
		"regrow_days": 0,
		"seed_price": 25,
		"sell_price": 70,
		"icon_sheet": "turnip",
		"icon_col": 0,
		"preferred_season": "winter",
		"sheet_path": "res://assets/sprites/seasons/turnip_sheet.png",
		"icon_path": "res://assets/sprites/seasons/turnip_icon.png",
		"hframes": 5,
		"vframes": 1,
	},
}


static func get_all_definitions() -> Dictionary:
	return DEFINITIONS.duplicate(true)


static func get_crop_order() -> Array[String]:
	return CROP_ORDER.duplicate()


static func get_preferred_season(crop_id: String) -> String:
	if not DEFINITIONS.has(crop_id):
		return ""
	return str((DEFINITIONS[crop_id] as Dictionary).get("preferred_season", ""))


static func get_preferred_season_label(crop_id: String) -> String:
	var season_id: String = get_preferred_season(crop_id)
	return str(SEASON_LABELS.get(season_id, season_id))


static func is_in_preferred_season(crop_id: String, season_id: String) -> bool:
	return DEFINITIONS.has(crop_id) and get_preferred_season(crop_id) == season_id


## Modo Cozy: todo cultivo pode ser plantado o ano inteiro (nunca murcha).
## Estação ideal = -1 dia (mín. 1). No Inverno, cultivos que não são de Inverno levam +1 dia.
static func get_effective_days_to_grow(crop_id: String, season_id: String) -> int:
	if not DEFINITIONS.has(crop_id):
		return 2
	var entry: Dictionary = DEFINITIONS[crop_id]
	var base_days: int = maxi(int(entry.get("days_to_grow", 2)), 1)
	var pref: String = str(entry.get("preferred_season", ""))
	if pref == season_id:
		return maxi(1, base_days - 1)
	if season_id == "winter" and pref != "winter":
		return base_days + 1
	return base_days


static func get_season_price_multiplier(crop_id: String, season_id: String) -> float:
	return SEASON_BONUS_MULTIPLIER if is_in_preferred_season(crop_id, season_id) else 1.0


static func get_effective_sell_price(crop_id: String, season_id: String) -> int:
	if not DEFINITIONS.has(crop_id):
		return 0
	var base_price: int = maxi(int((DEFINITIONS[crop_id] as Dictionary).get("sell_price", 0)), 0)
	return roundi(float(base_price) * get_season_price_multiplier(crop_id, season_id))


static func create_crop(crop_id: String):
	var crop = new()
	if not DEFINITIONS.has(crop_id):
		return crop
	var entry: Dictionary = DEFINITIONS[crop_id]
	crop.id = str(entry["id"])
	crop.crop_name = str(entry["name"])
	crop.row = int(entry["row"])
	crop.days_to_grow = int(entry["days_to_grow"])
	crop.regrow_days = int(entry.get("regrow_days", 0))
	crop.seed_price = int(entry["seed_price"])
	crop.sell_price = int(entry["sell_price"])
	crop.preferred_season = str(entry.get("preferred_season", "spring"))
	return crop


func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": crop_name,
		"row": row,
		"days_to_grow": days_to_grow,
		"regrow_days": regrow_days,
		"seed_price": seed_price,
		"sell_price": sell_price,
		"preferred_season": preferred_season,
	}
