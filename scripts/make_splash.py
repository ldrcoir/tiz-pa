#!/usr/bin/env python3
# اسپلش بوت بازی — لوگوی بوقی/ایماروید روی گرادیان گرم آسفالت
# خروجی: game/assets/sprites/splash.png (1280x720) — لوگوی گودوت دیگر هرگز دیده نمی‌شود
from PIL import Image, ImageDraw, ImageFilter
import os

ROOT = "/home/z/my-project/game"
W, H = 1280, 720

# گرادیان عمودی گرم: قهوه‌ای آسفالتی تیره → دودی
img = Image.new("RGB", (W, H))
top = (44, 26, 16)
mid = (26, 15, 10)
bot = (14, 9, 8)
d = ImageDraw.Draw(img)
for y in range(H):
    t = y / (H - 1)
    if t < 0.55:
        u = t / 0.55
        c = tuple(int(top[i] + (mid[i] - top[i]) * u) for i in range(3))
    else:
        u = (t - 0.55) / 0.45
        c = tuple(int(mid[i] + (bot[i] - mid[i]) * u) for i in range(3))
    d.line([(0, y), (W, y)], fill=c)

# هالهٔ گرم پشت لوگو
glow = Image.new("L", (W, H), 0)
gd = ImageDraw.Draw(glow)
gd.ellipse([W // 2 - 420, 150, W // 2 + 420, 570], fill=70)
glow = glow.filter(ImageFilter.GaussianBlur(120))
warm = Image.new("RGB", (W, H), (120, 62, 18))
img = Image.composite(warm, img, glow)

# لوگوی رسمی وسط کادر
logo = Image.open(os.path.join(ROOT, "assets/sprites/logo.png")).convert("RGBA")
lw = 880
lh = int(logo.height * lw / logo.width)
logo = logo.resize((lw, lh), Image.LANCZOS)
# سایهٔ نرم زیر لوگو
sh = Image.new("RGBA", (W, H), (0, 0, 0, 0))
shadow = Image.new("RGBA", (lw, lh), (0, 0, 0, 140))
sh.paste(shadow, ((W - lw) // 2 + 6, (H - lh) // 2 + 10), shadow)
sh = sh.filter(ImageFilter.GaussianBlur(14))
img = Image.alpha_composite(img.convert("RGBA"), sh)
img.alpha_composite(logo, ((W - lw) // 2, (H - lh) // 2))

# نوار قرمز استودیویی پایین
d = ImageDraw.Draw(img)
d.rectangle([0, H - 26, W, H - 20], fill=(196, 32, 24))
d.rectangle([0, H - 20, W, H], fill=(10, 7, 6))

out = os.path.join(ROOT, "assets/sprites/splash.png")
img.convert("RGB").save(out, "PNG", optimize=True)
print("saved", out, img.size, os.path.getsize(out) // 1024, "KB")
