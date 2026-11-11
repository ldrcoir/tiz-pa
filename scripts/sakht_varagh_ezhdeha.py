#!/usr/bin/env python3
# ═══════════════════════════════════════════════════════════════════
#  پایپ‌لاینِ کاملِ اژدها — «عکسِ زیبای AI ← ورقِ فریم ← انیمیشنِ بازی»
#  ۹ کاستوم × ۴ حرکت (ist/doid/parsh/dam) = ۳۶ انیمیشن
#  خروجی: ورقِ PNG برای گودوت + SpriteFrames tres + WebP برای کارگاه + GIF
# ═══════════════════════════════════════════════════════════════════
import json
import math
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw

JA = Path("/home/z/my-project/to/ezhdeha")
KHAM = JA / "kham"
HONAR = JA / "assets" / "honar"
KARGAH = JA / "kargah_data"
for p in (HONAR, KARGAH):
    p.mkdir(parents=True, exist_ok=True)

FRAME = 256     # اندازهٔ هر فریم
TABE = 248      # خطِ کفِ پا
BOLANDI = 218   # بلندیِ کاراکتر در فریم (هم‌اندازه‌سازیِ همهٔ کاستوم‌ها)

# نامِ فارسیِ کاستوم‌ها (برای کارگاه و گزارش)
ESMHA = {
    "ezhdeha_asli":       ("عادی", False),
    "ezhdeha_jadugar":    ("جادوگر", True),      # آینه — رو به چپ بود
    "ezhdeha_polis":      ("پلیس", False),
    "ezhdeha_faza":       ("فضانورد", False),
    "ezhdeha_daryayi":    ("دزد دریایی", False),
    "ezhdeha_shah":       ("شاه", False),
    "ezhdeha_zemestani":  ("زمستانی", False),
    "ezhdeha_ranande":    ("مسابقه‌ای", False),
    "ezhdeha_ninja":      ("نینجا", False),
}
# ساختارِ حرکت‌ها: نام → (تعدادِ فریم، سرعتِ fps، حلقه)
HAREKAT = {"ist": (2, 6, True), "doid": (4, 12, True),
           "parsh": (3, 8, True), "dam": (2, 6, True)}


# ─────────────────────────── ابزارهای پایه (از پایپ‌لاینِ هلیا) ───────────────────────────
def kalid_sabz(img: Image.Image) -> Image.Image:
    """جداسازی از پس‌زمینهٔ سبز: رنگِ پس‌زمینه از گوشه‌ها نمونه‌برداری می‌شود"""
    arr = np.array(img.convert("RGB")).astype(int)
    gosha = np.concatenate([arr[:12, :12].reshape(-1, 3), arr[:12, -12:].reshape(-1, 3),
                            arr[-12:, :12].reshape(-1, 3), arr[-12:, -12:].reshape(-1, 3)])
    rang_bg = np.median(gosha, axis=0)
    fasele = np.sqrt(((arr - rang_bg) ** 2).sum(axis=2))
    alpha = np.clip((fasele - 30.0) / 55.0 * 255.0, 0, 255).astype(np.uint8)
    # سایهٔ نرمِ زیرِ پا هم پس‌زمینه است: سبزِ تیره‌تر از بوم = پاک
    tariki = (arr.sum(axis=2) < rang_bg.sum() - 55) & (arr[..., 1] >= arr[..., 0])
    zirin = np.zeros(arr.shape[:2], bool)
    zirin[int(arr.shape[0] * 0.78):, :] = True   # ناحیهٔ پایینِ عکس
    alpha[tariki & zirin] = 0
    # despill: بازتابِ سبزِ پس‌زمینه روی لبه‌ها
    lab = arr.copy()
    lab[..., 1] = np.minimum(arr[..., 1], np.maximum(arr[..., 0], arr[..., 2]) + 24)
    lab = (lab * (alpha[..., None] / 255.0) + rang_bg * (1.0 - alpha[..., None] / 255.0)).astype(np.uint8)
    out = np.dstack([lab, alpha])
    tasvir = Image.fromarray(out)
    a = np.array(tasvir)[..., 3]
    a[a < 45] = 0
    tasvir.putalpha(Image.fromarray(a))
    return tasvir


