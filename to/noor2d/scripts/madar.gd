extends Node2D
## «مدار» — پرش مداری تک‌لمسی
## از مدارِ یک هسته رها شو، در خط مستقیم پرواز کن و در مدارِ بعدی به دام بیفتد.
## دنباله‌دارِ نورانی، زنجیرهٔ هسته‌ها، تیغه‌های خطر و تخم‌های نور.

const Ashtar = preload("res://scripts/ashtar.gd")
const W := 1280.0
const H := 720.0

var fon_l: FontFile
var fon_b: FontFile
var fon_v: FontFile
var dunbal: Camera2D
var jahan: Node2D
var donbal: Line2D
var halo_bazigar: Sprite2D
var setara := []
var hud_emtiaz: Label
var hud_zanjire: Label

var cores := []            # هسته‌ها: {pos, rang, shoaa}
var mot_ha := []           # تخم‌های نور: {pos, rang}
var tigh_ha := []          # تیغه‌های خطر: {pos, zav}
var pop_ha := []           # پاپ‌آپ امتیاز: {pos, matn, omr, rang}

var hal := 0               # ۰=در مدار، ۱=پرواز آزاد
var core_i := 0
var zav := 0.6
var av := 2.5
var shoaa := 95.0
var makan := Vector2.ZERO
var seraat := Vector2.ZERO
var emtiaz := 0
var zanjire := 0
var lerze := 0.0
var t := 0.0
var t0 := 0
var aks := false
var aks_plan := [[2500, "madar_1.png"], [5900, "madar_2.png"]]
var aks_i := 0
var rng := RandomNumberGenerator.new()


func _ready() -> void:
        fon_l = Ashtar.fon("res://assets/fonts/Lalezar-Regular.ttf")
        fon_b = Ashtar.fon("res://assets/fonts/Vazirmatn-Bold.ttf")
        fon_v = Ashtar.fon("res://assets/fonts/Vazirmatn-Regular.ttf")
        aks = Ashtar.aks_faal()
        t0 = Time.get_ticks_msec()
        rng.seed = 711
        _pas_zamin()
        _dunbal_besaz()
        _zanjire_haste_ha()
        _bazigar_besaz()
        _hud_besaz()
        jahan = Node2D.new()
        add_child(jahan)
        jahan.draw.connect(_naghash_jahan)


func _pas_zamin() -> void:
        ## فضا: مه‌سحارهای بنفش و فیروزه‌ای + ستاره‌های چشمک‌زن
        var mgha := [
                [Color("#7b2ff7"), Vector2(280, 190)],
                [Color("#0f6b70"), Vector2(1010, 540)],
                [Color("#a1257c"), Vector2(940, 140)],
        ]
        for m in mgha:
                var h := Ashtar.halo(m[0], 300.0, 2.4)
                h.modulate.a = 0.16
                h.position = m[1]
                add_child(h)
        var rng_s := RandomNumberGenerator.new()
        rng_s.seed = 99
        for i in 90:
                var s := Ashtar.halo(Color(1, 1, 1, 0.85), rng_s.randf_range(1.2, 3.6))
                s.position = Vector2(rng_s.randf_range(0, W), rng_s.randf_range(0, H))
                s.set_meta("faz", rng_s.randf_range(0.0, TAU))
                add_child(s)
                setara.append(s)


func _dunbal_besaz() -> void:
        dunbal = Camera2D.new()
        dunbal.position = Vector2(W * 0.5, H * 0.5)
        add_child(dunbal)
        dunbal.make_current()


func _zanjire_haste_ha() -> void:
        ## زنجیرهٔ هسته‌ها از چپ به راست + تخم‌های نور روی مسیر + تیغه‌های کنار مسیر
        var rangha := [Color("#35e0ff"), Color("#ff4de0"), Color("#ffd24d"), Color("#7dff9c")]
        var p := Vector2(250, 470)
        for i in 12:
                var c := {"pos": p, "rang": rangha[i % rangha.size()], "shoaa": rng.randf_range(78.0, 104.0)}
                cores.append(c)
                var h := Ashtar.halo(c.rang, 84.0)
                h.position = p
                add_child(h)
                if i > 0:
                        var ghabli: Vector2 = cores[i - 1].pos
                        var vasat := (ghabli + p) * 0.5
                        var jahat := (p - ghabli).normalized().orthogonal()
                        for k in 3:
                                var mp := ghabli.lerp(p, 0.28 + 0.22 * float(k)) + jahat * rng.randf_range(-38.0, 38.0)
                                mot_ha.append({"pos": mp, "rang": Color("#ffe98a")})
                        tigh_ha.append({"pos": vasat + jahat * (150.0 if (i % 2 == 0) else -150.0), "zav": rng.randf_range(0.0, TAU)})
                p += Vector2(rng.randf_range(330.0, 430.0), rng.randf_range(-170.0, 170.0))
                p.y = clampf(p.y, 150.0, 590.0)


