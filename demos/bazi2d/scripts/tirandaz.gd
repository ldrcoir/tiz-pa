# ═══════════════════════════════════════════════════════════════
#  شهاب — تیرانداز فضایی
#  ستاره‌های پارالاکس، مه‌نماهای نرم، سه نوع دشمن، انفجار ذره‌ای،
#  لرزش صفحه و شماره‌های فارسی — همه با draw و پارتیکل، بدون عکس
# ═══════════════════════════════════════════════════════════════
extends Node2D

const MASIR_AKS := "/home/z/my-project/download/screenshots_2d"
const TOOL_AKSMAN := 520.0

var fnt: FontFile = null
var fnt_tiz: FontFile = null
var argha: Array = []
var aks_mode := false
var t_test := 0.0
var aks_gerefte := {}

var setareha: Array = []
var goluleha: Array = []          # Vector2
var doshmanha: Array = []         # {ja, noe, phaz, hp, rot}
var pop_ha: Array = []            # {l, ja, sen}
var zaman := 0.0
var zamane_tir := 0.0
var zamane_doshman := 0.0
var emtiaz := 0
var jan := 3
var moj := 1
var larze := 0.0
var flash := 0.0
var seh: Node2D                    # سفینه‌ی بازیکن
var hud: CanvasLayer
var matne_emtiaz: Label
var matne_jan: Label
var matne_moj: Label

func _fnt_amn(masir: String) -> FontFile:
        if ResourceLoader.exists(masir):
                return load(masir)
        return null

func _fa(adad: int) -> String:
        var s := ""
        for ch in str(adad):
                s += "۰۱۲۳۴۵۶۷۸۹"[int(ch)] if ch >= "0" and ch <= "9" else ch
        return s

func _ready() -> void:
        fnt = _fnt_amn("res://assets/fonts/Vazirmatn-Bold.ttf")
        fnt_tiz = _fnt_amn("res://assets/fonts/Lalezar-Regular.ttf")
        argha = OS.get_cmdline_user_args()
        aks_mode = argha.has("--aks")
        # ستاره‌ها — سه لایه سرعت برای حس عمق
        for i in 80:
                var laye := i % 3
                setareha.append({
                        "ja": Vector2(randf_range(0, 1280), randf_range(0, 720)),
                        "andaze": 1.5 + laye * 0.8,
                        "shetab": 26.0 + laye * 34.0,
                        "shafaf": 0.35 + laye * 0.22
                })
        _mehnama_besaz()
        seh = Node2D.new()
        seh.position = Vector2(640, 600)
        add_child(seh)
        _hud_besaz()

# مه‌نماها — گرادیان شعاعی نرم که فضای عمیق می‌سازند
func _mehnama_besaz() -> void:
        var rangha := [Color("7c4dff"), Color("00e5ff"), Color("ff5470")]
        var jaha := [Vector2(260, 180), Vector2(1010, 300), Vector2(620, 660)]
        for i in 3:
                var gh := Gradient.new()
                gh.colors = PackedColorArray([Color(rangha[i], 0.22), Color(rangha[i], 0.0)])
                gh.offsets = PackedFloat32Array([0.0, 1.0])
                var th := GradientTexture2D.new()
                th.gradient = gh
                th.fill = GradientTexture2D.FILL_RADIAL
                th.fill_from = Vector2(0.5, 0.5)
                th.fill_to = Vector2(0.5, 0.0)
                th.width = 640
                th.height = 640
                var sp := Sprite2D.new()
                sp.texture = th
                sp.position = jaha[i]
                add_child(sp)

func _hud_besaz() -> void:
        hud = CanvasLayer.new()
        add_child(hud)
        matne_emtiaz = _label_besaz("امتیاز " + _fa(emtiaz), fnt_tiz, 42, Color("ffd94a"), Vector2(40, 24), HORIZONTAL_ALIGNMENT_LEFT)
        matne_jan = _label_besaz("جان " + _fa(jan), fnt, 30, Color("ff5470"), Vector2(1080, 30), HORIZONTAL_ALIGNMENT_RIGHT)
        matne_moj = _label_besaz("موج " + _fa(moj), fnt, 26, Color("00e5ff"), Vector2(40, 80), HORIZONTAL_ALIGNMENT_LEFT)
        var onvan := _label_besaz("شهاب — تیرانداز فضایی", fnt_tiz, 30, Color(1, 1, 1, 0.5), Vector2(400, 24), HORIZONTAL_ALIGNMENT_CENTER)
        onvan.size = Vector2(480, 40)

func _label_besaz(matn: String, fon: FontFile, andaze: int, rang: Color, ja: Vector2, kaf: int) -> Label:
        var l := Label.new()
        l.text = matn
        l.position = ja
        l.horizontal_alignment = kaf
        l.add_theme_font_override("font", fon)
        l.add_theme_font_size_override("font_size", andaze)
        l.add_theme_color_override("font_color", rang)
        l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
        l.add_theme_constant_override("shadow_offset_x", 2)
        l.add_theme_constant_override("shadow_offset_y", 3)
        hud.add_child(l)
        return l

