extends Control

var fnt: FontFile
var fnt_tiz: FontFile
var fnt_onvan: FontFile
var panel_khane: PanelContainer
var panel_marhaleha: PanelContainer
var panel_rahnama: PanelContainer
var panel_darbare: PanelContainer
var dokme_bazi: Button
var matne_pool: Label
var virayeshe_pelak: LineEdit
var maghz = null
var mashinaye_shahr: Array = []
var ruye_anlan: Control = null
var _montazere_anlan := false
var dokme_bargasht: Button
var khaneye_aval: Button
var mostatil_akbar: TextureRect
var matne_jomle_akbar: Label
var gerehaye_onvan: Array = []
var _montazere_sahne := false

# بارگذاری مستقیم مغز — بدون وابستگی به class cache
const PRE_MAGHZ := preload("res://scripts/car_brain.gd")
const PRE_MOSA := preload("res://scripts/race3d.gd")
const PRE_NET := preload("res://scripts/online_race.gd")

const RANG_TALA := Color(0.96, 0.76, 0.25)
const RANG_TALA_KAM := Color(0.72, 0.55, 0.2)
const RANG_GHERMEZ := Color(0.78, 0.15, 0.12)
const RANG_GHERMEZ_TIR := Color(0.45, 0.08, 0.06)
const RANG_SHISHE := Color(0.055, 0.065, 0.10, 0.93)
const RANG_KERM := Color(0.95, 0.93, 0.88)
# ناحیه امن بالا (استاتوس‌بار گوشی) — هیچ UI مهمی بالای این خط
const MARZ_BALA := 46.0

func _khandane_amn(masir: String) -> Resource:
        # بارگذاری امن: منبع نبودن یا خرابی هرگز منو را نمی‌شکند
        if masir == null or not ResourceLoader.exists(masir):
                return null
        return load(masir)

func _fnt_amn(masir: String) -> FontFile:
        var r := _khandane_amn(masir)
        if r is FontFile:
                return r
        return null

func _ready() -> void:
        # ⛔ قفل صریح LTR — مقدار 0 (ارث‌بری) باگ v0.9 بود که روی گوشی فارسی
        # کل چیدمان را آینه می‌کرد
        layout_direction = Control.LAYOUT_DIRECTION_LTR
        fnt = _fnt_amn("res://assets/fonts/Vazirmatn-Regular.ttf")
        fnt_tiz = _fnt_amn("res://assets/fonts/Vazirmatn-Bold.ttf")
        fnt_onvan = _fnt_amn("res://assets/fonts/Lalezar-Regular.ttf")
        _zamine_besaz()
        _rabet_besaz()
        _taze_sazi()
        if has_node("/root/AudioMgr"):
                get_node("/root/AudioMgr").play_music()
        # تزئینات زنده — هر کدام فراخوان جداگانه تا خرابیِ هر بخش فقط خودش را بیندازد
        call_deferred("_tadarogha")
        call_deferred("_mashinaye_shahr")
        call_deferred("_maghze_shahr")
        call_deferred("_noskhe_deko")
        var arg_line := OS.get_cmdline_user_args()
        # چرخه کامل تست: برگشت از پنل پایان مسابقه به منو — پایان موفق چرخه
        if arg_line.has("--autotest-full"):
                if Koli.get_meta("at_menu_return", false):
                        Koli.remove_meta("at_menu_return")
                        print("[tizpa][autotest] TAP-ENDMENU OK — چرخه کامل بازی→پایان→منو سالم")
                        _aks("/home/z/my-project/scripts/shot_menu_return.png")
                        get_tree().quit(0)
                        return
                Koli.set_meta("start_level", 1)
                get_tree().change_scene_to_file("res://scenes/game.tscn")
                return
        if arg_line.has("--levels"):
                _neshon_bede(panel_marhaleha)
        if arg_line.has("--onlinetest"):
                _azm_anlan()
        if arg_line.has("--autotest"):
                _azm_khodkar()

