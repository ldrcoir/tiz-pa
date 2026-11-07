extends CharacterBody2D
# دزدِ دیگ — پیراهن راه‌راه، کلاه کپ قرمز برعکس، گونیِ غارت روی شانه
# همیشه رو به جلو می‌دود؛ در شکاف‌ها می‌پرد؛ آخر پشت‌بام بن‌بست است و می‌ماند

const JENES := 1500.0

var halat := "farar"             # farar | gereftan
var fase := 0.0
var mesh := 1.0
var nisbat := Vector2.ONE
var nav_idx := 0
var didan := false               # هنوز هلیا را ندیده — ایستاده و بی‌خیال

func _ready() -> void:
        var shekl := CollisionShape2D.new()
        var kapsol := CapsuleShape2D.new()
        kapsol.radius = 13.0
        kapsol.height = 44.0
        shekl.shape = kapsol
        shekl.position = Vector2(0, -22)
        add_child(shekl)

func _physics_process(delta: float) -> void:
        var reeshe = get_parent()
        if halat == "gereftan":
                # دست‌ها بالا — بازی تمام
                velocity.x = move_toward(velocity.x, 0.0, 3000.0 * delta)
                velocity.y += JENES * delta
                move_and_slide()
                nisbat = nisbat.lerp(Vector2(1.06, 0.94), 6.0 * delta)
                queue_redraw()
                return
        var sorat := 0.0
        if not didan:
                # تا وقتی هلیا نزدیک نشده، همان‌جا گج‌می‌خورد
                if reeshe.helia.global_position.x > global_position.x - 380.0:
                        didan = true
        elif global_position.x < reeshe.TOL - 360.0:
                sorat = 310.0                     # فرار تا بن‌بستِ آخر پشت‌بام
        velocity.x = sorat
        velocity.y += JENES * delta
        # پرش در شکاف‌ها با نقاط تعیین‌شده + کمکِ دیوارگیر
        var nav: Array = reeshe.nav_dozd
        if is_on_floor():
                if nav_idx < nav.size() and position.x > float(nav[nav_idx]) - 32.0 and sorat > 0.0:
                        velocity.y = -720.0
                        nav_idx += 1
                elif sorat > 0.0 and is_on_wall():
                        velocity.y = -720.0       # پلهٔ بلندتر — بپر بالا
        move_and_slide()
        # اگر در شکاف افتاد، دوباره بالا می‌آید و فرار را ادامه می‌دهد
        if position.y > 880.0:
                var s: Dictionary = reeshe.safhe_yab(position.x)
                position = Vector2(clampf(position.x, s.x0 + 50.0, s.x1 - 50.0), s.y - 6.0)
                velocity = Vector2.ZERO
                nav_idx = 0
                for k in nav.size():
                        if float(nav[k]) > position.x:
                                nav_idx = k
                                break
        mesh = 1.0
        fase += delta * (13.0 if sorat > 0.0 else 4.0)
        if sorat == 0.0:
                nisbat = Vector2(1.0 + sin(fase * 2.0) * 0.03, 1.0)   # نفس‌نفس‌زدن
        else:
                nisbat = nisbat.lerp(Vector2.ONE, 8.0 * delta)
        queue_redraw()

func _draw() -> void:
        var zaman := Time.get_ticks_msec() / 1000.0
        var pust := Color(0.93, 0.75, 0.60)
        var safid := Color(0.88, 0.86, 0.82)
        var rakhrah := Color(0.78, 0.28, 0.32)
        var shalvar := Color(0.22, 0.24, 0.32)
        var goni := Color(0.55, 0.42, 0.28)
        var kolo := Color(0.82, 0.25, 0.28)
        var f := Vector2(mesh, 1.0) * nisbat
        var zin := sin(fase) * 0.9
        var gonibob := sin(fase * 0.9) * 1.6
        # پاها
        draw_set_transform(Vector2(-4.0 * mesh, -18.0), -zin * 0.85 * mesh, nisbat)
        draw_rect(Rect2(-3.5, -2, 7, 14), shalvar.darkened(0.2))
        draw_rect(Rect2(-3.5, 10, 7, 6), Color(0.85, 0.85, 0.85))
        draw_set_transform(Vector2(4.0 * mesh, -18.0), zin * 0.85 * mesh, nisbat)
        draw_rect(Rect2(-3.5, -2, 7, 14), shalvar)
        draw_rect(Rect2(-3.5, 10, 7, 6), Color(0.90, 0.90, 0.90))
        # بازوی عقب
        draw_set_transform(Vector2(-7.0 * mesh, -40.0), -zin * 1.2 * mesh, nisbat)
        draw_rect(Rect2(-2.5, -2, 5, 14), safid.darkened(0.1))
        # گونی غارت روی شانهٔ عقب
        draw_circle(Vector2(-12.0 * mesh, -32 + gonibob), 9.0, goni)
        draw_circle(Vector2(-12.0 * mesh, -41 + gonibob), 3.2, goni.darkened(0.25))
        # تنهٔ راه‌راه
        draw_set_transform(Vector2.ZERO, 0, f)
        draw_rect(Rect2(-10, -44, 20, 26), safid)
        draw_rect(Rect2(-10, -40, 20, 3), rakhrah)
        draw_rect(Rect2(-10, -33, 20, 3), rakhrah)
        draw_rect(Rect2(-10, -26, 20, 3), rakhrah)
        # بازوی جلو — اگر گرفته شده باشد دست‌ها بالا
        if halat == "gereftan":
                draw_set_transform(Vector2(7.0 * mesh, -44.0), PI, nisbat)
                draw_rect(Rect2(-2.5, -2, 5, 15), safid)
                draw_circle(Vector2(0, 14), 3.0, pust)
                draw_set_transform(Vector2(-7.0 * mesh, -44.0), PI, nisbat)
                draw_rect(Rect2(-2.5, -2, 5, 15), safid.darkened(0.1))
                draw_circle(Vector2(0, 14), 3.0, pust)
        else:
                draw_set_transform(Vector2(7.0 * mesh, -40.0), zin * 1.2 * mesh, nisbat)
                draw_rect(Rect2(-2.5, -2, 5, 15), safid)
                draw_circle(Vector2(0, 14), 3.0, pust)
        # سر و کلاه کپ برعکس
        draw_set_transform(Vector2.ZERO, 0, f)
        draw_circle(Vector2(1.0 * mesh, -51), 8.5, pust)
        draw_rect(Rect2(-8, -61, 16, 6), kolo)
        draw_rect(Rect2(-14 * mesh - 6.0 * mesh, -57, 8, 3), kolo.darkened(0.15))
        draw_circle(Vector2(0, -62), 2.0, kolo.darkened(0.25))
        # چشم نگران
        draw_circle(Vector2(5.0 * mesh, -52), 1.2, Color(0.15, 0.12, 0.12))
        # قطرهٔ عرق هنگام ایستادن در بن‌بست
        if halat != "gereftan" and fase > 0.0 and absf(velocity.x) < 5.0:
                var al := 0.5 + 0.5 * sin(zaman * 6.0)
                draw_circle(Vector2(10.0 * mesh, -58 - fposmod(zaman * 14.0, 10.0)), 2.0, Color(0.6, 0.8, 1.0, 0.7 * al))
        draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
