#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ساخت مدلِ سه‌بعدیِ ماشین‌های مسابقه‌ای به سبک NFS — خروجی GLB برای گودوت ۴
بدنهٔ لوفت‌شده از مقطع‌های نرم + کابینِ شیشه‌ای + وینگ + رینگِ پره‌دار + چراغ‌های نئونی
خروجی‌ها:
  ema/tizpa/assets/models/mashin_sport.glb     — کوپهٔ اسپرت (ماشین بازیکن)
  ema/tizpa/assets/models/mashin_supercar.glb  — ابرخودرو (رقبا)
قراردادهای بازی:
  گره‌های چرخ: charkh_jelo_* / charkh_paeen_*  (چرخش حول X، فرمانِ جلوها حول Y)
  متریال «rang_badane» = رنگ‌بدنه — بازی فقط همین را بازرنگ می‌کند
  جلوی ماشین: +Z  |  مثلث‌ها: پادساعت‌گرد دیده از بیرون  |  واحد: متر
"""
import json
import math
import os
import struct
import numpy as np

# ═══════════════ متریال‌ها ═══════════════
def mate(nam, rang, metal=0.1, rough=0.45, emiss=None, double=False):
    m = {"name": nam, "pbrMetallicRoughness": {
        "baseColorFactor": [rang[0], rang[1], rang[2], 1.0],
        "metallicFactor": metal, "roughnessFactor": rough}}
    if emiss:
        m["emissiveFactor"] = [float(e) for e in emiss]
    if double:
        m["doubleSided"] = True
    return m

M_BADANE  = mate("rang_badane",  [0.95, 0.72, 0.05], 0.55, 0.30)          # بازرنگ می‌شود
M_SHISHE  = mate("rang_shishe",  [0.045, 0.065, 0.09], 0.9, 0.08)
M_TIR     = mate("rang_tir",     [0.035, 0.035, 0.04], 0.2, 0.75)
M_CHERAGH = mate("rang_cheragh", [0.93, 0.96, 1.0], 0.1, 0.2, emiss=[1.0, 0.95, 0.8])
M_TOHEL   = mate("rang_tohelang",[0.82, 0.04, 0.03], 0.1, 0.25, emiss=[0.85, 0.05, 0.03])
M_KROM    = mate("rang_krom",    [0.82, 0.84, 0.88], 1.0, 0.18)
M_LASTIK  = mate("rang_lastik",  [0.05, 0.05, 0.055], 0.0, 0.92)
M_RING    = mate("rang_ring",    [0.70, 0.72, 0.77], 1.0, 0.30)
M_TORMOZ  = mate("rang_tormoz",  [0.12, 0.12, 0.13], 0.9, 0.45)
M_RIN     = mate("rang_rin_rang",[0.85, 0.68, 0.25], 0.9, 0.32)
M_CHAH    = mate("rang_chah",    [0.03, 0.03, 0.035], 0.2, 0.8, double=True)

# ═══════════════ ریاضیاتِ مش ═══════════════
def normal_narm(pos, idx):
    """نرمالِ نرم — میانگینِ نرمالِ وجه‌ها روی رأس‌ها"""
    p = np.asarray(pos, np.float64)
    i = np.asarray(idx, np.int64).reshape(-1, 3)
    fn = np.cross(p[i[:, 1]] - p[i[:, 0]], p[i[:, 2]] - p[i[:, 0]])
    ln = np.linalg.norm(fn, axis=1); ln[ln == 0] = 1.0
    fn = fn / ln[:, None]
    n = np.zeros_like(p)
    for k in range(3):
        np.add.at(n, i[:, k], fn)
    ln2 = np.linalg.norm(n, axis=1); ln2[ln2 == 0] = 1.0
    return (n / ln2[:, None]).astype(np.float32)

def qute(c, s, ry=0.0, rz=0.0, rx=0.0):
    """جعبه با نرمالِ تخت — c مرکز، s اندازهٔ کامل، چرخش RX→RY→RZ"""
    hx, hy, hz = s[0] / 2, s[1] / 2, s[2] / 2
    v = np.array([[x, y, z] for x in (-hx, hx) for y in (-hy, hy) for z in (-hz, hz)])
    Rx = np.array([[1,0,0],[0,math.cos(rx),-math.sin(rx)],[0,math.sin(rx),math.cos(rx)]])
    Ry = np.array([[math.cos(ry),0,math.sin(ry)],[0,1,0],[-math.sin(ry),0,math.cos(ry)]])
    Rz = np.array([[math.cos(rz),-math.sin(rz),0],[math.sin(rz),math.cos(rz),0],[0,0,1]])
    R = Rz @ Ry @ Rx
    v = (v @ R.T) + np.asarray(c)
    dirs = {'+z':[0,0,1],'-z':[0,0,-1],'+y':[0,1,0],'-y':[0,-1,0],'+x':[1,0,0],'-x':[-1,0,0]}
    ns = {a: (R @ np.array(d)).tolist() for a, d in dirs.items()}
    fac = [(0,1,3,2,'-x'),(4,6,7,5,'+x'),(0,4,5,1,'-y'),(2,3,7,6,'+y'),(0,2,6,4,'-z'),(1,5,7,3,'+z')]
    pos, nrm, idx = [], [], []
    for a,b,c2,d2,dl in fac:
        o = len(pos)
        pos += [v[a],v[b],v[c2],v[d2]]
        n = ns[dl]; nrm += [n]*4
        idx += [o,o+1,o+2, o,o+2,o+3]
    return [np.asarray(p, np.float64) for p in pos], nrm, idx

def ostovane(r, h, seg=20, cap_bala=True, cap_paeen=True):
    """استوانه با محور Y — کلاهک‌ها کامل؛ مثلث‌ها رو به بیرون"""
    th = np.linspace(0, 2*math.pi, seg+1)[:-1]
    sn, cs = np.sin(th), np.cos(th)
    pos, nrm, idx = [], [], []
    o = len(pos)
    for y in (-h/2, h/2):
        for k in range(seg):
            pos.append([r*sn[k], y, r*cs[k]]); nrm.append([sn[k], 0, cs[k]])
    for k in range(seg):
        k2 = (k+1) % seg
        idx += [o+k, o+seg+k2, o+seg+k,  o+k, o+k2, o+seg+k2]
    if cap_paeen:
        o = len(pos)
        pos.append([0,-h/2,0]); nrm.append([0,-1,0])
        for k in range(seg):
            pos.append([r*sn[k],-h/2,r*cs[k]]); nrm.append([0,-1,0])
        for k in range(seg):
            idx += [o, o+1+(k+1)%seg, o+1+k]
    if cap_bala:
        o = len(pos)
        pos.append([0,h/2,0]); nrm.append([0,1,0])
        for k in range(seg):
            pos.append([r*sn[k],h/2,r*cs[k]]); nrm.append([0,1,0])
        for k in range(seg):
            idx += [o, o+1+k, o+1+(k+1)%seg]
    return [np.asarray(p, np.float64) for p in pos], nrm, idx

def ostovane_z(x, y, z, r, h, seg=12):
    """استوانه با محور Z — برای اگزوز"""
    th = np.linspace(0, 2*math.pi, seg+1)[:-1]
    sn, cs = np.sin(th), np.cos(th)
    pos, nrm, idx = [], [], []
    o = len(pos)
    for zz in (z-h/2, z+h/2):
        for k in range(seg):
            pos.append([x+r*sn[k], y+r*cs[k], zz]); nrm.append([sn[k], cs[k], 0])
    for k in range(seg):
        k2 = (k+1) % seg
        idx += [o+k, o+seg+k2, o+seg+k,  o+k, o+k2, o+seg+k2]
    return [np.asarray(p, np.float64) for p in pos], nrm, idx

def be_charkhes_ax(pos, nrm):
    """چرخاندنِ محورِ Y به X — برای چاه‌چرخ"""
    R = np.array([[0,-1,0],[1,0,0],[0,0,1]], np.float64)  # (x,y,z)->(-y,x,z)
    return [(R @ np.asarray(p)) for p in pos], [(R @ np.asarray(n)).tolist() for n in nrm]

# ═══════════════ لوفت ═══════════════
def gozar_badane(y_b, y_t, w):
    """مقطعِ گردِ بدنه — حلقهٔ بستهٔ پادساعت‌گرد دیده از +Z"""
    pts = [
        (0.0, y_b), (w*0.55, y_b), (w*0.88, y_b+0.02), (w, y_b+0.16),
        (w, (y_b+y_t)/2),
        (w*0.97, y_t-0.08), (w*0.72, y_t-0.01), (w*0.36, y_t), (0.0, y_t),
    ]
    chap = [(-x, y) for x, y in reversed(pts[1:-1])]
    return pts + chap  # ۱۶ نقطه

def gozar_kabin(y_b, y_t, w):
    pts = [
        (0.0, y_b), (w*0.62, y_b), (w*0.94, y_b+0.05),
        (w, (y_b+y_t)/2),
        (w*0.80, y_t-0.03), (w*0.42, y_t), (0.0, y_t),
    ]
    chap = [(-x, y) for x, y in reversed(pts[1:-1])]
    return pts + chap  # ۱۲ نقطه

def loft(istgahha):
    """هر ایستگاه = (z, نقاطِ مقطع) — مشِ بستهٔ نرم؛ مثلث‌ها رو به بیرون"""
    pos, idx = [], []
    N = len(istgahha[0][1])
    for z, pts in istgahha:
        assert len(pts) == N, f"تعدادِ نقطهٔ مقطع ناهماهنگ: {len(pts)} ≠ {N}"
        for x, y in pts:
            pos.append((x, y, z))
    S = len(istgahha)
    for s in range(S-1):
        for k in range(N):
            k2 = (k+1) % N
            a = s*N+k; b = s*N+k2; c = (s+1)*N+k2; d = (s+1)*N+k
            idx += [a, b, c,  a, c, d]
    nrm = normal_narm(pos, idx)
    return [np.asarray(p, np.float64) for p in pos], [list(map(float, n)) for n in nrm], idx

# ═══════════════ پروفایلِ هر ماشین (z، پایین، بالا، نیم‌پهنا) ═══════════════
PROF_SPORT = [
    (-2.34, 0.30, 0.58, 0.58),
    (-2.28, 0.18, 0.66, 0.74),
    (-2.10, 0.15, 0.72, 0.90),
    (-1.75, 0.14, 0.76, 0.99),
    (-1.20, 0.13, 0.75, 1.02),
    (-0.60, 0.13, 0.73, 1.00),
    ( 0.00, 0.13, 0.71, 0.99),
    ( 0.60, 0.13, 0.68, 0.97),
    ( 1.15, 0.14, 0.63, 0.93),
    ( 1.60, 0.15, 0.58, 0.87),
    ( 1.95, 0.17, 0.54, 0.78),
    ( 2.18, 0.21, 0.50, 0.64),
    ( 2.34, 0.27, 0.46, 0.44),
]
PROF_SUPERCAR = [
    (-2.34, 0.30, 0.52, 0.62),
    (-2.28, 0.16, 0.60, 0.80),
    (-2.08, 0.13, 0.66, 0.94),
    (-1.72, 0.12, 0.70, 1.03),
    (-1.15, 0.12, 0.69, 1.06),
    (-0.55, 0.12, 0.66, 1.03),
    ( 0.05, 0.12, 0.63, 1.01),
    ( 0.65, 0.12, 0.60, 0.98),
    ( 1.20, 0.13, 0.56, 0.93),
    ( 1.70, 0.15, 0.52, 0.85),
    ( 2.05, 0.17, 0.48, 0.74),
    ( 2.26, 0.22, 0.44, 0.56),
    ( 2.34, 0.28, 0.40, 0.38),
]
KABIN_SPORT = [
    (-1.42, 0.64, 0.78, 0.60),
    (-1.10, 0.68, 0.96, 0.72),
    (-0.55, 0.66, 1.04, 0.76),
    ( 0.10, 0.64, 1.04, 0.75),
    ( 0.66, 0.62, 0.92, 0.68),
    ( 1.05, 0.60, 0.76, 0.56),
    ( 1.28, 0.59, 0.62, 0.40),
]
KABIN_SUPERCAR = [
    (-1.45, 0.58, 0.72, 0.64),
    (-1.12, 0.62, 0.92, 0.76),
    (-0.55, 0.60, 1.00, 0.80),
    ( 0.12, 0.58, 1.00, 0.79),
    ( 0.70, 0.56, 0.88, 0.72),
    ( 1.10, 0.54, 0.72, 0.60),
    ( 1.36, 0.53, 0.58, 0.42),
]

# ═══════════════ چرخ ═══════════════
def charkh_sakht(r=0.345, panh=0.26):
    """بخش‌های چرخ در فضایِ محلی — محور Y؛ گرهٔ GLB با چرخشِ Z+90 می‌چرخاندش"""
    qismha = {}
    qismha["tir"]   = (*ostovane(r, panh, 22), M_LASTIK)
    qismha["ring"]  = (*ostovane(r*0.62, panh*1.04, 18), M_RING)
    qismha["disc"]  = (*ostovane(r*0.46, panh*0.5, 16), M_TORMOZ)
    pos, idx = [], []
    for pth in range(6):
        a = pth * math.tau / 6
        c = (math.cos(a)*r*0.30, 0, math.sin(a)*r*0.30)
        bp, bn, bi = qute(c, (r*0.58, panh*0.36, 0.06), ry=-a)
        o = len(pos); pos += bp; idx += [o+k for k in bi]
    qismha["pare"]  = (pos, [list(map(float, n)) for n in normal_narm(pos, idx)], idx, M_RING)
    qismha["halge"] = (*ostovane(r*0.63, panh*0.4, 18), M_RIN)
    return qismha

# ═══════════════ غالفِ GLB ═══════════════
class GLB:
    def __init__(self):
        self.nodes = [{"name": "mashin"}]
        self.meshes = []
        self.materials = []
        self.buf = bytearray()
        self.bufferviews = []
        self.accessors = []
        self._mate_idx = {}
        self.bacheha_rishe = []   # فقط گره‌های سطحِ بالا — بچه‌های چرخ به محورشان وصل‌اند

    def _node(self, name, mesh=None, translation=None, rotation=None, children=None):
        n = {"name": name}
        if mesh is not None:
            n["mesh"] = mesh
        if translation is not None:
            n["translation"] = [float(t) for t in translation]
        if rotation is not None:
            n["rotation"] = [float(r) for r in rotation]
        if children is not None:
            n["children"] = [int(c) for c in children]
        self.nodes.append(n)
        return len(self.nodes) - 1

    def mate_id(self, m):
        if m["name"] not in self._mate_idx:
            self._mate_idx[m["name"]] = len(self.materials)
            self.materials.append(m)
        return self._mate_idx[m["name"]]

    def _bife(self, dade, target):
        self.buf += b"\x00" * ((4 - len(self.buf) % 4) % 4)
        self.bufferviews.append({"buffer": 0, "byteOffset": len(self.buf),
                                 "byteLength": len(dade), "target": target})
        self.buf += dade
        return len(self.bufferviews) - 1

    def _aks(self, bufferview, tedad, jenis):
        self.accessors.append({"bufferView": bufferview, "componentType": 5125 if jenis == "SCALAR" else 5126,
                               "count": tedad, "type": jenis})
        return len(self.accessors) - 1

    def mesh_ezafe(self, name, qismha, translation=None, rotation=None):
        """یک گره + مش با چند سطح (هر سطح = یک متریال)"""
        primitives = []
        for pos, nrm, idx, mateh in qismha:
            pos = np.asarray(pos, np.float32).reshape(-1, 3)
            nrm = np.asarray(nrm, np.float32).reshape(-1, 3)
            idx = np.asarray(idx, np.uint32).reshape(-1)
            ac_p = self._aks(self._bife(pos.tobytes(), 34962), len(pos), "VEC3")
            self.accessors[-1]["min"] = pos.min(0).astype(np.float32).tolist()
            self.accessors[-1]["max"] = pos.max(0).astype(np.float32).tolist()
            ac_n = self._aks(self._bife(nrm.tobytes(), 34962), len(nrm), "VEC3")
            ac_i = self._aks(self._bife(idx.tobytes(), 34963), len(idx), "SCALAR")
            primitives.append({"attributes": {"POSITION": ac_p, "NORMAL": ac_n},
                               "indices": ac_i, "material": self.mate_id(mateh)})
        mesh_i = len(self.meshes)
        self.meshes.append({"name": name, "primitives": primitives})
        node_i = self._node(name, mesh=mesh_i, translation=translation, rotation=rotation)
        self.bacheha_rishe.append(node_i)
        return node_i

    def charkh_ezafe(self, name, position, r=0.345, panh=0.26):
        """گرهٔ محورِ چرخ (چرخشِ بازی روی X اینجا می‌خورد) + بچه‌ها با چرخشِ Z+۹۰"""
        qz = [0.0, 0.0, math.sin(math.pi/4), math.cos(math.pi/4)]
        qismha = charkh_sakht(r, panh)
        tedad_pish = len(self.bacheha_rishe)
        bacheha = []
        for nam in ["tir", "ring", "disc", "pare", "halge"]:
            pos, nrm, idx, mt = qismha[nam]
            bacheha.append(self.mesh_ezafe(f"{name}_{nam}", [(pos, nrm, idx, mt)],
                                           rotation=qz))
        # بچه‌های چرخ از فهرستِ ریشه حذف شوند — فقط به محور وصل‌اند
        for k in range(tedad_pish, len(self.bacheha_rishe)):
            self.bacheha_rishe.pop(tedad_pish)
        mehvar = self._node(name, translation=position, children=bacheha)
        self.bacheha_rishe.append(mehvar)   # محورِ چرخ خودش بچهٔ سطحِ بالای ریشه است
        return mehvar

    def zakhire(self, masir):
        """اتصالِ بچه‌ها به ریشه و نوشتنِ فایلِ .glb"""
        self.nodes[0]["children"] = list(self.bacheha_rishe)
        gltf = {
            "asset": {"version": "2.0", "generator": "sazande_mashin_tizpa"},
            "scene": 0,
            "scenes": [{"nodes": [0]}],
            "nodes": self.nodes,
            "meshes": self.meshes,
            "materials": self.materials,
            "buffers": [{"byteLength": len(self.buf)}],
            "bufferViews": self.bufferviews,
            "accessors": self.accessors,
        }
        js = json.dumps(gltf, separators=(",", ":")).encode("utf-8")
        js += b" " * ((4 - len(js) % 4) % 4)
        self.buf += b"\x00" * ((4 - len(self.buf) % 4) % 4)
        tool = 12 + (8 + len(js)) + (8 + len(self.buf))
        with open(masir, "wb") as f:
            f.write(struct.pack("<4sII", b"glTF", 2, tool))
            f.write(struct.pack("<I4s", len(js), b"JSON"))
            f.write(js)
            f.write(struct.pack("<I4s", len(self.buf), b"BIN\x00"))
            f.write(bytes(self.buf))
        print(f"[mashin3d] ذخیره شد: {masir} ({os.path.getsize(masir)//1024} کیلوبایت، "
              f"{len(self.meshes)} مش، {len(self.materials)} متریال، {len(self.nodes)-1} گره)")

# ═══════════════ ساختِ ماشینِ کامل ═══════════════
def mashin_saz(kind):
    g = GLB()
    if kind == "supercar":
        prof, kabin = PROF_SUPERCAR, KABIN_SUPERCAR
        tohel_y, wing_h = 0.44, True
    else:
        prof, kabin = PROF_SPORT, KABIN_SPORT
        tohel_y, wing_h = 0.48, False

    # ۱) بدنه + کابین
    ist = [(z, gozar_badane(yb, yt, w)) for z, yb, yt, w in prof]
    g.mesh_ezafe("badane", [(*loft(ist), M_BADANE)])
    ist2 = [(z, gozar_kabin(yb, yt, w)) for z, yb, yt, w in kabin]
    g.mesh_ezafe("kabin", [(*loft(ist2), M_SHISHE)])

    # ۲) تیرکش‌ها: دیفیوزر، اسپلیتر، رکاب، آینه، وینگ/اسپویلر، هواکش
    qism_tir = []
    qism_tir.append((*qute((0.0, 0.13, -2.14), (1.58, 0.14, 0.44)), M_TIR))   # دیفیوزر
    qism_tir.append((*qute((0.0, 0.12,  2.26), (1.30, 0.10, 0.30)), M_TIR))   # اسپلیتر
    qism_tir.append((*qute((0.0, 0.50,  2.10), (1.24, 0.06, 0.34)), M_TIR))   # سرپوشِ پوزه
    for j in (-1, 1):
        qism_tir.append((*qute((j*0.90, 0.20, -0.20), (0.12, 0.12, 2.60)), M_TIR))             # رکاب
        qism_tir.append((*qute((j*1.05, 0.80, 0.78), (0.20, 0.09, 0.11), ry=0.22*j), M_TIR))   # آینه
        qism_tir.append((*qute((j*0.95, 0.74, 0.78), (0.04, 0.10, 0.04)), M_TIR))              # پایهٔ آینه
    if wing_h:
        for j in (-1, 1):
            qism_tir.append((*qute((j*0.52, 0.78, -2.05), (0.06, 0.30, 0.10), rx=0.15), M_TIR))
        qism_tir.append((*qute((0.0, 0.94, -2.10), (1.74, 0.035, 0.34), rx=0.10), M_BADANE))
        qism_tir.append((*qute((0.0, 0.80, -1.90), (1.50, 0.05, 0.10)), M_TIR))
    else:
        qism_tir.append((*qute((0.0, 0.64, -2.24), (1.30, 0.05, 0.16), rx=0.12), M_BADANE))    # اسپویلرِ لبه
    qism_tir.append((*qute((0.0, 0.705, 1.30), (0.44, 0.02, 0.30)), M_TIR))                    # هواکشِ کاپوت
    g.mesh_ezafe("tirkeshi", qism_tir)

    # ۳) چراغ‌ها
    g.mesh_ezafe("cheragh_jelo", [
        (*qute(( 0.50, 0.52, 2.17), (0.42, 0.08, 0.10), ry=-0.30, rz=0.14), M_CHERAGH),
        (*qute((-0.50, 0.52, 2.17), (0.42, 0.08, 0.10), ry= 0.30, rz=-0.14), M_CHERAGH),
    ])
    g.mesh_ezafe("cheragh_aqab", [
        (*qute((0.0, tohel_y, -2.355), (1.38, 0.08, 0.05)), M_TOHEL),
    ])
    # ۴) اگزوز دوقلو
    g.mesh_ezafe("egzoz", [(*ostovane_z(j*0.42, 0.30, -2.36, 0.082, 0.20, 12), M_KROM) for j in (-1, 1)])
    # ۵) چاه‌چرخ‌ها — پوستهٔ تیرهٔ پشت چرخ (محور X)
    for wx in (-0.86, 0.86):
        for wz in (1.45, -1.45):
            pp, nn, ii = ostovane(0.44, 0.36, 16, cap_bala=False, cap_paeen=False)
            pp2, nn2 = be_charkhes_ax(pp, nn)
            pp2 = [np.asarray((wx, p[1], p[2] + wz), np.float64) for p in pp2]
            g.mesh_ezafe(f"chah_charkh_{int(wx*100)}_{int(wz*100)}", [(pp2, nn2, ii, M_CHAH)])

    # ۶) چهار چرخ — گره‌های قراردادیِ بازی
    for nam, pos in [
            ("charkh_jelo_chap",  ( 0.86, 0.345, 1.45)),
            ("charkh_jelo_rast",  (-0.86, 0.345, 1.45)),
            ("charkh_paeen_chap", ( 0.86, 0.345, -1.45)),
            ("charkh_paeen_rast", (-0.86, 0.345, -1.45)),
    ]:
        g.charkh_ezafe(nam, pos, r=0.345, panh=0.30)
    return g

if __name__ == "__main__":
    var_maghaz = os.path.abspath(os.path.join(os.path.dirname(__file__), "..",
                                              "ema", "tizpa", "assets", "models"))
    os.makedirs(var_maghaz, exist_ok=True)
    for kind in ["sport", "supercar"]:
        g = mashin_saz(kind)
        g.zakhire(os.path.join(var_maghaz, f"mashin_{kind}.glb"))
    print("[mashin3d] تمام — دو مدل آماده است")
