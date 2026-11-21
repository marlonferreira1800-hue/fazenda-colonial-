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

const BOOK_CHAPTER_ORDER: Array[String] = [
	"serao_dona_benta",
	"emilia_reino_aguas",
	"visconde_sabugo",
	"pedrinho_e_o_saci",
	"cuca_mata_colonial",
	"quindim_rabico_festa",
]

## Livro de Histórias do Sítio (inspirado na obra em domínio público de Monteiro Lobato)
## adaptado ao universo e às mecânicas da Fazenda Colonial.
const BOOK_CHAPTERS: Dictionary = {
	"serao_dona_benta": {
		"id": "serao_dona_benta",
		"title": "I. Os Serões de Dona Benta",
		"short_title": "I. Dona Benta",
		"subtitle": "Dona Benta & Tia Nastácia",
		"realm_id": "varanda_sitio",
		"unlock_type": "always",
		"unlock_req": "",
		"unlock_hint": "Disponível desde o início na estante da casa.",
		"pages": [
			"Ao cair da tarde, quando a enxada descansa e a lareira começa a crepitar, Dona Benta abre este velho livro encadernado em couro na varanda da fazenda.",
			"Da cozinha de Tia Nastácia sobe o cheiro de broa de milho, pão caseiro e chá quentinho — um convite para ouvir histórias que misturam imaginação e vida na roça.",
			"\"Quem cuida da terra com carinho\", diz Dona Benta, \"descobre que cada canto do sítio guarda um encanto: da mata ao norte até as águas calmas do lago.\""
		],
	},
	"emilia_reino_aguas": {
		"id": "emilia_reino_aguas",
		"title": "II. Emília e as Águas Claras",
		"short_title": "II. Emília",
		"subtitle": "Narizinho & o Ribeirão",
		"realm_id": "aguas_claras",
		"unlock_type": "always",
		"unlock_req": "",
		"unlock_hint": "Disponível desde o início na estante da casa.",
		"pages": [
			"Narizinho adorava sentar-se à beira do ribeirão com sua boneca de pano, Emília, observando os peixinhos brilharem sob o sol da tarde.",
			"Depois que o Doutor Caramujo deu à boneca a famosa pílula falante, Emília nunca mais parou de tagarelar — e jurava ouvir um canto misterioso vindo do fundo do lago.",
			"Dica do Sítio: ao entardecer (16h–20h), leve sua Vara de Pesca até a margem do lago. Dizem que a própria Iara aparece para quem pesca com paciência!"
		],
	},
	"visconde_sabugo": {
		"id": "visconde_sabugo",
		"title": "III. O Visconde de Sabugosa",
		"short_title": "III. Visconde",
		"subtitle": "O Sábio da Estante e do Milharal",
		"realm_id": "biblioteca_visconde",
		"unlock_type": "item",
		"unlock_req": "corn",
		"unlock_hint": "Desbloqueia ao colher Milho pela primeira vez na fazenda.",
		"pages": [
			"Feito de um sabugo de milho esquecido entre os livros antigos da estante, o Visconde de Sabugosa leu tanto que virou o maior sábio de toda a fazenda!",
			"Com sua cartolinha bem aprumada, ele estuda o solo, as estações e o crescimento das espigas douradas, anotando cada segredo da lavoura no seu caderno.",
			"Anotação do Visconde: \"O Curupira vigia a mata ao norte entre 06h e 17h. Quem lhe oferecer 2 Milhos ou 1 Melado de Cana recebe fertilizantes mágicos da floresta!\""
		],
	},
	"pedrinho_e_o_saci": {
		"id": "pedrinho_e_o_saci",
		"title": "IV. Pedrinho e o Redemoinho",
		"short_title": "IV. O Saci",
		"subtitle": "As Lições de Tio Barnabé",
		"realm_id": "capoeirao_saci",
		"unlock_type": "folklore",
		"unlock_req": "saci",
		"unlock_hint": "Desbloqueia ao encontrar o Saci-Pererê à tarde (12h–18h).",
		"pages": [
			"Pedrinho sempre sonhou em ver um Saci de perto. Foi Tio Barnabé quem lhe ensinou: quando um redemoinho de folhas dança perto da roça à tarde, o peralta está lá dentro!",
			"De gorro vermelho e cachimbo na boca, o Saci adora pregar peças na fazenda, dar nó em crina de cavalo e assobiar de longe só para confundir o lavrador.",
			"Segredo de Tio Barnabé: \"Em vez de tentar prendê-lo na garrafa, faça amizade! Seque Tabaco no Terreiro e ofereça 1 Rolo de Fumo ao Saci — ele retribui com sorte nas vendas.\""
		],
	},
	"cuca_mata_colonial": {
		"id": "cuca_mata_colonial",
		"title": "V. Mistérios da Mata e da Noite",
		"short_title": "V. A Mata",
		"subtitle": "Lendas da Estrada Real",
		"realm_id": "gruta_cuca",
		"unlock_type": "folklore_any",
		"unlock_req": ["curupira", "mula"],
		"unlock_hint": "Desbloqueia ao encontrar o Curupira ou a Mula Sem Cabeça.",
		"pages": [
			"Quando a noite cai sobre a fazenda e os lampiões se acendem, até os mais valentes lembram das histórias da Cuca na gruta e das lendas que rondam a Estrada Real.",
			"Na mata fechada, o Curupira protege as árvores com suas pegadas viradas para trás; já na estrada, após as 19h, o galope flamejante da Mula Sem Cabeça ilumina a neblina.",
			"Conselho de Dona Benta: \"O medo se dissipa com respeito e fé. Antes de falar com a Mula Sem Cabeça à noite, faça uma prece na Capela da fazenda para receber a Bênção.\""
		],
	},
	"quindim_rabico_festa": {
		"id": "quindim_rabico_festa",
		"title": "VI. O Quintal de Tia Nastácia",
		"short_title": "VI. O Quintal",
		"subtitle": "Bichos, Forno e Festa na Vila",
		"realm_id": "varanda_sitio",
		"unlock_type": "quest_or_artisan",
		"unlock_req": "",
		"unlock_hint": "Desbloqueia ao concluir uma missão ou produzir um item artesanal.",
		"pages": [
			"No quintal do sítio nunca falta alegria: o guloso Marquês de Rabicó fareja jabuticabas, o sábio burro Conselheiro observa o pasto e o bom rinoceronte Quindim vigia a porteira.",
			"Enquanto isso, a Casa de Farinha, a prensa de queijos e o forno de barro trabalham a todo vapor, enchendo a mesa da fazenda e alegrando as festas da Igreja Matriz.",
			"E assim, entre colheitas, bichos cuidados e boas histórias à beira da lareira, a sua Fazenda Colonial torna-se um verdadeiro Sítio de encantos!"
		],
	},
}