func _azm_khodkar() -> void:
        await get_tree().create_timer(1.2).timeout
        _aks("/home/z/my-project/scripts/shot_menu.png")
        if dokme_bazi == null or not is_instance_valid(dokme_bazi):
                print("[tizpa][autotest] TAP-PLAY FAIL (no button)")
                get_tree().quit(1)
                return
        # ۱) تپ واقعی روی «مراحل»
        print("[tizpa][autotest] play_btn rect=", dokme_bazi.get_global_rect(), " visible=", dokme_bazi.visible)
        var _faz := panel_khane.get_parent()
        print("[tizpa][autotest] viewport=", get_viewport().get_visible_rect().size, " window=", DisplayServer.window_get_size())
        print("[tizpa][autotest] cc rect=", (_faz as Control).get_global_rect() if _faz is Control else Vector2())
        print("[tizpa][autotest] panel rect=", panel_khane.get_global_rect(), " min=", panel_khane.custom_minimum_size)
        for _c in panel_khane.get_child(0).get_child(0).get_children():
                if _c is Control:
                        print("[tizpa][autotest]   child ", _c.get_class(), " rect=", _c.get_global_rect())
        _lamse(dokme_bazi)
        await get_tree().create_timer(0.7).timeout
        var ok := panel_marhaleha != null and panel_marhaleha.visible
        print("[tizpa][autotest] TAP-PLAY ", "OK" if ok else "FAIL")
        _aks("/home/z/my-project/scripts/shot_levels.png")
        if not ok:
                get_tree().quit(1)
                return
        # ۲) برگشت به خانه
        if dokme_bargasht != null and is_instance_valid(dokme_bargasht):
                _lamse(dokme_bargasht)
                await get_tree().create_timer(0.5).timeout
                print("[tizpa][autotest] TAP-BACK ", "OK" if panel_khane.visible else "FAIL")
        # ۳) ورود به مرحله ۱ — تپ روی کاشی اول؛ انتظار: تعویض صحنه به Game
        if khaneye_aval == null or not is_instance_valid(khaneye_aval):
                print("[tizpa][autotest] TAP-LEVEL FAIL (no tile)")
                get_tree().quit(1)
                return
        _lamse(dokme_bazi) # برگرد به لیست
        await get_tree().create_timer(0.5).timeout
        _lamse(khaneye_aval)
        _montazere_sahne = true
        # اگر تا ۲ ثانیه دیگر صحنه عوض نشده باشد، منو هنوز زنده است = شکست
        await get_tree().create_timer(2.0).timeout
        print("[tizpa][autotest] TAP-LEVEL FAIL (scene did not change — باگ ورود به بازی!)")
        get_tree().quit(1)

func _exit_tree() -> void:
        if _montazere_sahne:
                print("[tizpa][autotest] TAP-LEVEL OK — scene changed to ", "(Game)")
        if _montazere_anlan:
                print("[tizpa][onlinetest] ONLINE-TAKEOVER OK — اکبر آمد و مسابقه لود شد")

func _azm_anlan() -> void:
        await get_tree().create_timer(0.5).timeout
        _anlan_bazkon()
        await get_tree().create_timer(0.6).timeout
        var ok := ruye_anlan != null and is_instance_valid(ruye_anlan) and ruye_anlan.visible and ruye_anlan.size.x > 1000.0
        print("[tizpa][onlinetest] OVERLAY ", "OK" if ok else "FAIL", " size=", ruye_anlan.size if ruye_anlan != null else "none")
        _aks("/home/z/my-project/scripts/shot_online.png")
        if not ok:
                get_tree().quit(1)
                return
        _montazere_anlan = true
        await get_tree().create_timer(24.0).timeout
        print("[tizpa][onlinetest] FAIL — تعویض صحنه انجام نشد")
        get_tree().quit(1)

func _aks(masir: String) -> void:
        var aks := get_viewport().get_texture().get_image()
        if aks != null:
                aks.save_png(masir)

func _lamse(btn: Button) -> void:
        var ja: Vector2 = btn.get_global_rect().get_center()
        for feshorde in [true, false]:
                var ev := InputEventMouseButton.new()
                ev.button_index = MOUSE_BUTTON_LEFT
                ev.pressed = feshorde
                if feshorde:
                        ev.button_mask = MOUSE_BUTTON_MASK_LEFT
                ev.position = ja
                ev.global_position = ja
                Input.parse_input_event(ev)

func _zamine_besaz() -> void:
        var teks := _khandane_amn("res://assets/sprites/menu_bg.webp")
        if teks == null:
                teks = _khandane_amn("res://assets/sprites/menu_bg.png")
        if teks != null:
                var paszamine := TextureRect.new()
                paszamine.texture = teks
                paszamine.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
                paszamine.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
                paszamine.set_anchors_preset(Control.PRESET_FULL_RECT)
                paszamine.mouse_filter = Control.MOUSE_FILTER_IGNORE
                add_child(paszamine)
        else:
                var gt := GradientTexture2D.new()
                var g := Gradient.new()
                g.offsets = PackedFloat32Array([0.0, 0.6, 1.0])
                g.colors = PackedColorArray([Color(0.30, 0.16, 0.10), Color(0.14, 0.09, 0.07), Color(0.06, 0.04, 0.04)])
                gt.gradient = g
                gt.fill_from = Vector2(0.3, 0.0)
                gt.fill_to = Vector2(0.7, 1.0)
                var paszamine := TextureRect.new()
                paszamine.texture = gt
                paszamine.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
                paszamine.set_anchors_preset(Control.PRESET_FULL_RECT)
                paszamine.mouse_filter = Control.MOUSE_FILTER_IGNORE
                add_child(paszamine)

