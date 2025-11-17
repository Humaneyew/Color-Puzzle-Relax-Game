import json
import math
import random
import colorsys
from pathlib import Path

random.seed(8723)

EASY_SIZES = [(3, 7), (5, 5), (4, 7)]
MEDIUM_SIZES = [(5, 7), (6, 6), (6, 7), (7, 6)]
LARGE_SIZES = [(7, 7), (7, 8), (8, 8)]
HARD_SIZES = [(7, 9), (8, 9), (9, 9)]

PALETTE_BASES = [
    "sunrise",
    "mint",
    "lavender",
    "sorbet",
    "canyon",
    "aurora",
    "ocean",
    "orchid",
    "sage",
    "ember",
    "glacier",
    "copper",
    "meadow",
    "berry",
]
_palette_counts = {name: 0 for name in PALETTE_BASES}


def next_palette_id(base):
    if base not in _palette_counts:
        _palette_counts[base] = 0
    _palette_counts[base] += 1
    return f"{base}_{_palette_counts[base]:02d}"


def clamp(value, minimum=0.0, maximum=1.0):
    return max(minimum, min(maximum, value))


def mix_color(c1, c2, t):
    return tuple(c1[i] + (c2[i] - c1[i]) * t for i in range(3))


def rgb_to_hex(rgb):
    r = int(round(clamp(rgb[0]) * 255))
    g = int(round(clamp(rgb[1]) * 255))
    b = int(round(clamp(rgb[2]) * 255))
    return f"#{r:02X}{g:02X}{b:02X}"


def hsl_to_rgb(h, s, l):
    r, g, b = colorsys.hls_to_rgb((h % 360) / 360.0, clamp(l), clamp(s))
    return (r, g, b)


def bilinear(c00, c01, c10, c11, u, v):
    top = mix_color(c00, c01, u)
    bottom = mix_color(c10, c11, u)
    return mix_color(top, bottom, v)


def generate_mono(rows, cols, rng):
    hue = rng.uniform(0, 360)
    saturation = rng.uniform(0.22, 0.42)
    light_start = rng.uniform(0.55, 0.7)
    light_end = min(0.9, light_start + rng.uniform(0.18, 0.28))
    orientation = rng.choice(["horizontal", "vertical", "diagonal"])
    grid = []
    for r in range(rows):
        row = []
        for c in range(cols):
            u = c / (cols - 1) if cols > 1 else 0
            v = r / (rows - 1) if rows > 1 else 0
            if orientation == "horizontal":
                t = u
            elif orientation == "vertical":
                t = v
            else:
                t = (u + v) / 2
            light = light_start + (light_end - light_start) * t
            sat = clamp(saturation + (t - 0.5) * rng.uniform(-0.08, 0.08))
            color = hsl_to_rgb(hue, sat, light)
            row.append(color)
        grid.append(row)
    return grid


def generate_dual(rows, cols, rng):
    hue_a = rng.uniform(0, 360)
    hue_b = (hue_a + rng.uniform(60, 140)) % 360
    sat_a = rng.uniform(0.25, 0.45)
    sat_b = clamp(sat_a + rng.uniform(-0.1, 0.1))
    light_a = rng.uniform(0.6, 0.75)
    light_b = clamp(light_a + rng.uniform(-0.05, 0.08))
    orient = rng.choice(["horizontal", "diagonal"])
    grid = []
    for r in range(rows):
        row = []
        for c in range(cols):
            u = c / (cols - 1) if cols > 1 else 0
            v = r / (rows - 1) if rows > 1 else 0
            t = (u + v) / 2 if orient == "diagonal" else u
            color_a = hsl_to_rgb(hue_a, sat_a, light_a)
            color_b = hsl_to_rgb(hue_b, sat_b, light_b)
            mixed = mix_color(color_a, color_b, t)
            vertical_shade = clamp(0.03 * (v - 0.5))
            final = mix_color(mixed, (1.0, 1.0, 1.0), 0.05 + vertical_shade)
            row.append(final)
        grid.append(row)
    return grid


def generate_quad(rows, cols, rng):
    base_hue = rng.uniform(0, 360)
    offsets = [0, rng.uniform(30, 90), rng.uniform(90, 180), rng.uniform(180, 270)]
    sat_values = [rng.uniform(0.25, 0.45) for _ in range(4)]
    light_values = [rng.uniform(0.6, 0.82) for _ in range(4)]
    corners = [
        hsl_to_rgb(base_hue + offsets[0], sat_values[0], light_values[0]),
        hsl_to_rgb(base_hue + offsets[1], sat_values[1], light_values[1]),
        hsl_to_rgb(base_hue + offsets[2], sat_values[2], light_values[2]),
        hsl_to_rgb(base_hue + offsets[3], sat_values[3], light_values[3]),
    ]
    grid = []
    for r in range(rows):
        row = []
        for c in range(cols):
            u = c / (cols - 1) if cols > 1 else 0
            v = r / (rows - 1) if rows > 1 else 0
            color = bilinear(corners[0], corners[1], corners[2], corners[3], u, v)
            row.append(color)
        grid.append(row)
    return grid


