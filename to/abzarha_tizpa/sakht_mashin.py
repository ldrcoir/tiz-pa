# ─────────────────────────────────────────────────────────────────
# سدان طلایی «تیز پا» — مدل سه‌بعدی در بلندر، خروجی GLB
# مرجع: نقاشی ماشین زرد کاربر (سدان مدرن ایرانی، شیشه دودی، رینگ تیره)
# محورها: دماغه رو به -Y (در گودوت می‌شود +Z)، بالا +Z، عرض X
# شیشه = تفکیک ماده در خودِ لوفت — نه ورق جدا؛ پس هیچ‌وقت لبه‌اش نمی‌پرد
# ─────────────────────────────────────────────────────────────────
import bpy, bmesh, math, os
from mathutils import Vector, Matrix

AJOR_GLB = "/home/z/my-project/game/assets/models/tizpa.glb"

bpy.ops.wm.read_factory_settings(use_empty=True)

def mat_jadid(nam, rang, metallic=0.0, rough=0.5, emis=None, tavan=0.0):
    m = bpy.data.materials.new(nam)
    m.use_nodes = True
    bsdf = m.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*rang, 1.0)
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = rough
    if emis is not None:
        bsdf.inputs["Emission Color"].default_value = (*emis, 1.0)
        bsdf.inputs["Emission Strength"].default_value = tavan
    return m

M_RANG   = mat_jadid("rang_badane", (0.86, 0.62, 0.06), metallic=0.72, rough=0.28)
M_SHISHE = mat_jadid("shishe", (0.020, 0.024, 0.032), metallic=0.65, rough=0.07)
M_TIR    = mat_jadid("lastik", (0.048, 0.048, 0.052), rough=0.92)
M_RING   = mat_jadid("ring", (0.135, 0.135, 0.150), metallic=0.90, rough=0.34)
M_CHROM  = mat_jadid("chrom", (0.82, 0.83, 0.86), metallic=1.0, rough=0.18)
M_TIRIK  = mat_jadid("plastik", (0.055, 0.057, 0.062), rough=0.72)
M_CHER_J = mat_jadid("cheragh_jelo", (0.92, 0.91, 0.86), rough=0.15, emis=(1.0, 0.97, 0.82), tavan=2.4)
M_CHER_A = mat_jadid("cheragh_aqab", (0.52, 0.03, 0.03), rough=0.18, emis=(0.90, 0.05, 0.04), tavan=2.0)
M_LINER  = mat_jadid("liner", (0.030, 0.030, 0.034), rough=0.95)

# ═════════════ بدنه ═════════════
def kaf_ba_qoos(y):
    q = 0.0
    for markaz in (-1.45, 1.45):
        dy = abs(y - markaz)
        if dy < 0.62:
            t = 1.0 - (dy / 0.62) ** 2
            q = max(q, 0.46 * t ** 1.5)
    return 0.26 + q

IST = [
    (-2.31, 0.62, 0.56, 0.62),   # نوک دماغه
    (-2.22, 0.68, 0.60, 0.74),
    (-2.02, 0.72, 0.64, 0.82),   # جلوپنجره
    (-1.78, 0.76, 0.68, 0.86),   # شروع کاپوت
    (-1.58, 0.78, 0.70, 0.88),
    (-1.45, 0.80, 0.71, 0.885),  # قوس چرخ جلو
    (-1.28, 0.80, 0.72, 0.89),
    (-1.05, 0.84, 0.74, 0.895),  # کاپوت
    (-0.85, 0.88, 0.76, 0.90),   # پای شیشه‌جلو
    (-0.55, 1.02, 0.78, 0.905),
    (-0.18, 1.34, 0.79, 0.91),   # شیشه‌جلو
    ( 0.25, 1.46, 0.80, 0.91),   # سقف
    ( 0.62, 1.47, 0.81, 0.905),
    ( 0.95, 1.42, 0.82, 0.90),
    ( 1.28, 1.22, 0.82, 0.885),  # شیشه‌عقب
    ( 1.58, 1.05, 0.82, 0.86),   # لبه‌ی صندوق
    ( 1.88, 1.00, 0.81, 0.845),
    ( 2.14, 0.98, 0.78, 0.82),   # صندوق
    ( 2.26, 0.94, 0.72, 0.78),
    ( 2.31, 0.62, 0.58, 0.64),   # نوک ته
]

