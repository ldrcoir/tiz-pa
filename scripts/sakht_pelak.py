# ساخت پلاک تهران ۱۱ — چیدمان واقعی پلاک ایران:
# نوار آبی پرچم در چپ + عدد دورقم + حرف + عدد سه‌رقمی + کادر کد استان در راست
# «ایران» هم بالای کادر کد استان — مثل پلاک‌های واقعی خیابان‌های تهران
import os
from PIL import Image, ImageDraw, ImageFont
import arabic_reshaper
from bidi.algorithm import get_display

AJOR = "/home/z/my-project/game/assets/fonts/Vazirmatn-Bold.ttf"
KHORUJI = "/home/z/my-project/game/assets/textures/pelak_tehran.png"

W, H = 1040, 220  # نسبت ۴.۷۲:۱ مثل پلاک واقعی (۵۲۰×۱۱۰ میلی‌متر)


def fa(txt):
    # حروف فارسی باید به هم بچسبند و راست‌به‌چپ شوند
    return get_display(arabic_reshaper.reshape(txt))


def aoq(point, txt, fnt, fill, anchor="mm"):
    d.text(point, fa(txt), font=fnt, fill=fill, anchor=anchor)


img = Image.new("RGB", (W, H), (245, 245, 242))
d = ImageDraw.Draw(img)

# خط دور مشکی نازک — مثل پلاک‌های پرس
d.rectangle([2, 2, W - 3, H - 3], outline=(18, 18, 18), width=5)

# ── نوار آبی چپ + پرچم ──
AB = (26, 58, 140)
d.rectangle([6, 6, 118, H - 7], fill=AB)
# پرچم: سه نوار سبز/سفید/سرخ + نشان سرخ وسط
fy = 40
d.rectangle([22, fy, 102, fy + 26], fill=(23, 145, 66))
d.rectangle([22, fy + 26, 102, fy + 52], fill=(240, 240, 240))
d.rectangle([22, fy + 52, 102, fy + 78], fill=(214, 40, 40))
d.ellipse([52, fy + 39 - 11, 74, fy + 39 + 11], fill=(214, 40, 40))
fnt_s = ImageFont.truetype(AJOR, 46)
aoq((62, H - 52), "ایران", fnt_s, (255, 255, 255))

# ── عدد دورقم (سری) ──
fnt_b = ImageFont.truetype(AJOR, 118)
aoq((165, H / 2), "۱۲", fnt_b, (15, 15, 15))

# ── حرف ──
aoq((290, H / 2), "ب", fnt_b, (15, 15, 15))

# ── عدد سه‌رقمی + «ایران» کوچک بالای آن ──
aoq((480, H / 2 + 14), "۴۷۲", fnt_b, (15, 15, 15))
fnt_k = ImageFont.truetype(AJOR, 40)
aoq((480, 34), "ایران", fnt_k, (15, 15, 15))

# ── کادر کد استان در راست: ۱۱ = تهران ──
d.rectangle([W - 178, 16, W - 14, H - 16], outline=(15, 15, 15), width=5)
d.rectangle([W - 172, 22, W - 20, H - 22], fill=(28, 52, 110))
aoq((W - 96, H / 2 + 6), "۱۱", fnt_b, (255, 255, 255))

img.save(KHORUJI)
print("pelak saved:", KHORUJI, img.size)

# نسخه‌ی کمکی برای منو/گاراژ — پلاک بزرگ روی پس‌زمینه شفاف
img.resize((520, 110), Image.LANCZOS).save("/home/z/my-project/download/pelak_tehran.png")
print("ok")
