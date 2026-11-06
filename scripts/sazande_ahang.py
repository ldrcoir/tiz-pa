# سازنده‌ی آهنگ تیز پا — ترک کامل دریفت/سینث‌ویو با حال‌وهوای ایرانی
# لایه‌ها: درام کامل (کیک/اسنر/های‌هت/فیل)، بیس پامپ‌دار، آرپژ ۱۶، ملودی حجاز، پد
# خروجی: music_loop.ogg — لوپ بی‌درز ۳۲ میزانی در ۱۰۰ BPM
import numpy as np, wave, os

SR = 44100
BPM = 100.0
BEAT = 60.0 / BPM          # 0.6 s
BAR = BEAT * 4.0           # 2.4 s
BARS = 32
DUR = BAR * BARS           # 76.8 s
N = int(DUR * SR)
L = np.zeros(N); R = np.zeros(N)

def env_exp(n, tau):
    return np.exp(-np.arange(n) / (tau * SR))

def note_hz(name):
    # نام نت مثل A4 یا Bb3 — فرکانس از شماره‌ی MIDI
    nam = name[:-1]; okt = int(name[-1])
    nadife = {"C":0,"C#":1,"Db":1,"D":2,"Eb":3,"E":4,"F":5,"F#":6,"G":7,"G#":8,"Ab":8,"A":9,"Bb":10,"B":11}[nam]
    midi = (okt + 1) * 12 + nadife
    return 440.0 * 2 ** ((midi - 69) / 12.0)

def add(sig, t0, gain=1.0, pan=0.0):
    i0 = int(t0 * SR)
    i1 = min(N, i0 + len(sig))
    if i1 <= i0: return
    seg = sig[:i1 - i0] * gain
    gl = gain * (1.0 - max(pan, 0) * 0.7)
    gr = gain * (1.0 + min(pan, 0) * 0.7)
    L[i0:i1] += seg * gl
    R[i0:i1] += seg * gr

# ── سازها ──────────────────────────────────────────────
def kick():
    n = int(0.30 * SR); t = np.arange(n) / SR
    f = 130 * np.exp(-t * 28) + 42
    ph = np.cumsum(f) / SR * 2 * np.pi
    s = np.sin(ph) * env_exp(n, 0.09)
    s += np.sin(ph * 2.02) * env_exp(n, 0.04) * 0.4
    return s * 1.0

def snare():
    n = int(0.24 * SR); t = np.arange(n) / SR
    noise = np.random.default_rng(7).uniform(-1, 1, n)
    k = 24
    lp = np.convolve(noise, np.ones(k) / k, 'same')
    hp = noise - lp
    body = np.sin(2 * np.pi * 190 * t) * env_exp(n, 0.05)
    return (hp * env_exp(n, 0.075) * 0.9 + body * 0.55) * 0.85

def hat(open_=False):
    d = 0.30 if open_ else 0.07
    n = int(d * SR)
    rng = np.random.default_rng(11 if open_ else 13)
    noise = rng.uniform(-1, 1, n)
    k = 3
    lp = np.convolve(noise, np.ones(k) / k, 'same')
    hp = noise - lp
    return hp * env_exp(n, d * 0.5 if open_ else 0.02) * 0.32

def bass_saw(f, d):
    n = int(d * SR); t = np.arange(n) / SR
    saw = 2 * ((f * t) % 1.0) - 1.0
    sq = np.sign(np.sin(2 * np.pi * f * 0.5 * t)) * 0.5
    s = saw * 0.75 + sq * 0.45
    lp = np.convolve(s, np.ones(6) / 6, 'same')
    return (lp * env_exp(n, d * 0.85) + np.sin(2 * np.pi * f * 0.5 * t) * env_exp(n, d * 0.9) * 0.6)

def pluck(f, d=0.22):
    n = int(d * SR); t = np.arange(n) / SR
    saw = 2 * ((f * t) % 1.0) - 1.0
    s = saw + 0.35 * np.sin(2 * np.pi * f * 2 * t)
    return s * env_exp(n, 0.055)

def lead(f, d):
    n = int(d * SR); t = np.arange(n) / SR
    s = (np.sin(2 * np.pi * f * t) * 0.55
         + 0.30 * (2 * ((f * 1.005 * t) % 1.0) - 1.0)
         + 0.30 * (2 * ((f * 0.995 * t) % 1.0) - 1.0)
         + 0.12 * np.sin(2 * np.pi * f * 2 * t))
    atk = np.minimum(t / 0.03, 1.0)
    return s * atk * env_exp(n, d * 0.75)

def pad_chord(freqs, d):
    n = int(d * SR); t = np.arange(n) / SR
    s = np.zeros(n)
    for f in freqs:
        s += np.sin(2 * np.pi * f * t) + 0.4 * np.sin(2 * np.pi * f * 2 * t)
    atk = np.minimum(t / (d * 0.3), 1.0)
    rel = np.minimum((d - t) / (d * 0.25), 1.0)
    return s / len(freqs) * atk * np.maximum(rel, 0) * 0.9

# دیلی ساده برای فضای صحنه
DLY = int(0.45 * SR)
def echo(buf, fb=0.34, mix=0.28):
    out = buf.copy()
    e = np.zeros_like(buf)
    e[DLY:] = buf[:-DLY] * fb
    for _ in range(3):
        e[DLY:] += e[:-DLY] * fb * 0.5
    return out * (1 - mix) + e * mix

