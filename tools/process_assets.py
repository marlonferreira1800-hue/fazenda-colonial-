"""Processa os sprite sheets brutos em assets/raw/ para sprites PNG RGBA limpos em assets/sprites/.

Usa flood-fill a partir das bordas para remover apenas o fundo escuro (#1a1a2e)
sem apagar contornos escuros internos dos sprites, e gera também um atlas
alinhado 16x16 (godot_tileset_16x16.png) para o TileMapLayer do Godot 4.
"""

from collections import deque
from pathlib import Path
from PIL import Image, ImageDraw

RAW_DIR = Path("assets/raw")
OUT_DIR = Path("assets/sprites")


def remove_bg_floodfill(img: Image.Image, tolerance: int = 38) -> Image.Image:
    """Remove o fundo conectado às bordas com base na cor do canto superior esquerdo."""
    rgba = img.convert("RGBA")
    w, h = rgba.size
    pixels = rgba.load()
    bg_r, bg_g, bg_b, _ = pixels[0, 0]

    visited = bytearray(w * h)
    queue = deque()

    def is_bg(x: int, y: int) -> bool:
        r, g, b, a = pixels[x, y]
        if a == 0:
            return True
        return (
            abs(r - bg_r) <= tolerance
            and abs(g - bg_g) <= tolerance
            and abs(b - bg_b) <= tolerance
        )

    for x in range(w):
        for y in (0, h - 1):
            idx = y * w + x
            if not visited[idx] and is_bg(x, y):
                visited[idx] = 1
                queue.append((x, y))
    for y in range(h):
        for x in (0, w - 1):
            idx = y * w + x
            if not visited[idx] and is_bg(x, y):
                visited[idx] = 1
                queue.append((x, y))

    while queue:
        cx, cy = queue.popleft()
        pixels[cx, cy] = (0, 0, 0, 0)
        for nx, ny in ((cx - 1, cy), (cx + 1, cy), (cx, cy - 1), (cx, cy + 1)):
            if 0 <= nx < w and 0 <= ny < h:
                idx = ny * w + nx
                if not visited[idx] and is_bg(nx, ny):
                    visited[idx] = 1
                    queue.append((nx, ny))

    return rgba


