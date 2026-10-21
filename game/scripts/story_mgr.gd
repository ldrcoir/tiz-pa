extends RefCounted

const PRE_GANJ := preload("res://scripts/asset_vault.gd")

const QESMATHA := [
        {"id": "ep1",  "num": 1,  "title": "سیب‌زمینی و سنگک",   "desc": "لیست خریدِ زن اکبر رسید!", "hearts": 1},
        {"id": "ep2",  "num": 2,  "title": "سنگک داغ",           "desc": "تایمرِ نون قبل از سرد شدن", "hearts": 1},
        {"id": "ep3",  "num": 3,  "title": "شورشویی عمو رجب",    "desc": "هلیا از فرچه می‌ترسد!", "hearts": 1},
        {"id": "ep4",  "num": 4,  "title": "استاد فنر و انگشت پا", "desc": "«بوقت زنگ گرفته؟»", "hearts": 1},
        {"id": "ep5",  "num": 5,  "title": "عروسی خواهرزاده",     "desc": "روبان و گل برای همه", "hearts": 2},
        {"id": "ep6",  "num": 6,  "title": "شب بارونی",          "desc": "پتوی برزنتی و خُرخُرِ نیسان", "hearts": 1},
        {"id": "ep7",  "num": 7,  "title": "حسرت هندونه",        "desc": "هندونه رو سقف؟!", "hearts": 1},
        {"id": "ep8",  "num": 8,  "title": "جریمه",              "desc": "همه ادب، ماشین‌ها نه!", "hearts": 1},
        {"id": "ep9",  "num": 9,  "title": "رادیو قرضی",         "desc": "یک ترانه، صد بار", "hearts": 1},
        {"id": "ep10", "num": 10, "title": "مسابقه‌ی زیر خاک",    "desc": "کوچه‌ی خاکیِ حفاری", "hearts": 2},
        {"id": "ep11", "num": 11, "title": "نون برای مامان‌بزرگ",  "desc": "پیغام از فراز شهر", "hearts": 1},
        {"id": "ep12", "num": 12, "title": "جشن محله",           "desc": "کری‌خوانی گروهی روی میدان", "hearts": 3},
]

static func load_episode(id: String) -> Dictionary:
        var n := int(id.trim_prefix("ep"))
        var masir := "res://data/story/episode_%02d.json" % n
        var dade: Dictionary = PRE_GANJ.load_json(masir)
        if dade.is_empty():
                dade = {}
        return dade

static func card_list() -> Array:
        var khoruj := []
        for e in QESMATHA:
                var c: Dictionary = e.duplicate(true)
                var ep := load_episode(str(e["id"]))
                c["ready"] = not ep.is_empty()
                c["seen"] = Koli.dastan_dide.has(str(e["id"]))
                khoruj.append(c)
        return khoruj

static func bazshode(sh: int) -> bool:
        if sh == 0:
                return true
        var qabli: Dictionary = QESMATHA[sh - 1]
        if not load_episode(str(qabli["id"])).is_empty():
                return Koli.dastan_dide.has(str(qabli["id"]))
        # اپیزود قبلی هنوز فایل ندارد؛ فقط تا آخرین «آماده» جلو می‌رویم
        return false

static func mark_seen(id: String, delha: int) -> void:
        Koli.dastan_dide[id] = true
        Koli.delha += delha
        Koli.zakhire_kon()

static func total_hearts() -> int:
        var t := 0
        for e in QESMATHA:
                t += int(e["hearts"])
        return t