func _matn_besaz(matn: String, size: int, bold := false, display := false, rangi := RANG_KERM) -> Label:
        var l := Label.new()
        l.text = matn
        var f := fnt_onvan if display else (fnt_tiz if bold else fnt)
        if f != null:
                l.add_theme_font_override("font", f)
        l.add_theme_font_size_override("font_size", size)
        l.add_theme_color_override("font_color", rangi)
        l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        return l

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
                sb.shadow_color = Color(0, 0, 0, 0.45)
                sb.shadow_size = 10
        return sb

func _dokme_shekl(b: Button, kind := "red") -> void:
        var normal: StyleBoxFlat
        var ru_hashie: StyleBoxFlat
        var feshorde: StyleBoxFlat
        var qeyrfaal: StyleBoxFlat
        var fg := RANG_KERM
        if kind == "red":
                normal = _sb(RANG_GHERMEZ, RANG_GHERMEZ_TIR, 16, 3)
                ru_hashie = _sb(RANG_GHERMEZ.lightened(0.10), RANG_GHERMEZ_TIR, 16, 3)
                feshorde = _sb(RANG_GHERMEZ_TIR, RANG_GHERMEZ_TIR, 16, 3)
                qeyrfaal = _sb(Color(0.35, 0.2, 0.18), Color(0.3, 0.16, 0.14), 16, 3)
                fg = Color(1, 0.96, 0.9)
        elif kind == "dark":
                normal = _sb(Color(0.16, 0.175, 0.20, 0.97), RANG_TALA_KAM, 16, 2)
                ru_hashie = _sb(Color(0.22, 0.235, 0.26, 0.97), RANG_TALA, 16, 2)
                feshorde = _sb(Color(0.10, 0.11, 0.13, 0.97), RANG_TALA_KAM, 16, 2)
                qeyrfaal = _sb(Color(0.14, 0.145, 0.16), Color(0.2, 0.2, 0.22), 16, 2)
                fg = Color(0.98, 0.92, 0.72)
        else:
                normal = _sb(Color(0.20, 0.22, 0.25, 0.97), Color(0.36, 0.39, 0.43), 12, 2, false)
                ru_hashie = _sb(Color(0.27, 0.30, 0.34, 0.97), RANG_TALA_KAM, 12, 2, false)
                feshorde = _sb(Color(0.13, 0.14, 0.16, 0.97), Color(0.3, 0.32, 0.35), 12, 2, false)
                qeyrfaal = _sb(Color(0.145, 0.15, 0.16, 0.9), Color(0.21, 0.215, 0.22), 12, 2, false)
                fg = RANG_KERM
        b.add_theme_stylebox_override("normal", normal)
        b.add_theme_stylebox_override("hover", ru_hashie)
        b.add_theme_stylebox_override("pressed", feshorde)
        b.add_theme_stylebox_override("disabled", qeyrfaal)
        b.add_theme_color_override("font_color", fg)
        b.add_theme_color_override("font_hover_color", fg)
        b.add_theme_color_override("font_focus_color", fg)
        b.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
        b.add_theme_color_override("font_disabled_color", Color(0.52, 0.5, 0.47))

func _dokme_besaz(matn: String, size := 26, kind := "red", h := 74) -> Button:
        var b := Button.new()
        b.text = matn
        if fnt_onvan != null:
                b.add_theme_font_override("font", fnt_onvan)
        b.add_theme_font_size_override("font_size", size)
        b.custom_minimum_size = Vector2(320, h)
        _dokme_shekl(b, kind)
        return b

func _sakhtane_takse_saye() -> Texture2D:
        var gt := GradientTexture2D.new()
        gt.fill = GradientTexture2D.FILL_RADIAL
        gt.width = 240
        gt.height = 64
        gt.fill_from = Vector2(0.5, 0.5)
        gt.fill_to = Vector2(0.5, 0.0)
        var g := Gradient.new()
        g.offsets = PackedFloat32Array([0.0, 0.65, 1.0])
        g.colors = PackedColorArray([Color(0.02, 0.02, 0.03, 0.8), Color(0.02, 0.02, 0.03, 0.22), Color(0, 0, 0, 0)])
        gt.gradient = g
        return gt

func _tadarogha() -> void:
        _tadarog_besaz(true)
        _tadarog_besaz(false)

func _tadarog_besaz(bala: bool) -> void:
        var gt := GradientTexture2D.new()
        var g := Gradient.new()
        if bala:
                g.offsets = PackedFloat32Array([0.0, 1.0])
                g.colors = PackedColorArray([Color(0.05, 0.04, 0.06, 0.62), Color(0, 0, 0, 0.0)])
                gt.fill_from = Vector2(0, 0)
                gt.fill_to = Vector2(0, 1)
        else:
                g.offsets = PackedFloat32Array([0.0, 1.0])
                g.colors = PackedColorArray([Color(0, 0, 0, 0.0), Color(0.04, 0.03, 0.05, 0.72)])
                gt.fill_from = Vector2(0, 0)
                gt.fill_to = Vector2(0, 1)
        gt.gradient = g
        var tr := TextureRect.new()
        tr.texture = gt
        tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        tr.stretch_mode = TextureRect.STRETCH_SCALE
        tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
        tr.anchor_left = 0.0
        tr.anchor_right = 1.0
        if bala:
                tr.anchor_top = 0.0
                tr.anchor_bottom = 0.24
        else:
                tr.anchor_top = 0.70
                tr.anchor_bottom = 1.0
        add_child(tr)

