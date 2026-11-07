extends Node2D
## «کتابچه» — صفحه‌های معرفیِ سه‌گانهٔ نور
## هر صفحه رندر و PNG می‌شود؛ بعداً با پایتون به PDF چسبانده می‌شود.

const Ashtar = preload("res://scripts/ashtar.gd")
const W := 1280.0
const H := 720.0
const DIR := "/home/z/my-project/download/screenshots_modern_2d"

var fon_l: FontFile
var fon_b: FontFile
var fon_v: FontFile
var saf: Node2D = null
var saf_ha := []
var i_jari := -1
var t0 := 0
var t_jari := 0.0
var zakhire_shod := false


func _ready() -> void:
        fon_l = Ashtar.fon("res://assets/fonts/Lalezar-Regular.ttf")
        fon_b = Ashtar.fon("res://assets/fonts/Vazirmatn-Bold.ttf")
        fon_v = Ashtar.fon("res://assets/fonts/Vazirmatn-Regular.ttf")
        saf_ha = [
                {"noe": "jeld"},
                {"noe": "bazi", "onvan": "مدار", "rang": "#35e0ff", "zir": "پرش مداری تک‌لمسی — رها شو، در هستهٔ بعدی به دام بیفتد", "aks": ["madar_1.png", "madar_2.png"], "vijehi": ["پرش مداری با هندسهٔ واقعی", "دنبالهٔ نورانیِ زنده و محوشونده", "زنجیرهٔ هسته‌ها و کمبوی امتیاز", "تخم‌های نور + تیغه‌های چرخان"], "kontrol": "کنترل: یک لمس/کلیک — رها شدن از مدار"},
                {"noe": "bazi", "onvan": "شب‌تاب", "rang": "#ffe98a", "zir": "بقا در باغِ تاریک — هالهٔ نورِ تو جانِ بازیه", "aks": ["shabtab_1.png", "shabtab_2.png"], "vijehi": ["هالهٔ نور نفس می‌کشد و کم می‌شود", "سایه‌ها فقط در نور پیدا می‌شوند", "باغ زنده: علف، گل شب‌زنده، گرده", "برخورد سایه = فلاش سرخ و لرزش"], "kontrol": "کنترل: حرکت موس/لمس — شب‌تاب دنبالت می‌آید"},
                {"noe": "bazi", "onvan": "بادبادک تهران", "rang": "#ff7a9c", "zir": "نخ‌بازی روی پشت‌بام‌ها — فیزیک واقعی نخ و باد", "aks": ["badbadek_1.png", "badbadek_2.png"], "vijehi": ["نخِ ۱۵ گرهی با فیزیک ورله", "نسیم و تندبادِ متغیر", "غروب تهران + برج میلاد در افق", "دم پاپیونی، کلاغ‌ها و تخمِ نور"], "kontrol": "کنترل: حرکت موس/لمس — راه رفتن با نخ روی پشت‌بام"},
        ]
        t0 = Time.get_ticks_msec()
        _saf_badi()


func _saf_badi() -> void:
        i_jari += 1
        t_jari = 0.0
        zakhire_shod = false
        if saf != null:
                saf.queue_free()
        saf = Node2D.new()
        add_child(saf)
        if i_jari >= saf_ha.size():
                return
        var d: Dictionary = saf_ha[i_jari]
        if d.noe == "jeld":
                _jeld_besaz()
        else:
                _saf_bazi_besaz(d)


func _halo_saf(pos: Vector2, rang: Color, shoa: float) -> void:
        var h := Ashtar.halo(rang, shoa, 2.0)
        h.modulate.a = 0.4
        h.position = pos
        saf.add_child(h)


func _matn_saf(matn: String, fon: FontFile, andaze: int, rang: Color, pos: Vector2, arz: float, hamr: int = HORIZONTAL_ALIGNMENT_RIGHT) -> Label:
        var l := Label.new()
        l.text = matn
        l.add_theme_font_override("font", fon)
        l.add_theme_font_size_override("font_size", andaze)
        l.add_theme_color_override("font_color", rang)
        l.position = pos
        l.horizontal_alignment = hamr
        l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        l.size = Vector2(arz, andaze * 3)
        saf.add_child(l)
        return l


