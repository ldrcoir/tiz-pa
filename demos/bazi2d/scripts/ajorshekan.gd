# ═══════════════════════════════════════════════════════════════
#  آجرشکن کاشی — بریک‌اوت با رنگ‌های کاشی‌کاری ایرانی
#  فیروزه، لاجورد، زعفران و آجری؛ ذرات، رد توپ، شکستن دومرحله‌ای
# ═══════════════════════════════════════════════════════════════
extends Node2D

const MASIR_AKS := "/home/z/my-project/download/screenshots_2d"
const SATR := 7
const SOTON := 10
const T_KASHI := Vector2(112, 34)
const FASELE := 6.0
const SHETAB_TOP := 470.0

var fnt: FontFile = null
var fnt_tiz: FontFile = null
var argha: Array = []
var aks_mode := false
var t_test := 0.0
var aks_gerefte := {}

var kashiha: Array = []          # {ja, rang, hp, satr}
var top_ja := Vector2(640, 500)
var top_sokhte := Vector2(0.42, -1.0).normalized()
var lagani_x := 640.0
var rad := 9.0
var emtiaz := 0
var jan := 3
var zaman := 0.0
var raftari: Array = []          # رد توپ
var bord := false

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
        _kashi_benaz()

# رنگ‌های کاشی‌کاری: زعفران، فیروزه، لاجورد، آجری، صدف صل‌سفید
func _kashi_benaz() -> void:
        kashiha.clear()
        var rangha := [Color("e9b44c"), Color("17a398"), Color("1c448e"), Color("c0392b"), Color("e8e4d8"), Color("7c4dff"), Color("17a398")]
        var x0 := (1280.0 - float(SOTON) * T_KASHI.x - float(SOTON - 1) * FASELE) / 2.0
        for r in SATR:
                for c in SOTON:
                        kashiha.append({
                                "ja": Vector2(x0 + float(c) * (T_KASHI.x + FASELE), 110.0 + float(r) * (T_KASHI.y + FASELE)),
                                "rang": rangha[r % rangha.size()],
                                "hp": 2 if r < 2 else 1,
                                "satr": r
                        })
        bord = false

func _label_besaz(matn: String, fon: FontFile, andaze: int, rang: Color, ja: Vector2) -> Label:
        var l := Label.new()
        l.text = matn
        l.position = ja
        l.add_theme_font_override("font", fon)
        l.add_theme_font_size_override("font_size", andaze)
        l.add_theme_color_override("font_color", rang)
        l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
        l.add_theme_constant_override("shadow_offset_x", 2)
        l.add_theme_constant_override("shadow_offset_y", 3)
        l.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(l)
        return l

var matne_emtiaz: Label
var matne_jan: Label

func _process(dt: float) -> void:
        zaman += dt
        # اتوپایلوت: تخته با کمی تأخیر دنبال توپ می‌آید — مثل بازیکن واقعی
        lagani_x = lerpf(lagani_x, top_ja.x, minf(dt * 9.0, 1.0))
        lagani_x = clampf(lagani_x, 90, 1190)
        _top_tike(dt)
        _raft_tike(dt)
        if top_ja.y > 780:
                jan -= 1
                top_ja = Vector2(lagani_x, 640)
                top_sokhte = Vector2(randf_range(-0.35, 0.35), -1.0).normalized()
        var zande := 0
        for k in kashiha:
                if k["hp"] > 0:
                        zande += 1
        if zande == 0 and not bord:
                bord = true
                emtiaz += 50
                get_tree().create_timer(1.2).timeout.connect(func(): _kashi_benaz())
                bord = false
        if matne_emtiaz != null:
                matne_emtiaz.text = "امتیاز " + _fa(emtiaz)
                matne_jan.text = "جان " + _fa(jan)
        queue_redraw()
        if aks_mode:
                t_test += dt
                for m in [[2.6, "ajorshekan_1"], [5.6, "ajorshekan_2"]]:
                        if t_test > float(m[0]) and not aks_gerefte.has(m[1]):
                                aks_gerefte[m[1]] = true
                                _aks_begir(MASIR_AKS + "/" + m[1] + ".png")
                if t_test > 7.2:
                        print("[demo2d] AJORSHEKAN DONE emtiaz=", emtiaz)
                        get_tree().quit()

