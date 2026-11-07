extends Node2D
# «هلیا پلیس» — پلتفرمر پشت‌بام‌های تهران
# هلیا با یونیفرم پلیس دنبال دزدِ دیگ است؛ سکه‌های دزدیده‌شده را پس می‌گیرد
# سبک: فلتِ مدرنِ غروبِ تهران — پارالاکس البرز و شهر، بادگیر و رخت‌آویز و گربهٔ پشت‌بام
# نه رترو است، نه کپی؛ از صفر برای این بازی طراحی شده

const TOL := 5300.0                                   # طول جهان
const AKS_DIR := "/home/z/my-project/to/helia_polis/aks/"

# پالت غروب تهران
const RANG_ASEMAN_BALA := Color(0.106, 0.118, 0.235)
const RANG_ASEMAN_MIANE := Color(0.36, 0.208, 0.40)
const RANG_ASEMAN_AFKHOR := Color(0.91, 0.45, 0.29)
const RANG_KOH_DOOR := Color(0.29, 0.208, 0.40)
const RANG_KOH_NAZDIK := Color(0.227, 0.165, 0.322)
const RANG_SHAHR := Color(0.173, 0.129, 0.271)
const RANG_MILAD := Color(0.36, 0.29, 0.55)
const RANG_SAKHTAMAN := Color(0.11, 0.086, 0.188)
const RANG_PASHBAM := Color(0.20, 0.165, 0.322)
const RANG_LABE := Color(0.29, 0.247, 0.47)
const RANG_ZIN := Color(0.267, 0.224, 0.431)
const RANG_ZIN_2 := Color(0.337, 0.29, 0.522)
const RANG_SEKE := Color(1.0, 0.80, 0.35)

var sath_ha := [
        {"x0": 0.0, "x1": 980.0, "y": 560.0},
        {"x0": 1120.0, "x1": 1800.0, "y": 500.0},
        {"x0": 1930.0, "x1": 2660.0, "y": 430.0},
        {"x0": 2820.0, "x1": 3420.0, "y": 490.0},
        {"x0": 3600.0, "x1": 4260.0, "y": 540.0},
        {"x0": 4420.0, "x1": 5300.0, "y": 560.0},
]
# نقاط پرش خلبان خودکار — ۵۵ پیکسل مانده به هر شکاف
var navarti := [925, 1745, 2605, 3365, 4205]
var nav_dozd := [1745, 2605, 3365, 4205]
var ja_sekeh_ha := [
        Vector2(1005, 470), Vector2(1055, 440), Vector2(1105, 470),
        Vector2(1830, 390), Vector2(1880, 360), Vector2(1930, 390),
        Vector2(3460, 450), Vector2(3510, 420), Vector2(3560, 450),
        Vector2(4600, 490), Vector2(4700, 478), Vector2(4800, 490),
]

var dorbin: Camera2D
var helia
var dozd
var zaman := 0.0
var lershe := 0.0
var teh_sekeh := 0
var halat_bazi := "doid"                              # doid | bord
var khod_peyma := false
var marhale := 0
var onvan_raft := false

var lbl_sekeh: Label
var lbl_mamuriyat: Label
var karte_onvan: Control
var bayar_gereftan: Control
var fnt_lalezar: FontFile
var fnt_vazir: FontFile

func _ready() -> void:
        fnt_lalezar = load("res://assets/fonts/Lalezar-Regular.ttf")
        fnt_vazir = load("res://assets/fonts/Vazirmatn-Bold.ttf")
        khod_peyma = OS.get_cmdline_user_args().has("--aks")
        sakht_aseman()
        sakht_sath_ha()
        sakht_sekeh_ha()
        sakht_bazikon_ha()
        sakht_dorbin()
        sakht_hud()

# ─── ساخت جهان ───────────────────────────────────────────────

func sakht_aseman() -> void:
        var laye := CanvasLayer.new()
        laye.layer = -10
        add_child(laye)
        var aseman := Aseman.new()
        laye.add_child(aseman)
        # وینیت نرم دور کادر
        var laye2 := CanvasLayer.new()
        laye2.layer = 8
        add_child(laye2)
        laye2.add_child(Viniet.new())

func sakht_sath_ha() -> void:
        for s in sath_ha:
                var badane := StaticBody2D.new()
                var shekl := CollisionShape2D.new()
                var moraba := RectangleShape2D.new()
                moraba.size = Vector2(s.x1 - s.x0, 30)
                shekl.shape = moraba
                shekl.position = Vector2((s.x0 + s.x1) * 0.5, s.y + 15)
                badane.add_child(shekl)
                add_child(badane)
        # دیوارهای دو سر جهان
        for j in [[-20.0, 300.0], [TOL + 20.0, 300.0]]:
                var divar := StaticBody2D.new()
                var shekl2 := CollisionShape2D.new()
                var moraba2 := RectangleShape2D.new()
                moraba2.size = Vector2(40, 700)
                shekl2.shape = moraba2
                shekl2.position = Vector2(j[0], j[1])
                divar.add_child(shekl2)
                add_child(divar)

