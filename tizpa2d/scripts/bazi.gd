# ═══════════════════════════════════════════════════════════════
#  تیزپا ۲بعدی — رانر خیابان ولیعصر
#  پرش دوگانه، نیترو با سوخت سکه، کمبو، اسلوموشن هنگام تصادف،
#  لرزش دوربین، سکه‌های چرخان، شیب پرش با چرخش کامل هوا —
#  چهار لایه‌ی پارالاکس دستی روی هنرِ AI؛ کد دست‌نویس، بدون عکس برای جاده
# ═══════════════════════════════════════════════════════════════
extends Node2D

const MASIR_AKS := "/home/z/my-project/download/screenshots_2d"
const Y_ZAMIN := 640.0
const GHA := 2000.0
const TOL_LAYER := 1344.0
const PIKSEL_METR := 14.0

var fnt: FontFile = null
var fnt_tiz: FontFile = null
var argha: Array = []
var aks_mode := false
var t_test := 0.0
var aks_gerefte := {}

# ─── حالت جهان ───
var sekant := 0.0
var zaman := 0.0
var sorat := 430.0
var mane_ha: Array = []
var sekke_ha: Array = []
var entezar_mane := 1.2
var mantaghe_badi := 250.0

# ─── حالت ماشین ───
var y_mashin := Y_ZAMIN
var sorat_amudi := 0.0
var der_hava := 0
var squash := 1.0
var zaviye := 0.0
var parvaz := false
var nitro_mande := 0.0
var nitro_pur := 0.0

# ─── امتیاز ───
var emtiaz_bon := 0
var sekke := 0
var kombo := 0
var zamane_kombo := 0.0
var jan := 3
var invul := 0.0
var behtarin := 0
var motevafegh := false

# ─── افکت‌ها ───
var larze := 0.0
var flash := 0.0
var pop_ha: Array = []

# ─── گره‌ها ───
var layer_ha: Array = []
var mashin: Sprite2D
var dud: CPUParticles2D
var atash: CPUParticles2D
var hud: CanvasLayer
var matne_emtiaz: Label
var matne_metr: Label
var matne_sekke: Label
var matne_sorat: Label
var matne_kombo: Label
var banner: Label
var banner_sen := -1.0
var panjare: Control
var matne_amarnegar: Label

func _fnt_amn(masir: String) -> FontFile:
        if ResourceLoader.exists(masir):
                return load(masir)
        return null

func _texture_amn(masir: String) -> Texture2D:
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
        var fa := FileAccess.open("user://tizpa2d_best.txt", FileAccess.READ)
        if fa != null:
                behtarin = int(fa.get_as_text().strip_edges())
        _layer_ha_besaz()
        var jad := Node2D.new()
        jad.set_script(load("res://scripts/jadde.gd"))
        add_child(jad)
        var jahan := Node2D.new()
        jahan.set_script(load("res://scripts/jahan.gd"))
        add_child(jahan)
        _mashin_besaz()
        _hud_besaz()
        _panjare_besaz()

# چهار لایه‌ی پارالاکس — مقیاس‌بندی شده تا میله و آسمان نفس بکشند
# هر لایه چند نسخه دارد تا عرض صفحه پوشیده شود
func _layer_ha_besaz() -> void:
        var tarif_ha := [
                ["res://assets/art/aseman.png", 0.0, 720.0, 1.0],
                ["res://assets/art/khat_shahr.png", 0.12, 528.0, 0.50],
                ["res://assets/art/sakhtemanha.png", 0.32, 560.0, 0.42],
                ["res://assets/art/derakht.png", 0.55, 560.0, 0.26]
        ]
        for t in tarif_ha:
                var tex := _texture_amn(t[0])
                var maghsas := float(t[3])
                var tool_l := TOL_LAYER * maghsas
                var y_bala := float(t[2]) - 768.0 * maghsas
                var sp_ha := []
                var tedad := int(ceil(1280.0 / tool_l)) + 1
                for i in tedad:
                        var sp := Sprite2D.new()
                        sp.texture = tex
                        sp.centered = false
                        sp.scale = Vector2(maghsas, maghsas)
                        sp.position = Vector2(float(i) * tool_l, y_bala)
                        add_child(sp)
                        sp_ha.append(sp)
                layer_ha.append({"sp_ha": sp_ha, "faktor": float(t[1]), "tol": tool_l})

