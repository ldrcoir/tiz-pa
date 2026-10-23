extends Node

const MASIRE_ZAKHIRE := "user://tizpa_save.json"

# نسخه‌ی بازی — همه‌جا از همین خونده می‌شه
const NOSKHE := "0.13"
const SAKHT := 21

var pool: int = 0
var esme_pelak: String = "هلیا"
var mashin_entekhabi: int = 0
var artagha := {"engine": 0, "tire": 0, "nitro": 0}
var mashin_bazshode: Array = []
var setare_marhale := {}  # id -> stars
var fasl = null      # parsed season json
# داستان: اپیزودهای دیده‌شده + دلِ محله + مدت صبر آنلاین (ثانیه)
var dastan_dide := {}
var delha: int = 0
var entezare_anlan: float = 15.0

# رشته ماشین‌ها: نام‌های واقعی و آشنای خیابان‌های ایران
# ترتیب = نردبان قیمت؛ پراید/تیبا/پژو/سمند/دنا/نیسان/شاهین/کوییک
const MASHINHA := [
        {
                "id": "boghi", "name": "تیز پا", "en": "Tiz Pa",
                "desc": "ماشین تو — قرمز، سبک و همیشه گرسنه‌ی سبقت!",
                "tex": "res://assets/sprites/car_boghi.webp",
                "rang": "#c8141e",
                "jump": 1.0, "accel": 1.0, "tough": 1.0, "price": 0
        },
        {
                "id": "boghi_yellow", "name": "تیز پا زرد", "en": "Tiz Pa Sun",
                "desc": "همان رفیق آفتابی — لبخند به رنگ خورشید!",
                "tex": "res://assets/sprites/car_boghi_yellow.webp",
                "rang": "#e8a018",
                "jump": 1.05, "accel": 1.08, "tough": 0.92, "price": 800
        },
        {
                "id": "tiba", "name": "تیبا", "en": "Tiba",
                "desc": "آبی و چابک — فرمان‌های تیز تو پیچ‌های تنگ",
                "tex": "res://assets/sprites/car_tiba.webp",
                "rang": "#5a7ea8",
                "jump": 1.12, "accel": 0.95, "tough": 0.8, "price": 600
        },
        {
                "id": "pride", "name": "پراید قرمز", "en": "Pride RS",
                "desc": "هاچ‌بک مسابقه‌ای با استریک و اسپویلر — شتاب بالا!",
                "tex": "res://assets/sprites/car_pride.webp",
                "rang": "#b81620",
                "jump": 0.9, "accel": 1.18, "tough": 0.9, "price": 900
        },
        {
                "id": "pejo", "name": "پژو ۲۰۶", "en": "Peugeot 206",
                "desc": "نقره‌ای فرمان‌رو — تعادل عالی سرعت و کنترل",
                "tex": "res://assets/sprites/car_pejo.webp",
                "rang": "#b8bcc4",
                "jump": 1.0, "accel": 1.1, "tough": 0.95, "price": 1200
        },
        {
                "id": "samand", "name": "سمند کلاسیک", "en": "Samand Classic",
                "desc": "سالخورده‌ی مطمئن محله — مثل دیوار محکم",
                "tex": "res://assets/sprites/car_samand.webp",
                "rang": "#e2e0dc",
                "jump": 0.95, "accel": 0.9, "tough": 1.35, "price": 1500
        },
        {
                "id": "dena", "name": "دنا پلاس", "en": "Dena Plus",
                "desc": "سدان سفید ملی — شکوه و آرامش جاده",
                "tex": "res://assets/sprites/car_dena.webp",
                "rang": "#eceae6",
                "jump": 1.0, "accel": 1.15, "tough": 1.1, "price": 1800
        },
        {
                "id": "nissan", "name": "نیسان قرمز", "en": "Nissan Pickup",
                "desc": "وانت افسانه‌ای آسفالت‌خور — سنگین ولی شکست‌ناپذیر",
                "tex": "res://assets/sprites/car_nissan.webp",
                "rang": "#4a4e55",
                "jump": 0.8, "accel": 0.85, "tough": 1.5, "price": 2200
        },
        {
                "id": "pejo_race", "name": "پژو ۲۰۶ مسابقه‌ای", "en": "206 Racing",
                "desc": "قرمز آتشین با استریک سفید — عاشق پیست است!",
                "tex": "res://assets/sprites/car_pejo_race.webp",
                "rang": "#c01820",
                "jump": 1.05, "accel": 1.22, "tough": 0.9, "price": 2400
        },
        {
                "id": "shahin", "name": "شاهین", "en": "Shahin",
                "desc": "مشکی اسپرت با خط طلایی — شاه شب‌های تهران",
                "tex": "res://assets/sprites/car_shahin.webp",
                "rang": "#1c1d22",
                "jump": 0.9, "accel": 1.3, "tough": 1.0, "price": 2600
        },
        {
                "id": "quick", "name": "کوییک", "en": "Quick",
                "desc": "نارنجی جیغ جوان — عاشق دریفت‌های طولانی!",
                "tex": "res://assets/sprites/car_quick.webp",
                "rang": "#e06818",
                "jump": 1.25, "accel": 1.05, "tough": 0.75, "price": 3400
        },
        {
                "id": "dena_race", "name": "دنا مسابقه‌ای", "en": "Dena Racing",
                "desc": "سدان ملی با لباس استریک قرمز — غرور پیست!",
                "tex": "res://assets/sprites/car_dena_race.webp",
                "rang": "#e6e2dc",
                "jump": 1.0, "accel": 1.3, "tough": 1.05, "price": 4200
        },
        {
                "id": "pride_blue", "name": "پراید آبی مسابقه‌ای", "en": "Pride Blue RS",
                "desc": "موج آبی پیست — استریک سفید و بال بزرگ!",
                "tex": "res://assets/sprites/car_pride_blue.webp",
                "rang": "#1c4f9e",
                "jump": 0.95, "accel": 1.28, "tough": 0.9, "price": 4800
        },
        {
                "id": "pejo_green", "name": "پژو سبز مسابقه‌ای", "en": "206 Emerald",
                "desc": "زمرد پرشور پیست — استریک مشکی، شتاب وحشی!",
                "tex": "res://assets/sprites/car_pejo_green.webp",
                "rang": "#1c7a4a",
                "jump": 1.05, "accel": 1.32, "tough": 0.9, "price": 5400
        },
        {
                "id": "shahin_white", "name": "شاهین سفید", "en": "Shahin Pearl",
                "desc": "قهرمان سفید شب‌های تهران — خط طلایی، نفس طلایی!",
                "tex": "res://assets/sprites/car_shahin_white.webp",
                "rang": "#f0f0ee",
                "jump": 0.95, "accel": 1.38, "tough": 1.0, "price": 6000
        },
        {
                "id": "dena_red", "name": "دنا سرخ کاپیتان", "en": "Dena Red Captain",
                "desc": "کاپیتان سرخ مأموریت‌ها — سخت‌کوش و سریع!",
                "tex": "res://assets/sprites/car_dena_red.webp",
                "rang": "#a01018",
                "jump": 1.0, "accel": 1.42, "tough": 1.1, "price": 6800
        },
        {
                "id": "nissan_blue", "name": "نیسان آبی اکبر", "en": "Akbar's Blue Nissan",
                "desc": "نیسان آبی اکبر سیبیلو — لونگ گردن، آسفالت زیر چرخ!",
                "tex": "res://assets/sprites/car_nissan_blue.webp",
                "rang": "#2c5f8e",
                "jump": 0.82, "accel": 0.9, "tough": 1.55, "price": 7600
        },
        {
                "id": "formula_red", "name": "فرمول آتش", "en": "Formula Fire",
                "desc": "فرمول‌یک سرخِ آتشین — بال جلو، بال عقب، جون نصف!",
                "tex": "res://assets/sprites/car_formula_red.webp",
                "rang": "#d01818",
                "jump": 1.05, "accel": 1.5, "tough": 0.85, "price": 9500
        },
        {
                "id": "formula_blue", "name": "فرمول موج", "en": "Formula Wave",
                "desc": "فرمول‌یک آبیِ موج‌سوار — چابک‌ترین چرخ‌های پیست!",
                "tex": "res://assets/sprites/car_formula_blue.webp",
                "rang": "#1858c0",
                "jump": 1.18, "accel": 1.55, "tough": 0.78, "price": 12000
        },
        {
                "id": "formula_black", "name": "فرمول شاهین", "en": "Formula Shahin",
                "desc": "مشکی-طلایی شب‌های تهران — پادشاه بی‌رقیب سرعت!",
                "tex": "res://assets/sprites/car_formula_black.webp",
                "rang": "#18181c",
                "jump": 1.0, "accel": 1.68, "tough": 0.9, "price": 16000
        },
]

