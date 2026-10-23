extends Control

# ─── منوی اصلی تیز پا ─────────────────────────────────────────
# خانه = هنر تمام‌صفحه + ستون دکمه‌ها؛ بدون جعبه‌های سیاه بزرگ

var fnt: FontFile
var fnt_tiz: FontFile
var fnt_onvan: FontFile
var panel_home: PanelContainer
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
var gerehaye_onvan: Array = []
var _montazere_sahne := false

const PRE_MAGHZ := preload("res://scripts/car_brain.gd")
const PRE_MOSA := preload("res://scripts/race3d.gd")
const PRE_NET := preload("res://scripts/online_race.gd")

const RANG_TALA := Color(0.96, 0.76, 0.25)
const RANG_TALA_KAM := Color(0.72, 0.55, 0.2)
const RANG_GHERMEZ := Color(0.78, 0.15, 0.12)
const RANG_GHERMEZ_TIR := Color(0.45, 0.08, 0.06)
const RANG_SHISHE := Color(0.055, 0.065, 0.10, 0.94)
const RANG_KERM := Color(0.95, 0.93, 0.88)
# ناحیه امن بالا (استاتوس‌بار گوشی) — هیچ UI مهمی بالای این خط
const MARZ_BALA := 46.0

func _khandane_amn(masir: String) -> Resource:
        # منبع نبودن یا خرابی هرگز منو را نمی‌شکند
        if masir == null or not ResourceLoader.exists(masir):
                return null
        return load(masir)

func _fnt_amn(masir: String) -> FontFile:
        var r := _khandane_amn(masir)
        if r is FontFile:
                return r
        return null

func _ready() -> void:
        # قفل LTR — ضدآینه‌شدن چیدمان روی گوشی فارسی
        layout_direction = Control.LAYOUT_DIRECTION_LTR
        fnt = _fnt_amn("res://assets/fonts/Vazirmatn-Regular.ttf")
        fnt_tiz = _fnt_amn("res://assets/fonts/Vazirmatn-Bold.ttf")
        fnt_onvan = _fnt_amn("res://assets/fonts/Lalezar-Regular.ttf")
        _zamine_besaz()
        _rabet_besaz()
        _taze_sazi()
        Seda.ahang_baz()
        call_deferred("_maghze_shahr")
        var arg_line := OS.get_cmdline_user_args()
        # چرخه کامل تست: برگشت از پنل پایان مسابقه به منو
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
        if arg_line.has("--panels"):
                _azm_panilha()
        if arg_line.has("--onlinetest"):
                _azm_anlan()
        if arg_line.has("--autotest"):
                _azm_khodkar()

# عکس از هر دو پنل راهنما و درباره ما — جایی بیرون کادر نماند
func _azm_panilha() -> void:
        await get_tree().create_timer(1.0).timeout
        _neshon_bede(panel_rahnama)
        await get_tree().create_timer(0.5).timeout
        _aks("/home/z/my-project/scripts/shot_rahnama.png")
        _neshon_bede(panel_darbare)
        await get_tree().create_timer(0.5).timeout
        _aks("/home/z/my-project/scripts/shot_darbare.png")
        print("[tizpa][panels] RAHNAMA+DARBARE OK")
        get_tree().quit()

