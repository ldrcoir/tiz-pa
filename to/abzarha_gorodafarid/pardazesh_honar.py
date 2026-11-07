#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# پس‌پردازشِ هنرِ گردآفرید — جداسازی از پس‌زمینهٔ سبز، برش، هم‌اندازه‌سازی
# + ساخت دکمه‌های لمسی
import numpy as np
from PIL import Image, ImageFilter, ImageDraw
import os, json

KH = "/tmp/honar"
OUT = "/home/z/my-project/ema/gorodafarid/assets/honar"
os.makedirs(OUT, exist_ok=True)

def key_sabz(tasvir: Image.Image) -> Image.Image:
    """حذف پس‌زمینهٔ تک‌رنگ (سبز یا فیروزه‌ای) با نمونه‌گیری از حاشیه —
    سیلاب از مرزها + حذفِ هستهٔ سخت در همه‌جا؛ سبزِ داخلِ بدن می‌ماند"""
    tasvir = tasvir.convert("RGBA")
    a = np.array(tasvir).astype(np.int16)
    h, w = a.shape[:2]
    rgb = a[..., :3].astype(np.float64)
    # نمونهٔ رنگ پس‌زمینه از حلقهٔ حاشیه
    halghe = np.concatenate([rgb[:18].reshape(-1, 3), rgb[-18:].reshape(-1, 3),
                             rgb[:, :18].reshape(-1, 3), rgb[:, -18:].reshape(-1, 3)])
    moraj = np.median(halghe, axis=0)
    fas = np.linalg.norm(rgb - moraj, axis=2)
    mask_sokht = fas < 62.0          # هستهٔ سخت — همه‌جا حذف می‌شود
    mask_narm = fas < 128.0          # ناحیهٔ سیلاب
    # سیلاب از مرزها در ناحیهٔ نرم
    dida = np.zeros((h, w), dtype=bool)
    stack = []
    for x in range(w):
        for y in (0, h - 1):
            if mask_narm[y, x] and not dida[y, x]:
                stack.append((y, x)); dida[y, x] = True
    for y in range(h):
        for x in (0, w - 1):
            if mask_narm[y, x] and not dida[y, x]:
                stack.append((y, x)); dida[y, x] = True
    while stack:
        y, x = stack.pop()
        for ny, nx in ((y-1,x),(y+1,x),(y,x-1),(y,x+1)):
            if 0 <= ny < h and 0 <= nx < w and mask_narm[ny, nx] and not dida[ny, nx]:
                dida[ny, nx] = True
                stack.append((ny, nx))
    hazf = dida | mask_sokht
    alfa = a[..., 3].astype(np.float64)
    alfa[hazf] = 0.0
    # لبهٔ نرم
    alfa_img = Image.fromarray(alfa.astype(np.uint8))
    alfa_narm = alfa_img.filter(ImageFilter.GaussianBlur(1.0))
    a[..., 3] = np.array(alfa_narm)
    kh = Image.fromarray(a.astype(np.uint8))
    # برشِ اندازهٔ محتوا
    sandogh = kh.getbbox()
    if sandogh:
        x0, y0, x1, y1 = sandogh
        x0 = max(0, x0 - 6); y0 = max(0, y0 - 6)
        x1 = min(kh.width, x1 + 6); y1 = min(kh.height, y1 + 6)
        kh = kh.crop((x0, y0, x1, y1))
    return kh

def amaliyat_khas(tasvir: Image.Image, nam: str) -> Image.Image:
    """عملیاتِ ویژهٔ هر قطعه"""
    if nam == "div_sefid":
        # پاک کردن واترمارکِ گوشهٔ پایین راست
        a = np.array(tasvir)
        h, w = a.shape[:2]
        a[int(h * 0.86):, int(w * 0.66):, 3] = 0
        tasvir = Image.fromarray(a)
    if nam == "dargah":
        # حذف نوارِ زمینِ پایین
        a = np.array(tasvir)
        h = a.shape[0]
        a[int(h * 0.945):, :, 3] = 0
        tasvir = Image.fromarray(a)
    return tasvir

def hamandaze(tasvir: Image.Image, buland: int) -> Image.Image:
    """هم‌اندازه‌سازی بر پایهٔ بلندی با حفظ نسبت"""
    nesbat = buland / tasvir.height
    return tasvir.resize((max(1, int(tasvir.width * nesbat)), buland), Image.LANCZOS)