def brot(img: Image.Image, bolandi: int) -> Image.Image:
    """برشِ تنگ دور کاراکتر + هم‌اندازه‌سازی"""
    m = np.array(img)[..., 3] > 12
    ys, xs = np.where(m)
    if len(xs) == 0:
        raise RuntimeError("asparait peyda nashod")
    img = img.crop((int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1))
    k = bolandi / img.height
    return img.resize((max(1, round(img.width * k)), bolandi), Image.LANCZOS)


def gharar(asparait: Image.Image, dx=0, dy=0, sx=1.0, sy=1.0, zaviye=0.0) -> Image.Image:
    """فریمِ ۲۵۶×۲۵۶: کاراکتر با کش‌وقوس و چرخش، کفِ پا روی خطِ زمین"""
    safhe = Image.new("RGBA", (FRAME, FRAME), (0, 0, 0, 0))
    w, h = asparait.size
    if sx != 1.0 or sy != 1.0:
        asparait = asparait.resize((max(1, round(w * sx)), max(1, round(h * sy))), Image.LANCZOS)
        w, h = asparait.size
    if zaviye != 0.0:
        asparait = asparait.rotate(-zaviye, expand=True, resample=Image.BICUBIC)
        w, h = asparait.size
    x = (FRAME - w) // 2 + dx
    y = TABE - h + dy
    safhe.alpha_composite(asparait, (int(x), int(y)))
    return safhe