const ARTAGHAHA := [
        {"id": "engine", "name": "موتور", "desc": "شتاب و سرعت بیشتر", "costs": [120, 260, 520]},
        {"id": "tire", "name": "لاستیک", "desc": "چسبندگی بیشتر در پیچ و دریفت", "costs": [100, 220, 450]},
        {"id": "nitro", "name": "نیترو", "desc": "نیتروی قوی‌تر و طولانی‌تر", "costs": [140, 300, 600]},
]

const ZABANHA := {
        "play": {"fa": "بازی", "en": "Play"},
        "garage": {"fa": "کارگاه", "en": "Garage"},
        "levels": {"fa": "مأموریت‌ها", "en": "Missions"},
        "back": {"fa": "برگشت", "en": "Back"},
        "plate_hint": {"fa": "اسم روی پلاک:", "en": "Name on plate:"},
        "coins": {"fa": "سکه", "en": "Coins"},
        "select": {"fa": "انتخاب", "en": "Select"},
        "selected": {"fa": "انتخاب شد", "en": "Selected"},
        "buy": {"fa": "خرید", "en": "Buy"},
        "engine": {"fa": "موتور", "en": "Engine"},
        "tire": {"fa": "لاستیک", "en": "Tire"},
        "nitro": {"fa": "نیترو", "en": "Nitro"},
        "tab_cars": {"fa": "ماشین‌ها", "en": "Cars"},
        "tab_ups": {"fa": "ارتقا", "en": "Upgrades"},
        "workshop": {"fa": "کارگاه استاد فنر", "en": "Ustad Faner Workshop"},
        "max": {"fa": "ماکزیمم", "en": "Max"},
        "jump": {"fa": "پرش", "en": "JUMP"},
        "boost": {"fa": "توربو", "en": "TURBO"},
        "go": {"fa": "برو!", "en": "GO!"},
        "pos": {"fa": "جایگاه", "en": "POS"},
        "paused": {"fa": "توقف", "en": "Paused"},
        "resume": {"fa": "ادامه", "en": "Resume"},
        "menu": {"fa": "منو", "en": "Menu"},
        "win": {"fa": "آفرین! مأموریت انجام شد", "en": "Mission Complete!"},
        "lose": {"fa": "آخ! دوباره امتحان کن", "en": "Oops! Try again"},
        "next": {"fa": "مرحله بعد", "en": "Next"},
        "retry": {"fa": "دوباره", "en": "Retry"},
        "reward": {"fa": "جایزه", "en": "Reward"},
        "mission": {"fa": "مأموریت", "en": "Mission"},
        "type_race": {"fa": "برس به خط پایان!", "en": "Reach the finish!"},
        "type_collect": {"fa": "سکه جمع کن!", "en": "Collect coins!"},
        "type_taxi": {"fa": "مسافر برسون!", "en": "Deliver passengers!"},
        "type_challenge": {"fa": "چالش ویژه!", "en": "Special challenge!"},
        "locked": {"fa": "قفله! قبلیو ببر", "en": "Locked! Win previous"},
}