# ── کاراکترها و اشیاء (کلید سبز) ──
karha = [
    ("gordafarid_idle", "gordafarid_doid", 250),
    ("gordafarid_zadan", "gordafarid_zadan", 250),
    ("gordafarid_tirandaz", "gordafarid_tirandaz", 250),
    ("savare", "savare", 270),
    ("asb", "asb", 210),
    ("sarbaz_turan", "sarbaz", 230),
    ("div_bozorg", "div", 330),
    ("div_kuchak", "kuchak", 120),
    ("div_sefid", "div_sefid", 470),
    ("enar", "enar", 84),
    ("senobar", "senobar", 390),
    ("dargah", "dargah", 620),
]
manijest = {}
for manba, maghsad, buland in karha:
    masir = f"{KH}/{manba}.png"
    if not os.path.exists(masir):
        print("نبود:", manba); continue
    t = Image.open(masir)
    t = key_sabz(t)
    t = amaliyat_khas(t, manba)
    t = hamandaze(t, buland)
    t.save(f"{OUT}/{maghsad}.png")
    manijest[maghsad] = [t.width, t.height]
    print("پردازش شد:", maghsad, t.size)

# ── پس‌زمینه‌ها (بدون کلید؛ فقط مات‌کردنِ بالای کوه و شهر) ──
def mahv_bala(tasvir, darsad, maghsad):
    a = np.array(tasvir.convert("RGBA")).astype(np.float64)
    h = a.shape[0]
    marz = int(h * darsad)
    for y in range(marz):
        n = 1.0 - y / marz          # بالا=۰، پایینِ ناحیه=۱
        a[y, :, 3] *= (n * n)
    Image.fromarray(a.astype(np.uint8)).save(f"{OUT}/{maghsad}.png")
    manijest[maghsad] = [tasvir.width, tasvir.height]
    print("پردازش شد:", maghsad)

for nam, darsad in [("aseman", 0.0), ("kuh", 0.52), ("shahr", 0.34)]:
    masir = f"{KH}/{nam}.png"
    if os.path.exists(masir):
        t = Image.open(masir)
        if darsad > 0:
            mahv_bala(t, darsad, nam)
        else:
            t.convert("RGBA").save(f"{OUT}/{nam}.png")
            manijest[nam] = [t.width, t.height]
            print("پردازش شد:", nam)
# کاشی — بدون دست‌کاری
if os.path.exists(f"{KH}/kash.png"):
    Image.open(f"{KH}/kash.png").convert("RGBA").save(f"{OUT}/kash.png")
    manijest["kash"] = [1024, 1024]
    print("پردازش شد: kash")

# ── دکمه‌های لمسی (۹۶×۹۶، دایرهٔ کج‌دار با نماد) ──
def dokme(nam, rang, jorat):
    img = Image.new("RGBA", (96, 96), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse((4, 4, 92, 92), fill=(24, 14, 16, 165), outline=rang, width=5)
    if jorat == "chap":
        d.polygon([(62, 28), (62, 68), (30, 48)], fill=rang)
    elif jorat == "rast":
        d.polygon([(34, 28), (34, 68), (66, 48)], fill=rang)
    elif jorat == "parsh":
        d.polygon([(48, 22), (70, 52), (56, 52), (56, 74), (40, 74), (40, 52), (26, 52)], fill=rang)
    elif jorat == "shemshir":
        d.line((30, 66, 62, 34), fill=rang, width=7)
        d.line((26, 52, 44, 70), fill=rang, width=6)
        d.line((60, 30, 68, 38), fill=rang, width=5)
    elif jorat == "kaman":
        d.arc((26, 22, 62, 74), -70, 70, fill=rang, width=6)
        d.line((44, 26, 44, 70), fill=(240, 230, 210, 220), width=3)
        d.line((44, 48, 72, 48), fill=rang, width=5)
        d.polygon([(66, 42), (78, 48), (66, 54)], fill=rang)
    elif jorat == "savari":
        d.ellipse((30, 30, 52, 50), fill=rang)
        d.rectangle((28, 48, 70, 56), fill=rang)
        d.line((34, 56, 30, 72), fill=rang, width=6)
        d.line((64, 56, 68, 72), fill=rang, width=6)
    img.save(f"{OUT}/{nam}.png")
    manijest[nam] = [96, 96]
    print("دکمه:", nam)

dokme("dokme_chap", (255, 214, 120, 255), "chap")
dokme("dokme_rast", (255, 214, 120, 255), "rast")
dokme("dokme_parsh", (140, 230, 160, 255), "parsh")
dokme("dokme_shemshir", (255, 150, 140, 255), "shemshir")
dokme("dokme_kaman", (150, 200, 255, 255), "kaman")
dokme("dokme_savari", (220, 180, 255, 255), "savari")

with open(f"{OUT}/manifest.json", "w") as f:
    json.dump(manijest, f, ensure_ascii=False, indent=1)
print("پایانِ پس‌پردازش —", len(manijest), "قطعه")