func _jeld_besaz() -> void:
        var zamin := ColorRect.new()
        zamin.color = Color("#07070f")
        zamin.size = Vector2(W, H)
        saf.add_child(zamin)
        _halo_saf(Vector2(280, 220), Color("#3a1c71"), 260.0)
        _halo_saf(Vector2(1000, 500), Color("#0f5c6b"), 240.0)
        _halo_saf(Vector2(860, 160), Color("#7a1f4d"), 200.0)
        var ashk := Ashtar.halo(Color("#ffd24d"), 70.0)
        ashk.position = Vector2(W * 0.5, 250)
        saf.add_child(ashk)
        _matn_saf("سه‌گانهٔ نور", fon_l, 104, Color("#fff6df"), Vector2(0, 196), W, HORIZONTAL_ALIGNMENT_CENTER)
        _matn_saf("سه تجربهٔ دوبعدی مدرن: مدار، شب‌تاب، بادبادک تهران", fon_v, 28, Color("#9fb2d8"), Vector2(0, 330), W, HORIZONTAL_ALIGNMENT_CENTER)
        _matn_saf("همه با گودوت ۴ و کدِ دست‌نویس — بدون موتور آماده و بدون کپیِ بازی قدیمی", fon_v, 22, Color("#6f7fa0"), Vector2(0, 388), W, HORIZONTAL_ALIGNMENT_CENTER)
        ## نوار سه اسکرین‌شات واقعی از سه بازی
        var mini := ["madar_1.png", "shabtab_1.png", "badbadek_1.png"]
        for i in mini.size():
                var img := Image.load_from_file(DIR.path_join(mini[i]))
                if img == null:
                        continue
                var tex := ImageTexture.create_from_image(img)
                var tr := TextureRect.new()
                tr.texture = tex
                tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
                tr.stretch_mode = TextureRect.STRETCH_SCALE
                var arz := 368.0
                var mast := arz / float(tex.get_width())
                tr.size = Vector2(arz, float(tex.get_height()) * mast)
                tr.position = Vector2(60.0 + float(i) * 396.0, 440.0)
                saf.add_child(tr)
        _matn_saf("آبان ۱۴۰۵ — اسکرین‌شات‌های این کتابچه، واقعی و از اجرای زندهٔ گودوت‌اند", fon_b, 20, Color("#8fa3c7"), Vector2(0, 668), W, HORIZONTAL_ALIGNMENT_CENTER)


func _saf_bazi_besaz(d: Dictionary) -> void:
        var zamin := ColorRect.new()
        zamin.color = Color("#090a12")
        zamin.size = Vector2(W, H)
        saf.add_child(zamin)
        _halo_saf(Vector2(1100, 120), Color(d.rang), 200.0)
        ## نوار سربرگ کم‌رنگ
        var noghte := ColorRect.new()
        noghte.color = Color(d.rang, 0.08)
        noghte.position = Vector2.ZERO
        noghte.size = Vector2(W, 136)
        saf.add_child(noghte)
        ## سربرگ
        _matn_saf(d.onvan, fon_l, 56, Color(d.rang), Vector2(920, 24), 340, HORIZONTAL_ALIGNMENT_RIGHT)
        _matn_saf(d.zir, fon_v, 21, Color("#c7d2ea"), Vector2(120, 96), 1140, HORIZONTAL_ALIGNMENT_RIGHT)
        ## قاب اسکرین‌شات (دو عکس روی همِ مورب)
        var box := Rect2(56, 150, 850, 500)
        var aks_ha: Array = d.aks
        for i in aks_ha.size():
                var masir := DIR.path_join(aks_ha[i])
                var img := Image.load_from_file(masir)
                if img == null:
                        continue
                var tex := ImageTexture.create_from_image(img)
                var tr := TextureRect.new()
                tr.texture = tex
                tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
                tr.stretch_mode = TextureRect.STRETCH_SCALE
                var mast := minf(box.size.x / float(tex.get_width()), box.size.y / float(tex.get_height()))
                var andaze := Vector2(float(tex.get_width()) * mast, float(tex.get_height()) * mast)
                tr.size = andaze
                tr.position = box.position + (box.size - andaze) * 0.5 + Vector2(float(i) * 26.0, float(i) * -26.0)
                saf.add_child(tr)
        ## ستون ویژگی‌ها
        _matn_saf("ویژگی‌ها", fon_l, 34, Color(d.rang), Vector2(910, 170), 330, HORIZONTAL_ALIGNMENT_RIGHT)
        var y := 232.0
        for v in d.vijehi:
                _matn_saf("◆  " + str(v), fon_v, 18, Color("#dbe4f5"), Vector2(900, y), 340)
                y += 76.0
        _matn_saf(d.kontrol, fon_b, 18, Color(d.rang), Vector2(56, 668), 1160, HORIZONTAL_ALIGNMENT_RIGHT)
        _matn_saf("سه‌گانهٔ نور — صفحهٔ " + Ashtar.fa(i_jari + 1) + " از " + Ashtar.fa(saf_ha.size()), fon_v, 16, Color("#6f7fa0"), Vector2(56, 20), 500, HORIZONTAL_ALIGNMENT_LEFT)


func _process(delta: float) -> void:
        t_jari += delta
        ## هر صفحه: ۰٫۹ ثانیه رندر، بعد ذخیره؛ پایان: بستن
        if not zakhire_shod and t_jari >= 0.9 and i_jari < saf_ha.size():
                Ashtar.shat(get_viewport(), "sahife_%d.png" % (i_jari + 1))
                zakhire_shod = true
        if t_jari >= 1.4:
                if i_jari + 1 >= saf_ha.size():
                        print("KETABCHE_TAMAM")
                        get_tree().quit()
                else:
                        _saf_badi()
