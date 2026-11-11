#!/usr/bin/env python3
# ═══════════════════════════════════════════════════════════
#  بازرسیِ ورودی‌های اژدها — ورقِ کوچکِ همهٔ ۹ عکس برای چشمِ من
# ═══════════════════════════════════════════════════════════
from pathlib import Path
from PIL import Image

JA = Path("/home/z/my-project/to/ezhdeha")
esmha = ["ezhdeha_asli", "ezhdeha_jadugar", "ezhdeha_polis", "ezhdeha_faza",
         "ezhdeha_daryayi", "ezhdeha_shah", "ezhdeha_zemestani",
         "ezhdeha_ranande", "ezhdeha_ninja"]

sakht = 3  # ۳ ستون
sator = (len(esmha) + sakht - 1) // sakht
K = 340
varagh = Image.new("RGB", (sakht * K, sator * K), (20, 18, 31))
for i, esm in enumerate(esmha):
    aks = Image.open(JA / "kham" / f"{esm}.png").convert("RGB")
    aks.thumbnail((K - 10, K - 10))
    x = (i % sakht) * K + (K - aks.width) // 2
    y = (i // sakht) * K + (K - aks.height) // 2
    varagh.paste(aks, (x, y))
varagh.save(JA / "qc_vorudi.jpg", quality=88)
print("ok:", JA / "qc_vorudi.jpg", varagh.size)
