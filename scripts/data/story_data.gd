class_name StoryData
extends RefCounted
## Dados narrativos da v4: Historinhas, Missões da Vila Colonial e Folclore Brasileiro
## (Saci-Pererê, Mula Sem Cabeça, Curupira e Iara).

const QUEST_ORDER: Array[String] = [
	"pao_da_matriz",
	"trato_do_redemoinho",
	"fogo_estrada_real",
	"guardiao_da_mata",
	"canto_mae_dagua",
]

const QUESTS: Dictionary = {
	"pao_da_matriz": {
		"id": "pao_da_matriz",
		"title": "O Pão da Matriz",
		"giver_id": "padre",
		"giver_name": "Padre Antônio",
		"summary": "Leve 1 Farinha de Mandioca ao Padre Antônio na Vila Colonial.",
		"reward_desc": "+Rs 250 e +2 ♥ com Padre Antônio",
		"req_type": "artisan",
		"req_id": "farinha_mandioca",
		"req_qty": 1,
		"reward_money": 250,
		"intro_lines": [
			"A paz esteja contigo, lavrador! A festa da Igreja Matriz se aproxima.",
			"Preciso de 1 Farinha de Mandioca feita na Casa de Farinha para os bolos da comunidade.",
			"Traga-me uma saca e contarei o segredo para acalmar a Mula Sem Cabeça na Estrada Real."
		],
		"reminder_lines": [
			"Ainda aguardo 1 Farinha de Mandioca da Casa de Farinha (2 Mandiocas).",
			"Quando trouxer, a Matriz estará em festa!"
		],
		"complete_lines": [
			"Louvado seja! Esta farinha está clarinha e cheirosa!",
			"Tome Rs 250 pelo seu esforço. E ouça bem: se encontrar a Mula Sem Cabeça após as 19h...",
			"...receba primeiro a Bênção na Capela da fazenda antes de falar com ela!"
		],
	},
	"trato_do_redemoinho": {
		"id": "trato_do_redemoinho",
		"title": "O Trato do Redemoinho",
		"giver_id": "saci",
		"giver_name": "Saci-Pererê",
		"summary": "Ofereça 1 Rolo de Fumo (feito no Terreiro) ao Saci-Pererê à tarde (12h–18h).",
		"reward_desc": "+Rs 350 e Amuleto do Saci (+10% nas vendas)",
		"req_type": "artisan",
		"req_id": "rolo_fumo",
		"req_qty": 1,
		"reward_money": 350,
		"intro_lines": [
			"Psiu! Fiu-fiu! Achou mesmo que aquele redemoinho perto da lavoura era só vento?",
			"Eu sou o Saci-Pererê! Gosto de dar nó em crina de cavalo e esconder enxada...",
			"Mas se você secar 2 Tabacos no Terreiro e me trouxer 1 Rolo de Fumo, eu viro seu aliado!"
		],
		"reminder_lines": [
			"Hehe! Cadê meu Rolo de Fumo? Seque 2 Tabacos no Terreiro perto do Paiol!",
			"Sem fumo, sem trato, lavrador!"
		],
		"complete_lines": [
			"Aí sim! Fumo de primeira da colônia! *puf-puf*",
			"Fique com estas Rs 350 perdidas no mato e com o meu Amuleto do Saci!",
			"De hoje em diante, todas as suas vendas rendem +10% em Réis!"
		],
	},
	"fogo_estrada_real": {
		"id": "fogo_estrada_real",
		"title": "Fogo na Estrada Real",
		"giver_id": "mula",
		"giver_name": "Mula Sem Cabeça",
		"summary": "Fale com a Mula Sem Cabeça à noite (19h+) estando com a Bênção da Capela ativa.",
		"reward_desc": "+Rs 400 e Relíquia da Estrada (+15 Energia máx.)",
		"req_type": "capela_blessed",
		"req_id": "capela_blessed",
		"req_qty": 1,
		"reward_money": 400,
		"intro_lines": [
			"*Relincho flamejante ecoa pela Estrada Real...*",
			"As labaredas do pescoço da Mula Sem Cabeça iluminam os lampiões da porteira!",
			"Somente quem carregar a Bênção da Capela da fazenda pode acalmar sua maldição."
		],
		"reminder_lines": [
			"*As chamas crepitam com fúria na noite colonial...*",
			"Reze na Capela da Fazenda hoje para receber a Bênção e depois volte falar com ela!"
		],
		"complete_lines": [
			"*Ao sentir a Bênção da Capela, as labaredas se tornam douradas e serenas...*",
			"A Mula inclina-se em gratidão e deixa cair uma antiga Relíquia da Estrada Real.",
			"Você recebeu +Rs 400 e +15 de Energia máxima permanente!"
		],
	},
	"guardiao_da_mata": {
		"id": "guardiao_da_mata",
		"title": "O Guardião da Mata",
		"giver_id": "curupira",
		"giver_name": "Curupira",
		"summary": "Leve 2 Milhos (ou 1 Melado de Cana) ao Curupira na borda norte (06h–17h).",
		"reward_desc": "+Rs 250 e +5 Fertilizantes da Mata",
		"req_type": "curupira_offering",
		"req_id": "corn",
		"req_qty": 2,
		"reward_money": 250,
		"intro_lines": [
			"Pare aí! Minhas pegadas apontam para trás, mas meus olhos veem tudo nesta mata.",
			"Eu sou o Curupira. Muitos derrubam árvores sem respeito, mas vejo que você cuida da terra.",
			"Traga-me 2 Milhos ou 1 Melado de Cana como oferenda à floresta e abençoarei seu solo!"
		],
		"reminder_lines": [
			"A mata espera sua oferenda: 2 Milhos colhidos ou 1 Melado de Cana.",
			"Respeite a floresta e ela devolverá em dobro."
		],
		"complete_lines": [
			"A floresta aceita seu gesto de respeito, guardião da fazenda!",
			"Tome +5 Fertilizantes mágicos da mata e Rs 250 em moedas antigas encontradas nas raízes."
		],
	},
	"canto_mae_dagua": {
		"id": "canto_mae_dagua",
		"title": "O Canto da Mãe d'Água",
		"giver_id": "iara",
		"giver_name": "Iara (Mãe d'Água)",
		"summary": "Pesque 1 peixe no lago e entregue à Iara ao entardecer (16h–20h).",
		"reward_desc": "+Rs 300 e Bênção da Iara (pesca mais fácil)",
		"req_type": "any_fish",
		"req_id": "any_fish",
		"req_qty": 1,
		"reward_money": 300,
		"intro_lines": [
			"Ouviu meu canto sobre as águas calmas do lago, viajante?",
			"Sou a Iara, senhora dos rios e lagoas. Mostre que conhece a paciência das águas:",
			"Pesque 1 peixe qualquer neste lago e entregue-o a mim ao entardecer."
		],
		"reminder_lines": [
			"Use a Vara de Pesca na margem do lago e traga-me 1 peixe ao entardecer (16h–20h)."
		],
		"complete_lines": [
			"As águas sorriem para você! Devolvo este peixe ao fundo do lago com minha bênção.",
			"Receba +Rs 300 e a Bênção da Iara: sua barra de pesca será mais ampla para sempre!"
		],
	},
}