func sakht_sekeh_ha() -> void:
        var sh := 0
        for ja in ja_sekeh_ha:
                var seke := Ske.new(sh * 0.37)
                seke.position = ja
                add_child(seke)
                sh += 1

func sakht_bazikon_ha() -> void:
        helia = CharacterBody2D.new()
        helia.name = "helia"
        helia.set_script(load("res://scripts/helia.gd"))
        helia.position = Vector2(200, 556)
        helia.khod_peyma = khod_peyma
        add_child(helia)
        dozd = CharacterBody2D.new()
        dozd.name = "dozd"
        dozd.set_script(load("res://scripts/dozd.gd"))
        dozd.position = Vector2(1250, 496)
        add_child(dozd)

func sakht_dorbin() -> void:
        dorbin = Camera2D.new()
        dorbin.limit_left = 0
        dorbin.limit_right = int(TOL)
        dorbin.limit_top = -260
        dorbin.limit_bottom = 780
        dorbin.position_smoothing_enabled = false
        dorbin.position = helia.position + Vector2(0, -120)
        add_child(dorbin)
        dorbin.make_current()

func sakht_hud() -> void:
        var laye := CanvasLayer.new()
        laye.layer = 10
        add_child(laye)
        # شمارندهٔ سکه — بالا چپ
        lbl_sekeh = Label.new()
        lbl_sekeh.text = "سکه‌ها ۰/۱۲"
        lbl_sekeh.add_theme_font_override("font", fnt_vazir)
        lbl_sekeh.add_theme_font_size_override("font_size", 27)
        lbl_sekeh.add_theme_color_override("font_color", Color(1.0, 0.90, 0.65))
        lbl_sekeh.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.55))
        lbl_sekeh.add_theme_constant_override("shadow_offset_x", 3)
        lbl_sekeh.add_theme_constant_override("shadow_offset_y", 3)
        lbl_sekeh.position = Vector2(26, 16)
        laye.add_child(lbl_sekeh)
        # مأموریت — بالا راست
        lbl_mamuriyat = Label.new()
        lbl_mamuriyat.text = "دزد دیگ رو گیر بنداز!"
        lbl_mamuriyat.add_theme_font_override("font", fnt_vazir)
        lbl_mamuriyat.add_theme_font_size_override("font_size", 21)
        lbl_mamuriyat.add_theme_color_override("font_color", Color(1.0, 0.96, 0.88, 0.92))
        lbl_mamuriyat.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
        lbl_mamuriyat.add_theme_constant_override("shadow_offset_y", 2)
        lbl_mamuriyat.position = Vector2(880, 22)
        laye.add_child(lbl_mamuriyat)
        # کارت عنوان — وسط
        karte_onvan = Control.new()
        karte_onvan.set_anchors_preset(Control.PRESET_FULL_RECT)
        laye.add_child(karte_onvan)
        var onvan := Label.new()
        onvan.text = "هلیا پلیس"
        onvan.add_theme_font_override("font", fnt_lalezar)
        onvan.add_theme_font_size_override("font_size", 92)
        onvan.add_theme_color_override("font_color", Color(1.0, 0.83, 0.42))
        onvan.add_theme_color_override("font_shadow_color", Color(0.08, 0.05, 0.12, 0.8))
        onvan.add_theme_constant_override("shadow_offset_x", 5)
        onvan.add_theme_constant_override("shadow_offset_y", 6)
        onvan.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        onvan.position = Vector2(0, 148)
        onvan.size = Vector2(1280, 120)
        karte_onvan.add_child(onvan)
        var zironvan := Label.new()
        zironvan.text = "گشتِ پشت‌بام‌های تهران"
        zironvan.add_theme_font_override("font", fnt_vazir)
        zironvan.add_theme_font_size_override("font_size", 30)
        zironvan.add_theme_color_override("font_color", Color(1.0, 0.95, 0.88, 0.95))
        zironvan.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
        zironvan.add_theme_constant_override("shadow_offset_y", 3)
        zironvan.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        zironvan.position = Vector2(0, 272)
        zironvan.size = Vector2(1280, 44)
        karte_onvan.add_child(zironvan)
        var rahnama := Label.new()
        rahnama.text = "فلش چپ/راست: دویدن      فاصله: پرش"
        rahnama.add_theme_font_override("font", fnt_vazir)
        rahnama.add_theme_font_size_override("font_size", 20)
        rahnama.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.72))
        rahnama.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
        rahnama.add_theme_constant_override("shadow_offset_y", 2)
        rahnama.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        rahnama.position = Vector2(0, 632)
        rahnama.size = Vector2(1280, 36)
        karte_onvan.add_child(rahnama)
        # بنر برد — وسط، پنهان
        bayar_gereftan = Control.new()
        bayar_gereftan.set_anchors_preset(Control.PRESET_FULL_RECT)
        bayar_gereftan.visible = false
        laye.add_child(bayar_gereftan)
        var bayar1 := Label.new()
        bayar1.text = "گیرش انداختی!"
        bayar1.add_theme_font_override("font", fnt_lalezar)
        bayar1.add_theme_font_size_override("font_size", 76)
        bayar1.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))
        bayar1.add_theme_color_override("font_shadow_color", Color(0.1, 0.05, 0.1, 0.8))
        bayar1.add_theme_constant_override("shadow_offset_x", 4)
        bayar1.add_theme_constant_override("shadow_offset_y", 5)
        bayar1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        bayar1.position = Vector2(0, 236)
        bayar1.size = Vector2(1280, 100)
        bayar_gereftan.add_child(bayar1)
        var bayar2 := Label.new()
        bayar2.text = "دیگ برگشت خونه — مأموریت کامل شد"
        bayar2.add_theme_font_override("font", fnt_vazir)
        bayar2.add_theme_font_size_override("font_size", 26)
        bayar2.add_theme_color_override("font_color", Color(1.0, 0.96, 0.90, 0.95))
        bayar2.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
        bayar2.add_theme_constant_override("shadow_offset_y", 2)
        bayar2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        bayar2.position = Vector2(0, 344)
        bayar2.size = Vector2(1280, 40)
        bayar_gereftan.add_child(bayar2)

