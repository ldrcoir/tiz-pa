extends CharacterBody2D
# دشمنانِ گردآفرید — سربازِ توران، دیوِ سنگ‌انداز، دیوک، دیوسپید
# هر چهارنوع با یک اسکریپت و «noe» از هم جدا می‌شوند

const JENES := 2400.0

var noe := "sarbaz"              # sarbaz | div | kuchak | div_sefid
var bazi
var joon := 2
var ghodrat := 1                 # ضربه‌ای که به هلیا می‌زند
var vosat := 52.0                # نیم‌عرض بدن برای برخورد
var sorat := 120.0
var halat := "gard"              # gard | donybal | telegh | morde
var khane := Vector2.ZERO        # جای خانه برای گشت‌زنی
var tokhme_gard := 0.0
var zaman_ai := 0.0
var zaman_telegh := 0.0
var zaman_flash := 0.0
var zaman_morde := 0.0
var mesh := -1.0
var faal := false                # بوس تا هلیا نرسیده خفته است
var nmayesh: Sprite2D
var geram := 0.5

func _ready() -> void:
        khane = global_position
        tokhme_gard = randf() * TAU
        var shekl := CollisionShape2D.new()
        var kapsol := CapsuleShape2D.new()
        match noe:
                "sarbaz":
                        joon = 2; ghodrat = 1; vosat = 52.0; sorat = 135.0; geram = 0.58
                "div":
                        joon = 3; ghodrat = 1; vosat = 92.0; sorat = 62.0; geram = 0.6
                "kuchak":
                        joon = 1; ghodrat = 1; vosat = 34.0; sorat = 250.0; geram = 0.64
                "div_sefid":
                        joon = 8; ghodrat = 2; vosat = 128.0; sorat = 42.0; geram = 0.62
        kapsol.radius = vosat * 0.55
        kapsol.height = vosat * 1.7
        shekl.shape = kapsol
        shekl.position = Vector2(0, -vosat * 0.85)
        add_child(shekl)
        nmayesh = Sprite2D.new()
        var masir := "res://assets/honar/"
        match noe:
                "sarbaz": nmayesh.texture = load(masir + "sarbaz.png")
                "div": nmayesh.texture = load(masir + "div.png")
                "kuchak": nmayesh.texture = load(masir + "kuchak.png")
                "div_sefid": nmayesh.texture = load(masir + "div_sefid.png")
        nmayesh.scale = Vector2(geram, geram)
        nmayesh.position = Vector2(0, -nmayesh.texture.get_height() * geram * 0.5 + 5)
        add_child(nmayesh)
        if noe == "div_sefid":
                faal = false
        zaman_ai = 2.0 + randf() * 1.4

