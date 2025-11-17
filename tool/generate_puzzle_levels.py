import json
import math
import random
from pathlib import Path
from typing import Iterable, List, Sequence, Tuple

SEED = 20251117
EASY_SIZES: Sequence[Tuple[int, int]] = ((3, 7), (5, 5), (4, 7))
ADVANCED_SIZES: Sequence[Tuple[int, int]] = (
    (7, 7),
    (8, 8),
    (7, 8),
    (8, 7),
    (9, 9),
    (7, 9),
    (9, 7),
)
ANCHOR_RATIO_RANGE = (0.15, 0.25)
MAX_NOISE = 4.0

# D65 reference white
REF_X = 95.047
REF_Y = 100.0
REF_Z = 108.883


def _hsl_to_rgb(h: float, s: float, l: float) -> Tuple[float, float, float]:
    import colorsys

    r, g, b = colorsys.hls_to_rgb((h % 360) / 360.0, l, s)
    return (r, g, b)


def _pivot_rgb(value: float) -> float:
    if value <= 0.04045:
        return value / 12.92
    return ((value + 0.055) / 1.055) ** 2.4


def _rgb_to_xyz(rgb: Tuple[float, float, float]) -> Tuple[float, float, float]:
    r, g, b = (_pivot_rgb(component) * 100.0 for component in rgb)
    r, g, b = r, g, b
    x = r * 0.4124 + g * 0.3576 + b * 0.1805
    y = r * 0.2126 + g * 0.7152 + b * 0.0722
    z = r * 0.0193 + g * 0.1192 + b * 0.9505
    return (x, y, z)


def _pivot_xyz(value: float) -> float:
    if value > 0.008856:
        return value ** (1 / 3)
    return (7.787 * value) + (16 / 116)


def _xyz_to_lab(xyz: Tuple[float, float, float]) -> Tuple[float, float, float]:
    x, y, z = xyz
    x = _pivot_xyz(x / REF_X)
    y = _pivot_xyz(y / REF_Y)
    z = _pivot_xyz(z / REF_Z)
    l = (116 * y) - 16
    a = 500 * (x - y)
    b = 200 * (y - z)
    return (l, a, b)


def _rgb_to_lab(rgb: Tuple[float, float, float]) -> Tuple[float, float, float]:
    return _xyz_to_lab(_rgb_to_xyz(rgb))


def _pivot_lab(value: float) -> float:
    if value ** 3 > 0.008856:
        return value ** 3
    return (value - 16 / 116) / 7.787


def _lab_to_xyz(lab: Tuple[float, float, float]) -> Tuple[float, float, float]:
    l, a, b = lab
    y = (l + 16) / 116
    x = a / 500 + y
    z = y - b / 200
    x = REF_X * _pivot_lab(x)
    y = REF_Y * _pivot_lab(y)
    z = REF_Z * _pivot_lab(z)
    return (x, y, z)


def _xyz_to_rgb(xyz: Tuple[float, float, float]) -> Tuple[float, float, float]:
    x, y, z = (component / 100.0 for component in xyz)
    r = x * 3.2406 + y * -1.5372 + z * -0.4986
    g = x * -0.9689 + y * 1.8758 + z * 0.0415
    b = x * 0.0557 + y * -0.2040 + z * 1.0570

    def gamma_correct(value: float) -> float:
        value = max(0.0, min(1.0, value))
        if value <= 0.0031308:
            return 12.92 * value
        return 1.055 * (value ** (1 / 2.4)) - 0.055

    return (gamma_correct(r), gamma_correct(g), gamma_correct(b))


def _lab_to_rgb(lab: Tuple[float, float, float]) -> Tuple[float, float, float]:
    return _xyz_to_rgb(_lab_to_xyz(lab))


def _lab_to_hex(lab: Tuple[float, float, float]) -> str:
    r, g, b = _lab_to_rgb(lab)
    r_i = max(0, min(255, int(round(r * 255))))
    g_i = max(0, min(255, int(round(g * 255))))
    b_i = max(0, min(255, int(round(b * 255))))
    return f"#{r_i:02X}{g_i:02X}{b_i:02X}"