# ─── حلقهٔ بازی ──────────────────────────────────────────────

func _process(delta: float) -> void:
        zaman += delta
        # دوربین دنبال هلیا با نگاهِ رو به جلو
        var negah_jolo: float = helia.velocity.x * 0.30
        var hadaf: Vector2 = helia.position + Vector2(negah_jolo, -120)
        dorbin.position = dorbin.position.lerp(hadaf, 1.0 - pow(0.001, delta))
        # لرزش صحنه
        lershe = lerpf(lershe, 0.0, 9.0 * delta)
        dorbin.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * lershe
        # گرفتن دزد
        if halat_bazi == "doid" and helia.global_position.distance_to(dozd.global_position) < 80.0:
                bord()
        # افتادن از پشت‌بام — برگشت نرم به آخرین پشت‌بام
        if helia.position.y > 900.0:
                bazgash()
        # محو کارت عنوان
        if not onvan_raft:
                var shurud := 2.2 if khod_peyma else 3.8
                if zaman > shurud:
                        onvan_raft = true
                        var tv := create_tween()
                        tv.tween_property(karte_onvan, "modulate:a", 0.0, 0.7)
        # تایم‌لاین دمو و اسکرین‌شات
        if khod_peyma:
                if marhale == 0 and zaman > 1.15:
                        marhale = 1
                        aks("akse_1_onvan.png")
                elif marhale == 1 and zaman > 5.40:
                        marhale = 2
                        aks("akse_2_bazi.png")
                elif marhale == 2 and zaman > 7.90:
                        marhale = 3
                        # صحنهٔ پایانی تمیز: هر دو روی پشت‌بام چهارم
                        helia.position = Vector2(2900.0, 484.0)
                        helia.velocity = Vector2.ZERO
                        dozd.position = helia.position + Vector2(56, 0)
                        dozd.velocity = Vector2.ZERO
                elif marhale == 3 and zaman > 8.70:
                        marhale = 4
                        aks("akse_3_gereftan.png")
                elif marhale == 4 and zaman > 9.30:
                        get_tree().quit()
        queue_redraw()

func bord() -> void:
        halat_bazi = "bord"
        dozd.halat = "gereftan"
        lershe = 16.0
        konfeti(dozd.global_position + Vector2(0, -40))
        bayar_gereftan.visible = true
        bayar_gereftan.modulate.a = 0.0
        var tv := create_tween()
        tv.tween_property(bayar_gereftan, "modulate:a", 1.0, 0.4)
        lbl_mamuriyat.text = "مأموریت کامل شد"

func bazgash() -> void:
        var x: float = helia.position.x
        var s := safhe_yab(x)
        helia.position = Vector2(clampf(x, s.x0 + 60.0, s.x1 - 60.0), s.y - 6.0)
        helia.velocity = Vector2.ZERO
        lershe = 6.0
        porup(Vector2(helia.position.x, s.y), "اه!", Color(1, 1, 1, 0.9))

func safhe_yab(x: float) -> Dictionary:
        var behtar: Dictionary = sath_ha[0]
        for s in sath_ha:
                if x >= s.x0 and x <= s.x1:
                        return s
                if absf(x - (s.x0 + s.x1) * 0.5) < absf(x - (behtar.x0 + behtar.x1) * 0.5):
                        behtar = s
        return behtar

