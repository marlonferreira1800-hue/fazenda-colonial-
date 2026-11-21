class_name VersionData
extends RefCounted
## Metadados de versão, autoria, links do repositório e histórico de atualizações da Fazendinha 2D.

const CURRENT_VERSION := "v1.6.2"
const REPO_URL := "https://github.com/marlonferreira1800-hue/Fazenda-asclepio-"
const RELEASES_URL := "https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/releases"
const ISSUES_URL := "https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/issues?q=is%3Aissue"
const CHANGELOG_URL := "https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/blob/main/CHANGELOG.md"
const AUTHOR := "@marlonferreira1800-hue (Marlon Ferreira)"

const HISTORY: Array[Dictionary] = [
	{
		"version": "v1.6.2",
		"title": "Exportação Web Godot 4.7.2, Cache-Busting Único & Troca Rápida no Badge da Estação",
		"date": "2026-11-20",
		"author": "@marlonferreira1800-hue",
		"tag_url": "https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/releases/tag/v1.6.2",
		"before": "O navegador reutilizava index.pck?v=v1.6.1 em cache com scripts não compilados (.gd sem .gdc), mantendo a tela cinza no GitHub Pages.",
		"after": "Exportação oficial Godot 4.7.2 no CI com bytecode .gdc, cache-busting único por deploy e clique no badge da estação na HUD para avançar de estação.",
		"highlights": [
			"Antes -> Depois: Cache do navegador retinha index.pck antigo (?v=v1.6.1) -> Cache-busting único e exportação oficial Godot 4.7.2 (.gdc) no GitHub Pages",
			"Clique no badge da estação (Primavera · Ano 1) na HUD avança diretamente para a próxima estação para testar/explorar todas as 4 estações",
			"Proteção de posição inicial ao restaurar saves antigos para garantir spawn válido em frente à casa (136, 118)",
		],
	},
	{
		"version": "v1.6.1",
		"title": "Hotfix: Renderização do Mapa Sazonal e Badge das 4 Estações na HUD",
		"date": "2026-11-20",
		"author": "@marlonferreira1800-hue",
		"tag_url": "https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/releases/tag/v1.6.1",
		"before": "Conflito de merge em farm_world.gd impedia o carregamento do mapa no navegador (fundo cinza apenas com o jogador e HUD sem o badge da estação).",
		"after": "Mapa completo 40x24 renderizando com paletas sazonais, partículas climáticas, interior da casa e badge Primavera · Ano 1 na HUD.",
		"highlights": [
			"Antes -> Depois: Mapa não carregava por marcador de merge em farm_world.gd -> Mapa sazonal, props, animais, interior da casa e badge da estação funcionando no Web",
			"Restaurados preloads de SeasonDataScript/CropDataScript em farm_world.gd e badge SeasonBadge no painel superior da HUD",
		],
	},
	{
		"version": "v1.6.0",
		"title": "Sistema das 4 Estações do Ano, Nabo de Inverno, Paletas & Partículas Sazonais",
		"date": "2026-11-20",
		"author": "@marlonferreira1800-hue",
		"tag_url": "https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/releases/tag/v1.6.0",
		"before": "Calendário sem estações do ano (apenas Dia 1, 2, 3...), visual fixo de primavera/verão, sem cultivo de inverno e sem bônus sazonal na loja ou colheitas.",
		"after": "Ciclo completo das 4 Estações (Primavera, Verão, Outono e Inverno com 28 dias cada), paletas e partículas sazonais, Nabo de Inverno (tecla =), Modo Cozy (+35% e -1 dia na estação ideal) e +20% em animais/artesanais no Inverno.",
		"highlights": [
			"Antes -> Depois: Fazenda sem estações do ano -> Ciclo anual de 4 Estações (28 dias cada / 112 por ano) com paletas, partículas e bônus sazonais",
			"Primavera (Trigo/Morango), Verão (Milho/Tomate), Outono (Cenoura/Abóbora) e Inverno (Nabo +35% e Animais/Artesanais +20%)",
			"11 novos spritesheets sazonais em assets/sprites/seasons/ (terreno, casinha/árvores nevadas, ícones e Nabo em 5 estágios)",
			"Badge da estação + Dia X/28 na HUD, banner animado com carrilhão procedural, 12º slot (=) na Hotbar e destaque dourado na Loja (B)",
		],
	},
	{
		"version": "v1.5.1",
		"title": "Corrigir cache do navegador no GitHub Pages (cache-busting do index.pck)",
		"date": "2026-11-20",
		"author": "@marlonferreira1800-hue",
		"tag_url": "https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/releases/tag/v1.5.1",
		"before": "O navegador reutilizava index.js e index.pck antigos em cache do GitHub Pages, mantendo a versão anterior ao abrir a URL.",
		"after": "Adicionado cache-busting automático (?v=1.5.1) no carregamento de index.js e no fetch de index.pck/index.wasm para forçar o download imediato da versão nova.",
		"highlights": [
			"Antes -> Depois: O navegador reutilizava index.js e index.pck antigos em cache do GitHub Pages, mantendo a versão anterior ao abrir a URL. -> Adicionado cache-busting automático (?v=1.5.1) no carregamento de index.js e no fetch de index.pck/index.wasm para forçar o download imediato da versão nova.",
			"Issue #13: Cache-busting automático em build/web/index.html e build/web/index.js durante a exportação Web no auto_release_bot.py",
		],
	},
	{
		"version": "v1.5.0",
		"title": "Acesso ao interior da casa e móveis interativos CC0",
		"date": "2026-11-20",
		"author": "@marlonferreira1800-hue",
		"tag_url": "https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/releases/tag/v1.5.0",
		"before": "A casinha da fazenda funcionava apenas pelo lado de fora (sem cena interna, sem transição de porta e sem móveis interativos no interior).",
		"after": "Adicionado acesso completo ao interior da casa (18x12 tiles) via porta com fade, spritesheet CC0 house_interior.png (256x160) e 8 interações internas (cama, fogão com chá +20 energia, lareira animada, estante com guia, escrivaninha/diário para salvar, baú, mesa posta e capacho de saída).",
		"highlights": [
			"Antes -> Depois: A casinha da fazenda funcionava apenas pelo lado de fora (sem cena interna, sem transição de porta e sem móveis interativos no interior). -> Adicionado acesso completo ao interior da casa (18x12 tiles) via porta com fade, spritesheet CC0 house_interior.png (256x160) e 8 interações internas (cama, fogão com chá +20 energia, lareira animada, estante com guia, escrivaninha/diário para salvar, baú, mesa posta e capacho de saída).",
			"Issue #12: Cena scenes/house_interior.tscn e script scripts/world/house_interior.gd com lareira animada e iluminação quente;Spritesheet assets/sprites/house_interior.png (256x160 RGBA) com pacotes CC0 (Kenney Roguelike Indoor, Zelda-like indoor e 16x16 Food);Transição de entrada/saída na porta, persistência de localização no save e suporte ao modo Demo IA (P)",
		],
	},
	{
		"version": "v1.4.0",
		"title": "Pesca no Lago, Máquinas Artesanais, Rebrota, Fertilizante, Encomendas & Álbum",
		"date": "2026-11-20",
		"author": "@marlonferreira1800-hue",
		"tag_url": "https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/releases/tag/v1.4.0",
		"before": "Sem minigame de pesca, sem máquinas artesanais, sem rebrota ou qualidade Ouro, sem carinho em animais e sem pedidos diários ou álbum de coleções.",
		"after": "Pesca no lago (4 peixes), Queijeira/Forno/Apiário, rebrota (Morango/Milho/Tomate), Fertilizante Ouro (1.5x), carinho (♥ 0..5) + Ovo Azul, compra de animais e Diário (J) com Encomendas e Álbum.",
		"highlights": [
			"Antes -> Depois: Fazenda v1.3.0 sem pesca/máquinas/álbum -> Pesca, Máquinas Artesanais, Rebrota, Fertilizante Ouro, Encomendas e Álbum",
			"Minigame de pesca no lago (Tilápia, Camarão, Truta, Carpa Dourada) com suporte a teclado, mouse e touch",
			"Queijeira (Queijo), Forno de Pão (Pão) e Apiário (Mel) + compra de até 8 animais e carinho diário (♥ 0..5 + Ovo Azul)",
			"Rebrota em Morango/Milho/Tomate, Fertilizante para colheitas Ouro ★ (1.5x) e Diário (J) com Encomendas e Álbum",
		],
	},
	{
		"version": "v1.3.0",
		"title": "Novos Cultivos, Upgrades, Clima, Música, Animais & Mobile",
		"date": "2026-11-19",
		"author": "@marlonferreira1800-hue",
		"tag_url": "https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/releases/tag/v1.3.0",
		"before": "Apenas 3 cultivos, ferramentas sem evolução, clima estático, sem música de fundo, 2 tipos de animais e sem controles touch ou botão de reinício.",
		"after": "6 cultivos, upgrades de ferramentas/energia e Aspersor 3x3, chuva automática, música cozy procedural, Ovelha e Porco, Menu/Reiniciar, controles touch e Auto-Farmer 12 canteiros.",
		"highlights": [
			"Antes -> Depois: Fazenda básica manual -> 6 cultivos, upgrades 3x3, Aspersor, Chuva, BGM procedural, Ovelha/Porco e Touch",
			"Issue #7: Novos cultivos (Milho, Tomate, Abóbora) com spritesheets e ícones integrados",
			"Upgrades de Enxada, Regador e Resistência (Nv. 1-3) + Aspersor automático 3x3 na Loja com abas",
			"Sistema de Clima (Sol/Chuva com previsão e rega automática) + música procedural em loop",
			"Ovelha (Lã $60) e Porco (Trufa $80), D-Pad touch mobile, Menu/Reiniciar save e Auto-Farmer expandido",
		],
	},
	{
		"version": "v1.2.0",
		"title": "Modo Fazendeiro Automático, Painel de Atualizações & Deploy Web",
		"date": "2026-11-15",
		"author": "@marlonferreira1800-hue",
		"tag_url": "https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/releases/tag/v1.2.0",
		"before": "Controle 100% manual sem exibição de versão/histórico no jogo e sem deploy Web contínuo.",
		"after": "Modo Fazendeiro Automático (tecla P), Painel de Atualizações in-game (tecla V) com Antes vs. Depois e deploy automático no GitHub Pages.",
		"highlights": [
			"Antes -> Depois: Jogo apenas manual e sem histórico in-game -> Demo IA ao vivo (P), Painel de Versões (V) e GitHub Pages automático",
			"Issue #3: Modo Fazendeiro Automático (Auto / tecla P) com rota inteligente pelos portões",
			"Issue #4: Painel de Atualizações (tecla V) in-game com histórico de versões, autor e links para Releases/Issues",
			"Publicação automática no GitHub Pages via GitHub Actions",
		],
	},
	{
		"version": "v1.1.0",
		"title": "Correção de Contraste da HUD, Áudio Procedural, Save/Load & Animais",
		"date": "2026-11-15",
		"author": "@marlonferreira1800-hue",
		"tag_url": "https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/releases/tag/v1.1.0",
		"before": "Texto da HUD sem contorno escuro (baixo contraste), jogo mudo, sem salvamento e animais apenas decorativos.",
		"after": "HUD com contorno e barra escura legível, AudioManager SFX procedural, Save/Load JSON e coleta diária de Ovo/Leite.",
		"highlights": [
			"Antes -> Depois: HUD com baixo contraste, sem áudio/save e animais passivos -> Contraste corrigido, SFX procedural, Save/Load e Ovo/Leite",
			"Issue #1 (Bugfix): Contraste de leitura corrigido nas barras de Energia/Água, hotbar e barra inferior",
			"Issue #2: Efeitos sonoros procedurais (AudioManager), Save/Load (user://savegame.json) e coleta de Ovo ($30) e Leite ($45)",
			"Importador CLI tools/import_pack.py e expansão de ui_icons.png (128x16) com itens CC0",
		],
	},
	{
		"version": "v1.0.0",
		"title": "Lançamento Inicial — Protótipo Jogável Fazendinha 2D",
		"date": "2026-11-15",
		"author": "@marlonferreira1800-hue",
		"tag_url": "https://github.com/marlonferreira1800-hue/Fazenda-asclepio-/releases/tag/v1.0.0",
		"before": "Repositório inicial vazio sem cena jogável, lógica de fazenda ou spritesheets 16x16.",
		"after": "Protótipo jogável completo em Godot 4.7.2 com cultivos, loja, caixa de venda, ciclo dia/noite e spritesheets CC0.",
		"highlights": [
			"Antes -> Depois: Projeto do zero -> Fazendinha 2D jogável em Godot 4.7.2 (cultivos, loja, ciclo dia/noite e sprites 16x16)",
			"Mapa 40x24 em TileMapLayer (Godot 4.7.2) com ciclo dia/noite, poço, lago e casinha",
			"Cultivos de Trigo, Cenoura e Morango em 5 estágios com loja e caixa de venda",
			"Spritesheets 16x16 pixel art cozy e catálogo ASSETS_GRATUITOS.md",
		],
	},
]


static func get_current_version() -> String:
	return CURRENT_VERSION


static func get_history() -> Array[Dictionary]:
	return HISTORY
