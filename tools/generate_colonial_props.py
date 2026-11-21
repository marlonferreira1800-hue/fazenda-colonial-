"""Gera sprites pixel-art coloniais brasileiros em assets/sprites/colonial_buildings_px/
para enriquecer o cenário da fazenda no Godot 4.

Sprites gerados:
- chafariz_colonial.png (40x36): Chafariz de pedra-sabão com 2 carrancas/bicas, tanque abaulado e cruz/pináculos.
- capela_colonial.png (44x48): Capela caiada de branco com telha capa-canal, porta azul colonial e sino.
- carro_de_boi.png (40x24): Carro de boi de madeira com rodas raiadas e carga de sacos/cana.
- lampiao_colonial.png (12x24): Poste de ferro forjado com lampião a óleo.
- palmeira_imperial.png (24x44): Palmeira imperial típica de entradas de fazendas coloniais.
"""

from pathlib import Path
from PIL import Image, ImageDraw

OUT_DIR = Path("assets/sprites/colonial_buildings_px")
OUT_DIR.mkdir(parents=True, exist_ok=True)


def px(img: Image.Image, x: int, y: int, color: tuple[int, int, int, int]) -> None:
    if 0 <= x < img.width and 0 <= y < img.height:
        img.putpixel((x, y), color)


def rect(img: Image.Image, x0: int, y0: int, x1: int, y1: int, color: tuple[int, int, int, int]) -> None:
    d = ImageDraw.Draw(img)
    d.rectangle([x0, y0, x1, y1], fill=color)


def generate_chafariz() -> None:
    img = Image.new("RGBA", (40, 36), (0, 0, 0, 0))
    outline = (36, 32, 34, 255)
    stone_dark = (102, 106, 114, 255)
    stone_mid = (142, 146, 154, 255)
    stone_light = (178, 182, 188, 255)
    soapstone = (124, 134, 128, 255)
    water_dark = (42, 108, 168, 255)
    water_mid = (72, 152, 214, 255)
    water_foam = (196, 236, 255, 255)
    bronze = (164, 118, 54, 255)
    gold = (212, 174, 78, 255)

    # Sombra no chão
    rect(img, 3, 31, 36, 34, (20, 24, 20, 95))

    # Frontão barroco + cruz no topo
    rect(img, 19, 1, 20, 6, stone_dark)
    rect(img, 17, 2, 22, 3, stone_mid)
    px(img, 19, 0, gold)
    px(img, 20, 0, gold)

    # Pináculos laterais
    rect(img, 8, 5, 10, 9, stone_dark)
    px(img, 9, 4, stone_light)
    rect(img, 29, 5, 31, 9, stone_dark)
    px(img, 30, 4, stone_light)

    # Parede principal do chafariz (pedra-sabão e quartzito)
    rect(img, 7, 7, 32, 24, outline)
    rect(img, 8, 8, 31, 23, stone_mid)
    rect(img, 9, 8, 30, 10, stone_light)  # cornija superior

    # Nicho central (oratório/brasão)
    rect(img, 17, 10, 22, 15, stone_dark)
    rect(img, 18, 11, 21, 14, soapstone)
    px(img, 19, 12, gold)
    px(img, 20, 12, gold)
    px(img, 19, 13, bronze)

    # Textura de blocos de pedra
    for bx in (10, 14, 25, 29):
        rect(img, bx, 12, bx + 1, 13, stone_dark)
        rect(img, bx, 17, bx + 1, 18, stone_light)

    # Duas carrancas / bicas de bronze jorrando água
    for bx in (13, 25):
        rect(img, bx, 16, bx + 2, 18, bronze)
        px(img, bx + 1, 17, gold)
        # Jato de água caindo
        rect(img, bx + 1, 19, bx + 1, 25, water_mid)
        px(img, bx + 1, 21, water_foam)
        px(img, bx + 1, 24, water_foam)

    # Tanque abaulado principal (frente)
    rect(img, 4, 22, 35, 32, outline)
    rect(img, 5, 23, 34, 31, stone_dark)
    rect(img, 6, 23, 33, 24, stone_light)  # borda superior do tanque
    rect(img, 6, 25, 33, 28, water_dark)   # água no tanque
    rect(img, 7, 25, 32, 26, water_mid)
    # Espuma onde os jatos caem
    rect(img, 13, 25, 15, 26, water_foam)
    rect(img, 25, 25, 27, 26, water_foam)
    # Parede frontal do tanque
    rect(img, 6, 29, 33, 31, stone_mid)
    for sx in range(8, 33, 5):
        px(img, sx, 30, stone_dark)

    img.save(OUT_DIR / "chafariz_colonial.png")