const SITIO_REALMS: Dictionary = {
	"varanda_sitio": {
		"id": "varanda_sitio",
		"name": "Varanda & Jabuticabeira do Sítio",
		"ground_color": Color(0.36, 0.62, 0.30, 1.0),
		"plaza_color": Color(0.76, 0.62, 0.44, 1.0),
		"particle_color": Color(1.0, 0.90, 0.45, 0.95),
		"magic_title": "Bolinhos de Chuva da Tia Nastácia",
		"magic_desc": "Restaura 100% da Energia + 1 Pão/Bolinho artesanal (1x/dia)",
		"magic_prompt": "[F] Provar Bolinhos de Chuva (Magia do Sítio)",
		"magic_sprite": "res://assets/sprites/sitio_px/mesa_bolinhos.png",
		"magic_pos": Vector2(192.0, 128.0),
		"relic_name": "Jabuticabeira Encantada",
		"relic_sprite": "res://assets/sprites/sitio_px/jabuticabeira.png",
		"relic_farm_pos": Vector2(216.0, 108.0),
		"props": [
			{"sprite": "res://assets/sprites/sitio_px/jabuticabeira.png", "pos": Vector2(92.0, 106.0), "offset": Vector2(0.0, -20.0), "col": Vector2(18.0, 12.0)},
			{"sprite": "res://assets/sprites/sitio_px/jabuticabeira.png", "pos": Vector2(292.0, 106.0), "offset": Vector2(0.0, -20.0), "col": Vector2(18.0, 12.0)},
			{"sprite": "res://assets/sprites/sitio_px/estante_visconde.png", "pos": Vector2(192.0, 62.0), "offset": Vector2(0.0, -16.0), "col": Vector2(24.0, 12.0)},
		],
		"npcs": [
			{
				"id": "dona_benta",
				"name": "Dona Benta",
				"sprite": "res://assets/sprites/sitio_px/npc_dona_benta.png",
				"pos": Vector2(142.0, 118.0),
				"lines": [
					"Que alegria receber você na nossa varanda através do Pó de Pirlimpimpim!",
					"Os livros abrem portas para mundos inteiros — e cada visita traz um encanto novo para a sua Fazenda Colonial.",
					"Prove os bolinhos da mesa de Tia Nastácia para renovar todas as suas forças!"
				],
			},
			{
				"id": "tia_nastacia",
				"name": "Tia Nastácia",
				"sprite": "res://assets/sprites/sitio_px/npc_tia_nastacia.png",
				"pos": Vector2(242.0, 118.0),
				"lines": [
					"Acabei de tirar estes bolinhos de chuva e pão quentinho do forno de barro!",
					"Coma à vontade, meu filho — fazendeiro bem alimentado colhe o dobro na roça!",
					"Leve também uma mudinha da nossa Jabuticabeira Encantada para enfeitar sua fazenda."
				],
			},
			{
				"id": "rabico",
				"name": "Marquês de Rabicó",
				"sprite": "res://assets/sprites/sitio_px/npc_rabico.png",
				"pos": Vector2(96.0, 164.0),
				"lines": [
					"*Oinc! Oinc!* O cheiro das jabuticabas e dos bolinhos está irresistível!",
					"Dizem que se você cuidar bem dos bichos da sua fazenda, a sorte nunca falta no quintal!"
				],
			},
		],
	},
	"aguas_claras": {
		"id": "aguas_claras",
		"name": "Reino das Águas Claras",
		"ground_color": Color(0.14, 0.44, 0.62, 1.0),
		"plaza_color": Color(0.24, 0.60, 0.76, 1.0),
		"particle_color": Color(0.70, 0.96, 1.0, 0.90),
		"magic_title": "Encanto das Águas Claras",
		"magic_desc": "Rega automaticamente TODAS as plantações da fazenda hoje (1x/dia)",
		"magic_prompt": "[F] Ativar Fonte das Águas Claras (Regar Fazenda)",
		"magic_sprite": "res://assets/sprites/sitio_px/fonte_aguas.png",
		"magic_pos": Vector2(192.0, 128.0),
		"relic_name": "Fonte das Águas Claras",
		"relic_sprite": "res://assets/sprites/sitio_px/fonte_aguas.png",
		"relic_farm_pos": Vector2(364.0, 212.0),
		"props": [
			{"sprite": "res://assets/sprites/sitio_px/fonte_aguas.png", "pos": Vector2(92.0, 102.0), "offset": Vector2(0.0, -12.0), "col": Vector2(18.0, 10.0)},
			{"sprite": "res://assets/sprites/sitio_px/fonte_aguas.png", "pos": Vector2(292.0, 102.0), "offset": Vector2(0.0, -12.0), "col": Vector2(18.0, 10.0)},
			{"sprite": "res://assets/sprites/sitio_px/cogumelo_magico.png", "pos": Vector2(118.0, 186.0), "offset": Vector2(0.0, -8.0), "col": Vector2(10.0, 6.0)},
			{"sprite": "res://assets/sprites/sitio_px/cogumelo_magico.png", "pos": Vector2(266.0, 186.0), "offset": Vector2(0.0, -8.0), "col": Vector2(10.0, 6.0)},
		],
		"npcs": [
			{
				"id": "emilia",
				"name": "Emília",
				"sprite": "res://assets/sprites/sitio_px/npc_emilia.png",
				"pos": Vector2(146.0, 124.0),
				"lines": [
					"Ora, ora! Até que enfim alguém usou meu Pó de Pirlimpimpim direito!",
					"Aqui no Reino das Águas Claras a água obedece à imaginação!",
					"Toque na Fonte Luminosa aí no meio e eu mando uma chuva encantada regar sua lavoura inteirinha!"
				],
			},
			{
				"id": "narizinho",
				"name": "Narizinho",
				"sprite": "res://assets/sprites/sitio_px/npc_narizinho.png",
				"pos": Vector2(238.0, 124.0),
				"lines": [
					"Bem-vindo ao Reino das Águas Claras! As bolhas brilhantes trazem frescor para toda a fazenda.",
					"Quando voltar pelo portal dourado, sua fonte mágica também brilhará perto do lago!"
				],
			},
		],
	},
	"biblioteca_visconde": {
		"id": "biblioteca_visconde",
		"name": "Biblioteca Viva do Visconde",
		"ground_color": Color(0.28, 0.16, 0.14, 1.0),
		"plaza_color": Color(0.56, 0.24, 0.22, 1.0),
		"particle_color": Color(1.0, 0.86, 0.38, 0.95),
		"magic_title": "Sabedoria do Sabugo",
		"magic_desc": "Avança +1 estágio de crescimento em todas as lavouras da fazenda (1x/dia)",
		"magic_prompt": "[F] Consultar Estante Viva (Acelerar Lavouras)",
		"magic_sprite": "res://assets/sprites/sitio_px/estante_visconde.png",
		"magic_pos": Vector2(192.0, 118.0),
		"relic_name": "Estante Sábia do Visconde",
		"relic_sprite": "res://assets/sprites/sitio_px/estante_visconde.png",
		"relic_farm_pos": Vector2(128.0, 152.0),
		"props": [
			{"sprite": "res://assets/sprites/sitio_px/estante_visconde.png", "pos": Vector2(96.0, 88.0), "offset": Vector2(0.0, -16.0), "col": Vector2(24.0, 12.0)},
			{"sprite": "res://assets/sprites/sitio_px/estante_visconde.png", "pos": Vector2(288.0, 88.0), "offset": Vector2(0.0, -16.0), "col": Vector2(24.0, 12.0)},
			{"sprite": "res://assets/sprites/sitio_px/estante_visconde.png", "pos": Vector2(96.0, 172.0), "offset": Vector2(0.0, -16.0), "col": Vector2(24.0, 12.0)},
			{"sprite": "res://assets/sprites/sitio_px/estante_visconde.png", "pos": Vector2(288.0, 172.0), "offset": Vector2(0.0, -16.0), "col": Vector2(24.0, 12.0)},
		],
		"npcs": [
			{
				"id": "visconde",
				"name": "Visconde de Sabugosa",
				"sprite": "res://assets/sprites/sitio_px/npc_visconde.png",
				"pos": Vector2(150.0, 134.0),
				"lines": [
					"Saudações científicas, nobre lavrador! Vejo que já colheu belas espigas de milho!",
					"Minhas pesquisas botânicas descobriram como acelerar a germinação com a sabedoria dos livros.",
					"Consulte a Estante Viva ao centro e todas as suas plantações darão um salto de crescimento!"
				],
			},
		],
	},
	"capoeirao_saci": {
		"id": "capoeirao_saci",
		"name": "Capoeirão do Saci",
		"ground_color": Color(0.18, 0.38, 0.20, 1.0),
		"plaza_color": Color(0.46, 0.38, 0.24, 1.0),
		"particle_color": Color(0.76, 0.96, 0.44, 0.95),
		"magic_title": "Redemoinho da Fortuna",
		"magic_desc": "Concede +Rs 150 em moedas escondidas na mata + sorte mágica (1x/dia)",
		"magic_prompt": "[F] Girar o Redemoinho Mágico (+Rs 150)",
		"magic_sprite": "res://assets/sprites/sitio_px/redemoinho_saci.png",
		"magic_pos": Vector2(192.0, 128.0),
		"relic_name": "Redemoinho Amigo do Saci",
		"relic_sprite": "res://assets/sprites/sitio_px/redemoinho_saci.png",
		"relic_farm_pos": Vector2(286.0, 268.0),
		"props": [
			{"sprite": "res://assets/sprites/sitio_px/jabuticabeira.png", "pos": Vector2(88.0, 96.0), "offset": Vector2(0.0, -20.0), "col": Vector2(18.0, 12.0)},
			{"sprite": "res://assets/sprites/sitio_px/jabuticabeira.png", "pos": Vector2(296.0, 96.0), "offset": Vector2(0.0, -20.0), "col": Vector2(18.0, 12.0)},
			{"sprite": "res://assets/sprites/sitio_px/cogumelo_magico.png", "pos": Vector2(108.0, 182.0), "offset": Vector2(0.0, -8.0), "col": Vector2(10.0, 6.0)},
			{"sprite": "res://assets/sprites/sitio_px/cogumelo_magico.png", "pos": Vector2(276.0, 182.0), "offset": Vector2(0.0, -8.0), "col": Vector2(10.0, 6.0)},
		],
		"npcs": [
			{
				"id": "pedrinho",
				"name": "Pedrinho",
				"sprite": "res://assets/sprites/sitio_px/npc_pedrinho.png",
				"pos": Vector2(146.0, 128.0),
				"lines": [
					"Ei! Você também veio explorar o Capoeirão atrás do Saci?",
					"Tio Barnabé disse que esse redemoinho dourado guarda moedas antigas perdidas pela mata!"
				],
			},
			{
				"id": "tio_barnabe",
				"name": "Tio Barnabé",
				"sprite": "res://assets/sprites/sitio_px/npc_tio_barnabe.png",
				"pos": Vector2(240.0, 128.0),
				"lines": [
					"Quem respeita as histórias da mata ganha a amizade do Saci-Pererê.",
					"Chegue perto do Redemoinho Mágico com [F] e receba a sorte do capoeirão!"
				],
			},
		],
	},
	"gruta_cuca": {
		"id": "gruta_cuca",
		"name": "Gruta Encantada da Cuca",
		"ground_color": Color(0.16, 0.12, 0.24, 1.0),
		"plaza_color": Color(0.24, 0.18, 0.34, 1.0),
		"particle_color": Color(0.68, 0.98, 0.62, 0.95),
		"magic_title": "Poção Dourada da Cuca",
		"magic_desc": "Enfeitiça até 3 plantações da fazenda com fertilizante Ouro ★ (1x/dia)",
		"magic_prompt": "[F] Mexer o Caldeirão da Cuca (Ouro ★ na Roça)",
		"magic_sprite": "res://assets/sprites/sitio_px/caldeirao_cuca.png",
		"magic_pos": Vector2(192.0, 126.0),
		"relic_name": "Caldeirão Borbulhante",
		"relic_sprite": "res://assets/sprites/sitio_px/caldeirao_cuca.png",
		"relic_farm_pos": Vector2(364.0, 96.0),
		"props": [
			{"sprite": "res://assets/sprites/sitio_px/cogumelo_magico.png", "pos": Vector2(96.0, 98.0), "offset": Vector2(0.0, -8.0), "col": Vector2(10.0, 6.0)},
			{"sprite": "res://assets/sprites/sitio_px/cogumelo_magico.png", "pos": Vector2(288.0, 98.0), "offset": Vector2(0.0, -8.0), "col": Vector2(10.0, 6.0)},
			{"sprite": "res://assets/sprites/sitio_px/cogumelo_magico.png", "pos": Vector2(114.0, 182.0), "offset": Vector2(0.0, -8.0), "col": Vector2(10.0, 6.0)},
			{"sprite": "res://assets/sprites/sitio_px/cogumelo_magico.png", "pos": Vector2(270.0, 182.0), "offset": Vector2(0.0, -8.0), "col": Vector2(10.0, 6.0)},
		],
		"npcs": [
			{
				"id": "cuca",
				"name": "Cuca",
				"sprite": "res://assets/sprites/sitio_px/npc_cuca.png",
				"pos": Vector2(146.0, 122.0),
				"lines": [
					"Hehehe! Ora, ora... um lavrador corajoso visitando a minha Gruta Encantada!",
					"Já que você conhece as lendas da mata e da noite, hoje estou de bom humor...",
					"Mexa no meu Caldeirão Borbulhante e vou jogar um feitiço de Ouro ★ nas suas plantações!"
				],
			},
		],
	},
}