func ske_gereft(seke) -> void:
        if halat_bazi != "doid":
                return
        teh_sekeh += 1
        lbl_sekeh.text = "سکه‌ها " + adad_fa(teh_sekeh) + "/" + adad_fa(12)
        porup(seke.global_position, "+" + adad_fa(1), RANG_SEKE)
        shekar(seke.global_position)
        lershe = 3.0

# ─── جلوه‌ها ─────────────────────────────────────────────────

func konfeti(ja: Vector2) -> void:
        var z := CPUParticles2D.new()
        z.one_shot = true
        z.emitting = true
        z.amount = 80
        z.lifetime = 1.3
        z.explosiveness = 1.0
        z.spread = 180.0
        z.direction = Vector2(0, -1)
        z.initial_velocity_min = 220.0
        z.initial_velocity_max = 480.0
        z.gravity = Vector2(0, 760)
        z.scale_amount_min = 3.0
        z.scale_amount_max = 6.5
        var grad := Gradient.new()
        grad.offsets = PackedFloat32Array([0.0, 0.33, 0.66, 1.0])
        grad.colors = PackedColorArray([Color("ffd166"), Color("06d6a0"), Color("ef476f"), Color("f8f9fa")])
        z.color_initial_ramp = grad
        z.position = ja
        add_child(z)
        var tv := create_tween()
        tv.tween_interval(2.2)
        tv.tween_callback(z.queue_free)

func shekar(ja: Vector2) -> void:
        var z := CPUParticles2D.new()
        z.one_shot = true
        z.emitting = true
        z.amount = 18
        z.lifetime = 0.5
        z.explosiveness = 1.0
        z.spread = 180.0
        z.initial_velocity_min = 90.0
        z.initial_velocity_max = 200.0
        z.gravity = Vector2(0, 120)
        z.scale_amount_min = 2.0
        z.scale_amount_max = 4.0
        z.color = Color(1.0, 0.88, 0.5)
        z.position = ja
        add_child(z)
        var tv := create_tween()
        tv.tween_interval(1.0)
        tv.tween_callback(z.queue_free)

func porup(ja: Vector2, matn: String, rang: Color) -> void:
        var lbl := Label.new()
        lbl.text = matn
        lbl.add_theme_font_override("font", fnt_lalezar)
        lbl.add_theme_font_size_override("font_size", 30)
        lbl.add_theme_color_override("font_color", rang)
        lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
        lbl.add_theme_constant_override("shadow_offset_y", 2)
        add_child(lbl)
        lbl.position = ja + Vector2(-24, -78)
        lbl.z_index = 50
        var tv := create_tween()
        tv.set_parallel(true)
        tv.tween_property(lbl, "position:y", lbl.position.y - 52.0, 0.9)
        tv.tween_property(lbl, "modulate:a", 0.0, 0.9).set_delay(0.35)
        tv.chain().tween_callback(lbl.queue_free)

func adad_fa(n: int) -> String:
        var ragham := "۰۱۲۳۴۵۶۷۸۹"
        var khoruji := ""
        for herf in str(n):
                khoruji += ragham[int(herf)]
        return khoruji

func aks(nam: String) -> void:
        await RenderingServer.frame_post_draw
        var tasvir := get_viewport().get_texture().get_image()
        tasvir.save_png(AKS_DIR + nam)
        print("akse zakhire shod: " + nam)

# ─── نقاشی جهان (هر فریم — پارالاکس دستی) ────────────────────

func _draw() -> void:
        var t := Time.get_ticks_msec() / 1000.0
        var cam_x := dorbin.position.x + dorbin.offset.x
        # البرز — دو رشته‌کوه با برف
        koh(cam_x, 0.88, 777, 640.0, 60.0, 230.0, RANG_KOH_DOOR, true)
        koh(cam_x, 0.80, 888, 660.0, 40.0, 150.0, RANG_KOH_NAZDIK, false)
        # خط افق شهر + برج میلاد و آزادی و گنبدها (پارالاکس ۰٫۲۵)
        var os := cam_x * 0.75
        kume_shahr(os - 500.0, 660.0, 11)
        milad(1300.0 + os, 660.0, t)
        azadi(600.0 + os, 660.0)
        kume_shahr(os + 900.0, 660.0, 22)
        kume_shahr(os + 1700.0, 660.0, 33)
        # پشت‌بام‌ها و ساختمان‌ها
        var i := 0
        for s in sath_ha:
                sakhtaman(s, i, t)
                i += 1

func koh(cam_x: float, k: float, tokhm: int, paye: float, kamin: float, bolandi: float, rang: Color, barf: bool) -> void:
        var rnd := RandomNumberGenerator.new()
        rnd.seed = tokhm
        var ebteda := cam_x * (1.0 - k) - 600.0
        var noghte := PackedVector2Array()
        var x := ebteda
        while x < ebteda + 2600.0:
                noghte.append(Vector2(x, paye - rnd.randf_range(kamin, bolandi)))
                x += rnd.randf_range(120.0, 190.0)
        noghte.append(Vector2(ebteda + 2600.0, paye))
        noghte.append(Vector2(ebteda + 2600.0, 920.0))
        noghte.append(Vector2(ebteda, 920.0))
        draw_colored_polygon(noghte, rang)
        if barf:
                for p in noghte:
                        if p.y < paye - bolandi * 0.55:
                                draw_colored_polygon(PackedVector2Array([p, p + Vector2(16, 18), p + Vector2(-16, 18)]), Color(1, 1, 1, 0.30))

