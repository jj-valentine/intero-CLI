#!/usr/bin/env python3
"""Build Intero Mono from Hack Nerd Font Mono.

Phase 1: metadata rename only (all glyphs copied as-is).
Phase 3 (future): per-glyph scaling for chosen icons.
"""

import argparse
import os
import sys
from pathlib import Path

try:
    from fontTools.ttLib import TTFont
except ImportError:
    print("fonttools required: pip3 install fonttools", file=sys.stderr)
    sys.exit(1)

FAMILY = "Intero Mono"
VERSION = "Version 1.000"

VARIANTS = {
    "Regular":    {"subfamily": "Regular",     "ps": "InteroMono-Regular"},
    "Bold":       {"subfamily": "Bold",        "ps": "InteroMono-Bold"},
    "Italic":     {"subfamily": "Italic",      "ps": "InteroMono-Italic"},
    "BoldItalic": {"subfamily": "Bold Italic", "ps": "InteroMono-BoldItalic"},
}

# Glyph transforms
# target_height: desired height in font units (FA reference ~1400)
# target_cy: vertical center (709 = NF default, lower = drop glyph down)
# mode: "uniform" (scale both axes), "y_only", "fit" (uniform unless it overflows cell width)
GLYPH_TRANSFORMS = {
    0xE315: {"target_height": 1400, "mode": "uniform"},                        # weather-lightning
    0x00B7: {"target_height": 220, "target_cy": 745, "center_x": True, "mode": "uniform"},  # middle dot — match HNFM vertical center
    0xE00A: {"target_height": 2200, "target_cy": 746, "mode": "uniform"},      # pom-external_interruption (model icon)
    0xF07B: {"target_height": 1800, "target_cy": 746, "mode": "uniform"},       # fa-folder
    0xF115: {"target_height": 1800, "target_cy": 746, "mode": "uniform"},      # fa-folder_open_o
    0xF0A1E: {"target_height": 2200, "target_cy": 746, "mode": "uniform"},     # md-microsoft_visual_studio_code
    0xF1897: {"target_height": 2400, "target_cy": 746, "mode": "uniform"},     # md-forest_outline (worktree)
}

# ── Bulk icon scaling ─────────────────────────────────────────────
BULK_ICON_MIN_HEIGHT = 1800
BULK_ICON_CENTER_Y = 709
BULK_ICON_MODE = "uniform"

NF_ICON_RANGES = [
    (0x23FB, 0x23FE),   # IEC Power Symbols
    (0x2B58, 0x2B58),   # IEC Power Symbol
    (0xE000, 0xE00A),   # Pomicons
    # Powerline (E0A0-E0D4) deliberately excluded — separators, not icons
    (0xE200, 0xE2A9),   # Font Awesome Extension
    (0xE300, 0xE3E3),   # Weather Icons
    (0xE5FA, 0xE6B5),   # Seti-UI + Custom
    (0xE700, 0xE7C5),   # Devicons
    (0xEA60, 0xEBC9),   # Codicons
    (0xF000, 0xF2FF),   # Font Awesome
    (0xF300, 0xF372),   # Font Logos
    (0xF400, 0xF533),   # Octicons
    (0xF0001, 0xF1AF0), # Material Design Icons
]


def is_nf_icon(codepoint):
    return any(start <= codepoint <= end for start, end in NF_ICON_RANGES)


PRESERVE_IDS = {0, 13, 14}


def update_names(font, subfamily, ps_name):
    full_name = f"{FAMILY} {subfamily}"
    unique_id = f"{FAMILY} {subfamily} 1.0"
    name_updates = {
        1: FAMILY,
        2: subfamily,
        3: unique_id,
        4: full_name,
        5: VERSION,
        6: ps_name,
        16: FAMILY,
        17: subfamily,
    }
    name_table = font["name"]
    for record in name_table.names:
        if record.nameID in PRESERVE_IDS:
            continue
        if record.nameID in name_updates:
            record.string = name_updates[record.nameID]