func _mashin_besaz() -> void:
        mashin = Sprite2D.new()
        mashin.texture = _texture_amn("res://assets/sprites/car_boghi_yellow.webp")
        mashin.scale = Vector2(0.52, 0.52)
        mashin.position = Vector2(320, Y_ZAMIN)
        add_child(mashin)
        dud = CPUParticles2D.new()
        dud.position = Vector2(-100, 46)
        dud.amount = 12
        dud.lifetime = 0.8
        dud.direction = Vector2(-1, 0.15)
        dud.spread = 20.0
        dud.gravity = Vector2(0, -30)
        dud.initial_velocity_min = 40.0
        dud.initial_velocity_max = 90.0
        dud.scale_amount_min = 2.5
        dud.scale_amount_max = 5.5
        dud.color = Color(0.62, 0.62, 0.65, 0.28)
        mashin.add_child(dud)
        atash = CPUParticles2D.new()
        atash.position = Vector2(-112, 38)
        atash.amount = 26
        atash.lifetime = 0.22
        atash.direction = Vector2(-1, 0)
        atash.spread = 14.0
        atash.gravity = Vector2(0, 0)
        atash.initial_velocity_min = 320.0
        atash.initial_velocity_max = 560.0
        atash.scale_amount_min = 4.0
        atash.scale_amount_max = 9.0
        atash.color = Color("ff7b3a")
        atash.emitting = false
        mashin.add_child(atash)