def saqf_dar(y):
    for i in IST:
        if i[0] >= y:
            return i[1]
    return IST[-1][1]

def profil(kaf, kamar, w, saqf):
    shane = saqf - 0.12 if saqf > kamar + 0.30 else kamar + 0.10
    return [
        (0.0, kaf),
        (w * 0.80, kaf),
        (w * 0.965, kaf + 0.10),
        (w, kamar - 0.16),
        (w * 0.99, kamar),
        (w * 0.93, kamar + 0.20),
        (w * 0.86, shane),
        (w * 0.70, saqf - 0.10),
        (w * 0.46, saqf),
        (w * 0.20, saqf + 0.008),
        (0.0, saqf + 0.012),
        (-w * 0.20, saqf + 0.008),
        (-w * 0.46, saqf),
        (-w * 0.70, saqf - 0.10),
        (-w * 0.86, shane),
        (-w * 0.93, kamar + 0.20),
        (-w * 0.99, kamar),
        (-w, kamar - 0.16),
        (-w * 0.965, kaf + 0.10),
        (-w * 0.80, kaf),
    ]

halqeha = []
for (y, saqf, kamar, w) in IST:
    halqeha.append([Vector((p[0], y, p[1])) for p in profil(kaf_ba_qoos(y), kamar, w, saqf)])

# خط زیر شیشه — کابین دودی از اینجا به بالاست؛ سقف طلایی می‌ماند
KHAT = [(-0.72, 1.00), (-0.30, 1.00), (0.95, 1.00), (1.30, 1.17), (1.52, 1.32)]

def khat_dar(y):
    if y <= KHAT[0][0]:
        return KHAT[0][1]
    for k in range(len(KHAT) - 1):
        if KHAT[k][0] <= y <= KHAT[k + 1][0]:
            t = (y - KHAT[k][0]) / (KHAT[k + 1][0] - KHAT[k][0])
            return KHAT[k][1] + (KHAT[k + 1][1] - KHAT[k][1]) * t
    return KHAT[-1][1]

def shishe_ast(y, z, x):
    if y < -0.72 or y > 1.52:
        return False
    if z < khat_dar(y):
        return False
    # نوار سقفِ مرکزی طلایی می‌ماند — ریل سقف پهن‌تر؛ شیشه تا ۱.۳۰
    if -0.05 <= y <= 0.95 and z > 1.30:
        return False
    return True

