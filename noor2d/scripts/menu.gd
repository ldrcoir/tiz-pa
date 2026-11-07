extends Node2D
## منوی «سه‌گانهٔ نور» — سه تجربهٔ دوبعدی مدرن

const Ashtar = preload("res://scripts/ashtar.gd")
const W := 1280.0
const H := 720.0

var fon_l: FontFile
var fon_v: FontFile
var fon_b: FontFile
var halha := []            # هاله‌های شناور پس‌زمینه
var setara := []           # ستاره‌ها
var t := 0.0
var t0 := 0
var aks := false
var aks_plan := [[1700, "menu.png"]]
var aks_i := 0
var rng := RandomNumberGenerator.new()


func _ready() -> void:
        fon_l = Ashtar.fon("res://assets/fonts/Lalezar-Regular.ttf")
        fon_v = Ashtar.fon("res://assets/fonts/Vazirmatn-Regular.ttf")
        fon_b = Ashtar.fon("res://assets/fonts/Vazirmatn-Bold.ttf")
        aks = Ashtar.aks_faal()
        t0 = Time.get_ticks_msec()
        rng.seed = 20251107
        _aseman_besaz()
        _onvan_besaz()
        _kart_ha_besaz()
        _paen_besaz()


func _aseman_besaz() -> void:
        ## پس‌زمینه: هاله‌های رنگی شناور + ستاره‌های چشمک‌زن
        var zamin := ColorRect.new()
        zamin.color = Color("#07070f")
        zamin.size = Vector2(W, H)
        add_child(zamin)
        var rangha := [Color("#3a1c71"), Color("#0f5c6b"), Color("#7a1f4d")]
        for i in 3:
                var h := Ashtar.halo(rangha[i], 300.0, 2.2)
                h.position = Vector2(220.0 + float(i) * 420.0, 240.0 + 130.0 * float((i % 2) * 2 - 1))
                h.set_meta("faz", float(i) * 2.1)
                add_child(h)
                halha.append(h)
        for i in 80:
                var s := Ashtar.halo(Color(1, 1, 1, 0.8), rng.randf_range(1.5, 4.0))
                s.position = Vector2(rng.randf_range(0, W), rng.randf_range(0, H))
                s.set_meta("faz", rng.randf_range(0.0, TAU))
                add_child(s)
                setara.append(s)


func _matn(matn: String, fon: FontFile, andaze: int, rang: Color, pos: Vector2, arz: float, hamrorasti := HORIZONTAL_ALIGNMENT_CENTER) -> Label:
        var l := Label.new()
        l.text = matn
        l.add_theme_font_override("font", fon)
        l.add_theme_font_size_override("font_size", andaze)
        l.add_theme_color_override("font_color", rang)
        l.position = pos
        l.size = Vector2(arz, andaze + 24)
        l.horizontal_alignment = hamrorasti
        add_child(l)
        return l


func _onvan_besaz() -> void:
        var ashk := Ashtar.halo(Color("#ffd24d"), 60.0)
        ashk.position = Vector2(W * 0.5, 96)
        add_child(ashk)
        _matn("سه‌گانهٔ نور", fon_l, 92, Color("#fff6df"), Vector2(0, 44), W)
        _matn("سه تجربهٔ دوبعدی خلاقانه — نه کپیِ بازی‌های قدیمی، همه با کد و هنر رویه‌ای", fon_v, 24, Color("#9fb2d8"), Vector2(0, 152), W)


func _kart_ha_besaz() -> void:
        ## سه کارت معرفی؛ هر کارت رنگ و دنیای خودش را دارد
        var baz := [
                ["مدار", "#35e0ff", "با یک لمس از مدارِ هسته رها شو و در مدار بعدی به دام بیفتد.\nزنجیره بساز، تخم‌های نور را جمع کن.", "تک‌لمسی · فیزیک مداری · دنبالهٔ نور"],
                ["شب‌تاب", "#ffe98a", "کرم شب‌تاب را در باغِ تاریک بران؛ هاله‌ات جانِ بازیه.\nپروانه‌های سایه فقط در نور پیدا می‌شوند.", "بقا · مه‌آلود · نور و سایه"],
                ["بادبادک تهران", "#ff7a9c", "بادبادکت را بر فراز پشت‌بام‌های تهران برسان.\nنخِ زنده با فیزیک ورله، نسیم و تندباد.", "فیزیک نخ · غروب تهران · کلاغ‌ها"],
        ]
        for i in 3:
                var x := 84.0 + float(i) * 376.0
                var y := 218.0
                var kart := Panel.new()
                var sb := StyleBoxFlat.new()
                sb.bg_color = Color(1, 1, 1, 0.03)
                sb.set_border_width_all(2)
                sb.border_color = Color(baz[i][1], 0.85)
                sb.set_corner_radius_all(18)
                kart.add_theme_stylebox_override("panel", sb)
                kart.position = Vector2(x, y)
                kart.size = Vector2(344, 408)
                add_child(kart)
                var barg := TextureRect.new()
                barg.texture = Ashtar.bargo([Color(baz[i][1], 0.22), Color(baz[i][1], 0.02)])
                barg.position = Vector2(2, 2)
                barg.size = Vector2(340, 200)
                barg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
                barg.stretch_mode = TextureRect.STRETCH_SCALE
                kart.add_child(barg)
                var nesh := Ashtar.halo(Color(baz[i][1]), 26.0)
                nesh.position = Vector2(60, 74)
                kart.add_child(nesh)
                var shomare := Label.new()
                shomare.text = Ashtar.fa(i + 1)
                shomare.add_theme_font_override("font", fon_l)
                shomare.add_theme_font_size_override("font_size", 44)
                shomare.add_theme_color_override("font_color", Color(baz[i][1]))
                shomare.position = Vector2(40, 44)
                kart.add_child(shomare)
                _matn_farzand(kart, baz[i][0], fon_l, 38, Color("#ffffff"), Vector2(24, 150), 296, HORIZONTAL_ALIGNMENT_RIGHT)
                _matn_farzand(kart, baz[i][2], fon_v, 19, Color("#c7d2ea"), Vector2(24, 216), 296, HORIZONTAL_ALIGNMENT_RIGHT)
                _matn_farzand(kart, baz[i][3], fon_b, 15, Color(baz[i][1], 0.9), Vector2(24, 352), 296, HORIZONTAL_ALIGNMENT_RIGHT)


func _matn_farzand(valed: Control, matn: String, fon: FontFile, andaze: int, rang: Color, pos: Vector2, arz: float, hamr: int) -> Label:
        var l := Label.new()
        l.text = matn
        l.add_theme_font_override("font", fon)
        l.add_theme_font_size_override("font_size", andaze)
        l.add_theme_color_override("font_color", rang)
        l.position = pos
        l.horizontal_alignment = hamr
        l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        l.size = Vector2(arz, andaze * 3)
        valed.add_child(l)
        return l


func _paen_besaz() -> void:
        _matn("اسکرین‌شات‌های هر بازی، واقعی و از اجرای زندهٔ گودوت است — پوشهٔ download/screenshots_modern_2d", fon_v, 18, Color("#6f7fa0"), Vector2(0, 668), W)


func _process(delta: float) -> void:
        t += delta
        for h in halha:
                var faz: float = h.get_meta("faz")
                h.position.y += sin(t * 0.7 + faz) * 0.3
                h.position.x += cos(t * 0.5 + faz) * 0.2
        for s in setara:
                s.modulate.a = 0.4 + 0.35 * sin(t * 2.0 + float(s.get_meta("faz")))
        if aks:
                aks_i = Ashtar.aks_ravat(self, t0, aks_plan, aks_i)
