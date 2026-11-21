# Guia de Jogo 2D: Fazenda & Engenho Colonial (Brasil Colônia)

Adaptação dos dados do Período Colonial para um jogo 2D estilo **fazenda / simulação rural** (visão top-down, similar a *Stardew Valley* / *Harvest Moon*) no Godot.

---

## 1. Zonas do Mapa da Fazenda (Layout 2D)

1. **Sede (Casa-Grande / Casarão Rural):** Ponto inicial, descanso (passa o dia e salva), livro-caixa (finanças em Réis e metas).
2. **Área de Lavoura (Terra Roxa / Massapê):** Lotes aráveis próximos ao rio para cana-de-açúcar, mandioca, milho, feijão, tabaco e algodão.
3. **Área Produtiva (Engenhoca & Casa de Farinha):** Estações de beneficiamento (moenda movida a água ou boi, caldeiras, forno de farinha).
4. **Curral e Pasto:** Cercados de madeira rústica para bois, vacas, cavalos, mulas, porcos e galinhas.
5. **Mata Atlântica e Rio:** Fonte de água (irrigação e roda d'água), coleta de madeira, ervas/frutas nativas e risco de fauna silvestre (onça à noite).
6. **Porteira / Estrada Real (ou Embarcadouro):** Ponto de chegada do **Tropeiro** ou **Carro de Boi** para escoar caixas de açúcar e comprar insumos/ferramentas.

---

## 2. Culturas Agrícolas (Lavoura)

| Cultura | Dias p/ Colher | Rega | Produto Bruto | Beneficiamento (Agregação de Valor) |
| :--- | :---: | :---: | :--- | :--- |
| **Cana-de-Açúcar** | 8 dias (rebrota) | Alta | Feixe de Cana | Moenda + Caldeira → **Açúcar Mascavo / Rapadura / Aguardente** |
| **Mandioca** | 5 dias | Baixa | Raiz de Mandioca | Casa de Farinha → **Farinha de Mandioca** (alimento/venda) |
| **Milho** | 4 dias | Média | Espiga de Milho | Ração animal ou **Fubá** |
| **Feijão** | 4 dias | Média | Grãos de Feijão | Alimento básico e venda local |
| **Tabaco (Fumo)** | 6 dias | Média | Folha de Tabaco | Secagem → **Rolo de Fumo** (alto valor de troca) |
| **Algodão** | 7 dias | Média | Capulho de Algodão | Descaroçamento → **Fardo de Algodão / Tecido rústico** |
| **Café** *(fase tardia)* | 10 dias (arbusto) | Média | Grão de Café | Terreiro + Torra → **Saca de Café** |

---

## 3. Pecuária e Animais da Fazenda

- **Boi:** Tração para a **moenda** e **carro de boi**; fornece couro e carne.
- **Vaca:** Produz **leite** diário (processado em **queijo**).
- **Mula / Cavalo:** Aumenta velocidade de deslocamento e capacidade de carga até a vila.
- **Porco:** Fonte de carne e banha; alimenta-se de restos/milho.
- **Galinha:** Produção diária de **ovos** (baixo custo inicial).
- **Ameaça Silvestre (Opcional):** *Onça-pintada* pode rondar o curral à noite se não houver cercas reforçadas ou tochas.

---

## 4. Construções e Estações de Trabalho

- **Poço / Roda d'Água:** Recarrega regador e automatiza a moenda de cana.
- **Moenda & Caldeira:** Converte *Cana-de-Açúcar* em *Açúcar* ou *Rapadura*.
- **Casa de Farinha:** Prensa e forno para transformar *Mandioca* em *Farinha*.
- **Secador de Fumo:** Galpão coberto para curar folhas de *Tabaco*.
- **Paiol / Armazém:** Aumenta limite de estoque e protege colheita de chuva/pragas.
- **Oficina de Carpintaria / Ferraria:** Repara e melhora ferramentas (ferro → aço).

---

## 5. Ferramentas do Jogador

- **Enxada:** Prepara o solo (terra arável).
- **Regador / Balde de Madeira:** Irriga as plantações.
- **Foice / Facão:** Colheita de cana, milho, mato alto e defesa leve.
- **Machado:** Corte de árvores (madeira de construção e lenha para as caldeiras).
- **Picareta:** Limpeza de pedras do terreno.

---

## 6. Economia, Comércio e Loop Diário

1. **Manhã:** Regar/colher lavouras, alimentar animais, colocar lenha na caldeira/forno.
2. **Tarde:** Processar colheita (moenda/casa de farinha), cortar madeira, explorar mata/rio ou ir à vila vizinha.
3. **Comércio (Réis / Patacas):**
   - **Tropeiro Itinerante:** Passa a cada poucos dias na porteira comprando sacas/caixas e vendendo sementes raras.
   - **Vila Colonial:** Mercado fixo, ferreiro, igreja (calendário de festas) e coletor de impostos da Coroa (ex.: pagamento periódico de dízimo).

---

## 7. Integração no Godot 4

Use [fazenda_colonial_data.json](file:///c:/Users/marlo/Downloads/FABRI/fazenda_colonial_data.json) para popular culturas, receitas, animais, construções e ferramentas dinamicamente em `GDScript`.