func milad(cx: float, paye: float, t: float) -> void:
        var r := RANG_MILAD
        # تنهٔ مخروطی
        draw_colored_polygon(PackedVector2Array([Vector2(cx - 11, paye), Vector2(cx - 6, paye - 212), Vector2(cx + 6, paye - 212), Vector2(cx + 11, paye)]), r)
        # اتاقک هشت‌وجهی
        draw_colored_polygon(PackedVector2Array([Vector2(cx - 23, paye - 212), Vector2(cx - 16, paye - 248), Vector2(cx + 16, paye - 248), Vector2(cx + 23, paye - 212)]), r.lightened(0.06))
        draw_colored_polygon(PackedVector2Array([Vector2(cx - 12, paye - 248), Vector2(cx - 7, paye - 270), Vector2(cx + 7, paye - 270), Vector2(cx + 12, paye - 248)]), r)
        draw_rect(Rect2(cx - 8, paye - 284, 16, 14), r.lightened(0.04))
        # دکل
        draw_line(Vector2(cx, paye - 284), Vector2(cx, paye - 336), r.lightened(0.10), 3.0)
        # نوارهای نورانی اتاقک + چراغ سرخ تپنده
        draw_line(Vector2(cx - 19, paye - 222), Vector2(cx + 19, paye - 222), Color(1.0, 0.85, 0.5, 0.35), 2.0)
        draw_line(Vector2(cx - 16, paye - 238), Vector2(cx + 16, paye - 238), Color(1.0, 0.85, 0.5, 0.28), 2.0)
        draw_circle(Vector2(cx, paye - 300), 3.5, Color(1.0, 0.25, 0.25, 0.5 + 0.5 * sin(t * 2.6)))

func azadi(cx: float, paye: float) -> void:
        var r := RANG_SHAHR.lightened(0.05)
        draw_colored_polygon(PackedVector2Array([Vector2(cx - 42, paye), Vector2(cx - 30, paye - 58), Vector2(cx + 30, paye - 58), Vector2(cx + 42, paye)]), r)
        draw_rect(Rect2(cx - 24, paye - 74, 48, 18), r)
        draw_rect(Rect2(cx - 28, paye - 78, 56, 5), r.lightened(0.08))
        # دهانهٔ طاق
        draw_colored_polygon(PackedVector2Array([Vector2(cx - 13, paye), Vector2(cx - 13, paye - 30), Vector2(cx - 7, paye - 40), Vector2(cx + 7, paye - 40), Vector2(cx + 13, paye - 30), Vector2(cx + 13, paye)]), Color(0.76, 0.37, 0.26))

func kume_shahr(bx: float, paye: float, tokhm: int) -> void:
        var rnd := RandomNumberGenerator.new()
        rnd.seed = tokhm
        var x := bx
        var sh := 0
        while sh < 5:
                var pahna := rnd.randf_range(70.0, 130.0)
                var bolandi := rnd.randf_range(50.0, 130.0)
                draw_rect(Rect2(x, paye - bolandi, pahna, bolandi + 40), RANG_SHAHR)
                # گنبد یا مناره یا پشت‌بام ساده
                var no := rnd.randi_range(0, 2)
                if no == 0:
                        draw_set_transform(Vector2(x + pahna * 0.5, paye - bolandi), 0, Vector2(1, 0.62))
                        draw_circle(Vector2.ZERO, pahna * 0.30, RANG_SHAHR.lightened(0.05))
                        draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
                        draw_line(Vector2(x + pahna * 0.5, paye - bolandi - pahna * 0.20), Vector2(x + pahna * 0.5, paye - bolandi - pahna * 0.20 - 12.0), RANG_SHAHR.lightened(0.08), 2.0)
                elif no == 1:
                        draw_rect(Rect2(x + pahna - 4, paye - bolandi - 64, 7, 64), RANG_SHAHR.lightened(0.04))
                        draw_set_transform(Vector2(x + pahna, paye - bolandi - 64), 0, Vector2(1, 1))
                        draw_circle(Vector2.ZERO, 5.0, RANG_SHAHR.lightened(0.08))
                        draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
                # پنجره‌های روشن پراکنده
                var wx := x + 10.0
                while wx < x + pahna - 14.0:
                        if rnd.randf() < 0.4:
                                draw_rect(Rect2(wx, paye - rnd.randf_range(24.0, bolandi - 10.0), 6, 8), Color(1.0, 0.8, 0.45, 0.5))
                        wx += 18.0
                x += pahna + rnd.randf_range(24.0, 60.0)
                sh += 1

