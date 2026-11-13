#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
وصلهٔ بازی تیزپا: جوی‌استیکِ لمسی + مدل‌های سه‌بعدیِ اسپرت + آهنگِ جدید
ویرایشِ دقیقِ race3d.gd با لنگرهای کوتاه — بدونِ دست‌زدن به بقیه
"""
import re
import sys

MASIR = "/home/z/my-project/ema/tizpa/scripts/race3d.gd"
src = open(MASIR, encoding="utf-8").read()
shomare = [0]

def ja_nameh(l_anchor, matn_jadid, tajar=1):
    """جایگزینیِ دقیق: اولین فراوانیِ لنگر با متنِ تازه"""
    global src
    if src.count(l_anchor) < tajar:
        print(f"[khata] لنگر پیدا نشد: {l_anchor[:60]!r}")
        sys.exit(1)
    idx = 0
    for _ in range(tajar):
        idx = src.index(l_anchor, idx) + len(l_anchor)
    idx -= len(l_anchor)
    src = src[:idx] + matn_jadid + src[idx + len(l_anchor):]
    shomare[0] += 1
    print(f"[vasle {shomare[0]:02d}] {l_anchor[:52]!r} -> {len(matn_jadid)} کاراکتر")

# ── ۱) متغیرِ جوی‌استیک + تابعِ ویبره ──
ja_nameh(
    "var sh_dokmeha := {}                 #",
    "var joy_kontorol: Control = null     # جوی‌استیکِ رویِ صفحه — پایه + دسته‌گردان\nvar sh_dokmeha := {}                 #")

# ── ۲) زونِ چپ/راست → جوی‌استیک ──
ja_nameh(
    '''var x_chap := kenar + r_asli
        var x_gaz := W - kenar - r_asli''',
    '''var r_joy := clampf(H * 0.150, 78.0, 132.0)        # جوی‌استیکِ بزرگ — انالوگِ واقعی
        var x_joy := kenar + r_joy
        var y_joy := H - labe - r_joy
        var x_gaz := W - kenar - r_asli''')

ja_nameh(
    '''"chap": {"pos": Vector2(x_chap, y_paeen), "r": r_asli * 1.05, "col": Color(0.35, 0.45, 0.6, 0.60), "label": ""},
                "rast": {"pos": Vector2(x_chap + r_asli * 2.35, y_paeen), "r": r_asli * 1.05, "col": Color(0.35, 0.45, 0.6, 0.60), "label": ""},''',
    '''"joy": {"pos": Vector2(x_joy, y_joy), "r": r_joy, "col": Color(0.35, 0.45, 0.6, 0.60), "label": "فرمان"},''')

# ── ۳) حذفِ فلش‌های چپ/راست از رسمِ دکمه‌ها ──
ja_nameh(
    '''if nam == "chap" or nam == "rast":
                                # فلش پهن — بدون فونت، با مثلث
                                var samte: float = -1.0 if nam == "chap" else 1.0
                                var nowghat := PackedVector2Array([
                                        c2 + Vector2(-samte * 16.0, -22.0),
                                        c2 + Vector2(-samte * 16.0, 22.0),
                                        c2 + Vector2(samte * 20.0, 0.0),
                                ])
                                halqe.draw_colored_polygon(nowghat, Color(1, 1, 1, 0.92))
                        elif fnt_dokme != null:''',
    '''if fnt_dokme != null:''')

# ── ۴) جوی‌استیکِ تصویری — بعد از حلقهٔ دکمه‌ها ──
ja_nameh(
    '''        hud.add_child(eshare_gaz)

# جای دکمه‌ها''',
    '''        hud.add_child(eshare_gaz)

        # ── جوی‌استیکِ فرمان — پایه‌ی ثابت + دسته‌گردانِ انالوگ ──
        var j: Dictionary = zoonha["joy"]
        joy_kontorol = Control.new()
        joy_kontorol.position = j["pos"] - Vector2(j["r"], j["r"])
        joy_kontorol.size = Vector2(j["r"] * 2, j["r"] * 2)
        joy_kontorol.draw.connect(func():
                var c2 := Vector2(j["r"], j["r"])
                # پایه‌ی نیمه‌شفاف + حلقه‌ی طلاییِ مسابقه‌ای
                joy_kontorol.draw_circle(c2, j["r"], Color(0.04, 0.05, 0.08, 0.42))
                joy_kontorol.draw_arc(c2, j["r"] - 2.0, 0.0, TAU, 48, Color(0.96, 0.76, 0.25, 0.80), 3.0)
                joy_kontorol.draw_arc(c2, j["r"] * 0.62, 0.0, TAU, 40, Color(1, 1, 1, 0.13), 2.0)
                # چهار جهتِ راهنما
                for sam in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
                        joy_kontorol.draw_line(c2 + sam * j["r"] * 0.66, c2 + sam * j["r"] * 0.82, Color(1, 1, 1, 0.30), 3.0)
                # دسته‌گردان — با فرمانِ جاری جابه‌جا می‌شود
                var kh := meghdare_fermane_lamsi * j["r"] * 0.58
                var ja_daste := c2 + Vector2(kh, 0)
                joy_kontorol.draw_circle(ja_daste, j["r"] * 0.30, Color(1, 1, 1, 0.16))
                joy_kontorol.draw_circle(ja_daste, j["r"] * 0.26, Color(0.96, 0.76, 0.25, 0.92))
                # برچسبِ کوچکِ زیرِ پایه
                if fnt_dokme != null:
                        joy_kontorol.draw_string(fnt_dokme, Vector2(6, j["r"] * 2 - 10), "فرمان", HORIZONTAL_ALIGNMENT_CENTER, j["r"] * 2 - 12, 17, Color(1, 1, 1, 0.70)))
        joy_kontorol.mouse_filter = Control.MOUSE_FILTER_IGNORE
        hud.add_child(joy_kontorol)

# جای دکمه‌ها''')

# ── ۵) لمسِ جوی‌استیک در ورودی ──
ja_nameh(
    '''if zn == "chap" or zn == "rast" or zn != "":
                                # همه‌ی دکمه‌ها ناحیه‌ای مشخص دارند؛ کشیدن آزاد فقط وقتی روی هیچ دکمه‌ای نیستی
                                if zn != "":
                                        sh_dokmeha[zn] = t.index
                                        if zn == "nitro":
                                                nitro_rushan = true
                                        elif zn == "hb":
                                                dasti = true
                                        elif zn == "brake":
                                                paye_termoz = true
                                        elif zn == "gaz":
                                                gaz_feshorde = true
                                        return
                        if t.position.x < 430 and id_fermane_lamsi == -1:
                                id_fermane_lamsi = t.index
                                x0_fermane_lamsi = t.position.x
                                meghdare_fermane_lamsi = 0.0''',
    '''if zn == "joy":
                                # گرفتنِ جوی‌استیک — از همین‌جا به هر سو بکش
                                if id_fermane_lamsi == -1:
                                        id_fermane_lamsi = t.index
                                        x0_fermane_lamsi = t.position.x
                                        meghdare_fermane_lamsi = 0.0
                                return
                        if zn != "":
                                # همه‌ی دکمه‌ها ناحیه‌ی مشخص دارند
                                sh_dokmeha[zn] = t.index
                                if zn == "nitro":
                                        nitro_rushan = true
                                        _lerze(60)
                                elif zn == "hb":
                                        dasti = true
                                elif zn == "brake":
                                        paye_termoz = true
                                elif zn == "gaz":
                                        gaz_feshorde = true
                                return
                        # لمسِ هر جای دیگر در مسابقه = فرمانِ کششی — دستِ چپ آزاد است
                        if id_fermane_lamsi == -1 and halat == "race":
                                id_fermane_lamsi = t.index
                                x0_fermane_lamsi = t.position.x
                                meghdare_fermane_lamsi = 0.0''')

# ── ۶) کشیدنِ انالوگ با شعاعِ جوی‌استیک ──
ja_nameh(
    '''if d.index == id_fermane_lamsi:
                        meghdare_fermane_lamsi = clampf((d.position.x - x0_fermane_lamsi) / 160.0, -1.0, 1.0)''',
    '''if d.index == id_fermane_lamsi:
                        # شعاعِ جوی‌استیک = مسِ انالوگ؛ هرچه بزرگ‌تر، فرمان دقیق‌تر
                        var shoa := _zoonha()["joy"]["r"] * 0.80
                        meghdare_fermane_lamsi = clampf((d.position.x - x0_fermane_lamsi) / shoa, -1.0, 1.0)''')

# ── ۷) ترکیبِ فرمان — منطقه‌ی مرده + حذفِ چپ/راست ──
ja_nameh(
    '''var ks := _ferman_kibord()
        # فرمان = کشیدن انگشت + کلید + دکمه‌های چپ/راست
        fermane_dokme = (1.0 if sh_dokmeha.has("rast") else 0.0) - (1.0 if sh_dokmeha.has("chap") else 0.0)
        mizane_ferman = clampf(ks + meghdare_fermane_lamsi + fermane_dokme, -1.0, 1.0)''',
    '''var ks := _ferman_kibord()
        # فرمان = جوی‌استیکِ انالوگ (با منطقه‌ی مرده) + کلید
        var magh_lamsi := 0.0
        if absf(meghdare_fermane_lamsi) > 0.07:
                magh_lamsi = (meghdare_fermane_lamsi - signf(meghdare_fermane_lamsi) * 0.07) / 0.93
        fermane_dokme = 0.0
        mizane_ferman = clampf(ks + magh_lamsi + fermane_dokme, -1.0, 1.0)''')

# ── ۸) تازه‌کشیدنِ جوی‌استیک هر فریم ──
ja_nameh(
    '''func _hasteye_hud() -> void:
        if sanje_hud:
                sanje_hud.queue_redraw()''',
    '''func _hasteye_hud() -> void:
        if sanje_hud:
                sanje_hud.queue_redraw()
        if joy_kontorol != null:
                joy_kontorol.queue_redraw()   # دسته‌ی جوی‌استیک هر فریم جابه‌جا شود''')

# ── ۹) انتخابِ مدلِ سه‌بعدی بر اساس نوع ──
ja_nameh(
    '''func _sahne_mashin() -> PackedScene:
        if _sahne_glb == null and ResourceLoader.exists("res://assets/models/tizpa.glb"):
                _sahne_glb = load("res://assets/models/tizpa.glb")
        return _sahne_glb

func _mashin_besaz(rang: Color, kind := "sport", with_driver := false) -> Dictionary:
        var sahne := _sahne_mashin()''',
    '''func _sahne_mashin(kind := "sport") -> PackedScene:
        # مدل‌های سه‌بعدیِ اسپرتِ سبکِ NFS — اول مدلِ تازه، بعد سدانِ قدیمی
        var masir_jadid := "res://assets/models/mashin_supercar.glb" if kind == "supercar" else "res://assets/models/mashin_sport.glb"
        if ResourceLoader.exists(masir_jadid):
                return load(masir_jadid)
        if ResourceLoader.exists("res://assets/models/tizpa.glb"):
                return load("res://assets/models/tizpa.glb")
        return null

func _mashin_besaz(rang: Color, kind := "sport", with_driver := false) -> Dictionary:
        var sahne := _sahne_mashin(kind)''')

# ── ۱۰) رقیب‌ها: یک‌درمیانِ ابرخودرو و اسپرت ──
ja_nameh(
    'var rr := _mashin_besaz(RANG_RAQIBHA[r % RANG_RAQIBHA.size()], "sport", false)',
    'var rr := _mashin_besaz(RANG_RAQIBHA[r % RANG_RAQIBHA.size()], "supercar" if r % 2 == 0 else "sport", false)')

# ── ۱۱) شعلهٔ نیترو سرِ اگزوزِ جدید ──
ja_nameh(
    'shole.position = Vector3(-0.48, 0.30, -2.42)',
    'shole.position = Vector3(-0.42, 0.30, -2.50)')

# ── ۱۲) پلاک‌ها روی سپرِ مدلِ جدید ──
ja_nameh(
    'for qarar in [Vector3(0, 0.44, 2.335), Vector3(0, 0.52, -2.34)]:',
    'for qarar in [Vector3(0, 0.36, 2.345), Vector3(0, 0.44, -2.355)]')

# ── ۱۳) راننده در کابینِ عقب‌کشیدهٔ اسپرت ──
ja_nameh(
    'ranande.position = Vector3(0, 0.58, 0.28)',
    'ranande.position = Vector3(0, 0.56, -0.10)')

open(MASIR, "w", encoding="utf-8").write(src)
print(f"[tamam] {shomare[0]} وصله اعمال شد")
