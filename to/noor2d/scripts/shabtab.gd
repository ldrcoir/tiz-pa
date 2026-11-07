extends Node2D
## «شب‌تاب» — بقا در باغ تاریک
## هالهٔ نورِ تو جانِ بازی است: تخم‌های نور جمع کن تا هاله زنده بماند،
## پروانه‌های سایه فقط وقتی پیدایشان می‌شود که وارد نور شوی.

const Ashtar = preload("res://scripts/ashtar.gd")
const W := 1280.0
const H := 720.0

var fon_l: FontFile
var fon_b: FontFile
var fon_v: FontFile
var dunbal: Camera2D
var jahan: Node2D
var halo_bozorg: Sprite2D
var halo_kuchak: Sprite2D
var setara := []
var hud_emtiaz: Label
var pur_konande: ColorRect
var flash: ColorRect

var makan := Vector2(360, 380)
var aura := 0.85
var emtiaz := 0
var lerze := 0.0
var t := 0.0
var t0 := 0
var aks := false
var aks_plan := [[2700, "shabtab_1.png"], [6300, "shabtab_2.png"]]
var aks_i := 0
var rng := RandomNumberGenerator.new()

var tokm_ha := []          # تخم‌های نور: {pos, vel, faz}
var bazt_tokm := 0.0
var parvane_ha := []       # پروانه‌های سایه: {node, pos, vel, stun, stun_dir, faz}
var vakit_parvane := 1.2
var alaf_ha := []          # علف‌ها: {x, h, faz}
var gol_ha := []           # گل‌های شب‌زنده: {x, h, rang, faz}


func _ready() -> void:
        fon_l = Ashtar.fon("res://assets/fonts/Lalezar-Regular.ttf")
        fon_b = Ashtar.fon("res://assets/fonts/Vazirmatn-Bold.ttf")
        fon_v = Ashtar.fon("res://assets/fonts/Vazirmatn-Regular.ttf")
        aks = Ashtar.aks_faal()
        t0 = Time.get_ticks_msec()
        rng.seed = 1403
        _shab_besaz()
        _dunbal_besaz()
        _bagh_besaz()
        _shabtab_besaz()
        _hud_besaz()
        for i in 7:
                _tokm_jadid()
        jahan = Node2D.new()
        add_child(jahan)
        jahan.draw.connect(_naghash_jahan)


func _shab_besaz() -> void:
        ## شبِ نزدیک به سیاه با ته‌مایهٔ سبز جنگلی
        var zamin := ColorRect.new()
        zamin.color = Color("#081119")
        zamin.size = Vector2(W, H)
        add_child(zamin)
        var h := Ashtar.halo(Color("#14503a"), 320.0, 2.4)
        h.modulate.a = 0.45
        h.position = Vector2(640, 300)
        add_child(h)
        var h2 := Ashtar.halo(Color("#0e2f4a"), 260.0, 2.2)
        h2.modulate.a = 0.32
        h2.position = Vector2(1080, 520)
        add_child(h2)
        var rs := RandomNumberGenerator.new()
        rs.seed = 5
        for i in 60:
                var s := Ashtar.halo(Color(1, 1, 1, 0.7), rs.randf_range(1.0, 2.6))
                s.position = Vector2(rs.randf_range(0, W), rs.randf_range(0, H * 0.55))
                s.set_meta("faz", rs.randf_range(0.0, TAU))
                add_child(s)
                setara.append(s)
        ## گرده‌های شناور در هوای باغ
        var graf := CPUParticles2D.new()
        graf.position = Vector2(W * 0.5, H * 0.5)
        graf.amount = 80
        graf.lifetime = 7.0
        graf.preprocess = 7.0
        graf.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
        graf.emission_rect_extents = Vector2(W * 0.5, H * 0.5)
        graf.gravity = Vector2(0, -12)
        graf.initial_velocity_min = 5.0
        graf.initial_velocity_max = 18.0
        graf.scale_amount_min = 1.0
        graf.scale_amount_max = 2.6
        graf.color = Color(0.65, 1.0, 0.75, 0.42)
        var mt := CanvasItemMaterial.new()
        mt.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
        graf.material = mt
        add_child(graf)
        ## کرم‌های شب‌تابِ دور برای عمق صحنه
        for i in 6:
                var dor := Ashtar.halo(Color("#b8ffc9"), rng.randf_range(5.0, 9.0))
                dor.position = Vector2(rng.randf_range(80, W - 80), rng.randf_range(120, H - 160))
                dor.modulate.a = 0.55
                dor.set_meta("faz", rng.randf_range(0.0, TAU))
                add_child(dor)
                setara.append(dor)


