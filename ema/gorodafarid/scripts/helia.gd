extends CharacterBody2D
# هلیا در نقشِ گردآفرید — دلاورِ دژِ سپید
# شمشیر و کمان و اسب؛ کوایوت‌تایم و بافر پرش و اسکواش/استرچ
# ورودی از بازی می‌آید (کیبورد + لمسی + خلبان خودکار) تا یک‌جا مدیریت شود

const JENES := 2400.0
const SORAT := 330.0
const SORAT_SAVARI := 590.0
const PARSH := -1000.0
const PARSH_SAVARI := -1180.0
const KOYOT := 0.12              # رها شدن از لبه هنوز پرش می‌دهد
const SAF := 0.14                # بافر پرش

const GERAM := 0.62                    # مقیاسِ هلیا

var bazi                         # صحنهٔ اصلی
var khod_peyma := false
var mesh := 1.0                  # جهت نگاه
var fase := 0.0                  # فاز انیمیشن دویدن
var nisbat := Vector2.ONE        # اسکواش/استرچ
var zaman_labe := 0.0
var zaman_saf := 0.0
var parsh_ghabli := false
var halat := "doid"              # doid | zadan | tirandaz | morde
var zaman_zadan := 0.0
var kosh_zadan := false          # ضربهٔ شمشیر اعمال شد؟
var zaman_tirandaz := 0.0
var tir_antal_shod := false
var zaman_sard_kaman := 0.0      # سردشدن کمان
var zaman_zakhmi := 0.0          # بی‌مرگی پس از ضربه
var savar := false               # سوار بر اسب است؟
var parsh_dovom := true          # پرشِ دومِ گردآفرید
var tex_doid: Texture2D
var tex_zadan: Texture2D
var tex_tirandaz: Texture2D
var tex_savare: Texture2D
var nmayesh: Sprite2D
var ghubar: CPUParticles2D
var zaman := 0.0

func _ready() -> void:
        # برخورد کپسولی — مبدأ روی کف پا
        var shekl := CollisionShape2D.new()
        var kapsol := CapsuleShape2D.new()
        kapsol.radius = 16.0
        kapsol.height = 54.0
        shekl.shape = kapsol
        shekl.position = Vector2(0, -27)
        add_child(shekl)
        tex_doid = load("res://assets/honar/gordafarid_doid.png")
        tex_zadan = load("res://assets/honar/gordafarid_zadan.png")
        tex_tirandaz = load("res://assets/honar/gordafarid_tirandaz.png")
        tex_savare = load("res://assets/honar/savare.png")
        nmayesh = Sprite2D.new()
        nmayesh.texture = tex_doid
        nmayesh.scale = Vector2(GERAM, GERAM)
        nmayesh.position = Vector2(0, -tex_doid.get_height() * GERAM * 0.5 + 6)
        add_child(nmayesh)
        # غبار دویدن و فرود
        ghubar = CPUParticles2D.new()
        ghubar.amount = 14
        ghubar.lifetime = 0.5
        ghubar.emitting = false
        ghubar.position = Vector2(0, -4)
        ghubar.direction = Vector2(-1, -0.6)
        ghubar.spread = 38.0
        ghubar.initial_velocity_min = 50.0
        ghubar.initial_velocity_max = 120.0
        ghubar.gravity = Vector2(0, 300)
        ghubar.scale_amount_min = 2.4
        ghubar.scale_amount_max = 5.4
        ghubar.color = Color(0.87, 0.80, 0.68, 0.5)
        add_child(ghubar)