func tarjome(kelid: String) -> String:
        if ZABANHA.has(kelid):
                return ZABANHA[kelid]["fa"]
        return kelid

func _ready() -> void:
        for i in MASHINHA.size():
                mashin_bazshode.append(false)
        mashin_bazshode[0] = true
        zakhire_bekhon()
        fasl = fasl_bekhon()

func fasl_bekhon() -> Dictionary:
        var f := FileAccess.open("res://data/season1_tehran.json", FileAccess.READ)
        if f == null:
                push_error("season file missing")
                return {}
        var dade = JSON.parse_string(f.get_as_text())
        if dade == null:
                push_error("season json broken")
                return {}
        return dade

func marhale_begir(id: int) -> Dictionary:
        if fasl == null or not fasl.has("levels"):
                return {}
        for marhale in fasl["levels"]:
                if int(marhale["id"]) == id:
                        return marhale
        return {}

func marhale_bazshode(id: int) -> bool:
        if id <= 1:
                return true
        return setare_marhale.has(id - 1)

func zakhire_kon() -> void:
        var dade := {
                "coins": pool,
                "plate_name": esme_pelak,
                "selected_car": mashin_entekhabi,
                "upgrades": artagha,
                "unlocked_car": mashin_bazshode,
                "level_stars": setare_marhale,
                "story_seen": dastan_dide,
                "hearts": delha,
                "online_wait": entezare_anlan,
        }
        var f := FileAccess.open(MASIRE_ZAKHIRE, FileAccess.WRITE)
        if f:
                f.store_string(JSON.stringify(dade))
                f.close()