func _mashinaye_shahr() -> void:
        var ghahreman := TextureRect.new()
        var teks_hero := _khandane_amn("res://assets/sprites/menu_hero.png")
        if teks_hero == null:
                return
        ghahreman.texture = teks_hero
        ghahreman.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        ghahreman.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        ghahreman.anchor_left = 0.02
        ghahreman.anchor_right = 0.02
        ghahreman.anchor_top = 1.0
        ghahreman.anchor_bottom = 1.0
        ghahreman.offset_left = -20.0
        ghahreman.offset_right = 250.0
        ghahreman.offset_top = -400.0
        ghahreman.offset_bottom = 30.0
        ghahreman.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(ghahreman)
        mashinaye_shahr.append(ghahreman)
        move_child(ghahreman, 1)
        if maghz != null:
                PRE_MAGHZ.add_breathing(ghahreman, 4.0, 1.1)

func _onvan_besaz() -> void:
        # هاله‌ی طلایی پشت تیتر
        var bashash := TextureRect.new()
        bashash.texture = _khandane_amn("res://assets/sprites/title_glow.png")
        if bashash.texture != null:
                bashash.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
                bashash.stretch_mode = TextureRect.STRETCH_SCALE
                bashash.anchor_left = 0.5
                bashash.anchor_right = 0.5
                bashash.offset_left = -320.0
                bashash.offset_right = 320.0
                bashash.offset_top = MARZ_BALA - 46.0
                bashash.offset_bottom = MARZ_BALA + 118.0
                bashash.mouse_filter = Control.MOUSE_FILTER_IGNORE
                bashash.modulate = Color(1.0, 0.9, 0.6, 0.85)
                add_child(bashash)
                gerehaye_onvan.append(bashash)
        var onvan := _matn_besaz("تیز پا", 108, false, true, Color(1.0, 0.87, 0.42))
        onvan.add_theme_color_override("font_outline_color", Color(0.14, 0.05, 0.02))
        onvan.add_theme_constant_override("outline_size", 18)
        onvan.anchor_left = 0.0
        onvan.anchor_right = 1.0
        onvan.offset_top = MARZ_BALA - 8
        onvan.offset_bottom = MARZ_BALA + 118
        onvan.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        add_child(onvan)
        gerehaye_onvan.append(onvan)
        # خط نئونی دوتایی زیر لوگو
        var midad := Panel.new()
        midad.add_theme_stylebox_override("panel", _sb(Color(1.0, 0.62, 0.16, 0.95), Color(0, 0, 0, 0), 2))
        midad.anchor_left = 0.5
        midad.anchor_right = 0.5
        midad.offset_left = -96.0
        midad.offset_right = 96.0
        midad.offset_top = MARZ_BALA + 122
        midad.offset_bottom = MARZ_BALA + 127
        add_child(midad)
        gerehaye_onvan.append(midad)
        var matne_zir := _matn_besaz("مسابقه‌ی خیابانی تهران  •  پنج مرحله  •  یک قهرمان", 26, true, false, Color(0.94, 0.92, 0.88, 0.95))
        matne_zir.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
        matne_zir.add_theme_constant_override("outline_size", 7)
        matne_zir.anchor_left = 0.0
        matne_zir.anchor_right = 1.0
        matne_zir.offset_top = MARZ_BALA + 134
        matne_zir.offset_bottom = MARZ_BALA + 170
        matne_zir.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        add_child(matne_zir)
        gerehaye_onvan.append(matne_zir)