def apply_transforms(font, bulk_scale=True, verbose=False):
    from fontTools.ttLib.tables.ttProgram import Program
    from fontTools.pens.boundsPen import BoundsPen
    from fontTools.pens.recordingPen import RecordingPointPen
    from fontTools.pens.transformPen import TransformPointPen
    from fontTools.pens.ttGlyphPen import TTGlyphPointPen
    from fontTools.misc.transform import Transform

    glyf = font["glyf"]
    hmtx = font["hmtx"]
    cmap = font.getBestCmap()

    def transform_glyph(glyph_name, spec):
        glyph = glyf[glyph_name]
        bp = BoundsPen(glyf)
        glyph.draw(bp, glyf)
        bounds = bp.bounds
        if not bounds:
            return None

        x_min, y_min, x_max, y_max = bounds
        cur_height = y_max - y_min
        if cur_height <= 0:
            return None
        mode = spec.get("mode", "fit")

        target = spec.get("target_height", cur_height)
        sy = target / cur_height
        sx = sy if mode == "uniform" else 1.0
        if mode == "fit":
            cur_width = x_max - x_min
            adv_width = hmtx.metrics[glyph_name][0]
            sx = 1.0 if cur_width * sy > adv_width else sy

        cx = (x_min + x_max) / 2
        cy = (y_min + y_max) / 2
        target_cy = spec.get("target_cy", 709)
        adv_width = hmtx.metrics[glyph_name][0]
        target_cx = adv_width / 2 if spec.get("center_x") else cx

        t = Transform()
        t = t.translate(target_cx, target_cy)
        t = t.scale(sx, sy)
        t = t.translate(-cx, -cy)

        rec = RecordingPointPen()
        glyph.drawPoints(rec, glyf)

        ttpen = TTGlyphPointPen(None)
        tpen = TransformPointPen(ttpen, t)
        rec.replay(tpen)

        new_glyph = ttpen.glyph()
        new_glyph.program = Program()
        new_glyph.program.fromBytecode(b"")
        new_glyph.recalcBounds(glyf)
        glyf[glyph_name] = new_glyph

        return (cur_height, target, sx, sy)

    # ── Phase 1: Bulk-scale NF icons below threshold ──────────
    if bulk_scale and BULK_ICON_MIN_HEIGHT > 0:
        bulk_count = 0
        bulk_already_large = 0
        scale_factors = []

        for codepoint, glyph_name in sorted(cmap.items()):
            if not is_nf_icon(codepoint):
                continue
            if codepoint in GLYPH_TRANSFORMS:
                continue

            glyph = glyf[glyph_name]
            bp = BoundsPen(glyf)
            glyph.draw(bp, glyf)
            if not bp.bounds:
                continue
            cur_height = bp.bounds[3] - bp.bounds[1]
            if cur_height >= BULK_ICON_MIN_HEIGHT:
                bulk_already_large += 1
                continue

            spec = {
                "target_height": BULK_ICON_MIN_HEIGHT,
                "target_cy": BULK_ICON_CENTER_Y,
                "mode": BULK_ICON_MODE,
            }
            result = transform_glyph(glyph_name, spec)
            if result:
                bulk_count += 1
                scale_factors.append(result[3])

        if verbose:
            print(f"  Bulk: {bulk_count} scaled to {BULK_ICON_MIN_HEIGHT}, "
                  f"{bulk_already_large} already large enough")
            if scale_factors:
                sf = sorted(scale_factors)
                print(f"    Scale factors: min={sf[0]:.2f} "
                      f"max={sf[-1]:.2f} "
                      f"median={sf[len(sf)//2]:.2f}")

    # ── Phase 2: Per-glyph overrides ──────────────────────────
    for codepoint, spec in GLYPH_TRANSFORMS.items():
        glyph_name = cmap.get(codepoint)
        if not glyph_name:
            print(f"  WARNING: U+{codepoint:04X} not in cmap, skipping")
            continue

        result = transform_glyph(glyph_name, spec)
        if result and verbose:
            old_h, new_h, sx, sy = result
            print(f"  U+{codepoint:04X} ({glyph_name}): {old_h:.0f} -> {new_h:.0f} "
                  f"(sx={sx:.2f} sy={sy:.2f})")


def build_variant(variant_name, info, source_dir, output_dir,
                   bulk_scale=True, verbose=False):
    source = source_dir / f"HackNerdFontMono-{variant_name}.ttf"
    output = output_dir / f"InteroMono-{variant_name}.ttf"

    if not source.exists():
        print(f"  SKIP: {source.name} not found")
        return False

    font = TTFont(str(source))
    update_names(font, info["subfamily"], info["ps"])
    apply_transforms(font, bulk_scale=bulk_scale, verbose=verbose)
    font.save(str(output))
    font.close()
    print(f"  {source.name} -> {output.name}")
    return True


def main():
    parser = argparse.ArgumentParser(description="Build Intero Mono font family")
    script_dir = Path(__file__).resolve().parent
    parser.add_argument("--source-dir", type=Path,
                        default=script_dir.parent / "fonts/source")
    parser.add_argument("--output-dir", type=Path,
                        default=Path.home() / "Library/Fonts")
    parser.add_argument("--verbose", "-v", action="store_true")
    parser.add_argument("--no-bulk-scale", action="store_true",
                        help="Disable bulk NF icon scaling")
    args = parser.parse_args()

    print(f"Building Intero Mono from HackNerdFontMono...")
    built = 0
    for variant_name, info in VARIANTS.items():
        if build_variant(variant_name, info, args.source_dir, args.output_dir,
                         bulk_scale=not args.no_bulk_scale, verbose=args.verbose):
            built += 1

    print(f"\nBuilt {built}/{len(VARIANTS)} variants.")
    print("\nRestart iTerm2 (Cmd+Q, reopen) to pick up changes.")


if __name__ == "__main__":
    main()
