"""Build a full-bleed square app icon for iOS / PWA home screen.

Source mockups often have transparent or black padding and pre-rounded corners.
iOS fills transparency with black and applies its own mask — use edge-to-edge art.
"""

from __future__ import annotations

import os
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets" / "icon" / "app_icon.png"
OUTPUT = ROOT / "assets" / "icon" / "app_icon_home.png"
SIZE = 1024


def _content_bbox(im: Image.Image) -> tuple[int, int, int, int]:
    pixels = im.load()
    w, h = im.size
    minx, miny, maxx, maxy = w, h, 0, 0
    found = False

    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            if a < 20:
                continue
            if r < 30 and g < 30 and b < 30:
                continue
            if r > 240 and g > 240 and b > 240:
                continue
            found = True
            minx = min(minx, x)
            miny = min(miny, y)
            maxx = max(maxx, x)
            maxy = max(maxy, y)

    if not found:
        return 0, 0, w - 1, h - 1
    return minx, miny, maxx, maxy


def _sample_background_blue(im: Image.Image) -> tuple[int, int, int]:
    w, h = im.size
    samples: list[tuple[int, int, int]] = []
    for y in range(int(h * 0.08), int(h * 0.35)):
        for x in range(int(w * 0.15), int(w * 0.85)):
            r, g, b, a = im.getpixel((x, y))
            if a < 200:
                continue
            if b > r + 15 and b > g + 5:
                samples.append((r, g, b))
    if not samples:
        return 74, 163, 220
    r = sum(s[0] for s in samples) // len(samples)
    g = sum(s[1] for s in samples) // len(samples)
    b = sum(s[2] for s in samples) // len(samples)
    return r, g, b


def build_home_icon(source: Path = SOURCE, output: Path = OUTPUT) -> Path:
    im = Image.open(source).convert("RGBA")
    bbox = _content_bbox(im)
    crop = im.crop(bbox)

    bg = _sample_background_blue(crop)
    canvas = Image.new("RGB", (SIZE, SIZE), bg)

    # Zoom in so the blue tile reaches every corner of the square canvas.
    zoom = 1.18
    zoomed_w = int(SIZE * zoom)
    zoomed_h = int(SIZE * zoom)
    scaled = crop.resize((zoomed_w, zoomed_h), Image.Resampling.LANCZOS)

    layer = Image.new("RGBA", (SIZE, SIZE), (*bg, 255))
    offset = ((SIZE - zoomed_w) // 2, (SIZE - zoomed_h) // 2)
    layer.paste(scaled, offset, scaled)
    canvas = Image.alpha_composite(
        canvas.convert("RGBA"),
        layer,
    ).convert("RGB")

    output.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(output, "PNG", optimize=True)
    return output


if __name__ == "__main__":
    out = build_home_icon()
    print(f"Wrote {out} ({os.path.getsize(out)} bytes)")