func _matn_besaz(matn: String, fon: FontFile, andaze: int, rang: Color, ja: Vector2, kaf := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
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
        l.mouse_filter = Control.MOUSE_FILTER_IGNORE
        return l

func _hud_besaz() -> void:
        hud = CanvasLayer.new()
        add_child(hud)
        var keshande := Node2D.new()
        keshande.set_script(load("res://scripts/hud.gd"))
        hud.add_child(keshande)
        matne_emtiaz = _matn_besaz("امتیاز ۰", fnt_tiz, 48, Color("ffd94a"), Vector2(340, 16), HORIZONTAL_ALIGNMENT_CENTER)
        matne_emtiaz.size = Vector2(600, 60)
        hud.add_child(matne_emtiaz)
        matne_metr = _matn_besaz("۰ متر", fnt, 24, Color("cfe0ff"), Vector2(340, 76), HORIZONTAL_ALIGNMENT_CENTER)
        matne_metr.size = Vector2(600, 32)
        hud.add_child(matne_metr)
        matne_sorat = _matn_besaz("سرعت ۱۱۰", fnt, 28, Color("00e5ff"), Vector2(920, 22))
        hud.add_child(matne_sorat)
        matne_sekke = _matn_besaz("۰", fnt, 28, Color("ffd94a"), Vector2(62, 80))
        hud.add_child(matne_sekke)
        matne_kombo = _matn_besaz("", fnt_tiz, 42, Color("ffd94a"), Vector2(440, 140), HORIZONTAL_ALIGNMENT_CENTER)
        matne_kombo.size = Vector2(400, 52)
        hud.add_child(matne_kombo)
        banner = _matn_besaz("", fnt_tiz, 34, Color("a5d6a7"), Vector2(340, 130), HORIZONTAL_ALIGNMENT_CENTER)
        banner.size = Vector2(600, 46)
        banner.visible = false
        hud.add_child(banner)
        # دکمه‌های لمسی — مثل خود تیزپا، بزرگ و شفاف
        var dokme_pary := _dokme_besaz("پرش", Vector2(44, 584), Vector2(200, 92), Color(0, 0.9, 1, 0.35))
        dokme_pary.pressed.connect(_pary)
        var dokme_nitro := _dokme_besaz("نیترو", Vector2(1036, 584), Vector2(200, 92), Color(1, 0.55, 0.2, 0.35))
        dokme_nitro.pressed.connect(_nitro)

func _dokme_besaz(matn: String, ja: Vector2, andaze: Vector2, rang: Color) -> Button:
        var b := Button.new()
        b.text = matn
        b.position = ja
        b.size = andaze
        b.add_theme_font_override("font", fnt_tiz)
        b.add_theme_font_size_override("font_size", 34)
        b.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
        var sb := StyleBoxFlat.new()
        sb.bg_color = rang
        sb.set_corner_radius_all(26)
        sb.set_border_width_all(3)
        sb.border_color = Color(1, 1, 1, 0.5)
        b.add_theme_stylebox_override("normal", sb)
        var sbh := sb.duplicate()
        sbh.bg_color = Color(rang.r, rang.g, rang.b, rang.a + 0.15)
        b.add_theme_stylebox_override("hover", sbh)
        b.add_theme_stylebox_override("pressed", sbh)
        hud.add_child(b)
        return b

func _panjare_besaz() -> void:
        panjare = Control.new()
        panjare.set_anchors_preset(Control.PRESET_FULL_RECT)
        panjare.visible = false
        hud.add_child(panjare)
        var siyah := ColorRect.new()
        siyah.color = Color(0, 0, 0, 0.62)
        siyah.set_anchors_preset(Control.PRESET_FULL_RECT)
        panjare.add_child(siyah)
        var vas := VBoxContainer.new()
        vas.alignment = BoxContainer.ALIGNMENT_CENTER
        vas.add_theme_constant_override("separation", 20)
        vas.set_anchors_preset(Control.PRESET_FULL_RECT)
        panjare.add_child(vas)
        var payan := _matn_besaz("تمام شد!", fnt_tiz, 72, Color("ff5470"), Vector2.ZERO, HORIZONTAL_ALIGNMENT_CENTER)
        payan.size = Vector2(1280, 90)
        vas.add_child(payan)
        matne_amarnegar = _matn_besaz("", fnt, 28, Color.WHITE, Vector2.ZERO, HORIZONTAL_ALIGNMENT_CENTER)
        matne_amarnegar.size = Vector2(1280, 44)
        vas.add_child(matne_amarnegar)
        var radif := HBoxContainer.new()
        radif.alignment = BoxContainer.ALIGNMENT_CENTER
        radif.add_theme_constant_override("separation", 26)
        vas.add_child(radif)
        var dobare := Button.new()
        dobare.text = "دوباره"
        dobare.custom_minimum_size = Vector2(220, 70)
        dobare.add_theme_font_override("font", fnt_tiz)
        dobare.add_theme_font_size_override("font_size", 32)
        dobare.add_theme_color_override("font_color", Color("1b2340"))
        var sb := StyleBoxFlat.new()
        sb.bg_color = Color("ffd94a")
        sb.set_corner_radius_all(18)
        dobare.add_theme_stylebox_override("normal", sb)
        dobare.add_theme_stylebox_override("hover", sb.duplicate())
        dobare.pressed.connect(_shorou_mojaddad)
        radif.add_child(dobare)
        var menu := Button.new()
        menu.text = "منو"
        menu.custom_minimum_size = Vector2(220, 70)
        menu.add_theme_font_override("font", fnt_tiz)
        menu.add_theme_font_size_override("font_size", 32)
        menu.add_theme_color_override("font_color", Color.WHITE)
        var sb2 := StyleBoxFlat.new()
        sb2.bg_color = Color("31406b")
        sb2.set_corner_radius_all(18)
        menu.add_theme_stylebox_override("normal", sb2)
        menu.add_theme_stylebox_override("hover", sb2.duplicate())
        menu.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/menu.tscn"))
        radif.add_child(menu)

# ═══════════ ورودی ═══════════
func _unhandled_input(roydad: InputEvent) -> void:
        if motevafegh:
                return
        if roydad is InputEventMouseButton and roydad.pressed:
                _pary()
        elif roydad is InputEventKey and roydad.pressed and not roydad.echo:
                if roydad.keycode == KEY_SPACE:
                        _pary()
                elif roydad.keycode == KEY_N:
                        _nitro()

func _pary() -> void:
        if motevafegh:
                return
        if y_mashin >= Y_ZAMIN - 2.0:
                sorat_amudi = -860.0
                der_hava = 1
        elif der_hava == 1:
                sorat_amudi = -740.0
                der_hava = 0
                squash = 1.06
                _ghobar()

func _nitro() -> void:
        if motevafegh:
                return
        if nitro_pur >= 1.0 and nitro_mande <= 0.0:
                nitro_pur = 0.0
                nitro_mande = 2.6
                atash.emitting = true
                _pop("نیترو!", Color("ff7b3a"), Vector2(320, y_mashin - 90))

func metr() -> float:
        return sekant / PIKSEL_METR

# ═══════════ حلقه‌ی اصلی ═══════════
func _process(dt: float) -> void:
        zaman += dt
        if not motevafegh:
                var paye := clampf(430.0 + metr() * 0.5, 430.0, 720.0)
                sorat = paye * (1.55 if nitro_mande > 0.0 else 1.0)
                sekant += sorat * dt
                # فیزیک پرش و فرود
                if y_mashin < Y_ZAMIN - 0.5 or sorat_amudi < 0.0:
                        sorat_amudi += GHA * dt
                        y_mashin += sorat_amudi * dt
                        if y_mashin >= Y_ZAMIN:
                                y_mashin = Y_ZAMIN
                                sorat_amudi = 0
                                der_hava = 0
                                squash = 0.72
                                parvaz = false
                                _ghobar()
                squash = lerpf(squash, 1.0, minf(dt * 7.0, 1.0))
                if nitro_mande > 0.0:
                        nitro_mande -= dt
                        if nitro_mande <= 0.0:
                                atash.emitting = false
                if zamane_kombo > 0.0:
                        zamane_kombo -= dt
                else:
                        kombo = 0
                if invul > 0.0:
                        invul -= dt
                if aks_mode:
                        _otopilot()
                _tolid_mane(dt)
                _pak_kardan()
                _barkhord()
                _milestone(dt)
        # ── بصری‌ها ──
        for l in layer_ha:
                var paye := fposmod(sekant * float(l["faktor"]), float(l["tol"]))
                for i in l["sp_ha"].size():
                        l["sp_ha"][i].position.x = float(i) * float(l["tol"]) - paye
        var dar_hava := y_mashin < Y_ZAMIN - 2.0
        var bob := 0.0 if dar_hava else sin(zaman * 16.0) * 2.4
        mashin.position.y = y_mashin + bob
        mashin.scale = Vector2(0.52 / sqrt(squash), 0.52 * squash)
        if parvaz and dar_hava:
                zaviye += 9.0 * dt
        else:
                var khast := 0.0 if not dar_hava else clampf(sorat_amudi * 0.00035, -0.2, 0.3)
                zaviye = lerpf(zaviye, khast, minf(dt * 10.0, 1.0))
        mashin.rotation = zaviye
        mashin.modulate.a = 1.0 if invul <= 0.0 else 0.45 + 0.35 * sin(zaman * 30.0)
        if larze > 0.0:
                larze = maxf(larze - dt * 2.0, 0.0)
                position = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * 11.0 * larze
        else:
                position = Vector2.ZERO
        if flash > 0.0:
                flash = maxf(flash - dt * 1.8, 0.0)
        _pop_tike(dt)
        # ── HUD ──
        var emtiaz := int(sekant / PIKSEL_METR) + emtiaz_bon
        matne_emtiaz.text = "امتیاز " + _fa(emtiaz)
        matne_metr.text = _fa(int(metr())) + " متر"
        matne_sekke.text = _fa(sekke)
        matne_sorat.text = "سرعت " + _fa(int(sorat / PIKSEL_METR * 3.6)) + " کیلومتر"
        matne_kombo.text = "کمبو ×" + _fa(kombo) if kombo >= 2 else ""
        if aks_mode:
                _azm_tike(dt)

# ═══════════ تولید و حرکت موانع ═══════════
func _tolid_mane(dt: float) -> void:
        entezar_mane -= dt
        if entezar_mane <= 0.0:
                entezar_mane = clampf(1.35 - sorat * 0.0009, 0.62, 1.35)
                _mane_ejad()
                if randf() < 0.55:
                        _sekk_ha_ejad()

func _mane_ejad() -> void:
        var wx := sekant + 1360.0
        var gozine := "cone"
        if metr() < 150.0:
                var vazin := [["cone", 0.34], ["chaleh", 0.27], ["gahi", 0.22], ["shib", 0.17]]
                gozine = _gozine_vazin(vazin)
        else:
                gozine = _gozine_vazin([["cone", 0.26], ["chaleh", 0.20], ["gahi", 0.17], ["shib", 0.10], ["parked", 0.27]])
        if gozine == "parked":
                var sp := Sprite2D.new()
                sp.texture = _texture_amn("res://assets/sprites/car_pejo.webp" if randf() < 0.5 else "res://assets/sprites/car_samand.webp")
                sp.scale = Vector2(0.5, 0.5)
                sp.position = Vector2(1360.0, 640.0)
                add_child(sp)
                mane_ha.append({"noe": "parked", "wx": wx, "sp": sp})
        else:
                mane_ha.append({"noe": gozine, "wx": wx})

func _gozine_vazin(vazin: Array) -> String:
        var gh := randf()
        var jam := 0.0
        for v in vazin:
                jam += float(v[1])
                if gh <= jam:
                        return String(v[0])
        return String(vazin[0][0])

func _sekk_ha_ejad() -> void:
        var wx0 := sekant + 1500.0
        if randf() < 0.45:
                for i in 5:
                        sekke_ha.append({"wx": wx0 + float(i) * 62.0, "y": 560.0 - sin(float(i) / 4.0 * PI) * 150.0, "gerefte": false})
        else:
                for i in 4:
                        sekke_ha.append({"wx": wx0 + float(i) * 66.0, "y": 600.0, "gerefte": false})

func _pak_kardan() -> void:
        var mande := []
        for m in mane_ha:
                if float(m["wx"]) > sekant - 280.0:
                        mande.append(m)
                elif m.has("sp") and is_instance_valid(m["sp"]):
                        m["sp"].queue_free()
        mane_ha = mande
        for m in mane_ha:
                if m.has("sp") and is_instance_valid(m["sp"]):
                        m["sp"].position.x = float(m["wx"]) - sekant
        var mande_sekk := []
        for s in sekke_ha:
                if float(s["wx"]) > sekant - 90.0:
                        mande_sekk.append(s)
        sekke_ha = mande_sekk

# ═══════════ برخوردها ═══════════
func _barkhord() -> void:
        var carx := sekant + 320.0
        for m in mane_ha.duplicate():
                var x := float(m["wx"]) - carx
                var noe := String(m["noe"])
                if noe == "shib":
                        if absf(x) < 95.0 and y_mashin >= Y_ZAMIN - 24.0 and not bool(m.get("parvaz", false)):
                                m["parvaz"] = true
                                sorat_amudi = -1050.0
                                der_hava = 1
                                parvaz = true
                                _pop("پرواز!", Color("00e5ff"), Vector2(320, y_mashin - 90))
                        continue
                var marz_x := 95.0 if noe == "parked" else 46.0
                var marz_y := 118.0 if noe == "parked" else (52.0 if noe == "cone" else (26.0 if noe == "chaleh" else 30.0))
                if absf(x) < marz_x and y_mashin > Y_ZAMIN - marz_y and invul <= 0.0:
                        _tasadom(m)
                        break
        for s in sekke_ha.duplicate():
                if bool(s["gerefte"]):
                        continue
                var dx := float(s["wx"]) - carx
                var dy := float(s["y"]) - (y_mashin - 30.0)
                if dx * dx + dy * dy < 62.0 * 62.0:
                        s["gerefte"] = true
                        sekke += 1
                        kombo += 1
                        zamane_kombo = 1.3
                        nitro_pur = minf(nitro_pur + 0.09, 1.0)
                        emtiaz_bon += 10 * kombo
                        _pop("+" + _fa(10 * kombo), Color("ffd94a"), Vector2(320, y_mashin - 80))
                        _jaraghe(Vector2(320, y_mashin - 30))

func _tasadom(m: Dictionary) -> void:
        print("[tizpa2d] HIT noe=", String(m["noe"]), " y=", snappedf(y_mashin, 1.0), " sorat=", int(sorat))
        jan -= 1
        kombo = 0
        invul = 1.5
        larze = 1.3
        flash = 0.7
        _tike_enzar(Vector2(320, y_mashin - 20))
        if m.has("sp") and is_instance_valid(m["sp"]):
                m["sp"].queue_free()
                mane_ha.erase(m)
        Engine.time_scale = 0.35
        get_tree().create_timer(0.5, true, false, true).timeout.connect(func():
                Engine.time_scale = 1.0
                if jan <= 0:
                        _payan())

# ═══════════ پایان و شروع دوباره ═══════════
func _payan() -> void:
        motevafegh = true
        var emtiaz := int(sekant / PIKSEL_METR) + emtiaz_bon
        var r_jadid := emtiaz > behtarin
        if r_jadid:
                behtarin = emtiaz
                var fa := FileAccess.open("user://tizpa2d_best.txt", FileAccess.WRITE)
                if fa != null:
                        fa.store_string(str(behtarin))
        matne_amarnegar.text = ("رکورد جدید! — " if r_jadid else "") + "امتیاز " + _fa(emtiaz) + " — " + _fa(int(metr())) + " متر — سکه " + _fa(sekke) + " — بهترین " + _fa(behtarin)
        panjare.visible = true
        dud.emitting = false
        atash.emitting = false

func _shorou_mojaddad() -> void:
        sekant = 0.0
        zaman = 0.0
        emtiaz_bon = 0
        sekke = 0
        kombo = 0
        jan = 3
        invul = 0.0
        nitro_pur = 0.0
        nitro_mande = 0.0
        y_mashin = Y_ZAMIN
        sorat_amudi = 0.0
        der_hava = 0
        parvaz = false
        motevafegh = false
        mantaghe_badi = 250.0
        Engine.time_scale = 1.0
        for m in mane_ha:
                if m.has("sp") and is_instance_valid(m["sp"]):
                        m["sp"].queue_free()
        mane_ha.clear()
        sekke_ha.clear()
        panjare.visible = false
        dud.emitting = true

# ═══════════ مال‌استون و پاپ‌آپ‌ها ═══════════
func _milestone(dt: float) -> void:
        if metr() >= mantaghe_badi:
                banner.text = _fa(int(mantaghe_badi)) + " متر! تندتر…"
                banner.visible = true
                banner_sen = 0.0
                mantaghe_badi += 250.0
        if banner_sen >= 0.0:
                banner_sen += dt
                banner.modulate.a = 1.0 if banner_sen < 1.0 else maxf(1.0 - (banner_sen - 1.0) / 0.4, 0.0)
                if banner_sen > 1.4:
                        banner.visible = false
                        banner_sen = -1.0

func _pop(matn: String, rang: Color, ja: Vector2) -> void:
        var l := Label.new()
        l.text = matn
        l.add_theme_font_override("font", fnt_tiz)
        l.add_theme_font_size_override("font_size", 30)
        l.add_theme_color_override("font_color", rang)
        l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
        l.position = ja - Vector2(40, 0)
        l.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(l)
        pop_ha.append({"l": l, "sen": 0.0})

func _pop_tike(dt: float) -> void:
        var mande := []
        for p in pop_ha:
                p["sen"] += dt
                p["l"].position.y -= 54.0 * dt
                p["l"].modulate.a = maxf(1.0 - p["sen"] / 0.8, 0.0)
                if p["sen"] < 0.8:
                        mande.append(p)
                else:
                        p["l"].queue_free()
        pop_ha = mande

# ═══════════ ذرات ═══════════
func _zarre(ja: Vector2, rang: Color, tedad: int, az: float, ta: float) -> void:
        var p := CPUParticles2D.new()
        p.position = ja
        p.amount = tedad
        p.one_shot = true
        p.explosiveness = 1.0
        p.lifetime = 0.6
        p.direction = Vector2(0, -1)
        p.spread = 180.0
        p.gravity = Vector2(0, 340)
        p.initial_velocity_min = az
        p.initial_velocity_max = ta
        p.scale_amount_min = 2.0
        p.scale_amount_max = 4.5
        p.color = rang
        add_child(p)
        p.emitting = true
        get_tree().create_timer(0.9).timeout.connect(func(): p.queue_free())

func _ghobar() -> void:
        _zarre(Vector2(320, 700), Color(0.7, 0.68, 0.6, 0.5), 14, 60.0, 180.0)

func _jaraghe(ja: Vector2) -> void:
        _zarre(ja, Color("ffd94a"), 12, 80.0, 220.0)

func _tike_enzar(ja: Vector2) -> void:
        _zarre(ja, Color("ff5470"), 26, 120.0, 320.0)

# ═══════════ اتوپایلوت و عکس‌ها ═══════════
func _otopilot() -> void:
        var carx := sekant + 320.0
        var nazdik_x := INF
        var nazdik_noe := ""
        for m in mane_ha:
                var dx0 := float(m["wx"]) - carx
                if dx0 > 30.0 and dx0 < nazdik_x:
                        nazdik_x = dx0
                        nazdik_noe = String(m["noe"])
        var dar_hava := y_mashin < Y_ZAMIN - 2.0
        # آستانه‌ی پرش بر اساس سرعت — تا فرود داخل مانع نیفتد
        if not dar_hava and nazdik_noe != "shib" and nazdik_noe != "":
                var hast_bala := 0.0
                match nazdik_noe:
                        "cone":
                                hast_bala = 46.0 + sorat * 0.16
                        "chaleh", "gahi":
                                hast_bala = 46.0 + sorat * 0.28
                        "parked":
                                hast_bala = 95.0 + sorat * 0.42
                if nazdik_x < hast_bala:
                        _pary()
        if dar_hava and der_hava == 1 and nazdik_noe == "parked" and nazdik_x < 210.0:
                _pary()
        if nitro_pur >= 1.0 and t_test > 4.4:
                _nitro()

func _azm_tike(dt: float) -> void:
        t_test += dt
        for m in [[2.6, "tizpa2d_1"], [5.9, "tizpa2d_2"]]:
                if t_test > float(m[0]) and not aks_gerefte.has(m[1]):
                        aks_gerefte[m[1]] = true
                        var aks := get_viewport().get_texture().get_image()
                        if aks != null:
                                aks.save_png(MASIR_AKS + "/" + String(m[1]) + ".png")
                                print("[tizpa2d] SHOT ", m[1])
        if t_test > 7.5:
                print("[tizpa2d] BAZI DONE emtiaz=", int(sekant / PIKSEL_METR) + emtiaz_bon, " sekke=", sekke, " jan=", jan)
                get_tree().quit()
