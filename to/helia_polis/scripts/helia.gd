extends CharacterBody2D
# هلیا — پلیسِ پشت‌بام‌ها: یونیفرم سرمه‌ای، نوار شبرنگ طلایی، مقنعهٔ روان
# حرکت با کوایوت‌تایم و بافر پرش؛ اسکواش/استرچ و غبار دویدن برای جوس

const JENES := 1500.0            # جاذبه
const SORAT := 330.0             # سرعت دویدن
const PARSH := -700.0            # قدرت پرش
const KOYOT := 0.12              # زمان کوایوت — رها شدن از لبه هنوز پرش می‌دهد
const SAF := 0.12                # بافر پرش — فشارِ زودتر هم شمرده می‌شود

var khod_peyma := false          # خلبان خودکار برای دمو و اسکرین‌شات
var fase := 0.0                  # فاز انیمیشن دویدن
var mesh := 1.0                  # جهت نگاه: ۱ راست، -۱ چپ
var zaman_labe := 0.0            # تایمر کوایوت
var zaman_saf := 0.0             # تایمر بافر پرش
var parsh_ghabli := false        # وضعیت دکمهٔ پرش در فریم قبل
var nisbat := Vector2.ONE        # اسکواش/استرچ بدن
var nav_idx := 0                 # اندیس نقطهٔ پرش خلبان خودکار
var donbale := PackedVector2Array()  # نقاط دنبالهٔ مقنعه در فضای جهان

func _ready() -> void:
        # برخورد کپسولی — مبدأ روی کف پا
        var shekl := CollisionShape2D.new()
        var kapsol := CapsuleShape2D.new()
        kapsol.radius = 15.0
        kapsol.height = 50.0
        shekl.shape = kapsol
        shekl.position = Vector2(0, -25)
        add_child(shekl)
        # غبار دویدن
        var ghubar := CPUParticles2D.new()
        ghubar.amount = 12
        ghubar.lifetime = 0.45
        ghubar.emitting = false
        ghubar.position = Vector2(0, -4)
        ghubar.direction = Vector2(-1, -0.5)
        ghubar.spread = 34.0
        ghubar.initial_velocity_min = 40.0
        ghubar.initial_velocity_max = 95.0
        ghubar.gravity = Vector2(0, 240)
        ghubar.scale_amount_min = 2.0
        ghubar.scale_amount_max = 4.6
        ghubar.color = Color(0.85, 0.78, 0.72, 0.45)
        add_child(ghubar)
        set_meta("ghubar", ghubar)
        # دنبالهٔ مقنعه — شش بند
        donbale.resize(6)
        for i in 6:
                donbale[i] = global_position + Vector2(0, -50)

func _physics_process(delta: float) -> void:
        var reeshe = get_parent()
        var mehr := 0.0
        var feshorde := false
        var raha := false
        if khod_peyma:
                # خلبان خودکار: همیشه رو به جلو، پرش در نقاط ازپیش‌تعیین‌شدهٔ شکاف‌ها
                if position.x < reeshe.TOL - 300.0:
                        mehr = 1.0
                var nav: Array = reeshe.navarti
                if reeshe.halat_bazi == "bord":
                        mehr = 0.0                 # مأموریت تمام — هلیا می‌ایستد
                if is_on_floor() and nav_idx < nav.size() and position.x > float(nav[nav_idx]) - 32.0:
                        feshorde = true
                        nav_idx += 1
        else:
                var chap := Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A)
                var rast := Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D)
                mehr = float(rast) - float(chap)
                var parsh := Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W)
                feshorde = parsh and not parsh_ghabli
                raha = (not parsh) and parsh_ghabli
                parsh_ghabli = parsh
        # فیزیک افقی و عمودی
        velocity.x = move_toward(velocity.x, mehr * SORAT, 2600.0 * delta)
        velocity.y += JENES * delta
        zaman_labe = KOYOT if is_on_floor() else zaman_labe - delta
        zaman_saf = SAF if feshorde else zaman_saf - delta
        if zaman_saf > 0.0 and zaman_labe > 0.0:
                velocity.y = PARSH
                zaman_saf = 0.0
                zaman_labe = 0.0
                nisbat = Vector2(0.78, 1.22)      # کش آمدن هنگام پرش
        if raha and velocity.y < 0.0:
                velocity.y *= 0.55                # پرش متغیر — رها کردن، پرش را کوتاه می‌کند
        var bud_zamin := is_on_floor()
        move_and_slide()
        if is_on_floor() and not bud_zamin:
                nisbat = Vector2(1.24, 0.76)      # له شدن هنگام فرود
                reeshe.lershe = maxf(reeshe.lershe, 4.0)
        # انیمیشن دویدن
        if absf(velocity.x) > 12.0:
                mesh = signf(velocity.x)
                if is_on_floor():
                        fase += delta * 13.0
                        (get_meta("ghubar") as CPUParticles2D).emitting = true
                else:
                        (get_meta("ghubar") as CPUParticles2D).emitting = false
        else:
                (get_meta("ghubar") as CPUParticles2D).emitting = false
        nisbat = nisbat.lerp(Vector2.ONE, 10.0 * delta)
        # ورلهٔ سادهٔ دنبالهٔ مقنعه
        donbale[0] = global_position + Vector2(-mesh * 4.0, -52.0)
        var zaman := Time.get_ticks_msec() / 1000.0
        for i in range(1, 6):
                var hadaf: Vector2 = donbale[i - 1] + Vector2(-mesh * 8.0, 2.5 + sin(zaman * 7.0 + i) * 1.8)
                donbale[i] = donbale[i].lerp(hadaf, 0.40)
        queue_redraw()