func _physics_process(delta: float) -> void:
        if halat == "morde":
                zaman_morde += delta
                position.y += 26.0 * delta
                nmayesh.modulate.a = maxf(0.0, 1.0 - zaman_morde * 1.6)
                if zaman_morde > 1.4:
                        queue_free()
                return
        zaman_flash = maxf(0.0, zaman_flash - delta)
        var rang_flash := Color(1.0, 1.0, 1.0)
        if zaman_flash > 0.0:
                rang_flash = Color(2.2, 2.2, 2.2)
        if zaman_telegh > 0.0:
                zaman_telegh -= delta
                rang_flash = Color(1.9, 0.75, 0.65)          # سرخِ هشدار
                if zaman_telegh <= 0.0:
                        zarbe_nahai()
                nmayesh.modulate = rang_flash
                velocity.y += JENES * delta
                move_and_slide()
                return
        nmayesh.modulate = rang_flash
        var helia = bazi.helia
        var dx: float = helia.global_position.x - global_position.x
        var dy: float = absf(helia.global_position.y - global_position.y)
        match noe:
                "sarbaz":
                        if halat == "gard":
                                var gh = khane.x + sin(Time.get_ticks_msec() / 1000.0 * 0.9 + tokhme_gard) * 170.0
                                var mehr := signf(gh - global_position.x)
                                velocity.x = mehr * sorat * 0.6
                                if absf(dx) < 340.0 and dy < 130.0 and helia.halat != "morde":
                                        halat = "donybal"
                        else:
                                velocity.x = signf(dx) * sorat
                                if absf(dx) < 92.0 and dy < 120.0:
                                        zaman_telegh = 0.34
                                if absf(global_position.x - khane.x) > 560.0 and absf(dx) > 420.0:
                                        halat = "gard"
                "div":
                        velocity.x = 0.0
                        zaman_ai -= delta
                        if zaman_ai <= 0.0 and absf(dx) > 260.0 and absf(dx) < 780.0 and dy < 420.0 and faal_ist():
                                mesh = signf(dx)
                                zaman_ai = 3.2
                                bazi.sang_antal(global_position + Vector2(mesh * 40.0, -vosat * 1.5), helia.global_position + Vector2(0, -46))
                        if absf(dx) < 140.0 and dy < 140.0 and zaman_telegh <= 0.0:
                                zaman_telegh = 0.42
                        mesh = signf(dx) if absf(dx) > 30.0 else mesh
                "kuchak":
                        if is_on_floor():
                                velocity.x = signf(dx) * sorat * 0.4
                                zaman_ai -= delta
                                if zaman_ai <= 0.0:
                                        velocity.y = -660.0
                                        velocity.x = signf(dx) * sorat
                                        zaman_ai = 0.85
                        mesh = signf(dx) if absf(dx) > 20.0 else mesh
                "div_sefid":
                        if not faal:
                                # خفته تا هلیا به میدان برسد
                                nmayesh.modulate = Color(0.75, 0.78, 0.9)
                                velocity.y += JENES * delta
                                move_and_slide()
                                return
                        nmayesh.modulate = rang_flash
                        var ghash := 1.0
                        if joon <= 5:
                                ghash = 1.5             # خشمِ دیوسپید
                        velocity.x = signf(dx) * sorat * ghash
                        if global_position.x < 7560.0:
                                velocity.x = maxf(velocity.x, 0.0)   # بوس در میدان می‌ماند
                        if global_position.x > 8100.0:
                                velocity.x = minf(velocity.x, 0.0)
                        mesh = signf(dx) if absf(dx) > 40.0 else mesh
                        zaman_ai -= delta
                        if absf(dx) < 190.0 and dy < 200.0 and zaman_telegh <= 0.0 and zaman_ai <= 0.0:
                                zaman_telegh = 0.5
                                bazi.seda("gharjar", -2.0)
                        elif zaman_ai <= 0.0 and absf(dx) < 900.0:
                                zaman_ai = 2.6 / ghash
                                bazi.sang_antal(global_position + Vector2(mesh * 60.0, -vosat * 1.6), helia.global_position + Vector2(0, -46), true)
        velocity.y += JENES * delta
        move_and_slide()
        nmayesh.flip_h = mesh > 0.0

func faal_ist() -> bool:
        return halat != "morde"

func zarbe_nahai() -> void:
        # لحظهٔ اصابت: فقط اگر هلیا هنوز نزدیک باشد
        var helia = bazi.helia
        var dx: float = absf(helia.global_position.x - global_position.x)
        var shoae := 150.0 if noe == "div" else 120.0
        if noe == "div_sefid":
                shoae = 210.0
                bazi.mowj_antal(global_position + Vector2(0, -14), signf(helia.global_position.x - global_position.x))
        if dx < shoae and absf(helia.global_position.y - global_position.y) < 150.0:
                bazi.zakhmi_helia(ghodrat, global_position)

func zarbe(gh: int) -> void:
        if halat == "morde":
                return
        joon -= gh
        zaman_flash = 0.16
        var helia = bazi.helia
        var geran := signf(global_position.x - helia.global_position.x)
        velocity.x = geran * (210.0 if noe != "div_sefid" else 60.0)
        bazi.esparak(global_position + Vector2(0, -vosat), Color(1.0, 0.85, 0.4))
        if joon <= 0:
                morde_shod()

func morde_shod() -> void:
        halat = "morde"
        zaman_morde = 0.0
        set_deferred("collision_layer", 0)
        set_deferred("collision_mask", 0)
        bazi.seda("gharjar", -6.0)
        bazi.doshman_mord(self)