def extract_components(rgba: Image.Image, min_size: int = 16) -> list[tuple[int, int, int, int]]:
    """Encontra bounding boxes de sprites separados por transparência."""
    w, h = rgba.size
    alpha = rgba.getchannel("A").load()
    visited = bytearray(w * h)
    boxes = []

    for y in range(h):
        for x in range(w):
            idx = y * w + x
            if visited[idx] or alpha[x, y] == 0:
                continue
            visited[idx] = 1
            q = deque([(x, y)])
            min_x = max_x = x
            min_y = max_y = y
            while q:
                cx, cy = q.popleft()
                if cx < min_x:
                    min_x = cx
                if cx > max_x:
                    max_x = cx
                if cy < min_y:
                    min_y = cy
                if cy > max_y:
                    max_y = cy
                for nx in range(max(0, cx - 2), min(w, cx + 3)):
                    for ny in range(max(0, cy - 2), min(h, cy + 3)):
                        nidx = ny * w + nx
                        if not visited[nidx] and alpha[nx, ny] > 0:
                            visited[nidx] = 1
                            q.append((nx, ny))
            if (max_x - min_x + 1) >= min_size and (max_y - min_y + 1) >= min_size:
                boxes.append((min_x, min_y, max_x + 1, max_y + 1))

    # Ordena de cima para baixo (em faixas de 48px) e esquerda para direita
    boxes.sort(key=lambda b: (b[1] // 48, b[0]))
    return boxes


def build_godot_tileset_16x16(out_path: Path) -> None:
    """Gera um atlas 16x16 (8x2 = 128x32) garantidamente alinhado para o TileMapLayer."""
    atlas = Image.new("RGBA", (128, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(atlas)

    def tile_rect(col: int, row: int, color: tuple[int, int, int, int]) -> tuple[int, int]:
        ox, oy = col * 16, row * 16
        d.rectangle([ox, oy, ox + 15, oy + 15], fill=color)
        return ox, oy

    # (0,0) Grama tropical
    ox, oy = tile_rect(0, 0, (74, 138, 66, 255))
    for px, py in ((2, 3), (9, 5), (5, 11), (13, 12)):
        d.point((ox + px, oy + py), fill=(96, 168, 82, 255))
        d.point((ox + px + 1, oy + py), fill=(58, 112, 52, 255))

    # (1,0) Terra arável seca
    ox, oy = tile_rect(1, 0, (128, 82, 52, 255))
    for y in (3, 7, 11):
        d.line([ox + 1, oy + y, ox + 14, oy + y], fill=(98, 60, 36, 255))

    # (2,0) Terra arável regada (úmida)
    ox, oy = tile_rect(2, 0, (78, 46, 28, 255))
    for y in (3, 7, 11):
        d.line([ox + 1, oy + y, ox + 14, oy + y], fill=(54, 30, 18, 255))

    # (3,0) Caminho de terra batida
    ox, oy = tile_rect(3, 0, (176, 126, 78, 255))
    for px, py in ((3, 4), (10, 9), (6, 13)):
        d.point((ox + px, oy + py), fill=(148, 102, 60, 255))

    # (4,0) Água de rio
    ox, oy = tile_rect(4, 0, (52, 126, 178, 255))
    d.line([ox + 2, oy + 5, ox + 6, oy + 5], fill=(118, 186, 224, 255))
    d.line([ox + 9, oy + 11, ox + 13, oy + 11], fill=(118, 186, 224, 255))

    # (5,0) Calçamento colonial (pedra)
    ox, oy = tile_rect(5, 0, (132, 130, 124, 255))
    d.rectangle([ox + 1, oy + 1, ox + 6, oy + 6], outline=(96, 94, 90, 255))
    d.rectangle([ox + 8, oy + 2, ox + 14, oy + 7], outline=(96, 94, 90, 255))
    d.rectangle([ox + 2, oy + 8, ox + 8, oy + 14], outline=(96, 94, 90, 255))

    # Linha 1: Estágios de crescimento (0..3) de Mandioca (cols 0..3) e Cana (cols 4..7)
    # Mandioca 0..3
    for stage in range(4):
        ox, oy = stage * 16, 16
        if stage == 0:
            d.rectangle([ox + 7, oy + 11, ox + 8, oy + 13], fill=(120, 190, 72, 255))
        elif stage == 1:
            d.rectangle([ox + 7, oy + 8, ox + 8, oy + 13], fill=(92, 168, 56, 255))
            d.line([ox + 5, oy + 9, ox + 10, oy + 9], fill=(120, 196, 74, 255))
        elif stage == 2:
            d.rectangle([ox + 6, oy + 6, ox + 9, oy + 13], fill=(68, 148, 48, 255))
            d.rectangle([ox + 4, oy + 6, ox + 11, oy + 9], fill=(98, 178, 62, 255))
        else:
            d.rectangle([ox + 5, oy + 11, ox + 10, oy + 14], fill=(142, 96, 56, 255))
            d.rectangle([ox + 3, oy + 3, ox + 12, oy + 10], fill=(72, 162, 52, 255))
            d.rectangle([ox + 5, oy + 2, ox + 10, oy + 7], fill=(108, 196, 68, 255))

    # Cana-de-açúcar 0..3
    for stage in range(4):
        ox, oy = (4 + stage) * 16, 16
        if stage == 0:
            d.rectangle([ox + 7, oy + 10, ox + 8, oy + 14], fill=(148, 206, 82, 255))
        elif stage == 1:
            d.rectangle([ox + 5, oy + 7, ox + 6, oy + 14], fill=(116, 186, 64, 255))
            d.rectangle([ox + 9, oy + 8, ox + 10, oy + 14], fill=(116, 186, 64, 255))
        elif stage == 2:
            for sx in (4, 7, 10):
                d.rectangle([ox + sx, oy + 4, ox + sx + 1, oy + 14], fill=(102, 174, 58, 255))
            d.line([ox + 3, oy + 5, ox + 12, oy + 3], fill=(142, 210, 78, 255))
        else:
            for sx in (3, 6, 9, 12):
                d.rectangle([ox + sx, oy + 2, ox + sx + 1, oy + 14], fill=(138, 182, 66, 255))
                d.point((ox + sx, oy + 6), fill=(196, 214, 108, 255))
                d.point((ox + sx, oy + 10), fill=(196, 214, 108, 255))
            d.line([ox + 2, oy + 2, ox + 13, oy + 1], fill=(92, 176, 56, 255))

    atlas.save(out_path)


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    sheets = {
        "buildings": RAW_DIR / "colonial_buildings.png",
        "characters_items": RAW_DIR / "colonial_characters_items.png",
        "terrain_crops": RAW_DIR / "colonial_tileset_terrain_crops.png",
    }

    for name, src in sheets.items():
        if not src.exists():
            print(f"SKIP (not found): {src}")
            continue
        rgba = remove_bg_floodfill(Image.open(src))
        clean_path = OUT_DIR / f"{name}_clean.png"
        rgba.save(clean_path)

        sub_dir = OUT_DIR / name
        sub_dir.mkdir(parents=True, exist_ok=True)
        boxes = extract_components(rgba, min_size=18)
        for i, box in enumerate(boxes):
            crop = rgba.crop(box)
            crop.save(sub_dir / f"{name}_{i:02d}.png")
        print(f"OK {name}: {len(boxes)} sprites extraídos -> {sub_dir}")

    tileset_path = OUT_DIR / "godot_tileset_16x16.png"
    build_godot_tileset_16x16(tileset_path)
    print(f"OK tileset 16x16 -> {tileset_path} ({Image.open(tileset_path).size})")


if __name__ == "__main__":
    main()
