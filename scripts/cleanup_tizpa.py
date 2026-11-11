#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""پاک‌سازی نهایی تیز پا: برند نو + حجم کم + بدون هیچ نام سازنده"""
import io, os, glob, re, sys

B = "/home/z/my-project"
G = B + "/game"
fails = []

def patch(path, pairs):
    src = io.open(path, encoding="utf-8").read()
    for old, new in pairs:
        if old in src:
            src = src.replace(old, new)
        else:
            fails.append(path.split("/")[-1] + " :: " + old[:60])
    io.open(path, "w", encoding="utf-8").write(src)

# ── ۱) حذف کد مرده game.gd (جایگزین با race3d.gd شد) ──
for f in ["game.gd", "game.gd.uid"]:
    p = G + "/scripts/" + f
    if os.path.exists(p):
        os.remove(p)
        print("removed dead:", f)

# ── ۲) حذف اسپرایت‌های بی‌استفاده (۲۸+ مگ) ──
dead_sprites = []
dead_sprites += glob.glob(G + "/assets/sprites/*_top.png")
dead_sprites += [G + "/assets/sprites/map_%d.png" % i for i in range(4)]
dead_sprites += [G + "/assets/sprites/bg_sky.png", G + "/assets/sprites/bg_tehran.png",
                 G + "/assets/sprites/road_strip.png", G + "/assets/sprites/cone.png",
                 G + "/assets/sprites/ramp.png", G + "/assets/sprites/light_soft.png",
                 G + "/assets/sprites/passenger.png", G + "/assets/sprites/garage_bg.png",
                 G + "/assets/sprites/arian_side.png", G + "/assets/sprites/baran_side.png",
                 G + "/assets/sprites/ezhdeha_side.png", G + "/assets/sprites/karvan_side.png",
                 G + "/assets/sprites/sepand_side.png", G + "/assets/sprites/menu_bg.png"]
saved = 0
for p in dead_sprites:
    if os.path.exists(p):
        saved += os.path.getsize(p)
        os.remove(p)
        imp = p + ".import"
        if os.path.exists(imp):
            os.remove(imp)
print("sprites removed: %.1f MB" % (saved / 1048576.0))

# ── ۳) منو: وب‌پی مقدم بر پی‌ان‌جی ──
patch(G + "/scripts/menu.gd", [
    ('var tex := _safe_load("res://assets/sprites/menu_bg.png")\n        if tex == null:\n                tex = _safe_load("res://assets/sprites/menu_bg.webp")',
     'var tex := _safe_load("res://assets/sprites/menu_bg.webp")\n        if tex == null:\n                tex = _safe_load("res://assets/sprites/menu_bg.png")'),
])

# ── ۴) برند: car_brain — لقب‌ها و جملات ──
patch(G + "/scripts/car_brain.gd", [
    ('"nick": "بوقیِ شیطون"', '"nick": "شیطونِ محله"'),
    ('"nick": "بوقیِ آفتابی"', '"nick": "آفتابیِ محله"'),
    ('"برق پیش! بوقی تو راهه!"', '"برق پیش! تیز پا تو راهه!"'),
    ('"اشکال نداره، بوقی که همیشه برمی‌گرده"', '"اشکال نداره، قهرمان که همیشه برمی‌گرده"'),
    ('"اینم هدیه‌ی بوقی!', '"اینم هدیه‌ی هلیا!'),
])
# هر باقی‌مانده‌ی متنی «بوقی» در کامنت‌ها هم پاک شود
for gp in [G + "/scripts/car_brain.gd"]:
    src = io.open(gp, encoding="utf-8").read()
    src = src.replace("مغز بوقی", "مغز تیز پا").replace("بوقیِ", "تیزپایِ")
    io.open(gp, "w", encoding="utf-8").write(src)

# ── ۵) برند: globals — ماشین‌ها و پیش‌فرض پلاک ──
patch(G + "/scripts/globals.gd", [
    ('"id": "boghi", "name": "بوقی", "en": "Boghi",', '"id": "boghi", "name": "تیز پا", "en": "Tiz Pa",'),
    ('"desc": "پراید قرمز محله — سبک و چابک، همیشه گرسنه‌ی سبقت!"',
     '"desc": "ماشین تو — قرمز، سبک و همیشه گرسنه‌ی سبقت!"'),
    ('"id": "boghi_yellow", "name": "بوقی زرد", "en": "Boghi Sun",', '"id": "boghi_yellow", "name": "تیز پا زرد", "en": "Tiz Pa Sun",'),
    ('"desc": "داداش آفتابی بوقی — همان لبخند به رنگ خورشید!"', '"desc": "همان رفیق آفتابی — لبخند به رنگ خورشید!"'),
    ('plate_name = str(data.get("plate_name", "بوقی"))', 'plate_name = str(data.get("plate_name", "هلیا"))'),
])

# ── ۶) asset_vault — لاگ بی‌برند ──
patch(G + "/scripts/asset_vault.gd", [
    ('var txt := "سلام از ناخدای vault — بوقی!"', 'var txt := "تیز پا — vault سالم است"'),
])

# ── ۷) اکسپورت: نسخه/پکیج/نام/فقط arm64 ──
patch(G + "/export_presets.cfg", [
    ('architectures/armeabi-v7a=true', 'architectures/armeabi-v7a=false'),
    ('architectures/arm64-v8a=true', 'architectures/arm64-v8a=true'),
    ('version/code=16', 'version/code=17'),
    ('version/name="0.14"', 'version/name="0.15"'),
    ('package/unique_name="ir.emaroid.boghi"', 'package/unique_name="ir.tizpa.game"'),
    ('package/name="بوقی: تور شهرها"', 'package/name="تیز پا"'),
    ('export_path="/home/z/my-project/download/BoghiCityTour_v0.13.apk"',
     'export_path="/home/z/my-project/download/TizPa_v0.15.apk"'),
])

# ── ۸) gitignore تمیز ──
gi = """tools/
build/
download/
upload/
tool-results/
game/assets/sprites/*.png.import.tmp
*.apk
*.aab
*.tpz
__pycache__/
*.log
"""
io.open(B + "/.gitignore", "w", encoding="utf-8").write(gi)

if fails:
    print("FAILED:")
    for f in fails:
        print("  ✗", f)
    sys.exit(1)
print("cleanup OK")
