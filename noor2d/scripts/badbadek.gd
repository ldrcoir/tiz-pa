extends Node2D
## «بادبادک تهران» — نخ‌بازی روی پشت‌بام‌ها
## نخِ بادبادک با شبیه‌سازی ورله (۱۵ گره) زنده است؛ نسیم و تندباد بادبادک را می‌رقصد.
## پشت‌بام‌های تهران زیر پایت، برج میلاد در افق، کلاغ‌ها در آسمان.

const Ashtar = preload("res://scripts/ashtar.gd")
const W := 1280.0
const H := 720.0
const TEDAD_GEREH := 15
const GHAZE_GEREH := 17.0

var fon_l: FontFile
var fon_b: FontFile
var fon_v: FontFile
var dunbal: Camera2D
var jahan: Node2D
var setara := []
var abr_ha := []           # ابرها: آرایه‌ای از هاله‌های نرم
var hud_emtiaz: Label

var rope := PackedVector2Array()   # نقاط نخ (ورله)
var rope_prev := PackedVector2Array()
var dom := PackedVector2Array()    # دم پاپیونی: ۵ گره
var dom_prev := PackedVector2Array()
var lanch := Vector2(640, 628)   # جای پای تو روی پشت‌بام
var mot_ha := []           # تخم‌های نور
var kalagh_ha := []        # کلاغ‌ها: {pos, vel, faz, node}
var vakit_kalagh := 2.0
var emtiaz := 0
var vakit := 0.0
var lerze := 0.0
var t := 0.0
var t0 := 0
var aks := false
var aks_plan := [[2800, "badbadek_1.png"], [6400, "badbadek_2.png"]]
var aks_i := 0
var rng := RandomNumberGenerator.new()

var khane_ha := []         # خانه‌ها: {x, w, h, panjere_ha}
var pop_ha := []
var donbal: Line2D
var hale_te: Sprite2D      # هالهٔ گرم بازیگر (یک‌بار ساخته می‌شود)


func _ready() -> void:
        fon_l = Ashtar.fon("res://assets/fonts/Lalezar-Regular.ttf")
        fon_b = Ashtar.fon("res://assets/fonts/Vazirmatn-Bold.ttf")
        fon_v = Ashtar.fon("res://assets/fonts/Vazirmatn-Regular.ttf")
        aks = Ashtar.aks_faal()
        t0 = Time.get_ticks_msec()
        rng.seed = 1111
        _ghurub_besaz()
        _dunbal_besaz()
        _shahr_besaz()
        _nakh_besaz()
        _bazigar_ha()
        _hud_besaz()
        for i in 8:
                mot_ha.append({"pos": Vector2(rng.randf_range(120, W - 120), rng.randf_range(110, 440)), "faz": rng.randf_range(0.0, TAU)})
        jahan = Node2D.new()
        add_child(jahan)
        jahan.draw.connect(_naghash_jahan)


func _ghurub_besaz() -> void:
        ## آسمان غروب تهران: از بنفش شب تا نارنجیِ افق + خورشیدِ مه‌گرفته
        var laye := CanvasLayer.new()
        laye.layer = -10
        add_child(laye)
        var aseman := TextureRect.new()
        aseman.texture = Ashtar.bargo([Color("#160d38"), Color("#4b1d54"), Color("#a03a63"), Color("#ff8a52")])
        aseman.size = Vector2(W, H)
        aseman.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        aseman.stretch_mode = TextureRect.STRETCH_SCALE
        laye.add_child(aseman)
        var khurshid := Ashtar.halo(Color("#ffb35c"), 190.0, 2.6)
        khurshid.modulate.a = 0.5
        khurshid.position = Vector2(990, 560)
        laye.add_child(khurshid)
        var rs := RandomNumberGenerator.new()
        rs.seed = 3
        for i in 46:
                var s := Ashtar.halo(Color(1, 1, 1, 0.7), rs.randf_range(1.0, 2.4))
                s.position = Vector2(rs.randf_range(0, W), rs.randf_range(0, H * 0.4))
                s.set_meta("faz", rs.randf_range(0.0, TAU))
                laye.add_child(s)
                setara.append(s)
        ## ابرهای نرمِ رونده
        for i in 4:
                var goruh := Node2D.new()
                goruh.position = Vector2(rs.randf_range(0, W), rs.randf_range(90, 330))
                for k in 4:
                        var p := Ashtar.halo(Color("#ffd9c2"), rs.randf_range(34.0, 64.0), 1.4)
                        p.modulate.a = 0.09
                        p.position = Vector2(float(k) * 52.0 - 78.0, rs.randf_range(-14, 14))
                        goruh.add_child(p)
                goruh.set_meta("serat", rs.randf_range(8.0, 20.0))
                laye.add_child(goruh)
                abr_ha.append(goruh)


