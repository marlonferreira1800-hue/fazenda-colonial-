extends RefCounted
## Dados da Vila Colonial (Vila de São Sebastião), Vale do Ribeirão, edificações,
## grafo de estradas e rotinas autônomas dos 8 moradores.


static func get_road_graph(tile_size: int) -> Dictionary:
	var ts: float = float(tile_size)
	var raw: Dictionary = {
		"capela": {"tile": Vector2(4.5, 6.5), "neighbors": ["farm_yard"]},
		"farm_yard": {"tile": Vector2(8.5, 6.5), "neighbors": ["capela", "farm_cross"]},
		"farm_cross": {"tile": Vector2(17.5, 6.5), "neighbors": ["farm_yard", "farm_east_top", "estrada_porteira"]},
		"farm_east_top": {"tile": Vector2(26.5, 6.5), "neighbors": ["farm_cross", "farm_east_mid"]},
		"farm_east_mid": {"tile": Vector2(26.5, 11.5), "neighbors": ["farm_east_top", "village_entry"]},
		"village_entry": {"tile": Vector2(41.5, 11.5), "neighbors": ["farm_east_mid", "village_nw", "praca_w", "village_sw_lane"]},
		"village_nw": {"tile": Vector2(41.5, 8.5), "neighbors": ["village_entry", "venda_front"]},
		"venda_front": {"tile": Vector2(44.5, 8.5), "neighbors": ["village_nw", "praca_nw"]},
		"praca_nw": {"tile": Vector2(48.5, 8.5), "neighbors": ["venda_front", "ferraria_front", "praca_w"]},
		"ferraria_front": {"tile": Vector2(52.5, 8.5), "neighbors": ["praca_nw", "praca_ne"]},
		"praca_ne": {"tile": Vector2(56.5, 8.5), "neighbors": ["ferraria_front", "botica_front", "praca_e"]},
		"botica_front": {"tile": Vector2(60.5, 8.5), "neighbors": ["praca_ne", "village_ne_corner"]},
		"village_ne_corner": {"tile": Vector2(62.5, 8.5), "neighbors": ["botica_front", "village_e"]},
		"praca_w": {"tile": Vector2(48.5, 11.5), "neighbors": ["village_entry", "praca_nw", "praca_sw"]},
		"praca_e": {"tile": Vector2(56.5, 11.5), "neighbors": ["praca_ne", "village_e", "praca_se"]},
		"village_e": {"tile": Vector2(62.5, 11.5), "neighbors": ["praca_e", "village_ne_corner", "village_se_corner"]},
		"praca_sw": {"tile": Vector2(48.5, 14.5), "neighbors": ["praca_w", "praca_s", "village_s_mid"]},
		"praca_s": {"tile": Vector2(51.5, 14.5), "neighbors": ["praca_sw", "praca_se"]},
		"praca_se": {"tile": Vector2(56.5, 14.5), "neighbors": ["praca_s", "praca_e", "village_se_lane"]},
		"village_sw_lane": {"tile": Vector2(41.5, 20.5), "neighbors": ["village_entry", "pescador_front"]},
		"pescador_front": {"tile": Vector2(44.5, 20.5), "neighbors": ["village_sw_lane", "village_s_mid"]},
		"village_s_mid": {"tile": Vector2(48.5, 20.5), "neighbors": ["praca_sw", "pescador_front", "sinha_front", "vale_east"]},
		"sinha_front": {"tile": Vector2(52.5, 20.5), "neighbors": ["village_s_mid", "village_se_lane"]},
		"village_se_lane": {"tile": Vector2(56.5, 20.5), "neighbors": ["praca_se", "sinha_front", "estalagem_front"]},
		"estalagem_front": {"tile": Vector2(60.5, 20.5), "neighbors": ["village_se_lane", "village_se_corner"]},
		"village_se_corner": {"tile": Vector2(62.5, 20.5), "neighbors": ["estalagem_front", "village_e"]},
		"vale_east": {"tile": Vector2(48.5, 29.5), "neighbors": ["village_s_mid", "ponte_east"]},
		"ponte_east": {"tile": Vector2(38.5, 29.5), "neighbors": ["vale_east", "ponte_west"]},
		"ponte_west": {"tile": Vector2(30.5, 29.5), "neighbors": ["ponte_east", "chico_front"]},
		"chico_front": {"tile": Vector2(24.5, 29.5), "neighbors": ["ponte_west", "estrada_sul"]},
		"estrada_sul": {"tile": Vector2(17.5, 29.5), "neighbors": ["chico_front", "paroquial_front", "estrada_porteira"]},
		"paroquial_front": {"tile": Vector2(10.5, 29.5), "neighbors": ["estrada_sul"]},
		"estrada_porteira": {"tile": Vector2(17.5, 22.5), "neighbors": ["estrada_sul", "farm_cross"]},
	}
	var graph: Dictionary = {}
	for k in raw.keys():
		var item: Dictionary = raw[k]
		var t: Vector2 = item["tile"]
		graph[k] = {
			"pos": Vector2(t.x * ts, t.y * ts),
			"neighbors": item["neighbors"],
		}
	return graph