def generate_complex(rows, cols, rng):
    base_grid = generate_quad(rows, cols, rng)
    center_hue = rng.uniform(0, 360)
    center_color = hsl_to_rgb(center_hue, rng.uniform(0.25, 0.5), rng.uniform(0.65, 0.85))
    band_color = hsl_to_rgb((center_hue + rng.uniform(90, 150)) % 360, rng.uniform(0.25, 0.4), rng.uniform(0.6, 0.8))
    grid = []
    for r in range(rows):
        row = []
        for c in range(cols):
            u = c / (cols - 1) if cols > 1 else 0
            v = r / (rows - 1) if rows > 1 else 0
            base = base_grid[r][c]
            dist_center = math.sqrt((u - 0.5) ** 2 + (v - 0.5) ** 2)
            center_weight = math.exp(-((dist_center) / 0.45) ** 2) * 0.35
            band = math.cos((u - 0.5) * math.pi)
            band_weight = max(0.0, band) * 0.2 + max(0.0, math.sin((v - 0.5) * math.pi)) * 0.1
            with_center = mix_color(base, center_color, center_weight)
            with_band = mix_color(with_center, band_color, band_weight)
            softened = mix_color(with_band, (1.0, 1.0, 1.0), 0.08)
            row.append(softened)
        grid.append(row)
    return grid


def choose_gradient(level_id):
    if level_id <= 8:
        return "mono"
    if level_id <= 15:
        return "mono" if level_id % 3 != 0 else "dual"
    if level_id <= 24:
        return "dual"
    if level_id <= 32:
        return "quad"
    if level_id <= 40:
        return "complex" if level_id % 2 == 0 else "quad"
    return "complex"


def size_for_level(level_id):
    if level_id <= 10:
        sizes = EASY_SIZES
    elif level_id <= 25:
        sizes = MEDIUM_SIZES
    elif level_id <= 40:
        sizes = LARGE_SIZES
    else:
        sizes = HARD_SIZES
    return sizes[(level_id - 1) % len(sizes)]


def difficulty_for_level(level_id):
    if level_id <= 10:
        return "easy"
    if level_id <= 30:
        return "medium"
    return "hard"


PATTERNS = [
    "perimeter",
    "cross",
    "vertical",
    "horizontal",
    "diagonal",
    "staggered",
    "inner_cross",
    "clusters",
    "offset_lines",
]


def pattern_for_level(level_id):
    if level_id <= 10:
        return PATTERNS[level_id % 3]
    if level_id <= 25:
        return PATTERNS[(level_id + 1) % len(PATTERNS)]
    if level_id <= 40:
        return PATTERNS[(level_id + 3) % len(PATTERNS)]
    return PATTERNS[(level_id + 5) % len(PATTERNS)]


