# اژدها — کاراکترِ ساخته‌شده از ورقِ حرکتِ AI با ۹ کاستوم و ۴ حرکت
# ورق‌ها را scripts/sakht_varagh_ezhdeha.py می‌سازد؛ هر کاستوم = یک ورقِ ۱۱ فریمه:
#   فریم ۰-۱: ist | ۲-۵: doid | ۶-۸: parsh | ۹-۱۰: dam
# تعویضِ کاستوم = سوییچِ انیمیشن به نامِ «کاستوم_حرکت» + جهشِ کوچکِ مقیاس
extends CharacterBody2D

const SPEED := 310.0
const JUMP_V := -700.0
const GRAV := 1500.0

# نامِ فنیِ کاستوم‌ها به ترتیبِ نمایش (فارسی‌ها فقط برای HUD)
const KASTUMHA := ["ezhdeha_asli", "ezhdeha_jadugar", "ezhdeha_polis", "ezhdeha_faza",
        "ezhdeha_daryayi", "ezhdeha_shah", "ezhdeha_zemestani", "ezhdeha_ranande",
        "ezhdeha_ninja"]

const HAREKAT_RANGE := {"ist": [0, 2, 6.0, true], "doid": [2, 4, 12.0, true],
        "parsh": [6, 3, 8.0, true], "dam": [9, 2, 6.0, true]}

var zaman := 0.0
var kastum := 0
var anim: AnimatedSprite2D
var soye: Sprite2D
var zamin_y := 660.0
var halat := "doid"          # حالتِ فعلی: doid / parsh / dam / jashn
var jadval_parsh := [2.3, 5.3, 8.3]
var jadval_kastum := [1.5, 3.0, 4.5, 6.0, 7.5, 9.0, 10.5, 12.0]
var jadval_dam := [13.6]     # پُفِ آتشِ پایانی
var parsh_zade := {}
var kastum_zade := {}
var dam_zade := false


func amade() -> void:
        # برخوردکنندهٔ بدن — بدونِ این، اژدها از زمین می‌گذرد
        var badane := CollisionShape2D.new()
        var mostatil := RectangleShape2D.new()
        mostatil.size = Vector2(96.0, 168.0)
        badane.shape = mostatil
        badane.position = Vector2(0, -84.0)
        add_child(badane)
        anim = AnimatedSprite2D.new()
        anim.name = "Harekat"
        anim.scale = Vector2(0.82, 0.82)
        anim.position = Vector2(0, -100)
        add_child(anim)
        _sf_besaz()
        anim.animation_finished.connect(_az_parsh_be_doid)
        anim.play(KASTUMHA[0] + "_doid")


# چیدنِ ورق‌ها به SpriteFrames — تبدیلِ «ورقِ فریم ← انیمیشنِ گودوت»
func _sf_besaz() -> void:
        var sf := SpriteFrames.new()
        sf.remove_animation("default")
        for ki in range(KASTUMHA.size()):
                var esm: String = KASTUMHA[ki]
                var varagh: Texture2D = load("res://assets/honar/%s.png" % esm)
                for harekat in HAREKAT_RANGE.keys():
                        var r: Array = HAREKAT_RANGE[harekat]
                        var na: String = esm + "_" + str(harekat)
                        var az: int = r[0]
                        var tedad: int = r[1]
                        sf.add_animation(na)
                        sf.set_animation_speed(na, r[2])
                        sf.set_animation_loop(na, r[3])
                        for f in range(az, az + tedad):
                                var at := AtlasTexture.new()
                                at.atlas = varagh
                                at.region = Rect2(f * 256.0, 0.0, 256.0, 256.0)
                                sf.add_frame(na, at)
        anim.sprite_frames = sf


func _az_parsh_be_doid() -> void:
        # پرش تمام شد → برگشت به دویدن (مگر در جشن)
        if halat == "parsh":
                halat = "doid"
                anim.play(KASTUMHA[kastum] + "_doid")


func kastum_avaz(ki: int) -> void:
        # تعویضِ کاستوم با جهشِ مقیاس (pop)
        kastum = clampi(ki, 0, KASTUMHA.size() - 1)
        anim.play(KASTUMHA[kastum] + "_" + halat)
        anim.scale = Vector2(0.98, 0.72)
        var tv := create_tween()
        tv.tween_property(anim, "scale", Vector2(0.82, 0.82), 0.28)\
                .set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func dam_bephef() -> void:
        halat = "dam"
        anim.play(KASTUMHA[kastum] + "_dam")


func jashn() -> void:
        halat = "parsh"
        velocity.y = JUMP_V * 0.8
        anim.play(KASTUMHA[kastum] + "_parsh")


func _physics_process(delta: float) -> void:
        zaman += delta
        # خلبانِ خودکارِ فیلم: پرش و تعویضِ کاستوم و آتش در زمان‌های معیّن
        for t in jadval_parsh:
                if zaman >= t and not parsh_zade.get(t, false):
                        parsh_zade[t] = true
                        if halat != "dam":
                                halat = "parsh"
                                velocity.y = JUMP_V
                                anim.play(KASTUMHA[kastum] + "_parsh")
        for i in range(jadval_kastum.size()):
                var t2: float = jadval_kastum[i]
                if zaman >= t2 and not kastum_zade.get(t2, false):
                        kastum_zade[t2] = true
                        kastum_avaz(i + 1)
        for t3 in jadval_dam:
                if zaman >= t3 and not dam_zade:
                        dam_zade = true
                        dam_bephef()
        if zaman >= 15.4 and halat != "parsh" and halat == "dam":
                jashn()   # پایان: پرشِ خوشحالی

        # حرکتِ ثابت به راست (دوندهٔ نمایشی)
        if halat != "dam":
                velocity.x = SPEED
        else:
                velocity.x = SPEED * 0.55   # هنگامِ آتش کمی آرام‌تر
        if halat == "parsh":
                velocity.y += GRAV * delta
        elif is_on_floor():
                velocity.y = 0.0
        move_and_slide()
        # فرودِ پرش → برگشت به دویدن
        if halat == "parsh" and is_on_floor() and velocity.y >= 0.0:
                halat = "doid"
                anim.play(KASTUMHA[kastum] + "_doid")
        if halat == "doid" and is_on_floor():
                anim.play(KASTUMHA[kastum] + "_doid")

        # سایه روی زمین می‌ماند
        if soye != null:
                soye.global_position = Vector2(global_position.x, zamin_y - 3.0)
                var fasele := clampf(1.0 - (zamin_y - global_position.y) / 420.0, 0.55, 1.0)
                soye.scale = Vector2(0.9, 0.5) * fasele
                soye.modulate.a = 0.36 * fasele