static func get_village_buildings() -> Array[Dictionary]:
	return [
		{
			"name": "VendaSecosMolhados",
			"owner_id": "manoel",
			"tex": "res://assets/sprites/colonial_buildings_px/venda_secos_molhados.png",
			"tile": Vector2(44.5, 7.2),
			"offset": Vector2(0.0, -20.0),
			"collider": Rect2(0.0, -10.0, 46.0, 22.0),
			"window_pos": Vector2(0.0, -14.0),
		},
		{
			"name": "FerrariaColonial",
			"owner_id": "bento",
			"tex": "res://assets/sprites/colonial_buildings_px/ferraria_colonial.png",
			"tile": Vector2(52.5, 7.2),
			"offset": Vector2(0.0, -20.0),
			"collider": Rect2(0.0, -10.0, 44.0, 22.0),
			"window_pos": Vector2(-12.0, -10.0),
		},
		{
			"name": "BoticaColonial",
			"owner_id": "quiteria",
			"tex": "res://assets/sprites/colonial_buildings_px/botica_colonial.png",
			"tile": Vector2(60.5, 7.2),
			"offset": Vector2(0.0, -19.0),
			"collider": Rect2(0.0, -10.0, 40.0, 20.0),
			"window_pos": Vector2(0.0, -14.0),
		},
		{
			"name": "CoretoVila",
			"owner_id": "",
			"tex": "res://assets/sprites/colonial_buildings_px/coreto_vila.png",
			"tile": Vector2(52.5, 12.2),
			"offset": Vector2(0.0, -18.0),
			"collider": Rect2(0.0, -6.0, 34.0, 18.0),
			"window_pos": Vector2.ZERO,
		},
		{
			"name": "CasaPescador",
			"owner_id": "tiao",
			"tex": "res://assets/sprites/colonial_buildings_px/casa_colonial_azul.png",
			"tile": Vector2(44.5, 19.0),
			"offset": Vector2(0.0, -19.0),
			"collider": Rect2(0.0, -10.0, 40.0, 20.0),
			"window_pos": Vector2(0.0, -14.0),
		},
		{
			"name": "CasaTecela",
			"owner_id": "sinha",
			"tex": "res://assets/sprites/colonial_buildings_px/casa_colonial_ocre.png",
			"tile": Vector2(52.5, 19.0),
			"offset": Vector2(0.0, -19.0),
			"collider": Rect2(0.0, -10.0, 40.0, 20.0),
			"window_pos": Vector2(0.0, -14.0),
		},
		{
			"name": "EstalagemColonial",
			"owner_id": "ze",
			"tex": "res://assets/sprites/colonial_buildings_px/estalagem_colonial.png",
			"tile": Vector2(60.5, 19.0),
			"offset": Vector2(0.0, -20.0),
			"collider": Rect2(0.0, -10.0, 46.0, 22.0),
			"window_pos": Vector2(0.0, -14.0),
		},
		{
			"name": "CasaParoquial",
			"owner_id": "antonio",
			"tex": "res://assets/sprites/colonial_buildings_px/casa_paroquial.png",
			"tile": Vector2(10.5, 28.0),
			"offset": Vector2(0.0, -19.0),
			"collider": Rect2(0.0, -10.0, 40.0, 20.0),
			"window_pos": Vector2(0.0, -14.0),
		},
		{
			"name": "CasaRoceiro",
			"owner_id": "chico",
			"tex": "res://assets/sprites/colonial_buildings_px/casa_colonial_terracota.png",
			"tile": Vector2(24.5, 28.0),
			"offset": Vector2(0.0, -19.0),
			"collider": Rect2(0.0, -10.0, 40.0, 20.0),
			"window_pos": Vector2(0.0, -14.0),
		},
	]


