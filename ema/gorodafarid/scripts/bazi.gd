extends Node2D
# «گردآفرید» — پلتفرمر نبردِ شاهنامه‌ای
# هلیا در نقشِ گردآفرید: شمشیر و کمان و اسب، سربازانِ توران و دیوان،
# و سرانجام دیوسپیدِ گردِ دژِ سپید
# سبک: نگارگریِ ایرانیِ مدرن — هنرهای ساخته‌شده با هوش مصنوعی + پارالاکس زنده

const SK_HELIA := preload("res://scripts/helia.gd")
const SK_DOSHMAN := preload("res://scripts/doshman.gd")

const TOL := 8600.0
const AKS_DIR := "/home/z/my-project/ema/gorodafarid/aks/"

# ── دادهٔ جهان ──
var sath_ha := [
        {"x0": 0.0, "x1": 1400.0, "y": 640.0},
        {"x0": 1500.0, "x1": 2400.0, "y": 600.0},
        {"x0": 2520.0, "x1": 3300.0, "y": 640.0},
        {"x0": 3420.0, "x1": 4000.0, "y": 560.0},
        {"x0": 4120.0, "x1": 4900.0, "y": 640.0},
        {"x0": 5020.0, "x1": 5700.0, "y": 600.0},
        {"x0": 5820.0, "x1": 8600.0, "y": 640.0},
]
var zin_ha := [
        {"x0": 2100.0, "x1": 2340.0, "y": 470.0},
        {"x0": 2900.0, "x1": 3140.0, "y": 500.0},
        {"x0": 3660.0, "x1": 3900.0, "y": 420.0},
        {"x0": 4450.0, "x1": 4690.0, "y": 500.0},
        {"x0": 5380.0, "x1": 5620.0, "y": 460.0},
        {"x0": 6600.0, "x1": 6900.0, "y": 480.0},
]
var ja_sarbaz := [1750.0, 2100.0, 2750.0, 4400.0]
var ja_div := [3700.0, 5350.0]
var ja_kuchak := [1150.0, 2350.0, 3150.0, 4560.0, 5600.0]
var ja_bos := 7750.0
var ja_asb_ha := [Vector2(300, 600), Vector2(4750, 600)]
var ja_enar_ha := [Vector2(1100, 560), Vector2(2220, 430), Vector2(3780, 380),
        Vector2(5060, 560), Vector2(6750, 440), Vector2(6220, 580)]
var ja_chekpoint := [Vector2(140, 560), Vector2(3480, 500), Vector2(5880, 560)]
var ja_atesh_ha := [700.0, 2600.0, 4600.0, 6100.0, 7150.0]
var ja_senobar := [500.0, 1900.0, 3050.0, 4300.0, 5550.0, 6450.0, 7050.0]
var navarti := [1340.0, 2340.0, 3240.0, 3940.0, 4840.0, 5640.0]

# ── وضعیت ──
var helia
var doshman_ha := []
var bos = null
var asb_ha := []
var enar_ha := []
var tir_ha := []
var sang_ha := []
var mowj_ha := []
var pop_ha := []
var dorbin: Camera2D
var halat_bazi := "onvan"        # onvan | bazi | shekast | bord
var joon_helia := 5
var shmar_kosh := 0
var chekpoint_idx := 0
var zaman := 0.0
var zaman_bazi := 0.0
var zaman_payam := 0.0
var lershe := 0.0
var bos_faal_shod := false
var dargah_vaz := false
var khod_peyma := false
var halat_film := false
var zaman_film := 0.0
var maks_x_film := 0.0            # دورترین x که در فیلم رسیده
var zaman_pishraft_film := 0.0    # زمانِ بدونِ پیشرفت
var zaman_duel_film := 0.0        # شمارندهٔ ضربه‌های دوئلِ فیلم
var zaman_bord := 0.0
var zaman_asb_akhar := -20.0      # آخرین بار که اسبِ تازه سبز شد
var zaman_gir_oftade := 0.0      # برای فرارِ خلبان از گیر

var vorudi := {"chap": 0.0, "rast": 0.0, "parsh": false, "shemshir": false, "kaman": false, "savari": false}
var vorudi_ai := {"chap": 0.0, "rast": 0.0, "parsh": false, "shemshir": false, "kaman": false, "savari": false}
var zaman_tir_ai := 0.0

# ── هنر و صدا ──
var tex_kash: Texture2D
var tex_enar: Texture2D
var fnt_lalezar: FontFile
var fnt_vazir: FontFile
var seda_ha := {}
var seda_pakhshkon_ha := []
var seda_idx := 0

# ── HUD ──
var laye_hud: CanvasLayer
var del_ha := []
var lbl_kosh: Label
var lbl_payam: Label
var lbl_zirpayam: Label
var bos_ghab: ColorRect
var bos_por: ColorRect
var btn_chap: TouchScreenButton
var btn_rast: TouchScreenButton
var btn_parsh: TouchScreenButton
var btn_shemshir: TouchScreenButton
var btn_kaman: TouchScreenButton
var btn_savari: TouchScreenButton

func _ready() -> void:
        var argh := OS.get_cmdline_user_args()
        khod_peyma = argh.has("--aks") or argh.has("--film")
        halat_film = argh.has("--film")
        tex_kash = load("res://assets/honar/kash.png")
        tex_enar = load("res://assets/honar/enar.png")
        fnt_lalezar = load("res://assets/fonts/Lalezar-Regular.ttf")
        fnt_vazir = load("res://assets/fonts/Vazirmatn-Bold.ttf")
        texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
        sakht_paralaks()
        sakht_sath_ha()
        sakht_tazinh()
        sakht_doshmanan()
        sakht_asb_ha()
        sakht_enar_ha()
        sakht_helia()
        sakht_dorbin()
        sakht_seda()
        sakht_hud()
        moseghi()
        payam("گردآفرید", "دلاورِ دژِ سپید — شمشیر، کمان، اسب", 3.0)

# ═══════════════ ساختِ جهان ═══════════════

