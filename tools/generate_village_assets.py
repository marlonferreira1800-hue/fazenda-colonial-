"""Gera sprites pixel-art coloniais brasileiros para a Vila Colonial e os 8 moradores (NPCs)
em assets/sprites/colonial_buildings_px/.

Edificações geradas:
- venda_secos_molhados.png (56x48)
- ferraria_colonial.png (54x46)
- botica_colonial.png (48x44)
- estalagem_colonial.png (56x48)
- casa_colonial_ocre.png (48x44)
- casa_colonial_azul.png (48x44)
- casa_colonial_terracota.png (48x44)
- casa_paroquial.png (48x44)
- coreto_vila.png (44x44)
- ponte_madeira.png (64x36)
- placa_direcao.png (20x24)

Spritesheets de moradores (64x64 = 4x4 frames de 16x16, compatível com farmer_sheet.png):
- villager_manoel.png, villager_bento.png, villager_quiteria.png, villager_antonio.png,
  villager_tiao.png, villager_sinha.png, villager_ze.png, villager_chico.png
"""

from pathlib import Path
from PIL import Image, ImageDraw

OUT_DIR = Path("assets/sprites/colonial_buildings_px")
OUT_DIR.mkdir(parents=True, exist_ok=True)

OUTLINE = (38, 30, 26, 255)
SHADOW = (20, 24, 20, 95)
ROOF_DARK = (138, 56, 38, 255)
ROOF_MID = (176, 78, 52, 255)
ROOF_LIGHT = (208, 108, 72, 255)
STONE_DARK = (104, 102, 98, 255)
STONE_MID = (142, 138, 132, 255)
WOOD_DARK = (86, 52, 32, 255)
WOOD_MID = (128, 82, 48, 255)
WOOD_LIGHT = (164, 114, 68, 255)
GOLD = (224, 184, 72, 255)


def px(img: Image.Image, x: int, y: int, color: tuple[int, int, int, int]) -> None:
    if 0 <= x < img.width and 0 <= y < img.height:
        img.putpixel((x, y), color)


def rect(img: Image.Image, x0: int, y0: int, x1: int, y1: int, color: tuple[int, int, int, int]) -> None:
    if x1 < x0 or y1 < y0:
        return
    d = ImageDraw.Draw(img)
    d.rectangle([x0, y0, x1, y1], fill=color)


def draw_colonial_roof(img: Image.Image, x0: int, y0: int, x1: int, y1: int) -> None:
    rect(img, x0, y0, x1, y1, OUTLINE)
    rect(img, x0 + 1, y0 + 1, x1 - 1, y1 - 1, ROOF_MID)
    # Cumeeira iluminada
    rect(img, x0 + 2, y0 + 1, x1 - 2, y0 + 2, ROOF_LIGHT)
    # Beiral sombreado
    rect(img, x0 + 1, y1 - 2, x1 - 1, y1 - 1, ROOF_DARK)
    # Telhas capa-canal verticais
    for tx in range(x0 + 3, x1 - 2, 4):
        rect(img, tx, y0 + 3, tx, y1 - 3, ROOF_DARK)
        rect(img, tx + 1, y0 + 3, tx + 1, y1 - 3, ROOF_LIGHT)


def draw_window(
    img: Image.Image,
    x: int,
    y: int,
    trim_col: tuple[int, int, int, int],
    glass_col: tuple[int, int, int, int] = (74, 108, 134, 255),
) -> None:
    rect(img, x, y, x + 7, y + 8, OUTLINE)
    rect(img, x + 1, y + 1, x + 6, y + 7, trim_col)
    rect(img, x + 2, y + 2, x + 5, y + 6, glass_col)
    # Reflexo e esquadria em cruz
    px(img, x + 2, y + 2, (162, 206, 224, 255))
    rect(img, x + 3, y + 2, x + 3, y + 6, trim_col)
    rect(img, x + 2, y + 4, x + 5, y + 4, trim_col)
    # Peitoril
    rect(img, x - 1, y + 8, x + 8, y + 9, STONE_MID)


