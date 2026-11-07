#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# صدا و موسیقی «گردآفرید» — سنتورِ پلاکِ کارپلس-استرانگ + جلوه‌های نبرد
# خروجی: ema/gorodafarid/assets/audio/*.wav
import numpy as np, wave, os

SR = 22050
OUT = "/home/z/my-project/ema/gorodafarid/assets/audio"
os.makedirs(OUT, exist_ok=True)

def zakhire(nam, sig, vol=0.9):
    sig = np.asarray(sig, dtype=np.float64)
    m = np.max(np.abs(sig)) or 1.0
    sig = sig / m * vol
    dat = (sig * 32767).astype(np.int16)
    with wave.open(f"{OUT}/{nam}.wav", "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes(dat.tobytes())
    print("ساخته شد:", nam)

def plak(freq, dur=1.6, damp=0.9965, bright=0.5):
    # کارپلس-استرانگ — پلاکِ سنتور با کمی برق
    n = int(SR * dur)
    p = int(SR / freq)
    buf = (np.random.rand(p) * 2 - 1) * bright + (1 - bright) * np.sin(np.linspace(0, 2*np.pi, p))
    kh = np.zeros(n)
    for i in range(n):
        kh[i] = buf[i % p]
        buf[i % p] = damp * (0.5 * buf[i % p] + 0.5 * buf[(i + 1) % p])
    win = np.exp(-np.linspace(0, 4.2, n))
    return kh * win

def nois(n):
    # n بر حسبِ نمونه — نه ثانیه
    return np.random.uniform(-1, 1, int(n))

# ─── موسیقی پس‌زمینه: حلقهٔ دستگاهِ همایون (D-Eb-F#-G-A-Bb-C) ───
BPM = 92
BEAT = 60.0 / BPM
MIL = 2 * BEAT                       # میل طولی
# ریتم: الگوی وزنِ عراق — ضرب و پلاک‌ها
nagh = [
    (0.0, "D4", 1.0), (1.0, "A3", 0.7), (1.5, "C5", 0.8), (2.0, "Bb4", 0.9),
    (3.0, "A4", 0.8), (3.5, "G4", 0.7), (4.0, "F#4", 0.9), (5.0, "A4", 0.7),
    (5.5, "Bb4", 0.8), (6.0, "C5", 0.9), (7.0, "D5", 1.0), (7.5, "C5", 0.6),
    (8.0, "Bb4", 0.8), (9.0, "A4", 0.9), (9.5, "G4", 0.6), (10.0, "F#4", 0.8),
    (11.0, "D4", 1.0), (11.5, "Eb4", 0.7), (12.0, "D4", 0.9),
]
fregha = {"D2": 73.42, "D3": 146.83, "D4": 293.66, "Eb4": 311.13, "F#4": 369.99,
          "G4": 392.0, "A3": 220.0, "A4": 440.0, "Bb4": 466.16, "C5": 523.25, "D5": 587.33}
tool = int(SR * (14 * BEAT))
moosiqi = np.zeros(tool)
for mil, nott, vol in nagh:
    t0 = int(mil * BEAT * SR)
    sig = plak(fregha[nott], dur=2.2, damp=0.995, bright=0.35) * vol * 0.5
    payan = min(t0 + len(sig), tool)
    moosiqi[t0:payan] += sig[:payan - t0]
# باسِ بلند (سه‌تارِ بم) — رِ در کل حلقه
bas = plak(fregha["D2"], dur=14 * BEAT, damp=0.999, bright=0.15) * 0.35
moosiqi += bas[:tool]
# ضربِ تنبک — بم و تِک
for mil in range(0, 14, 2):
    t0 = int(mil * BEAT * SR)
    dar = int(0.09 * SR)
    tanb = np.zeros(dar)
    z = nois(dar) * np.exp(-np.linspace(0, 55, dar))       # تِک
    bom = np.sin(2 * np.pi * np.linspace(120, 55, dar)) * np.exp(-np.linspace(0, 38, dar))
    tanb = z * 0.4 + bom * 0.9
    payan = min(t0 + dar, tool)
    moosiqi[t0:payan] += tanb[:payan - t0]
    t1 = int((mil + 1.5) * BEAT * SR)
    dar1 = int(0.06 * SR)
    tek = nois(dar1) * np.exp(-np.linspace(0, 70, dar1)) * 0.5
    payan = min(t1 + dar1, tool)
    moosiqi[t1:payan] += tek[:payan - t1]
zakhire("moeini", moosiqi, vol=0.55)

# ─── جلوه‌ها ───
# شمشیر: هوایِ تیز — نویزِ باندپاس با فرود
dar = int(0.28 * SR)
t = np.linspace(0, 1, dar)
swoosh = nois(dar) * np.sin(np.pi * t) ** 1.5
fal = np.convolve(swoosh, np.ones(8) / 8, "same")
zakhire("shemshir", fal, vol=0.7)

# کمان: تُنگِ زه + پرتاب
dar = int(0.22 * SR)
t = np.linspace(0, 0.22, dar)
tir = np.sin(2 * np.pi * (900 + 500 * t) * t) * np.exp(-np.linspace(0, 30, dar))
tir += nois(dar) * np.exp(-np.linspace(0, 60, dar)) * 0.5
zakhire("tir", tir, vol=0.75)

# ضربهٔ خوردن: تُمبِ بم + نویز
dar = int(0.3 * SR)
zad = np.sin(2 * np.pi * np.linspace(190, 50, dar)) * np.exp(-np.linspace(0, 26, dar))
zad += nois(dar) * np.exp(-np.linspace(0, 80, dar)) * 0.6
zakhire("zadakhor", zad, vol=0.85)

# ضربهٔ زدن به دشمن: کلینگِ فلزی
dar = int(0.25 * SR)
t = np.linspace(0, 0.25, dar)
kling = (np.sin(2*np.pi*1180*t) + np.sin(2*np.pi*1780*t) * 0.6 + np.sin(2*np.pi*2410*t) * 0.4)
kling *= np.exp(-np.linspace(0, 34, dar))
kling += nois(dar) * np.exp(-np.linspace(0, 90, dar)) * 0.35
zakhire("kling", kling, vol=0.6)

# پرش: بادِ بالارونده
dar = int(0.3 * SR)
t = np.linspace(0, 0.3, dar)
parsh = np.sin(2 * np.pi * (320 + 460 * t) * t) * np.exp(-np.linspace(3, 0, dar))
parsh += nois(dar) * np.sin(np.pi * t) * 0.25
zakhire("parsh", parsh, vol=0.5)

# انار (جان): دو نُتِ شاد
dar = int(0.5 * SR)
sig = np.zeros(dar)
for i, f in enumerate([660.0, 880.0]):
    t0 = int(i * 0.12 * SR)
    p = plak(f, dur=0.4, bright=0.2) * 0.7
    payan = min(t0 + len(p), dar)
    sig[t0:payan] += p[:payan - t0]
zakhire("enar", sig, vol=0.7)

# سوارشدن اسب: ارتعاشِ زین + هور
dar = int(0.45 * SR)
t = np.linspace(0, 0.45, dar)
sav = np.sin(2 * np.pi * (240 + 180 * t) * t) * np.sin(np.pi * t)
sav += nois(dar) * np.exp(-np.linspace(0, 30, dar)) * 0.3
zakhire("savari", sav, vol=0.6)

# رگبارِ سم‌ها (دویدن اسب) — چهار تُمبِ سریع
dar = int(0.55 * SR)
sig = np.zeros(dar)
for i, dt in enumerate([0.0, 0.13, 0.27, 0.40]):
    t0 = int(dt * SR)
    d1 = int(0.08 * SR)
    tum = np.sin(2 * np.pi * np.linspace(150, 60, d1)) * np.exp(-np.linspace(0, 40, d1))
    payan = min(t0 + d1, dar)
    sig[t0:payan] += tum[:payan - t0] * (0.9 - i * 0.1)
zakhire("sam", sig, vol=0.65)

# فریادِ دیو: موجِ دندانه‌ارهٔ بمِ لرزان
dar = int(0.7 * SR)
t = np.linspace(0, 0.7, dar)
growl = np.sign(np.sin(2 * np.pi * (72 + 14 * np.sin(2 * np.pi * 5.5 * t)) * t))
growl = growl * (0.55 + 0.45 * np.sin(2 * np.pi * 9 * t)) * np.sin(np.pi * t)
growl = np.convolve(growl, np.ones(6) / 6, "same")
zakhire("gharjar", growl, vol=0.55)

# پیروزی: آرپژِ همایونِ بلند
dar = int(2.6 * SR)
sig = np.zeros(dar)
for i, (f, v) in enumerate([(293.66, 0.9), (369.99, 0.8), (440.0, 0.85), (587.33, 1.0), (698.46, 0.7)]):
    t0 = int(i * 0.16 * SR)
    p = plak(f, dur=1.8, bright=0.3) * v
    payan = min(t0 + len(p), dar)
    sig[t0:payan] += p[:payan - t0]
zakhire("piroozi", sig, vol=0.8)

# شکست: فرودِ غم‌ناک
dar = int(1.6 * SR)
sig = np.zeros(dar)
for i, f in enumerate([392.0, 311.13, 233.08]):
    t0 = int(i * 0.22 * SR)
    p = plak(f, dur=1.2, damp=0.993, bright=0.25) * 0.8
    payan = min(t0 + len(p), dar)
    sig[t0:payan] += p[:payan - t0]
zakhire("shekast", sig, vol=0.7)

# ایستگاه (چک‌پوینت): پلاکِ زنگی
dar = int(0.8 * SR)
t = np.linspace(0, 0.8, dar)
zang = (np.sin(2*np.pi*1320*t) + np.sin(2*np.pi*1980*t)*0.5) * np.exp(-np.linspace(0, 14, dar))
zakhire("istgah", zang, vol=0.5)

print("پایان — همهٔ صداها ساخته شدند")
