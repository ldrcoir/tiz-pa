# ═══════════════════════════════════════════════════════════════
#  تیزپا ۲بعدی — منوی شروع
#  چهار لایه‌ی هنرِ AI پارالاکس می‌شوند؛ هلیا-ماشین پایین با خروجی دود
# ═══════════════════════════════════════════════════════════════
extends Node2D

const MASIR_AKS := "/home/z/my-project/download/screenshots_2d"
const TOL_LAYER := 1344.0

var fnt: FontFile = null
var fnt_tiz: FontFile = null
var argha: Array = []
var aks_mode := false
var t_test := 0.0
var zaman := 0.0
var mashin: Sprite2D

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
        _layer_ha_besaz()
        _jadde_besaz()
        _mashin_besaz()
        _ui_besaz()

func _texture_amn(masir: String) -> Texture2D:
        if ResourceLoader.exists(masir):
                return load(masir)
        return null

# چهار لایه‌ی هنرِ AI — مقیاس‌بندی شده؛ میله و آسمان دیده می‌شوند، درخت نازک جلوی نماس
func _layer_ha_besaz() -> void:
        var tarif_ha := [
                ["res://assets/art/aseman.png", 720.0, 1.0],
                ["res://assets/art/khat_shahr.png", 560.0, 1.0],
                ["res://assets/art/sakhtemanha.png", 560.0, 0.42],
                ["res://assets/art/derakht.png", 560.0, 0.26]
        ]
        for t in tarif_ha:
                var maghsas := float(t[2])
                var tool_l := TOL_LAYER * maghsas
                var y_bala := float(t[1]) - 768.0 * maghsas
                var i := 0
                while float(i) * tool_l < 1280.0:
                        var sp := Sprite2D.new()
                        sp.texture = _texture_amn(t[0])
                        sp.centered = false
                        sp.scale = Vector2(maghsas, maghsas)
                        sp.position = Vector2(float(i) * tool_l, y_bala)
                        add_child(sp)
                        i += 1
        # سایه‌ی نرم پایین نمای ساختمان‌ها — حس عمق
        var sayeh := ColorRect.new()
        sayeh.color = Color(0, 0, 0, 0.18)
        sayeh.position = Vector2(0, 520)
        sayeh.size = Vector2(1280, 40)
        add_child(sayeh)

func _jadde_besaz() -> void:
        var asfalt := ColorRect.new()
        asfalt.color = Color("2e3238")
        asfalt.position = Vector2(0, 556)
        asfalt.size = Vector2(1280, 164)
        add_child(asfalt)
        var varag := ColorRect.new()
        varag.color = Color("d8b93a")
        varag.position = Vector2(0, 550)
        varag.size = Vector2(1280, 7)
        add_child(varag)
        var tir := ColorRect.new()
        tir.color = Color(0, 0, 0, 0.22)
        tir.position = Vector2(0, 712)
        tir.size = Vector2(1280, 8)
        add_child(tir)

func _mashin_besaz() -> void:
        mashin = Sprite2D.new()
        mashin.texture = _texture_amn("res://assets/sprites/car_boghi_yellow.webp")
        mashin.scale = Vector2(0.52, 0.52)
        mashin.position = Vector2(500, 640)
        add_child(mashin)
        var dud := CPUParticles2D.new()
        dud.position = Vector2(-100, 48)
        dud.amount = 16
        dud.lifetime = 1.1
        dud.direction = Vector2(-1, 0.15)
        dud.spread = 22.0
        dud.gravity = Vector2(0, -34)
        dud.initial_velocity_min = 38.0
        dud.initial_velocity_max = 85.0
        dud.scale_amount_min = 3.0
        dud.scale_amount_max = 7.0
        dud.color = Color(0.62, 0.62, 0.65, 0.30)
        mashin.add_child(dud)

func _matn_besaz(matn: String, fon: FontFile, andaze: int, rang: Color, ja: Vector2) -> Label:
        var l := Label.new()
        l.text = matn
        l.position = ja
        l.add_theme_font_override("font", fon)
        l.add_theme_font_size_override("font_size", andaze)
        l.add_theme_color_override("font_color", rang)
        l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.55))
        l.add_theme_constant_override("shadow_offset_x", 3)
        l.add_theme_constant_override("shadow_offset_y", 4)
        l.mouse_filter = Control.MOUSE_FILTER_IGNORE
        return l

func _ui_besaz() -> void:
        var hud := CanvasLayer.new()
        add_child(hud)
        var onvan := _matn_besaz("تیزپا ۲بعدی", fnt_tiz, 100, Color("ffd94a"), Vector2(0, 76))
        onvan.size = Vector2(1280, 120)
        onvan.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        hud.add_child(onvan)
        var zir := _matn_besaz("خیابان ولیعصر — تهران — دوی بی‌پایان", fnt, 27, Color("cfe0ff"), Vector2(0, 208))
        zir.size = Vector2(1280, 40)
        zir.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        hud.add_child(zir)
        var behtarin := 0
        var fa := FileAccess.open("user://tizpa2d_best.txt", FileAccess.READ)
        if fa != null:
                behtarin = int(fa.get_as_text().strip_edges())
        if behtarin > 0:
                var r := _matn_besaz("بهترین رکورد: " + _fa(behtarin), fnt, 23, Color("a5d6a7"), Vector2(0, 252))
                r.size = Vector2(1280, 34)
                r.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
                hud.add_child(r)
        var dokme := Button.new()
        dokme.text = "شروع مسابقه"
        dokme.position = Vector2(480, 306)
        dokme.size = Vector2(320, 76)
        dokme.add_theme_font_override("font", fnt_tiz)
        dokme.add_theme_font_size_override("font_size", 36)
        dokme.add_theme_color_override("font_color", Color("1b2340"))
        var sb := StyleBoxFlat.new()
        sb.bg_color = Color("ffd94a")
        sb.set_corner_radius_all(20)
        sb.set_content_margin_all(14)
        dokme.add_theme_stylebox_override("normal", sb)
        var sbh := sb.duplicate()
        sbh.bg_color = Color("ffe98a")
        dokme.add_theme_stylebox_override("hover", sbh)
        dokme.add_theme_stylebox_override("pressed", sbh)
        dokme.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/bazi.tscn"))
        hud.add_child(dokme)
        var foot := _matn_besaz("هنر: هوش مصنوعی — کد: دست‌نویس — موتور: گودوت ۴.۷", fnt, 18, Color(1, 1, 1, 0.45), Vector2(0, 676))
        foot.size = Vector2(1280, 30)
        foot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        hud.add_child(foot)

func _process(dt: float) -> void:
        zaman += dt
        if mashin != null:
                mashin.position.y = 640.0 + sin(zaman * 13.0) * 2.6
        if aks_mode:
                t_test += dt
                if t_test > 1.4 and t_test - dt <= 1.4:
                        var aks := get_viewport().get_texture().get_image()
                        if aks != null:
                                aks.save_png(MASIR_AKS + "/tizpa2d_menu.png")
                                print("[tizpa2d] SHOT menu")
                if t_test > 2.0:
                        print("[tizpa2d] MENU DONE")
                        get_tree().quit()
