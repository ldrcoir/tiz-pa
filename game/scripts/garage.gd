extends Control

var fnt: FontFile
var fnt_tiz: FontFile
var fnt_onvan: FontFile

var matne_pool: Label
var akse_mashin: TextureRect
var matne_esme_mashin: Label
var virayeshe_pelak: LineEdit
var ostad: TextureRect
var helia: TextureRect
var jarqeha: CPUParticles2D
var dokme_tab_mashinha: Button
var dokme_tab_artagha: Button
var shabake_mashinha: GridContainer
var qute_artagha: VBoxContainer
var payam: Label

var dokmehaye_mashin: Array = []
var dokmehaye_artagha := {}      # uid -> Button
var noqtehaye_artagha := {}         # uid -> Label
var _dar_kar := false
var _zaman_demo: Timer
var maghz = null

# بارگذاری مستقیم مغز — بدون وابستگی به class cache
const PRE_MAGHZ := preload("res://scripts/car_brain.gd")

func _ready() -> void:
        # قفل LTR — ضدآینه‌شدن روی گوشی فارسی (درس v0.9)
        layout_direction = Control.LAYOUT_DIRECTION_LTR
        fnt = load("res://assets/fonts/Vazirmatn-Regular.ttf")
        fnt_tiz = load("res://assets/fonts/Vazirmatn-Bold.ttf")
        fnt_onvan = load("res://assets/fonts/Lalezar-Regular.ttf")
        _besaz()
        _taze_sazi()
        Seda.ahang_baz()
        # مغز تیز پا در کارگاه: ماشین‌ها و استاد فنر حرف می‌زنند
        maghz = PRE_MAGHZ.new()
        add_child(maghz)
        PRE_MAGHZ.add_breathing(akse_mashin, 3.0, 1.4)
        maghz.gap_e_aval(
                func(sh: String) -> Control:
                        return ostad if sh == "ustad" else (helia if sh == "helia" else akse_mashin),
                func() -> Array:
                        return [str(Koli.MASHINHA[Koli.mashin_entekhabi]["id"]), "ustad", "helia"], 9.0, 16.0)
        if OS.get_cmdline_user_args().has("--autotest"):
                if maghz != null:
                        maghz.begu(akse_mashin, str(Koli.MASHINHA[Koli.mashin_entekhabi]["id"]), "select")
                await get_tree().create_timer(1.35).timeout
                get_viewport().get_texture().get_image().save_png("/home/z/my-project/scripts/shot_garage.png")
                await get_tree().create_timer(0.75).timeout
                get_viewport().get_texture().get_image().save_png("/home/z/my-project/scripts/shot_garage2.png")
                get_tree().quit()

func _sb(paszamine: Color, border: Color, radius: int, bw: int = 0, saye := true) -> StyleBoxFlat:
        var sb := StyleBoxFlat.new()
        sb.bg_color = paszamine
        sb.set_corner_radius_all(radius)
        sb.border_color = border
        sb.border_width_left = bw
        sb.border_width_right = bw
        sb.border_width_top = bw
        sb.border_width_bottom = bw + (4 if bw > 0 else 0)
        if saye:
                sb.shadow_color = Color(0.1, 0.06, 0.04, 0.4)
                sb.shadow_size = 8
        return sb

func _dokme_shekl(b: Button, primary := true) -> void:
        var paye := Color(0.165, 0.616, 0.561) if primary else Color(0.965, 0.886, 0.737)
        var tir := Color(0.11, 0.42, 0.385) if primary else Color(0.8, 0.66, 0.42)
        b.add_theme_stylebox_override("normal", _sb(paye, tir, 14, 3))
        b.add_theme_stylebox_override("hover", _sb(paye.lightened(0.07), tir, 14, 3))
        b.add_theme_stylebox_override("pressed", _sb(tir, tir, 14, 3))
        var fg := Color(1, 1, 1) if primary else Color(0.29, 0.216, 0.157)
        b.add_theme_color_override("font_color", fg)
        b.add_theme_color_override("font_hover_color", fg)
        b.add_theme_color_override("font_focus_color", fg)
        b.add_theme_color_override("font_pressed_color", Color(1, 1, 1))