def loft(nam, halqeha, mateha, subsurf=True, shishe=False):
    m = bpy.data.meshes.new(nam)
    bm = bmesh.new()
    n = len(halqeha[0])
    shabake = [[bm.verts.new(p) for p in h] for h in halqeha]
    for mate in mateha:
        m.materials.append(mate)
    for k in range(len(halqeha) - 1):
        a, b = shabake[k], shabake[k + 1]
        for j in range(n):
            j2 = (j + 1) % n
            f = bm.faces.new((a[j], a[j2], b[j2], b[j]))
            if shishe:
                vasat = (a[j].co + a[j2].co + b[j2].co + b[j].co) / 4.0
                f.material_index = 1 if shishe_ast(vasat.y, vasat.z, vasat.x) else 0
    for idx in (0, len(halqeha) - 1):
        h = halqeha[idx]
        c = Vector((0, h[0].y, sum(p.z for p in h) / len(h)))
        markaz = bm.verts.new(c)
        ring = shabake[idx]
        for j in range(n):
            j2 = (j + 1) % n
            if idx == 0:
                bm.faces.new((markaz, ring[j2], ring[j]))
            else:
                bm.faces.new((markaz, ring[j], ring[j2]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bm.to_mesh(m)
    bm.free()
    o = bpy.data.objects.new(nam, m)
    bpy.context.collection.objects.link(o)
    if subsurf:
        mod = o.modifiers.new("sub", "SUBSURF")
        mod.levels = 1
        mod.render_levels = 1
    for p in o.data.polygons:
        p.use_smooth = True
    return o

badane = loft("badane", halqeha, [M_RANG, M_SHISHE], shishe=True)

# ═════════════ جزئیات ═════════════
def qute(nam, size, pos, mate, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_cube_add(size=1)
    o = bpy.context.active_object
    o.name = nam
    o.scale = size
    bpy.ops.object.transform_apply(scale=True)
    o.rotation_euler = tuple(math.radians(a) for a in rot)
    o.location = pos
    o.data.materials.append(mate)
    for p in o.data.polygons:
        p.use_smooth = False
    return o

def arz_badane(y, z):
    # نیم‌عرض بدنه در ارتفاع z — برای نشاندن پیلار روی شیشه
    for k in range(len(IST) - 1):
        (ya, saqf_a, kam_a, w_a), (yb, saqf_b, kam_b, w_b) = IST[k], IST[k + 1]
        if ya <= y <= yb:
            t = 0.0 if yb == ya else (y - ya) / (yb - ya)
            saqf, kamar, w = saqf_a + (saqf_b - saqf_a) * t, kam_a + (kam_b - kam_a) * t, w_a + (w_b - w_a) * t
            break
    shane = saqf - 0.12 if saqf > kamar + 0.30 else kamar + 0.10
    lagzha = [(kaf_ba_qoos(y), w * 0.80), (kaf_ba_qoos(y) + 0.10, w * 0.965), (kamar - 0.16, w),
              (kamar, w * 0.99), (kamar + 0.20, w * 0.93), (shane, w * 0.86),
              (saqf, w * 0.46), (saqf + 0.012, w * 0.20)]
    if z <= lagzha[0][0]:
        return lagzha[0][1]
    for k in range(len(lagzha) - 1):
        (z0, w0), (z1, w1) = lagzha[k], lagzha[k + 1]
        if z0 <= z <= z1:
            t2 = 0.0 if z1 == z0 else (z - z0) / (z1 - z0)
            return w0 + (w1 - w0) * t2
    return lagzha[-1][1]

# پیلار B — تکه‌ی رنگ‌بدنه روی شیشه‌ی پهلو (شیب به سمت داخل، مثل تومبل‌هوم)
for sx in (-1, 1):
    arz_p = arz_badane(0.24, 1.15)
    qute(f"pilar_B_{sx}", (0.016, 0.10, 0.44), Vector((sx * (arz_p + 0.010), 0.24, 1.15)), M_RANG, rot=(0, -sx * 13, 0))

# جلوپنجره‌ی کروم + چراغ جلو + مه‌شکن
qute("gril", (0.58, 0.05, 0.15), Vector((0, -2.305, 0.60)), M_CHROM)
qute("cheragh_j_r", (0.34, 0.06, 0.10), Vector((0.46, -2.24, 0.70)), M_CHER_J, rot=(8, 6, 0))
qute("cheragh_j_l", (0.34, 0.06, 0.10), Vector((-0.46, -2.24, 0.70)), M_CHER_J, rot=(8, -6, 0))
qute("spor_paeen", (1.50, 0.22, 0.14), Vector((0, -2.18, 0.34)), M_TIRIK)
qute("mahshekan_r", (0.14, 0.05, 0.07), Vector((0.58, -2.26, 0.38)), M_CHER_J)
qute("mahshekan_l", (0.14, 0.05, 0.07), Vector((-0.58, -2.26, 0.38)), M_CHER_J)
# چراغ عقب سراسری سرخ
qute("cheragh_a_r", (0.34, 0.05, 0.11), Vector((0.54, 2.24, 0.88)), M_CHER_A, rot=(-6, 4, 0))
qute("cheragh_a_l", (0.34, 0.05, 0.11), Vector((-0.54, 2.24, 0.88)), M_CHER_A, rot=(-6, -4, 0))
qute("navor_aqab", (0.52, 0.04, 0.07), Vector((0, 2.30, 0.90)), M_CHER_A)
qute("chrom_sanduq", (0.66, 0.03, 0.03), Vector((0, 2.28, 0.72)), M_CHROM)
# دستگیره‌ها + آینه‌ها + فین
for sy in (-0.42, 0.38):
    for sx in (-1, 1):
        qute(f"dastgire_{sy}_{sx}", (0.030, 0.17, 0.042), Vector((sx * 0.90, sy, 0.90)), M_CHROM)
for sx in (-1, 1):
    qute(f"ayene_{sx}", (0.055, 0.16, 0.09), Vector((sx * 0.93, -0.80, 1.00)), M_RANG, rot=(0, 0, sx * 10))
    qute(f"paye_ayene_{sx}", (0.04, 0.10, 0.035), Vector((sx * 0.86, -0.78, 0.955)), M_TIRIK)
qute("kuse", (0.05, 0.20, 0.075), Vector((0, 0.98, 1.42)), M_TIRIK, rot=(-14, 0, 0))

bpy.ops.mesh.primitive_cylinder_add(radius=0.048, depth=0.16, vertices=14)
egz = bpy.context.active_object
egz.name = "egzoz"
egz.rotation_euler = (math.radians(90), 0, 0)
egz.location = Vector((-0.48, 2.26, 0.30))
egz.data.materials.append(M_CHROM)
for p in egz.data.polygons:
    p.use_smooth = True

# لاینر تیره داخل قوس چرخ‌ها — جمع‌وجور، بیرون بدنه نمی‌زند
for nam, x, y in [("liner_jr", 0.70, -1.45), ("liner_jl", -0.70, -1.45),
                  ("liner_ar", 0.70, 1.45), ("liner_al", -0.70, 1.45)]:
    bpy.ops.mesh.primitive_cylinder_add(radius=0.42, depth=0.22, vertices=18)
    lin = bpy.context.active_object
    lin.name = nam
    lin.rotation_euler = (0, math.radians(90), 0)
    lin.location = Vector((x, y, 0.42))
    lin.data.materials.append(M_LINER)

# ═════════════ چرخ‌ها ═════════════
def charkh(nam, x, y):
    sn = 1.0 if x > 0 else -1.0
    qism = []
    bpy.ops.mesh.primitive_torus_add(major_radius=0.275, minor_radius=0.070,
                                     major_segments=26, minor_segments=12)
    t = bpy.context.active_object
    t.name = "lastik_" + nam
    t.rotation_euler = (0, math.radians(90), 0)
    bpy.ops.object.transform_apply(rotation=True)
    t.data.materials.append(M_TIR)
    for p in t.data.polygons:
        p.use_smooth = True
    qism.append(t)
    bpy.ops.mesh.primitive_cylinder_add(radius=0.205, depth=0.22, vertices=24)
    r = bpy.context.active_object
    r.name = "ring_" + nam
    r.rotation_euler = (0, math.radians(90), 0)
    bpy.ops.object.transform_apply(rotation=True)
    r.data.materials.append(M_RING)
    for p in r.data.polygons:
        p.use_smooth = True
    qism.append(r)
    for k in range(10):
        a = k * math.pi * 2 / 10
        bpy.ops.mesh.primitive_cube_add(size=1)
        s = bpy.context.active_object
        s.name = f"pare_{nam}_{k}"
        s.scale = (0.030, 0.30, 0.042)
        bpy.ops.object.transform_apply(scale=True)
        s.rotation_euler = (a, 0, 0)
        ofs = Matrix.Rotation(a, 4, 'X') @ Vector((0, 0.115, 0))
        s.location = Vector((sn * 0.13, ofs.y, ofs.z))
        s.data.materials.append(M_CHROM)
        qism.append(s)
    bpy.ops.mesh.primitive_cylinder_add(radius=0.062, depth=0.04, vertices=12)
    hb = bpy.context.active_object
    hb.name = "tope_" + nam
    hb.rotation_euler = (0, math.radians(90), 0)
    hb.location = (sn * 0.14, 0, 0)
    bpy.ops.object.transform_apply(rotation=True, location=True)
    hb.data.materials.append(M_CHROM)
    for p in hb.data.polygons:
        p.use_smooth = True
    qism.append(hb)
    bpy.ops.object.select_all(action='DESELECT')
    for o in qism:
        o.select_set(True)
    bpy.context.view_layer.objects.active = qism[0]
    bpy.ops.object.join()
    wh = bpy.context.active_object
    wh.name = nam
    wh.location = (x, y, 0.345)
    return wh

charkh("charkh_jelo_rast", -0.74, -1.45)
charkh("charkh_jelo_chap", 0.74, -1.45)
charkh("charkh_aqab_rast", -0.74, 1.45)
charkh("charkh_aqab_chap", 0.74, 1.45)

# ═════════════ ریشه + خروجی GLB ═════════════
rishe = bpy.data.objects.new("tizpa_root", None)
bpy.context.collection.objects.link(rishe)
for o in list(bpy.data.objects):
    if o.name != "tizpa_root":
        o.parent = rishe

os.makedirs(os.path.dirname(AJOR_GLB), exist_ok=True)
bpy.ops.export_scene.gltf(filepath=AJOR_GLB, export_format='GLB',
                          export_apply=True, export_extras=True)
print("GLB SAVED:", AJOR_GLB, os.path.getsize(AJOR_GLB) // 1024, "KB")