func _dunbal_besaz() -> void:
        dunbal = Camera2D.new()
        dunbal.position = Vector2(W * 0.5, H * 0.5)
        add_child(dunbal)
        dunbal.make_current()


func _bagh_besaz() -> void:
        ## علف‌ها و گل‌های شب‌زنده در حاشیهٔ پایین
        for i in 46:
                alaf_ha.append({"x": rng.randf_range(0, W), "h": rng.randf_range(38.0, 96.0), "faz": rng.randf_range(0.0, TAU)})
        var rangha := [Color("#ff9ad5"), Color("#9ad7ff"), Color("#ffe98a"), Color("#c39aff")]
        for i in 8:
                gol_ha.append({"x": 60.0 + float(i) * 160.0 + rng.randf_range(-40.0, 40.0), "h": rng.randf_range(90.0, 170.0), "rang": rangha[i % rangha.size()], "faz": rng.randf_range(0.0, TAU)})


func _shabtab_besaz() -> void:
        halo_bozorg = Ashtar.halo(Color("#ffef9e"), 230.0)
        add_child(halo_bozorg)
        halo_kuchak = Ashtar.halo(Color("#fffbe0"), 26.0)
        add_child(halo_kuchak)


func _hud_besaz() -> void:
        var laye := CanvasLayer.new()
        add_child(laye)
        var onvan := Label.new()
        onvan.text = "شب‌تاب"
        onvan.add_theme_font_override("font", fon_l)
        onvan.add_theme_font_size_override("font_size", 44)
        onvan.add_theme_color_override("font_color", Color("#ffe98a"))
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
        ## هشدار هاله و نوار آن
        var hosh := Label.new()
        hosh.text = "هالهٔ نور"
        hosh.add_theme_font_override("font", fon_v)
        hosh.add_theme_font_size_override("font_size", 18)
        hosh.add_theme_color_override("font_color", Color(1, 1, 1, 0.65))
        hosh.position = Vector2(W * 0.5 - 130, H - 56)
        hosh.size = Vector2(260, 26)
        hosh.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        laye.add_child(hosh)
        var posht := ColorRect.new()
        posht.color = Color(1, 1, 1, 0.12)
        posht.position = Vector2(W * 0.5 - 130, H - 28)
        posht.size = Vector2(260, 12)
        laye.add_child(posht)
        pur_konande = ColorRect.new()
        pur_konande.color = Color("#ffe98a")
        pur_konande.position = Vector2(W * 0.5 - 128, H - 26)
        pur_konande.size = Vector2(256 * aura, 8)
        laye.add_child(pur_konande)
        ## مهر تاریکی دور قاب + فلاش ضربه
        var vin := TextureRect.new()
        var g := Gradient.new()
        g.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
        g.colors = PackedColorArray([Color(0, 0, 0, 0.0), Color(0, 0, 0, 0.3), Color(0, 0, 0, 0.6)])
        var gt := GradientTexture2D.new()
        gt.gradient = g
        gt.fill = GradientTexture2D.FILL_RADIAL
        gt.width = 256
        gt.height = 256
        gt.fill_from = Vector2(0.5, 0.5)
        gt.fill_to = Vector2(1.0, 0.5)
        vin.texture = gt
        vin.size = Vector2(W, H)
        vin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        vin.stretch_mode = TextureRect.STRETCH_SCALE
        vin.mouse_filter = Control.MOUSE_FILTER_IGNORE
        laye.add_child(vin)
        flash = ColorRect.new()
        flash.color = Color(1, 0.25, 0.25, 0.0)
        flash.size = Vector2(W, H)
        flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
        laye.add_child(flash)


func _tokm_jadid() -> void:
        tokm_ha.append({"pos": Vector2(rng.randf_range(90, W - 90), rng.randf_range(80, H - 130)), "vel": Vector2(rng.randf_range(-30, 30), rng.randf_range(-20, 20)), "faz": rng.randf_range(0.0, TAU)})


func _nazdirin_tokm() -> Vector2:
        var behtar := Vector2.INF
        var kamarin := INF
        for m in tokm_ha:
                var d: float = makan.distance_to(m.pos)
                if d < kamarin:
                        kamarin = d
                        behtar = m.pos
        return behtar


