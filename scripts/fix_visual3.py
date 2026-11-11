#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""راند ۳ پولیش بصری"""
import io, sys

P = "/home/z/my-project/game/scripts/race3d.gd"
src = io.open(P, encoding="utf-8").read()
fails = []

def rep(old, new):
    global src
    if old in src:
        src = src.replace(old, new, 1)
    else:
        fails.append(old[:60].replace("\n", "\\n"))

# ۱) عدد سرعت: زیر مرکز گیج (عقربه رد نشود)
rep('g.draw_string(f, c + Vector2(-46, 6), str(kmh), HORIZONTAL_ALIGNMENT_CENTER, 92, 44, Color(1, 1, 1))',
    'g.draw_string(f, c + Vector2(-46, 52), str(kmh), HORIZONTAL_ALIGNMENT_CENTER, 92, 46, Color(1, 1, 1))')

# ۲) فلش‌ها: بدون حلقه — دو بلوک صریح
rep("""	# فلش فرمان — bind جهت
	for side in [-1.0, 1.0]:
		var ar := Control.new()
		if side < 0:
			ar.position = Vector2(30, 720 - 170)
		else:
			ar.position = Vector2(240, 720 - 170)
		ar.size = Vector2(110, 110)
		ar.draw.connect(_draw_steer_arrow.bind(ar, side))
		ar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hud.add_child(ar)""",
"""	# فلش فرمان — دو بلوک صریح (بدون حلقه/capture)
	var ar_l := Control.new()
	ar_l.position = Vector2(30, 720 - 170)
	ar_l.size = Vector2(110, 110)
	ar_l.draw.connect(_draw_steer_arrow.bind(ar_l, -1.0))
	ar_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(ar_l)
	var ar_r := Control.new()
	ar_r.position = Vector2(240, 720 - 170)
	ar_r.size = Vector2(110, 110)
	ar_r.draw.connect(_draw_steer_arrow.bind(ar_r, 1.0))
	ar_r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(ar_r)""")

# ۳) نور و رنگ: خورشید کمی پایین‌تر، پالت‌ها اشباع‌تر
rep('sun.light_energy = L["sun_e"]', 'sun.light_energy = L["sun_e"] * 0.84')
rep('mat.albedo_color = Color(0.135, 0.135, 0.15)', 'mat.albedo_color = Color(0.145, 0.14, 0.135)')

# پالت ساختمان هر مرحله: کمی تیره‌تر تا سفید نشود
for old_c, new_c in [
    ("Color(0.82, 0.74, 0.62), Color(0.75, 0.62, 0.52), Color(0.68, 0.68, 0.64), Color(0.86, 0.80, 0.70)",
     "Color(0.72, 0.62, 0.48), Color(0.64, 0.50, 0.40), Color(0.56, 0.56, 0.52), Color(0.76, 0.68, 0.56)"),
    ("Color(0.78, 0.60, 0.44), Color(0.70, 0.52, 0.40), Color(0.82, 0.70, 0.55), Color(0.62, 0.46, 0.38)",
     "Color(0.70, 0.50, 0.34), Color(0.60, 0.42, 0.30), Color(0.74, 0.60, 0.44), Color(0.52, 0.36, 0.28)"),
    ("Color(0.72, 0.72, 0.74), Color(0.64, 0.66, 0.70), Color(0.80, 0.76, 0.70), Color(0.58, 0.60, 0.62)",
     "Color(0.62, 0.62, 0.66), Color(0.54, 0.56, 0.62), Color(0.72, 0.66, 0.58), Color(0.48, 0.50, 0.54)"),
    ("Color(0.85, 0.70, 0.55), Color(0.78, 0.62, 0.50), Color(0.88, 0.76, 0.62), Color(0.70, 0.58, 0.48)",
     "Color(0.78, 0.58, 0.42), Color(0.68, 0.50, 0.38), Color(0.82, 0.66, 0.50), Color(0.60, 0.46, 0.36)"),
    ("Color(0.80, 0.68, 0.56), Color(0.72, 0.60, 0.52), Color(0.86, 0.74, 0.60), Color(0.66, 0.56, 0.50)",
     "Color(0.74, 0.58, 0.44), Color(0.62, 0.50, 0.42), Color(0.80, 0.64, 0.48), Color(0.56, 0.46, 0.40)"),
]:
    rep(old_c, new_c)

# ۴) شمارش معکوس درشت‌تر
rep('lbl_center.add_theme_font_size_override("font_size", 120)', 'lbl_center.add_theme_font_size_override("font_size", 150)')

# ۵) زمان‌بندی عکس: دریفت داخل پنجره‌ی دستی (۴.۰–۵.۴)
rep('var marks := [[1.7, "countdown"], [4.8, "chase"], [5.7, "drift"], [7.9, "nitro"], [11.5, "city"]]',
    'var marks := [[1.7, "countdown"], [3.7, "chase"], [5.0, "drift"], [7.9, "nitro"], [11.5, "city"]]')

io.open(P, "w", encoding="utf-8").write(src)
if fails:
    print("FAILED:")
    for f in fails:
        print("  X", f)
    sys.exit(1)
print("round-3 OK")
