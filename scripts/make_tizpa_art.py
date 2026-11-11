#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""ساخت لوگو/اسپلش/آیکون تیز پا + فشرده‌سازی پرتره هلیا — متن فارسی با لاله‌زار"""
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

G = "/home/z/my-project/game"
FZ = G + "/assets/fonts/Lalezar-Regular.ttf"

def fa_font(size):
    return ImageFont.truetype(FZ, size)

# ── لوگوی تیز پا (مربع، پس‌زمینه شفاف) ──
def make_logo():
    S = 640
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # سپر مسابقه
    d.polygon([(S*0.5, S*0.04), (S*0.94, S*0.18), (S*0.94, S*0.55),
               (S*0.5, S*0.96), (S*0.06, S*0.55), (S*0.06, S*0.18)],
              fill=(178, 24, 20, 255), outline=(250, 204, 40, 255), width=10)
    # خطوط سرعت
    for i, y in enumerate([0.30, 0.40, 0.50]):
        d.line([(S*0.14, S*y), (S*(0.30 - i*0.04), S*y)], fill=(250, 204, 40, 200), width=12)
    # متن
    f1 = fa_font(150)
    t = "تیز پا"
    bb = d.textbbox((0, 0), t, font=f1)
    d.text((S/2 - (bb[2]-bb[0])/2, S*0.30), t, font=f1, fill=(255, 244, 214, 255),
           stroke_width=8, stroke_fill=(60, 8, 6, 255))
    f2 = fa_font(52)
    t2 = "TIZ PA"
    bb2 = d.textbbox((0, 0), t2, font=f2)
    d.text((S/2 - (bb2[2]-bb2[0])/2, S*0.60), t2, font=f2, fill=(250, 204, 40, 255))
    img.save(G + "/assets/sprites/logo.png")
    # آیکون — همان سپر روی پس‌زمینه
    ic = Image.new("RGBA", (S, S), (24, 26, 34, 255))
    ic.alpha_composite(img)
    ic.resize((192, 192), Image.LANCZOS).save(G + "/icon.png")
    print("logo+icon OK")

# ── اسپلش (۱۲۸۰×۷۲۰ — روشن، آسمان روز، افق شهر) ──
def make_splash():
    W, H = 1280, 720
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    # آسمان گرادیان روشن
    top = (72, 130, 200); bot = (185, 210, 232)
    for y in range(H):
        t = y / H
        c = tuple(int(top[i] + (bot[i]-top[i])*t) for i in range(3))
        d.line([(0, y), (W, y)], fill=c)
    # سیلوئت شهر (برج آزادی و میلاد)
    base = 520
    city = (70, 78, 96)
    import random
    random.seed(7)
    x = 0
    while x < W:
        bw = random.randint(40, 110)
        bh = random.randint(40, 150)
        d.rectangle([x, base-bh, x+bw, base], fill=city)
        x += bw + random.randint(4, 18)
    # برج میلاد
    d.polygon([(880, base), (896, base), (893, base-230), (883, base-230)], fill=city)
    d.ellipse([858, base-268, 918, base-218], fill=city)
    # بنای آزادی (ساده)
    d.polygon([(180, base), (216, base-150), (232, base-150), (212, base)], fill=(90, 96, 112))
    d.polygon([(300, base), (264, base-150), (248, base-150), (268, base)], fill=(90, 96, 112))
    d.rectangle([212, base-186, 268, base-142], fill=(90, 96, 112))
    # جاده
    d.polygon([(0, base), (W, base), (W, H), (0, H)], fill=(52, 54, 60))
    d.line([(W/2, base), (W/2, H)], fill=(240, 226, 160), width=8)
    # ماشین سیلوئت اسپرت
    d.ellipse([W/2-150, H-190, W/2+150, H-90], fill=(178, 24, 20))
    d.rectangle([W/2-150, H-150, W/2+150, H-110], fill=(178, 24, 20))
    d.ellipse([W/2-70, H-200, W/2+70, H-140], fill=(140, 18, 15))
    for wx in (W/2-105, W/2+105):
        d.ellipse([wx-26, H-118, wx+26, H-66], fill=(20, 20, 22))
    # عنوان
    f = fa_font(132)
    t = "تیز پا"
    bb = d.textbbox((0, 0), t, font=f)
    d.text((W/2-(bb[2]-bb[0])/2 + 4, 150 + 4), t, font=f, fill=(40, 20, 8), stroke_width=2, stroke_fill=(40, 20, 8))
    d.text((W/2-(bb[2]-bb[0])/2, 146), t, font=f, fill=(255, 214, 64), stroke_width=6, stroke_fill=(90, 24, 10))
    f2 = fa_font(44)
    t2 = "مسابقه‌ی خیابانی تهران"
    bb2 = d.textbbox((0, 0), t2, font=f2)
    d.text((W/2-(bb2[2]-bb2[0])/2, 320), t2, font=f2, fill=(255, 255, 255))
    img.save(G + "/assets/sprites/splash.png", optimize=True)
    print("splash OK")

# ── فشرده‌سازی هلیا ──
def squeeze_helia():
    p = G + "/assets/sprites/helia_portrait.png"
    im = Image.open(p).convert("RGB")
    im.thumbnail((300, 525), Image.LANCZOS)
    im.save(G + "/assets/sprites/helia_portrait.png", optimize=True)
    print("helia squeezed:", os.path.getsize(p)//1024, "KB")

make_logo()
make_splash()
squeeze_helia()