func _parvane_jadid() -> void:
        ## از لبهٔ صفحه می‌آید
        var lab := rng.randi_range(0, 3)
        var pos: Vector2
        if lab == 0:
                pos = Vector2(-30, rng.randf_range(80, H - 120))
        elif lab == 1:
                pos = Vector2(W + 30, rng.randf_range(80, H - 120))
        elif lab == 2:
                pos = Vector2(rng.randf_range(60, W - 60), -30)
        else:
                pos = Vector2(rng.randf_range(60, W - 60), H + 30)
        var n := Node2D.new()
        add_child(n)
        n.draw.connect(_naghash_parvane.bind(n))
        parvane_ha.append({"node": n, "pos": pos, "vel": Vector2.ZERO, "stun": 0.0, "stun_dir": Vector2.ZERO, "faz": rng.randf_range(0.0, TAU)})


func _process(delta: float) -> void:
        t += delta
        if aks:
                aks_i = Ashtar.aks_ravat(self, t0, aks_plan, aks_i)
        _raftar_bazigar(delta)
        _tokm_ha_ravat(delta)
        _parvane_ha_ravat(delta)
        aura = clampf(aura - 0.03 * delta, 0.12, 1.0)
        lerze = maxf(0.0, lerze - delta * 2.0)
        flash.color.a = maxf(0.0, flash.color.a - delta * 1.8)
        dunbal.offset = Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1)) * lerze * 12.0
        for s in setara:
                s.modulate.a = 0.3 + 0.3 * sin(t * 2.0 + float(s.get_meta("faz")))
        ## هاله‌ها با هالهٔ نور نفس می‌کشند
        var nafas := 0.55 + aura * 0.95 + 0.05 * sin(t * 5.0)
        halo_bozorg.position = makan
        halo_bozorg.scale = Vector2.ONE * (230.0 * 2.0 / 256.0) * nafas
        halo_kuchak.position = makan
        halo_kuchak.scale = Vector2.ONE * (26.0 * 2.0 / 256.0) * (1.0 + 0.15 * sin(t * 8.0))
        pur_konande.size.x = 256.0 * aura
        hud_emtiaz.text = "امتیاز: " + Ashtar.fa(emtiaz)
        jahan.queue_redraw()


func _raftar_bazigar(delta: float) -> void:
        ## خلبان خودکار دمو: دنبال نزدیک‌ترین تخمِ نور با تلوتلوی ملایم
        var hadaf := _nazdirin_tokm()
        if hadaf != Vector2.INF:
                makan = makan.move_toward(hadaf, 255.0 * delta)
        makan += Vector2(sin(t * 3.1) * 16.0, cos(t * 2.3) * 11.0) * delta
        makan.x = clampf(makan.x, 60, W - 60)
        makan.y = clampf(makan.y, 70, H - 110)


func _tokm_ha_ravat(delta: float) -> void:
        var bud := []
        for m in tokm_ha:
                m.vel.x += rng.randf_range(-60, 60) * delta
                m.vel.y += rng.randf_range(-60, 60) * delta
                m.vel = m.vel.limit_length(45.0)
                m.pos += m.vel * delta
                m.pos.y += sin(t * 1.7 + m.faz) * 8.0 * delta
                m.pos.x = clampf(m.pos.x, 50, W - 50)
                m.pos.y = clampf(m.pos.y, 60, H - 100)
                if makan.distance_to(m.pos) < 170.0:
                        m.pos = m.pos.move_toward(makan, 70.0 * delta)
                if makan.distance_to(m.pos) < 32.0:
                        emtiaz += 10
                        aura = clampf(aura + 0.16, 0.0, 1.0)
                        Ashtar.enfejar(self, m.pos, Color("#9dffbe"), 18, 190.0)
                        _pop(m.pos, "+" + Ashtar.fa(10), Color("#9dffbe"))
                else:
                        bud.append(m)
        tokm_ha = bud
        bazt_tokm -= delta
        if tokm_ha.size() < 7 and bazt_tokm <= 0.0:
                _tokm_jadid()
                bazt_tokm = 0.5


