# ═══════════════════════════════════════════════════════════════
#  افعی باغ فردوس — مار کلاسیک روی چمن شطرنجی
#  اتوپایلوت دانه‌دانه‌ی راه میرود؛ سیب می‌خورد، رشد می‌کند، تندتر می‌شود
# ═══════════════════════════════════════════════════════════════
extends Node2D

const MASIR_AKS := "/home/z/my-project/download/screenshots_2d"
const SOTON := 32
const SATR := 14
const KHANE := 36
const OX := 64.0
const OY := 118.0

var fnt: FontFile = null
var fnt_tiz: FontFile = null
var argha: Array = []
var aks_mode := false
var t_test := 0.0
var aks_gerefte := {}

var mor: Array = []              # خانه‌ها — سر اول
var ger := Vector2i(1, 0)
var sib := Vector2i(20, 7)
var raste_mor := 0.0
var gham_zaman := 0.13
var emtiaz := 0
var rast_tan := 2                # چند خانه هنوز باید رشد کند
var zaman := 0.0

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
        _shorou()
        var matne_onvan := Label.new()
        matne_onvan.text = "افعی باغ فردوس"
        matne_onvan.position = Vector2(40, 26)
        matne_onvan.add_theme_font_override("font", fnt_tiz)
        matne_onvan.add_theme_font_size_override("font_size", 38)
        matne_onvan.add_theme_color_override("font_color", Color("a5d6a7"))
        matne_onvan.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
        matne_onvan.add_theme_constant_override("shadow_offset_x", 2)
        matne_onvan.add_theme_constant_override("shadow_offset_y", 3)
        add_child(matne_onvan)
        var matne_rahnama := Label.new()
        matne_rahnama.text = "سیب‌ها را بخور و بلندتر از همه شو"
        matne_rahnama.position = Vector2(40, 76)
        matne_rahnama.add_theme_font_override("font", fnt)
        matne_rahnama.add_theme_font_size_override("font_size", 20)
        matne_rahnama.add_theme_color_override("font_color", Color(1, 1, 1, 0.55))
        add_child(matne_rahnama)

func _shorou() -> void:
        mor.clear()
        var vasat := Vector2i(SOTON / 4, SATR / 2)
        for i in 5:
                mor.append(vasat - Vector2i(i, 0))
        ger = Vector2i(1, 0)
        gham_zaman = 0.13
        rast_tan = 0
        _sib_ejad()

func _sib_ejad() -> void:
        while true:
                var ja := Vector2i(randi() % SOTON, randi() % SATR)
                if not mor.has(ja):
                        sib = ja
                        break

func _process(dt: float) -> void:
        zaman += dt
        raste_mor += dt
        if raste_mor >= gham_zaman:
                raste_mor = 0.0
                _gham()
        queue_redraw()
        if aks_mode:
                t_test += dt
                for m in [[2.6, "afei_1"], [5.6, "afei_2"]]:
                        if t_test > float(m[0]) and not aks_gerefte.has(m[1]):
                                aks_gerefte[m[1]] = true
                                _aks_begir(MASIR_AKS + "/" + m[1] + ".png")
                if t_test > 7.2:
                        print("[demo2d] AFEI DONE emtiaz=", emtiaz)
                        get_tree().quit()

# اتوپایلوت: بین «مستقیم، چپ، راست» فقط مسیر امن را برمی‌گزیند
# و از میان آن‌ها نزدیک‌ترین به سیب را — ساده ولی گیر نمی‌کند
func _gham() -> void:
        var mohre: Array = [ger, _charkh(ger, -1), _charkh(ger, 1)]
        var entekhab := ger
        var behtarin := INF
        for g in mohre:
                var bad := mor[0] + g
                var bedaneh := false
                if bad.x < 0 or bad.y < 0 or bad.x >= SOTON or bad.y >= SATR:
                        bedaneh = true
                for i in mor.size() - 1:   # دم اگر رشد نکند جابه‌جا می‌شود — پس دم امن است
                        if mor[i] == bad:
                                bedaneh = true
                                break
                if bedaneh:
                        continue
                var fa := (bad - sib).length()
                if fa < behtarin:
                        behtarin = fa
                        entekhab = g
        ger = entekhab
        var sar := mor[0] + ger
        if sar.x < 0 or sar.y < 0 or sar.x >= SOTON or sar.y >= SATR or mor.has(sar):
                # گیر افتاد — بی‌صدا از نو
                _shorou()
                return
        mor.push_front(sar)
        if sar == sib:
                emtiaz += 10
                rast_tan += 2
                gham_zaman = maxf(gham_zaman - 0.004, 0.095)
                _sib_ejad()
        if rast_tan > 0:
                rast_tan -= 1
        else:
                mor.pop_back()

