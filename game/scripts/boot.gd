extends Control

# ─── بوت: اسپلش کوتاه و رفتن به منو ──────────────────────────

var matne_vaziat: Label
var matne_tozih: Label

func _ready() -> void:
        var paszamine := ColorRect.new()
        paszamine.color = Color(0.055, 0.04, 0.045)
        paszamine.set_anchors_preset(Control.PRESET_FULL_RECT)
        add_child(paszamine)

        if ResourceLoader.exists("res://assets/sprites/logo.png"):
                var logo := TextureRect.new()
                logo.texture = load("res://assets/sprites/logo.png")
                logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
                logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
                logo.set_anchors_preset(Control.PRESET_CENTER_TOP)
                logo.anchor_left = 0.34
                logo.anchor_right = 0.66
                logo.offset_top = 110.0
                logo.offset_bottom = 330.0
                logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
                add_child(logo)

        matne_tozih = _matn_besaz("در حال باز کردن منو…", 22)
        matne_tozih.set_anchors_preset(Control.PRESET_CENTER)
        matne_tozih.anchor_top = 0.72
        matne_tozih.anchor_bottom = 0.80
        matne_tozih.offset_left = -300
        matne_tozih.offset_right = 300
        matne_tozih.add_theme_color_override("font_color", Color(1, 1, 1, 0.7))
        add_child(matne_tozih)

        matne_vaziat = _matn_besaz("", 34)
        matne_vaziat.set_anchors_preset(Control.PRESET_CENTER)
        matne_vaziat.anchor_top = 0.5
        matne_vaziat.anchor_bottom = 0.6
        matne_vaziat.offset_left = -300
        matne_vaziat.offset_right = 300
        add_child(matne_vaziat)
        _bargard_be_menu()

func _matn_besaz(matn: String, size: int) -> Label:
        var l := Label.new()
        l.text = matn
        l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        l.add_theme_font_size_override("font_size", size)
        var f := load("res://assets/fonts/Vazirmatn-Bold.ttf")
        if f != null:
                l.add_theme_font_override("font", f)
        return l

func _bargard_be_menu() -> void:
        await get_tree().process_frame
        await get_tree().process_frame
        # مسیر مستقیم برای تست/دمو: --story یا --storytest → هاب زندگی محله
        # --autotest-full / --shots / --playtest → مستقیم مسابقه
        var arg_line := OS.get_cmdline_user_args()
        var masire_sahne := "res://scenes/menu.tscn"
        if arg_line.has("--story") or arg_line.has("--storytest"):
                masire_sahne = "res://scenes/story.tscn"
        elif arg_line.has("--autotest-full") or arg_line.has("--shots") or arg_line.has("--playtest"):
                masire_sahne = "res://scenes/game.tscn"
        elif arg_line.has("--garage"):
                masire_sahne = "res://scenes/garage.tscn"
        var basteh: PackedScene = load(masire_sahne)
        if basteh == null:
                _shekast("صحنه پیدا نشد: " + masire_sahne)
                return
        var nemone := basteh.instantiate()
        if nemone == null:
                _shekast("ساخت صحنه شکست خورد (instantiate = null)")
                return
        if nemone is Control:
                nemone.set("layout_direction", Control.LAYOUT_DIRECTION_LTR)
        get_tree().root.add_child.call_deferred(nemone)
        await get_tree().create_timer(0.9).timeout
        if not is_instance_valid(self):
                return
        # چک سلامت: پنل خانه‌ی منو باید ساخته شده باشد
        if masire_sahne.ends_with("menu.tscn") and nemone.get("panel_home") == null:
                _shekast("منو نیمه‌کاره ماند (پنل اصلی ساخته نشد — جزئیات از لاگ پایین صفحه)")
                return
        # حیاتی: منو باید صحنه‌ی رسمی درخت شود؛ وگرنه change_scene_to_fileها بی‌صدا شکست می‌خورند
        get_tree().current_scene = nemone
        print("[tizpa][boot] current_scene -> ", masire_sahne.get_file(), " OK")
        # تست سلامت خزانه BVAULT — خرابی استریم کلید همین‌جا در لاگ دیده می‌شود
        var GANJE = load("res://scripts/asset_vault.gd")
        if GANJE != null and not GANJE.self_test():
                print("[tizpa][boot] BVAULT SELF-TEST FAILED — محتوای رمزی سالم باز نمی‌شود!")
        var tw := create_tween()
        tw.tween_property(self, "modulate:a", 0.0, 0.3)
        tw.tween_callback(queue_free)
        # اهرم ایمنی: بوت همیشه خودش را می‌بندد تا لمس‌ها بلعیده نشوند
        get_tree().create_timer(3.0).timeout.connect(func():
                if is_instance_valid(self) and is_inside_tree():
                        queue_free())

func _shekast(peygham: String) -> void:
        matne_vaziat.text = "خطای راه‌اندازی"
        var domb := _dam_log()
        matne_tozih.text = peygham
        if domb != "":
                matne_tozih.text += "\n\n— آخرِ لاگ —\n" + domb
        matne_tozih.add_theme_color_override("font_color", Color(1.0, 0.45, 0.4))

func _dam_log() -> String:
        # خطاهای اسکریپت از لاگ گودوت روی صفحه نشان داده می‌شوند
        for p in ["user://logs/godot.log", "user://logs/godot.log.1"]:
                if not FileAccess.file_exists(p):
                        continue
                var f := FileAccess.open(p, FileAccess.READ)
                if f == null:
                        continue
                var khattha: Array[String] = []
                while not f.eof_reached():
                        var l := f.get_line()
                        if l.strip_edges() != "":
                                khattha.append(l)
                f.close()
                var khataha: Array[String] = []
                for l in khattha:
                        if l.contains("ERROR") or l.contains("Failed") or l.contains("error"):
                                khataha.append(l)
                var entekhab: Array[String] = khataha if not khataha.is_empty() else khattha
                var khoruj := ""
                for i in range(max(0, entekhab.size() - 7), entekhab.size()):
                        khoruj += entekhab[i].substr(0, 110) + "\n"
                if khoruj != "":
                        return khoruj
        return ""