func _azm_khodkar() -> void:
        await get_tree().create_timer(1.2).timeout
        _aks("/home/z/my-project/scripts/shot_menu.png")
        if dokme_bazi == null or not is_instance_valid(dokme_bazi):
                print("[tizpa][autotest] TAP-PLAY FAIL (no button)")
                get_tree().quit(1)
                return
        print("[tizpa][autotest] play_btn rect=", dokme_bazi.get_global_rect(), " visible=", dokme_bazi.visible)
        print("[tizpa][autotest] viewport=", get_viewport().get_visible_rect().size, " window=", DisplayServer.window_get_size())
        _lamse(dokme_bazi)
        await get_tree().create_timer(0.7).timeout
        var ok := panel_marhaleha != null and panel_marhaleha.visible
        print("[tizpa][autotest] TAP-PLAY ", "OK" if ok else "FAIL")
        _aks("/home/z/my-project/scripts/shot_levels.png")
        if not ok:
                get_tree().quit(1)
                return
        if dokme_bargasht != null and is_instance_valid(dokme_bargasht):
                _lamse(dokme_bargasht)
                await get_tree().create_timer(0.5).timeout
                print("[tizpa][autotest] TAP-BACK ", "OK" if panel_home.visible else "FAIL")
        if khaneye_aval == null or not is_instance_valid(khaneye_aval):
                print("[tizpa][autotest] TAP-LEVEL FAIL (no tile)")
                get_tree().quit(1)
                return
        _lamse(dokme_bazi)
        await get_tree().create_timer(0.5).timeout
        _lamse(khaneye_aval)
        _montazere_sahne = true
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

# ═══════════════════ خانه ═══════════════════
func _zamine_besaz() -> void:
        var teks := _khandane_amn("res://assets/sprites/menu_bg.webp")
        if teks == null:
                var gt := GradientTexture2D.new()
                var g := Gradient.new()
                g.offsets = PackedFloat32Array([0.0, 0.6, 1.0])
                g.colors = PackedColorArray([Color(0.05, 0.07, 0.13), Color(0.03, 0.04, 0.08), Color(0.02, 0.02, 0.04)])
                gt.gradient = g
                gt.fill_from = Vector2(0.3, 0.0)
                gt.fill_to = Vector2(0.7, 1.0)
                teks = gt
        var paszamine := TextureRect.new()
        paszamine.texture = teks
        paszamine.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        paszamine.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
        paszamine.set_anchors_preset(Control.PRESET_FULL_RECT)
        paszamine.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(paszamine)
        # گرادیان تیره‌ی بالا برای تیتر
        var gt2 := GradientTexture2D.new()
        var g2 := Gradient.new()
        g2.offsets = PackedFloat32Array([0.0, 1.0])
        g2.colors = PackedColorArray([Color(0.02, 0.03, 0.05, 0.72), Color(0, 0, 0, 0.0)])
        gt2.gradient = g2
        gt2.fill_from = Vector2(0, 0)
        gt2.fill_to = Vector2(0, 1)
        var tr := TextureRect.new()
        tr.texture = gt2
        tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        tr.stretch_mode = TextureRect.STRETCH_SCALE
        tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
        tr.anchor_left = 0.0
        tr.anchor_right = 1.0
        tr.anchor_top = 0.0
        tr.anchor_bottom = 0.30
        add_child(tr)

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
                normal = _sb(RANG_GHERMEZ, RANG_GHERMEZ_TIR, 14, 3)
                ru_hashie = _sb(RANG_GHERMEZ.lightened(0.10), RANG_GHERMEZ_TIR, 14, 3)
                feshorde = _sb(RANG_GHERMEZ_TIR, RANG_GHERMEZ_TIR, 14, 3)
                qeyrfaal = _sb(Color(0.35, 0.2, 0.18), Color(0.3, 0.16, 0.14), 14, 3)
                fg = Color(1, 0.96, 0.9)
        elif kind == "dark":
                normal = _sb(Color(0.10, 0.11, 0.15, 0.92), RANG_TALA_KAM, 14, 2)
                ru_hashie = _sb(Color(0.16, 0.17, 0.22, 0.95), RANG_TALA, 14, 2)
                feshorde = _sb(Color(0.07, 0.08, 0.11, 0.95), RANG_TALA_KAM, 14, 2)
                qeyrfaal = _sb(Color(0.12, 0.13, 0.16, 0.9), Color(0.25, 0.25, 0.28), 14, 2)
                fg = Color(0.98, 0.92, 0.72)
        else:
                normal = _sb(Color(0.13, 0.15, 0.19, 0.85), Color(0.32, 0.34, 0.38), 12, 1, false)
                ru_hashie = _sb(Color(0.20, 0.23, 0.28, 0.9), RANG_TALA_KAM, 12, 1, false)
                feshorde = _sb(Color(0.08, 0.09, 0.12, 0.9), Color(0.3, 0.32, 0.35), 12, 1, false)
                qeyrfaal = _sb(Color(0.12, 0.13, 0.16, 0.8), Color(0.21, 0.215, 0.22), 12, 1, false)
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
        b.custom_minimum_size = Vector2(300, h)
        _dokme_shekl(b, kind)
        return b