func _panele_khane_besaz() -> void:
        panel_khane = PanelContainer.new()
        panel_khane.add_theme_stylebox_override("panel", _sb(RANG_SHISHE, Color(0.85, 0.68, 0.28, 0.45), 22, 2))
        # اندازه بزرگ — دکمه‌ها باید حداقل ارتفاعِ لمس اندروید (~۸۸px کانواس) را داشته باشند
        # چیدمان دوستونه تا هم دکمه بلند باشد هم زیر تیتر (تا y=۱۶۰) جا شود
        panel_khane.custom_minimum_size = Vector2(560, 500)
        # جعبه‌ی قطعی: CenterContainer تمام‌صفحه زیر تیتر — بدون رقص anchors
        var rangi_khane := CenterContainer.new()
        rangi_khane.set_anchors_preset(Control.PRESET_FULL_RECT)
        rangi_khane.offset_top = 148.0
        rangi_khane.mouse_filter = Control.MOUSE_FILTER_PASS
        add_child(rangi_khane)
        rangi_khane.add_child(panel_khane)

        var mv := MarginContainer.new()
        mv.add_theme_constant_override("margin_left", 18)
        mv.add_theme_constant_override("margin_right", 18)
        mv.add_theme_constant_override("margin_top", 10)
        mv.add_theme_constant_override("margin_bottom", 10)
        panel_khane.add_child(mv)

        var hb := VBoxContainer.new()
        hb.add_theme_constant_override("separation", 6)
        hb.alignment = BoxContainer.ALIGNMENT_CENTER
        mv.add_child(hb)

        # چیپ سکه — آیکون واقعی (ایموجی در فونت گوشی گلیف ندارد)
        var chip := PanelContainer.new()
        chip.add_theme_stylebox_override("panel", _sb(Color(0.16, 0.17, 0.20, 0.97), RANG_TALA_KAM, 22, 1, false))
        chip.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
        var qabze_chip := HBoxContainer.new()
        qabze_chip.add_theme_constant_override("separation", 8)
        chip.add_child(qabze_chip)
        var teks_pool := _khandane_amn("res://assets/sprites/coin.png")
        if teks_pool != null:
                var neshane_pool := TextureRect.new()
                neshane_pool.texture = teks_pool
                neshane_pool.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
                neshane_pool.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
                neshane_pool.custom_minimum_size = Vector2(30, 30)
                neshane_pool.size_flags_vertical = Control.SIZE_SHRINK_CENTER
                qabze_chip.add_child(neshane_pool)
        matne_pool = _matn_besaz(str(Koli.pool), 24, true, false, RANG_TALA)
        matne_pool.custom_minimum_size = Vector2(90, 42)
        matne_pool.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        matne_pool.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
        qabze_chip.add_child(matne_pool)
        hb.add_child(chip)

        # پلاک نئونی اسم — نوجوان‌پسند (بدون عکس بچه!)
        var qute_pelak := Control.new()
        qute_pelak.custom_minimum_size = Vector2(324, 88)
        var teks_takhte := _khandane_amn("res://assets/sprites/plate_empty.webp")
        if teks_takhte != null:
                var takhte := TextureRect.new()
                takhte.texture = teks_takhte
                takhte.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
                takhte.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
                takhte.set_anchors_preset(Control.PRESET_FULL_RECT)
                takhte.mouse_filter = Control.MOUSE_FILTER_IGNORE
                qute_pelak.add_child(takhte)
        virayeshe_pelak = LineEdit.new()
        virayeshe_pelak.text = Koli.esme_pelak
        virayeshe_pelak.max_length = 12
        if fnt_tiz != null:
                virayeshe_pelak.add_theme_font_override("font", fnt_tiz)
        virayeshe_pelak.add_theme_font_size_override("font_size", 32)
        virayeshe_pelak.alignment = HORIZONTAL_ALIGNMENT_CENTER
        virayeshe_pelak.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
        virayeshe_pelak.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
        virayeshe_pelak.add_theme_color_override("font_color", Color(0.99, 0.85, 0.30))
        virayeshe_pelak.add_theme_color_override("caret_color", Color(0.99, 0.85, 0.30))
        virayeshe_pelak.add_theme_color_override("font_placeholder_color", Color(0.6, 0.5, 0.25))
        virayeshe_pelak.placeholder_text = "اسم تو..."
        virayeshe_pelak.anchor_left = 0.12
        virayeshe_pelak.anchor_right = 0.88
        virayeshe_pelak.anchor_top = 0.34
        virayeshe_pelak.anchor_bottom = 0.72
        virayeshe_pelak.text_changed.connect(func(_t): _pelak_taghir_kard())
        qute_pelak.add_child(virayeshe_pelak)
        hb.add_child(qute_pelak)

        # سه‌بخشی: مسابقه (قرمز اصلی) + دو ردیف دوستونه — همگی بالای حداقل لمس
        var dokme_mosabeqe := _dokme_besaz("مسابقه", 36, "red", 88)
        dokme_mosabeqe.pressed.connect(_mosabeqe_sari)
        hb.add_child(dokme_mosabeqe)

        var satr1 := HBoxContainer.new()
        satr1.add_theme_constant_override("separation", 10)
        var dokme_shoroo := _dokme_besaz("مراحل", 26, "dark", 80)
        dokme_shoroo.pressed.connect(func(): _neshon_bede(panel_marhaleha))
        dokme_bazi = dokme_shoroo
        satr1.add_child(dokme_shoroo)
        var dokme_garaj := _dokme_besaz("کارگاه", 24, "dark", 80)
        dokme_garaj.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/garage.tscn"))
        satr1.add_child(dokme_garaj)
        hb.add_child(satr1)

        var satr2 := HBoxContainer.new()
        satr2.add_theme_constant_override("separation", 10)
        var dokme_rahnama := _dokme_besaz("راهنمای بازی", 24, "dark", 72)
        dokme_rahnama.pressed.connect(func(): _neshon_bede(panel_rahnama))
        satr2.add_child(dokme_rahnama)
        var dokme_zendegi := _dokme_besaz("زندگی محله", 24, "dark", 72)
        dokme_zendegi.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/story.tscn"))
        satr2.add_child(dokme_zendegi)
        hb.add_child(satr2)

        # درباره ما — ته منو
        var dokme_darbare := _dokme_besaz("درباره ما", 22, "dark", 60)
        dokme_darbare.pressed.connect(func(): _neshon_bede(panel_darbare))
        hb.add_child(dokme_darbare)