def generate_anchor_mask(rows, cols, difficulty, pattern, rng):
    total = rows * cols
    if difficulty == "easy":
        ratio = rng.uniform(0.32, 0.4)
        min_required = 4
    elif difficulty == "medium":
        ratio = rng.uniform(0.22, 0.28)
        min_required = 4
    else:
        ratio = rng.uniform(0.12, 0.2)
        min_required = 2
    target = min(total, max(min_required, round(total * ratio)))
    if total - target < 5:
        target = max(min_required, total - 5)
    mask = [[False for _ in range(cols)] for _ in range(rows)]

    def add_cell(r, c):
        if 0 <= r < rows and 0 <= c < cols and not mask[r][c]:
            mask[r][c] = True

    corners = [(0, 0), (0, cols - 1), (rows - 1, 0), (rows - 1, cols - 1)]
    if difficulty in ("easy", "medium"):
        for r, c in corners:
            add_cell(r, c)
    else:
        rng.shuffle(corners)
        for r, c in corners[:2]:
            add_cell(r, c)

    def perimeter_positions():
        for c in range(cols):
            yield (0, c)
            yield (rows - 1, c)
        for r in range(rows):
            yield (r, 0)
            yield (r, cols - 1)

    def cross_positions():
        mid_r = rows // 2
        mid_c = cols // 2
        for c in range(cols):
            yield (mid_r, c)
        for r in range(rows):
            yield (r, mid_c)
        for pos in corners:
            yield pos

    def vertical_positions():
        mid_c = cols // 2
        for r in range(rows):
            yield (r, mid_c)
        for offset in (-1, 1):
            c = mid_c + offset
            if 0 <= c < cols:
                for r in range(rows):
                    yield (r, c)

    def horizontal_positions():
        mid_r = rows // 2
        for c in range(cols):
            yield (mid_r, c)
        for offset in (-1, 1):
            r = mid_r + offset
            if 0 <= r < rows:
                for c in range(cols):
                    yield (r, c)

    def diagonal_positions():
        for r in range(rows):
            c = int(round((cols - 1) * (r / (rows - 1) if rows > 1 else 0)))
            yield (r, c)
            yield (r, cols - 1 - c)

    def staggered_positions():
        for r in range(rows):
            start = r % 2
            for c in range(start, cols, 2):
                yield (r, c)

    def inner_cross_positions():
        mid_r = rows // 2
        mid_c = cols // 2
        offsets = [-1, 0, 1]
        for dr in offsets:
            r = mid_r + dr
            if 0 <= r < rows:
                for c in range(cols):
                    yield (r, c)
        for dc in offsets:
            c = mid_c + dc
            if 0 <= c < cols:
                for r in range(rows):
                    yield (r, c)

    def cluster_positions():
        centers = [
            (rows // 3, cols // 3),
            (rows // 3, 2 * cols // 3),
            (2 * rows // 3, cols // 3),
            (2 * rows // 3, 2 * cols // 3),
        ]
        for cr, cc in centers:
            for dr in (-1, 0, 1):
                for dc in (-1, 0, 1):
                    yield (cr + dr, cc + dc)

    def offset_lines_positions():
        for r in range(0, rows, 2):
            for c in range(cols):
                yield (r, c)
        for c in range(1, cols, 2):
            for r in range(rows):
                yield (r, c)

    pattern_map = {
        "perimeter": perimeter_positions,
        "cross": cross_positions,
        "vertical": vertical_positions,
        "horizontal": horizontal_positions,
        "diagonal": diagonal_positions,
        "staggered": staggered_positions,
        "inner_cross": inner_cross_positions,
        "clusters": cluster_positions,
        "offset_lines": offset_lines_positions,
    }

    generator = pattern_map.get(pattern, perimeter_positions)
    for pos in generator():
        add_cell(*pos)
        if sum(row.count(True) for row in mask) >= target:
            return mask

    attempts = 0
    while sum(row.count(True) for row in mask) < target and attempts < total * 3:
        attempts += 1
        if rows > 2 and cols > 2:
            r = rng.randint(1, rows - 2)
            c = rng.randint(1, cols - 2)
        else:
            r = rng.randrange(rows)
            c = rng.randrange(cols)
        add_cell(r, c)

    return mask


def generate_grid(rows, cols, gradient, rng):
    if gradient == "mono":
        return generate_mono(rows, cols, rng)
    if gradient == "dual":
        return generate_dual(rows, cols, rng)
    if gradient == "quad":
        return generate_quad(rows, cols, rng)
    return generate_complex(rows, cols, rng)


def reshape(flat, rows, cols):
    return [flat[r * cols:(r + 1) * cols] for r in range(rows)]


def convert_grid_to_hex(grid):
    return [[rgb_to_hex(color) for color in row] for row in grid]


def shuffle_start(solution_flat, mask, rows, cols, level_id):
    movable_indices = [idx for idx, is_fixed in enumerate(mask) if not is_fixed]
    movable_colors = [solution_flat[idx] for idx in movable_indices]
    rng = random.Random(level_id * 7919)
    attempts = 0
    while True:
        attempts += 1
        shuffled = movable_colors[:]
        rng.shuffle(shuffled)
        start_flat = list(solution_flat)
        for idx, pos in enumerate(movable_indices):
            start_flat[pos] = shuffled[idx]
        misplaced = sum(1 for i, color in enumerate(start_flat) if color != solution_flat[i])
        if misplaced >= 5:
            return start_flat
        if attempts > 50:
            rng.shuffle(movable_indices)


def main():
    rng = random.Random(8723)
    levels = []
    for level_id in range(1, 51):
        rows, cols = size_for_level(level_id)
        difficulty = difficulty_for_level(level_id)
        gradient = choose_gradient(level_id)
        pattern = pattern_for_level(level_id)
        palette_base = rng.choice(PALETTE_BASES)
        palette_id = next_palette_id(palette_base)
        grid = generate_grid(rows, cols, gradient, rng)
        solution_hex = convert_grid_to_hex(grid)
        mask_matrix = generate_anchor_mask(rows, cols, difficulty, pattern, rng)
        mask_flat = [cell for row in mask_matrix for cell in row]
        solution_flat = [color for row in solution_hex for color in row]
        start_flat = shuffle_start(solution_flat, mask_flat, rows, cols, level_id)
        start_matrix = reshape(start_flat, rows, cols)
        levels.append({
            "id": level_id,
            "rows": rows,
            "cols": cols,
            "paletteId": palette_id,
            "solution": solution_hex,
            "fixedMask": mask_matrix,
            "start": start_matrix,
            "difficulty": difficulty,
        })

    output = {"levels": levels}
    path = Path("assets/data")
    path.mkdir(parents=True, exist_ok=True)
    out_file = path / "puzzle_levels.json"
    with out_file.open("w", encoding="utf-8") as handle:
        json.dump(output, handle, indent=2)
        handle.write("\n")
    print(f"Wrote {len(levels)} levels to {out_file}")


if __name__ == "__main__":
    main()