func sakht_paralaks() -> void:
        var pa := ParallaxBackground.new()
        add_child(pa)
        # آسمانِ غروب — دورترین
        var l1 := ParallaxLayer.new()
        l1.motion_scale = Vector2(0.04, 0.02)
        pa.add_child(l1)
        var s1 := Sprite2D.new()
        s1.texture = load("res://assets/honar/aseman.png")
        s1.centered = false
        s1.scale = Vector2(1.25, 1.75)
        s1.position = Vector2(0, -160)
        l1.add_child(s1)
        l1.motion_mirroring = Vector2(1344.0 * 1.25, 0)
        # کوهِ البرز و دژِ سپید
        var l2 := ParallaxLayer.new()
        l2.motion_scale = Vector2(0.14, 0.05)
        pa.add_child(l2)
        var s2 := Sprite2D.new()
        s2.texture = load("res://assets/honar/kuh.png")
        s2.centered = false
        s2.scale = Vector2(1.25, 0.78)
        s2.position = Vector2(0, 60)
        l2.add_child(s2)
        l2.motion_mirroring = Vector2(1344.0 * 1.25, 0)
        # شهرِ باستانی — نزدیک‌ترین
        var l3 := ParallaxLayer.new()
        l3.motion_scale = Vector2(0.36, 0.08)
        pa.add_child(l3)
        var s3 := Sprite2D.new()
        s3.texture = load("res://assets/honar/shahr.png")
        s3.centered = false
        s3.scale = Vector2(1.25, 0.6)
        s3.position = Vector2(0, 235)
        l3.add_child(s3)
        l3.motion_mirroring = Vector2(1344.0 * 1.25, 0)

func sakht_sath_ha() -> void:
        for s in sath_ha:
                var tan := StaticBody2D.new()
                tan.position = Vector2((s.x0 + s.x1) * 0.5, s.y + 200.0)
                var shekl := CollisionShape2D.new()
                var mostatil := RectangleShape2D.new()
                mostatil.size = Vector2(s.x1 - s.x0, 400.0)
                shekl.shape = mostatil
                tan.add_child(shekl)
                add_child(tan)
        for z in zin_ha:
                var tan := StaticBody2D.new()
                tan.position = Vector2((z.x0 + z.x1) * 0.5, z.y + 23.0)
                var shekl := CollisionShape2D.new()
                var mostatil := RectangleShape2D.new()
                mostatil.size = Vector2(z.x1 - z.x0, 46.0)
                shekl.shape = mostatil
                shekl.one_way_collision = true
                tan.add_child(shekl)
                add_child(tan)
        # دیوارهای دو سرِ جهان
        for d in [[-30.0, 360.0], [TOL + 30.0, 360.0]]:
                var tan := StaticBody2D.new()
                tan.position = Vector2(d[0], 300.0)
                var shekl := CollisionShape2D.new()
                var mostatil := RectangleShape2D.new()
                mostatil.size = Vector2(60.0, 1400.0)
                shekl.shape = mostatil
                tan.add_child(shekl)
                add_child(tan)
        # دروازهٔ دژ — تا بوس نمرده بسته است
        var divar := StaticBody2D.new()
        divar.name = "divar_dargah"
        divar.position = Vector2(8470.0, 300.0)
        var shekl2 := CollisionShape2D.new()
        var mostatil2 := RectangleShape2D.new()
        mostatil2.size = Vector2(90.0, 1400.0)
        shekl2.shape = mostatil2
        divar.add_child(shekl2)
        add_child(divar)

func sakht_tazinh() -> void:
        # سروهای نگارگری در پس‌زمینه
        for x in ja_senobar:
                var s := Sprite2D.new()
                s.texture = load("res://assets/honar/senobar.png")
                s.scale = Vector2(0.6, 0.6)
                s.position = Vector2(x, zamin_y_at(x) - s.texture.get_height() * 0.6 * 0.5 + 8.0)
                s.modulate = Color(1, 1, 1, 0.85)
                s.z_index = -2
                add_child(s)
        # دروازهٔ دژ در پایان
        var dargah := Sprite2D.new()
        dargah.name = "dargah"
        dargah.texture = load("res://assets/honar/dargah.png")
        dargah.scale = Vector2(0.72, 0.72)
        dargah.position = Vector2(8520.0, 640.0 - dargah.texture.get_height() * 0.72 * 0.5 + 10.0)
        dargah.z_index = -1
        add_child(dargah)
        # آتش‌بازوهای اردوگاه
        for x in ja_atesh_ha:
                var atesh := CPUParticles2D.new()
                atesh.amount = 16
                atesh.lifetime = 0.7
                atesh.position = Vector2(x, zamin_y_at(x) - 78.0)
                atesh.direction = Vector2(0, -1)
                atesh.spread = 16.0
                atesh.initial_velocity_min = 60.0
                atesh.initial_velocity_max = 140.0
                atesh.gravity = Vector2(0, -60)
                atesh.scale_amount_min = 3.0
                atesh.scale_amount_max = 7.0
                atesh.color = Color(1.0, 0.62, 0.22, 0.85)
                add_child(atesh)

func sakht_doshmanan() -> void:
        for x in ja_sarbaz:
                besaz("sarbaz", Vector2(x, zamin_y_at(x) - 60.0))
        for x in ja_div:
                besaz("div", Vector2(x, zamin_y_at(x) - 80.0))
        for x in ja_kuchak:
                besaz("kuchak", Vector2(x, zamin_y_at(x) - 50.0))
        bos = besaz("div_sefid", Vector2(ja_bos, zamin_y_at(ja_bos) - 130.0))

func besaz(noe: String, ja: Vector2):
        var d = SK_DOSHMAN.new()
        d.noe = noe
        d.bazi = self
        d.position = ja
        add_child(d)
        doshman_ha.append(d)
        return d

func sakht_asb_ha() -> void:
        for ja in ja_asb_ha:
                var a := Sprite2D.new()
                a.texture = load("res://assets/honar/asb.png")
                a.scale = Vector2(0.56, 0.56)
                a.position = Vector2(ja.x, zamin_y_at(ja.x) - a.texture.get_height() * 0.56 * 0.5 + 6.0)
                add_child(a)
                asb_ha.append(a)

func sakht_enar_ha() -> void:
        for ja in ja_enar_ha:
                var e := Sprite2D.new()
                e.texture = tex_enar
                e.scale = Vector2(0.55, 0.55)
                e.position = ja
                add_child(e)
                enar_ha.append(e)

func sakht_helia() -> void:
        helia = SK_HELIA.new()
        helia.bazi = self
        helia.khod_peyma = khod_peyma
        helia.position = Vector2(140, 560)
        add_child(helia)

func sakht_dorbin() -> void:
        dorbin = Camera2D.new()
        dorbin.position_smoothing_enabled = true
        dorbin.position_smoothing_speed = 5.5
        dorbin.limit_left = 0
        dorbin.limit_right = int(TOL)
        dorbin.limit_bottom = 860
        dorbin.limit_top = -560
        dorbin.offset = Vector2(0, -170)
        add_child(dorbin)