func _dunbal_besaz() -> void:
        dunbal = Camera2D.new()
        dunbal.position = Vector2(W * 0.5, H * 0.5)
        add_child(dunbal)
        dunbal.make_current()


func _shahr_besaz() -> void:
        ## ردیف پشت‌بام‌ها + پنجره‌های روشن + برج میلاد در افق
        var x := -40.0
        while x < W + 40.0:
                var w := rng.randf_range(64.0, 150.0)
                var h := rng.randf_range(90.0, 175.0)
                var panj := []
                for k in rng.randi_range(2, 5):
                        panj.append(Vector2(x + rng.randf_range(8, w - 10), H - 40.0 - rng.randf_range(14, h - 16)))
                khane_ha.append({"x": x, "w": w, "h": h, "panjere_ha": panj})
                x += w + rng.randf_range(4.0, 26.0)


func _nakh_besaz() -> void:
        ## نخِ ورله: همهٔ گره‌ها روی هم، دم پاپیونی جدا
        for i in TEDAD_GEREH:
                var p := lanch + Vector2(0, -float(i) * GHAZE_GEREH)
                rope.append(p)
                rope_prev.append(p)
        var kite: Vector2 = rope[TEDAD_GEREH - 1]
        for i in 6:
                var p := kite + Vector2(float(i) * 4.0, float(i) * 9.0)
                dom.append(p)
                dom_prev.append(p)
        donbal = Line2D.new()
        var g := Gradient.new()
        g.offsets = PackedFloat32Array([0.0, 1.0])
        g.colors = PackedColorArray([Color("#ff7a9c", 0.75), Color("#ff7a9c", 0.0)])
        donbal.gradient = g
        donbal.width = 6.0
        donbal.joint_mode = Line2D.LINE_JOINT_ROUND
        add_child(donbal)


func _bazigar_ha() -> void:
        hale_te = Ashtar.halo(Color("#ffd9a0"), 26.0)
        hale_te.modulate.a = 0.5
        add_child(hale_te)


func _hud_besaz() -> void:
        var laye := CanvasLayer.new()
        add_child(laye)
        var onvan := Label.new()
        onvan.text = "بادبادک تهران"
        onvan.add_theme_font_override("font", fon_l)
        onvan.add_theme_font_size_override("font_size", 44)
        onvan.add_theme_color_override("font_color", Color("#ff9db6"))
        onvan.position = Vector2(28, 12)
        laye.add_child(onvan)
        hud_emtiaz = Label.new()
        hud_emtiaz.add_theme_font_override("font", fon_b)
        hud_emtiaz.add_theme_font_size_override("font_size", 30)
        hud_emtiaz.add_theme_color_override("font_color", Color.WHITE)
        hud_emtiaz.position = Vector2(W - 460, 16)
        hud_emtiaz.size = Vector2(440, 50)
        hud_emtiaz.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        laye.add_child(hud_emtiaz)
        var rasaneh := Label.new()
        rasaneh.text = "موس/لمس: راه رفتن با نخ — نسیم بادبادک را می‌رقصد"
        rasaneh.add_theme_font_override("font", fon_v)
        rasaneh.add_theme_font_size_override("font_size", 18)
        rasaneh.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))
        rasaneh.position = Vector2(28, 68)
        laye.add_child(rasaneh)


