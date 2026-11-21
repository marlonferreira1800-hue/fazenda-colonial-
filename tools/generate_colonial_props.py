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


if __name__ == "__main__":
    generate_chafariz()
    generate_capela()
    generate_carro_de_boi()
    generate_lampiao()
    generate_palmeira()
    print("Sprites coloniais gerados com sucesso em", OUT_DIR)
