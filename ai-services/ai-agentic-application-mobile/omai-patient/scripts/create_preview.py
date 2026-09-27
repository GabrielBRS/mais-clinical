"""Compose a presentation image from actual native Qt smoke captures."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

root = Path(__file__).resolve().parents[1]
canvas = Image.new("RGB", (1380, 840), "#EAF1F0")
draw = ImageDraw.Draw(canvas)
regular = ImageFont.truetype("C:/Windows/Fonts/segoeui.ttf", 18)
bold = ImageFont.truetype("C:/Windows/Fonts/seguisb.ttf", 34)
small = ImageFont.truetype("C:/Windows/Fonts/segoeui.ttf", 14)
draw.text((48, 30), "OMAI Patient", font=bold, fill="#173C40")
draw.text((48, 82), "Seu cuidado, conectado.", font=regular, fill="#637D80")
draw.text((1000, 48), "QT QUICK  /  C++20", font=small, fill="#12776B")
screens = [("03-home", "01  Início"), ("15-prescription", "02  Prescrição digital"),
           ("18-privacy", "03  Você no controle"), ("39-home", "04  Modo escuro")]
for index, (name, label) in enumerate(screens):
    x = 48 + index * 330
    image = Image.open(root / "build" / "screenshots" / (name + ".bmp")).convert("RGB")
    image.thumbnail((294, 616), Image.Resampling.LANCZOS)
    draw.rounded_rectangle((x - 5, 135, x + 299, 765), radius=28, fill="#CFDEDA")
    mask = Image.new("L", image.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, image.width, image.height), radius=24, fill=255)
    canvas.paste(image, (x, 141), mask)
    draw.text((x, 781), label, font=regular, fill="#173C40")
canvas.save(root / "docs" / "preview.png")
