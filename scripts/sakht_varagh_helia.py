# ═══════════════════════════════════════════════════════════════
#  ساختِ ورقِ حرکتِ هلیا — پایپ‌لاینِ «عکسِ زیبای AI ← ورقِ فریم ← بازی»
#  ۱) کلیدِ سبز: جداکردنِ کاراکتر از پس‌زمینهٔ سبزِ عکسِ تولیدشده
#  ۲) ساختِ فریم‌های ist / dovid / parsh با تبدیل‌های نرمِ تصویر
#     (نفس‌کشیدنِ ایستادن، جهشِ دویدن با گردوخاک، فازهای پرش)
#  ۳) چیدنِ فریم‌ها روی ورق‌های افقی ۲۵۶×۲۵۶
#  ۴) تولیدِ helia_frames.tres — ورق تبدیل می‌شود به انیمیشنِ گودوت
# ═══════════════════════════════════════════════════════════════
import math
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw

VORUDI = Path("/tmp/helia2d/helia_chibi_raw2.png")
PAKEN = Path("/home/z/my-project/to/azmayesh_helia2d")
TASAVIR = PAKEN / "assets" / "helia"
FRAME = 256      # اندازهٔ هر فریم
TABE = 250       # خطِ پا (کفِ فریم)


def kalid_sabz(img: Image.Image) -> Image.Image:
    """جداسازی از پس‌زمینه: رنگِ پس‌زمینه از گوشه‌ها نمونه‌برداری می‌شود؛
    هر پیکسل بر اساس فاصله‌اش از آن رنگ شفاف می‌شود (برای هر پس‌زمینهٔ یک‌رنگ کار می‌کند)"""
    arr = np.array(img.convert("RGB")).astype(int)
    h, w = arr.shape[:2]
    # نمونهٔ رنگِ پس‌زمینه از چهار گوشه
    gosha = np.concatenate([arr[:12, :12].reshape(-1, 3), arr[:12, -12:].reshape(-1, 3),
                            arr[-12:, :12].reshape(-1, 3), arr[-12:, -12:].reshape(-1, 3)])
    rang_bg = np.median(gosha, axis=0)
    fasele = np.sqrt(((arr - rang_bg) ** 2).sum(axis=2))
    alpha = np.clip((fasele - 28.0) / 52.0 * 255.0, 0, 255).astype(np.uint8)
    # هر پیکسلِ سبزِ خالص (مثل خطِ زمینِ نقاشی‌شده زیر پا) هم پاک می‌شود
    sabzi2 = arr[..., 1] - np.maximum(arr[..., 0], arr[..., 2])
    alpha[sabzi2 > 25] = 0
    # حذفِ بازتابِ سبز/زردِ پس‌زمینه روی لبه‌ها (despill)
    lab = arr.copy()
    lab[..., 1] = np.minimum(arr[..., 1], np.maximum(arr[..., 0], arr[..., 2]) + 24)
    lab = (lab * (alpha[..., None] / 255.0) + rang_bg * (1.0 - alpha[..., None] / 255.0)).astype(np.uint8)
    out = np.dstack([lab, alpha])
    tasvir = Image.fromarray(out)
    # پاک‌سازیِ نویزِ شفافِ خیلی کم‌رنگ
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
        # زاویهٔ مثبت = خم‌شدن به جلو (کاراکتر رو به راست است)
        asparait = asparait.rotate(-zaviye, expand=True, resample=Image.BICUBIC)
        w, h = asparait.size
    x = (FRAME - w) // 2 + dx
    y = TABE - h + dy
    safhe.alpha_composite(asparait, (int(x), int(y)))
    return safhe


def ghobar(safhe: Image.Image) -> None:
    """پافِ گردوخاکِ پشتِ پا برای فریم‌های تماسِ دویدن"""
    d = ImageDraw.Draw(safhe)
    for cx, cy, r, a in [(FRAME // 2 - 36, TABE - 10, 9, 130),
                         (FRAME // 2 - 50, TABE - 17, 6, 85),
                         (FRAME // 2 - 60, TABE - 24, 4, 55)]:
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(238, 233, 218, a))


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
        ext.append(f'[ext_resource type="Texture2D" path="res://assets/helia/{fail}" id="{idx}"]')
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
    """سایهٔ نرمِ زیرِ پا (بیضیِ محو) — جدا از کاراکتر تا روی زمین بماند"""
    safhe = Image.new("RGBA", (128, 40), (0, 0, 0, 0))
    d = ImageDraw.Draw(safhe)
    d.ellipse([14, 6, 114, 34], fill=(10, 8, 20, 170))
    return safhe.filter(__import__("PIL.ImageFilter", fromlist=["ImageFilter"]).GaussianBlur(4))


def asli() -> None:
    TASAVIR.mkdir(parents=True, exist_ok=True)
    khom = kalid_sabz(Image.open(VORUDI))
    khom = brot(khom, 190)   # ارتفاعِ کاراکتر در فریم
    print("[varagh] asparait:", khom.size)

    # ── ist: ایستادن با نفس‌کشیدنِ آرام ──
    ist = []
    for i in range(8):
        faza = 2 * math.pi * i / 8
        ist.append(gharar(khom, dy=-round(2.5 * math.sin(faza)), sy=1.0 + 0.012 * math.sin(faza)))

    # ── dovid: جهش با خم به جلو، لهیدگی در لحظهٔ تماس + گردوخاک ──
    dovid = []
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
        dovid.append(f)

    # ── parsh: شش فازِ پرش؛ آخرین فریم هنگام سقوط نگه داشته می‌شود ──
    fazha = [(10.0, 0.95, 1.10, -4), (7.0, 0.96, 1.08, -8), (4.0, 0.98, 1.04, -10),
             (0.0, 1.00, 1.00, -12), (-4.0, 0.97, 1.05, -8), (-7.0, 0.95, 1.07, -4)]
    parsh = [gharar(khom, zaviye=z, sx=sx, sy=sy, dy=dy) for z, sx, sy, dy in fazha]

    varaghha = {"helia_ist.png": ist, "helia_dovid.png": dovid, "helia_parsh.png": parsh}
    for esm, framha in varaghha.items():
        varagh_besaz(framha).save(TASAVIR / esm)
        print("[varagh]", esm, "=", len(framha), "frame")
    soye_besaz().save(TASAVIR / "soye.png")

    # ── فایلِ انیمیشنِ گودوت: ورق ← SpriteFrames ──
    harkatha = [("ist", "helia_ist.png", 8, 7.0, True),
                ("dovid", "helia_dovid.png", 8, 14.0, True),
                ("parsh", "helia_parsh.png", 6, 10.0, False)]
    (TASAVIR / "helia_frames.tres").write_text(tres_besaz(harkatha), encoding="utf-8")
    print("[varagh] helia_frames.tres = OK")

    # ── پیش‌نمایش برای بررسیِ چشمی ──
    safha = Image.new("RGBA", (2048, 256 * 3 + 20), (30, 28, 40, 255))
    for r, (_, framha) in enumerate(varaghha.items()):
        safha.alpha_composite(varagh_besaz(framha), (0, r * (256 + 10)))
    safha.resize((1024, (256 * 3 + 20) // 2), Image.LANCZOS).save("/tmp/helia2d/varagh_pishnamayesh.png")
    print("[varagh] TAAMOOM OK")


if __name__ == "__main__":
    asli()