def ghobar(safhe: Image.Image, jahat=1) -> None:
    """پافِ گردوخاکِ پشتِ پا برای فریم‌های تماسِ دویدن"""
    d = ImageDraw.Draw(safhe)
    paein = TABE - 8
    for cx, cy, r, a in [(FRAME // 2 - 34 * jahat, paein, 9, 135),
                         (FRAME // 2 - 48 * jahat, paein - 9, 6, 90),
                         (FRAME // 2 - 58 * jahat, paein - 18, 4, 55)]:
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(214, 202, 178, a))


def atash(safhe: Image.Image, shomare: int) -> None:
    """پُفِ آتشِ دهان — دو فریم: کوچک و بزرگ"""
    d = ImageDraw.Draw(safhe)
    # دهانِ اژدها حدودِ نیمهٔ بلندیِ بدن، سمتِ راستِ فریم
    mx, my = FRAME // 2 + 62, TABE - 118
    gelh = [(255, 140, 59), (255, 178, 84), (255, 233, 160)]
    for faze, (tool, zavi) in enumerate([(46, 8), (72, 10)]):
        if faze != shomare:
            continue
        for i, rang in enumerate(gelh):
            k = 1.0 - i * 0.28
            panja = max(3, int(tool * k))
            gh = [(mx + tool - int(tool * 0.55 * i), my - panja // 2 - i * 3),
                  (mx + tool * 2 - int(tool * 0.6 * i), my - int(panja * 0.18)),
                  (mx + tool - int(tool * 0.55 * i), my + panja // 2 + i * 3)]
            d.polygon(gh, fill=rang + (230,))
        # جرقه‌ها
        for sx_, sy_ in [(tool * 2 + 6, -4), (tool * 2 - 2, 8), (tool * 2 + 10, 6)]:
            d.ellipse([mx + sx_ - 3, my + sy_ - 3, mx + sx_ + 3, my + sy_ + 3],
                      fill=(255, 240, 190, 200))


# ─────────────────────────── ساختِ فریم‌های هر کاستوم ───────────────────────────
def framha_esm(asparait: Image.Image):
    """۱۱ فریم: ist 2 + doid 4 + parsh 3 + dam 2 — شمارهٔ فریم در کلِ ورق"""
    kl = []
    # ist — نفس‌کشیدن
    kl.append(gharar(asparait))
    kl.append(gharar(asparait, sy=0.965, dy=7))
    # doid — جهش با لهیدگی و گردوخاک
    kl.append(gharar(asparait, dy=-14, zaviye=8)); ghobar(kl[-1])
    kl.append(gharar(asparait, dy=-2, zaviye=2))
    kl.append(gharar(asparait, dy=-14, zaviye=8)); ghobar(kl[-1], jahat=1)
    kl.append(gharar(asparait, dy=-6, zaviye=-6))
    # parsh — خم / پرتاب / فرود
    kl.append(gharar(asparait, sx=1.06, sy=0.86, dy=16))
    kl.append(gharar(asparait, sx=0.94, sy=1.10, dy=-46, zaviye=6))
    kl.append(gharar(asparait, sx=1.03, sy=0.95, dy=-6))
    # dam — پُفِ آتش (بدن کمی عقب، جا برای شعله)
    kl.append(gharar(asparait, dx=-30, zaviye=-3))
    kl.append(gharar(asparait, dx=-30, zaviye=-6)); atash(kl[-1], 1)
    return kl


# ─────────────────────────── اجرا ───────────────────────────
jason = {"frame": FRAME, "tabe": TABE, "kastumha": [], "harekat": {}}
for esm_h, (esm_fa, ayene) in ESMHA.items():
    tasvir = Image.open(KHAM / f"{esm_h}.png")
    if ayene:
        tasvir = tasvir.transpose(Image.FLIP_LEFT_RIGHT)
    asparait = brot(kalid_sabz(tasvir), BOLANDI)
    fr = framha_esm(asparait)

    # ورقِ افقیِ ۱۱ فریم
    varagh = Image.new("RGBA", (FRAME * len(fr), FRAME), (0, 0, 0, 0))
    for i, f in enumerate(fr):
        varagh.paste(f, (i * FRAME, 0))
    varagh.save(HONAR / f"{esm_h}.png")
    varagh.save(KARGAH / f"{esm_h}.webp", quality=80, method=6)

    # مرزِ دهان برای JS (آتش و چشم‌ک) — کسرِ بلندی
    jason["kastumha"].append({
        "esm": esm_h, "esm_fa": esm_fa,
        "varagh": f"{esm_h}.webp",
        "tedad_fram": len(fr),
    })

jason["harekat"] = {esm: {"az": i0, "tedad": t, "sorat": s, "halghe": h}
                    for i0, (esm, (t, s, h)) in zip(
                        [0, 2, 6, 9], [(k, v) for k, v in HAREKAT.items()])}
(KARGAH / "ezhdeha.json").write_text(json.dumps(jason, ensure_ascii=False, indent=1),
                                     encoding="utf-8")

# پیش‌نمایشِ GIF اژدهای عادی — چرخهٔ دویدن
gi = Image.new("RGBA", (FRAME, FRAME), (30, 27, 46, 255))
esm0 = Image.open(HONAR / "ezhdeha_asli.png")
fram_gi = [esm0.crop((i * FRAME, 0, (i + 1) * FRAME, FRAME)) for i in range(11)]
gi.save(JA / "pishnamayesh.gif", save_all=True,
        append_images=fram_gi, duration=110, loop=0, disposal=2)

# ورقِ بازرسیِ خروجیِ پردازش — برای چشمِ خودم
qc = Image.new("RGB", (9 * 140, 140), (30, 27, 46))
for i, esm_h in enumerate(ESMHA):
    fr0 = Image.open(HONAR / f"{esm_h}.png").crop((0, 0, FRAME, FRAME))
    fr0.thumbnail((130, 130))
    qc.paste(fr0, (i * 140 + 5, 5), fr0)
qc.save(JA / "qc_pardazesh.jpg", quality=90)
print("tamam — varagh:", len(ESMHA), "| fram dar har varagh:", 11)