func _bazigar_besaz() -> void:
        makan = cores[0].pos + Vector2.RIGHT.rotated(zav) * shoaa
        donbal = Line2D.new()
        var g := Gradient.new()
        g.offsets = PackedFloat32Array([0.0, 1.0])
        g.colors = PackedColorArray([Color(0.45, 0.95, 1.0, 0.9), Color(0.45, 0.95, 1.0, 0.0)])
        donbal.gradient = g
        donbal.width = 10.0
        var kham := Curve.new()
        kham.add_point(Vector2(0.0, 1.0))
        kham.add_point(Vector2(1.0, 0.1))
        donbal.width_curve = kham
        donbal.joint_mode = Line2D.LINE_JOINT_ROUND
        donbal.begin_cap_mode = Line2D.LINE_CAP_ROUND
        donbal.end_cap_mode = Line2D.LINE_CAP_ROUND
        add_child(donbal)
        halo_bazigar = Ashtar.halo(Color("#bdf3ff"), 30.0)
        add_child(halo_bazigar)


func _hud_besaz() -> void:
        var laye := CanvasLayer.new()
        add_child(laye)
        hud_emtiaz = _lab(laye, "امتیاز: ۰", fon_b, 30, Color("#ffffff"), Vector2(W - 460, 16), 440, HORIZONTAL_ALIGNMENT_RIGHT)
        hud_zanjire = _lab(laye, "زنجیره: ×۰", fon_b, 24, Color("#ffd24d"), Vector2(W - 460, 58), 440, HORIZONTAL_ALIGNMENT_RIGHT)
        _lab(laye, "مدار", fon_l, 44, Color("#35e0ff"), Vector2(28, 12), 300, HORIZONTAL_ALIGNMENT_LEFT)
        _lab(laye, "یک لمس: رها شدن از مدار", fon_v, 18, Color(1, 1, 1, 0.6), Vector2(28, 66), 320, HORIZONTAL_ALIGNMENT_LEFT)


func _lab(valed: Node, matn: String, fon: FontFile, andaze: int, rang: Color, pos: Vector2, arz: float, hamr: int) -> Label:
        var l := Label.new()
        l.text = matn
        l.add_theme_font_override("font", fon)
        l.add_theme_font_size_override("font_size", andaze)
        l.add_theme_color_override("font_color", rang)
        l.position = pos
        l.size = Vector2(arz, andaze + 20)
        l.horizontal_alignment = hamr
        valed.add_child(l)
        return l


func _raha(dir: Vector2) -> void:
        hal = 1
        seraat = dir * 470.0
        Ashtar.enfejar(self, makan, Color("#9fe8ff"), 14, 160.0)


func _ghereftan(i: int) -> void:
        hal = 0
        core_i = i
        var r: Vector2 = makan - cores[i].pos
        shoaa = clampf(r.length(), 60.0, 112.0)
        zav = r.angle()
        var cr := r.cross(seraat)
        av = 2.5 if cr >= 0.0 else -2.5
        zanjire += 1
        var emt := 25 * mini(zanjire, 8)
        emtiaz += emt
        _pop(cores[i].pos + Vector2(0, -50), "در مدار! +" + Ashtar.fa(emt), cores[i].rang)
        Ashtar.enfejar(self, makan, cores[i].rang, 30, 280.0)
        lerze = 0.55


func _pop(pos: Vector2, matn: String, rang: Color) -> void:
        pop_ha.append({"pos": pos, "matn": matn, "omr": 1.0, "rang": rang})