func moseghi() -> void:
        var p := AudioStreamPlayer.new()
        var moosiqi: AudioStreamWAV = load("res://assets/audio/moeini.wav")
        moosiqi.loop_mode = AudioStreamWAV.LOOP_FORWARD
        moosiqi.loop_begin = 0
        moosiqi.loop_end = moosiqi.data.size() / 2
        p.stream = moosiqi
        p.volume_db = -13.0
        p.autoplay = true
        add_child(p)
        p.play()

func sakht_seda() -> void:
        for nam in ["shemshir", "tir", "zadakhor", "kling", "parsh", "enar", "savari", "sam", "gharjar", "piroozi", "shekast", "istgah"]:
                seda_ha[nam] = load("res://assets/audio/" + nam + ".wav")
        for i in 10:
                var p := AudioStreamPlayer.new()
                add_child(p)
                seda_pakhshkon_ha.append(p)

func seda(nam: String, db := 0.0) -> void:
        if not seda_ha.has(nam):
                return
        var p: AudioStreamPlayer = seda_pakhshkon_ha[seda_idx]
        seda_idx = (seda_idx + 1) % seda_pakhshkon_ha.size()
        p.stream = seda_ha[nam]
        p.volume_db = db
        p.play()

# ═══════════════ HUD و لمس ═══════════════

func sakht_hud() -> void:
        laye_hud = CanvasLayer.new()
        laye_hud.layer = 10
        add_child(laye_hud)
        # انارهای جان — بالا چپ
        for i in 5:
                var d := TextureRect.new()
                d.texture = tex_enar
                d.custom_minimum_size = Vector2(46, 46)
                d.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
                d.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
                d.position = Vector2(24 + i * 52, 18)
                laye_hud.add_child(d)
                del_ha.append(d)
        # شمارِ دشمنان — بالا راست
        lbl_kosh = Label.new()
        lbl_kosh.text = "دشمنان ۰"
        lbl_kosh.add_theme_font_override("font", fnt_vazir)
        lbl_kosh.add_theme_font_size_override("font_size", 26)
        lbl_kosh.add_theme_color_override("font_color", Color(1.0, 0.9, 0.66))
        lbl_kosh.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
        lbl_kosh.add_theme_constant_override("shadow_offset_x", 2)
        lbl_kosh.add_theme_constant_override("shadow_offset_y", 2)
        lbl_kosh.anchor_left = 1.0
        lbl_kosh.anchor_right = 1.0
        lbl_kosh.offset_left = -230
        lbl_kosh.offset_top = 18
        laye_hud.add_child(lbl_kosh)
        # پیامِ بزرگ و زیرپیام
        lbl_payam = Label.new()
        lbl_payam.add_theme_font_override("font", fnt_lalezar)
        lbl_payam.add_theme_font_size_override("font_size", 72)
        lbl_payam.add_theme_color_override("font_color", Color(1.0, 0.88, 0.55))
        lbl_payam.add_theme_color_override("font_shadow_color", Color(0.25, 0.08, 0.05, 0.85))
        lbl_payam.add_theme_constant_override("shadow_offset_x", 4)
        lbl_payam.add_theme_constant_override("shadow_offset_y", 5)
        lbl_payam.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        lbl_payam.anchor_left = 0.0
        lbl_payam.anchor_right = 1.0
        lbl_payam.offset_top = 170
        laye_hud.add_child(lbl_payam)
        lbl_zirpayam = Label.new()
        lbl_zirpayam.add_theme_font_override("font", fnt_vazir)
        lbl_zirpayam.add_theme_font_size_override("font_size", 27)
        lbl_zirpayam.add_theme_color_override("font_color", Color(1.0, 0.96, 0.9, 0.95))
        lbl_zirpayam.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
        lbl_zirpayam.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        lbl_zirpayam.anchor_left = 0.0
        lbl_zirpayam.anchor_right = 1.0
        lbl_zirpayam.offset_top = 268
        laye_hud.add_child(lbl_zirpayam)
        # نوارِ جونِ دیوسپید
        bos_ghab = ColorRect.new()
        bos_ghab.color = Color(0.08, 0.05, 0.07, 0.72)
        bos_ghab.position = Vector2(410, 640)
        bos_ghab.size = Vector2(460, 22)
        bos_ghab.visible = false
        laye_hud.add_child(bos_ghab)
        bos_por = ColorRect.new()
        bos_por.color = Color(0.85, 0.25, 0.3)
        bos_por.position = Vector2(414, 644)
        bos_por.size = Vector2(452, 14)
        bos_por.visible = false
        laye_hud.add_child(bos_por)
        # دکمه‌های لمسی — فقط روی گوشی دیده می‌شوند
        btn_chap = dokme("dokme_chap", Vector2(60, 586))
        btn_rast = dokme("dokme_rast", Vector2(196, 586))
        btn_parsh = dokme("dokme_parsh", Vector2(1150, 470))
        btn_shemshir = dokme("dokme_shemshir", Vector2(1150, 586))
        btn_kaman = dokme("dokme_kaman", Vector2(1022, 586))
        btn_savari = dokme("dokme_savari", Vector2(890, 586))
        # راهنمای کیبورد
        var lbl_rahnama := Label.new()
        lbl_rahnama.text = "→ حرکت   فاصله پرش   X شمشیر   C کمان   E اسب   R ازنو"
        lbl_rahnama.add_theme_font_override("font", fnt_vazir)
        lbl_rahnama.add_theme_font_size_override("font_size", 17)
        lbl_rahnama.add_theme_color_override("font_color", Color(1, 1, 1, 0.55))
        lbl_rahnama.position = Vector2(24, 680)
        laye_hud.add_child(lbl_rahnama)

func dokme(nam: String, ja: Vector2) -> TouchScreenButton:
        var d := TouchScreenButton.new()
        d.texture_normal = load("res://assets/honar/" + nam + ".png")
        d.position = ja
        d.visibility_mode = TouchScreenButton.VISIBILITY_TOUCHSCREEN_ONLY
        d.modulate = Color(1, 1, 1, 0.62)
        laye_hud.add_child(d)
        return d

# ═══════════════ حلقهٔ بازی ═══════════════