def generate_capela() -> None:
    img = Image.new("RGBA", (44, 48), (0, 0, 0, 0))
    outline = (42, 34, 30, 255)
    white_wall = (238, 232, 220, 255)
    wall_shade = (204, 196, 184, 255)
    roof_dark = (146, 62, 42, 255)
    roof_mid = (182, 84, 56, 255)
    roof_light = (212, 114, 78, 255)
    blue_wood = (54, 102, 148, 255)
    blue_dark = (36, 70, 106, 255)
    stone_base = (126, 124, 120, 255)
    gold = (224, 186, 76, 255)

    # Sombra
    rect(img, 4, 43, 39, 46, (20, 24, 20, 95))

    # Cruz no topo da sineira
    rect(img, 21, 1, 22, 7, gold)
    rect(img, 19, 3, 24, 4, gold)

    # Frontão triangular / sineira
    for row in range(8):
        w = 4 + row * 2
        x0 = 22 - w // 2
        rect(img, x0 - 1, 7 + row, x0 + w, 7 + row, outline)
        rect(img, x0, 7 + row, x0 + w - 1, 7 + row, white_wall)

    # Sino na sineira
    rect(img, 20, 10, 23, 13, (64, 52, 44, 255))
    rect(img, 21, 11, 22, 13, gold)

    # Telhado capa-canal (duas águas)
    for row in range(8):
        y = 15 + row
        x0 = 6 - row // 2
        x1 = 37 + row // 2
        rect(img, x0, y, x1, y, outline)
        c = roof_mid if row % 2 == 0 else roof_dark
        rect(img, x0 + 1, y, x1 - 1, y, c)
    # Cumeeira e brilho das telhas
    for tx in range(7, 37, 3):
        rect(img, tx, 16, tx + 1, 21, roof_light)

    # Corpo da Capela (parede caiada)
    rect(img, 5, 23, 38, 43, outline)
    rect(img, 6, 23, 37, 41, white_wall)
    rect(img, 6, 23, 8, 41, wall_shade)
    rect(img, 35, 23, 37, 41, wall_shade)
    # Cunhais / pilastras azul colonial
    rect(img, 6, 23, 7, 41, blue_wood)
    rect(img, 36, 23, 37, 41, blue_wood)

    # Base de pedra
    rect(img, 6, 40, 37, 43, stone_base)

    # Porta principal em arco azul colonial
    rect(img, 18, 29, 25, 42, outline)
    rect(img, 19, 30, 24, 42, blue_wood)
    rect(img, 21, 30, 22, 42, blue_dark)
    px(img, 23, 36, gold)

    # Janelas laterais (óculos/venezianas)
    for jx in (11, 30):
        rect(img, jx, 28, jx + 3, 33, outline)
        rect(img, jx + 1, 29, jx + 2, 32, blue_dark)

    # Degrau de pedra
    rect(img, 16, 43, 27, 44, (160, 158, 152, 255))

    img.save(OUT_DIR / "capela_colonial.png")


def generate_carro_de_boi() -> None:
    img = Image.new("RGBA", (40, 24), (0, 0, 0, 0))
    outline = (38, 28, 22, 255)
    wood_dark = (96, 62, 36, 255)
    wood_mid = (138, 92, 52, 255)
    wood_light = (176, 126, 76, 255)
    sack = (206, 188, 148, 255)
    sack_shade = (168, 148, 110, 255)
    iron = (78, 82, 90, 255)

    # Sombra
    rect(img, 5, 19, 35, 22, (20, 24, 20, 90))

    # Cabeçalho / timão do carro (apontando para a esquerda)
    rect(img, 1, 13, 12, 15, outline)
    rect(img, 2, 14, 11, 14, wood_mid)
    # Canga na ponta
    rect(img, 2, 11, 4, 17, outline)
    rect(img, 3, 12, 3, 16, wood_light)

    # Carga de sacos de açúcar/café
    rect(img, 14, 4, 24, 10, outline)
    rect(img, 15, 5, 23, 9, sack)
    rect(img, 23, 5, 32, 10, outline)
    rect(img, 24, 6, 31, 9, sack_shade)
    rect(img, 18, 2, 28, 7, outline)
    rect(img, 19, 3, 27, 6, sack)

    # Caçamba / mesa de madeira
    rect(img, 11, 8, 35, 16, outline)
    rect(img, 12, 9, 34, 15, wood_mid)
    rect(img, 12, 9, 34, 10, wood_light)
    for rx in range(14, 34, 4):
        rect(img, rx, 9, rx, 14, wood_dark)

    # Roda maciça colonial (aro de ferro + raios de madeira)
    d = ImageDraw.Draw(img)
    d.ellipse([17, 11, 29, 23], fill=wood_dark, outline=outline)
    d.ellipse([19, 13, 27, 21], fill=wood_mid, outline=iron)
    rect(img, 22, 14, 24, 20, wood_light)
    rect(img, 20, 16, 26, 18, wood_light)
    px(img, 23, 17, iron)

    img.save(OUT_DIR / "carro_de_boi.png")


