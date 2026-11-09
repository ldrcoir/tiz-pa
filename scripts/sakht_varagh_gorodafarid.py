# ═══════════════════════════════════════════════════════════════════
#  ساختِ ورقِ حرکتِ گردآفرید — پایپ‌لاینِ «عکسِ زیبای AI ← ورقِ فریم ← بازی»
#  همانِ راهِ هلیا + یک انیمیشنِ تازه: zadan (شمشیرزنی با کمانِ نور)
#  ۱) کلیدِ سبز: جداکردنِ کاراکتر از پس‌زمینهٔ سبزِ عکسِ تولیدشده
#  ۲) فریم‌های ist / doid / parsh / zadan با تبدیل‌های نرمِ تصویر
#  ۳) ورق‌های افقی ۲۵۶×۲۵۶ + فایلِ SpriteFrames گودوت (gordafarid_frames.tres)
#  ۴) پیش‌نمایشِ متحرکِ GIF برایِ دیدنِ نتیجه بدونِ بازکردنِ گودوت
# ═══════════════════════════════════════════════════════════════════
import math
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

VORUDI = Path("/tmp/gordafarid/gordafarid_chibi_raw.png")
MAKHRAJ = Path("/home/z/my-project/ema/gorodafarid/assets/honar/varagh")
FRAME = 256      # اندازهٔ هر فریم
TABE = 244       # خطِ پا (کفِ فریم)


def kalid_sabz(img: Image.Image) -> Image.Image:
    """جداسازی از پس‌زمینه: رنگ از گوشه‌ها نمونه‌برداری می‌شود؛ هر پیکسل بر اساس
    فاصلهٔ رنگی‌اش شفاف می‌شود؛ سبزِ خالصِ باقی‌مانده (سایهٔ زمین) هم پاک می‌شود"""
    arr = np.array(img.convert("RGB")).astype(int)
    gosha = np.concatenate([arr[:12, :12].reshape(-1, 3), arr[:12, -12:].reshape(-1, 3),
                            arr[-12:, :12].reshape(-1, 3), arr[-12:, -12:].reshape(-1, 3)])
    rang_bg = np.median(gosha, axis=0)
    fasele = np.sqrt(((arr - rang_bg) ** 2).sum(axis=2))
    alpha = np.clip((fasele - 28.0) / 52.0 * 255.0, 0, 255).astype(np.uint8)
    sabzi2 = arr[..., 1] - np.maximum(arr[..., 0], arr[..., 2])
    alpha[sabzi2 > 25] = 0
    lab = arr.copy()
    lab[..., 1] = np.minimum(arr[..., 1], np.maximum(arr[..., 0], arr[..., 2]) + 24)
    lab = (lab * (alpha[..., None] / 255.0) + rang_bg * (1.0 - alpha[..., None] / 255.0)).astype(np.uint8)
    tasvir = Image.fromarray(np.dstack([lab, alpha]))
    a = np.array(tasvir)[..., 3]
    a[a < 40] = 0
    tasvir.putalpha(Image.fromarray(a))
    return tasvir


def brot(img: Image.Image, bolandi: int) -> Image.Image:
    """برشِ تنگ دور کاراکتر + تغییر اندازه به ارتفاعِ دلخواه"""
    m = np.array(img)[..., 3] > 12
    ys, xs = np.where(m)
    if len(xs) == 0:
        raise RuntimeError("asparait dar aks peyda nashod")
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