func sakhtaman(s: Dictionary, i: int, t: float) -> void:
        var rnd := RandomNumberGenerator.new()
        rnd.seed = 1000 + i * 13
        # بدنهٔ ساختمان
        draw_rect(Rect2(s.x0, s.y, s.x1 - s.x0, 320), RANG_SAKHTAMAN)
        # پنجره‌ها — بعضی روشن، بعضی خاموش
        var py: float = s.y + 36.0
        while py < s.y + 230.0:
                var px: float = s.x0 + 34.0
                while px < s.x1 - 40.0:
                        if rnd.randf() < 0.38:
                                draw_rect(Rect2(px - 4, py - 4, 34, 44), Color(1.0, 0.82, 0.5, 0.10))
                                draw_rect(Rect2(px, py, 26, 36), Color(1.0, 0.82, 0.5, 0.72))
                        else:
                                draw_rect(Rect2(px, py, 26, 36), Color(0.13, 0.11, 0.24))
                        px += 58.0
                py += 78.0
        # سطح پشت‌بام + لبهٔ روشن
        draw_rect(Rect2(s.x0 - 16, s.y - 14, s.x1 - s.x0 + 32, 14), RANG_PASHBAM)
        draw_rect(Rect2(s.x0 - 16, s.y - 14, s.x1 - s.x0 + 32, 3), RANG_LABE)
        # جان‌پناه
        var jx: float = s.x0 + 8.0
        while jx < s.x1 - 8.0:
                draw_rect(Rect2(jx, s.y - 22, 10, 9), RANG_PASHBAM)
                jx += 46.0
        # تزئینات ایرانیِ هر پشت‌بام
        match i:
                0:
                        ragh(s.x0 + 120, s.x1 - 90, s.y)
                        tank(s.x0 + 500, s.y)
                        gorbe(s.x1 - 180, s.y, t)
                1:
                        antenna(s.x0 + 110, s.y, t)
                        kolas(s.x0 + 300, s.y)
                        tank(s.x1 - 130, s.y)
                2:
                        badgir(s.x0 + 170, s.y)
                        dudkesh(s.x0 + 540, s.y, t)
                        gorbe(s.x1 - 130, s.y, t)
                3:
                        dish(s.x0 + 140, s.y)
                        ragh(s.x0 + 330, s.x0 + 560, s.y)
                        antenna(s.x1 - 110, s.y, t)
                4:
                        tank(s.x0 + 190, s.y)
                        kolas(s.x0 + 500, s.y)
                        dudkesh(s.x1 - 260, s.y, t)
                5:
                        badgir(s.x0 + 130, s.y)
                        dish(s.x0 + 400, s.y)
                        ragh(s.x0 + 620, s.x0 + 850, s.y)
                        gorbe(s.x1 - 160, s.y, t)

# ─── تزئینات پشت‌بام‌های تهران ───────────────────────────────

func tank(x: float, y: float) -> void:
        draw_rect(Rect2(x - 12, y - 14, 4, 14), RANG_ZIN)
        draw_rect(Rect2(x + 8, y - 14, 4, 14), RANG_ZIN)
        draw_rect(Rect2(x - 20, y - 46, 40, 34), RANG_ZIN_2.darkened(0.15))
        draw_set_transform(Vector2(x, y - 46), 0, Vector2(1, 0.35))
        draw_circle(Vector2.ZERO, 20.0, RANG_ZIN_2)
        draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
        draw_rect(Rect2(x - 27, y - 20, 8, 4), RANG_ZIN_2)

func kolas(x: float, y: float) -> void:
        draw_rect(Rect2(x - 16, y - 26, 32, 26), RANG_ZIN.darkened(0.1))
        draw_line(Vector2(x - 11, y - 21), Vector2(x + 11, y - 21), RANG_LABE, 1.5)
        draw_line(Vector2(x - 11, y - 15), Vector2(x + 11, y - 15), RANG_LABE, 1.5)
        draw_circle(Vector2(x + 6, y - 8), 4.5, Color(0.16, 0.18, 0.22))

func dish(x: float, y: float) -> void:
        draw_line(Vector2(x, y), Vector2(x, y - 26), RANG_ZIN_2, 3.0)
        draw_arc(Vector2(x, y - 34), 15.0, PI * 0.12, PI * 0.95, 12, Color(0.62, 0.64, 0.74), 5.0, false)
        draw_line(Vector2(x, y - 34), Vector2(x + 7, y - 46), Color(0.62, 0.64, 0.74), 2.0)