func _ghaz(delta: float, i: int) -> Vector2:
        ## شتاب باد و جاذبه؛ نزدیک بادبادک باد قوی‌تر است
        var baz := 1.0 + float(i) / float(TEDAD_GEREH) * 1.7
        var tong := maxf(0.0, sin(t * 0.8)) * 230.0
        var bad := Vector2((150.0 + sin(t * 0.6) * 70.0 + sin(t * 2.3) * 30.0) * baz, -(60.0 + tong) * baz)
        return bad + Vector2(0, 340)


func _process(delta: float) -> void:
        t += delta
        if aks:
                aks_i = Ashtar.aks_ravat(self, t0, aks_plan, aks_i)
        ## خلبان خودکار: قدم زدن با نخ روی پشت‌بام
        lanch.x = 640.0 + sin(t * 0.55) * 300.0
        lanch.y = 628.0
        _verlet(delta)
        _kalagh_ha_ravat(delta)
        _mot_ha_ravat(delta)
        vakit += delta
        if vakit >= 1.0:
                emtiaz += 1
                vakit -= 1.0
        lerze = maxf(0.0, lerze - delta * 2.0)
        dunbal.offset = Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1)) * lerze * 10.0
        for s in setara:
                s.modulate.a = 0.3 + 0.3 * sin(t * 2.0 + float(s.get_meta("faz")))
        for a in abr_ha:
                a.position.x += float(a.get_meta("serat")) * delta
                if a.position.x > W + 220.0:
                        a.position.x = -220.0
        donbal.add_point(_kite_pos())
        if donbal.get_point_count() > 30:
                donbal.remove_point(0)
        hud_emtiaz.text = "امتیاز: " + Ashtar.fa(emtiaz)
        jahan.queue_redraw()


func _kite_pos() -> Vector2:
        return rope[TEDAD_GEREH - 1]


func _verlet(delta: float) -> void:
        ## یک قدم فیزیک ورله برای نخ و دم + جورکردن فاصله‌ها
        for i in range(1, TEDAD_GEREH):
                var p: Vector2 = rope[i]
                var gh: Vector2 = p - rope_prev[i]
                rope_prev[i] = p
                rope[i] = p + gh * 0.985 + _ghaz(delta, i) * delta * delta
        rope[0] = lanch
        for i in range(1, 6):
                var p2: Vector2 = dom[i]
                var gh2: Vector2 = p2 - dom_prev[i]
                dom_prev[i] = p2
                dom[i] = p2 + gh2 * 0.97 + Vector2(0, 300.0) * delta * delta + Vector2(sin(t * 3.0 + float(i)) * 26.0, 0) * delta * delta
        for tekrar in 4:
                for i in range(0, TEDAD_GEREH - 1):
                        var a: Vector2 = rope[i]
                        var b: Vector2 = rope[i + 1]
                        var far := (b - a).length()
                        if far <= 0.0001:
                                continue
                        var forgh := (far - GHAZE_GEREH) / far * 0.5
                        var j := Vector2(b - a) * forgh
                        if i == 0:
                                rope[i + 1] -= j * 2.0
                        elif i == TEDAD_GEREH - 2:
                                rope[i] += j * 1.5
                                rope[i + 1] -= j * 0.5
                        else:
                                rope[i] += j
                                rope[i + 1] -= j
                rope[0] = lanch
        dom[0] = _kite_pos() + Vector2(0, 20)
        for i in range(0, 5):
                var a2: Vector2 = dom[i]
                var b2: Vector2 = dom[i + 1]
                var far2 := (b2 - a2).length()
                if far2 <= 0.0001:
                        continue
                var fo2 := (far2 - 11.0) / far2 * 0.5
                var j2 := (b2 - a2) * fo2
                if i == 0:
                        dom[i + 1] -= j2 * 2.0
                else:
                        dom[i] += j2
                        dom[i + 1] -= j2