def _bilinear(c00, c10, c01, c11, u, v):
    def lerp(a, b, t):
        return a + (b - a) * t

    top = tuple(lerp(c00[i], c10[i], u) for i in range(3))
    bottom = tuple(lerp(c01[i], c11[i], u) for i in range(3))
    return tuple(lerp(top[i], bottom[i], v) for i in range(3))


def _select_corner_palette(level_id: int, rng: random.Random) -> List[Tuple[float, float, float]]:
    if level_id <= 10:
        base_hue = rng.uniform(0, 360)
        sat = rng.uniform(0.32, 0.48)
        light = rng.uniform(0.55, 0.7)
        offsets = [rng.uniform(-10, 10) for _ in range(4)]
        lights = [light + rng.uniform(-0.1, 0.1) for _ in range(4)]
        return [
            _rgb_to_lab(_hsl_to_rgb(base_hue + offsets[i], sat, max(0.35, min(0.9, lights[i]))))
            for i in range(4)
        ]
    if level_id <= 30:
        base = rng.uniform(0, 360)
        companion = (base + rng.uniform(45, 120)) % 360
        sat_a = rng.uniform(0.28, 0.5)
        sat_b = rng.uniform(0.28, 0.5)
        light_a = rng.uniform(0.55, 0.75)
        light_b = rng.uniform(0.55, 0.8)
        c00 = _rgb_to_lab(_hsl_to_rgb(base, sat_a, light_a))
        c10 = _rgb_to_lab(_hsl_to_rgb(companion, sat_b, light_b))
        c01 = _rgb_to_lab(_hsl_to_rgb(base + rng.uniform(-20, 20), sat_a, light_b))
        c11 = _rgb_to_lab(_hsl_to_rgb(companion + rng.uniform(-15, 15), sat_b, light_a))
        return [c00, c10, c01, c11]
    hues = [rng.uniform(0, 360)]
    while len(hues) < 4:
        candidate = rng.uniform(0, 360)
        if all(abs((candidate - h + 180) % 360 - 180) > 40 for h in hues):
            hues.append(candidate)
    sat_values = [rng.uniform(0.25, 0.55) for _ in range(4)]
    light_values = [rng.uniform(0.5, 0.82) for _ in range(4)]
    return [
        _rgb_to_lab(_hsl_to_rgb(hues[i], sat_values[i], light_values[i])) for i in range(4)
    ]


def _generate_solution(rows: int, cols: int, level_id: int, rng: random.Random) -> List[List[str]]:
    corners = _select_corner_palette(level_id, rng)
    grid: List[List[str]] = []
    for r in range(rows):
        row: List[str] = []
        v = r / (rows - 1) if rows > 1 else 0
        for c in range(cols):
            u = c / (cols - 1) if cols > 1 else 0
            lab = _bilinear(corners[0], corners[1], corners[2], corners[3], u, v)
            noise_a = rng.uniform(-MAX_NOISE, MAX_NOISE)
            noise_b = rng.uniform(-MAX_NOISE, MAX_NOISE)
            lab = (lab[0], lab[1] + noise_a, lab[2] + noise_b)
            row.append(_lab_to_hex(lab))
        grid.append(row)
    return grid


def _choose_size(level_id: int, rng: random.Random) -> Tuple[int, int]:
    sizes = EASY_SIZES if level_id <= 10 else ADVANCED_SIZES
    return rng.choice(list(sizes))