func _charkh(g: Vector2i, tav: int) -> Vector2i:
        return Vector2i(-g.y * tav, g.x * tav)

func _aks_begir(masir: String) -> void:
        var aks := get_viewport().get_texture().get_image()
        if aks != null:
                aks.save_png(masir)
                print("[demo2d] SHOT ", masir)

# ═══════════ نقاشی ═══════════
func _draw() -> void:
        # قاب چوبی حاشیه‌ی باغ
        draw_rect(Rect2(OX - 26, OY - 26, float(SOTON) * KHANE + 52.0, float(SATR) * KHANE + 52.0), Color("12100e"))
        draw_rect(Rect2(OX - 26, OY - 26, float(SOTON) * KHANE + 52.0, float(SATR) * KHANE + 52.0), Color("795548"), false, 10.0)
        # چمن شطرنجی — دو سبز نزدیک هم برای بافت نرم
        for r in SATR:
                for c in SOTON:
                        var rang := Color("1d3b24") if (r + c) % 2 == 0 else Color("22452a")
                        draw_rect(Rect2(OX + float(c) * KHANE, OY + float(r) * KHANE, KHANE, KHANE), rang)
        # سیب — بدنه، برگ، برق
        var makhraj := Vector2(OX + float(sib.x) * KHANE + KHANE / 2.0, OY + float(sib.y) * KHANE + KHANE / 2.0)
        draw_circle(makhraj, 14.0, Color("d32f2f"))
        draw_circle(makhraj + Vector2(-4, -5), 4.5, Color(1, 1, 1, 0.55))
        draw_rect(Rect2(makhraj + Vector2(2, -18), Vector2(9, 6)), Color("2e7d32"))
        # بدنه‌ی افعی — سبز متناوب، سر روشن‌تر با چشم
        for i in mor.size():
                var ja := Vector2(OX + float(mor[i].x) * KHANE, OY + float(mor[i].y) * KHANE)
                if i == 0:
                        draw_rect(Rect2(ja + Vector2(2, 2), Vector2(KHANE - 4, KHANE - 4)), Color("8bc34a"))
                else:
                        var bed := Color("4caf50") if i % 2 == 0 else Color("388e3c")
                        draw_rect(Rect2(ja + Vector2(3, 3), Vector2(KHANE - 6, KHANE - 6)), bed)
        var sar_ja := Vector2(OX + float(mor[0].x) * KHANE + KHANE / 2.0, OY + float(mor[0].y) * KHANE + KHANE / 2.0)
        var sorat := Vector2(ger) * 7.0
        var amudi := Vector2(-float(ger.y), float(ger.x)) * 8.0
        draw_circle(sar_ja + sorat + amudi, 4.0, Color.WHITE)
        draw_circle(sar_ja + sorat - amudi, 4.0, Color.WHITE)
        draw_circle(sar_ja + sorat * 1.3 + amudi, 2.0, Color.BLACK)
        draw_circle(sar_ja + sorat * 1.3 - amudi, 2.0, Color.BLACK)
        # HUD
        var matne := "امتیاز " + _fa(emtiaz) + "   طول " + _fa(mor.size())
        var l := get_meta("hud_matne", null)
        if l == null:
                l = Label.new()
                l.text = matne
                l.position = Vector2(820, 30)
                l.add_theme_font_override("font", fnt_tiz)
                l.add_theme_font_size_override("font_size", 34)
                l.add_theme_color_override("font_color", Color("ffd94a"))
                l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
                add_child(l)
                set_meta("hud_matne", l)
        else:
                l.text = matne