func _top_tike(dt: float) -> void:
        # دو گام کوچک در هر فریم — تا توپ از کاشی ناگهانی رد نشود
        for gham in 2:
                var gh: float = dt / 2.0
                top_ja += top_sokhte * SHETAB_TOP * gh
                # دیوارها
                if top_ja.x < rad + 4.0:
                        top_ja.x = rad + 4.0
                        top_sokhte.x = absf(top_sokhte.x)
                if top_ja.x > 1276.0 - rad:
                        top_ja.x = 1276.0 - rad
                        top_sokhte.x = -absf(top_sokhte.x)
                if top_ja.y < 96.0 + rad:
                        top_ja.y = 96.0 + rad
                        top_sokhte.y = absf(top_sokhte.y)
                # تخته — زاویه‌ی برگشت به جایی که توپ می‌خورد بستگی دارد
                if top_sokhte.y > 0.0 and top_ja.y > 668.0 - rad and top_ja.y < 694.0:
                        var of := (top_ja.x - lagani_x) / 75.0
                        if absf(of) <= 1.1:
                                var zavie := of * (PI / 3.0)
                                top_sokhte = Vector2(sin(zavie), -cos(zavie))
                                top_ja.y = 668.0 - rad
                # کاشی‌ها — فقط یکی در هر گام
                for k in kashiha:
                        if k["hp"] <= 0:
                                continue
                        var most := Rect2(k["ja"], T_KASHI).grow(rad)
                        if most.has_point(top_ja):
                                var chp: float = minf(top_ja.x - most.position.x, most.end.x - top_ja.x)
                                var vchp: float = minf(top_ja.y - most.position.y, most.end.y - top_ja.y)
                                if vchp < chp:
                                        top_sokhte.y = -top_sokhte.y
                                else:
                                        top_sokhte.x = -top_sokhte.x
                                k["hp"] -= 1
                                if k["hp"] <= 0:
                                        emtiaz += 5 + (SATR - int(k["satr"]))
                                        _zarre_besaz(k["ja"], k["rang"])
                                break

func _raft_tike(dt: float) -> void:
        raftari.append(top_ja)
        if raftari.size() > 14:
                raftari.pop_front()

func _zarre_besaz(ja: Vector2, rang: Color) -> void:
        var p := CPUParticles2D.new()
        p.position = ja + T_KASHI / 2.0
        p.amount = 22
        p.one_shot = true
        p.explosiveness = 1.0
        p.lifetime = 0.55
        p.direction = Vector2(0, 1)
        p.spread = 180.0
        p.gravity = Vector2(0, 420)
        p.initial_velocity_min = 90.0
        p.initial_velocity_max = 260.0
        p.scale_amount_min = 2.0
        p.scale_amount_max = 4.5
        p.color = rang
        add_child(p)
        p.emitting = true
        get_tree().create_timer(0.9).timeout.connect(func(): p.queue_free())

func _aks_begir(masir: String) -> void:
        var aks := get_viewport().get_texture().get_image()
        if aks != null:
                aks.save_png(masir)
                print("[demo2d] SHOT ", masir)

func _ready_hud() -> void:
        pass

# ═══════════ نقاشی ═══════════
func _draw() -> void:
        # زمین تیره با شبکه‌ی کم‌رنگ
        draw_rect(Rect2(0, 0, 1280, 720), Color("0a1220"))
        for x in range(0, 1281, 80):
                draw_line(Vector2(float(x), 0), Vector2(float(x), 720), Color(1, 1, 1, 0.035), 1.0)
        for y in range(0, 721, 80):
                draw_line(Vector2(0, float(y)), Vector2(1280, float(y)), Color(1, 1, 1, 0.035), 1.0)
        # خط بالای HUD
        draw_line(Vector2(0, 96), Vector2(1280, 96), Color("ffd94a"), 3.0)
        # کاشی‌ها — دو رنگ برای دو جانِ کاشی، شکسته‌ها با ترک
        for k in kashiha:
                if k["hp"] <= 0:
                        continue
                var rang: Color = k["rang"] if int(k["hp"]) == 2 else k["rang"].lightened(0.22)
                draw_rect(Rect2(k["ja"], T_KASHI), rang)
                draw_rect(Rect2(k["ja"], T_KASHI), rang.lightened(0.3), false, 2.0)
                if int(k["hp"]) == 1 and k["satr"] != null:
                        draw_line(k["ja"] + Vector2(T_KASHI.x * 0.3, 4), k["ja"] + Vector2(T_KASHI.x * 0.7, T_KASHI.y - 4), Color(0, 0, 0, 0.35), 2.0)
        # رد توپ — نقاط محو‌شونده
        for i in raftari.size():
                draw_circle(raftari[i], 4.0 + float(i) * 0.3, Color(1, 1, 1, 0.05 + 0.035 * float(i)))
        # توپ با هاله
        draw_circle(top_ja, 15.0, Color(1, 1, 1, 0.18))
        draw_circle(top_ja, rad, Color("fdfdfd"))
        # تخته — فیروزه با لبه‌ی تیره
        draw_rect(Rect2(Vector2(lagani_x - 78, 668), Vector2(156, 18)), Color("00e5ff"))
        draw_rect(Rect2(Vector2(lagani_x - 78, 684), Vector2(156, 4)), Color("008ba3"))

func _init() -> void:
        call_deferred("_hud_chand")
