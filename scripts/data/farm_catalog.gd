class_name FarmCatalog
extends RefCounted
## Catálogo central da v1.4.0: produtos animais, peixes, máquinas artesanais,
## fertilizante, compra de animais e metas do Álbum.

const ANIMAL_PRODUCTS: Dictionary = {
	"egg": {
		"id": "egg",
		"name": "Ovo",
		"sell_price": 30,
		"icon_sheet": "base",
		"icon_col": 6,
		"album_group": "artisan",
	},
	"blue_egg": {
		"id": "blue_egg",
		"name": "Ovo Azul",
		"sell_price": 55,
		"icon_sheet": "v13",
		"icon_col": 9,
		"album_group": "artisan",
	},
	"milk": {
		"id": "milk",
		"name": "Leite",
		"sell_price": 45,
		"icon_sheet": "base",
		"icon_col": 7,
		"album_group": "artisan",
	},
	"wool": {
		"id": "wool",
		"name": "Lã",
		"sell_price": 60,
		"icon_sheet": "base",
		"icon_col": 12,
		"album_group": "artisan",
	},
	"truffle": {
		"id": "truffle",
		"name": "Trufa",
		"sell_price": 80,
		"icon_sheet": "base",
		"icon_col": 13,
		"album_group": "artisan",
	},
}

const ANIMAL_PRODUCT_ORDER: Array[String] = ["egg", "blue_egg", "milk", "wool", "truffle"]

const FISH: Dictionary = {
	"tilapia": {
		"id": "tilapia",
		"name": "Tilápia",
		"sell_price": 35,
		"icon_sheet": "v13",
		"icon_col": 11,
		"album_group": "fish",
	},
	"shrimp": {
		"id": "shrimp",
		"name": "Camarão",
		"sell_price": 45,
		"icon_sheet": "v13",
		"icon_col": 12,
		"album_group": "fish",
	},
	"trout": {
		"id": "trout",
		"name": "Truta",
		"sell_price": 55,
		"icon_sheet": "v13",
		"icon_col": 13,
		"album_group": "fish",
	},
	"golden_carp": {
		"id": "golden_carp",
		"name": "Carpa Dourada",
		"sell_price": 120,
		"icon_sheet": "v13",
		"icon_col": 14,
		"album_group": "fish",
	},
}

const FISH_ORDER: Array[String] = ["tilapia", "shrimp", "trout", "golden_carp"]

const ARTISAN: Dictionary = {
	"cheese": {
		"id": "cheese",
		"name": "Queijo Colonial",
		"sell_price": 95,
		"icon_sheet": "v13",
		"icon_col": 6,
		"album_group": "artisan",
	},
	"bread": {
		"id": "bread",
		"name": "Açúcar Mascavo",
		"sell_price": 80,
		"icon_sheet": "v13",
		"icon_col": 7,
		"album_group": "artisan",
	},
	"honey": {
		"id": "honey",
		"name": "Melado de Cana",
		"sell_price": 70,
		"icon_sheet": "v13",
		"icon_col": 8,
		"album_group": "artisan",
	},
	"farinha_mandioca": {
		"id": "farinha_mandioca",
		"name": "Farinha de Mandioca",
		"sell_price": 135,
		"icon_sheet": "v13",
		"icon_col": 7,
		"album_group": "artisan",
	},
	"rolo_fumo": {
		"id": "rolo_fumo",
		"name": "Rolo de Fumo",
		"sell_price": 260,
		"icon_sheet": "v13",
		"icon_col": 8,
		"album_group": "artisan",
	},
	"saca_cafe": {
		"id": "saca_cafe",
		"name": "Saca de Café",
		"sell_price": 190,
		"icon_sheet": "v13",
		"icon_col": 6,
		"album_group": "artisan",
	},
}

const ARTISAN_ORDER: Array[String] = ["cheese", "bread", "honey", "farinha_mandioca", "rolo_fumo", "saca_cafe"]