static func get_villager_specs(tile_size: int) -> Array[Dictionary]:
	var ts: float = float(tile_size)
	return [
		{
			"id": "manoel",
			"name": "Seu Manoel",
			"role": "Vendeiro",
			"home_node": "venda_front",
			"home_door_pos": Vector2(44.5 * ts, 8.2 * ts),
			"sprite": "res://assets/sprites/colonial_buildings_px/villager_manoel.png",
			"speed": 30.0,
			"schedule": [
				{"start_min": 360.0, "node": "venda_front", "activity": "Abrindo a Venda", "indoors": false, "chatter": ["Bom dia, freguesia!", "Abrindo o armazém..."]},
				{"start_min": 720.0, "node": "praca_s", "activity": "Almoço na Praça", "indoors": false, "shelter_in_rain": true, "chatter": ["Que movimento bom hoje!", "A vila tá crescendo!"]},
				{"start_min": 840.0, "node": "venda_front", "activity": "Atendendo na Venda", "indoors": false, "chatter": ["Sementes frescas!", "Açúcar e café de primeira!"]},
				{"start_min": 1050.0, "node": "estalagem_front", "activity": "Prosa na Estalagem", "indoors": false, "shelter_in_rain": true, "chatter": ["Boa noite, compadres!"]},
				{"start_min": 1200.0, "node": "venda_front", "activity": "Dormindo", "indoors": true, "chatter": []},
			],
			"dialogues": {
				"morning": [
					"Bom dia! O Armazém Secos & Molhados já está de portas abertas.",
					"Chegaram sementes novas pela Estrada Real! Dê uma olhada na Loja.",
				],
				"afternoon": [
					"A Vila de São Sebastião agradece a sua produção, vizinho!",
					"Quando o Tropeiro passar, aproveite o preço especial do Pedido da Corte!",
				],
				"evening": [
					"Que dia produtivo! Agora vou prosear um pouco na Estalagem do Zé.",
				],
				"rainy": [
					"Chuva boa pra lavoura! Hoje o movimento na venda tá mais calmo.",
				],
				"friend": [
					"Você é o melhor fazendeiro desta freguesia! Sempre bem-vindo aqui!",
				],
			},
		},
		{
			"id": "bento",
			"name": "Mestre Bento",
			"role": "Ferreiro",
			"home_node": "ferraria_front",
			"home_door_pos": Vector2(52.5 * ts, 8.2 * ts),
			"sprite": "res://assets/sprites/colonial_buildings_px/villager_bento.png",
			"speed": 29.0,
			"schedule": [
				{"start_min": 360.0, "node": "praca_w", "activity": "Buscando água pra forja", "indoors": false, "chatter": ["Água fresca pra temperar o aço."]},
				{"start_min": 450.0, "node": "ferraria_front", "activity": "Forjando ferramentas", "indoors": false, "chatter": ["Tlim-tlim! A bigorna não para!", "Ferro quente!"]},
				{"start_min": 750.0, "node": "praca_s", "activity": "Descanso no Coreto", "indoors": false, "shelter_in_rain": true, "chatter": ["Uf, o calor da forja hoje tá forte!"]},
				{"start_min": 840.0, "node": "ferraria_front", "activity": "Trabalhando na Ferraria", "indoors": false, "chatter": ["Enxada bem afiada rende o dobro!"]},
				{"start_min": 1060.0, "node": "estalagem_front", "activity": "Descansando na Estalagem", "indoors": false, "chatter": ["Uma boa prosa depois da bigorna!"]},
				{"start_min": 1220.0, "node": "ferraria_front", "activity": "Dormindo", "indoors": true, "chatter": []},
			],
			"dialogues": {
				"morning": [
					"Bom dia! Já acendi a forja cedo. Ferramenta boa dura a vida toda!",
					"Se aprimorar sua Enxada e Regador na Loja, vai arar até 3x3 de uma vez!",
				],
				"afternoon": [
					"Tlim-tlim! O engenho e a lavoura precisam de bom ferro colonial.",
					"Passe sempre pela Ferraria quando quiser trocar uma ideia.",
				],
				"evening": [
					"Forja apagada por hoje. Hora de ouvir a viola do Zé do Cravo!",
				],
				"rainy": [
					"A chuva ajuda a refrescar o calor da forja!",
				],
				"friend": [
					"Compadre, com sua dedicação essa fazenda vai virar referência no Brasil!",
				],
			},
		},
		{
			"id": "quiteria",
			"name": "Dona Quitéria",
			"role": "Curandeira",
			"home_node": "botica_front",
			"home_door_pos": Vector2(60.5 * ts, 8.2 * ts),
			"sprite": "res://assets/sprites/colonial_buildings_px/villager_quiteria.png",
			"speed": 28.0,
			"schedule": [
				{"start_min": 360.0, "node": "village_e", "activity": "Colhendo ervas", "indoors": false, "shelter_in_rain": true, "chatter": ["Alecrim, erva-cidreira e boldo...", "O orvalho faz bem às ervas."]},
				{"start_min": 510.0, "node": "botica_front", "activity": "Preparando chás", "indoors": false, "chatter": ["Chá fresquinho na Botica!", "Remédio da mata."]},
				{"start_min": 740.0, "node": "praca_s", "activity": "Visitando a Praça", "indoors": false, "shelter_in_rain": true, "chatter": ["Como vão todos na vila?"]},
				{"start_min": 880.0, "node": "botica_front", "activity": "Atendendo na Botica", "indoors": false, "chatter": ["Uma xícara revigora a alma!"]},
				{"start_min": 1050.0, "node": "sinha_front", "activity": "Conversando com D. Sinhá", "indoors": false, "shelter_in_rain": true, "chatter": ["Que tarde serena, Sinhá!"]},
				{"start_min": 1170.0, "node": "botica_front", "activity": "Dormindo", "indoors": true, "chatter": []},
			],
			"dialogues": {
				"morning": [
					"Deus te abençoe, meu filho! Colhi erva-cidreira fresca nesta manhã.",
					"Sempre que precisar de energia, venha tomar um chá na minha Botica!",
				],
				"afternoon": [
					"O segredo da saúde na roça é água limpa, boa comida e descanso.",
				],
				"evening": [
					"O sereno já está caindo. Não trabalhe até tarde demais na lavoura!",
				],
				"rainy": [
					"Dia de chuva pede um chá bem quentinho de gengibre e mel.",
				],
				"friend": [
					"Você tem um coração de ouro! Minha Botica está sempre aberta pra você.",
				],
			},
		},
		{
			"id": "antonio",
			"name": "Padre Antônio",
			"role": "Pároco",
			"home_node": "paroquial_front",
			"home_door_pos": Vector2(10.5 * ts, 29.0 * ts),
			"sprite": "res://assets/sprites/colonial_buildings_px/villager_antonio.png",
			"speed": 27.0,
			"schedule": [
				{"start_min": 360.0, "node": "paroquial_front", "activity": "Oração matinal", "indoors": false, "chatter": ["Paz e bem neste novo dia!"]},
				{"start_min": 420.0, "node": "capela", "activity": "Cuidando da Capela", "indoors": false, "chatter": ["A Capela abençoa a colheita!", "Sino da paz."]},
				{"start_min": 700.0, "node": "praca_s", "activity": "Saudando a Vila", "indoors": false, "shelter_in_rain": true, "chatter": ["Que alegria ver a vila unida!"]},
				{"start_min": 880.0, "node": "estrada_sul", "activity": "Caminhada no Vale", "indoors": false, "shelter_in_rain": true, "chatter": ["Bela criação divina este vale."]},
				{"start_min": 1020.0, "node": "capela", "activity": "Reza do Angelus", "indoors": false, "chatter": ["Hora do Angelus..."]},
				{"start_min": 1160.0, "node": "paroquial_front", "activity": "Descansando", "indoors": true, "chatter": []},
			],
			"dialogues": {
				"morning": [
					"Paz e bem! Passo toda manhã pela Capela da sua fazenda.",
					"Lembre-se de receber a Bênção da Capela para melhorar a qualidade da colheita!",
				],
				"afternoon": [
					"Gosto de caminhar da Casa Paroquial no Vale até a Praça da Vila.",
				],
				"evening": [
					"O tocar do sino ao entardecer acalma o coração de toda a freguesia.",
				],
				"rainy": [
					"A chuva é bênção dos céus para os nossos campos!",
				],
				"friend": [
					"Sua fazenda trouxe prosperidade e esperança para todo o arraial!",
				],
			},
		},
		{
			"id": "tiao",
			"name": "Pescador Tião",
			"role": "Pescador",
			"home_node": "pescador_front",
			"home_door_pos": Vector2(44.5 * ts, 20.0 * ts),
			"sprite": "res://assets/sprites/colonial_buildings_px/villager_tiao.png",
			"speed": 31.0,
			"schedule": [
				{"start_min": 360.0, "node": "ponte_east", "activity": "Pescando no Ribeirão", "indoors": false, "chatter": ["Hoje a tilápia tá mordendo!", "Olha a carpa dourada!"]},
				{"start_min": 660.0, "node": "venda_front", "activity": "Entregando peixe fresco", "indoors": false, "chatter": ["Peixe fresquinho pro Seu Manoel!"]},
				{"start_min": 780.0, "node": "pescador_front", "activity": "Consertando redes", "indoors": false, "chatter": ["Remendando a tarrafa..."]},
				{"start_min": 930.0, "node": "ponte_west", "activity": "Pescando na Ponte", "indoors": false, "chatter": ["Rio manso, pescaria boa!"]},
				{"start_min": 1100.0, "node": "estalagem_front", "activity": "Contando causos", "indoors": false, "chatter": ["Peguei um peixe deste tamanho!"]},
				{"start_min": 1220.0, "node": "pescador_front", "activity": "Dormindo", "indoors": true, "chatter": []},
			],
			"dialogues": {
				"morning": [
					"Ôpa! O Ribeirão lá embaixo na ponte tá cheio de peixe hoje!",
					"Se você tiver a Vara de Pesca (tecla 3), experimente pescar no lago ou no rio!",
				],
				"afternoon": [
					"Nada como o barulho da água correndo embaixo da ponte de madeira.",
				],
				"evening": [
					"Na Estalagem ninguém acredita no tamanho da Carpa Dourada que eu vi!",
				],
				"rainy": [
					"Peixe adora água mexida pela chuva! Melhor hora pra pescar!",
				],
				"friend": [
					"Parceiro de pescaria! Se precisar de dica do rio, é só chamar o Tião!",
				],
			},
		},
		{
			"id": "sinha",
			"name": "Dona Sinhá",
			"role": "Tecelã e Doceira",
			"home_node": "sinha_front",
			"home_door_pos": Vector2(52.5 * ts, 20.0 * ts),
			"sprite": "res://assets/sprites/colonial_buildings_px/villager_sinha.png",
			"speed": 28.0,
			"schedule": [
				{"start_min": 390.0, "node": "sinha_front", "activity": "Regando as flores", "indoors": false, "chatter": ["Bom dia, florzinhas!"]},
				{"start_min": 540.0, "node": "venda_front", "activity": "Comprando açúcar", "indoors": false, "chatter": ["Preciso de açúcar pro doce de leite!"]},
				{"start_min": 720.0, "node": "praca_s", "activity": "Fazendo renda no Coreto", "indoors": false, "shelter_in_rain": true, "chatter": ["Ponto por ponto na renda...", "Que brisa boa!"]},
				{"start_min": 870.0, "node": "sinha_front", "activity": "Fiando algodão", "indoors": false, "chatter": ["Algodão e lã de primeira!"]},
				{"start_min": 1050.0, "node": "praca_se", "activity": "Passeio ao entardecer", "indoors": false, "shelter_in_rain": true, "chatter": ["Que pôr do sol lindo!"]},
				{"start_min": 1180.0, "node": "sinha_front", "activity": "Dormindo", "indoors": true, "chatter": []},
			],
			"dialogues": {
				"morning": [
					"Bom dia, querido! O cheiro de doce caseiro já tá tomando conta da rua.",
				],
				"afternoon": [
					"Adoro tecer com o algodão e a lã que vêm da sua fazenda!",
					"Quando ficarmos mais amigos, sempre guardo um docinho pra você!",
				],
				"evening": [
					"A vila iluminada pelos lampiões à noite parece uma pintura!",
				],
				"rainy": [
					"Dia chuvoso é ótimo pra fazer renda e assar bolinho de chuva!",
				],
				"friend": [
					"Que alegria ver você por aqui! Trouxe um docinho caseiro pra você!",
				],
			},
		},
		{
			"id": "ze",
			"name": "Zé do Cravo",
			"role": "Estalajadeiro",
			"home_node": "estalagem_front",
			"home_door_pos": Vector2(60.5 * ts, 20.0 * ts),
			"sprite": "res://assets/sprites/colonial_buildings_px/villager_ze.png",
			"speed": 31.0,
			"schedule": [
				{"start_min": 420.0, "node": "estalagem_front", "activity": "Arrumando a Estalagem", "indoors": false, "chatter": ["Varrendo a varanda!", "Barris no lugar!"]},
				{"start_min": 600.0, "node": "venda_front", "activity": "Buscando suprimentos", "indoors": false, "chatter": ["Seu Manoel, separa duas sacas!"]},
				{"start_min": 750.0, "node": "estalagem_front", "activity": "Recebendo viajantes", "indoors": false, "chatter": ["Sejam bem-vindos à Estalagem!"]},
				{"start_min": 960.0, "node": "praca_s", "activity": "Tocando viola no Coreto", "indoors": false, "shelter_in_rain": true, "chatter": ["♪ Moda de viola na praça ♪", "♪ Ô sertão colonial ♪"]},
				{"start_min": 1080.0, "node": "estalagem_front", "activity": "Seresta na Estalagem", "indoors": false, "chatter": ["♪ Noite alegre na vila! ♪"]},
				{"start_min": 1260.0, "node": "estalagem_front", "activity": "Fechando a Estalagem", "indoors": true, "chatter": []},
			],
			"dialogues": {
				"morning": [
					"E aí, patrão! A Estalagem acolhe tropeiros e viajantes da Estrada Real.",
				],
				"afternoon": [
					"Mais tarde vou pro Coreto puxar uma moda de viola pra animar a vila!",
				],
				"evening": [
					"♪ Senta aí, compadre! A noite na Vila de São Sebastião é sempre festiva! ♪",
				],
				"rainy": [
					"Chuva lá fora, viola afinada e lampião aceso aqui na Estalagem!",
				],
				"friend": [
					"Fiz até uma moda de viola em homenagem à sua Fazenda Colonial!",
				],
			},
		},
		{
			"id": "chico",
			"name": "Chico Roceiro",
			"role": "Lenheiro do Vale",
			"home_node": "chico_front",
			"home_door_pos": Vector2(24.5 * ts, 29.0 * ts),
			"sprite": "res://assets/sprites/colonial_buildings_px/villager_chico.png",
			"speed": 32.0,
			"schedule": [
				{"start_min": 360.0, "node": "chico_front", "activity": "Cortando lenha", "indoors": false, "chatter": ["Lenha seca pro fogão!", "Dia bonito no Vale!"]},
				{"start_min": 570.0, "node": "farm_cross", "activity": "Visitando a Fazenda", "indoors": false, "chatter": ["Bela lavoura, vizinho!", "O engenho tá bonito!"]},
				{"start_min": 760.0, "node": "chico_front", "activity": "Almoço no Vale", "indoors": false, "chatter": ["Feijão com farinha no capricho!"]},
				{"start_min": 920.0, "node": "venda_front", "activity": "Compras na Vila", "indoors": false, "chatter": ["Vim comprar mantimentos na vila."]},
				{"start_min": 1080.0, "node": "ponte_west", "activity": "Voltando pela Ponte", "indoors": false, "chatter": ["Voltando pro Vale antes de escurecer."]},
				{"start_min": 1190.0, "node": "chico_front", "activity": "Dormindo", "indoors": true, "chatter": []},
			],
			"dialogues": {
				"morning": [
					"Bão dia, vizinho! Moro aqui no Vale do Ribeirão, pertinho da sua porteira!",
				],
				"afternoon": [
					"Sempre dou uma passada pela sua fazenda pra admirar a plantação.",
					"A ponte nova sobre o Ribeirão deixou o caminho até a Vila rapidinho!",
				],
				"evening": [
					"Já recolhi a lenha do dia. Bom descanso pra nós!",
				],
				"rainy": [
					"Terra molhada tem cheiro de fartura, né vizinho?",
				],
				"friend": [
					"Ter você como vizinho no Vale é a melhor coisa que aconteceu por aqui!",
				],
			},
		},
	]