func _physics_process(delta: float) -> void:
        zaman += delta
        if halat_bazi == "onvan" and zaman > 3.0:
                halat_bazi = "bazi"
                zaman_bazi = 0.0
        if halat_bazi == "bazi":
                zaman_bazi += delta
        # ورودیِ ترکیبی: کیبورد + لمس
        vorudi["chap"] = clampf(float(Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A)) + (1.0 if (btn_chap != null and btn_chap.is_pressed()) else 0.0), 0.0, 1.0)
        vorudi["rast"] = clampf(float(Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D)) + (1.0 if (btn_rast != null and btn_rast.is_pressed()) else 0.0), 0.0, 1.0)
        vorudi["parsh"] = Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W) or (btn_parsh != null and btn_parsh.is_pressed())
        vorudi["shemshir"] = Input.is_key_pressed(KEY_X) or Input.is_key_pressed(KEY_J) or (btn_shemshir != null and btn_shemshir.is_pressed())
        vorudi["kaman"] = Input.is_key_pressed(KEY_C) or Input.is_key_pressed(KEY_K) or (btn_kaman != null and btn_kaman.is_pressed())
        vorudi["savari"] = Input.is_key_pressed(KEY_E) or (btn_savari != null and btn_savari.is_pressed())
        if Input.is_key_pressed(KEY_R):
                get_tree().reload_current_scene()
        # خلبانِ خودکار
        if khod_peyma:
                maghz_ai(delta)
        # برخوردِ تن‌به‌تن و لگدِ اسب
        barkhord_ha()
        # پروژه‌یل‌ها
        tir_ha_bor(delta)
        sang_ha_bor(delta)
        mowj_ha_bor(delta)
        # انار و اسب و چک‌پوینت
        jam_avari()
        chekpoint_baresi()
        bos_hoshidar()
        piroozi_baresi()
        pop_ha_bor(delta)
        # دوربین
        var hadaf_dorbin := Vector2(helia.global_position.x + helia.mesh * 130.0, helia.global_position.y - 60.0)
        dorbin.position = dorbin.position.lerp(hadaf_dorbin, 1.0 - pow(0.0015, delta))
        lershe = maxf(0.0, lershe - delta * 26.0)
        dorbin.offset = Vector2(randf_range(-lershe, lershe), randf_range(-lershe, lershe) - 170.0)
        # نوارِ بوس
        if is_instance_valid(bos) and bos.faal and bos.halat != "morde":
                bos_ghab.visible = true
                bos_por.visible = true
                bos_por.size.x = 452.0 * float(bos.joon) / 8.0
        else:
                bos_ghab.visible = false
                bos_por.visible = false
        # پیام‌ها
        zaman_payam = maxf(0.0, zaman_payam - delta)
        if zaman_payam <= 0.0:
                lbl_payam.text = ""
                lbl_zirpayam.text = ""
        # پایان‌ها
        if halat_bazi == "bord":
                zaman_bord += delta
                if int(zaman_bord * 2.0) != int((zaman_bord - delta) * 2.0):
                        konfeti(helia.global_position + Vector2(randf_range(-260, 260), -randf_range(60, 220)))
        # حالتِ فیلم
        if halat_film:
                zaman_film += delta
                # پیش‌برندهٔ تضمینی: اگر ۱۴ ثانیه جلو نرفت، ۴۲۰ پیکسل جلوتر ببر
                if helia.global_position.x > maks_x_film:
                        maks_x_film = helia.global_position.x
                        zaman_pishraft_film = 0.0
                elif halat_bazi == "bazi":
                        zaman_pishraft_film += delta
                        if zaman_pishraft_film > 14.0 and maks_x_film < 6800.0:
                                if helia.savar:
                                        helia.savar = false
                                        asb_rahayi()
                                var jx_film: float = maks_x_film + 420.0
                                var gy_film: float = zamin_y_at(jx_film)
                                if gy_film > 940.0:
                                        gy_film = helia.global_position.y
                                helia.global_position = Vector2(jx_film, gy_film - 90.0)
                                helia.velocity = Vector2.ZERO
                                helia.zaman_zakhmi = 1.5
                                maks_x_film = jx_film
                                zaman_pishraft_film = 0.0
                # کمکِ دوئل در فیلم: ضربه‌های گردآفرید همیشه به دیوسپید می‌نشیند
                if maks_x_film > 7300.0 and is_instance_valid(bos) and bos.halat != "morde":
                        zaman_duel_film += delta
                        if zaman_duel_film > 1.2:
                                zaman_duel_film = 0.0
                                bos.zarbe(1)
                film_tarikhche()
                # اسبِ تازه — تا هلیا در فیلم همیشه سواره بتازد
                if not helia.savar and helia.halat == "doid" and zaman - zaman_asb_akhar > 5.0:
                        var asb_zende := false
                        for a2 in asb_ha:
                                if is_instance_valid(a2) and a2.modulate.a > 0.9 and not a2.get_meta("raft", false):
                                        asb_zende = true
                        if not asb_zende:
                                var jax: float = helia.global_position.x + 560.0
                                var gy: float = zamin_y_at(jax)
                                if gy > 940.0:
                                        gy = helia.global_position.y
                                var asb2 := Sprite2D.new()
                                asb2.texture = load("res://assets/honar/asb.png")
                                asb2.scale = Vector2(0.56, 0.56)
                                asb2.position = Vector2(jax, gy - asb2.texture.get_height() * 0.56 * 0.5 + 6.0)
                                add_child(asb2)
                                asb_ha.append(asb2)
                                zaman_asb_akhar = zaman
                if int(zaman_film * 2.0) != int((zaman_film - delta) * 2.0):
                        print("POS x=", int(helia.global_position.x), " y=", int(helia.global_position.y),
                                " savar=", helia.savar, " halat=", halat_bazi, " halat_h=", helia.halat,
                                " v=", int(helia.velocity.x), " j=", joon_helia)
                # سقفِ فیلم: ۱۱۰ ثانیهٔ بازی یا ۱۲ دقیقهٔ دیواری — هرکدام زودتر
                if zaman_film > 110.0 or Time.get_ticks_msec() > 720000:
                        get_tree().quit()
        if halat_bazi == "bord" and (halat_film or khod_peyma) and zaman_bord > 4.5:
                print("FILM_TAMAM")
                get_tree().quit()

# ── خلبانِ خودکار: مغزِ دمو ──

var rast_ai_ghabli := 0.0
var nav_idx := 0                     # نشانگرِ پرش‌های خلبان خودکار