const MACHINES: Dictionary = {
	"cheese_press": {
		"id": "cheese_press",
		"name": "Prensa de Queijo",
		"desc": "1 Leite -> Queijo Colonial (Rs 95)",
		"buy_price": 150,
		"input_cat": "animal_products",
		"input_id": "milk",
		"input_qty": 1,
		"output_id": "cheese",
		"duration_minutes": 240.0,
		"tile": Vector2i(17, 5),
		"prop_col_idle": 2,
		"prop_col_ready": 3,
		"icon_sheet": "v13",
		"icon_col": 6,
	},
	"bakery_oven": {
		"id": "bakery_oven",
		"name": "Moenda e Caldeira",
		"desc": "2 Cana -> Açúcar Mascavo (Rs 80)",
		"buy_price": 120,
		"input_cat": "harvested",
		"input_id": "wheat",
		"input_qty": 2,
		"output_id": "bread",
		"duration_minutes": 180.0,
		"tile": Vector2i(19, 5),
		"prop_col_idle": 4,
		"prop_col_ready": 5,
		"icon_sheet": "v13",
		"icon_col": 7,
	},
	"bee_hive": {
		"id": "bee_hive",
		"name": "Engenho de Melado",
		"desc": "Gera Melado (Rs 70) todo amanhecer",
		"buy_price": 180,
		"input_cat": "",
		"input_id": "",
		"input_qty": 0,
		"output_id": "honey",
		"duration_minutes": 0.0,
		"tile": Vector2i(21, 5),
		"prop_col_idle": 6,
		"prop_col_ready": 6,
		"icon_sheet": "v13",
		"icon_col": 8,
	},
}

const MACHINE_ORDER: Array[String] = ["cheese_press", "bakery_oven", "bee_hive"]

const SUPPLIES: Dictionary = {
	"fertilizer": {
		"id": "fertilizer",
		"name": "Fertilizante",
		"desc": "Mais chance de colheita Ouro ★ (1.5x)",
		"buy_price": 15,
		"icon_sheet": "v13",
		"icon_col": 4,
	},
}

const ANIMAL_SHOP: Dictionary = {
	"chicken": {
		"id": "chicken",
		"name": "Galinha",
		"buy_price": 100,
		"desc": "Ovo (Rs 30) ou Ovo Azul (Rs 55) com carinho",
		"icon_sheet": "base",
		"icon_col": 6,
	},
	"sheep": {
		"id": "sheep",
		"name": "Ovelha",
		"buy_price": 160,
		"desc": "Produz Lã (Rs 60) diariamente",
		"icon_sheet": "base",
		"icon_col": 12,
	},
	"cow": {
		"id": "cow",
		"name": "Vaca",
		"buy_price": 220,
		"desc": "Produz Leite (Rs 45) diariamente",
		"icon_sheet": "base",
		"icon_col": 7,
	},
	"pig": {
		"id": "pig",
		"name": "Porco",
		"buy_price": 260,
		"desc": "Fareja Trufa (Rs 80) diariamente",
		"icon_sheet": "base",
		"icon_col": 13,
	},
}

const ANIMAL_SHOP_ORDER: Array[String] = ["chicken", "sheep", "cow", "pig"]
const MAX_FARM_ANIMALS: int = 8

const ALBUM_GROUPS: Dictionary = {
	"crops": {
		"title": "Botânico (7/7 Cultivos)",
		"bonus_desc": "+15% no valor de venda das colheitas",
		"items": ["wheat", "carrot", "strawberry", "corn", "tomato", "pumpkin", "turnip"],
	},
	"fish": {
		"title": "Pescador (4/4 Peixes)",
		"bonus_desc": "Barra de pesca +25% mais larga",
		"items": ["tilapia", "shrimp", "trout", "golden_carp"],
	},
	"artisan": {
		"title": "Mestre Artesão (8/8 Animais & Artesanais)",
		"bonus_desc": "Máquinas produzem 30% mais rápido",
		"items": ["egg", "blue_egg", "milk", "wool", "truffle", "cheese", "bread", "honey"],
	},
}


static func get_item_info(item_id: String, crops_defs: Dictionary) -> Dictionary:
	if crops_defs.has(item_id):
		var c: Dictionary = crops_defs[item_id]
		return {
			"id": item_id,
			"name": str(c.get("name", item_id)),
			"sell_price": int(c.get("sell_price", 10)),
			"category": "harvested",
			"icon_sheet": str(c.get("icon_sheet", "base")),
			"icon_col": int(c.get("icon_col", 2)),
		}
	if ANIMAL_PRODUCTS.has(item_id):
		var a: Dictionary = ANIMAL_PRODUCTS[item_id]
		var out := a.duplicate(true)
		out["category"] = "animal_products"
		return out
	if FISH.has(item_id):
		var f: Dictionary = FISH[item_id]
		var out := f.duplicate(true)
		out["category"] = "fish"
		return out
	if ARTISAN.has(item_id):
		var ar: Dictionary = ARTISAN[item_id]
		var out := ar.duplicate(true)
		out["category"] = "artisan"
		return out
	return {}
