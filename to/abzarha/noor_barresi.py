#!/usr/bin/env python3
# کنترل کیفی اسکرین‌شات‌ها + ساخت PDF کتابچه
import glob
import os

from PIL import Image

DIR = "/home/z/my-project/download/screenshots_modern_2d"
PDF = "/home/z/my-project/download/ketabche_sehgane_noor.pdf"

print("=== barresi kifi ===")
ok = True
for f in sorted(glob.glob(os.path.join(DIR, "*.png"))):
    im = Image.open(f).convert("RGB")
    w, h = im.size
    px = im.resize((160, 90))
    data = list(px.getdata())
    n = len(data)
    mean = tuple(sum(c[i] for c in data) / n for i in range(3))
    sefid = sum(1 for c in data if c[0] > 240 and c[1] > 240 and c[2] > 240) / n
    siyah = sum(1 for c in data if c[0] < 12 and c[1] < 12 and c[2] < 12) / n
    rangin = sum(1 for c in data if max(c) - min(c) > 30) / n
    name = os.path.basename(f)
    halat = "OK"
    if w != 1280 or h != 720:
        halat = "BAD_SIZE"
        ok = False
    if siyah > 0.92:
        halat = "KHALI_SIYAH"
        ok = False
    if rangin < 0.03:
        halat = "BI_RANG"
        ok = False
    print(f"{name:20s} {w}x{h} mean=({mean[0]:.0f},{mean[1]:.0f},{mean[2]:.0f}) rangin={rangin:.2f} siyah={siyah:.2f} -> {halat}")

print("=== sakht PDF ===")
pages = sorted(glob.glob(os.path.join(DIR, "sahife_*.png")))
if len(pages) == 4:
    ims = [Image.open(p).convert("RGB") for p in pages]
    ims[0].save(PDF, save_all=True, append_images=ims[1:], resolution=96.0, title="Sehgane Noor")
    print("PDF:", PDF, os.path.getsize(PDF), "bytes", "pages:", len(ims))
else:
    print("PDF NASHOD — saf ha:", len(pages))
    ok = False

print("NAKI" if ok else "MOSHKEL")