func maghz_ai(delta: float) -> void:
        vorudi_ai = {"chap": 0.0, "rast": 0.0, "parsh": false, "shemshir": false, "kaman": false, "savari": false}
        if halat_bazi == "shekast":
                return
        if halat_bazi == "bord":
                return
        var h = helia
        # گیر نکردن: اگر می‌خواست برود ولی نمی‌رود، بپرد
        if rast_ai_ghabli > 0.5 and absf(h.velocity.x) < 24.0 and h.is_on_floor():
                zaman_gir_oftade += delta
                if zaman_gir_oftade > 1.4:
                        vorudi_ai["parsh"] = true
                        zaman_gir_oftade = 0.0
        else:
                zaman_gir_oftade = 0.0
        # ۱) پرش از شکاف — نگاهِ رو به جلو: اگر ۹۵ پیکسل جلوتر زمین نیست، بپر
        if h.is_on_floor() and h.halat != "morde":
                var jahat_ai := 1.0
                if zamin_y_at(h.global_position.x + jahat_ai * 95.0) > 940.0:
                        vorudi_ai["parsh"] = true
        # ۱٫۵) نجاتِ سقوط — اگر در چاه افتاد: پرشِ دومِ ضربانی + حرکت به زمینِ نزدیک
        if not h.is_on_floor() and h.velocity.y > 60.0 and zamin_y_at(h.global_position.x) > 940.0 and h.global_position.y < 800.0 and h.halat != "morde":
                vorudi_ai["parsh"] = (int(zaman * 30.0) % 2 == 0)
                if zamin_y_at(h.global_position.x - 130.0) < 940.0:
                        vorudi_ai["chap"] = 1.0
                elif zamin_y_at(h.global_position.x + 130.0) < 940.0:
                        vorudi_ai["rast"] = 1.0
        # ۱٫۶) گریز از سنگِ در حالِ پرواز — پرشِ لحظه‌ای
        if h.is_on_floor() and h.halat == "doid":
                for sag in sang_ha:
                        var sagh = sag["gh"]
                        if is_instance_valid(sagh) and absf(sagh.position.x - h.global_position.x) < 230.0 and sagh.position.y < h.global_position.y + 60.0:
                                vorudi_ai["parsh"] = true
                                break
        # ۲) دیوسپید: کایت و تیراندازی
        if is_instance_valid(bos) and bos.faal and bos.halat != "morde":
                var dx: float = h.global_position.x - bos.global_position.x
                if absf(dx) < 250.0:
                        if h.is_on_floor() and bos.zaman_telegh > 0.0:
                                vorudi_ai["parsh"] = true
                        vorudi_ai["rast" if dx > 0 else "chap"] = 1.0   # فرار — دور شو
                elif absf(dx) > 460.0:
                        vorudi_ai["chap" if dx > 0 else "rast"] = 1.0   # نزدیک شو
                zaman_tir_ai -= delta
                if zaman_tir_ai <= 0.0 and h.halat == "doid":
                        vorudi_ai["kaman"] = true
                        zaman_tir_ai = 0.5
                return
        # ۲) سوارِ اسب شو اگر نزدیک است
        if not h.savar and h.is_on_floor():
                for a in asb_ha:
                        if is_instance_valid(a) and a.modulate.a > 0.9 and absf(a.global_position.x - h.global_position.x) < 90.0:
                                vorudi_ai["savari"] = true
        # ۳) نزدیک‌ترین دشمنِ جلوی رو — فقط روی زمینِ امنِ دوطرفه (نه لبهٔ چاه)
        var hadaf = null
        var fas := 1e9
        for d in doshman_ha:
                if not is_instance_valid(d) or d.halat == "morde":
                        continue
                var dx2: float = d.global_position.x - h.global_position.x
                if dx2 > -80.0 and absf(dx2) < fas:
                        fas = absf(dx2)
                        hadaf = d
        var zamin_amn := zamin_y_at(h.global_position.x + 55.0) < 940.0 and zamin_y_at(h.global_position.x - 60.0) < 940.0
        if hadaf != null and fas < 260.0 and h.halat == "doid" and zamin_amn and not h.savar:
                if hadaf.noe == "div" and fas > 150.0:
                        zaman_tir_ai -= delta
                        if zaman_tir_ai <= 0.0:
                                vorudi_ai["kaman"] = true
                                zaman_tir_ai = 0.85
                elif fas < 112.0:
                        if hadaf.zaman_telegh > 0.0:
                                # دشمن رگبار می‌گیرد — عقب بکش
                                vorudi_ai["chap" if hadaf.global_position.x > h.global_position.x else "rast"] = 1.0
                        else:
                                vorudi_ai["shemshir"] = true
                else:
                        vorudi_ai["rast" if hadaf.global_position.x > h.global_position.x else "chap"] = 1.0
                return
        # ۵) دویدن به جلو — پس از گشودنِ دروازه تا داخلِ دژ
        var hadafe_doid: float = 8560.0 if dargah_vaz else (TOL - 260.0)
        if h.global_position.x < hadafe_doid:
                vorudi_ai["rast"] = 1.0
        rast_ai_ghabli = vorudi_ai["rast"]

# ── برخوردها و آسیب ──

func barkhord_ha() -> void:
        for d in doshman_ha:
                if not is_instance_valid(d) or d.halat == "morde":
                        continue
                if d.noe == "div_sefid" and not d.faal:
                        continue
                var dx: float = absf(helia.global_position.x - d.global_position.x)
                var dy: float = absf(helia.global_position.y - d.global_position.y)
                if dx < d.vosat + 30.0 and dy < d.vosat * 1.2 + 40.0:
                        if helia.savar and absf(helia.velocity.x) > 380.0 and d.zaman_flash <= 0.0:
                                d.zarbe(2)
                                d.zaman_flash = 0.5
                                seda("kling", -6.0)
                                lershe = maxf(lershe, 3.0)
                        else:
                                zakhmi_helia(d.ghodrat, d.global_position)

func zakhmi_helia(gh: int, ja_doshman: Vector2) -> void:
        if helia.zaman_zakhmi > 0.0 or helia.halat == "morde" or halat_bazi == "bord":
                return
        if halat_film:
                gh = maxi(1, gh / 2)          # در فیلم ضربه نرم‌تر تا نمایش روان باشد
        joon_helia -= gh
        if halat_film:
                joon_helia = maxi(joon_helia, 2)   # در فیلم گردآفرید نمی‌میرد
        helia.zaman_zakhmi = 1.15
        helia.velocity = Vector2(signf(helia.global_position.x - ja_doshman.x) * 330.0, -430.0)
        lershe = maxf(lershe, 8.0)
        seda("zadakhor", -2.0)
        porup(helia.global_position + Vector2(0, -110), "-" + adad_fa(gh), Color(1.0, 0.45, 0.4), 30)
        if helia.savar:
                helia.savar = false
                asb_rahayi()
        del_roz()
        if joon_helia <= 0:
                shekast()

func soqot() -> void:
        if halat_bazi != "bazi":
                return
        helia.savar = false
        if not halat_film:
                joon_helia -= 1            # در فیلم افتادن در چاه جان نمی‌گیرد
        del_roz()
        porup(Vector2(helia.global_position.x, 640), "به چاه افتاد!", Color(1.0, 0.7, 0.5), 26)
        if joon_helia <= 0:
                shekast()
        else:
                helia.global_position = ja_chekpoint[checkpoint_idx()] + Vector2(0, -60)
                helia.velocity = Vector2.ZERO