func _matn_besaz(matn: String, size: int, bold := false, display := false, rangi := Color(0.29, 0.216, 0.157)) -> Label:
        var l := Label.new()
        l.text = matn
        l.add_theme_font_override("font", fnt_onvan if display else (fnt_tiz if bold else fnt))
        l.add_theme_font_size_override("font_size", size)
        l.add_theme_color_override("font_color", rangi)
        return l

func _besaz() -> void:
        # پس‌زمینه کارگاه گرم و پرنور
        var paszamine := TextureRect.new()
        paszamine.texture = load("res://assets/sprites/garage_bg.webp")
        paszamine.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        paszamine.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
        paszamine.set_anchors_preset(Control.PRESET_FULL_RECT)
        add_child(paszamine)

        # دکمه برگشت (بالا-چپ) — زیر خط امن استاتوس‌بار
        var dokme_bargasht := Button.new()
        dokme_bargasht.text = Koli.tarjome("back")
        dokme_bargasht.add_theme_font_override("font", fnt_onvan)
        dokme_bargasht.add_theme_font_size_override("font_size", 26)
        dokme_bargasht.position = Vector2(14, 54)
        dokme_bargasht.size = Vector2(120, 54)
        _dokme_shekl(dokme_bargasht, false)
        dokme_bargasht.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/menu.tscn"))
        add_child(dokme_bargasht)

        # عنوان کارگاه
        var onvan := _matn_besaz(Koli.tarjome("workshop"), 46, false, true, Color(0.95, 0.75, 0.14))
        onvan.add_theme_color_override("font_outline_color", Color(0.22, 0.12, 0.05))
        onvan.add_theme_constant_override("outline_size", 12)
        onvan.position = Vector2(120, 54)
        onvan.custom_minimum_size = Vector2(780, 0)
        onvan.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        add_child(onvan)

        # سکه‌ها (بالا-چپ، کنار دکمه برگشت)
        # آیکون سکه + عدد — به‌جای ایموجی که در فونت گوشی نیست
        if ResourceLoader.exists("res://assets/sprites/coin.png"):
                var neshane_pool := TextureRect.new()
                neshane_pool.texture = load("res://assets/sprites/coin.png")
                neshane_pool.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
                neshane_pool.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
                neshane_pool.position = Vector2(148, 62)
                neshane_pool.size = Vector2(36, 36)
                neshane_pool.mouse_filter = Control.MOUSE_FILTER_IGNORE
                add_child(neshane_pool)
        matne_pool = _matn_besaz(str(Koli.pool), 30, true, false, Color(0.98, 0.85, 0.3))
        matne_pool.add_theme_color_override("font_outline_color", Color(0.22, 0.12, 0.05))
        matne_pool.add_theme_constant_override("outline_size", 8)
        matne_pool.position = Vector2(190, 68)
        add_child(matne_pool)

        # سایه و ویترین ماشین (وسط-چپ)
        var saye := Sprite2D.new()
        saye.texture = _sakhtane_takse_saye()
        saye.position = Vector2(360, 558)
        saye.scale = Vector2(2.4, 1.0)
        add_child(saye)
        akse_mashin = TextureRect.new()
        akse_mashin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        akse_mashin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        akse_mashin.position = Vector2(50, 285)
        akse_mashin.size = Vector2(620, 265)
        add_child(akse_mashin)
        matne_esme_mashin = _matn_besaz("", 30, false, true, Color(0.99, 0.93, 0.78))
        matne_esme_mashin.add_theme_color_override("font_outline_color", Color(0.22, 0.12, 0.05))
        matne_esme_mashin.add_theme_constant_override("outline_size", 10)
        matne_esme_mashin.position = Vector2(50, 566)
        matne_esme_mashin.custom_minimum_size = Vector2(620, 0)
        matne_esme_mashin.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        add_child(matne_esme_mashin)

        # اسم روی پلاک — زیر ویترین؛ هر اسمی که راننده دوست دارد
        var neshane_pelak := _matn_besaz(Koli.tarjome("plate_hint"), 20, true, false, Color(0.98, 0.9, 0.7))
        neshane_pelak.add_theme_color_override("font_outline_color", Color(0.22, 0.12, 0.05))
        neshane_pelak.add_theme_constant_override("outline_size", 8)
        neshane_pelak.position = Vector2(50, 628)
        neshane_pelak.custom_minimum_size = Vector2(620, 0)
        neshane_pelak.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        add_child(neshane_pelak)
        virayeshe_pelak = LineEdit.new()
        virayeshe_pelak.text = Koli.esme_pelak
        virayeshe_pelak.max_length = 12
        if fnt_tiz != null:
                virayeshe_pelak.add_theme_font_override("font", fnt_tiz)
        virayeshe_pelak.add_theme_font_size_override("font_size", 24)
        virayeshe_pelak.alignment = HORIZONTAL_ALIGNMENT_CENTER
        virayeshe_pelak.position = Vector2(230, 664)
        virayeshe_pelak.size = Vector2(260, 44)
        virayeshe_pelak.add_theme_stylebox_override("normal", _sb(Color(0.08, 0.09, 0.12, 0.92), Color(0.85, 0.68, 0.28, 0.6), 10, 2, false))
        virayeshe_pelak.add_theme_color_override("font_color", Color(0.99, 0.85, 0.30))
        virayeshe_pelak.add_theme_color_override("caret_color", Color(0.99, 0.85, 0.30))
        virayeshe_pelak.text_changed.connect(func(_t):
                Koli.esme_pelak = virayeshe_pelak.text.strip_edges()
                if Koli.esme_pelak.is_empty():
                        Koli.esme_pelak = "هلیا"
                Koli.zakhire_kon())
        add_child(virayeshe_pelak)

        # جرقه هنگام ارتقا
        jarqeha = CPUParticles2D.new()
        jarqeha.position = Vector2(360, 440)
        jarqeha.emitting = false
        jarqeha.one_shot = true
        jarqeha.explosiveness = 1.0
        jarqeha.amount = 90
        jarqeha.lifetime = 0.75
        jarqeha.spread = 180.0
        jarqeha.initial_velocity_min = 220.0
        jarqeha.initial_velocity_max = 520.0
        jarqeha.gravity = Vector2(0, 700)
        jarqeha.scale_amount_min = 3.0
        jarqeha.scale_amount_max = 6.0
        var sg := Gradient.new()
        sg.offsets = PackedFloat32Array([0.0, 0.4, 1.0])
        sg.colors = PackedColorArray([Color(1.0, 0.97, 0.6, 1.0), Color(1.0, 0.6, 0.1, 0.9), Color(0.9, 0.2, 0.02, 0.0)])
        jarqeha.color_ramp = sg
        var mate := CanvasItemMaterial.new()
        mate.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
        jarqeha.material = mate
        add_child(jarqeha)

        # استاد فنر — سیبیلو با انیمیشن نفس‌کشیدن کنار ماشین
        ostad = TextureRect.new()
        ostad.texture = load("res://assets/sprites/ustad.webp")
        ostad.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        ostad.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        ostad.position = Vector2(660, 350)
        ostad.size = Vector2(250, 330)
        ostad.pivot_offset = Vector2(125, 330)
        add_child(ostad)
        var esme_karbar := _matn_besaz("استاد فنر", 26, false, true, Color(0.98, 0.9, 0.7))
        esme_karbar.add_theme_color_override("font_outline_color", Color(0.22, 0.12, 0.05))
        esme_karbar.add_theme_constant_override("outline_size", 8)
        esme_karbar.position = Vector2(660, 682)
        esme_karbar.custom_minimum_size = Vector2(250, 0)
        esme_karbar.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        add_child(esme_karbar)
        var bikar := create_tween().set_loops()
        bikar.tween_property(ostad, "position:y", 342.0, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
        bikar.tween_property(ostad, "position:y", 356.0, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

        # هلیا — بانوی فرمان؛ دختر ایرانیِ پوشیده با حجاب، کنار تیز پا
        helia = TextureRect.new()
        if ResourceLoader.exists("res://assets/sprites/helia.webp"):
                helia.texture = load("res://assets/sprites/helia.webp")
        if helia.texture != null:
                helia.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
                helia.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
                helia.position = Vector2(455, 330)
                helia.size = Vector2(200, 322)
                helia.pivot_offset = Vector2(100, 322)
                add_child(helia)
                var esme_helia := _matn_besaz("هلیا", 26, false, true, Color(0.98, 0.9, 0.7))
                esme_helia.add_theme_color_override("font_outline_color", Color(0.22, 0.12, 0.05))
                esme_helia.add_theme_constant_override("outline_size", 8)
                esme_helia.position = Vector2(455, 655)
                esme_helia.custom_minimum_size = Vector2(200, 0)
                esme_helia.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
                add_child(esme_helia)
                var nafase_helia := create_tween().set_loops()
                nafase_helia.tween_property(helia, "position:y", 322.0, 1.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
                nafase_helia.tween_property(helia, "position:y", 338.0, 1.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

        # پنل راست: تب‌ها + محتوا (چیدمان منظم)
        var panel := PanelContainer.new()
        panel.add_theme_stylebox_override("panel", _sb(Color(0.99, 0.96, 0.88, 0.98), Color(0.29, 0.216, 0.157), 22, 5))
        panel.position = Vector2(930, 70)
        panel.size = Vector2(336, 620)
        add_child(panel)

        var pv := VBoxContainer.new()
        pv.add_theme_constant_override("separation", 8)
        panel.add_child(pv)

        var tabha := HBoxContainer.new()
        tabha.add_theme_constant_override("separation", 8)
        pv.add_child(tabha)
        dokme_tab_artagha = Button.new()
        dokme_tab_artagha.text = Koli.tarjome("tab_ups")
        dokme_tab_artagha.add_theme_font_override("font", fnt_onvan)
        dokme_tab_artagha.add_theme_font_size_override("font_size", 26)
        dokme_tab_artagha.custom_minimum_size = Vector2(170, 72)
        dokme_tab_artagha.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        dokme_tab_artagha.pressed.connect(func(): _tab_avaz(false))
        tabha.add_child(dokme_tab_artagha)
        dokme_tab_mashinha = Button.new()
        dokme_tab_mashinha.text = Koli.tarjome("tab_cars")
        dokme_tab_mashinha.add_theme_font_override("font", fnt_onvan)
        dokme_tab_mashinha.add_theme_font_size_override("font_size", 26)
        dokme_tab_mashinha.custom_minimum_size = Vector2(170, 72)
        dokme_tab_mashinha.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        dokme_tab_mashinha.pressed.connect(func(): _tab_avaz(true))
        tabha.add_child(dokme_tab_mashinha)

        var skrol := ScrollContainer.new()
        skrol.custom_minimum_size = Vector2(306, 520)
        skrol.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
        pv.add_child(skrol)

        var mohtava := VBoxContainer.new()
        mohtava.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        skrol.add_child(mohtava)

        # تب ماشین‌ها: گرید ۲ ستونه
        shabake_mashinha = GridContainer.new()
        shabake_mashinha.columns = 2
        shabake_mashinha.add_theme_constant_override("h_separation", 8)
        shabake_mashinha.add_theme_constant_override("v_separation", 8)
        mohtava.add_child(shabake_mashinha)
        for i in Koli.MASHINHA.size():
                shabake_mashinha.add_child(_karte_mashin(i))

        # تب ارتقا: سه ردیف منظم
        qute_artagha = VBoxContainer.new()
        qute_artagha.add_theme_constant_override("separation", 10)
        mohtava.add_child(qute_artagha)
        for u in Koli.ARTAGHAHA:
                var sh_yekta: String = u["id"]
                var satr := PanelContainer.new()
                satr.add_theme_stylebox_override("panel", _sb(Color(0.97, 0.92, 0.8), Color(0.8, 0.66, 0.42), 14, 2, false))
                var hb := HBoxContainer.new()
                hb.add_theme_constant_override("separation", 8)
                satr.add_child(hb)
                var etelaat := VBoxContainer.new()
                etelaat.size_flags_horizontal = Control.SIZE_EXPAND_FILL
                etelaat.add_child(_matn_besaz(str(u["name"]), 22, false, true))
                etelaat.add_child(_matn_besaz(str(u["desc"]), 15))
                hb.add_child(etelaat)
                var rast := VBoxContainer.new()
                rast.alignment = BoxContainer.ALIGNMENT_CENTER
                var noqtha := _matn_besaz("", 20, true, false, Color(0.72, 0.52, 0.1))
                noqtha.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
                rast.add_child(noqtha)
                noqtehaye_artagha[sh_yekta] = noqtha
                var b := Button.new()
                b.custom_minimum_size = Vector2(150, 72)
                b.add_theme_font_override("font", fnt_tiz)
                b.add_theme_font_size_override("font_size", 20)
                b.pressed.connect(_artagha_zad.bind(sh_yekta))
                _dokme_shekl(b, true)
                rast.add_child(b)
                dokmehaye_artagha[sh_yekta] = b
                hb.add_child(rast)
                qute_artagha.add_child(satr)

        payam = _matn_besaz("", 19, true, false, Color(0.75, 0.2, 0.1))
        payam.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        payam.modulate.a = 0.0
        add_child(payam)

        _tab_avaz(true)

        # استاد هر از چندی خودش سرِ کار می‌رود — گاراژ همیشه زنده است
        _zaman_demo = Timer.new()
        _zaman_demo.wait_time = 7.0
        _zaman_demo.autostart = true
        _zaman_demo.timeout.connect(_kare_ostad)
        add_child(_zaman_demo)
        # همین که وارد گاراژ می‌شوی، استاد مشغول کار است
        get_tree().create_timer(0.8).timeout.connect(_kare_ostad)

func _karte_mashin(i: int) -> Control:
        var c = Koli.MASHINHA[i]
        var karte := PanelContainer.new()
        karte.add_theme_stylebox_override("panel", _sb(Color(0.97, 0.92, 0.8), Color(0.8, 0.66, 0.42), 14, 2, false))
        var vb := VBoxContainer.new()
        vb.add_theme_constant_override("separation", 2)
        karte.add_child(vb)
        var tasvir := TextureRect.new()
        tasvir.texture = load(c["tex"])
        tasvir.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        tasvir.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        tasvir.custom_minimum_size = Vector2(150, 70)
        vb.add_child(tasvir)
        var nm := _matn_besaz(str(c["name"]), 17, true)
        nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        vb.add_child(nm)
        var b := Button.new()
        b.custom_minimum_size = Vector2(150, 64)
        b.add_theme_font_override("font", fnt_tiz)
        b.add_theme_font_size_override("font_size", 18)
        b.set_meta("car_index", i)
        _dokme_shekl(b, true)
        b.pressed.connect(_dokme_mashin.bind(i))
        vb.add_child(b)
        dokmehaye_mashin.append(b)
        return karte

func _tab_avaz(cars_tab: bool) -> void:
        shabake_mashinha.visible = cars_tab
        qute_artagha.visible = not cars_tab
        dokme_tab_mashinha.disabled = cars_tab
        dokme_tab_artagha.disabled = not cars_tab

func _dokme_mashin(i: int) -> void:
        if Koli.mashin_bazshode[i]:
                Koli.mashin_entekhabi = i
                Koli.zakhire_kon()
                Seda.sfx_baz("coin")
        elif not Koli.mashin_bekhar(i):
                _payam_neshon("سکه کافی نداری! مأموریت برو")
                if maghz != null:
                        maghz.begu(akse_mashin, str(Koli.MASHINHA[Koli.mashin_entekhabi]["id"]), "poor")
                return
        else:
                Seda.sfx_baz("win")
        _taze_sazi()
        _kare_ostad()
        if maghz != null:
                var sh := str(Koli.MASHINHA[Koli.mashin_entekhabi]["id"])
                maghz.begu(akse_mashin, sh, "select")

func _artagha_zad(sh_yekta: String) -> void:
        if not Koli.artagha_bezan(sh_yekta):
                var hazine := Koli.qeymate_artagha(sh_yekta)
                if hazine > 0:
                        _payam_neshon("سکه کافی نداری! مأموریت برو")
                return
        Seda.sfx_baz("clank")
        _taze_sazi()
        _kare_ostad()
        if maghz != null:
                maghz.begu(akse_mashin, str(Koli.MASHINHA[Koli.mashin_entekhabi]["id"]), "upgrade")

func _kare_ostad() -> void:
        # انیمیشن واقعی «استاد در حال کار»: سه ضربه آچار، جرقه، صدای فلز، لرزش ماشین
        if _dar_kar:
                return
        _dar_kar = true
        Seda.sfx_baz("boost")
        if maghz != null and _tasadofi_ostad():
                maghz.begu(ostad, "ustad", "idle")
        for i in 3:
                var bala_kesh := create_tween()
                bala_kesh.tween_property(ostad, "rotation_degrees", -17.0, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
                await get_tree().create_timer(0.18).timeout
                var khat := create_tween()
                khat.tween_property(ostad, "rotation_degrees", 9.0, 0.09).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
                jarqeha.restart()
                jarqeha.emitting = true
                Seda.sfx_baz("clank")
                _larze_mashin()
                await get_tree().create_timer(0.38).timeout
        var sabt := create_tween()
        sabt.tween_property(ostad, "rotation_degrees", 0.0, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
        await sabt.finished
        _dar_kar = false

func _larze_mashin() -> void:
        # ماشین روی جک با هر ضربه می‌لرزد
        var paye := akse_mashin.position
        var t := create_tween()
        t.tween_property(akse_mashin, "position:x", paye.x + 5.0, 0.05)
        t.tween_property(akse_mashin, "position:x", paye.x - 4.0, 0.05)
        t.tween_property(akse_mashin, "position:x", paye.x, 0.05)

func _tasadofi_ostad() -> bool:
        return randf() < 0.45

func _payam_neshon(peygham: String) -> void:
        payam.text = peygham
        payam.position = Vector2(330, 640)
        payam.custom_minimum_size = Vector2(620, 0)
        payam.modulate.a = 1.0
        var t := create_tween()
        t.tween_interval(1.2)
        t.tween_property(payam, "modulate:a", 0.0, 0.6)

func _taze_sazi() -> void:
        matne_pool.text = str(Koli.pool)
        var c = Koli.MASHINHA[Koli.mashin_entekhabi]
        akse_mashin.texture = load(c["tex"])
        matne_esme_mashin.text = str(c["name"])
        if virayeshe_pelak != null and not virayeshe_pelak.has_focus():
                virayeshe_pelak.text = Koli.esme_pelak
        for b in dokmehaye_mashin:
                var i: int = b.get_meta("car_index")
                if Koli.mashin_entekhabi == i:
                        b.text = Koli.tarjome("selected")
                        b.disabled = true
                elif Koli.mashin_bazshode[i]:
                        b.text = Koli.tarjome("select")
                        b.disabled = false
                else:
                        b.text = Koli.tarjome("buy") + " " + str(Koli.MASHINHA[i]["price"])
                        b.disabled = false
        for sh_yekta in dokmehaye_artagha:
                var sath: int = Koli.artagha[sh_yekta]
                var hazine := Koli.qeymate_artagha(sh_yekta)
                var noqtha := ""
                for k in 3:
                        noqtha += "•" if k < sath else "·"
                noqtehaye_artagha[sh_yekta].text = noqtha
                dokmehaye_artagha[sh_yekta].text = Koli.tarjome("max") if hazine < 0 else str(hazine) + " سکه"
                dokmehaye_artagha[sh_yekta].disabled = hazine < 0

func _sakhtane_takse_saye() -> ImageTexture:
    var sz := Vector2i(240, 64)
    var aks := Image.create(sz.x, sz.y, false, Image.FORMAT_RGBA8)
    var cx := sz.x / 2.0
    var cy := sz.y / 2.0
    for y in sz.y:
        for x in sz.x:
            var d := Vector2((x - cx) / (cx - 6.0), (y - cy) / (cy - 4.0)).length()
            var a: float = clamp(1.0 - d, 0.0, 1.0)
            aks.set_pixel(x, y, Color(0.05, 0.03, 0.02, a * a * 0.75))
    return ImageTexture.create_from_image(aks)