const VILLAGERS: Dictionary = {
	"padre": {
		"id": "padre",
		"name": "Padre Antônio",
		"role": "Pároco da Igreja Matriz",
		"quest_id": "pao_da_matriz",
		"lines": [
			"Bom dia! A Igreja Matriz é o coração da nossa vila colonial.",
			"Dizem que à noite a Mula Sem Cabeça galopa perto da porteira da fazenda...",
			"Sua fazenda prospera a cada estação! A vila inteira comenta com alegria."
		],
	},
	"ferreiro": {
		"id": "ferreiro",
		"name": "Ferreiro Joaquim",
		"role": "Mestre da Forja",
		"quest_id": "",
		"lines": [
			"O ferro quente não espera! Enxada bem afiada poupa metade da energia na roça.",
			"Já ouviu o assobio do Saci perto da lavoura? Dizem que ele adora Rolo de Fumo!",
			"Com seu esforço, esta fazenda logo será digna de um Barão do Café!"
		],
	},
	"quiteria": {
		"id": "quiteria",
		"name": "Dona Quitéria",
		"role": "Dona da Venda Colonial",
		"quest_id": "",
		"lines": [
			"Entre, freguês! Aqui na Venda temos sementes, animais e notícias frescas da Corte.",
			"Fique de olho no Tropeiro a cada 3 dias: ele paga +50% no Pedido da Corte!",
			"Seus queijos, farinhas e sacas de café são os mais procurados de toda a província!"
		],
	},
}

const FOLKLORE_ORDER: Array[String] = ["saci", "mula", "curupira", "iara"]

const FOLKLORE_INFO: Dictionary = {
	"saci": {
		"id": "saci",
		"name": "Saci-Pererê",
		"schedule": "Tarde (12h–18h) perto da lavoura",
		"quest_id": "trato_do_redemoinho",
	},
	"mula": {
		"id": "mula",
		"name": "Mula Sem Cabeça",
		"schedule": "Noite (19h–02h) na Estrada Real",
		"quest_id": "fogo_estrada_real",
	},
	"curupira": {
		"id": "curupira",
		"name": "Curupira",
		"schedule": "Dia (06h–17h) na mata ao norte",
		"quest_id": "guardiao_da_mata",
	},
	"iara": {
		"id": "iara",
		"name": "Iara (Mãe d'Água)",
		"schedule": "Entardecer (16h–20h) no lago",
		"quest_id": "canto_mae_dagua",
	},
}