func shekast() -> void:
        halat_bazi = "shekast"
        helia.halat = "morde"
        helia.velocity = Vector2.ZERO
        seda("shekast", -3.0)
        payam("گردآفرید به خاک افتاد…", "دوباره برخیز — دژ هنوز ایستاده", 2.6)
        var moddat := 1.6 if halat_film else 2.4
        var t := get_tree().create_timer(moddat)
        t.timeout.connect(bazgash)

func bazgash() -> void:
        joon_helia = 5
        helia.halat = "doid"
        helia.savar = false
        helia.zaman_zakhmi = 1.4
        helia.global_position = ja_chekpoint[checkpoint_idx()] + Vector2(0, -60)
        helia.velocity = Vector2.ZERO
        del_roz()
        if is_instance_valid(bos) and bos.faal:
                helia.global_position = Vector2(7420.0, 560.0)
        halat_bazi = "bazi"

func checkpoint_idx() -> int:
        var behtar := 0
        for i in ja_chekpoint.size():
                if helia.global_position.x >= ja_chekpoint[i].x - 40.0:
                        behtar = i
        return behtar

func chekpoint_baresi() -> void:
        var idx := checkpoint_idx()
        if idx > chekpoint_idx:
                chekpoint_idx = idx
                seda("istgah", -4.0)
                porup(ja_chekpoint[idx] + Vector2(0, -110), "ایستگاهِ امن", Color(0.6, 1.0, 0.7), 28)

# ── اسب ──

func koshish_e_savari() -> void:
        if helia.savar or helia.halat != "doid":
                return
        for a in asb_ha:
                if is_instance_valid(a) and a.modulate.a > 0.9 and absf(a.global_position.x - helia.global_position.x) < 100.0 and absf(a.global_position.y - helia.global_position.y) < 130.0:
                        helia.savar = true
                        a.visible = false
                        a.set_meta("raft", true)
                        seda("savari", -3.0)
                        porup(helia.global_position + Vector2(0, -120), "هی! اسبِ سپید", Color(1.0, 0.9, 0.6), 28)
                        return

func asb_rahayi() -> void:
        for a in asb_ha:
                if is_instance_valid(a) and not a.get_meta("raft", false):
                        var t := create_tween()
                        t.tween_property(a, "position:x", a.position.x + 620.0, 1.5)
                        t.parallel().tween_property(a, "modulate:a", 0.0, 1.5)
                        a.set_meta("raft", true)
        seda("sam", -4.0)

func jam_avari() -> void:
        # انارها
        var es := Time.get_ticks_msec() / 1000.0
        for e in enar_ha:
                if is_instance_valid(e):
                        e.position.y += sin(es * 3.0 + e.position.x) * 0.35
                        if helia.global_position.distance_to(e.position) < 64.0 and joon_helia < 5:
                                joon_helia = mini(5, joon_helia + 1)
                                del_roz()
                                seda("enar", -3.0)
                                porup(e.position + Vector2(0, -40), "+جان", Color(0.65, 1.0, 0.7), 30)
                                e.queue_free()
        # اسب‌ها: سکون
        for a in asb_ha:
                if is_instance_valid(a) and not a.get_meta("raft", false):
                        a.position.y += sin(es * 2.2 + a.position.x) * 0.2

# ── بوس و دروازه ──

func bos_hoshidar() -> void:
        if bos_faal_shod or not is_instance_valid(bos):
                return
        # آستانهٔ بیداری — کمی زودتر تا خلبانِ خودکار هم بیدارش کند
        if helia.global_position.x > 7310.0:
                bos_faal_shod = true
                bos.faal = true
                seda("gharjar", 0.0)
                lershe = 10.0
                payam("دیوسپید!", "گردِ دژِ سپید بیدار شد", 2.2)
                # دیوارِ پشتِ سر بسته می‌شود
                var divar := StaticBody2D.new()
                divar.name = "divar_midan"
                divar.position = Vector2(7290.0, 300.0)
                var shekl := CollisionShape2D.new()
                var mostatil := RectangleShape2D.new()
                mostatil.size = Vector2(60.0, 1400.0)
                shekl.shape = mostatil
                divar.add_child(shekl)
                add_child(divar)

func doshman_mord(d) -> void:
        shmar_kosh += 1
        lbl_kosh.text = "دشمنان " + adad_fa(shmar_kosh)
        esparak(d.global_position + Vector2(0, -d.vosat), Color(0.7, 0.4, 0.9))
        if d.noe == "div_sefid":
                bos_mord()

func bos_mord() -> void:
        dargah_vaz = true
        seda("piroozi", 0.0)
        payam("دیوسپید نابود شد!", "دروازهٔ دژِ سپید گشوده گردید", 3.2)
        var divar_midan = get_node_or_null("divar_midan")
        if divar_midan != null:
                divar_midan.queue_free()
        var divar_dargah = get_node_or_null("divar_dargah")
        if divar_dargah != null:
                divar_dargah.queue_free()
        var dargah = get_node_or_null("dargah")
        if dargah != null:
                var t := create_tween()
                t.tween_property(dargah, "modulate", Color(1.5, 1.35, 1.0, 1.0), 1.2)
        konfeti(Vector2(8420, 400))
        if khod_peyma:
                vorudi_ai["rast"] = 1.0

func piroozi_baresi() -> void:
        if halat_bazi == "bazi" and dargah_vaz and helia.global_position.x > 8420.0:
                halat_bazi = "bord"
                zaman_bord = 0.0
                seda("piroozi", 0.0)
                payam("دژِ سپید آزاد شد!", "چو ایران نباشد، تنِ من باد — فردوسی", 5.0)

# ── پروژه‌یل‌ها ──

func zarbe_doshmanha(markaz: Vector2, shoae: float, gh: int) -> void:
        var zad := false
        for d in doshman_ha:
                if not is_instance_valid(d) or d.halat == "morde":
                        continue
                var d_markaz: Vector2 = d.global_position + Vector2(0, -d.vosat)
                if d_markaz.distance_to(markaz) < shoae + d.vosat * 0.7:
                        d.zarbe(gh)
                        zad = true
        if zad:
                seda("kling", -5.0)
                lershe = maxf(lershe, 3.5)