func _rabet_besaz() -> void:
        _onvan_besaz()
        _kahrome_pool()
        _hero_besaz()
        _setune_dokmeha()
        _panele_marhaleha_besaz()
        _panele_etelaat_besaz()
        _neshon_bede(panel_home)

# تیتر وسط بالا — همیشه کامل داخل کادر
func _onvan_besaz() -> void:
        var onvan := _matn_besaz("تیز پا", 88, false, true, Color(1.0, 0.87, 0.42))
        onvan.add_theme_color_override("font_outline_color", Color(0.10, 0.04, 0.02))
        onvan.add_theme_constant_override("outline_size", 14)
        onvan.anchor_left = 0.0
        onvan.anchor_right = 1.0
        onvan.offset_top = MARZ_BALA
        onvan.offset_bottom = MARZ_BALA + 108
        onvan.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        add_child(onvan)
        gerehaye_onvan.append(onvan)
        var matne_zir := _matn_besaz("مسابقه‌ی خیابانی تهران  •  پنج مرحله  •  یک قهرمان", 22, true, false, Color(0.94, 0.92, 0.88, 0.95))
        matne_zir.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
        matne_zir.add_theme_constant_override("outline_size", 6)
        matne_zir.anchor_left = 0.0
        matne_zir.anchor_right = 1.0
        matne_zir.offset_top = MARZ_BALA + 112
        matne_zir.offset_bottom = MARZ_BALA + 146
        matne_zir.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        add_child(matne_zir)
        gerehaye_onvan.append(matne_zir)

# چیپ سکه — گوشه بالا-چپ، کوچک و بی‌آزار
func _kahrome_pool() -> void:
        var qabze_chip := PanelContainer.new()
        qabze_chip.add_theme_stylebox_override("panel", _sb(Color(0.05, 0.06, 0.09, 0.85), RANG_TALA_KAM, 20, 1, false))
        qabze_chip.anchor_left = 0.0
        qabze_chip.anchor_right = 0.0
        qabze_chip.offset_left = 18
        qabze_chip.offset_right = 158
        qabze_chip.offset_top = MARZ_BALA + 4
        qabze_chip.offset_bottom = MARZ_BALA + 52
        var hb := HBoxContainer.new()
        hb.add_theme_constant_override("separation", 8)
        hb.alignment = BoxContainer.ALIGNMENT_CENTER
        qabze_chip.add_child(hb)
        var teks_pool := _khandane_amn("res://assets/sprites/coin.png")
        if teks_pool != null:
                var neshane_pool := TextureRect.new()
                neshane_pool.texture = teks_pool
                neshane_pool.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
                neshane_pool.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
                neshane_pool.custom_minimum_size = Vector2(28, 28)
                neshane_pool.size_flags_vertical = Control.SIZE_SHRINK_CENTER
                hb.add_child(neshane_pool)
        matne_pool = _matn_besaz(str(Koli.pool), 22, true, false, RANG_TALA)
        matne_pool.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        matne_pool.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
        hb.add_child(matne_pool)
        add_child(qabze_chip)
        gerehaye_onvan.append(qabze_chip)

# کارت ماشین — سمت چپ، لبه‌های محو داخل خودِ عکس
func _hero_besaz() -> void:
        var teks_hero := _khandane_amn("res://assets/sprites/menu_hero.webp")
        if teks_hero == null:
                return
        var ghahreman := TextureRect.new()
        ghahreman.texture = teks_hero
        ghahreman.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        ghahreman.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        ghahreman.anchor_left = 0.01
        ghahreman.anchor_right = 0.60
        ghahreman.anchor_top = 0.30
        ghahreman.anchor_bottom = 0.98
        ghahreman.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(ghahreman)
        mashinaye_shahr.append(ghahreman)

