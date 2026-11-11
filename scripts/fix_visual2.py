#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""فیکس بصری نسل ۲ — تب‌ها خودکار به ۸ فاصله تبدیل می‌شوند"""
import io, sys

P = "/home/z/my-project/game/scripts/race3d.gd"
src = io.open(P, encoding="utf-8").read()
fails = []

def sp(s):
    return s.replace("\t", "        ")

def rep(old, new):
    global src
    old, new = sp(old), sp(new)
    if old in src:
        src = src.replace(old, new, 1)
    else:
        fails.append(old[:60].replace("\n", "\\n"))

# ۱) نور ملایم‌تر
rep('env.ambient_light_energy = 1.15', 'env.ambient_light_energy = 0.9')
rep('gmat.albedo_color = L["ground"]', 'gmat.albedo_color = L["ground"].darkened(0.25)')

# ۲) آسفالت تیره + ساخت پیاده‌رو
rep("""	var mesh := st.commit()
	var mi := MeshInstance3D.new()
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.roughness = 0.92
	mesh.surface_set_material(0, mat)
	mi.mesh = mesh
	add_child(mi)""",
"""	var mesh := st.commit()
	var mi := MeshInstance3D.new()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.135, 0.135, 0.15)
	mat.vertex_color_use_as_albedo = true
	mat.roughness = 0.95
	mesh.surface_set_material(0, mat)
	mi.mesh = mesh
	add_child(mi)
	_sidewalks()""")

anchor = "func _road_marks() -> void:"
sidewalk = sp("""func _sidewalks() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var h: float = L["half"]
	var sw := 2.4
	for side in [-1.0, 1.0]:
		var i := 0
		while i < NS:
			var j := (i + 1) % NS
			var a0: Vector3 = P[i] + NRM[i] * side * h
			var b0: Vector3 = P[j] + NRM[j] * side * h
			var a1: Vector3 = P[i] + NRM[i] * side * (h + sw)
			var b1: Vector3 = P[j] + NRM[j] * side * (h + sw)
			var top := Color(0.58, 0.57, 0.54)
			var up := Vector3.UP
			var a0t := a0 + Vector3.UP * 0.12
			var b0t := b0 + Vector3.UP * 0.12
			var a1t := a1 + Vector3.UP * 0.12
			var b1t := b1 + Vector3.UP * 0.12
			st.set_color(top); st.set_normal(up); st.add_vertex(a0t)
			st.set_color(top); st.set_normal(up); st.add_vertex(b0t)
			st.set_color(top); st.set_normal(up); st.add_vertex(b1t)
			st.set_color(top); st.set_normal(up); st.add_vertex(a0t)
			st.set_color(top); st.set_normal(up); st.add_vertex(b1t)
			st.set_color(top); st.set_normal(up); st.add_vertex(a1t)
			var curb := Color(0.72, 0.70, 0.66)
			st.set_color(curb); st.set_normal(-NRM[i] * side); st.add_vertex(a0)
			st.set_color(curb); st.set_normal(-NRM[j] * side); st.add_vertex(b0)
			st.set_color(curb); st.set_normal(-NRM[j] * side); st.add_vertex(b0t)
			st.set_color(curb); st.set_normal(-NRM[i] * side); st.add_vertex(a0)
			st.set_color(curb); st.set_normal(-NRM[j] * side); st.add_vertex(b0t)
			st.set_color(curb); st.set_normal(-NRM[i] * side); st.add_vertex(a0t)
			i += 1
	var mesh := st.commit()
	mesh.surface_set_material(0, _vcol_mat(false))
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	add_child(mi)

""")
rep(anchor, sidewalk + anchor)

# ۳) فلش فرمان با bind
rep("""	# فلش‌های فرمان
	for side in [-1.0, 1.0]:
		var ar := Control.new()
		if side < 0:
			ar.position = Vector2(30, 720 - 170)
		else:
			ar.position = Vector2(240, 720 - 170)
		ar.size = Vector2(110, 110)
		ar.draw.connect(func():
			var pts := PackedVector2Array()
			var cx := 55.0
			var cy := 55.0
			var s: float = side
			pts.append(Vector2(cx - s * 30, cy - 34))
			pts.append(Vector2(cx - s * 30, cy + 34))
			pts.append(Vector2(cx + s * 34, cy))
			ar.draw_colored_polygon(pts, Color(1, 1, 1, 0.35)))
		ar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hud.add_child(ar)""",
"""	# فلش فرمان — bind جهت
	for side in [-1.0, 1.0]:
		var ar := Control.new()
		if side < 0:
			ar.position = Vector2(30, 720 - 170)
		else:
			ar.position = Vector2(240, 720 - 170)
		ar.size = Vector2(110, 110)
		ar.draw.connect(_draw_steer_arrow.bind(ar, side))
		ar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hud.add_child(ar)""")

rep("func _build_touch_controls() -> void:",
sp("""func _draw_steer_arrow(ar: Control, side: float) -> void:
	var pts := PackedVector2Array()
	var cx := 55.0
	var cy := 55.0
	pts.append(Vector2(cx - side * 30.0, cy - 34.0))
	pts.append(Vector2(cx - side * 30.0, cy + 34.0))
	pts.append(Vector2(cx + side * 34.0, cy))
	ar.draw_colored_polygon(pts, Color(1, 1, 1, 0.35))

func _build_touch_controls() -> void:"""))

# ۴) زمان‌بندی عکس‌ها
rep('var marks := [[0.5, "countdown"], [4.6, "chase"], [5.4, "drift"], [7.6, "nitro"], [10.5, "city"]]',
    'var marks := [[1.7, "countdown"], [4.8, "chase"], [5.7, "drift"], [7.9, "nitro"], [11.5, "city"]]')

io.open(P, "w", encoding="utf-8").write(src)
if fails:
    print("FAILED:")
    for f in fails:
        print("  X", f)
    sys.exit(1)
print("visual round-2 OK")