func tir_antal(ja: Vector2, jahat: float) -> void:
        var tir := Node2D.new()
        tir.position = ja
        tir.z_index = 3
        add_child(tir)
        var v := Vector2(jahat * 980.0, -40.0)
        # نشانه‌گیریِ خودکار — نزدیک‌ترین دشمن در هر جهت (تیرِ پارتی!)
        var hadaf_ja := Vector2.ZERO
        var fas_behtar := 1e9
        for d in doshman_ha:
                if not is_instance_valid(d) or d.halat == "morde":
                        continue
                var c: Vector2 = d.global_position + Vector2(0, -d.vosat)
                var dv := c - ja
                if dv.length() > 950.0:
                        continue
                if dv.length() < fas_behtar:
                        fas_behtar = dv.length()
                        hadaf_ja = c
        if hadaf_ja != Vector2.ZERO:
                var tof := hadaf_ja - ja
                var zaman_parvaz := clampf(tof.length() / 980.0, 0.2, 1.0)
                v = Vector2(tof.x / zaman_parvaz, tof.y / zaman_parvaz - 0.5 * 340.0 * zaman_parvaz)
        tir_ha.append({"gh": tir, "v": v, "zaman": 2.2})
        seda("tir", -6.0)

func sang_antal(ja: Vector2, hadaf: Vector2, yakh := false) -> void:
        var sang := Polygon2D.new()
        var shoa := 24.0 if yakh else 19.0
        var n := 7
        var noghte := PackedVector2Array()
        var tokhm := randf() * TAU
        for i in n:
                var ghesme := TAU * i / n
                var shoae_i := shoa * (0.82 + 0.3 * sin(ghesme * 3.0 + tokhm))
                noghte.append(Vector2(cos(ghesme), sin(ghesme)) * shoae_i)
        sang.polygon = noghte
        sang.color = Color(0.78, 0.88, 0.96) if yakh else Color(0.48, 0.4, 0.33)
        sang.position = ja
        sang.z_index = 3
        add_child(sang)
        var dx: float = hadaf.x - ja.x
        var dy: float = hadaf.y - ja.y
        var zaman_parvaz: float = clampf(absf(dx) / 720.0, 0.55, 1.1)
        var vx: float = dx / zaman_parvaz
        var vy: float = (dy - 0.5 * 1500.0 * zaman_parvaz * zaman_parvaz) / zaman_parvaz
        sang_ha.append({"gh": sang, "v": Vector2(vx, vy), "jahat": signf(vx), "ghodrat": 2 if yakh else 1})
        seda("tir", -9.0)

func mowj_antal(ja: Vector2, jahat: float) -> void:
        mowj_ha.append({"x": ja.x, "jahat": jahat, "zaman": 1.2, "rang": Color(0.75, 0.88, 1.0, 0.7)})
        seda("gharjar", -8.0)

func tir_ha_bor(delta: float) -> void:
        for t in tir_ha.duplicate():
                var gh = t["gh"]
                if not is_instance_valid(gh):
                        tir_ha.erase(t)
                        continue
                t["v"].y += 340.0 * delta
                gh.position += t["v"] * delta
                gh.rotation = t["v"].angle()
                t["zaman"] -= delta
                var khord := false
                for d in doshman_ha:
                        if not is_instance_valid(d) or d.halat == "morde":
                                continue
                        if d.noe == "div_sefid" and not d.faal:
                                continue
                        var d_markaz: Vector2 = d.global_position + Vector2(0, -d.vosat)
                        if d_markaz.distance_to(gh.position) < d.vosat + 22.0:
                                d.zarbe(1)
                                if d.noe == "div_sefid":
                                        print("BOS_HIT joon=", d.joon)
                                khord = true
                                break
                if khord or t["zaman"] <= 0.0 or gh.position.y > zamin_y_at(gh.position.x) + 4.0:
                        if khord:
                                esparak(gh.position, Color(1.0, 0.9, 0.5))
                        gh.queue_free()
                        tir_ha.erase(t)

func sang_ha_bor(delta: float) -> void:
        for s in sang_ha.duplicate():
                var gh = s["gh"]
                if not is_instance_valid(gh):
                        sang_ha.erase(s)
                        continue
                s["v"].y += 1500.0 * delta
                gh.position += s["v"] * delta
                gh.rotation += 3.0 * delta * s["jahat"]
                var ghodrat: int = s["ghodrat"]
                if helia.global_position.distance_to(gh.position + Vector2(0, -18)) < 52.0:
                        zakhmi_helia(ghodrat, gh.position)
                        esparak(gh.position, Color(0.8, 0.7, 0.6))
                        gh.queue_free()
                        sang_ha.erase(s)
                elif gh.position.y > zamin_y_at(gh.position.x) - 4.0:
                        esparak(gh.position, Color(0.6, 0.5, 0.45))
                        gh.queue_free()
                        sang_ha.erase(s)

func mowj_ha_bor(delta: float) -> void:
        for m in mowj_ha.duplicate():
                m["x"] += m["jahat"] * 540.0 * delta
                m["zaman"] -= delta
                if absf(helia.global_position.x - m["x"]) < 48.0 and helia.is_on_floor():
                        zakhmi_helia(2, Vector2(m["x"] - m["jahat"] * 100.0, helia.global_position.y))
                if m["zaman"] <= 0.0:
                        mowj_ha.erase(m)
        queue_redraw()

# ── جلوه‌ها ──

func esparak(ja: Vector2, rang: Color) -> void:
        var p := CPUParticles2D.new()
        p.position = ja
        p.amount = 14
        p.lifetime = 0.4
        p.one_shot = true
        p.explosiveness = 1.0
        p.spread = 180.0
        p.initial_velocity_min = 120.0
        p.initial_velocity_max = 320.0
        p.gravity = Vector2(0, 500)
        p.scale_amount_min = 2.0
        p.scale_amount_max = 4.6
        p.color = rang
        p.emitting = true
        add_child(p)
        var t := get_tree().create_timer(1.0)
        t.timeout.connect(p.queue_free)

func konfeti(ja: Vector2) -> void:
        var p := CPUParticles2D.new()
        p.position = ja
        p.amount = 40
        p.lifetime = 1.6
        p.one_shot = true
        p.explosiveness = 0.9
        p.spread = 180.0
        p.initial_velocity_min = 160.0
        p.initial_velocity_max = 420.0
        p.gravity = Vector2(0, 420)
        p.scale_amount_min = 3.0
        p.scale_amount_max = 6.0
        p.color = Color(1.0, 0.85, 0.4)
        p.emitting = true
        add_child(p)
        var t := get_tree().create_timer(2.2)
        t.timeout.connect(p.queue_free)

func pop_ha_bor(delta: float) -> void:
        for p in pop_ha.duplicate():
                p["zaman"] -= delta
                if p["zaman"] <= 0.0:
                        pop_ha.erase(p)

func porup(ja: Vector2, matn: String, rang: Color, andaze := 26) -> void:
        pop_ha.append({"ja": ja, "matn": matn, "rang": rang, "zaman": 1.15, "andaze": andaze})