# ستون دکمه‌ها — سمت راست، شیشه‌ایِ نازک پشتشان
func _setune_dokmeha() -> void:
        panel_home = PanelContainer.new()
        panel_home.add_theme_stylebox_override("panel", _sb(Color(0.04, 0.05, 0.08, 0.55), Color(0.85, 0.68, 0.28, 0.28), 20, 1, false))
        panel_home.anchor_left = 0.62
        panel_home.anchor_right = 0.965
        panel_home.anchor_top = 0.30
        panel_home.anchor_bottom = 0.965
        panel_home.offset_top = 6.0
        var mv := MarginContainer.new()
        mv.add_theme_constant_override("margin_left", 14)
        mv.add_theme_constant_override("margin_right", 14)
        mv.add_theme_constant_override("margin_top", 12)
        mv.add_theme_constant_override("margin_bottom", 12)
        panel_home.add_child(mv)
        var hb := VBoxContainer.new()
        hb.add_theme_constant_override("separation", 10)
        hb.alignment = BoxContainer.ALIGNMENT_CENTER
        mv.add_child(hb)

        var dokme_mosabeqe := _dokme_besaz("مسابقه", 38, "red", 92)
        dokme_mosabeqe.pressed.connect(_mosabeqe_sari)
        dokme_mosabeqe.size_flags_vertical = Control.SIZE_EXPAND_FILL
        hb.add_child(dokme_mosabeqe)

        var dokme_shoroo := _dokme_besaz("مراحل", 26, "dark", 76)
        dokme_shoroo.pressed.connect(func(): _neshon_bede(panel_marhaleha))
        dokme_bazi = dokme_shoroo
        dokme_shoroo.size_flags_vertical = Control.SIZE_EXPAND_FILL
        hb.add_child(dokme_shoroo)

        var dokme_garaj := _dokme_besaz("کارگاه", 26, "dark", 76)
        dokme_garaj.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/garage.tscn"))
        dokme_garaj.size_flags_vertical = Control.SIZE_EXPAND_FILL
        hb.add_child(dokme_garaj)

        var dokme_zendegi := _dokme_besaz("زندگی محله", 24, "dark", 64)
        dokme_zendegi.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/story.tscn"))
        hb.add_child(dokme_zendegi)

        var satr_paein := HBoxContainer.new()
        satr_paein.add_theme_constant_override("separation", 10)
        var dokme_rahnama := _dokme_besaz("راهنمای بازی", 21, "flat", 56)
        dokme_rahnama.custom_minimum_size = Vector2(0, 56)
        dokme_rahnama.pressed.connect(func(): _neshon_bede(panel_rahnama))
        dokme_rahnama.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        satr_paein.add_child(dokme_rahnama)
        var dokme_darbare := _dokme_besaz("درباره ما", 21, "flat", 56)
        dokme_darbare.custom_minimum_size = Vector2(0, 56)
        dokme_darbare.pressed.connect(func(): _neshon_bede(panel_darbare))
        dokme_darbare.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        satr_paein.add_child(dokme_darbare)
        hb.add_child(satr_paein)
        add_child(panel_home)

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