func _kalagh_ha_ravat(delta: float) -> void:
        vakit_kalagh -= delta
        if vakit_kalagh <= 0.0 and kalagh_ha.size() < 3:
                var az_chap := rng.randi_range(0, 1) == 0
                var pos := Vector2(-40.0 if az_chap else W + 40.0, rng.randf_range(130, 430))
                var n := Node2D.new()
                add_child(n)
                n.draw.connect(_naghash_kalagh.bind(n))
                kalagh_ha.append({"node": n, "pos": pos, "vel": Vector2(230.0 if az_chap else -230.0, 0.0), "faz": rng.randf_range(0.0, TAU)})
                vakit_kalagh = 2.8
        var mande := []
        for k in kalagh_ha:
                k.pos.x += k.vel.x * delta
                k.pos.y += sin(t * 1.4 + k.faz) * 22.0 * delta
                k.node.position = k.pos
                k.node.queue_redraw()
                if _kite_pos().distance_to(k.pos) < 36.0:
                        lerze = 1.0
                        emtiaz = maxi(0, emtiaz - 5)
                        _pop(k.pos, "کلاغ! " + Ashtar.fa(-5), Color("#ffb0c0"))
                        Ashtar.enfejar(self, k.pos, Color("#22222c"), 14, 180.0)
                if k.pos.x > -80.0 and k.pos.x < W + 80.0:
                        mande.append(k)
                else:
                        k.node.queue_free()
        kalagh_ha = mande


func _mot_ha_ravat(delta: float) -> void:
        var kite := _kite_pos()
        var mande := []
        for m in mot_ha:
                m.pos.y += sin(t * 1.6 + m.faz) * 14.0 * delta
                m.pos.x += cos(t * 1.1 + m.faz) * 10.0 * delta
                if kite.distance_to(m.pos) < 44.0:
                        emtiaz += 10
                        _pop(m.pos, "+" + Ashtar.fa(10), Color("#ffe98a"))
                        Ashtar.enfejar(self, m.pos, Color("#ffe98a"), 16, 190.0)
                        m.pos = Vector2(rng.randf_range(120, W - 120), rng.randf_range(110, 440))
                mande.append(m)
        mot_ha = mande


func _pop(pos: Vector2, matn: String, rang: Color) -> void:
        pop_ha.append({"pos": pos, "matn": matn, "omr": 1.0, "rang": rang})