func ragh(xa: float, xb: float, y: float) -> void:
        draw_rect(Rect2(xa - 2, y - 72, 4, 72), RANG_ZIN)
        draw_rect(Rect2(xb - 2, y - 72, 4, 72), RANG_ZIN)
        draw_line(Vector2(xa, y - 70), Vector2(xb, y - 70), Color(0.75, 0.72, 0.68, 0.8), 2.0)
        # فرش آویزان
        var mx := (xa + xb) * 0.5 - 16.0
        draw_rect(Rect2(mx, y - 68, 32, 42), Color(0.18, 0.45, 0.45))
        draw_rect(Rect2(mx + 3, y - 62, 26, 4), Color(0.79, 0.44, 0.44))
        draw_rect(Rect2(mx + 3, y - 48, 26, 4), Color(0.79, 0.44, 0.44))
        draw_rect(Rect2(mx + 3, y - 34, 26, 3), Color(0.85, 0.72, 0.45, 0.8))
        # دو تی‌شرت آویزان
        draw_rect(Rect2(xa + 26, y - 68, 16, 20), Color(0.85, 0.83, 0.78, 0.95))
        draw_rect(Rect2(xa + 24, y - 68, 4, 9), Color(0.85, 0.83, 0.78, 0.95))
        draw_rect(Rect2(xa + 40, y - 68, 4, 9), Color(0.85, 0.83, 0.78, 0.95))
        draw_rect(Rect2(xb - 44, y - 68, 15, 18), Color(0.60, 0.72, 0.85, 0.95))
        draw_rect(Rect2(xb - 46, y - 68, 4, 8), Color(0.60, 0.72, 0.85, 0.95))
        draw_rect(Rect2(xb - 31, y - 68, 4, 8), Color(0.60, 0.72, 0.85, 0.95))

func badgir(x: float, y: float) -> void:
        draw_rect(Rect2(x - 17, y - 80, 34, 80), RANG_ZIN_2)
        for k in 4:
                draw_line(Vector2(x - 11 + k * 7.3, y - 74), Vector2(x - 11 + k * 7.3, y - 12), RANG_SAKHTAMAN, 2.5)
        draw_rect(Rect2(x - 22, y - 86, 44, 8), RANG_ZIN_2.lightened(0.07))
        draw_rect(Rect2(x - 20, y - 74, 40, 3), RANG_LABE.darkened(0.3))

func antenna(x: float, y: float, t: float) -> void:
        draw_line(Vector2(x, y), Vector2(x, y - 64), Color(0.55, 0.55, 0.62), 3.0)
        draw_line(Vector2(x - 14, y - 58), Vector2(x + 14, y - 58), Color(0.55, 0.55, 0.62), 2.0)
        draw_line(Vector2(x - 10, y - 47), Vector2(x + 10, y - 47), Color(0.55, 0.55, 0.62), 2.0)
        draw_line(Vector2(x - 7, y - 36), Vector2(x + 7, y - 36), Color(0.55, 0.55, 0.62), 2.0)
        draw_circle(Vector2(x, y - 66), 3.0, Color(1.0, 0.30, 0.30, 0.4 + 0.6 * absf(sin(t * 3.0))))

func dudkesh(x: float, y: float, t: float) -> void:
        draw_rect(Rect2(x - 9, y - 32, 18, 32), RANG_ZIN.darkened(0.25))
        var of := fposmod(t * 12.0, 12.0)
        for k in 3:
                draw_circle(Vector2(x + 2 + sin(t * 1.3 + k * 2.0) * 5.0, y - 40 - k * 15.0 - of), 6.0 + k * 2.0, Color(0.8, 0.78, 0.8, 0.20 - k * 0.05))

func gorbe(x: float, y: float, t: float) -> void:
        var rang := Color(0.082, 0.071, 0.14)
        draw_set_transform(Vector2(x, y - 9), 0, Vector2(1.3, 0.9))
        draw_circle(Vector2.ZERO, 8.0, rang)
        draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
        draw_circle(Vector2(x + 8, y - 17), 5.5, rang)
        draw_colored_polygon(PackedVector2Array([Vector2(x + 4, y - 21), Vector2(x + 6, y - 27), Vector2(x + 9, y - 21)]), rang)
        draw_colored_polygon(PackedVector2Array([Vector2(x + 9, y - 21), Vector2(x + 12, y - 26), Vector2(x + 13, y - 20)]), rang)
        draw_polyline(PackedVector2Array([Vector2(x - 9, y - 7), Vector2(x - 15, y - 10), Vector2(x - 17, y - 16 + sin(t * 2.0) * 3.0)]), rang, 3.0, true)
        draw_circle(Vector2(x + 9.5, y - 18), 1.0, Color(1.0, 0.82, 0.42, 0.9))
        draw_circle(Vector2(x + 6.5, y - 18), 1.0, Color(1.0, 0.82, 0.42, 0.9))

# ─── کلاس‌های داخلی ──────────────────────────────────────────

