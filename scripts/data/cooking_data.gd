class_name CookingData
extends RefCounted
## Receitas da Culinária Colonial (fogão de lenha da Casa-Grande)
## e itens exclusivos das lojas internas da Vila de São Sebastião.

const RECIPE_ORDER: Array[String] = [
	"caldo_cana",
	"cafe_coado",
	"bolo_fuba",
	"peixe_assado",
	"pao_de_queijo",
]

const RECIPES: Dictionary = {
	"caldo_cana": {
		"id": "caldo_cana",
		"name": "Caldo de Cana",
		"energy": 30,
		"sell_price": 85,
		"ingredients": [{"bucket": "harvested", "id": "wheat", "qty": 2, "label": "2 Cana"}],
	},
	"cafe_coado": {
		"id": "cafe_coado",
		"name": "Café Coado",
		"energy": 35,
		"sell_price": 95,
		"ingredients": [{"bucket": "harvested", "id": "turnip", "qty": 1, "label": "1 Café"}],
	},
	"bolo_fuba": {
		"id": "bolo_fuba",
		"name": "Bolo de Fubá",
		"energy": 40,
		"sell_price": 125,
		"ingredients": [
			{"bucket": "harvested", "id": "corn", "qty": 2, "label": "2 Milho"},
			{"bucket": "animal_products", "id": "egg", "qty": 1, "label": "1 Ovo"},
		],
	},
	"peixe_assado": {
		"id": "peixe_assado",
		"name": "Peixe Assado",
		"energy": 50,
		"sell_price": 115,
		"ingredients": [{"bucket": "fish", "id": "tilapia", "qty": 1, "label": "1 Tilápia"}],
	},
	"pao_de_queijo": {
		"id": "pao_de_queijo",
		"name": "Pão de Queijo",
		"energy": 45,
		"sell_price": 140,
		"ingredients": [
			{"bucket": "artisan", "id": "cheese", "qty": 1, "label": "1 Queijo"},
			{"bucket": "animal_products", "id": "egg", "qty": 1, "label": "1 Ovo"},
		],
	},
}

const VILLAGE_SHOP_ITEMS: Dictionary = {
	"botica": [
		{"id": "elixir_ervas", "name": "Elixir de Ervas da Botica", "price": 65, "energy": 60},
		{"id": "cha_cidreira", "name": "Chá de Erva-Cidreira", "price": 35, "energy": 30},
	],
	"estalagem": [
		{"id": "prato_colonial", "name": "Prato Feito Colonial", "price": 90, "energy": 70},
		{"id": "pao_queijo_quente", "name": "Pão de Queijo Quentinho", "price": 60, "energy": 45},
	],
}