def ghobar(safhe: Image.Image) -> None:
    """پافِ گردوخاکِ پشتِ پا برای فریم‌های تماسِ دویدن"""
    d = ImageDraw.Draw(safhe)
    for cx, cy, r, a in [(FRAME // 2 - 40, TABE - 10, 9, 130),
                         (FRAME // 2 - 54, TABE - 17, 6, 85),
                         (FRAME // 2 - 64, TABE - 24, 4, 55)]:
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(238, 233, 218, a))


def kaman_nor(safhe: Image.Image, pishraft: float, tondi: int) -> None:
    """کمانِ نورِ ضربِ شمشیر — هلالِ طلایی در پیشِ کاراکتر (رو به راست)
    pishraft: ۰ تا ۱ (پیشرویِ ضرب)؛ tondi: شفافیتِ ۰ تا ۲۵۵"""
    d = ImageDraw.Draw(safhe)
    cx, cy = FRAME // 2 + 34, TABE - 78
    r1, r2 = 66, 40
    # هلالِ اصلی: از زاویهٔ بالا به پایین در سمتِ راست
    boshoro = -75 + 130 * pishraft
    d.arc([cx - r1, cy - r1, cx + r1, cy + r1], boshoro, boshoro + 95,
          fill=(255, 226, 150, tondi), width=7)
    d.arc([cx - r2, cy - r2, cx + r2, cy + r2], boshoro + 14, boshoro + 78,
          fill=(255, 250, 220, min(255, tondi + 40)), width=3)


def varagh_besaz(framha: list) -> Image.Image:
    """چیدنِ فریم‌ها پشتِ هم روی یک ورقِ افقی"""
    safhe = Image.new("RGBA", (FRAME * len(framha), FRAME), (0, 0, 0, 0))
    for i, f in enumerate(framha):
        safhe.alpha_composite(f, (i * FRAME, 0))
    return safhe


def tres_besaz(harkatha) -> str:
    """تولیدِ فایلِ SpriteFrames گودوت — قلبِ تبدیلِ «ورق ← انیمیشنِ بازی»"""
    ext, sub, anims = [], [], []
    tedad_sub = sum(h[2] for h in harkatha)
    for idx, (esm, fail, tedad, sorat, halghe) in enumerate(harkatha, start=1):
        ext.append(f'[ext_resource type="Texture2D" path="res://assets/honar/varagh/{fail}" id="{idx}"]')
        framha = []
        for f in range(tedad):
            sid = f"AtlasTexture_{esm}_{f}"
            sub.append(f'[sub_resource type="AtlasTexture" id="{sid}"]')
            sub.append(f'atlas = ExtResource("{idx}")')
            sub.append(f'region = Rect2({f * FRAME}, 0, {FRAME}, {FRAME})')
            sub.append("")
            framha.append('{\n"duration": 1.0,\n"texture": SubResource("%s")\n}' % sid)
        anims.append('{\n"frames": [%s],\n"loop": %s,\n"name": &"%s",\n"speed": %s\n}'
                     % (", ".join(framha), "true" if halghe else "false", esm, sorat))
    load_steps = len(harkatha) + tedad_sub + 1
    return ('[gd_resource type="SpriteFrames" load_steps=%d format=3]\n\n' % load_steps
            + "\n".join(ext) + "\n\n" + "\n".join(sub).rstrip() + "\n\n[resource]\nanimations = ["
            + ", ".join(anims) + "]\n")


def soye_besaz() -> Image.Image:
    """سایهٔ نرمِ زیرِ پا — جدا از کاراکتر تا روی زمین بماند"""
    safhe = Image.new("RGBA", (128, 40), (0, 0, 0, 0))
    d = ImageDraw.Draw(safhe)
    d.ellipse([14, 6, 114, 34], fill=(10, 8, 20, 170))
    return safhe.filter(ImageFilter.GaussianBlur(4))


def gif_besaz(varaghha: dict, mahal: Path) -> None:
    """پیش‌نمایشِ متحرک: همهٔ انیمیشن‌ها پشتِ هم رویِ زمینهٔ تیره — بدونِ گودوت هم دیده می‌شود"""
    pichidha = []
    for _, framha in varaghha.items():
        pichidha += framha
    zamine = Image.new("RGB", (FRAME, FRAME), (30, 28, 40))
    chobi = []
    for f in pichidha:
        safhe = zamine.copy()
        safhe.paste(f, (0, 0), f)
        chobi.append(safhe.resize((128, 128), Image.LANCZOS))
    chobi[0].save(mahal, save_all=True, append_images=chobi[1:], duration=110, loop=0)


def asli() -> None:
    MAKHRAJ.mkdir(parents=True, exist_ok=True)
    khom = kalid_sabz(Image.open(VORUDI))
    khom = brot(khom, 200)   # ارتفاعِ کاراکتر در فریم
    khom = khom.transpose(Image.FLIP_LEFT_RIGHT)   # آینه: کاراکتر رو به راستِ بازی
    print("[gorodafarid] asparait:", khom.size)

    # ── ist: ایستادن با نفس‌کشیدنِ آرام و بالفتهٔ مو ──
    ist = []
    for i in range(8):
        faza = 2 * math.pi * i / 8
        ist.append(gharar(khom, dy=-round(2.5 * math.sin(faza)), sy=1.0 + 0.012 * math.sin(faza)))

    # ── doid: جهش با خم به جلو، لهیدگی در لحظهٔ تماس + گردوخاک ──
    doid = []
    for i in range(8):
        faza = 2 * math.pi * i / 8
        hop = 13 * abs(math.sin(faza))
        sx, sy = 1.0, 1.0
        if i in (0, 4):          # تماسِ پا با زمین
            sx, sy = 1.07, 0.93
        elif i in (2, 6):        # اوجِ جهش
            sx, sy = 0.96, 1.06
        f = gharar(khom, dy=-round(hop), sx=sx, sy=sy, zaviye=7.0)
        if i in (0, 4):
            ghobar(f)
        doid.append(f)

    # ── parsh: شش فازِ پرش ──
    fazha = [(10.0, 0.95, 1.10, -4), (7.0, 0.96, 1.08, -8), (4.0, 0.98, 1.04, -10),
             (0.0, 1.00, 1.00, -12), (-4.0, 0.97, 1.05, -8), (-7.0, 0.95, 1.07, -4)]
    parsh = [gharar(khom, zaviye=z, sx=sx, sy=sy, dy=dy) for z, sx, sy, dy in fazha]

    # ── zadan: شمشیرزنی — گاردِ عقب، ضربِ تند با کمانِ نور، بازگشت ──
    zadan = []
    fazha_z = [(-9.0, 0.0), (-4.0, 0.15), (11.0, 0.75), (14.0, 1.0), (7.0, 0.55), (0.0, 0.0)]
    for jomle, (zaviye, pishraft) in enumerate(fazha_z):
        f = gharar(khom, zaviye=zaviye, sx=1.02 if zaviye > 0 else 1.0,
                   sy=0.97 if zaviye > 0 else 1.0)
        if pishraft > 0.05:
            tondi = int(210 * math.sin(math.pi * min(1.0, pishraft)))
            kaman_nor(f, pishraft, tondi)
        zadan.append(f)

    varaghha = {"gordafarid_ist.png": ist, "gordafarid_doid.png": doid,
                "gordafarid_parsh.png": parsh, "gordafarid_zadan.png": zadan}
    for esm, framha in varaghha.items():
        varagh_besaz(framha).save(MAKHRAJ / esm)
        print("[gorodafarid]", esm, "=", len(framha), "frame")
    soye_besaz().save(MAKHRAJ / "soye.png")

    # ── فایلِ انیمیشنِ گودوت ──
    harkatha = [("ist", "gordafarid_ist.png", 8, 7.0, True),
                ("doid", "gordafarid_doid.png", 8, 14.0, True),
                ("parsh", "gordafarid_parsh.png", 6, 10.0, False),
                ("zadan", "gordafarid_zadan.png", 6, 12.0, False)]
    (MAKHRAJ / "gordafarid_frames.tres").write_text(tres_besaz(harkatha), encoding="utf-8")
    print("[gorodafarid] gordafarid_frames.tres = OK")

    # ── پیش‌نمایشِ متحرکِ GIF ──
    gif_besaz(varaghha, MAKHRAJ / "pishnamayesh.gif")
    print("[gorodafarid] pishnamayesh.gif = OK")

    # ── ورقِ پیش‌نمایشِ ثابت برایِ دیدنِ همه با هم ──
    safha = Image.new("RGBA", (2048, 256 * 4 + 30), (30, 28, 40, 255))
    for r, (_, framha) in enumerate(varaghha.items()):
        safha.alpha_composite(varagh_besaz(framha), (0, r * (256 + 10)))
    safha.resize((1024, (256 * 4 + 30) // 2), Image.LANCZOS).save("/tmp/gordafarid/varagh_pishnamayesh.png")
    print("[gorodafarid] TAAMOOM")


if __name__ == "__main__":
    asli()
