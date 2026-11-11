#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""فیکس نوع + حذف ترافیک — نسخه‌ی space-indented (فایل ۸-فاصله‌ای است)"""
import io, re, sys

P = "/home/z/my-project/game/scripts/race3d.gd"
src = io.open(P, encoding="utf-8").read()
fails = []

def rep(old, new):
    global src
    if old in src:
        src = src.replace(old, new, 1)
    else:
        fails.append(old[:70].replace("\n", "\\n"))

# ۱) نوع‌ها
rep("                var t := u - floor(u)", "                var t: float = u - floor(u)")
rep("                        var inward := -NRM[i] * side * 1.5",
    "                        var inward: Vector3 = -NRM[i] * side * 1.5")
rep("                        var a2 := a + inward", "                        var a2: Vector3 = a + inward")
rep("                        var b2 := b + (-NRM[j] * side * 1.5)",
    "                        var b2: Vector3 = b + (-NRM[j] * side * 1.5)")
rep("        for arr in skid_pts:\n                var n := arr.size()",
    "        for arr in skid_pts:\n                var n: int = arr.size()")
rep("                        var s := side", "                        var s: float = side")

# ۲) اسپان ترافیک — کل بلوک
m = re.search(r"(        # ترافیک زنده دوطرفه\n(?:            .*\n|\n)+?)(?=        # رد لاستیک\n)", src)
if m:
    src = src.replace(m.group(1), "")
else:
    fails.append("traffic spawn block")

# ۳) فراخوانی
rep("                _physics_core(dt)\n                _rivals_core(dt)\n                _traffic_core(dt)",
    "                _physics_core(dt)\n                _rivals_core(dt)")

# ۴) تابع _traffic_core — از تعریف تا خط خالی بعدی
m = re.search(r"func _traffic_core\(dt: float\) -> void:\n(?:.*\n)*?\n\n", src)
if m:
    src = src.replace(m.group(0), "")
else:
    fails.append("_traffic_core func")

# ۵) متغیر
rep("var traffic: Array = []          # {root, s, lat, dir, vf, kind}\n", "")

io.open(P, "w", encoding="utf-8").write(src)

# ۶) راهنما: خط تاکسی
M = "/home/z/my-project/game/scripts/menu.gd"
src = io.open(M, encoding="utf-8").read()
old = '                "مراقب تاکسی‌ها و وانت‌ها باش — خوردن به آن‌ها سرعتت را می‌گیرد.",\n'
if old in src:
    src = src.replace(old, "")
    io.open(M, "w", encoding="utf-8").write(src)
    print("menu guide line removed")

if fails:
    print("FAILED:")
    for f in fails:
        print("  X", f)
    sys.exit(1)
print("ALL OK — traffic gone, types fixed")
