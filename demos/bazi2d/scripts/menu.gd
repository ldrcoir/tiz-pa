# ═══════════════════════════════════════════════════════════════
#  آزمایشگاه دوبعدی تیزپا — منوی انتخاب بازی
#  ثابت می‌کند دوبعدی کلاً مال ماست: هر چیزی که می‌بینی با کد ساخته شده،
#  بدون حتی یک عکس بیرونی — سه صحنه، سه اسکریپت، صفر تکسچر
# ═══════════════════════════════════════════════════════════════
extends Control

const MASIR_AKS := "/home/z/my-project/download/screenshots_2d"

var fnt: FontFile = null
var fnt_tiz: FontFile = null
var argha: Array = []
var aks_mode := false
var t_test := 0.0
var aks_gerefte := {}

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
        # قفل LTR — ضدآینه‌شدن روی گوشی فارسی (همان ترفند خود تیزپا)
        layout_direction = Control.LAYOUT_DIRECTION_LTR
        fnt = _fnt_amn("res://assets/fonts/Vazirmatn-Bold.ttf")
        fnt_tiz = _fnt_amn("res://assets/fonts/Lalezar-Regular.ttf")
        argha = OS.get_cmdline_user_args()
        aks_mode = argha.has("--aks")
        _shabake_besaz()
        _haml_besaz()

# پس‌زمینه‌ی شب‌رنگ + سه هاله‌ی رنگی نرم پشت کارت‌ها
func _shabake_besaz() -> void:
        var zamin := ColorRect.new()
        zamin.color = Color("0b0f1e")
        zamin.set_anchors_preset(Control.PRESET_FULL_RECT)
        zamin.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(zamin)
        # هاله‌ها — مثل سه ستاره‌ی دور که پشت منو می‌درخشند
        var rangha := [Color("7c4dff"), Color("00e5ff"), Color("2e7d32")]
        var ja_ha := [Vector2(220, 150), Vector2(1060, 180), Vector2(640, 640)]
        for i in 3:
                var gh := Gradient.new()
                gh.colors = PackedColorArray([Color(rangha[i], 0.30), Color(rangha[i], 0.0)])
                gh.offsets = PackedFloat32Array([0.0, 1.0])
                var th := GradientTexture2D.new()
                th.gradient = gh
                th.fill = GradientTexture2D.FILL_RADIAL
                th.fill_from = Vector2(0.5, 0.5)
                th.fill_to = Vector2(0.5, 0.0)
                th.width = 520
                th.height = 520
                var tr := TextureRect.new()
                tr.texture = th
                tr.position = ja_ha[i] - Vector2(260, 260)
                tr.size = Vector2(520, 520)
                tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
                add_child(tr)

func _matn_besaz(matn: String, fon: FontFile, andaze: int, rang: Color) -> Label:
        var l := Label.new()
        l.text = matn
        l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        l.add_theme_font_override("font", fon)
        l.add_theme_font_size_override("font_size", andaze)
        l.add_theme_color_override("font_color", rang)
        l.mouse_filter = Control.MOUSE_FILTER_IGNORE
        return l

func _haml_besaz() -> void:
        var vas := VBoxContainer.new()
        vas.set_anchors_preset(Control.PRESET_FULL_RECT)
        vas.alignment = BoxContainer.ALIGNMENT_CENTER
        vas.add_theme_constant_override("separation", 18)
        vas.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(vas)
        var onvan := _matn_besaz("آزمایشگاه دوبعدی", fnt_tiz, 92, Color("ffd94a"))
        onvan.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.55))
        onvan.add_theme_constant_override("shadow_offset_x", 4)
        onvan.add_theme_constant_override("shadow_offset_y", 5)
        vas.add_child(onvan)
        vas.add_child(_matn_besaz("سه بازیِ نمونه — توان واقعی گرافیک دوبعدی — همه با کد خالص", fnt, 26, Color("b8c4e0")))
        # ردیف کارت‌ها
        var radif := HBoxContainer.new()
        radif.alignment = BoxContainer.ALIGNMENT_CENTER
        radif.add_theme_constant_override("separation", 30)
        radif.mouse_filter = Control.MOUSE_FILTER_IGNORE
        vas.add_child(radif)
        var baziha := [
                ["شهاب", "تیرانداز فضایی", "ستاره‌ها، دشمن، انفجار ذره‌ای", Color("241b4d"), Color("00e5ff"), "res://scenes/tirandaz.tscn"],
                ["آجرشکن کاشی", "توپ و تخته", "کاشی‌های فیروزه و لاجورد و زعفرانی", Color("0f3438"), Color("ffd94a"), "res://scenes/ajorshekan.tscn"],
                ["افعی باغ فردوس", "مار کلاسیک", "چمن شطرنجی، سیب، رشد بی‌وقفه", Color("123020"), Color("a5d6a7"), "res://scenes/afei.tscn"]
        ]
        for b in baziha:
                radif.add_child(_kart_besaz(b[0], b[1], b[2], b[3], b[4], b[5]))
        vas.add_child(_matn_besaz("گودوت ۴.۷ — سه صحنه، سه اسکریپت، صفر تکسچر بیرونی", fnt, 20, Color("6b7a9e")))

func _kart_besaz(nam: String, noe: String, tozikh: String, rang: Color, border: Color, masir: String) -> Button:
        var kart := Button.new()
        kart.custom_minimum_size = Vector2(360, 270)
        var sb := StyleBoxFlat.new()
        sb.bg_color = rang
        sb.border_color = border
        sb.set_border_width_all(3)
        sb.set_corner_radius_all(22)
        sb.set_content_margin_all(24)
        kart.add_theme_stylebox_override("normal", sb)
        var sb_h := sb.duplicate()
        sb_h.bg_color = rang.lightened(0.12)
        sb_h.set_border_width_all(5)
        kart.add_theme_stylebox_override("hover", sb_h)
        kart.add_theme_stylebox_override("pressed", sb_h)
        var vas := VBoxContainer.new()
        vas.alignment = BoxContainer.ALIGNMENT_CENTER
        vas.add_theme_constant_override("separation", 12)
        vas.set_anchors_preset(Control.PRESET_FULL_RECT)
        vas.mouse_filter = Control.MOUSE_FILTER_IGNORE
        kart.add_child(vas)
        var neshane := ColorRect.new()
        neshane.color = border
        neshane.custom_minimum_size = Vector2(70, 8)
        vas.add_child(neshane)
        vas.add_child(_matn_besaz(nam, fnt_tiz, 46, Color.WHITE))
        vas.add_child(_matn_besaz(noe, fnt, 24, border))
        vas.add_child(_matn_besaz(tozikh, fnt, 19, Color("dfe8ff")))
        vas.add_child(_matn_besaz("برای شروع کلیک کن", fnt, 16, Color(1, 1, 1, 0.45)))
        kart.pressed.connect(func(): get_tree().change_scene_to_file(masir))
        return kart

func _process(dt: float) -> void:
        if not aks_mode:
                return
        t_test += dt
        if t_test > 1.4 and not aks_gerefte.has("menu"):
                aks_gerefte["menu"] = true
                _aks_begir(MASIR_AKS + "/menu.png")
        if t_test > 2.0:
                print("[demo2d] MENU DONE")
                get_tree().quit()

func _aks_begir(masir: String) -> void:
        var aks := get_viewport().get_texture().get_image()
        if aks != null:
                aks.save_png(masir)
                print("[demo2d] SHOT ", masir)