func _process(dt: float) -> void:
        zaman += dt
        _setareha_tike(dt)
        _otopilot(dt)
        _golule_tike(dt)
        _doshman_tike(dt)
        _pop_tike(dt)
        if larze > 0.0:
                larze = maxf(larze - dt * 2.2, 0.0)
                position = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * 9.0 * larze
        else:
                position = Vector2.ZERO
        if flash > 0.0:
                flash = maxf(flash - dt * 2.5, 0.0)
                queue_redraw()
        matne_emtiaz.text = "امتیاز " + _fa(emtiaz)
        matne_jan.text = "جان " + _fa(jan)
        matne_moj.text = "موج " + _fa(moj)
        moj = 1 + int(zaman / 6.0)
        queue_redraw()
        if aks_mode:
                _azm_tike(dt)

# اتوپایلوت — مثل یک بازیکن واقعی به نزدیک‌ترین دشمن شلیک می‌کند
func _otopilot(dt: float) -> void:
        var hedef := Vector2(640, 600)
        var nazdik := INF
        for d in doshmanha:
                var f := float(d["ja"].y)
                if f < nazdik:
                        nazdik = f
                        hedef = d["ja"]
        var gh := clampf(hedef.x, 70, 1210)
        seh.position.x = move_toward(seh.position.x, gh, TOOL_AKSMAN * dt)
        seh.position.y = 600.0 + sin(zaman * 1.7) * 14.0
        zamane_tir -= dt
        if zamane_tir <= 0.0 and not doshmanha.is_empty():
                zamane_tir = 0.24
                goluleha.append(seh.position + Vector2(0, -34))

func _golule_tike(dt: float) -> void:
        var mande: Array = []
        for g in goluleha:
                var jadid := g + Vector2(0, -780.0) * dt
                if jadid.y > -20:
                        mande.append(jadid)
                # برخورد با دشمن‌ها — نزدیک‌ترین را پیدا کن
                for i in doshmanha.size():
                        if jadid.distance_to(doshmanha[i]["ja"]) < 36.0:
                                doshmanha[i]["hp"] -= 1
                                mande.pop_back()
                                if doshmanha[i]["hp"] <= 0:
                                        _enzekar(doshmanha[i]["ja"], doshmanha[i]["noe"])
                                        doshmanha.remove_at(i)
                                        emtiaz += 10
                                        _pop_besaz("+۱۰", Color("ffd94a"), jadid)
                                break
        goluleha = mande

func _doshman_tike(dt: float) -> void:
        zamane_doshman -= dt
        if zamane_doshman <= 0.0:
                zamane_doshman = maxf(0.85 - zaman * 0.012, 0.5)
                var no := randi() % 3
                doshmanha.append({
                        "ja": Vector2(randf_range(90, 1190), -50),
                        "noe": no,
                        "phaz": randf_range(0, TAU),
                        "hp": 2 if no == 1 else 1,
                        "rot": randf_range(-0.6, 0.6)
                })
        var mande: Array = []
        for d in doshmanha:
                d["ja"].y += (120.0 + moj * 16.0) * dt
                d["ja"].x += sin(zaman * 2.4 + float(d["phaz"])) * 62.0 * dt
                if d["ja"].y < 760:
                        mande.append(d)
        doshmanha = mande
        for d in doshmanha:
                if d["ja"].distance_to(seh.position) < 52.0:
                        _enzekar(d["ja"], d["noe"])
                        doshmanha.erase(d)
                        jan -= 1
                        larze = 1.0
                        flash = 0.6
                        if jan <= 0:
                                jan = 3   # در دموی آزمایشگاه بی‌صدا ادامه بده
        if int(zaman) % 6 == 0 and zaman > 1.0 and moj != int(get_meta("moj_dbg", -1)):
                set_meta("moj_dbg", moj)

func _enzekar(ja: Vector2, noe: int) -> void:
        var p := CPUParticles2D.new()
        p.position = ja
        p.amount = 30
        p.one_shot = true
        p.explosiveness = 1.0
        p.lifetime = 0.65
        p.direction = Vector2(0, -1)
        p.spread = 180.0
        p.gravity = Vector2(0, 300)
        p.initial_velocity_min = 130.0
        p.initial_velocity_max = 360.0
        p.scale_amount_min = 2.5
        p.scale_amount_max = 6.0
        p.color = [Color("ffd94a"), Color("ff5470"), Color("ff8c42"), Color("00e5ff")][noe]
        add_child(p)
        p.emitting = true
        get_tree().create_timer(1.1).timeout.connect(func(): p.queue_free())