def draw_door(
    img: Image.Image,
    x: int,
    y: int,
    w: int,
    h: int,
    door_col: tuple[int, int, int, int],
    trim_col: tuple[int, int, int, int],
) -> None:
    rect(img, x, y, x + w, y + h, OUTLINE)
    rect(img, x + 1, y + 1, x + w - 1, y + h, trim_col)
    rect(img, x + 2, y + 2, x + w - 2, y + h, door_col)
    # Bandeira / detalhe superior
    rect(img, x + 3, y + 3, x + w - 3, y + 4, trim_col)
    # Maçaneta dourada
    px(img, x + w - 3, y + h // 2 + 1, GOLD)


def draw_colonial_house_base(
    w: int,
    h: int,
    wall_col: tuple[int, int, int, int],
    wall_shade: tuple[int, int, int, int],
    trim_col: tuple[int, int, int, int],
    door_col: tuple[int, int, int, int],
) -> Image.Image:
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    # Sombra no chão
    rect(img, 3, h - 5, w - 4, h - 1, SHADOW)

    # Corpo da casa
    bx0, by0, bx1, by1 = 5, 16, w - 6, h - 5
    rect(img, bx0, by0, bx1, by1, OUTLINE)
    rect(img, bx0 + 1, by0 + 1, bx1 - 1, by1 - 1, wall_col)
    # Sombra sob o beiral
    rect(img, bx0 + 1, by0 + 1, bx1 - 1, by0 + 3, wall_shade)
    # Cunhais (pilastras coloniais nos cantos)
    rect(img, bx0 + 1, by0 + 1, bx0 + 3, by1 - 1, trim_col)
    rect(img, bx1 - 3, by0 + 1, bx1 - 1, by1 - 1, trim_col)
    # Embasamento de pedra
    rect(img, bx0 + 1, by1 - 4, bx1 - 1, by1 - 1, STONE_DARK)
    rect(img, bx0 + 1, by1 - 4, bx1 - 1, by1 - 3, STONE_MID)

    # Telhado de duas águas com beiral largo
    draw_colonial_roof(img, 2, 4, w - 3, 17)

    # Porta central ou deslocada
    door_x = w // 2 - 5
    draw_door(img, door_x, by1 - 15, 10, 14, door_col, trim_col)
    # Degrau de pedra
    rect(img, door_x - 1, by1 - 1, door_x + 11, by1 + 1, STONE_MID)

    return img


def generate_casa_ocre() -> None:
    img = draw_colonial_house_base(
        48, 44,
        wall_col=(236, 206, 134, 255),
        wall_shade=(208, 174, 102, 255),
        trim_col=(244, 238, 224, 255),
        door_col=(52, 98, 146, 255),
    )
    draw_window(img, 9, 22, (52, 98, 146, 255))
    draw_window(img, 31, 22, (52, 98, 146, 255))
    # Vaso de flores na soleira
    rect(img, 10, 35, 13, 38, (168, 86, 54, 255))
    rect(img, 10, 33, 13, 35, (64, 146, 68, 255))
    px(img, 11, 33, (238, 92, 114, 255))
    px(img, 12, 34, (246, 212, 82, 255))
    img.save(OUT_DIR / "casa_colonial_ocre.png")


def generate_casa_azul() -> None:
    img = draw_colonial_house_base(
        48, 44,
        wall_col=(240, 236, 228, 255),
        wall_shade=(208, 204, 194, 255),
        trim_col=(56, 106, 162, 255),
        door_col=(42, 82, 128, 255),
    )
    draw_window(img, 9, 22, (56, 106, 162, 255))
    draw_window(img, 31, 22, (56, 106, 162, 255))
    # Detalhe de vara/rede de pesca encostada na direita
    rect(img, 38, 28, 41, 38, (186, 164, 124, 255))
    px(img, 39, 30, (124, 106, 78, 255))
    px(img, 40, 33, (124, 106, 78, 255))
    px(img, 39, 36, (124, 106, 78, 255))
    img.save(OUT_DIR / "casa_colonial_azul.png")


def generate_casa_terracota() -> None:
    img = draw_colonial_house_base(
        48, 44,
        wall_col=(224, 174, 142, 255),
        wall_shade=(192, 140, 108, 255),
        trim_col=(238, 228, 208, 255),
        door_col=(66, 110, 68, 255),
    )
    draw_window(img, 9, 22, (66, 110, 68, 255))
    draw_window(img, 31, 22, (66, 110, 68, 255))
    # Pilha de lenha à esquerda
    for ly in (34, 36, 38):
        rect(img, 6, ly, 13, ly + 1, WOOD_MID)
        px(img, 7, ly, WOOD_LIGHT)
        px(img, 10, ly, WOOD_LIGHT)
        px(img, 12, ly, WOOD_DARK)
    img.save(OUT_DIR / "casa_colonial_terracota.png")


def generate_casa_paroquial() -> None:
    img = draw_colonial_house_base(
        48, 44,
        wall_col=(244, 240, 232, 255),
        wall_shade=(212, 206, 194, 255),
        trim_col=(118, 86, 58, 255),
        door_col=(92, 58, 36, 255),
    )
    draw_window(img, 9, 22, (118, 86, 58, 255))
    draw_window(img, 31, 22, (118, 86, 58, 255))
    # Cruz discreta no topo do telhado
    rect(img, 23, 0, 24, 5, GOLD)
    rect(img, 21, 2, 26, 2, GOLD)
    img.save(OUT_DIR / "casa_paroquial.png")


def generate_botica() -> None:
    img = draw_colonial_house_base(
        48, 44,
        wall_col=(204, 232, 214, 255),
        wall_shade=(166, 200, 180, 255),
        trim_col=(242, 238, 226, 255),
        door_col=(54, 118, 86, 255),
    )
    draw_window(img, 9, 21, (54, 118, 86, 255))
    draw_window(img, 31, 21, (54, 118, 86, 255))
    # Floreiras de ervas sob as janelas
    for fx in (9, 31):
        rect(img, fx, 30, fx + 7, 32, WOOD_MID)
        rect(img, fx + 1, 28, fx + 6, 30, (66, 152, 74, 255))
        px(img, fx + 2, 28, (238, 206, 86, 255))
        px(img, fx + 5, 29, (186, 126, 224, 255))
    # Plaquinha da Botica acima da porta
    rect(img, 19, 18, 28, 22, WOOD_DARK)
    rect(img, 20, 19, 27, 21, (242, 234, 206, 255))
    px(img, 23, 20, (54, 134, 72, 255))
    px(img, 24, 20, (54, 134, 72, 255))
    img.save(OUT_DIR / "botica_colonial.png")


def generate_venda() -> None:
    img = draw_colonial_house_base(
        56, 48,
        wall_col=(242, 224, 184, 255),
        wall_shade=(212, 188, 146, 255),
        trim_col=(154, 66, 46, 255),
        door_col=(118, 66, 38, 255),
    )
    draw_window(img, 9, 24, (154, 66, 46, 255))
    draw_window(img, 39, 24, (154, 66, 46, 255))
    # Toldo listrado sobre a frente da venda
    for tx in range(8, 48, 4):
        col = (182, 54, 44, 255) if ((tx // 4) % 2 == 0) else (246, 238, 218, 255)
        rect(img, tx, 18, tx + 3, 22, col)
    rect(img, 7, 17, 48, 17, OUTLINE)
    rect(img, 7, 23, 48, 23, OUTLINE)
    # Placa no telhado "VENDA"
    rect(img, 18, 11, 37, 16, OUTLINE)
    rect(img, 19, 12, 36, 15, WOOD_LIGHT)
    rect(img, 21, 13, 34, 14, WOOD_DARK)
    # Barril e saca na calçada
    rect(img, 8, 37, 13, 43, OUTLINE)
    rect(img, 9, 38, 12, 42, WOOD_MID)
    rect(img, 9, 40, 12, 40, STONE_DARK)
    rect(img, 42, 38, 47, 43, OUTLINE)
    rect(img, 43, 39, 46, 42, (214, 194, 148, 255))
    img.save(OUT_DIR / "venda_secos_molhados.png")


def generate_ferraria() -> None:
    img = Image.new("RGBA", (54, 46), (0, 0, 0, 0))
    rect(img, 3, 41, 50, 45, SHADOW)
    # Chaminé de tijolo à esquerda
    rect(img, 8, 1, 15, 16, OUTLINE)
    rect(img, 9, 2, 14, 15, (148, 68, 48, 255))
    rect(img, 9, 4, 14, 4, (112, 48, 34, 255))
    rect(img, 9, 8, 14, 8, (112, 48, 34, 255))
    rect(img, 7, 1, 16, 2, STONE_DARK)

    # Corpo de pedra e taipa
    rect(img, 5, 16, 48, 41, OUTLINE)
    rect(img, 6, 17, 47, 40, (186, 176, 162, 255))
    rect(img, 6, 34, 47, 40, STONE_DARK)
    rect(img, 6, 34, 47, 36, STONE_MID)
    draw_colonial_roof(img, 2, 5, 51, 17)

    # Abertura da forja com brasa alaranjada
    rect(img, 9, 24, 20, 38, OUTLINE)
    rect(img, 10, 25, 19, 37, (44, 34, 32, 255))
    rect(img, 11, 32, 18, 36, (224, 96, 28, 255))
    rect(img, 12, 33, 17, 35, (255, 196, 56, 255))

    # Porta de madeira pesada
    draw_door(img, 24, 25, 10, 15, WOOD_DARK, WOOD_MID)

    # Bigorna à direita
    rect(img, 38, 34, 45, 36, (56, 58, 64, 255))
    rect(img, 40, 36, 43, 40, (42, 44, 50, 255))
    rect(img, 37, 34, 38, 35, (92, 96, 104, 255))
    img.save(OUT_DIR / "ferraria_colonial.png")


def generate_estalagem() -> None:
    img = draw_colonial_house_base(
        56, 48,
        wall_col=(234, 212, 176, 255),
        wall_shade=(200, 174, 138, 255),
        trim_col=(104, 58, 38, 255),
        door_col=(134, 54, 42, 255),
    )
    # Chaminé no canto direito
    rect(img, 41, 0, 46, 8, OUTLINE)
    rect(img, 42, 1, 45, 7, STONE_MID)
    draw_window(img, 9, 23, (104, 58, 38, 255), (244, 198, 104, 255))
    draw_window(img, 39, 23, (104, 58, 38, 255), (244, 198, 104, 255))
    # Placa pendurada de estalagem/taberna
    rect(img, 18, 19, 22, 20, WOOD_DARK)
    rect(img, 17, 20, 21, 25, OUTLINE)
    rect(img, 18, 21, 20, 24, GOLD)
    # Mesinha / banco de madeira na varanda
    rect(img, 38, 38, 46, 42, WOOD_MID)
    rect(img, 38, 38, 46, 39, WOOD_LIGHT)
    img.save(OUT_DIR / "estalagem_colonial.png")


def generate_coreto() -> None:
    img = Image.new("RGBA", (44, 44), (0, 0, 0, 0))
    rect(img, 4, 38, 39, 42, SHADOW)
    # Pináculo no topo
    rect(img, 21, 1, 22, 5, GOLD)
    # Cúpula verde-cobre colonial
    for row in range(12):
        half = 3 + int(row * 1.45)
        y = 5 + row
        rect(img, 22 - half, y, 21 + half, y, (46, 104, 88, 255))
        if row % 2 == 0:
            rect(img, 22 - half + 2, y, 21 + half - 2, y, (68, 138, 114, 255))
    rect(img, 4, 16, 39, 18, OUTLINE)
    rect(img, 5, 17, 38, 17, GOLD)
    # Colunas finas de ferro
    for cx in (8, 16, 27, 35):
        rect(img, cx, 19, cx + 1, 31, (54, 58, 62, 255))
    # Gradil e base octogonal de pedra
    rect(img, 6, 28, 37, 31, (64, 68, 72, 255))
    for rx in range(8, 36, 3):
        rect(img, rx, 29, rx, 30, (226, 222, 208, 255))
    rect(img, 5, 32, 38, 39, OUTLINE)
    rect(img, 6, 33, 37, 38, STONE_MID)
    rect(img, 6, 33, 37, 34, (192, 188, 180, 255))
    # Escadinha central
    rect(img, 18, 35, 25, 40, STONE_DARK)
    rect(img, 19, 36, 24, 37, STONE_MID)
    rect(img, 19, 39, 24, 40, (192, 188, 180, 255))
    img.save(OUT_DIR / "coreto_vila.png")


def generate_ponte_madeira() -> None:
    img = Image.new("RGBA", (64, 36), (0, 0, 0, 0))
    # Tábuas do tabuleiro
    rect(img, 2, 6, 61, 30, OUTLINE)
    rect(img, 3, 7, 60, 29, WOOD_MID)
    for tx in range(4, 60, 4):
        rect(img, tx, 7, tx, 29, WOOD_DARK)
        rect(img, tx + 1, 8, tx + 2, 28, WOOD_LIGHT)
    # Corrimões superior e inferior
    rect(img, 2, 4, 61, 7, WOOD_DARK)
    rect(img, 3, 5, 60, 6, WOOD_LIGHT)
    rect(img, 2, 29, 61, 32, WOOD_DARK)
    rect(img, 3, 30, 60, 31, WOOD_LIGHT)
    # Mourões (postes)
    for px_x in (4, 21, 40, 57):
        rect(img, px_x, 2, px_x + 2, 8, OUTLINE)
        rect(img, px_x + 1, 3, px_x + 1, 7, WOOD_LIGHT)
        rect(img, px_x, 27, px_x + 2, 34, OUTLINE)
        rect(img, px_x + 1, 28, px_x + 1, 33, WOOD_LIGHT)
    img.save(OUT_DIR / "ponte_madeira.png")


def generate_placa_direcao() -> None:
    img = Image.new("RGBA", (20, 24), (0, 0, 0, 0))
    rect(img, 6, 20, 13, 22, SHADOW)
    # Poste
    rect(img, 8, 4, 11, 21, OUTLINE)
    rect(img, 9, 5, 10, 20, WOOD_MID)
    # Seta direita
    rect(img, 9, 6, 18, 10, OUTLINE)
    rect(img, 10, 7, 17, 9, WOOD_LIGHT)
    px(img, 18, 8, OUTLINE)
    # Seta esquerda
    rect(img, 1, 11, 10, 15, OUTLINE)
    rect(img, 2, 12, 9, 14, WOOD_LIGHT)
    px(img, 1, 13, OUTLINE)
    img.save(OUT_DIR / "placa_direcao.png")


def draw_villager_frame(
    sheet: Image.Image,
    col: int,
    row: int,
    skin: tuple[int, int, int, int],
    hair: tuple[int, int, int, int],
    shirt: tuple[int, int, int, int],
    pants: tuple[int, int, int, int],
    hat: tuple[int, int, int, int] | None,
    accent: tuple[int, int, int, int] | None,
    is_dress: bool = False,
) -> None:
    ox = col * 16
    oy = row * 16
    # Walk bob & leg stride
    bob = -1 if (col in (1, 3)) else 0
    leg_l = 1 if col == 1 else (-1 if col == 3 else 0)
    leg_r = -leg_l

    # Ground shadow
    rect(sheet, ox + 4, oy + 14, ox + 11, oy + 15, (20, 24, 20, 80))

    # Legs / boots or dress hem
    if is_dress:
        rect(sheet, ox + 4, oy + 11 + bob, ox + 11, oy + 13 + bob, OUTLINE)
        rect(sheet, ox + 5, oy + 11 + bob, ox + 10, oy + 13 + bob, pants)
        px(sheet, ox + 5 + (1 if leg_l > 0 else 0), oy + 14, WOOD_DARK)
        px(sheet, ox + 10 + (-1 if leg_r < 0 else 0), oy + 14, WOOD_DARK)
    else:
        rect(sheet, ox + 5, oy + 11 + bob + max(0, leg_l), ox + 6, oy + 14, pants)
        rect(sheet, ox + 9, oy + 11 + bob + max(0, leg_r), ox + 10, oy + 14, pants)
        px(sheet, ox + 5, oy + 14, WOOD_DARK)
        px(sheet, ox + 10, oy + 14, WOOD_DARK)

    # Torso
    rect(sheet, ox + 4, oy + 7 + bob, ox + 11, oy + 11 + bob, OUTLINE)
    rect(sheet, ox + 5, oy + 8 + bob, ox + 10, oy + 11 + bob, shirt)
    if accent is not None:
        if row == 0:  # front apron / collar / vest
            rect(sheet, ox + 6, oy + 9 + bob, ox + 9, oy + 11 + bob, accent)
        elif row == 1:  # back
            rect(sheet, ox + 6, oy + 8 + bob, ox + 9, oy + 10 + bob, accent)
        else:
            rect(sheet, ox + 6, oy + 9 + bob, ox + 8, oy + 11 + bob, accent)

    # Arms
    arm_y = oy + 8 + bob
    px(sheet, ox + 4, arm_y + (1 if col == 1 else 0), skin)
    px(sheet, ox + 11, arm_y + (1 if col == 3 else 0), skin)

    # Head
    rect(sheet, ox + 4, oy + 2 + bob, ox + 11, oy + 7 + bob, OUTLINE)
    rect(sheet, ox + 5, oy + 3 + bob, ox + 10, oy + 6 + bob, skin)

    # Hair / face based on direction (0=down, 1=up, 2=left, 3=right)
    if row == 0:
        rect(sheet, ox + 5, oy + 3 + bob, ox + 10, oy + 3 + bob, hair)
        px(sheet, ox + 6, oy + 5 + bob, (30, 24, 22, 255))
        px(sheet, ox + 9, oy + 5 + bob, (30, 24, 22, 255))
    elif row == 1:
        rect(sheet, ox + 5, oy + 3 + bob, ox + 10, oy + 6 + bob, hair)
    elif row == 2:
        rect(sheet, ox + 7, oy + 3 + bob, ox + 10, oy + 6 + bob, hair)
        px(sheet, ox + 6, oy + 5 + bob, (30, 24, 22, 255))
    else:
        rect(sheet, ox + 5, oy + 3 + bob, ox + 8, oy + 6 + bob, hair)
        px(sheet, ox + 9, oy + 5 + bob, (30, 24, 22, 255))

    # Optional hat / headscarf
    if hat is not None:
        rect(sheet, ox + 3, oy + 2 + bob, ox + 12, oy + 3 + bob, hat)
        rect(sheet, ox + 5, oy + 1 + bob, ox + 10, oy + 2 + bob, hat)


def generate_villagers() -> None:
    specs = [
        # (filename, skin, hair, shirt, pants, hat, accent, is_dress)
        ("villager_manoel.png", (232, 186, 146, 255), (104, 72, 48, 255), (138, 86, 52, 255), (72, 62, 54, 255), (218, 194, 128, 255), (242, 236, 222, 255), False),
        ("villager_bento.png", (198, 144, 102, 255), (52, 38, 30, 255), (222, 210, 188, 255), (62, 54, 48, 255), None, (108, 62, 36, 255), False),
        ("villager_quiteria.png", (174, 122, 84, 255), (42, 32, 28, 255), (66, 134, 88, 255), (48, 96, 66, 255), (236, 228, 206, 255), (216, 234, 194, 255), True),
        ("villager_antonio.png", (236, 194, 158, 255), (178, 174, 168, 255), (42, 42, 48, 255), (36, 36, 42, 255), (48, 48, 54, 255), (244, 244, 240, 255), True),
        ("villager_tiao.png", (184, 132, 92, 255), (46, 36, 30, 255), (68, 124, 174, 255), (108, 88, 64, 255), (228, 200, 122, 255), (226, 232, 238, 255), False),
        ("villager_sinha.png", (214, 164, 124, 255), (58, 40, 32, 255), (166, 68, 86, 255), (132, 50, 68, 255), None, (244, 236, 224, 255), True),
        ("villager_ze.png", (206, 156, 114, 255), (48, 34, 26, 255), (238, 228, 208, 255), (76, 56, 44, 255), (96, 52, 38, 255), (154, 54, 48, 255), False),
        ("villager_chico.png", (192, 142, 100, 255), (62, 46, 34, 255), (206, 148, 66, 255), (84, 72, 54, 255), (216, 186, 112, 255), (124, 74, 42, 255), False),
        ("villager_pedrinho.png", (222, 174, 134, 255), (76, 48, 30, 255), (76, 152, 214, 255), (96, 72, 48, 255), (232, 206, 128, 255), (242, 240, 224, 255), False),
        ("villager_mariquinha.png", (204, 152, 112, 255), (48, 32, 24, 255), (234, 122, 146, 255), (196, 86, 112, 255), None, (248, 242, 226, 255), True),
    ]
    for filename, skin, hair, shirt, pants, hat, accent, is_dress in specs:
        sheet = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
        for row in range(4):
            for col in range(4):
                draw_villager_frame(sheet, col, row, skin, hair, shirt, pants, hat, accent, is_dress)
        sheet.save(OUT_DIR / filename)


def generate_mina_entrada() -> None:
    img = Image.new("RGBA", (48, 40), (0, 0, 0, 0))
    rect(img, 4, 34, 43, 38, SHADOW)
    # Rochedo externo
    rect(img, 4, 8, 43, 35, OUTLINE)
    rect(img, 5, 9, 42, 34, STONE_DARK)
    rect(img, 8, 5, 39, 12, STONE_MID)
    rect(img, 10, 9, 37, 15, STONE_MID)
    # Abertura escura da gruta com vigas de madeira
    rect(img, 14, 15, 33, 35, WOOD_DARK)
    rect(img, 16, 17, 31, 35, (22, 18, 20, 255))
    rect(img, 13, 14, 34, 17, WOOD_MID)
    rect(img, 14, 15, 33, 16, WOOD_LIGHT)
    # Brilhos dourados nas pedras
    px(img, 9, 20, GOLD)
    px(img, 10, 21, GOLD)
    px(img, 38, 18, GOLD)
    px(img, 39, 19, GOLD)
    # Tocha na lateral
    rect(img, 11, 24, 12, 30, WOOD_MID)
    rect(img, 10, 21, 13, 24, (255, 168, 36, 255))
    img.save(OUT_DIR / "mina_entrada.png")


def generate_arvore_frutifera() -> None:
    img = Image.new("RGBA", (32, 36), (0, 0, 0, 0))
    rect(img, 8, 31, 23, 34, SHADOW)
    # Tronco
    rect(img, 13, 20, 18, 32, OUTLINE)
    rect(img, 14, 21, 17, 31, WOOD_MID)
    rect(img, 15, 21, 16, 31, WOOD_LIGHT)
    # Copa frondosa verde
    rect(img, 5, 6, 26, 22, OUTLINE)
    rect(img, 6, 7, 25, 21, (48, 124, 52, 255))
    rect(img, 8, 4, 23, 18, (68, 154, 66, 255))
    rect(img, 10, 6, 21, 13, (96, 182, 84, 255))
    # Frutas douradas/alaranjadas coloniais
    for fx, fy in [(9, 12), (16, 9), (22, 14), (13, 17), (19, 18)]:
        rect(img, fx, fy, fx + 2, fy + 2, (244, 154, 38, 255))
        px(img, fx, fy, (255, 226, 104, 255))
    img.save(OUT_DIR / "arvore_frutifera.png")


def main() -> None:
    generate_casa_ocre()
    generate_casa_azul()
    generate_casa_terracota()
    generate_casa_paroquial()
    generate_botica()
    generate_venda()
    generate_ferraria()
    generate_estalagem()
    generate_coreto()
    generate_ponte_madeira()
    generate_placa_direcao()
    generate_mina_entrada()
    generate_arvore_frutifera()
    generate_villagers()
    print(f"Sprites da vila e moradores gerados com sucesso em {OUT_DIR}")


if __name__ == "__main__":
    main()
