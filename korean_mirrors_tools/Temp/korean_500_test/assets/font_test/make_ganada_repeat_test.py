from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(r"G:\PC88-Mirror")
SOURCE = ROOT / "reference" / "mirrors_tools" / "GFX" / "b1-8x16_font.png"
OUTPUT = ROOT / "Temp" / "font_test" / "b1-8x16_ganada_repeat.png"
FONT = Path(r"C:\Windows\Fonts\malgunbd.ttf")

image = Image.open(SOURCE).convert("RGB")
font = ImageFont.truetype(str(FONT), 16)
pattern = "가나다라"

# FontGen.rb reads 16 columns x 6 rows, beginning at source row 2.
for row in range(6):
    for column in range(16):
        glyph_char = pattern[(row * 16 + column) % len(pattern)]

        rendered = Image.new("L", (32, 32), 0)
        draw = ImageDraw.Draw(rendered)
        draw.text((4, 4), glyph_char, font=font, fill=255)
        bounds = rendered.getbbox()
        glyph = rendered.crop(bounds)

        # Compress the Korean glyph horizontally into the target 8x16 cell.
        glyph = glyph.resize((8, min(16, glyph.height)), Image.Resampling.LANCZOS)
        glyph = glyph.point(lambda pixel: 255 if pixel >= 128 else 0)

        cell = Image.new("RGB", (8, 16), (0, 0, 0))
        y_offset = (16 - glyph.height) // 2
        cell.paste((255, 255, 255), (0, y_offset), glyph)
        image.paste(cell, (column * 8, (row + 2) * 16))

image.save(OUTPUT)
print(f"created {OUTPUT}")
print(f"size={image.size} mode={image.mode}")