func _pop_besaz(matn: String, rang: Color, ja: Vector2) -> void:
        var l := Label.new()
        l.text = matn
        l.add_theme_font_override("font", fnt_tiz)
        l.add_theme_font_size_override("font_size", 30)
        l.add_theme_color_override("font_color", rang)
        l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
        l.position = ja - Vector2(20, 40)
        l.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(l)
        pop_ha.append({"l": l, "ja": ja, "sen": 0.0})

func _pop_tike(dt: float) -> void:
        var mande: Array = []
        for p in pop_ha:
                p["sen"] += dt
                p["ja"].y -= 52.0 * dt
                p["l"].position = p["ja"] - Vector2(20, 40)
                p["l"].modulate.a = maxf(1.0 - p["sen"] / 0.7, 0.0)
                if p["sen"] < 0.7:
                        mande.append(p)
                else:
                        p["l"].queue_free()
        pop_ha = mande

func _setareha_tike(dt: float) -> void:
        for s in setareha:
                s["ja"].y += float(s["shetab"]) * dt
                if s["ja"].y > 724:
                        s["ja"].y = -6
                        s["ja"].x = randf_range(0, 1280)

func _azm_tike(dt: float) -> void:
        t_test += dt
        for m in [[2.6, "tirandaz_1"], [5.6, "tirandaz_2"]]:
                if t_test > float(m[0]) and not aks_gerefte.has(m[1]):
                        aks_gerefte[m[1]] = true
                        _aks_begir(MASIR_AKS + "/" + m[1] + ".png")
        if t_test > 7.2:
                print("[demo2d] TIRANDAZ DONE emtiaz=", emtiaz)
                get_tree().quit()

func _aks_begir(masir: String) -> void:
        var aks := get_viewport().get_texture().get_image()
        if aks != null:
                aks.save_png(masir)
                print("[demo2d] SHOT ", masir)

# ═══════════ نقاشی — هر فریم با کد کشیده می‌شود ═══════════
func _draw() -> void:
        # رنگ چشمک قرمز هنگام برخورد
        if flash > 0.0:
                draw_rect(Rect2(0, 0, 1280, 720), Color(1, 0.2, 0.3, 0.22 * flash))
        # ستاره‌ها
        for s in setareha:
                draw_rect(Rect2(s["ja"], Vector2(float(s["andaze"]), float(s["andaze"]) * 2.2)), Color(1, 1, 1, float(s["shafaf"])))
        # گلوله‌ها — هسته‌ی روشن + هاله
        for g in goluleha:
                draw_circle(g, 9.0, Color(1, 0.9, 0.3, 0.25))
                draw_circle(g, 5.0, Color("ffe98a"))
        # دشمن‌ها — سه شکل متفاوت با چرخش آرام
        for d in doshmanha:
                var rot: float = float(d["rot"]) + sin(zaman * 3.0 + float(d["phaz"])) * 0.25
                draw_set_transform(d["ja"], rot, Vector2.ONE)
                match int(d["noe"]):
                        0: _poly_doshman(Color("ff5470"), [Vector2(0, 26), Vector2(22, 0), Vector2(0, -26), Vector2(-22, 0)])
                        1: _poly_doshman(Color("7c4dff"), _sheshgon(30.0))
                        2: _poly_doshman(Color("ffb347"), [Vector2(-32, 0), Vector2(-14, 16), Vector2(14, 16), Vector2(32, 0), Vector2(14, -16), Vector2(-14, -16)])
                draw_circle(Vector2(0, 0), 6.0, Color(1, 1, 1, 0.85))
        draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
        # سفینه — بدنه‌ی فیروزه‌ای، کابین سفید، شعله‌ی لرزان
        var flam := 16.0 + sin(zaman * 42.0) * 7.0
        draw_set_transform(seh.position, 0.0, Vector2.ONE)
        draw_colored_polygon(PackedVector2Array([Vector2(4, 14), Vector2(9, 14 + flam), Vector2(14, 14)]), Color("ff8c42"))
        draw_colored_polygon(PackedVector2Array([Vector2(-14, 14), Vector2(-9, 14 + flam), Vector2(-4, 14)]), Color("ff5470"))
        draw_colored_polygon(PackedVector2Array([Vector2(0, -34), Vector2(24, 16), Vector2(10, 22), Vector2(0, 14), Vector2(-10, 22), Vector2(-24, 16)]), Color("00e5ff"))
        draw_colored_polygon(PackedVector2Array([Vector2(0, -22), Vector2(8, 0), Vector2(0, 8), Vector2(-8, 0)]), Color(1, 1, 1, 0.92))

func _poly_doshman(rang: Color, noghte: Array) -> void:
        var pk := PackedVector2Array()
        for p in noghte:
                pk.append(p)
        draw_colored_polygon(pk, rang)
        draw_polyline(pk + PackedVector2Array([noghte[0]]), rang.lightened(0.35), 2.5)

func _sheshgon(shoa: float) -> Array:
        var noghte: Array = []
        for i in 6:
                noghte.append(Vector2.from_angle(float(i) * TAU / 6.0 - PI / 2.0) * shoa)
        return noghte