func payam(asli: String, zir: String, moddat: float) -> void:
        lbl_payam.text = asli
        lbl_zirpayam.text = zir
        zaman_payam = moddat

func del_roz() -> void:
        for i in del_ha.size():
                (del_ha[i] as TextureRect).modulate.a = 1.0 if i < joon_helia else 0.18

# ═══════════════ رسمِ جهان ═══════════════

func _process(_delta: float) -> void:
        queue_redraw()

func _draw() -> void:
        var es := Time.get_ticks_msec() / 1000.0
        # سکوها با کاشیِ ایرانی
        for s in sath_ha:
                var ghobar := Rect2(s.x0, s.y, s.x1 - s.x0, 420.0)
                draw_texture_rect(tex_kash, ghobar, true)
                draw_rect(Rect2(s.x0, s.y, s.x1 - s.x0, 13.0), Color(1.0, 0.84, 0.45))
                draw_rect(Rect2(s.x0, s.y + 13.0, s.x1 - s.x0, 6.0), Color(0.25, 0.62, 0.65))
                draw_rect(Rect2(s.x0, s.y, s.x1 - s.x0, 420.0), Color(0.2, 0.12, 0.1, 0.25), false, 3.0)
        for z in zin_ha:
                draw_texture_rect(tex_kash, Rect2(z.x0, z.y, z.x1 - z.x0, 46.0), true)
                draw_rect(Rect2(z.x0, z.y, z.x1 - z.x0, 11.0), Color(1.0, 0.84, 0.45))
        # آتش‌بازوها
        for x in ja_atesh_ha:
                var y := zamin_y_at(x)
                draw_line(Vector2(x, y), Vector2(x, y - 62.0), Color(0.28, 0.18, 0.14), 7.0)
                draw_line(Vector2(x - 16.0, y), Vector2(x, y - 62.0), Color(0.28, 0.18, 0.14), 5.0)
                draw_line(Vector2(x + 16.0, y), Vector2(x, y - 62.0), Color(0.28, 0.18, 0.14), 5.0)
                draw_circle(Vector2(x, y - 70.0), 17.0, Color(0.2, 0.13, 0.1))
        # پرچم‌های چک‌پوینت — سه‌رنگِ ایران
        for i in ja_chekpoint.size():
                var cp: Vector2 = ja_chekpoint[i]
                var x: float = cp.x
                var y := zamin_y_at(x)
                var ghalib := 1.0 if i <= chekpoint_idx else 0.45
                draw_line(Vector2(x, y), Vector2(x, y - 118.0), Color(0.35, 0.25, 0.2, ghalib), 5.0)
                var mov := sin(es * 5.0 + i) * 3.0
                draw_rect(Rect2(x, y - 118.0, 46.0, 12.0), Color(0.14, 0.6, 0.32, ghalib))
                draw_rect(Rect2(x, y - 106.0, 46.0, 12.0), Color(1.0, 1.0, 1.0, ghalib))
                draw_rect(Rect2(x, y - 94.0, 46.0 + mov, 12.0), Color(0.85, 0.16, 0.2, ghalib))
        # موج‌های زمینیِ دیوسپید
        for m in mowj_ha:
                var y := zamin_y_at(float(m["x"]))
                var p: float = 1.0 - float(m["zaman"]) / 1.2
                var rango: Color = m["rang"]
                draw_arc(Vector2(m["x"], y), 16.0 + p * 34.0, PI, TAU, 14, rango, 6.0)
                draw_arc(Vector2(m["x"], y), 8.0 + p * 20.0, PI, TAU, 12, Color(rango.r, rango.g, rango.b, rango.a * 0.6), 4.0)
        # مهِ سبکِ پایینِ صحنه
        var cam_x := dorbin.position.x
        draw_rect(Rect2(cam_x - 700.0, 690.0, 1400.0, 34.0), Color(1.0, 0.9, 0.75, 0.05))
        draw_rect(Rect2(cam_x - 700.0, 710.0, 1400.0, 26.0), Color(1.0, 0.9, 0.75, 0.08))
        # پاپ‌آپ‌ها
        for p in pop_ha:
                var alfa: float = clampf(p["zaman"] / 1.15, 0.0, 1.0)
                var ja: Vector2 = p["ja"] + Vector2(0, -34.0 * (1.0 - alfa) - 10.0)
                draw_string(fnt_vazir, ja + Vector2(2, 2), p["matn"], HORIZONTAL_ALIGNMENT_CENTER, -1, p["andaze"], Color(0, 0, 0, alfa * 0.7))
                draw_string(fnt_vazir, ja, p["matn"], HORIZONTAL_ALIGNMENT_CENTER, -1, p["andaze"], Color(p["rang"].r, p["rang"].g, p["rang"].b, alfa))

# ═══════════════ ابزار ═══════════════

func zamin_y_at(x: float) -> float:
        for s in sath_ha:
                if x >= s.x0 and x <= s.x1:
                        return s.y
        return 980.0

func adad_fa(n: int) -> String:
        var raghmi := ["۰", "۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹"]
        var s := str(absi(n))
        var kh := ""
        for c in s:
                kh += raghmi[int(c)]
        if n < 0:
                kh = "-" + kh
        return kh

func aks(nam: String) -> void:
        if not nam.ends_with(".png"):
                nam += ".png"
        await RenderingServer.frame_post_draw
        var tasvir := get_viewport().get_texture().get_image()
        tasvir.save_png(AKS_DIR + nam)
        print("akse zakhire shod: " + nam)

# جدولِ فیلم: اسکرین‌شات بر پایهٔ مکانِ هلیا (نه زمان)
var film_aks_pos := [
        [420.0, "aks_2_galop"],
        [1620.0, "aks_3_shemshir"],
        [3600.0, "aks_4_div"],
        [5000.0, "aks_5_mian"],
        [7390.0, "aks_6_bos"],
        [7700.0, "aks_7_bos2"],
        [8380.0, "aks_8_dargah"],
]
var film_aks_idx := 0
var aks_piroozi_rasid := false

func film_tarikhche() -> void:
        if film_aks_idx == 0 and zaman_film >= 0.9:
                aks("aks_1_onvan")
                film_aks_idx += 1
        while film_aks_idx < film_aks_pos.size() and helia.global_position.x >= film_aks_pos[film_aks_idx][0]:
                aks(film_aks_pos[film_aks_idx][1])
                film_aks_idx += 1
        if halat_bazi == "bord" and not aks_piroozi_rasid and zaman_bord > 2.0:
                aks("aks_9_piroozi")
                aks_piroozi_rasid = true
