# Dossiê Histórico: Período Colonial do Brasil (1500–1822) para Jogo 2D (Godot)

Guia de referência histórica e design de dados estruturado para desenvolvimento 2D no Godot Engine (tilesets, biomas, facções, economia, itens, armas, construções e missões).

---

## 1. Eras e Ciclos Econômicos (Progressão / Capítulos)

| Período | Ciclo / Fase | Foco Econômico | Mecânicas Sugeridas |
| :--- | :--- | :--- | :--- |
| **1500–1530** | Pré-Colonial | Extração de Pau-Brasil, escambo | Exploração costeira, coleta, troca com povos originários |
| **1530–1700** | Ciclo da Cana-de-Açúcar | Engenhos, latifúndio, comércio atlântico | Construção/gestão de engenho, defesa contra invasões (holandeses/corsários) |
| **Sécs. XVII–XVIII** | Expansão e Resistência | Bandeiras (interiorização), Quilombos, Pecuária | Exploração de sertão, sobrevivência, diplomacia/conflito |
| **1700–1808** | Ciclo do Ouro e Diamantes | Mineração (MG, GO, MT), impostos (Quinto/Derrama) | Mineração, contrabando vs. fiscalização da Coroa, urbanização barroca |
| **1808–1822** | Período Joanino e Independência | Abertura dos Portos, Reino Unido (1815), Independência | Política, comércio internacional, revoltas e emancipação |

---

## 2. Biomas e Cenários (Tilesets & Mapas 2D)

- **Litoral e Mata Atlântica:** Praias, manguezais, árvores de pau-brasil (tronco escuro, cerne vermelho), feitorias costeiras, portos e caravelas ancoradas.
- **Vila / Cidade Histórica (Salvador, Olinda, Ouro Preto, Paraty):** Ruas estreitas de pedra irregular (pé-de-moleque), sem calçadas, com canaleta central de escoamento; casas geminadas sem recuo frontal; sobrados de 2+ andares; igrejas barrocas/rococós.
- **Engenho de Açúcar:** Terreno dividido por hierarquia espacial — **Casa-Grande** no ponto mais alto, **Capela** próxima, **Fábrica/Engenhoca** (moenda, caldeiras, casa de purgar) e **Senzala** (galpões fechados e rústicos).
- **Quilombo (ex.: Palmares / Serra da Barriga):** Serras com mata densa, vales profundos, paliçadas defensivas ocultas, casas de pau a pique com telhado de palha e roças de subsistência (mandioca, milho, feijão).
- **Sertão e Estradas Reais:** Vegetação seca/cerrado, rios navegáveis por canoas, trilhas de terra batida para tropeiros e carros de boi.
- **Fortificações Costeiras e Fluviais:** Fortes em sistema de **traça italiana** (formato estrelado/poligonal, muralhas baixas, espessas e inclinadas) com canhões apontados para o mar/rio.

---

## 3. Arquitetura e Props para Tileset 2D

- **Técnicas Construtivas:**
  - *Taipa de pilão* (paredes grossas de terra batida, tons ocre/bege).
  - *Pau a pique* (tramado de madeira/bambu com barro).
  - *Alvenaria de pedra e cal* (construções oficiais, fortes e igrejas).
- **Telhados:** Telhas cerâmicas curvas (*capa-canal*) em duas ou quatro águas, com beirais salientes e cachorros de madeira.
- **Detalhes Visuais:** Caiação branca nas fachadas, esquadrias e portas de madeira em cores vivas (azul, verde, ocre), azulejos portugueses, lamparinas a óleo, pelourinho em praças centrais, chafarizes públicos.

---

## 4. Facções, Classes e NPCs

| Grupo / Profissão | Papel no Mundo | Vestimenta / Visual 2D |
| :--- | :--- | :--- |
| **Autoridades da Coroa** | Governadores, juízes, fiscais do Quinto, capitães-mores | Casacas longas, coletes bordados, calções, sapatos com fivela, perucas (séc. XVIII) |
| **Senhores de Engenho / Elite** | Donos de terras e minas | Veludos, sedas, rendas, gibões (séc. XVI–XVII) ou trajes rococós com leques/chapéus (séc. XVIII) |
| **Soldados e Milícias** | Defesa de fortes, escolta de ouro, repressão a revoltas | Uniformes coloniais, chapéus tricórnios/capacetes, bandoleiras |
| **Bandeirantes e Tropeiros** | Desbravadores do sertão e transportadores de carga | Chapéus de aba larga, gibões de couro (proteção contra flechas/mato), botas altas |
| **Jesuítas e Clero** | Catequização, missões, educação | Batinas pretas ou hábitos religiosos |
| **Escravizados e Libertos** | Base produtiva (engenho, minas, ganho urbano) | Algodão grosso (*baeta*), pés descalços; ganhadeiras urbanas com panos de cabeça e colares de contas |
| **Quilombolas** | Resistência organizada em quilombos | Roupas rústicas adaptadas à mata, armamento improvisado e agrícola |
| **Povos Indígenas** | Aliados de escambo, guerreiros ou aldeados | Pinturas corporais, cocares/adornos de penas, arcos e bordunas |
| **Artesãos e Comerciantes** | Ferreiros, carpinteiros, pedreiros, sapateiros, alfaiates | Aventais de couro/pano, camisas de linho/algodão simples |
| **Invasores / Corsários** | Holandeses (NE, 1630–1654), franceses e piratas | Uniformes navais europeus, casacos de corsário |