func zakhire_bekhon() -> void:
        if not FileAccess.file_exists(MASIRE_ZAKHIRE):
                return
        var f := FileAccess.open(MASIRE_ZAKHIRE, FileAccess.READ)
        if f == null:
                return
        var dade = JSON.parse_string(f.get_as_text())
        if dade == null:
                return
        pool = int(dade.get("coins", 0))
        esme_pelak = str(dade.get("plate_name", "هلیا"))
        mashin_entekhabi = int(dade.get("selected_car", 0))
        var up = dade.get("upgrades", {})
        for k in ["engine", "tire", "nitro"]:
                artagha[k] = int(up.get(k, 0))
        var uc = dade.get("unlocked_car", [true])
        for i in mashin_bazshode.size():
                mashin_bazshode[i] = bool(uc[i]) if i < uc.size() else false
        mashin_bazshode[0] = true
        var ls = dade.get("level_stars", {})
        setare_marhale.clear()
        for k in ls:
                setare_marhale[int(k)] = int(ls[k])
        var jaryan_jigh = dade.get("story_seen", {})
        dastan_dide = {}
        for k in jaryan_jigh:
                dastan_dide[str(k)] = bool(jaryan_jigh[k])
        delha = int(dade.get("hearts", 0))
        entezare_anlan = float(dade.get("online_wait", 15.0))
        f.close()

func amar_mashin() -> Dictionary:
        var c = MASHINHA[mashin_entekhabi]
        return {
                # در مسابقه‌ی واقعی: jump = چسبندگی لاستیک (گریپ)، turbo = دوام نیترو
                "jump": float(c["jump"]) * (1.0 + 0.10 * artagha["tire"]),
                "accel": float(c["accel"]) * (1.0 + 0.08 * artagha["engine"]),
                "tough": float(c["tough"]),
                "turbo": 1.2 + 0.5 * artagha["nitro"],
        }

func pool_efe(n: int) -> void:
        pool += n
        zakhire_kon()

func mashin_bekhar(i: int) -> bool:
        if mashin_bazshode[i]:
                return false
        var qeymat := int(MASHINHA[i]["price"])
        if pool >= qeymat:
                pool -= qeymat
                mashin_bazshode[i] = true
                mashin_entekhabi = i
                zakhire_kon()
                return true
        return false

func qeymate_artagha(sh_yekta: String) -> int:
        for u in ARTAGHAHA:
                if u["id"] == sh_yekta:
                        var sath: int = artagha[sh_yekta]
                        if sath >= 3:
                                return -1
                        return int(u["costs"][sath])
        return -1

func artagha_bezan(sh_yekta: String) -> bool:
        var hazine := qeymate_artagha(sh_yekta)
        if hazine < 0 or pool < hazine:
                return false
        pool -= hazine
        artagha[sh_yekta] += 1
        zakhire_kon()
        return true

func setare_bede(level_id: int, setareha: int) -> void:
        var qadimi := int(setare_marhale.get(level_id, 0))
        setare_marhale[level_id] = max(qadimi, setareha)
        zakhire_kon()