const SEASONAL_FESTIVALS: Dictionary = {
	"spring": {
		"id": "festa_flores",
		"day": 14,
		"name": "Festa das Flores",
		"bonfire": false,
		"banner_colors": [Color("#ff80ab"), Color("#ffe082"), Color("#80cbc4"), Color("#ce93d8")],
		"chatter": ["Viva a Festa das Flores!", "A Praça tá perfumada!", "Que primavera linda!"],
	},
	"summer": {
		"id": "festa_cana",
		"day": 14,
		"name": "Festa da Colheita da Cana",
		"bonfire": false,
		"banner_colors": [Color("#ffd54f"), Color("#ff8a65"), Color("#81c784"), Color("#fff176")],
		"chatter": ["Viva a colheita farta!", "Caldo de cana pra toda vila!", "Saudemos o verão!"],
	},
	"autumn": {
		"id": "feira_engenho",
		"day": 14,
		"name": "Feira do Engenho",
		"bonfire": false,
		"banner_colors": [Color("#ffb74d"), Color("#d84315"), Color("#fdd835"), Color("#8d6e63")],
		"chatter": ["Melhor Feira do Engenho!", "Produtos artesanais de ouro!", "Bela festa no Coreto!"],
	},
	"winter": {
		"id": "festa_junina",
		"day": 14,
		"name": "Festa Junina do Arraial",
		"bonfire": true,
		"banner_colors": [Color("#ef5350"), Color("#ffee58"), Color("#42a5f5"), Color("#66bb6a")],
		"chatter": ["Viva São João! ♪", "Olha a fogueira no Coreto!", "Pamonha, milho e moda de viola!"],
	},
}