class Aseman extends Node2D:
        # آسمان ثابت روی صفحه: گرادیان غروب، ستاره، خورشید، ابر
        var reeshe
        func _ready() -> void:
                reeshe = get_parent().get_parent()
                queue_redraw()
        func _process(_delta: float) -> void:
                queue_redraw()
        func _draw() -> void:
                var v := get_viewport_rect().size
                var t := Time.get_ticks_msec() / 1000.0
                draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(v.x, 0), Vector2(v.x, v.y * 0.5), Vector2(0, v.y * 0.5)]), PackedColorArray([reeshe.RANG_ASEMAN_BALA, reeshe.RANG_ASEMAN_BALA, reeshe.RANG_ASEMAN_MIANE, reeshe.RANG_ASEMAN_MIANE]))
                draw_polygon(PackedVector2Array([Vector2(0, v.y * 0.5), Vector2(v.x, v.y * 0.5), Vector2(v.x, v.y), Vector2(0, v.y)]), PackedColorArray([reeshe.RANG_ASEMAN_MIANE, reeshe.RANG_ASEMAN_MIANE, reeshe.RANG_ASEMAN_AFKHOR, reeshe.RANG_ASEMAN_AFKHOR]))
                # ستاره‌های چشمک‌زن در نیمهٔ بالا
                var rs := RandomNumberGenerator.new()
                rs.seed = 4242
                for i in 46:
                        var sx := rs.randf_range(0, v.x)
                        var sy := rs.randf_range(0, v.y * 0.42)
                        var al := 0.22 + 0.45 * (0.5 + 0.5 * sin(t * 1.8 + i * 1.31))
                        draw_circle(Vector2(sx, sy), rs.randf_range(1.0, 2.4), Color(1, 1, 1, al))
                # خورشیدِ نزدیک افق با هاله
                draw_circle(Vector2(258, 468), 88, Color(1.0, 0.72, 0.42, 0.10))
                draw_circle(Vector2(258, 468), 62, Color(1.0, 0.78, 0.46, 0.16))
                draw_circle(Vector2(258, 468), 46, Color(1.0, 0.85, 0.58, 0.95))
                # ابرهای نرمِ رونده
                for c in 4:
                        var cx := fposmod(180.0 + c * 380.0 + t * 9.0, v.x + 420.0) - 210.0
                        var cy := 130.0 + (c % 2) * 90.0 + c * 18.0
                        draw_set_transform(Vector2(cx, cy), 0, Vector2(2.6, 0.9))
                        draw_circle(Vector2.ZERO, 42, Color(0.98, 0.78, 0.70, 0.10))
                        draw_circle(Vector2(30, -8), 30, Color(0.98, 0.78, 0.70, 0.09))
                        draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

class Viniet extends Node2D:
        # تیرهٔ نرمِ بالا و پایین کادر
        func _ready() -> void:
                queue_redraw()
        func _draw() -> void:
                var v := get_viewport_rect().size
                var omgh := 0.30
                draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(v.x, 0), Vector2(v.x, 84), Vector2(0, 84)]), PackedColorArray([Color(0, 0, 0, 0), Color(0, 0, 0, 0), Color(0, 0, 0, omgh), Color(0, 0, 0, omgh)]))
                draw_polygon(PackedVector2Array([Vector2(0, v.y - 110), Vector2(v.x, v.y - 110), Vector2(v.x, v.y), Vector2(0, v.y)]), PackedColorArray([Color(0, 0, 0, 0), Color(0, 0, 0, 0), Color(0, 0, 0, omgh * 1.15), Color(0, 0, 0, omgh * 1.15)]))

class Ske extends Area2D:
        # سکهٔ طلایی — بالا و پایین می‌پرد، ستاره‌اش می‌چرخد
        var ofset := 0.0
        func _init(of := 0.0) -> void:
                ofset = of
        func _ready() -> void:
                var shekl := CollisionShape2D.new()
                var dayere := CircleShape2D.new()
                dayere.radius = 26.0
                shekl.shape = dayere
                add_child(shekl)
                body_entered.connect(_lams)
        func _process(_delta: float) -> void:
                queue_redraw()
        func _draw() -> void:
                var t := Time.get_ticks_msec() / 1000.0 + ofset
                var bob := sin(t * 3.2) * 4.0
                draw_set_transform(Vector2(0, bob), 0, Vector2.ONE)
                draw_circle(Vector2.ZERO, 21, Color(1.0, 0.85, 0.45, 0.13))
                draw_circle(Vector2.ZERO, 14, Color(0.98, 0.76, 0.30))
                draw_circle(Vector2.ZERO, 10.5, Color(1.0, 0.90, 0.55))
                var za := t * 2.4
                for i in 4:
                        draw_line(Vector2.ZERO, Vector2.from_angle(za + i * PI / 2.0) * 6.0, Color(0.92, 0.66, 0.20, 0.65), 1.6)
        func _lams(bedane: Node) -> void:
                if bedane.name == "helia":
                        var reeshe = get_parent()
                        reeshe.ske_gereft(self)
                        queue_free()