# ═══════════════════ مأموریت‌ها ═══════════════════
func _panele_marhaleha_besaz() -> void:
        var posht := ColorRect.new()
        posht.color = Color(0, 0, 0, 0.55)
        posht.set_anchors_preset(Control.PRESET_FULL_RECT)
        add_child(posht)
        panel_marhaleha = PanelContainer.new()
        var skrole_marhaleha := _sb(Color(0.07, 0.08, 0.12, 0.97), Color(0.85, 0.68, 0.28, 0.55), 20, 2)
        skrole_marhaleha.content_margin_left = 20.0
        skrole_marhaleha.content_margin_right = 20.0
        skrole_marhaleha.content_margin_top = 14.0
        skrole_marhaleha.content_margin_bottom = 14.0
        panel_marhaleha.add_theme_stylebox_override("panel", skrole_marhaleha)
        # قاب کشسان — روی هر صفحه‌ای داخل کادر می‌ماند
        panel_marhaleha.anchor_left = 0.03
        panel_marhaleha.anchor_right = 0.97
        panel_marhaleha.anchor_top = 0.075
        panel_marhaleha.anchor_bottom = 0.925
        panel_marhaleha.offset_left = 0.0
        panel_marhaleha.offset_right = 0.0
        panel_marhaleha.offset_top = 0.0
        panel_marhaleha.offset_bottom = 0.0
        var marhale := VBoxContainer.new()
        marhale.add_theme_constant_override("separation", 10)
        panel_marhaleha.add_child(marhale)
        # هدر: هلیا — راننده‌ی تیز پا
        var sar := HBoxContainer.new()
        sar.add_theme_constant_override("separation", 14)
        var helia := TextureRect.new()
        helia.texture = _khandane_amn("res://assets/sprites/helia_portrait.webp")
        if helia.texture != null:
                helia.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
                helia.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
                helia.custom_minimum_size = Vector2(78, 96)
                sar.add_child(helia)
        var ak := VBoxContainer.new()
        ak.add_theme_constant_override("separation", 2)
        # RTL: راست‌چین + EXPAND_FILL تا عرض کم نیاید
        ak.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        var esme_helia := _matn_besaz("هلیا — راننده‌ی تیز پا", 26, false, true, RANG_TALA)
        esme_helia.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        esme_helia.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        ak.add_child(esme_helia)
        var jomle_helia := _matn_besaz("پنج مرحله، یک هدف: خط پایان از جلو!", 19, true, false, RANG_KERM)
        jomle_helia.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        jomle_helia.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        jomle_helia.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
        jomle_helia.add_theme_constant_override("outline_size", 5)
        ak.add_child(jomle_helia)
        sar.add_child(ak)
        marhale.add_child(sar)
        var skrol := ScrollContainer.new()
        skrol.size_flags_vertical = Control.SIZE_EXPAND_FILL
        skrol.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
        var shabake := GridContainer.new()
        shabake.columns = 3
        shabake.add_theme_constant_override("h_separation", 12)
        shabake.add_theme_constant_override("v_separation", 12)
        for lv_def in PRE_MOSA.MARHALEHA:
                var id: int = int(lv_def["id"])
                var st: int = Koli.setare_marhale.get(id, 0)
                var bazshode: bool = Koli.marhale_bazshode(id)
                var b := Button.new()
                b.custom_minimum_size = Vector2(370, 116)
                b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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
                shomare.add_theme_font_size_override("font_size", 30)
                shomare.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
                shomare.add_theme_color_override("font_color", RANG_KERM if bazshode else Color(0.55, 0.53, 0.50))
                shomare.mouse_filter = Control.MOUSE_FILTER_IGNORE
                vb.add_child(shomare)
                var tozih := Label.new()
                tozih.text = str(lv_def["desc"]) if bazshode else "با قهرمانی در مرحله‌ی قبل باز می‌شود"
                if fnt_tiz != null:
                        tozih.add_theme_font_override("font", fnt_tiz)
                tozih.add_theme_font_size_override("font_size", 15)
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
                setareha.add_theme_font_size_override("font_size", 17)
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
        var dokme_bargasht1 := _dokme_besaz(Koli.tarjome("back"), 26, "dark", 64)
        dokme_bargasht1.pressed.connect(func(): _neshon_bede(panel_home))
        dokme_bargasht = dokme_bargasht1
        marhale.add_child(dokme_bargasht1)
        add_child(panel_marhaleha)
        panel_marhaleha.visible = false
        posht.visible = false
        panel_marhaleha.set_meta("posht", posht)

func _maghze_shahr() -> void:
        maghz = PRE_MAGHZ.new()
        add_child(maghz)