def _pattern_positions(rows: int, cols: int, pattern: str) -> Iterable[Tuple[int, int]]:
    if pattern == "perimeter":
        for c in range(cols):
            yield (0, c)
            yield (rows - 1, c)
        for r in range(1, rows - 1):
            yield (r, 0)
            yield (r, cols - 1)
    elif pattern == "cross":
        mid_r = rows // 2
        mid_c = cols // 2
        for c in range(cols):
            yield (mid_r, c)
        for r in range(rows):
            yield (r, mid_c)
    elif pattern == "inner_cross":
        mid_r = rows // 2
        mid_c = cols // 2
        for dr in (-1, 0, 1):
            r = mid_r + dr
            if 0 <= r < rows:
                for c in range(cols):
                    yield (r, c)
        for dc in (-1, 0, 1):
            c = mid_c + dc
            if 0 <= c < cols:
                for r in range(rows):
                    yield (r, c)
    elif pattern == "clusters":
        centers = [
            (rows // 3, cols // 3),
            (rows // 3, 2 * cols // 3),
            (2 * rows // 3, cols // 3),
            (2 * rows // 3, 2 * cols // 3),
        ]
        for cr, cc in centers:
            for dr in (-1, 0, 1):
                for dc in (-1, 0, 1):
                    r = cr + dr
                    c = cc + dc
                    if 0 <= r < rows and 0 <= c < cols:
                        yield (r, c)
    else:
        for r in range(rows):
            yield (r, 0)
            yield (r, cols - 1)
            if r in (0, rows - 1):
                for c in range(cols):
                    yield (r, c)


def _select_pattern(level_id: int, rng: random.Random) -> str:
    if level_id <= 10:
        return rng.choice(["perimeter", "cross"])
    if level_id <= 25:
        return rng.choice(["perimeter", "cross", "inner_cross", "clusters"])
    return rng.choice(["perimeter", "inner_cross", "clusters"])


def _count_true(mask: List[List[bool]]) -> int:
    return sum(1 for row in mask for cell in row if cell)


def _ensure_row_col_movable(mask: List[List[bool]], rng: random.Random) -> None:
    rows = len(mask)
    cols = len(mask[0])
    for r in range(rows):
        if all(mask[r]):
            c = rng.randrange(cols)
            mask[r][c] = False
    for c in range(cols):
        if all(mask[r][c] for r in range(rows)):
            r = rng.randrange(rows)
            mask[r][c] = False


def _generate_anchor_mask(rows: int, cols: int, level_id: int, rng: random.Random) -> List[List[bool]]:
    total = rows * cols
    min_anchors = max(2, int(math.floor(total * ANCHOR_RATIO_RANGE[0])))
    max_anchors = max(min_anchors + 1, int(math.floor(total * ANCHOR_RATIO_RANGE[1])))
    target = rng.randint(min_anchors, max_anchors)
    mask = [[False for _ in range(cols)] for _ in range(rows)]

    def set_anchor(r: int, c: int) -> None:
        if 0 <= r < rows and 0 <= c < cols:
            mask[r][c] = True

    for corner in ((0, 0), (0, cols - 1), (rows - 1, 0), (rows - 1, cols - 1)):
        set_anchor(*corner)

    pattern = _select_pattern(level_id, rng)
    for r, c in _pattern_positions(rows, cols, pattern):
        set_anchor(r, c)
        if _count_true(mask) >= target:
            break

    while _count_true(mask) < target:
        if rng.random() < 0.6:
            edge = rng.choice([
                (0, rng.randrange(cols)),
                (rows - 1, rng.randrange(cols)),
                (rng.randrange(rows), 0),
                (rng.randrange(rows), cols - 1),
            ])
            set_anchor(*edge)
        else:
            r = rng.randrange(rows)
            c = rng.randrange(cols)
            set_anchor(r, c)

    _ensure_row_col_movable(mask, rng)
    while _count_true(mask) < min_anchors:
        r = rng.randrange(rows)
        c = rng.randrange(cols)
        mask[r][c] = True
        _ensure_row_col_movable(mask, rng)

    while _count_true(mask) > max_anchors:
        candidates = [(r, c) for r in range(rows) for c in range(cols) if mask[r][c]]
        if not candidates:
            break
        r, c = rng.choice(candidates)
        mask[r][c] = False
        _ensure_row_col_movable(mask, rng)

    while total - _count_true(mask) < 5:
        # release random anchor to free movable space
        candidates = [(r, c) for r in range(rows) for c in range(cols) if mask[r][c]]
        if not candidates:
            break
        r, c = rng.choice(candidates)
        mask[r][c] = False
        _ensure_row_col_movable(mask, rng)

    while _count_true(mask) < min_anchors:
        r = rng.randrange(rows)
        c = rng.randrange(cols)
        mask[r][c] = True
        _ensure_row_col_movable(mask, rng)

    return mask


def _flatten(grid: List[List[str]]) -> List[str]:
    return [color for row in grid for color in row]


def _manhattan(a: int, b: int, cols: int) -> int:
    return abs(a // cols - b // cols) + abs(a % cols - b % cols)


def _misplaced_count(start: List[str], solution: List[str]) -> int:
    return sum(1 for idx, color in enumerate(start) if color != solution[idx])


def _build_start_easy(solution: List[str], anchors: List[bool], rows: int, cols: int, rng: random.Random) -> List[str]:
    movable_indices = [idx for idx, is_anchor in enumerate(anchors) if not is_anchor]
    neighborhood: dict[int, List[int]] = {}
    for src in movable_indices:
        allowed = [dst for dst in movable_indices if _manhattan(src, dst, cols) <= 3]
        if src not in allowed:
            allowed.append(src)
        neighborhood[src] = allowed

    attempts = 0
    while attempts < 800:
        attempts += 1
        available = set(movable_indices)
        assignment: dict[int, int] = {}
        for src in rng.sample(movable_indices, len(movable_indices)):
            choices = [dst for dst in neighborhood[src] if dst in available]
            if not choices:
                break
            dst = rng.choice(choices)
            assignment[src] = dst
            available.remove(dst)
        if len(assignment) != len(movable_indices):
            continue
        start = solution[:]
        for src, dst in assignment.items():
            start[dst] = solution[src]
        if _misplaced_count(start, solution) >= 5:
            return start
    raise RuntimeError('Unable to generate easy start state with required displacement.')


def _build_start_advanced(solution: List[str], anchors: List[bool], rows: int, cols: int, rng: random.Random) -> List[str]:
    movable_indices = [idx for idx, is_anchor in enumerate(anchors) if not is_anchor]
    def quadrant_of(pos: int) -> Tuple[int, int]:
        row = pos // cols
        col = pos % cols
        quad_r = 0 if row < rows // 2 else 1
        quad_c = 0 if col < cols // 2 else 1
        return (quad_r, quad_c)

    available_quadrants = {quadrant_of(pos) for pos in movable_indices}
    attempts = 0
    while attempts < 500:
        attempts += 1
        shuffled_colors = [solution[idx] for idx in movable_indices]
        rng.shuffle(shuffled_colors)
        start = solution[:]
        for idx, dst in enumerate(movable_indices):
            start[dst] = shuffled_colors[idx]
        misplaced_positions = [idx for idx in movable_indices if start[idx] != solution[idx]]
        if len(misplaced_positions) < 5:
            continue
        quadrants_hit = {quadrant_of(pos) for pos in misplaced_positions}
        if quadrants_hit.issuperset(available_quadrants):
            return start
    raise RuntimeError('Unable to generate advanced start state satisfying constraints.')


def _generate_start(solution: List[List[str]], anchors_matrix: List[List[bool]], level_id: int,
                    rng: random.Random) -> List[List[str]]:
    rows = len(solution)
    cols = len(solution[0])
    solution_flat = _flatten(solution)
    anchors_flat = [cell for row in anchors_matrix for cell in row]
    if level_id <= 10:
        start_flat = _build_start_easy(solution_flat, anchors_flat, rows, cols, rng)
    else:
        start_flat = _build_start_advanced(solution_flat, anchors_flat, rows, cols, rng)
    return [start_flat[r * cols:(r + 1) * cols] for r in range(rows)]


def _generate_palette(solution: List[List[str]]) -> List[str]:
    unique = sorted({color for row in solution for color in row})
    return unique


def main() -> None:
    rng = random.Random(SEED)
    levels = []
    for level_id in range(1, 51):
        rows, cols = _choose_size(level_id, rng)
        anchors = _generate_anchor_mask(rows, cols, level_id, rng)
        solution = _generate_solution(rows, cols, level_id, rng)
        start = _generate_start(solution, anchors, level_id, rng)
        palette = _generate_palette(solution)
        level = {
            "id": level_id,
            "rows": rows,
            "cols": cols,
            "palette": palette,
            "solution": solution,
            "anchors": anchors,
            "start": start,
        }
        levels.append(level)

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