func _parvane_ha_ravat(delta: float) -> void:
        vakit_parvane -= delta
        if vakit_parvane <= 0.0 and parvane_ha.size() < 5:
                _parvane_jadid()
                vakit_parvane = 2.1
        for d in parvane_ha:
                if d.stun > 0.0:
                        d.stun -= delta
                        d.pos += d.stun_dir * 300.0 * delta
                else:
                        var jahat: Vector2 = (makan - d.pos).normalized() * (135.0 + t * 3.0)
                        d.vel = d.vel.lerp(jahat, 0.035)
                        d.pos += d.vel * delta
                ## فقط در نور پیدا می‌شوند
                d.node.position = d.pos
                d.node.modulate.a = clampf(1.5 - d.pos.distance_to(makan) / 250.0, 0.06, 1.0)
                if d.stun <= 0.0 and d.pos.distance_to(makan) < 30.0:
                        d.stun = 0.6
                        d.stun_dir = (d.pos - makan).normalized()
                        aura = clampf(aura - 0.2, 0.12, 1.0)
                        lerze = 1.0
                        flash.color.a = 0.4
                        _pop(makan + Vector2(0, -60), "موذی!", Color("#ff5c5c"))
                        Ashtar.enfejar(self, d.pos, Color("#3a2b4a"), 14, 170.0)


func _pop(pos: Vector2, matn: String, rang: Color) -> void:
        pop_ha.append({"pos": pos, "matn": matn, "omr": 1.0, "rang": rang})
var pop_ha := []


func _naghash_jahan() -> void:
        ## گل‌های شب‌زنده
        for gol in gol_ha:
                var sway := sin(t * 1.2 + gol.faz) * 8.0
                var tip := Vector2(gol.x + sway, H - gol.h)
                jahan.draw_line(Vector2(gol.x, H), tip, Color("#1a3a28"), 2.5, true)
                jahan.draw_circle(tip, 12.0, Color(gol.rang, 0.32))
                jahan.draw_circle(tip, 5.0, Color(gol.rang, 0.95))
        ## علف‌های تاب‌خوران
        for a in alaf_ha:
                var sway2 := sin(t * 1.8 + a.faz) * 0.14
                var nook := Vector2(a.x, H - 4)
                var tip2: Vector2 = nook + Vector2(sin(sway2), -1.0).normalized() * a.h
                var chahar := PackedVector2Array([nook + Vector2(-3.5, 0), nook + Vector2(3.5, 0), tip2 + Vector2(2, 0), tip2 + Vector2(-2, 0)])
                jahan.draw_colored_polygon(chahar, Color("#0f2d1d"))
        ## تخم‌های نور
        for m in tokm_ha:
                var pel := 1.0 + 0.2 * sin(t * 4.0 + m.faz)
                jahan.draw_circle(m.pos, 14.0 * pel, Color("#9dffbe", 0.35))
                jahan.draw_circle(m.pos, 6.0 * pel, Color("#d8ffe6"))
        ## حلقهٔ هاله دور شب‌تاب
        jahan.draw_arc(makan, 44.0 + aura * 80.0, 0.0, TAU, 48, Color("#ffe98a", 0.6), 3.5, true)
        jahan.draw_arc(makan, 44.0 + aura * 80.0, t * 2.0, t * 2.0 + 1.2, 12, Color("#fffbe0", 0.8), 3.0, true)
        ## پروانه‌ها بدنشان در نود خودشان کشیده می‌شود (alpha با نود)
        for d in parvane_ha:
                var n: Node2D = d.node
                n.queue_redraw()
        for p in pop_ha:
                p.omr -= get_process_delta_time()
                p.pos.y -= 34.0 * get_process_delta_time()
        var zande := []
        for p in pop_ha:
                if p.omr > 0.0:
                        zande.append(p)
                        jahan.draw_string(fon_b, p.pos, p.matn, HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color(p.rang, clampf(p.omr, 0.0, 1.0)))
        pop_ha = zande


func _naghash_parvane(n: Node2D) -> void:
        ## بدن تیره با بال‌های بال‌زن و چشم سرخ
        var d = null
        for c in parvane_ha:
                if c.node == n:
                        d = c
                        break
        if d == null:
                return
        var baz := sin(t * 14.0 + float(d.faz))
        var bal_chap := PackedVector2Array([Vector2(-3, -2), Vector2(-17, -11.0 * baz), Vector2(-15, 3.0 * baz)])
        var bal_raast := PackedVector2Array([Vector2(3, -2), Vector2(17, -11.0 * baz), Vector2(15, 3.0 * baz)])
        n.draw_colored_polygon(bal_chap, Color("#191326"))
        n.draw_colored_polygon(bal_raast, Color("#191326"))
        n.draw_circle(Vector2.ZERO, 8.0, Color("#0d0a14"))
        n.draw_circle(Vector2(0, -3), 2.4, Color("#ff3b3b"))
        n.draw_circle(Vector2(0, -3), 5.0, Color("#ff3b3b", 0.25))