def generate_lampiao() -> None:
    img = Image.new("RGBA", (12, 24), (0, 0, 0, 0))
    iron = (44, 48, 54, 255)
    iron_light = (76, 82, 92, 255)
    glass = (255, 224, 138, 255)
    flame = (255, 248, 210, 255)

    # Base e poste
    rect(img, 4, 20, 7, 22, iron)
    rect(img, 5, 8, 6, 20, iron)
    px(img, 5, 12, iron_light)
    px(img, 5, 16, iron_light)

    # Braço e lanterna
    rect(img, 4, 3, 7, 4, iron)
    px(img, 5, 2, iron_light)
    rect(img, 3, 4, 8, 8, iron)
    rect(img, 4, 5, 7, 7, glass)
    px(img, 5, 6, flame)
    px(img, 6, 6, flame)
    rect(img, 4, 8, 7, 9, iron)

    img.save(OUT_DIR / "lampiao_colonial.png")


def generate_palmeira() -> None:
    img = Image.new("RGBA", (24, 44), (0, 0, 0, 0))
    outline = (28, 40, 24, 255)
    trunk_dark = (122, 108, 92, 255)
    trunk_light = (158, 144, 124, 255)
    palm_neck = (82, 132, 58, 255)
    leaf_dark = (42, 104, 44, 255)
    leaf_mid = (66, 142, 58, 255)
    leaf_light = (106, 178, 76, 255)

    # Sombra
    rect(img, 8, 40, 15, 42, (20, 24, 20, 85))

    # Tronco anelado cinza-claro da Palmeira Imperial
    rect(img, 10, 15, 13, 41, outline)
    rect(img, 11, 15, 12, 40, trunk_dark)
    for y in range(17, 40, 3):
        px(img, 11, y, trunk_light)
        px(img, 12, y, trunk_light)

    # Palmito verde no topo do tronco
    rect(img, 10, 11, 13, 15, palm_neck)

    # Copa de folhas arqueadas
    # Topo
    rect(img, 10, 2, 13, 10, leaf_mid)
    rect(img, 11, 3, 12, 8, leaf_light)
    # Esquerda superior e inferior
    rect(img, 3, 6, 10, 9, leaf_dark)
    rect(img, 4, 5, 9, 7, leaf_mid)
    rect(img, 2, 10, 9, 13, leaf_dark)
    rect(img, 3, 10, 8, 11, leaf_mid)
    px(img, 1, 13, outline)
    # Direita superior e inferior
    rect(img, 13, 6, 20, 9, leaf_dark)
    rect(img, 14, 5, 19, 7, leaf_mid)
    rect(img, 14, 10, 21, 13, leaf_dark)
    rect(img, 15, 10, 20, 11, leaf_mid)
    px(img, 22, 13, outline)
    # Destaques
    px(img, 6, 6, leaf_light)
    px(img, 17, 6, leaf_light)

    img.save(OUT_DIR / "palmeira_imperial.png")


def generate_pe_de_moleque() -> None:
    """Calçamento colonial pé-de-moleque (32x32) com pedras irregulares sobre terra."""
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    dirt = (132, 108, 82, 155)
    stone_dark = (102, 100, 96, 230)
    stone_mid = (138, 134, 126, 235)
    stone_light = (168, 164, 154, 235)

    # Base suave de terra batida entre as pedras (borda arredondada)
    rect(img, 2, 2, 29, 29, dirt)
    rect(img, 1, 4, 30, 27, dirt)
    rect(img, 4, 1, 27, 30, dirt)

    # Pedras irregulares de pé-de-moleque
    stones = [
        (3, 3, 9, 7), (11, 2, 18, 6), (20, 3, 27, 7),
        (2, 9, 7, 14), (9, 8, 16, 13), (18, 9, 24, 14), (26, 9, 30, 14),
        (3, 16, 10, 20), (12, 15, 19, 20), (21, 16, 28, 21),
        (2, 22, 8, 27), (10, 22, 17, 28), (19, 23, 26, 28), (27, 23, 30, 27),
    ]
    for i, (x0, y0, x1, y1) in enumerate(stones):
        rect(img, x0, y0, x1, y1, stone_dark)
        rect(img, x0 + 1, y0 + 1, x1 - 1, y1 - 1, stone_mid if i % 2 == 0 else stone_light)
        px(img, x0 + 1, y0 + 1, stone_light)

    img.save(OUT_DIR / "pe_de_moleque.png")