func _mosabeqe_sari() -> void:
        # مسابقه سریع = آخرین مرحله‌ی باز شده (یا مرحله‌ی ۱)
        var sh_dakheli := 1
        for i in range(5, 0, -1):
                if Koli.marhale_bazshode(i):
                        sh_dakheli = i
                        break
        Koli.set_meta("start_level", sh_dakheli)
        get_tree().change_scene_to_file("res://scenes/game.tscn")

func _anlan_bazkon() -> void:
        # جست‌وجوی حریف آنلاین؛ اگر تا پایان صبر پیدا نشد → اکبر AI
        var ov: Control = PRE_NET.new()
        ruye_anlan = ov
        add_child(ov)
        if ov.has_method("start"):
                ov.start(Koli.entezare_anlan)
        ov.ai_takeover.connect(func():
                Koli.set_meta("custom_level", {
                        "id": 902, "type": "race", "name": "آنلاین — حریف: اکبر (AI)", "district": "محله",
                        "speed": 13.6, "distance": 500, "time": 75,
                        "obstacle_rate": 0.5, "coin_rate": 0.85, "ramp_rate": 0.3, "reward": 90,
                })
                Koli.set_meta("start_level", 902)
                get_tree().change_scene_to_file("res://scenes/game.tscn"))

func _panele_marhaleha_besaz() -> void:
        panel_marhaleha = PanelContainer.new()
        var skrole_marhaleha := _sb(Color(0.115, 0.125, 0.145, 0.97), Color(0.85, 0.68, 0.28, 0.55), 24, 3)
        skrole_marhaleha.content_margin_left = 18.0 # متن فارسی نباید به لبه‌ی پنل بچسبد
        skrole_marhaleha.content_margin_right = 18.0
        skrole_marhaleha.content_margin_top = 12.0
        skrole_marhaleha.content_margin_bottom = 12.0
        panel_marhaleha.add_theme_stylebox_override("panel", skrole_marhaleha)
        panel_marhaleha.custom_minimum_size = Vector2(1240, 600)
        panel_marhaleha.set_anchors_preset(Control.PRESET_CENTER)
        panel_marhaleha.offset_top = 10.0
        panel_marhaleha.grow_horizontal = Control.GROW_DIRECTION_BOTH
        panel_marhaleha.grow_vertical = Control.GROW_DIRECTION_BOTH
        panel_marhaleha.mouse_filter = Control.MOUSE_FILTER_IGNORE
        var marhale := VBoxContainer.new()
        marhale.add_theme_constant_override("separation", 8)
        panel_marhaleha.add_child(marhale)
        # هدر: هلیا — راننده‌ی تیز پا
        var sar := HBoxContainer.new()
        sar.add_theme_constant_override("separation", 14)
        var helia := TextureRect.new()
        helia.texture = _khandane_amn("res://assets/sprites/helia_portrait.webp")
        if helia.texture != null:
                helia.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
                helia.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
                helia.custom_minimum_size = Vector2(92, 108)
                sar.add_child(helia)
        var ak := VBoxContainer.new()
        ak.add_theme_constant_override("separation", 2)
        # ⛔ درس RTL: RIGHT + EXPAND_FILL تا عرض هرگز کم نیاید
        ak.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        var esme_akbar := _matn_besaz("هلیا — راننده‌ی تیز پا", 26, false, true, RANG_TALA)
        esme_akbar.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        esme_akbar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        ak.add_child(esme_akbar)
        var jomle_akbar := _matn_besaz("پنج مرحله، یک هدف: خط پایان از جلو!", 20, true, false, RANG_KERM)
        jomle_akbar.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        jomle_akbar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        jomle_akbar.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
        jomle_akbar.add_theme_constant_override("outline_size", 5)
        ak.add_child(jomle_akbar)
        sar.add_child(ak)
        marhale.add_child(sar)
        var skrol := ScrollContainer.new()
        skrol.custom_minimum_size = Vector2(1196, 330)
        skrol.size_flags_vertical = Control.SIZE_EXPAND_FILL
        var shabake := GridContainer.new()
        shabake.columns = 3
        shabake.add_theme_constant_override("h_separation", 12)
        shabake.add_theme_constant_override("v_separation", 12)
        for lv_def in PRE_MOSA.MARHALEHA:
                var id: int = int(lv_def["id"])
                var st: int = Koli.setare_marhale.get(id, 0)
                var bazshode: bool = Koli.marhale_bazshode(id)
                var b := Button.new()
                b.custom_minimum_size = Vector2(388, 118)
                _dokme_shekl(b, "tile")
                b.disabled = not bazshode
                var vb := VBoxContainer.new()
                vb.set_anchors_preset(Control.PRESET_FULL_RECT)
                vb.alignment = BoxContainer.ALIGNMENT_CENTER
                vb.add_theme_constant_override("separation", 0)
                vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
                var shomare := Label.new()
                shomare.text = str(id) + " — " + str(lv_def["name"])
                if fnt_onvan != null:
                        shomare.add_theme_font_override("font", fnt_onvan)
                shomare.add_theme_font_size_override("font_size", 32)
                shomare.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
                shomare.add_theme_color_override("font_color", RANG_KERM if bazshode else Color(0.55, 0.53, 0.50))
                shomare.mouse_filter = Control.MOUSE_FILTER_IGNORE
                vb.add_child(shomare)
                var tozih := Label.new()
                tozih.text = str(lv_def["desc"]) if bazshode else "با قهرمانی در مرحله‌ی قبل باز می‌شود"
                if fnt_tiz != null:
                        tozih.add_theme_font_override("font", fnt_tiz)
                tozih.add_theme_font_size_override("font_size", 16)
                tozih.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
                tozih.add_theme_color_override("font_color", Color(0.80, 0.80, 0.76, 0.85) if bazshode else Color(0.45, 0.44, 0.42))
                tozih.mouse_filter = Control.MOUSE_FILTER_IGNORE
                vb.add_child(tozih)
                var setareha := Label.new()
                var matne_setare := ""
                for s in 3:
                        matne_setare += "٭" if s < st else "·"
                setareha.text = matne_setare + "   •   " + str(int(lv_def["laps"])) + " دور"
                if fnt_tiz != null:
                        setareha.add_theme_font_override("font", fnt_tiz)
                setareha.add_theme_font_size_override("font_size", 18)
                setareha.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
                setareha.add_theme_color_override("font_color", RANG_TALA if st > 0 else Color(0.42, 0.44, 0.47))
                setareha.mouse_filter = Control.MOUSE_FILTER_IGNORE
                vb.add_child(setareha)
                b.add_child(vb)
                b.pressed.connect(_marhale_shoroo.bind(id))
                shabake.add_child(b)
                if id == 1:
                        khaneye_aval = b
        skrol.add_child(shabake)
        marhale.add_child(skrol)
        var dokme_bargasht1 := _dokme_besaz(Koli.tarjome("back"), 28, "dark", 68)
        dokme_bargasht1.pressed.connect(func(): _neshon_bede(panel_khane))
        dokme_bargasht = dokme_bargasht1
        marhale.add_child(dokme_bargasht1)
        # پنل مستقیم (بدون CenterContainer تمام‌صفحه — درس v0.8)
        add_child(panel_marhaleha)
        panel_marhaleha.visible = false