# ═════════════ راهنما و درباره ما ═════════════
func _panele_etelaat_besaz() -> void:
        # راهنمای بازی — هرچه راننده‌ی تازه لازم دارد
        var posht1 := ColorRect.new()
        posht1.color = Color(0, 0, 0, 0.55)
        posht1.set_anchors_preset(Control.PRESET_FULL_RECT)
        add_child(posht1)
        panel_rahnama = PanelContainer.new()
        var gs := _sb(Color(0.07, 0.08, 0.12, 0.97), Color(0.85, 0.68, 0.28, 0.55), 20, 2)
        gs.content_margin_left = 26.0
        gs.content_margin_right = 26.0
        gs.content_margin_top = 16.0
        gs.content_margin_bottom = 16.0
        panel_rahnama.add_theme_stylebox_override("panel", gs)
        panel_rahnama.anchor_left = 0.10
        panel_rahnama.anchor_right = 0.90
        panel_rahnama.anchor_top = 0.10
        panel_rahnama.anchor_bottom = 0.90
        var gv := VBoxContainer.new()
        gv.add_theme_constant_override("separation", 10)
        panel_rahnama.add_child(gv)
        var gt := _matn_besaz("راهنمای بازی", 42, false, true, RANG_TALA)
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
                var rl := _matn_besaz("•  " + ln, 21, true, false, RANG_KERM)
                rl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
                rl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
                rl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
                gv.add_child(rl)
        var gb := _dokme_besaz(Koli.tarjome("back"), 26, "dark", 64)
        gb.pressed.connect(func(): _neshon_bede(panel_home))
        gv.add_child(gb)
        add_child(panel_rahnama)
        panel_rahnama.visible = false
        posht1.visible = false
        panel_rahnama.set_meta("posht", posht1)

        # درباره ما — جای خالی؛ بعداً متن نهایی اینجا می‌نشیند
        var posht2 := ColorRect.new()
        posht2.color = Color(0, 0, 0, 0.55)
        posht2.set_anchors_preset(Control.PRESET_FULL_RECT)
        add_child(posht2)
        panel_darbare = PanelContainer.new()
        var asb := _sb(Color(0.07, 0.08, 0.12, 0.97), Color(0.85, 0.68, 0.28, 0.55), 20, 2)
        asb.content_margin_top = 18.0
        asb.content_margin_bottom = 18.0
        panel_darbare.add_theme_stylebox_override("panel", asb)
        panel_darbare.anchor_left = 0.16
        panel_darbare.anchor_right = 0.84
        panel_darbare.anchor_top = 0.24
        panel_darbare.anchor_bottom = 0.72
        var av := VBoxContainer.new()
        av.add_theme_constant_override("separation", 14)
        av.alignment = BoxContainer.ALIGNMENT_CENTER
        panel_darbare.add_child(av)
        var at := _matn_besaz("درباره ما", 42, false, true, RANG_TALA)
        at.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        at.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        av.add_child(at)
        var ab := _dokme_besaz(Koli.tarjome("back"), 26, "dark", 64)
        ab.pressed.connect(func(): _neshon_bede(panel_home))
        av.add_child(ab)
        add_child(panel_darbare)
        panel_darbare.visible = false
        posht2.visible = false
        panel_darbare.set_meta("posht", posht2)

func _neshon_bede(p: PanelContainer) -> void:
        if panel_home == null or panel_marhaleha == null:
                return
        for pc in [panel_home, panel_marhaleha, panel_rahnama, panel_darbare]:
                if pc == null or not is_instance_valid(pc):
                        continue
                pc.visible = pc == p
                if pc.has_meta("posht"):
                        var posht: Control = pc.get_meta("posht")
                        if posht != null and is_instance_valid(posht):
                                posht.visible = pc == p and pc != panel_home
        # تیتر و چیپ فقط مال خانه
        for n in gerehaye_onvan:
                if is_instance_valid(n):
                        n.visible = p == panel_home
        for n in mashinaye_shahr:
                if is_instance_valid(n):
                        n.visible = p == panel_home
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