def generate_terreiro_secagem() -> None:
    """Terreiro ladrilhado colonial (64x40) com montes de café e tabaco secando ao sol."""
    img = Image.new("RGBA", (64, 40), (0, 0, 0, 0))
    border = (96, 74, 54, 245)
    tile_a = (166, 126, 88, 235)
    tile_b = (152, 114, 78, 235)
    tile_line = (122, 90, 62, 220)
    coffee_dark = (74, 44, 28, 255)
    coffee_mid = (112, 68, 42, 255)
    coffee_red = (156, 54, 44, 255)
    tobacco_dark = (104, 88, 40, 255)
    tobacco_mid = (146, 124, 56, 255)

    # Mureta baixa ao redor do terreiro
    rect(img, 1, 1, 62, 38, border)
    rect(img, 3, 3, 60, 36, tile_a)

    # Ladrilhos quadriculados
    for ty in range(3, 36, 6):
        for tx in range(3, 60, 8):
            c = tile_a if ((tx // 8 + ty // 6) % 2 == 0) else tile_b
            rect(img, tx, ty, min(tx + 6, 59), min(ty + 4, 35), c)
            rect(img, tx, min(ty + 5, 36), min(tx + 7, 60), min(ty + 5, 36), tile_line)

    # Leiras de grãos de café secando (esquerda)
    for row_y in (8, 16, 24):
        rect(img, 8, row_y, 26, row_y + 4, coffee_dark)
        rect(img, 9, row_y + 1, 25, row_y + 3, coffee_mid)
        for gx in range(10, 25, 3):
            px(img, gx, row_y + 1, coffee_red)

    # Folhas de tabaco / fumo secando (direita)
    for row_y in (9, 18, 26):
        rect(img, 34, row_y, 54, row_y + 4, tobacco_dark)
        rect(img, 35, row_y + 1, 53, row_y + 3, tobacco_mid)

    img.save(OUT_DIR / "terreiro_secagem.png")


def generate_porteira_colonial() -> None:
    """Porteira rústica de madeira (40x20) na entrada da Estrada Real."""
    img = Image.new("RGBA", (40, 20), (0, 0, 0, 0))
    outline = (42, 30, 22, 255)
    wood_dark = (94, 62, 38, 255)
    wood_mid = (134, 90, 54, 255)
    wood_light = (172, 122, 74, 255)
    stone = (130, 128, 124, 255)

    # Mourões laterais (esquerdo e direito) com base de pedra
    for mx in (2, 33):
        rect(img, mx - 1, 15, mx + 5, 18, stone)
        rect(img, mx, 2, mx + 4, 17, outline)
        rect(img, mx + 1, 3, mx + 3, 16, wood_mid)
        rect(img, mx + 1, 3, mx + 1, 16, wood_light)
        px(img, mx + 2, 1, wood_dark)

    # Folha da porteira aberta para a esquerda (não bloqueia passagem central)
    rect(img, 6, 6, 13, 15, outline)
    for ry in (7, 10, 13):
        rect(img, 6, ry, 12, ry + 1, wood_mid)
        px(img, 7, ry, wood_light)
    rect(img, 11, 6, 12, 15, wood_dark)

    # Folha direita entreaberta
    rect(img, 26, 6, 33, 15, outline)
    for ry in (7, 10, 13):
        rect(img, 27, ry, 33, ry + 1, wood_mid)
        px(img, 28, ry, wood_light)
    rect(img, 27, 6, 28, 15, wood_dark)

    img.save(OUT_DIR / "porteira_colonial.png")


def generate_cruzeiro_colonial() -> None:
    """Cruzeiro colonial de madeira e pedra (16x32) para o adro da Capela."""
    img = Image.new("RGBA", (16, 32), (0, 0, 0, 0))
    outline = (36, 28, 24, 255)
    stone_dark = (104, 104, 108, 255)
    stone_light = (156, 156, 160, 255)
    wood_dark = (88, 56, 34, 255)
    wood_mid = (128, 86, 50, 255)
    gold = (224, 186, 82, 255)

    # Sombra
    rect(img, 2, 28, 13, 30, (20, 24, 20, 90))
    # Pedestal escalonado de pedra
    rect(img, 2, 24, 13, 29, outline)
    rect(img, 3, 25, 12, 28, stone_dark)
    rect(img, 4, 22, 11, 25, outline)
    rect(img, 5, 23, 10, 24, stone_light)

    # Haste vertical da cruz
    rect(img, 6, 2, 9, 22, outline)
    rect(img, 7, 3, 8, 22, wood_mid)
    rect(img, 8, 3, 8, 22, wood_dark)

    # Braço horizontal
    rect(img, 2, 7, 13, 10, outline)
    rect(img, 3, 8, 12, 9, wood_mid)
    px(img, 7, 8, gold)
    px(img, 8, 8, gold)

    img.save(OUT_DIR / "cruzeiro_colonial.png")


def generate_barris_engenho() -> None:
    """Barris de aguardente/melado e sacas de açúcar (28x18) para o Engenho."""
    img = Image.new("RGBA", (28, 18), (0, 0, 0, 0))
    outline = (38, 28, 22, 255)
    wood_dark = (102, 66, 38, 255)
    wood_mid = (146, 98, 56, 255)
    iron = (72, 76, 84, 255)
    sack_light = (214, 196, 156, 255)
    sack_mid = (178, 158, 118, 255)

    # Sombra
    rect(img, 2, 14, 25, 16, (20, 24, 20, 90))

    # Dois barris de madeira com aros de ferro
    for bx in (2, 10):
        rect(img, bx, 4, bx + 7, 15, outline)
        rect(img, bx + 1, 5, bx + 6, 14, wood_mid)
        rect(img, bx + 5, 5, bx + 6, 14, wood_dark)
        rect(img, bx + 1, 7, bx + 6, 7, iron)
        rect(img, bx + 1, 12, bx + 6, 12, iron)

    # Sacas de açúcar mascavo empilhadas à direita
    rect(img, 18, 7, 26, 15, outline)
    rect(img, 19, 8, 25, 14, sack_mid)
    rect(img, 19, 8, 24, 10, sack_light)
    rect(img, 19, 3, 25, 8, outline)
    rect(img, 20, 4, 24, 7, sack_light)

    img.save(OUT_DIR / "barris_engenho.png")


def generate_tropeiro_mula() -> None:
    """Tropeiro colonial de chapéu de aba larga com mula cargueira (32x28)."""
    img = Image.new("RGBA", (32, 28), (0, 0, 0, 0))
    outline = (36, 28, 24, 255)
    hat = (96, 62, 34, 255)
    skin = (212, 162, 124, 255)
    poncho = (154, 58, 46, 255)
    poncho_dark = (114, 38, 30, 255)
    pants = (68, 62, 54, 255)
    mule_dark = (104, 78, 56, 255)
    mule_mid = (138, 106, 78, 255)
    pack = (204, 184, 138, 255)
    gold = (226, 188, 74, 255)

    # Sombra
    rect(img, 3, 24, 29, 26, (20, 24, 20, 90))

    # Mula cargueira (direita)
    rect(img, 15, 12, 28, 20, outline)
    rect(img, 16, 13, 27, 19, mule_mid)
    # Cabeça e orelhas da mula
    rect(img, 25, 8, 30, 14, outline)
    rect(img, 26, 9, 29, 13, mule_dark)
    rect(img, 26, 5, 27, 8, mule_dark)
    rect(img, 28, 5, 29, 8, mule_dark)
    # Pernas
    for lx in (16, 19, 24, 26):
        rect(img, lx, 20, lx + 1, 25, outline)
    # Bruaca / carga de mantimentos
    rect(img, 17, 9, 24, 15, outline)
    rect(img, 18, 10, 23, 14, pack)
    px(img, 20, 12, gold)

    # Tropeiro (esquerda)
    # Chapéu de aba larga
    rect(img, 3, 5, 13, 7, outline)
    rect(img, 5, 3, 11, 6, hat)
    rect(img, 4, 6, 12, 6, hat)
    # Rosto
    rect(img, 6, 7, 10, 10, skin)
    px(img, 7, 8, outline)
    px(img, 9, 8, outline)
    # Poncho / gibão colonial
    rect(img, 4, 11, 12, 19, outline)
    rect(img, 5, 12, 11, 18, poncho)
    rect(img, 5, 16, 11, 18, poncho_dark)
    rect(img, 7, 13, 9, 15, gold)
    # Botas/calças
    rect(img, 5, 19, 7, 25, pants)
    rect(img, 9, 19, 11, 25, pants)

    img.save(OUT_DIR / "tropeiro_mula.png")


def generate_saci_perere() -> None:
    """Saci-Pererê (20x24) com gorro vermelho, cachimbo e redemoinho de folhas."""
    img = Image.new("RGBA", (20, 24), (0, 0, 0, 0))
    outline = (32, 24, 22, 255)
    red = (206, 44, 42, 255)
    red_dark = (154, 28, 28, 255)
    skin = (108, 68, 46, 255)
    skin_light = (138, 90, 62, 255)
    swirl = (168, 154, 126, 175)
    leaf = (76, 152, 62, 235)
    smoke = (224, 228, 234, 195)

    # Redemoinho na base
    rect(img, 3, 19, 16, 22, swirl)
    rect(img, 5, 17, 14, 20, swirl)
    px(img, 4, 18, leaf)
    px(img, 15, 17, leaf)
    px(img, 8, 21, leaf)

    # Gorro vermelho icônico
    rect(img, 7, 1, 12, 3, red_dark)
    rect(img, 6, 3, 13, 6, outline)
    rect(img, 7, 3, 12, 5, red)
    px(img, 12, 2, red)

    # Rosto e cachimbo
    rect(img, 7, 6, 12, 10, outline)
    rect(img, 8, 7, 11, 9, skin)
    px(img, 9, 8, (250, 246, 238, 255))
    px(img, 11, 8, (250, 246, 238, 255))
    # Cachimbo + fumacinha
    rect(img, 12, 9, 15, 10, (120, 78, 42, 255))
    px(img, 15, 7, smoke)
    px(img, 16, 5, smoke)

    # Tronco e short vermelho (uma perna)
    rect(img, 7, 11, 12, 14, skin)
    px(img, 8, 12, skin_light)
    rect(img, 7, 14, 12, 17, red)
    rect(img, 9, 17, 10, 20, skin)

    img.save(OUT_DIR / "saci_perere.png")


def generate_mula_sem_cabeca() -> None:
    """Mula Sem Cabeça (32x28) com corpo marrom-escuro e labaredas no pescoço."""
    img = Image.new("RGBA", (32, 28), (0, 0, 0, 0))
    outline = (26, 20, 22, 255)
    body_dark = (64, 44, 38, 255)
    body_mid = (92, 64, 52, 255)
    hoof = (38, 34, 36, 255)
    fire_red = (224, 62, 28, 255)
    fire_org = (248, 136, 36, 255)
    fire_yel = (255, 228, 92, 255)

    # Sombra
    rect(img, 4, 24, 27, 26, (20, 16, 24, 105))

    # Corpo da mula
    rect(img, 10, 12, 26, 20, outline)
    rect(img, 11, 13, 25, 19, body_mid)
    rect(img, 11, 17, 25, 19, body_dark)
    # Cauda
    rect(img, 26, 13, 29, 18, body_dark)
    # Pernas + cascos
    for lx in (11, 14, 22, 25):
        rect(img, lx, 20, lx + 1, 24, body_dark)
        rect(img, lx, 24, lx + 1, 25, hoof)

    # Pescoço sem cabeça jorrando chamas
    rect(img, 7, 10, 12, 16, outline)
    rect(img, 8, 11, 11, 15, body_dark)
    # Labaredas (fogo vivo)
    rect(img, 4, 5, 11, 11, fire_red)
    rect(img, 5, 3, 10, 10, fire_org)
    rect(img, 6, 5, 9, 9, fire_yel)
    px(img, 5, 2, fire_red)
    px(img, 8, 1, fire_yel)
    px(img, 3, 7, fire_org)

    img.save(OUT_DIR / "mula_sem_cabeca.png")


def generate_curupira() -> None:
    """Curupira (20x24) guardião da mata com cabelo de fogo e tanga de folhas."""
    img = Image.new("RGBA", (20, 24), (0, 0, 0, 0))
    outline = (32, 26, 22, 255)
    hair_red = (224, 72, 32, 255)
    hair_org = (248, 142, 44, 255)
    skin = (186, 134, 92, 255)
    leaf_dark = (44, 112, 46, 255)
    leaf_light = (86, 166, 68, 255)

    # Sombra
    rect(img, 5, 21, 14, 23, (20, 24, 20, 90))
    # Cabelo flamejante
    rect(img, 6, 1, 13, 6, hair_red)
    rect(img, 7, 2, 12, 5, hair_org)
    px(img, 8, 0, hair_org)
    px(img, 11, 0, hair_red)
    # Rosto
    rect(img, 7, 6, 12, 10, outline)
    rect(img, 8, 7, 11, 9, skin)
    px(img, 9, 8, outline)
    px(img, 11, 8, outline)
    # Corpo e tanga de folhas
    rect(img, 7, 11, 12, 14, skin)
    rect(img, 6, 14, 13, 18, leaf_dark)
    rect(img, 7, 14, 12, 16, leaf_light)
    # Pernas com pés virados
    rect(img, 7, 18, 8, 21, skin)
    rect(img, 11, 18, 12, 21, skin)
    rect(img, 6, 21, 8, 22, outline)
    rect(img, 11, 21, 13, 22, outline)

    img.save(OUT_DIR / "curupira.png")


def generate_iara_lago() -> None:
    """Iara / Mãe d'Água (24x24) emergindo do lago com flor e cauda esmeralda."""
    img = Image.new("RGBA", (24, 24), (0, 0, 0, 0))
    outline = (24, 44, 52, 255)
    hair = (32, 34, 46, 255)
    skin = (198, 148, 112, 255)
    tail_dark = (34, 138, 118, 255)
    tail_light = (78, 198, 168, 255)
    water = (128, 216, 248, 195)
    flower = (244, 112, 152, 255)

    # Ondas na água
    rect(img, 3, 18, 20, 21, water)
    rect(img, 5, 20, 18, 22, (196, 240, 255, 215))

    # Cabelo longo escuro + flor
    rect(img, 7, 3, 16, 14, hair)
    rect(img, 14, 4, 16, 6, flower)
    px(img, 15, 5, (255, 232, 112, 255))

    # Rosto e tronco
    rect(img, 9, 5, 14, 9, skin)
    px(img, 10, 7, outline)
    px(img, 13, 7, outline)
    rect(img, 9, 10, 14, 14, skin)
    # Cauda brilhante emergindo
    rect(img, 8, 14, 15, 19, tail_dark)
    rect(img, 9, 15, 14, 18, tail_light)
    rect(img, 16, 15, 20, 18, tail_light)

    img.save(OUT_DIR / "iara_lago.png")


def generate_igreja_matriz() -> None:
    """Igreja Matriz barroca colonial (64x64) com torre sineira e frontão."""
    img = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    outline = (42, 34, 30, 255)
    wall = (242, 236, 224, 255)
    shade = (206, 198, 184, 255)
    blue = (54, 102, 152, 255)
    blue_dark = (34, 68, 104, 255)
    roof = (176, 78, 52, 255)
    roof_dark = (138, 56, 38, 255)
    gold = (228, 190, 76, 255)
    stone = (132, 130, 126, 255)

    # Sombra
    rect(img, 5, 58, 58, 62, (20, 24, 20, 95))

    # Cruz central e da torre
    rect(img, 31, 4, 32, 10, gold)
    rect(img, 29, 6, 34, 7, gold)
    rect(img, 49, 1, 50, 6, gold)
    rect(img, 48, 3, 51, 3, gold)

    # Torre sineira à direita
    rect(img, 43, 6, 56, 58, outline)
    rect(img, 44, 7, 55, 57, wall)
    rect(img, 44, 7, 55, 12, roof)
    rect(img, 47, 15, 52, 22, blue_dark)
    rect(img, 48, 17, 51, 21, gold)  # sino

    # Frontão barroco central
    for row in range(10):
        x0 = 26 - row
        x1 = 37 + row
        rect(img, x0, 11 + row, x1, 11 + row, outline)
        rect(img, x0 + 1, 11 + row, x1 - 1, 11 + row, wall)
    rect(img, 29, 15, 34, 19, blue_dark)  # óculo

    # Telhado nave esquerda
    rect(img, 7, 21, 43, 28, outline)
    rect(img, 8, 22, 42, 27, roof)
    for tx in range(9, 42, 4):
        rect(img, tx, 22, tx + 1, 27, roof_dark)

    # Fachada principal caiada
    rect(img, 8, 28, 44, 58, outline)
    rect(img, 9, 28, 43, 56, wall)
    rect(img, 9, 28, 11, 56, blue)
    rect(img, 41, 28, 43, 56, blue)
    rect(img, 9, 55, 55, 58, stone)

    # Portal principal em arco
    rect(img, 21, 38, 31, 57, outline)
    rect(img, 22, 39, 30, 57, blue)
    rect(img, 25, 39, 27, 57, blue_dark)
    # Janelas do coro
    for jx in (14, 34):
        rect(img, jx, 33, jx + 4, 40, outline)
        rect(img, jx + 1, 34, jx + 3, 39, blue_dark)
    # Escadaria
    rect(img, 18, 58, 34, 60, (166, 162, 156, 255))

    img.save(OUT_DIR / "igreja_matriz.png")


def generate_ferraria_colonial() -> None:
    """Ferraria colonial (48x40) com chaminé de pedra, forja acesa e bigorna."""
    img = Image.new("RGBA", (48, 40), (0, 0, 0, 0))
    outline = (38, 30, 26, 255)
    stone = (124, 122, 118, 255)
    stone_dark = (88, 86, 84, 255)
    roof = (148, 66, 44, 255)
    wood = (128, 84, 48, 255)
    fire = (252, 146, 38, 255)
    iron = (64, 68, 76, 255)

    rect(img, 3, 35, 44, 38, (20, 24, 20, 95))
    # Chaminé
    rect(img, 34, 2, 42, 16, outline)
    rect(img, 35, 3, 41, 15, stone)
    # Telhado
    rect(img, 3, 9, 44, 18, outline)
    rect(img, 4, 10, 43, 17, roof)
    # Paredes de pedra e madeira
    rect(img, 5, 18, 42, 35, outline)
    rect(img, 6, 18, 41, 34, stone)
    rect(img, 6, 18, 14, 34, wood)
    # Forja acesa
    rect(img, 24, 24, 34, 34, stone_dark)
    rect(img, 26, 26, 32, 32, fire)
    rect(img, 27, 28, 31, 31, (255, 224, 96, 255))
    # Bigorna na frente
    rect(img, 10, 30, 18, 35, iron)
    rect(img, 12, 28, 17, 30, (108, 114, 124, 255))

    img.save(OUT_DIR / "ferraria_colonial.png")


def generate_venda_colonial() -> None:
    """Venda / Armazém colonial da Dona Quitéria (48x40) com toldo e balcão."""
    img = Image.new("RGBA", (48, 40), (0, 0, 0, 0))
    outline = (38, 30, 26, 255)
    wall = (234, 214, 172, 255)
    roof = (174, 82, 54, 255)
    green = (52, 116, 74, 255)
    awning_a = (188, 56, 46, 255)
    awning_b = (242, 234, 214, 255)
    wood = (138, 92, 52, 255)

    rect(img, 3, 35, 44, 38, (20, 24, 20, 95))
    # Telhado
    rect(img, 3, 6, 44, 16, outline)
    rect(img, 4, 7, 43, 15, roof)
    # Parede ocre colonial
    rect(img, 5, 16, 42, 35, outline)
    rect(img, 6, 16, 41, 34, wall)
    # Porta verde colonial
    rect(img, 9, 22, 17, 35, outline)
    rect(img, 10, 23, 16, 35, green)
    # Toldo listrado sobre o balcão
    for i in range(6):
        ax = 20 + i * 3
        rect(img, ax, 20, ax + 2, 24, awning_a if i % 2 == 0 else awning_b)
    # Balcão com frutas/mercadorias
    rect(img, 20, 28, 39, 34, outline)
    rect(img, 21, 29, 38, 33, wood)
    px(img, 24, 27, (226, 66, 52, 255))
    px(img, 28, 27, (238, 198, 54, 255))
    px(img, 33, 27, (92, 166, 62, 255))

    img.save(OUT_DIR / "venda_colonial.png")


def _generate_villager_npc(filename: str, hat_color, outfit_color, accent_color) -> None:
    img = Image.new("RGBA", (16, 22), (0, 0, 0, 0))
    outline = (34, 28, 24, 255)
    skin = (214, 168, 132, 255)
    rect(img, 4, 19, 11, 21, (20, 24, 20, 85))
    # Chapéu / cabelo
    rect(img, 4, 2, 11, 5, outline)
    rect(img, 5, 3, 10, 4, hat_color)
    # Rosto
    rect(img, 5, 5, 10, 9, outline)
    rect(img, 6, 6, 9, 8, skin)
    px(img, 7, 7, outline)
    px(img, 9, 7, outline)
    # Roupa
    rect(img, 4, 10, 11, 17, outline)
    rect(img, 5, 11, 10, 16, outfit_color)
    rect(img, 7, 11, 8, 15, accent_color)
    # Pés
    rect(img, 5, 17, 6, 20, outline)
    rect(img, 9, 17, 10, 20, outline)
    img.save(OUT_DIR / filename)


def generate_village_npcs() -> None:
    # Padre Antônio (batina preta + colarinho branco)
    _generate_villager_npc("npc_padre.png", (76, 64, 58, 255), (38, 38, 44, 255), (242, 240, 236, 255))
    # Ferreiro Joaquim (avental de couro marrom + camisa crua)
    _generate_villager_npc("npc_ferreiro.png", (62, 46, 36, 255), (126, 78, 44, 255), (218, 204, 176, 255))
    # Dona Quitéria (lenço branco + vestido azul colonial)
    _generate_villager_npc("npc_quiteria.png", (240, 232, 218, 255), (56, 106, 156, 255), (234, 196, 92, 255))


if __name__ == "__main__":
    generate_chafariz()
    generate_capela()
    generate_carro_de_boi()
    generate_lampiao()
    generate_palmeira()
    generate_pe_de_moleque()
    generate_terreiro_secagem()
    generate_porteira_colonial()
    generate_cruzeiro_colonial()
    generate_barris_engenho()
    generate_tropeiro_mula()
    generate_saci_perere()
    generate_mula_sem_cabeca()
    generate_curupira()
    generate_iara_lago()
    generate_igreja_matriz()
    generate_ferraria_colonial()
    generate_venda_colonial()
    generate_village_npcs()
    print("Sprites coloniais gerados com sucesso em", OUT_DIR)