func _maghze_shahr() -> void:
        maghz = PRE_MAGHZ.new()
        add_child(maghz)
        # حباب حرف در منو حذف شد — لحن جدی‌تر؛ مغز فقط نفس‌کشیدن را می‌دهد

func _noskhe_deko() -> void:
        # برچسب نسخه از Globals — دیگر هرگز دستی نیست (باگ «v0.9 هاردکد»)
        var l := _matn_besaz("تیز پا v%s — بیلد %d" % [Koli.NOSKHE, Koli.SAKHT], 16, true, false, Color(1, 1, 1, 0.58))
        l.anchor_left = 0.0
        l.anchor_right = 1.0
        l.anchor_top = 1.0
        l.anchor_bottom = 1.0
        l.offset_left = 16.0
        l.offset_right = -16.0
        l.offset_top = -34.0
        l.offset_bottom = -8.0
        l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        l.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(l)

func _panele_etelaat_besaz() -> void:
        # راهنمای بازی — همه‌چیزی که راننده‌ی نو لازم دارد
        panel_rahnama = PanelContainer.new()
        var gs := _sb(Color(0.115, 0.125, 0.145, 0.97), Color(0.85, 0.68, 0.28, 0.55), 24, 3)
        panel_rahnama.add_theme_stylebox_override("panel", gs)
        panel_rahnama.custom_minimum_size = Vector2(1100, 560)
        panel_rahnama.set_anchors_preset(Control.PRESET_CENTER)
        panel_rahnama.offset_top = 10.0
        panel_rahnama.grow_horizontal = Control.GROW_DIRECTION_BOTH
        panel_rahnama.grow_vertical = Control.GROW_DIRECTION_BOTH
        var gv := VBoxContainer.new()
        gv.add_theme_constant_override("separation", 10)
        panel_rahnama.add_child(gv)
        var gt := _matn_besaz("راهنمای بازی", 44, false, true, RANG_TALA)
        gt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        gt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        gv.add_child(gt)
        var khattha := [
                "هدف: قبل از سه رقیب از خط پایان رد شو — جایگاه اول سه ستاره می‌دهد.",
                "فرمان: انگشتت را نیمه‌ی چپ صفحه بکش — هرچه بیشتر بکشی تندتر می‌پیچی.",
                "دستی (دکمه‌ی قرمز): بگیر و بپیچ تا ماشین بلغزد — این همان دریفت است!",
                "نیترو (دکمه‌ی آبی): دریفت بزن تا شارژ شود، بعد نگه‌دار تا شعله بزند.",
                "ترمز: دکمه‌ی خاکستری کنار دستی — داخل پیچ تنگ سر کم کن.",
                "ستاره‌ها در هر مرحله ذخیره می‌شوند و مرحله‌ی بعدی را باز می‌کنند.",
                "سکه‌ها را جمع کن و در کارگاه ماشین تازه و تیون بخر.",
        ]
        for ln in khattha:
                var rl := _matn_besaz("•  " + ln, 22, true, false, RANG_KERM)
                rl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
                rl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
                rl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
                gv.add_child(rl)
        var gb := _dokme_besaz(Koli.tarjome("back"), 28, "dark", 68)
        gb.pressed.connect(func(): _neshon_bede(panel_khane))
        dokme_bargasht = gb
        gv.add_child(gb)
        add_child(panel_rahnama)
        panel_rahnama.visible = false

        # درباره ما — آخرین گزینه‌ی منو؛ بدون هیچ نام سازنده (متن نهایی بعداً توسط مالک بازی کامل می‌شود)
        panel_darbare = PanelContainer.new()
        var asb := _sb(Color(0.115, 0.125, 0.145, 0.97), Color(0.85, 0.68, 0.28, 0.55), 24, 3)
        panel_darbare.add_theme_stylebox_override("panel", asb)
        panel_darbare.custom_minimum_size = Vector2(900, 430)
        panel_darbare.set_anchors_preset(Control.PRESET_CENTER)
        panel_darbare.offset_top = 10.0
        panel_darbare.grow_horizontal = Control.GROW_DIRECTION_BOTH
        panel_darbare.grow_vertical = Control.GROW_DIRECTION_BOTH
        var av := VBoxContainer.new()
        av.add_theme_constant_override("separation", 12)
        panel_darbare.add_child(av)
        var at := _matn_besaz("درباره ما", 44, false, true, RANG_TALA)
        at.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        at.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        av.add_child(at)
        var a1 := _matn_besaz("تیز پا — مسابقه‌ی خیابانی خیابان‌های تهران", 26, true, false, RANG_KERM)
        a1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        a1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        av.add_child(a1)
        var a2 := _matn_besaz("از ولیعصر تا میدان آزادی؛ پنج مرحله، دریفت واقعی و نیترو.", 22, true, false, RANG_KERM)
        a2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        a2.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        a2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        av.add_child(a2)
        var a3 := _matn_besaz("نسخه " + Koli.NOSKHE + " — بیلد " + str(Koli.SAKHT), 18, true, false, Color(1, 1, 1, 0.6))
        a3.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        a3.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        av.add_child(a3)
        var ab := _dokme_besaz(Koli.tarjome("back"), 28, "dark", 68)
        ab.pressed.connect(func(): _neshon_bede(panel_khane))
        av.add_child(ab)
        add_child(panel_darbare)
        panel_darbare.visible = false

