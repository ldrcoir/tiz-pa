#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
سازندهٔ آهنگِ واقعیِ مسابقه‌ای تیزپا — قطعهٔ کاملِ چندسازواره (بدونِ سکوت و بدونِ لوپِ خسته‌کننده)
ساختار: مقدمه → اوج‌گیری → ریختِ اول → فرود → ریختِ دوم → پایان (لوپ‌پذیر)
سازها: کیک، اسنیر، کلاپ، های‌هت (بسته/باز)، کراش، بیسِ اره‌ای+ساب، سوپرساوِ لید،
       آرپژِ پلاک، پدِ گرم، رایزر — همه با numpy سنتز می‌شوند؛ خروجی WAV استریو → OGG
همچنین صدای موتورِ جدید (motor_nfs.wav) — لوپِ بی‌درزِ غرشِ چندموجی
"""
import math
import os
import subprocess
import numpy as np

SR = 44100
BPM = 126.0
BEAT = 60.0 / BPM          # طولِ یک ضرب
BAR = BEAT * 4.0           # طولِ یک میزان

# ═══════════════ ابزارها ═══════════════
def til_zaman(t_s):
    """آرایهٔ زمان و تعداد نمونه"""
    n = int(t_s * SR)
    return np.arange(n, dtype=np.float64) / SR, n

def env_ad(n, a, d, curve=4.0):
    """حمله/افت — a و d به ثانیه"""
    e = np.ones(n)
    na = max(1, int(a * SR)); nd = max(1, int(d * SR))
    e[:na] = np.linspace(0, 1, na)
    if nd < n:
        e[n - nd:] = np.linspace(1, 0, nd) ** curve
    else:
        e *= np.linspace(1, 0, n) ** curve
    return e

def saw(f, t, phase=0.0):
    return 2.0 * ((f * t + phase) % 1.0) - 1.0

def squ(f, t, duty=0.5):
    return np.where((f * t) % 1.0 < duty, 1.0, -1.0)

def lowpass(x, cutoff, sr=SR, order_better=False):
    """فیلترِ پایین‌گذرِ سادهٔ یک‌قطبی (Yule-walker جایگزینِ سنگین)"""
    rc = 1.0 / (2 * math.pi * cutoff)
    dt = 1.0 / sr
    a = dt / (rc + dt)
    y = np.empty_like(x)
    acc = 0.0
    for i in range(len(x)):
        acc += a * (x[i] - acc)
        y[i] = acc
    return y

def highpass(x, cutoff, sr=SR):
    return x - lowpass(x, cutoff, sr)

def bandpass(x, lo, hi):
    return highpass(lowpass(x, hi), lo)

def stereo_pan(x, pan=0.0):
    """pan از -۱ (چپ) تا +۱ (راست)"""
    gl = math.sqrt(0.5 * (1.0 - pan)); gr = math.sqrt(0.5 * (1.0 + pan))
    return x * gl, x * gr

class Mikser:
    """میکسرِ ساده — هر ساز با زنجیرهٔ تأخیر و پن"""
    def __init__(self, toole_saniye):
        self.n = int(toole_saniye * SR)
        self.chap = np.zeros(self.n)
        self.rast = np.zeros(self.n)

    def ezafe(self, x, zamane_saniye, pan=0.0, gan=1.0, delay=0.0, gan_delay=0.0):
        i0 = int(zamane_saniye * SR)
        n = len(x)
        if i0 + n > self.n:
            n = self.n - i0
            if n <= 0:
                return
            x = x[:n]
        gl, gr = stereo_pan(x, pan)
        self.chap[i0:i0 + n] += gl * gan
        self.rast[i0:i0 + n] += gr * gan
        # اکو — عرضِ استریو و جنسِ «اتاقِ بزرگِ مسابقه»
        if gan_delay > 0:
            nd = int(delay * SR)
            d0 = i0 + nd
            if d0 + n < self.n:
                self.chap[d0:d0 + n] += gr * gan_delay
                self.rast[d0:d0 + n] += gl * gan_delay

    def sidechain(self, satre_kik, omgh=0.55):
        """فروپاشیِ حجم روی ضربِ کیک — پمپِ موسیقیِ مسابقه (نمونه‌برداریِ دوباره به طولِ صدا)"""
        duck_kotah = 1.0 - satre_kik * omgh
        duck_kotah = np.clip(duck_kotah, 0.05, 1.0)
        # درون‌یابیِ خطی از شبکهٔ کیک به نمونه‌های واقعی — هموار و بدونِ پرش
        x_tavan = np.linspace(0.0, 1.0, len(duck_kotah))
        x_nemoone = np.linspace(0.0, 1.0, self.n)
        duck = np.interp(x_nemoone, x_tavan, duck_kotah)
        self.chap *= duck
        self.rast *= duck

    def final(self, limit=0.94):
        """نرمال‌سازی + سقفِ نرم"""
        for ch in (self.chap, self.rast):
            m = np.max(np.abs(ch))
            if m > 0:
                ch *= limit / m
        # سقفِ نرمِ tanh برای جلوگیری از برش
        self.chap = np.tanh(self.chap * 1.15) * 0.92
        self.rast = np.tanh(self.rast * 1.15) * 0.92
        return self.chap, self.rast

# ═══════════════ سازها ═══════════════
def kik(tavan=1.0):
    t, n = til_zaman(0.30)
    fr = 130 * np.exp(-t * 22) + 44
    ph = np.cumsum(fr) / SR
    x = np.sin(2 * np.pi * ph)
    x *= np.exp(-t * 15)
    klik = highpass(np.random.default_rng(7).standard_normal(int(0.004 * SR)), 1500) * 0.5
    x[:len(klik)] += klik
    return x * tavan * 0.9

def esnir(tavan=1.0):
    t, n = til_zaman(0.22)
    noght = np.random.default_rng(11).standard_normal(n)
    x = bandpass(noght, 900, 7500) * np.exp(-t * 26)
    tan = np.sin(2 * np.pi * 195 * t) * np.exp(-t * 30) * 0.5
    x[:len(tan)] += tan
    return x * tavan * 0.62

def kalap(tavan=1.0):
    t, n = til_zaman(0.20)
    noght = np.random.default_rng(23).standard_normal(n)
    x = bandpass(noght, 1200, 9000)
    e = np.exp(-t * 30)
    for d in (0.0, 0.010, 0.021):   # سه‌لایهٔ کلاپ
        i = int(d * SR)
        e[i:] += 0.7 * np.exp(-t[:n - i] * 34)
    return x * e * tavan * 0.42

def hat(tavan=1.0, baz=False):
    t, n = til_zaman(0.24 if baz else 0.055)
    noght = np.random.default_rng(31).standard_normal(n)
    x = highpass(noght, 7800) * np.exp(-t * (10 if baz else 95))
    return x * tavan * (0.30 if baz else 0.22)

def kerash(tavan=1.0):
    t, n = til_zaman(1.6)
    noght = np.random.default_rng(43).standard_normal(n)
    x = highpass(noght, 4200) * np.exp(-t * 3.2)
    return x * tavan * 0.30

def beis(nemudar, barha, ghogh=70):
    """بیسِ درایو: اره + ساب با فیلترِ پویا — nemudar = آرایهٔ ارتفاع در ۱۶م‌ها"""
    n_bar = int(BAR * SR)
    step = BAR / 16.0
    x = np.zeros(n_bar * barha)
    for b in range(barha):
        for s in range(16):
            nem = nemudar[b * 16 + s] if len(nemudar) > b * 16 + s else 0.0
            if nem <= 0:
                continue
            fr = 440.0 * 2 ** ((nem - 69) / 12.0)
            t_s = step * 0.98
            t, n = til_zaman(t_s)
            env_f = 300 + 700 * np.exp(-t * 28)     # فیلترِ پویا — پانچ
            y = saw(fr, t) * 0.6 + np.sin(2 * np.pi * fr / 2 * t) * 0.5
            y = lowpass(y, 520)
            y *= env_ad(n, 0.004, t_s * 0.7)
            i0 = int((b * BAR + s * step) * SR)
            x[i0:i0 + len(y)] += y * 0.85
    return x

def soopersav(fr, t, detune=0.012, tavan=1.0):
    """لیدِ پهن: ۵ ارهٔ کوک‌رفته"""
    y = np.zeros(len(t))
    for k, d in enumerate((-2.5, -1.0, -0.3, 0.9, 2.2)):
        y += saw(fr * (1 + d / 1000.0), t, phase=k * 0.13)
    y /= 5
    vib = 1.0 + 0.004 * np.sin(2 * np.pi * 5.2 * t)
    y = saw(fr * vib, t) * 0.5 + y * 0.9
    return y * tavan

def lide_zadan(nem, toole, vib=0):
    """یک نتِ لید با حمله/افت"""
    fr = 440.0 * 2 ** ((nem - 69) / 12.0)
    t, n = til_zaman(toole)
    y = soopersav(fr, t)
    if vib:
        y += soopersav(fr * 2, t) * vib * 0.35
    y *= env_ad(n, 0.015, toole * 0.55)
    return y * 0.30

def palak(nem, toole):
    """آرپژِ پلاک — کوتاه و براق"""
    fr = 440.0 * 2 ** ((nem - 69) / 12.0)
    t, n = til_zaman(toole)
    y = saw(fr, t) * 0.5 + squ(fr, t, 0.3) * 0.2
    y = lowpass(y, 3200)
    y *= env_ad(n, 0.002, toole * 0.85, curve=3)
    return y * 0.20

def ped(akkor, toole):
    """پدِ گرمِ آکوردی"""
    t, n = til_zaman(toole)
    y = np.zeros(n)
    for nem in akkor:
        fr = 440.0 * 2 ** ((nem - 69) / 12.0)
        y += saw(fr * 0.999, t) * 0.33 + saw(fr * 1.003, t) * 0.33
    y = lowpass(y, 900)
    y *= env_ad(n, toole * 0.35, toole * 0.4)
    return y * 0.11

def rayzer(toole):
    """رایزرِ اوج‌گیری"""
    t, n = til_zaman(toole)
    noght = np.random.default_rng(57).standard_normal(n)
    x = noght * (0.25 + 0.75 * t / toole)
    ctoff = 300 + 3600 * (t / toole) ** 2
    y = np.empty(n); acc = 0.0
    for i in range(n):
        rc = 1.0 / (2 * math.pi * ctoff[i]); a = (1.0 / SR) / (rc + 1.0 / SR)
        acc += a * (x[i] - acc); y[i] = acc
    e = np.ones(n)
    ni = int(0.08 * SR)
    e[-ni:] = np.linspace(1, 0, ni)
    return y * e * 0.5

# ═══════════════ نُت‌ها و ملودی ═══════════════
# A minor: A=57(C3A2?) — با فرمتِ MIDI: A2=45, A3=57, A4=69
A2, C3, E3 = 45, 48, 52
A3, B3, C4, D4, E4, F4, G4, G3, F2, G2, A5 = 57, 59, 60, 62, 64, 65, 67, 55, 41, 43, 81
A4, B4, C5, D5, E5, G5 = 69, 71, 72, 74, 76, 79

# بیسِ ۱۶م‌ها — الگوی درایوِ مسابقه (A در همه‌جا با گذرهای کوتاه)
BEIS_DROP = [A2, 0, A2, 0, A2, 0, A2, 0,  A2, 0, A2, 0, A2, 0, E3, 0] * 4   # ۴ میزان
# ریختِ دوم — اکتاو بالاتر روی نیمِ دوم
BEIS_DROP2 = (BEIS_DROP[:64] +
              [n + 12 if n else 0 for n in BEIS_DROP[64:]] )

# ملودیِ لید — ۸ میزان × ۱۶ ۱۶م (۰ = سکوت) — ملودیِ قهرمانیِ تیزپا
MEL_A = [
    # میزان ۱ — اعلانِ شروع
    [E5,0,0,C5,0,0,A4,0, 0,0,C5,0,D5,0,E5,0],
    # میزان ۲ — پاسخ
    [0,0,D5,0,0,0,C5,0, 0,0,A4,0,0,0,0,0],
    # میزان ۳ — اوج
    [E5,0,0,G5,0,0,E5,0, 0,0,D5,0,C5,0,D5,0],
    # میزان ۴ — فرود روی تونیک
    [E4,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0],
    # میزان ۵
    [C5,0,0,D5,0,0,E5,0, 0,0,A4,0,0,0,0,0],
    # میزان ۶
    [0,0,A4,0,B4,0,C5,0, 0,0,D5,0,0,0,0,0],
    # میزان ۷ — دویدنِ به بالا
    [E5,0,D5,0,C5,0,D5,0, E5,0,0,G5,0,0,A4,0],
    # میزان ۸ — پایانِ پرسشی
    [B4,0,0,C5,0,0,0,0, 0,0,0,0,0,0,0,0],
]
MEL_B = [
    [A4,0,0,C5,0,0,E5,0, 0,0,G5,0,E5,0,0,0],
    [0,0,D5,0,0,0,E5,0, 0,0,C5,0,0,0,0,0],
    [E5,0,0,G5,0,0,A4,0, 0,0,C5,0,D5,0,E5,0],
    [G4,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0],
    [C5,0,0,E5,0,0,G5,0, 0,0,E5,0,0,0,0,0],
    [0,0,D5,0,C5,0,B4,0, 0,0,C5,0,0,0,0,0],
    [E5,0,G5,0,A4,0,C5,0, D5,0,E5,0,0,0,G5,0],
    [E5,0,0,D5,0,C5,0,0, A4,0,0,0,0,0,0,0],
]

AKKORHA = [
    [A2, E3, A3, C4, E4],       # Am
    [F2, 48, 53, 57, 60],       # F
    [C3, G3, 55, 60, 64],       # C
    [G2, 50, 55, 59, 62],       # G
]

# ═══════════════ چیدنِ قطعه ═══════════════
def bi_tarane():
    """قطعهٔ کامل — خروجی: فایل WAV استریو"""
    t_bars = (4 + 8 + 16 + 8 + 16 + 4)
    m = Mikser(t_bars * BAR + 0.5)

    nemudar_kik = np.zeros(t_bars * 32)   # شبکهٔ ۳۲م برای sidechain
    def kik_zan(bar, beat=0.0, tavan=1.0):
        m.ezafe(kik(tavan), bar * BAR + beat * BEAT, pan=0.0, gan=1.0)
        i = int((bar * BAR + beat * BEAT) / (t_bars * BAR) * len(nemudar_kik))
        for k in range(int(0.30 / BEAT * 32)):
            if i + k < len(nemudar_kik):
                nemudar_kik[i + k] = max(nemudar_kik[i + k], math.exp(-k * 0.22))

    def hat_zan(bar, beat, baz=False, tavan=1.0):
        m.ezafe(hat(tavan, baz), bar * BAR + beat * BEAT, pan=0.25, gan=1.0)

    # ── مقدمه (۰–۴): بمِ قلب + های‌هت + پد
    for b in range(4):
        beis_i = int((b * BAR) * SR)
        y = beis([A2,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0], 1)
        m.ezafe(y, b * BAR, gan=0.9)
        hat_zan(b, 2.0); hat_zan(b, 2.5); hat_zan(b, 3.5)
    m.ezafe(ped(AKKORHA[0], BAR * 4), 0.0, gan=1.0)

    # ── اوج‌گیری (۴–۱۲): کیک می‌آید + بیسِ کامل + آرپژ + رایزر
    rayzer_dor = 8 * BAR
    m.ezafe(rayzer(rayzer_dor), 4 * BAR, pan=0.0, gan=0.8)
    for b in range(4, 12):
        kik_zan(b, 0.0); kik_zan(b, 1.0, 0.85); kik_zan(b, 2.0); kik_zan(b, 3.0, 0.85)
        if b >= 8:
            esn = esnir(); m.ezafe(esn, b * BAR + 2 * BEAT, pan=-0.1)
        for s in range(8):
            hat_zan(b, s * 0.5, baz=(s % 4 == 3), tavan=0.8 if s % 2 else 1.0)
        by = beis(BEIS_DROP, 1)
        m.ezafe(by, b * BAR, gan=0.8)
    # آرپژِ اوج‌گیری — الگوی صعودی
    alg_arp = [A3, C4, E4, A4, C4, E4, A4, E4]
    for b in range(4, 12):
        for s in range(8):
            nem = alg_arp[s % len(alg_arp)] + (12 if b >= 10 else 0)
            m.ezafe(palak(nem, BEAT * 0.45), b * BAR + s * BEAT / 2, pan=0.35, gan=0.9,
                    delay=BEAT * 0.75, gan_delay=0.25)

    # ── ریختِ اول (۱۲–۲۸): همه‌چیز + ملودیِ A
    m.ezafe(kerash(), 12 * BAR, gan=1.0)
    for b in range(12, 28):
        kik_zan(b, 0.0); kik_zan(b, 1.0, 0.85); kik_zan(b, 2.0); kik_zan(b, 3.0, 0.85)
        m.ezafe(esnir(), b * BAR + 2 * BEAT, pan=-0.08)
        m.ezafe(kalap(), b * BAR + 2 * BEAT, pan=0.12)
        for s in range(8):
            hat_zan(b, s * 0.5, baz=(s % 8 == 6), tavan=0.85 if s % 2 else 1.0)
        m.ezafe(beis(BEIS_DROP, 1), b * BAR, gan=1.0)
        # ملودی
        miz = MEL_A[(b - 12) % len(MEL_A)]
        for s in range(16):
            nem = miz[s]
            if nem:
                toole = BEAT * 0.5
                # کشِ نت تا نتِ بعدی
                for s2 in range(s + 1, 16):
                    if miz[s2]:
                        toole = (s2 - s) * BEAT * 0.5 * 1.5
                        break
                else:
                    toole = (16 - s) * BEAT * 0.5 * 1.2
                m.ezafe(lide_zadan(nem, min(toole, BEAT * 3), vib=0.3 if (b - 12) % 8 in (2, 6) else 0.0),
                        b * BAR + s * BEAT * 0.5, pan=0.0, gan=1.0,
                        delay=BEAT * 0.375, gan_delay=0.28)
    # پد زیرِ ملودی
    for b in range(12, 28, 4):
        k = ((b - 12) // 4) % 4
        m.ezafe(ped(AKKORHA[k], BAR * 4), b * BAR, gan=0.8)

    # ── فرود (۲۸–۳۶): نفسِ تازه — پد + آرپژ + کیکِ آهسته
    for b in range(28, 36):
        kik_zan(b, 0.0, 0.7)
        for s in range(8):
            hat_zan(b, s * 0.5, tavan=0.55)
        m.ezafe(ped(AKKORHA[(b - 28) % 4], BAR), b * BAR, gan=1.0)
        alg = [A3, E4, C4, E4, A3, E4, D4, E4]
        for s in range(8):
            m.ezafe(palak(alg[s], BEAT * 0.5), b * BAR + s * BEAT / 2, pan=-0.3, gan=0.85,
                    delay=BEAT * 0.75, gan_delay=0.3)

    # ── ریختِ دوم (۳۶–۵۲): ملودیِ B با بیسِ اکتاوی
    m.ezafe(kerash(), 36 * BAR, gan=1.0)
    for b in range(36, 52):
        kik_zan(b, 0.0); kik_zan(b, 0.75, 0.6); kik_zan(b, 1.0, 0.85); kik_zan(b, 2.0)
        kik_zan(b, 3.0, 0.85); kik_zan(b, 3.5, 0.6)
        m.ezafe(esnir(), b * BAR + 2 * BEAT, pan=-0.08)
        m.ezafe(kalap(), b * BAR + 2 * BEAT, pan=0.12)
        for s in range(8):
            hat_zan(b, s * 0.5, baz=(s % 8 == 6), tavan=0.9 if s % 2 else 1.0)
        m.ezafe(beis(BEIS_DROP2, 1), b * BAR, gan=1.05)
        miz = MEL_B[(b - 36) % len(MEL_B)]
        for s in range(16):
            nem = miz[s]
            if nem:
                toole = BEAT * 0.5
                for s2 in range(s + 1, 16):
                    if miz[s2]:
                        toole = (s2 - s) * BEAT * 0.5 * 1.5
                        break
                else:
                    toole = (16 - s) * BEAT * 0.5 * 1.2
                m.ezafe(lide_zadan(nem, min(toole, BEAT * 3), vib=0.3 if (b - 36) % 8 in (2, 6) else 0.0),
                        b * BAR + s * BEAT * 0.5, pan=0.0, gan=1.05,
                        delay=BEAT * 0.375, gan_delay=0.28)
    for b in range(36, 52, 4):
        k = ((b - 36) // 4) % 4
        m.ezafe(ped(AKKORHA[k], BAR * 4), b * BAR, gan=0.7)

    # ── پایان (۵۲–۵۶): فروکشِ تمیز — لوپ‌پذیر به مقدمه
    for b in range(52, 56):
        kik_zan(b, 0.0, 0.75)
        hat_zan(b, 2.0); hat_zan(b, 3.5, tavan=0.6)
        m.ezafe(ped(AKKORHA[0], BAR), b * BAR, gan=0.9)
        m.ezafe(palak(A3, BEAT * 0.5), b * BAR + 3 * BEAT, pan=0.3)

    # sidechain + نهایی
    m.sidechain(nemudar_kik, omgh=0.42)
    return m.final()

def mootor_jadid():
    """غرشِ موتور — لوپِ بی‌درزِ ۲ ثانیه‌ای: اره‌های هارمونیک + لرزشِ AM + هیسِ هوا"""
    toole = 2.0
    t, n = til_zaman(toole)
    fr_bonyadi = 55.0
    y = np.zeros(n)
    for k, g in [(1, 0.5), (2, 0.34), (3, 0.22), (4, 0.14), (6, 0.09), (8, 0.05)]:
        fr = fr_bonyadi * k
        # هم‌بسته‌بودنِ لوپ: فقط هارمونیک‌های گویا روی 0.5Hz؟ — به‌جایش کراس‌فید می‌کنیم
        y += saw(fr, t) * g
    y += np.sin(2 * np.pi * fr_bonyadi / 2 * t) * 0.25   # ساب
    # لرزشِ نان‌هموارِ درجه
    y *= 0.85 + 0.15 * np.sin(2 * np.pi * 13.0 * t)
    # هیسِ هوا
    noght = np.random.default_rng(91).standard_normal(n)
    y += bandpass(noght, 700, 3000) * 0.05
    # کراس‌فیدِ ۵۰ هزارم‌ثانیه‌ای برای لوپِ بی‌درز
    nf = int(0.05 * SR)
    rampe = np.linspace(0, 1, nf)
    y[:nf] = y[:nf] * rampe + y[-nf:] * (1 - rampe)
    y = y[:n - nf] if False else y[:n]
    # فیلترِ گرم
    y = lowpass(y, 2400)
    m = np.max(np.abs(y))
    y = y / m * 0.85
    return y

def neveshtan_wav(masir, chap, rast, sr=SR):
    """WAV استریوی ۱۶-بیت"""
    import wave
    chap16 = (np.clip(chap, -1, 1) * 32767).astype(np.int16)
    rast16 = (np.clip(rast, -1, 1) * 32767).astype(np.int16)
    do = np.empty(len(chap16) * 2, dtype=np.int16)
    do[0::2] = chap16; do[1::2] = rast16
    with wave.open(masir, "wb") as w:
        w.setnchannels(2); w.setsampwidth(2); w.setframerate(sr)
        w.writeframes(do.tobytes())
    print(f"[ahang] WAV: {masir} ({os.path.getsize(masir)//1024} کیلوبایت)")

def neveshtan_wav_mono(masir, x, sr=SR):
    import wave
    x16 = (np.clip(x, -1, 1) * 32767).astype(np.int16)
    with wave.open(masir, "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(sr)
        w.writeframes(x16.tobytes())
    print(f"[ahang] WAV mono: {masir} ({os.path.getsize(masir)//1024} کیلوبایت)")

if __name__ == "__main__":
    var_maghaz = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "ema", "tizpa", "assets", "audio"))
    os.makedirs(var_maghaz, exist_ok=True)

    chap, rast = bi_tarane()
    toole = len(chap) / SR
    print(f"[ahang] طولِ قطعه: {toole:.1f} ثانیه ({toole/60:.1f} دقیقه)")
    wav_masir = "/tmp/music_nfs.wav"
    neveshtan_wav(wav_masir, chap, rast)
    ogg = os.path.join(var_maghaz, "music_nfs.ogg")
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", wav_masir,
                    "-c:a", "libvorbis", "-q:a", "5", ogg], check=True)
    print(f"[ahang] OGG: {ogg} ({os.path.getsize(ogg)//1024} کیلوبایت)")

    motor = mootor_jadid()
    wav_motor = os.path.join(var_maghaz, "motor_nfs.wav")
    neveshtan_wav_mono(wav_motor, motor)