# ── آهنگ‌سازی ───────────────────────────────────────────
# گام حجاز روی لا — رنگ ایرانی وسط ملودی
AKORDHA = [
    ["A2", ["A3", "C4", "E4"]],
    ["G2", ["G3", "B3", "D4"]],
    ["F2", ["F3", "A3", "C4"]],
    ["E2", ["E3", "G#3", "B3"]],
]

# ملودی: ۴ جمله — هر جمله ۸ میزان، نت‌ها بر حسب ضرب
j1 = [("A4",0.5),("Bb4",0.5),("C#5",1.0),("D5",0.5),("C#5",0.5),("Bb4",1.0),("A4",1.5),("E4",0.5),
      ("A4",0.5),("Bb4",0.5),("C#5",1.0),("E5",0.5),("F5",1.0),("E5",0.5),("C#5",1.0),("A4",1.5)]
j2 = [("A5",0.5),("G#5",0.5),("F5",1.0),("E5",0.5),("F5",0.5),("E5",1.0),("C#5",1.5),("Bb4",0.5),
      ("A4",0.5),("C#5",0.5),("E5",1.0),("G#5",0.5),("A5",2.0)]
j4 = [("A5",1.0),("F5",0.5),("E5",0.5),("C#5",1.0),("D5",0.5),("C#5",0.5),("Bb4",1.5),("A4",0.5),
      ("E4",0.5),("A4",1.0),("C#5",0.5),("E5",0.5),("A5",1.5),("A5",0.5)]
MEL = j1 + j2 + j1 + j4   # جمله‌ی اول دو بار — لوپ‌پسند

# ۱) درام و بیس و آرپژ — تمام ۳۲ میزان
for bar in range(BARS):
    tb = bar * BAR
    ak_i = AKORDHA[[0,0,1,1,2,2,3,3][bar % 8]]
    for beat in range(4):
        t0 = tb + beat * BEAT
        # کیک: چهار‌زمانی + کیک اضافی در میزان‌های پر
        add(kick(), t0, 0.95)
        if bar % 4 == 3 and beat == 3:
            add(kick(), t0 + BEAT * 0.5, 0.7)
        # اسنر روی ۲ و ۴
        if beat in (1, 3):
            add(snare(), t0, 0.5, pan=0.05)
        # های‌هت: ۸هم؛ آخر هر میزان باز
        for hh in range(2):
            add(hat(False), t0 + hh * BEAT * 0.5, 0.5, pan=-0.18)
        add(hat(True), tb + 3.5 * BEAT, 0.42, pan=0.22)
        # بیس — الگوی پامپ
        f = note_hz(ak_i[0])
        for bstep in range(2):
            add(bass_saw(f, BEAT * 0.42), t0 + bstep * BEAT * 0.5, 0.55)
        # آرپژ ۱۶ روی آکورد
        for st in range(4):
            nota = ak_i[1][[0,1,2,1][st]]
            add(pluck(note_hz(nota) * 2), t0 + st * BEAT * 0.25, 0.14, pan=0.3 if st % 2 else -0.3)

# ۲) پد آکوردی — هر دو میزان یک آکورد
for bar in range(0, BARS, 2):
    ak_i = AKORDHA[[0,0,1,1,2,2,3,3][bar % 8]]
    add(pad_chord([note_hz(x) for x in ak_i[1]], BAR * 2), bar * BAR, 0.16)

# ۳) ملودی — از میزان ۸ شروع (جمله‌ها ۸ میزانی)
t_mel = 8 * BAR
for nota, d_b in MEL:
    d = d_b * BEAT
    if t_mel + d > DUR - 0.1: break
    add(lead(note_hz(nota), d * 0.94), t_mel, 0.30, pan=0.08)
    t_mel += d

# ۴) فیل طبل پیش از برگشت لوپ — آخرین میزان
tb_fill = (BARS - 1) * BAR
for k in range(8):
    add(snare(), tb_fill + k * BAR / 8.0, 0.34 + k * 0.045, pan=0.1)

# اکو روی کل میکس برای فضای خیابان
L2 = echo(L); R2 = echo(R)
# پامپ سایدچین آرام — هر ضرب کیک، بقیه‌ی صدا کمی می‌نشیند
pamp = np.ones(N)
for bar in range(BARS):
    for beat in range(4):
        i0 = int((bar * BAR + beat * BEAT) * SR)
        i1 = min(N, i0 + int(0.14 * SR))
        pamp[i0:i1] = np.linspace(0.82, 1.0, i1 - i0)
L2 *= pamp; R2 *= pamp

# نرم‌سازی نهایی
mx = max(np.max(np.abs(L2)), np.max(np.abs(R2)))
g = 0.88 / mx
L3 = np.tanh(L2 * g * 1.1) * 0.92
R3 = np.tanh(R2 * g * 1.1) * 0.92
pcm = np.stack([L3, R3], axis=1)
pcm16 = (pcm * 32767).astype(np.int16)

wav_path = "/tmp/tizpa_music.wav"
with wave.open(wav_path, "wb") as w:
    w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes(pcm16.tobytes())
print("WAV OK:", wav_path, os.path.getsize(wav_path) // 1024, "KB", "dur=", DUR)