func _rabet_besaz() -> void:
        _onvan_besaz()
        _panele_khane_besaz()
        _panele_marhaleha_besaz()
        _panele_etelaat_besaz()
        _neshon_bede(panel_khane)

func _neshon_bede(p: PanelContainer) -> void:
        if panel_khane == null or panel_marhaleha == null:
                return
        panel_khane.visible = p == panel_khane
        panel_marhaleha.visible = p == panel_marhaleha
        if panel_rahnama != null:
                panel_rahnama.visible = p == panel_rahnama
        if panel_darbare != null:
                panel_darbare.visible = p == panel_darbare
        # تیتر فقط مال صفحه‌ی خانه است (لیست ماموریت‌ها خودش هدر دارد)
        for n in gerehaye_onvan:
                if is_instance_valid(n):
                        n.visible = p == panel_khane
        for n in mashinaye_shahr:
                if is_instance_valid(n):
                        n.visible = p == panel_khane
        _taze_sazi()

func _pelak_taghir_kard() -> void:
        Koli.esme_pelak = virayeshe_pelak.text.strip_edges()
        if Koli.esme_pelak.is_empty():
                Koli.esme_pelak = "هلیا"
        Koli.zakhire_kon()

func _taze_sazi() -> void:
        if matne_pool:
                matne_pool.text = str(Koli.pool)
        if virayeshe_pelak:
                virayeshe_pelak.text = Koli.esme_pelak

func _marhale_shoroo(id: int) -> void:
        Koli.set_meta("start_level", id)
        get_tree().change_scene_to_file("res://scenes/game.tscn")