func _physics_process(delta: float) -> void:
        zaman += delta
        var v: Dictionary
        if khod_peyma:
                v = bazi.vorudi_ai
        else:
                v = bazi.vorudi
        # ورودی افقی
        var mehr: float = v.get("rast", 0.0) - v.get("chap", 0.0)
        if halat == "morde":
                mehr = 0.0
        var hadaf_sorat: float = mehr * (SORAT_SAVARI if savar else SORAT)
        if (halat == "zadan" or halat == "tirandaz") and not savar:
                hadaf_sorat *= 0.25              # پیاده هنگام نبرد رکَب می‌ایستد — سوار با اسب می‌زند
        velocity.x = move_toward(velocity.x, hadaf_sorat, 2900.0 * delta)
        if absf(mehr) > 0.1 and zaman_zakhmi <= 0.0:
                mesh = signf(mehr)
        # پرش با کوایوت و بافر
        var feshorde: bool = v.get("parsh", false) and not parsh_ghabli
        var raha: bool = (not v.get("parsh", false)) and parsh_ghabli
        parsh_ghabli = v.get("parsh", false)
        velocity.y += JENES * delta
        zaman_labe = KOYOT if is_on_floor() else zaman_labe - delta
        zaman_saf = SAF if feshorde else zaman_saf - delta
        if zaman_saf > 0.0 and zaman_labe > 0.0 and halat != "morde":
                velocity.y = PARSH_SAVARI if savar else PARSH
                zaman_saf = 0.0
                zaman_labe = 0.0
                nisbat = Vector2(0.76, 1.24)
                parsh_dovom = true
                if halat == "zadan" or halat == "tirandaz":
                        halat = "doid"          # پرش، حمله را قطع می‌کند — لبهٔ چاه با تمامِ سرعت
                bazi.seda("parsh", -8.0)
        elif feshorde and not is_on_floor() and zaman_labe <= 0.0 and parsh_dovom and halat != "morde" and velocity.y > -160.0:
                # پرشِ دوم — چرخشِ دلیرانه در هوا
                velocity.y = (PARSH_SAVARI if savar else PARSH) * 0.92
                parsh_dovom = false
                nisbat = Vector2(0.74, 1.26)
                bazi.seda("parsh", -10.0)
        if raha and velocity.y < 0.0:
                velocity.y *= 0.55
        var bud_zamin := is_on_floor()
        move_and_slide()
        if is_on_floor() and not bud_zamin:
                nisbat = Vector2(1.26, 0.74)
                parsh_dovom = true
                lershe_kuchak()
        # افتادن در چاه
        if global_position.y > 980.0:
                bazi.soqot()
        # تایمرها
        zaman_sard_kaman = maxf(0.0, zaman_sard_kaman - delta)
        zaman_zakhmi = maxf(0.0, zaman_zakhmi - delta)
        nisbat = nisbat.lerp(Vector2.ONE, 10.0 * delta)
        # ── نبرد: شمشیر ──
        if v.get("shemshir", false) and halat == "doid" and zaman_zakhmi <= 0.0:
                halat = "zadan"
                zaman_zadan = 0.34
                kosh_zadan = false
                bazi.seda("shemshir", -4.0)
        if halat == "zadan":
                zaman_zadan -= delta
                if zaman_zadan < 0.22 and not kosh_zadan:
                        kosh_zadan = true
                        bazi.zarbe_doshmanha(global_position + Vector2(mesh * 74.0, -60.0), 92.0, 1)
                if zaman_zadan <= 0.0:
                        halat = "doid"
        # ── نبرد: کمان ──
        if v.get("kaman", false) and zaman_sard_kaman <= 0.0 and halat == "doid" and zaman_zakhmi <= 0.0:
                halat = "tirandaz"
                zaman_tirandaz = 0.30
                tir_antal_shod = false
        if halat == "tirandaz":
                zaman_tirandaz -= delta
                if zaman_tirandaz < 0.12 and not tir_antal_shod:
                        tir_antal_shod = true
                        bazi.tir_antal(global_position + Vector2(mesh * 42.0, -72.0), mesh)
                        zaman_sard_kaman = 0.55
                if zaman_tirandaz <= 0.0:
                        halat = "doid"
        # ── سوارشدن/پیاده‌شدن اسب ──
        if v.get("savari", false):
                bazi.koshish_e_savari()
        # غبار
        if is_on_floor() and absf(velocity.x) > 60.0:
                fase += delta * (19.0 if savar else 13.0)
                ghubar.emitting = true
        else:
                ghubar.emitting = false
        # انتخابِ پیکره بر پایهٔ وضعیت
        var t_gozine := tex_doid
        if savar:
                t_gozine = tex_savare
        elif halat == "zadan":
                t_gozine = tex_zadan
        elif halat == "tirandaz":
                t_gozine = tex_tirandaz
        if nmayesh.texture != t_gozine:
                nmayesh.texture = t_gozine
        nmayesh.flip_h = mesh < 0.0
        if t_gozine == tex_tirandaz:
                nmayesh.flip_h = mesh > 0.0   # ژستِ کمان رو به چپ کشیده شده
        # تنفس و تکانِ دویدن و اسکواش/استرچ
        var buland := t_gozine.get_height()
        var takan := absf(sin(fase * 3.1)) * (5.0 if not savar else 3.0)
        if not is_on_floor():
                takan = 0.0
        nmayesh.position = Vector2(0, -buland * GERAM * 0.5 + 6.0 - takan)
        nmayesh.scale = Vector2(GERAM, GERAM) * nisbat
        nmayesh.rotation = sin(fase * 1.55) * 0.05
        queue_redraw()

func lershe_kuchak() -> void:
        bazi.lershe = maxf(bazi.lershe, 2.6)

func _draw() -> void:
        # قوسِ تیغِ شمشیر هنگام زدن
        if halat == "zadan" and zaman_zadan > 0.0:
                var p := 1.0 - zaman_zadan / 0.34
                var alfa := 0.85 * (1.0 - p)
                var z := -0.9 + p * 2.4
                var noghte := PackedVector2Array()
                for i in 13:
                        var ghesme := z - 0.8 + i * 0.12
                        var shoa := 74.0 + sin(ghesme * 2.2) * 8.0
                        noghte.append(Vector2(cos(ghesme), sin(ghesme)) * shoa * Vector2(mesh, 1.0))
                for i in 12:
                        var a := noghte[i]
                        var b := noghte[i + 1]
                        draw_line(a + Vector2(mesh * 6.0, -62.0), b + Vector2(mesh * 6.0, -62.0),
                                Color(1.0, 0.94, 0.62, alfa), 7.0 - i * 0.3)
                        draw_line(a + Vector2(mesh * 2.0, -58.0), b + Vector2(mesh * 2.0, -58.0),
                                Color(1.0, 1.0, 0.98, alfa * 0.7), 3.0)
        # هالهٔ بی‌مرگی
        if zaman_zakhmi > 0.0 and int(zaman * 18.0) % 2 == 0:
                draw_circle(Vector2(0, -60), 62.0, Color(1.0, 0.5, 0.4, 0.10))