func _naghash_jahan() -> void:
        ## ردیف خانه‌ها و پنجره‌های گرم
        for kh in khane_ha:
            var mostatil := Rect2(kh.x, H - 40.0 - kh.h, kh.w, kh.h)
            jahan.draw_rect(mostatil, Color("#140a22"))
            jahan.draw_line(Vector2(kh.x, H - 40.0 - kh.h), Vector2(kh.x + kh.w, H - 40.0 - kh.h), Color("#2a1840"), 2.0)
            for p in kh.panjere_ha:
                    jahan.draw_rect(Rect2(p, Vector2(7, 10)), Color("#ff9d5c", 0.5))
        ## برج میلاد در افق (چپ)
        var b := Vector2(170, H - 40.0)
        jahan.draw_rect(Rect2(b.x - 5, b.y - 250, 10, 170), Color("#1c1030"))
        var kolah := PackedVector2Array([
                Vector2(b.x - 16, b.y - 250), Vector2(b.x + 16, b.y - 250),
                Vector2(b.x + 11, b.y - 292), Vector2(b.x - 11, b.y - 292),
        ])
        jahan.draw_colored_polygon(kolah, Color("#1c1030"))
        jahan.draw_rect(Rect2(b.x - 3, b.y - 330, 6, 42), Color("#1c1030"))
        jahan.draw_line(Vector2(b.x, b.y - 292), Vector2(b.x, b.y - 296), Color("#ff3b3b"), 3.0)
        ## خیابانِ جلو
        jahan.draw_rect(Rect2(0, H - 40, W, 40), Color("#0b0512"))
        jahan.draw_line(Vector2(0, H - 40), Vector2(W, H - 40), Color("#241338"), 2.0)
        ## خودت با نخ، روی پشت‌بام
        hale_te.position = lanch + Vector2(0, -18)
        jahan.draw_circle(lanch + Vector2(0, -26), 5.0, Color("#ffd9a0"))
        jahan.draw_line(lanch + Vector2(0, -21), lanch + Vector2(0, -8), Color("#ffd9a0"), 3.0)
        jahan.draw_line(lanch + Vector2(0, -8), lanch + Vector2(-4, 0), Color("#ffd9a0"), 2.5)
        jahan.draw_line(lanch + Vector2(0, -8), lanch + Vector2(4, 0), Color("#ffd9a0"), 2.5)
        ## نخ: خط نرم میان گره‌ها
        var nokat := PackedVector2Array()
        for p in rope:
                nokat.append(p)
        jahan.draw_polyline(nokat, Color("#e8e2d2", 0.75), 1.6, true)
        ## بادبادک: لوزی دولتی با چوب‌های صلیبی
        var kite := _kite_pos()
        var jahat := (kite - rope[TEDAD_GEREH - 2]).normalized()
        if jahat == Vector2.ZERO:
                jahat = Vector2.UP
        var zaviye := jahat.angle() + PI / 2.0
        var shakl := [Vector2(0, -30), Vector2(19, 0), Vector2(0, 24), Vector2(-19, 0)]
        var charkhid := PackedVector2Array()
        for v in shakl:
                charkhid.append(kite + v.rotated(zaviye))
        jahan.draw_colored_polygon(charkhid, Color("#ff5c8a", 0.95))
        var nim := PackedVector2Array([kite, charkhid[1], charkhid[2]])
        jahan.draw_colored_polygon(nim, Color("#ffd24d", 0.9))
        jahan.draw_polyline(charkhid + PackedVector2Array([charkhid[0]]), Color(1, 1, 1, 0.65), 1.5, true)
        jahan.draw_line(kite + Vector2(0, -30).rotated(zaviye), kite + Vector2(0, 24).rotated(zaviye), Color(1, 1, 1, 0.4), 1.2, true)
        jahan.draw_line(kite + Vector2(-19, 0).rotated(zaviye), kite + Vector2(19, 0).rotated(zaviye), Color(1, 1, 1, 0.4), 1.2, true)
        ## دم پاپیونی
        var nokat_dom := PackedVector2Array()
        for p in dom:
                nokat_dom.append(p)
        jahan.draw_polyline(nokat_dom, Color("#9ad7ff", 0.7), 1.4, true)
        for i in range(1, 6):
                var rang_dom := Color("#4de3ff") if i % 2 == 0 else Color("#ff7a9c")
                jahan.draw_colored_polygon(_moraba(dom[i], 5.0, float(i) * 0.7 + t), rang_dom)
        ## تخم‌های نور
        for m in mot_ha:
                var pel := 1.0 + 0.18 * sin(t * 4.0 + m.faz)
                jahan.draw_circle(m.pos, 11.0 * pel, Color("#ffe98a", 0.18))
                jahan.draw_circle(m.pos, 4.5 * pel, Color("#fff3c4"))
        ## پاپ‌آپ‌ها
        var zande := []
        for p in pop_ha:
                p.omr -= get_process_delta_time()
                p.pos.y -= 32.0 * get_process_delta_time()
                if p.omr > 0.0:
                        zande.append(p)
                        jahan.draw_string(fon_b, p.pos, p.matn, HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color(p.rang, clampf(p.omr, 0.0, 1.0)))
        pop_ha = zande


func _moraba(vasat: Vector2, sh: float, zaviye: float) -> PackedVector2Array:
        var kh := PackedVector2Array()
        for k in 4:
                kh.append(vasat + Vector2.RIGHT.rotated(zaviye + float(k) * PI / 2.0) * sh)
        return kh


func _naghash_kalagh(n: Node2D) -> void:
        var d = null
        for c in kalagh_ha:
                if c.node == n:
                        d = c
                        break
        if d == null:
                return
        var baz := sin(t * 11.0 + float(d.faz)) * 7.0
        var bal := PackedVector2Array([Vector2(-15, -baz), Vector2(0, 0), Vector2(15, -baz)])
        n.draw_polyline(bal, Color("#101018"), 3.2, true)
        n.draw_circle(Vector2.ZERO, 3.0, Color("#101018"))