---

## 5. Economia, Recursos e Itens

- **Moeda Oficial:** **Réis** (e moedas cunhadas como **Patacas** de prata e peças de ouro). No início do jogo/período pré-colonial, usar sistema de **escambo** (troca direta de mercadorias).
- **Recursos Coletáveis / Comércio:**
  - *Pau-Brasil* (madeira tintureira vermelha)
  - *Cana-de-açúcar* e *Açúcar mascavo/branco*
  - *Ouro em pó / Pepitas / Barras quintadas* e *Diamantes*
  - *Drogas do Sertão* (especiarias amazônicas, guaraná, castanhas, ervas medicinais)
  - *Tabaco*, *Algodão* e *Couro*
  - *Alimentos de subsistência:* Mandioca, milho, feijão, peixe, carne seca.

---

## 6. Armas e Combate

- **Armas de Fogo (Recarga lenta — ótima mecânica tática 2D):**
  - *Arcabuz* e *Mosquete* (antecarga, ignição por mecha ou pederneira).
  - *Pistola de pederneira* (curto alcance, uso por oficiais/bandeirantes).
- **Armas Brancas:**
  - *Espada / Florete / Sabre* (oficiais e tropa regular).
  - *Facão / Adaga / Punhal* (uso cotidiano e corpo a corpo).
  - *Lança / Pique* (formação de infantaria).
- **Armas Indígenas:**
  - *Arco e flecha*, *Zarabatanas*, *Borduna* (clava de madeira pesada).
- **Artilharia:**
  - *Canhões de ferro fundido ou bronze* (em fortes e navios).

---

## 7. Transportes e Navegação

- **Marítimo/Fluvial:** *Caravelas e Naus* (viagens atlânticas/cutscenes/portos), *Jangadas* (litoral e pesca), *Canoas de tronco cavado* (rios e interior).
- **Terrestre:** *Carro de Boi* (carga pesada lenta em estradas de terra), *Tropas de Mulas* (transporte de ouro e mantimentos pelo sertão), *Cavalos* e *Liteiras*.

---

## 8. Fauna e Flora (Ambientação e Perigos)

- **Flora:** Pau-brasil, cana-de-açúcar, mandioca, árvores frutíferas nativas, mata atlântica fechada, vegetação de cerrado/caatinga.
- **Fauna Nativa (Ambiental / Inimigos Naturais):** Onça-pintada, araras, macacos, capivaras, cobras.
- **Fauna Introduzida:** Bois, cavalos, mulas, porcos.

---

## 9. Eventos Históricos (Missões Principais / Linha do Tempo)

1. **1500:** Chegada da esquadra de Pedro Álvares Cabral na Bahia.
2. **1532:** Fundação da Vila de São Vicente (Martim Afonso de Sousa) e Capitanias Hereditárias.
3. **1549:** Criação do Governo-Geral em Salvador.
4. **1630–1654:** Invasões Holandesas no Nordeste e Insurreição Pernambucana.
5. **1695:** Resistência e queda de Zumbi dos Palmares.
6. **Sécs. XVII–XVIII:** Expedições das Bandeiras rumo ao interior.
7. **1789:** Inconfidência Mineira (Tiradentes, movimento elitista/iluminista).
8. **1798:** Conjuração Baiana / Revolta dos Alfaiates (movimento popular).
9. **1808:** Chegada da Família Real e Abertura dos Portos.
10. **1822 (7 de setembro):** Proclamação da Independência por D. Pedro I.

---

## 10. Uso no Godot 4

O arquivo complementar [colonial_database.json](file:///c:/Users/marlo/Downloads/FABRI/colonial_database.json) já está estruturado para carregamento direto via `GDScript`:

```gdscript
var file := FileAccess.open("res://colonial_database.json", FileAccess.READ)
var data: Dictionary = JSON.parse_string(file.get_as_text())
```
