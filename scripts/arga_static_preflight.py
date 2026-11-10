#!/usr/bin/env python3
"""Free, read-only Río Arga structural preflight; requires Python 3, not Flutter."""
from pathlib import Path
import math
import re

ROOT = Path(__file__).resolve().parents[1]
rules = (ROOT / "lib/arga_platform_rules.dart").read_text(encoding="utf-8")
main = (ROOT / "lib/main.dart").read_text(encoding="utf-8")
manifest = (ROOT / "pubspec.yaml").read_text(encoding="utf-8")

def numbers(name):
    match = re.search(r"const\s+" + re.escape(name) + r"\s*=\s*<double>\s*\[([^]]+)\]", rules)
    assert match, f"Missing list {name}"
    return [float(part.strip()) for part in match.group(1).split(",") if part.strip()]

easy, medium, hard = (numbers(name) for name in ("easyGaps", "mediumGaps", "hardGaps"))
widths, heights = numbers("widths"), numbers("heights")
assert all(len(values) == 8 for values in (easy, medium, hard, widths, heights))
assert "while(right<35900)" in rules and "36620.0-finishLeft" in rules
assert "const finishGap=65.0" in rules

# Introductory supports: contract checked against source to avoid stale simulation.
initial = re.findall(
    r"ArgaSurface\(\s*([\d.]+),\s*([\d.]+),\s*([\d.]+),\s*ArgaSurfaceKind\.(\w+)"
    r"(?:,\s*checkpoint\s*:\s*true)?", rules.split("static const surfaces =", 1)[1].split("];", 1)[0])
assert len(initial) == 9, "Introductory authored supports changed: update this preflight"
supports = []
for x, width, top, kind in initial:
    supports.append((float(x), float(width), float(top), kind, False))
# The first, sixth and ninth supports are checkpoint rocks in the authored sequence.
for i in (0, 5, 8):
    x, width, top, kind, _ = supports[i]
    supports[i] = (x, width, top, kind, True)
assert supports[0][0] == 0 and supports[-1][0] == 1920

kinds = ["rock", "log", "timber", "movingLog", "rock", "sinkingRock", "log", "rock"]
right = supports[-1][0] + supports[-1][1]
index = 0
tier_gaps = [[], [], []]
while right < 35900:
    segment = index // 8
    variant = (index + segment * 3) % 8
    tier = 0 if index < 24 else 1 if index < 80 else 2
    gap = (easy, medium, hard)[tier][(index + segment) % 8]
    checkpoint = index % 8 == 7
    width = widths[variant] + (80 if checkpoint else 0)
    kind = ("rock" if checkpoint else
            "movingLog" if tier == 2 and index % 5 == 2 else
            "sinkingRock" if tier == 2 and index % 7 == 4 else kinds[variant])
    x = right + gap
    supports.append((x, width, heights[variant], kind, checkpoint))
    tier_gaps[tier].append(gap)
    right = x + width
    index += 1
finish_left = right + 65
finish_width = max(520, 36620 - finish_left)
supports.append((finish_left, finish_width, 365, "rock", True))

jump_range = 169 * (2 * 423 / 960)
worst_gap = 0
for previous, current in zip(supports, supports[1:]):
    a_x, a_width, a_y, a_kind, _ = previous
    b_x, _, b_y, b_kind, checkpoint = current
    gap = b_x - (a_x + a_width)
    drift = (16 if a_kind == "movingLog" else 0) + (16 if b_kind == "movingLog" else 0)
    worst_gap = max(worst_gap, gap + drift)
    assert gap + drift <= jump_range - 20, f"Unreachable gap before x={b_x}"
    assert abs(a_y - b_y) <= 45, f"Excessive height delta before x={b_x}"
    if checkpoint:
        assert b_kind == "rock", f"Unsafe checkpoint at x={b_x}"
assert supports[-1][0] <= 36410 <= supports[-1][0] + supports[-1][1]
means = [sum(a) / len(a) for a in tier_gaps]
assert means[0] < means[1] < means[2], "Difficulty progression regressed"

active_images = [
    "arga_far_rc7_candidate.webp", "arga_mid_rc7_candidate.webp",
    "arga_far_wild_candidate.webp", "arga_mid_wild_candidate.webp",
    "arga_far_mill_candidate.webp", "arga_mid_mill_candidate.webp",
    "arga_supports_rc7_v1.webp", "arga_supports_rc7_v2_candidate.webp",
]
assert "- assets/images/arga_rc7/" in manifest
for name in active_images:
    path = ROOT / "assets/images/arga_rc7" / name
    assert path.is_file(), f"Missing visual resource: {path}"
    with path.open("rb") as stream:
        header = stream.read(12)
    assert header[:4] == b"RIFF" and header[8:12] == b"WEBP", f"Invalid WebP: {path}"
    assert name in main, f"Visual resource not referenced in painter: {name}"

assert "qaStage == 7" in main and "ArgaCourse" in main
print(f"OK Río Arga static preflight: {len(supports)} supports; "
      f"{sum(s[4] for s in supports)} checkpoints; max drift gap {worst_gap:.1f}px "
      f"of {jump_range:.1f}px; tiers {means[0]:.1f}/{means[1]:.1f}/{means[2]:.1f}; "
      f"{len(active_images)} WebP headers.")
print("NOTE: this is structural QA only; no Flutter compilation, render or gameplay verified.")