func _draw() -> void:
        var zaman := Time.get_ticks_msec() / 1000.0
        var maqnaeh := Color(0.10, 0.13, 0.22)
        var yoniform := Color(0.16, 0.22, 0.36)
        var yoniform_tarik := Color(0.12, 0.17, 0.28)
        var shalvar := Color(0.15, 0.18, 0.27)
        var pust := Color(0.96, 0.80, 0.66)
        var talaii := Color(1.0, 0.83, 0.42)
        # دنبالهٔ مقنعه — در فضای جهان، بدون فلیپ
        for i in range(5, 0, -1):
                draw_circle(to_local(donbale[i]), 3.0 + (6 - i) * 1.7, Color(maqnaeh.r, maqnaeh.g, maqnaeh.b, 0.92 - i * 0.09))
        var zin := sin(fase) * 0.85
        var f := Vector2(mesh, 1.0) * nisbat
        # پای عقب و جلو — چرخش دور لگن
        draw_set_transform(Vector2(-4.0 * mesh, -20.0), -zin * 0.8 * mesh, nisbat)
        draw_rect(Rect2(-3.5, -2, 7, 16), shalvar.darkened(0.25))
        draw_rect(Rect2(-3.5, 12, 7, 6), Color(0.07, 0.08, 0.12))
        draw_set_transform(Vector2(4.0 * mesh, -20.0), zin * 0.8 * mesh, nisbat)
        draw_rect(Rect2(-3.5, -2, 7, 16), shalvar)
        draw_rect(Rect2(-3.5, 12, 7, 6), Color(0.09, 0.10, 0.15))
        # بازوی عقب
        draw_set_transform(Vector2(-7.0 * mesh, -42.0), -zin * 1.15 * mesh, nisbat)
        draw_rect(Rect2(-2.5, -2, 5, 15), yoniform_tarik)
        draw_circle(Vector2(0, 14), 3.0, pust)
        # تنه با یونیفرم و نوار شبرنگ
        draw_set_transform(Vector2.ZERO, 0, f)
        draw_rect(Rect2(-11, -46, 22, 28), yoniform)
        draw_rect(Rect2(-11, -36, 22, 3.5), talaii)
        draw_rect(Rect2(-11, -28, 22, 2.0), Color(talaii.r, talaii.g, talaii.b, 0.65))
        draw_circle(Vector2(3.0 * mesh, -40), 2.2, talaii)
        draw_rect(Rect2(-2.0 * mesh - 3.0, -46, 6, 5), yoniform_tarik)
        # بازوی جلو
        draw_set_transform(Vector2(7.0 * mesh, -42.0), zin * 1.15 * mesh, nisbat)
        draw_rect(Rect2(-2.5, -2, 5, 15), yoniform)
        draw_circle(Vector2(0, 14), 3.0, pust)
        # سر، مقنعه و بازِ صورت
        draw_set_transform(Vector2.ZERO, 0, f)
        draw_circle(Vector2(1.5 * mesh, -54), 9.5, pust)
        draw_circle(Vector2(0, -55), 11.5, maqnaeh)
        draw_circle(Vector2(0, -49), 10.0, maqnaeh)
        draw_circle(Vector2(5.5 * mesh, -51), 6.2, pust)
        # چشمک کوچک — نفسِ کاراکتر
        draw_circle(Vector2(7.0 * mesh, -53 + sin(zaman * 2.0) * 0.4), 1.1, Color(0.15, 0.12, 0.12))
        draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