const FAVORITE_GIFTS: Dictionary = {
	"manoel": ["bread", "cheese", "saca_cafe", "wheat"],
	"bento": ["turnip", "saca_cafe", "cheese", "farinha_mandioca"],
	"quiteria": ["strawberry", "honey", "rolo_fumo", "turnip"],
	"antonio": ["turnip", "saca_cafe", "bread", "honey"],
	"tiao": ["tilapia", "trout", "shrimp", "golden_carp"],
	"sinha": ["pumpkin", "wool", "milk", "egg"],
	"ze": ["honey", "wheat", "cheese", "corn"],
	"chico": ["corn", "tomato", "carrot", "farinha_mandioca"],
}

const FESTIVAL_SPOTS: Dictionary = {
	"manoel": "praca_nw",
	"bento": "praca_w",
	"quiteria": "praca_ne",
	"antonio": "praca_s",
	"tiao": "praca_sw",
	"sinha": "praca_se",
	"ze": "praca_s",
	"chico": "praca_e",
}


static func get_active_festival(season_id: String, day_of_season: int) -> Dictionary:
	if SEASONAL_FESTIVALS.has(season_id):
		var fest: Dictionary = SEASONAL_FESTIVALS[season_id]
		if int(fest.get("day", -1)) == day_of_season:
			return fest
	return {}


static func get_favorite_gifts(npc_id: String) -> Array[String]:
	var out: Array[String] = []
	if FAVORITE_GIFTS.has(npc_id):
		for item in (FAVORITE_GIFTS[npc_id] as Array):
			out.append(str(item))
	return out