func _process(delta: float) -> void:
        t += delta
        if aks:
                aks_i = Ashtar.aks_ravat(self, t0, aks_plan, aks_i)
        _harkat(delta)
        _bob_khora(delta)
        _pakhsh(delta)
        dunbal.offset = Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1)) * lerze * 14.0
        lerze = maxf(0.0, lerze - delta * 2.0)
        for s in setara:
                s.modulate.a = 0.4 + 0.35 * sin(t * 2.2 + float(s.get_meta("faz")))
        halo_bazigar.position = makan
        halo_bazigar.scale = Vector2.ONE * (30.0 * 2.0 / 256.0) * (1.0 + 0.12 * sin(t * 6.0))
        donbal.add_point(makan)
        if donbal.get_point_count() > 46:
                donbal.remove_point(0)
        jahan.queue_redraw()


func _harkat(delta: float) -> void:
        if hal == 0:
                zav += av * delta
                makan = cores[core_i].pos + Vector2.RIGHT.rotated(zav) * shoaa
                if core_i + 1 < cores.size():
                        var bad: Vector2 = cores[core_i + 1].pos
                        var dir := Vector2.RIGHT.rotated(zav).rotated(PI / 2.0) * signf(av)
                        var tn := bad - makan
                        var along := tn.dot(dir)
                        if along > 0.0 and (tn - dir * along).length() < 38.0:
                                _raha(dir)
        else:
                makan += seraat * delta
                if core_i + 1 < cores.size():
                        var bad_i := core_i + 1
                        if makan.distance_to(cores[bad_i].pos) < maxf(cores[bad_i].shoaa, 84.0):
                                _ghereftan(bad_i)
                        elif makan.x > W + 90.0 or makan.y < -90.0 or makan.y > H + 90.0 or makan.x < -90.0:
                                makan = cores[bad_i].pos + Vector2(shoaa, 0)
                                _ghereftan(bad_i)


func _bob_khora(delta: float) -> void:
        ## جمع‌کردن تخم‌های نور
        for m in mot_ha:
                var d: Dictionary = m
                if d.get("raft", false):
                        continue
                if makan.distance_to(d.pos) < 30.0:
                        d.raft = true
                        emtiaz += 5
                        _pop(d.pos, "+" + Ashtar.fa(5), Color("#ffe98a"))
                        Ashtar.enfejar(self, d.pos, Color("#ffe98a"), 12, 150.0)


func _pakhsh(delta: float) -> void:
        ## تیغه‌ها می‌چرخند؛ برخورد = لرزش و جریمه
        for tg in tigh_ha:
                tg.zav += delta * 3.0
                if makan.distance_to(tg.pos) < 26.0:
                        lerze = 1.0
                        emtiaz = maxi(0, emtiaz - 15)
                        _pop(tg.pos, "تیغ! " + Ashtar.fa(-15), Color("#ff5c5c"))
        var pak := []
        for p in pop_ha:
                p.omr -= delta * 1.3
                p.pos.y -= 34.0 * delta
                if p.omr > 0.0:
                        pak.append(p)
        pop_ha = pak


func _naghash_jahan() -> void:
        ## همه‌چیزِ جهانِ مدار با draw کشیده می‌شود
        for c in cores:
                var rang: Color = c.rang
                jahan.draw_arc(c.pos, c.shoaa + 10.0, 0.0, TAU, 44, Color(rang, 0.35), 2.0, true)
                jahan.draw_arc(c.pos, c.shoaa + 22.0, t * 1.3, t * 1.3 + 4.6, 26, Color(rang, 0.2), 5.0, true)
                jahan.draw_circle(c.pos, 13.0, Color(rang).lightened(0.3))
                jahan.draw_circle(c.pos, 6.0, Color(1, 1, 1, 0.9))
        for m in mot_ha:
                if m.get("raft", false):
                        continue
                jahan.draw_circle(m.pos, 10.0, Color(m.rang, 0.25))
                jahan.draw_circle(m.pos, 4.5, m.rang)
        for tg in tigh_ha:
                var sh := 14.0
                var pts := PackedVector2Array()
                for k in 4:
                        pts.append(tg.pos + Vector2.RIGHT.rotated(tg.zav + float(k) * PI / 2.0) * sh)
                jahan.draw_colored_polygon(pts, Color("#ff3b5c", 0.9))
                jahan.draw_circle(tg.pos, 4.0, Color("#ffd6de"))
        for p in pop_ha:
                var a: float = clampf(p.omr, 0.0, 1.0)
                jahan.draw_string(fon_b, p.pos, p.matn, HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color(p.rang, a))
        hud_emtiaz.text = "امتیاز: " + Ashtar.fa(emtiaz)
        hud_zanjire.text = "زنجیره: ×" + Ashtar.fa(zanjire)
