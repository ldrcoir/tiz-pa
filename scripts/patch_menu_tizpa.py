#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""پچ منوی تیز پا: تیتر نو + پنل ۵ مرحله + راهنمای بازی + درباره ما (بدون سازنده)"""
import io, re, sys

P = "/home/z/my-project/game/scripts/menu.gd"
src = io.open(P, encoding="utf-8").read()
fails = []

def rep(old, new, must=True):
    global src
    if old in src:
        src = src.replace(old, new, 1)
    else:
        fails.append(old[:70])

# ── ۱) تیتر و زیرنویس ──
rep('var title := _mk_label("بوقی", 108, false, true, Color(1.0, 0.87, 0.42))',
    'var title := _mk_label("تیز پا", 108, false, true, Color(1.0, 0.87, 0.42))')
rep('var sub := _mk_label("تور شهرها  •  فصل ۱: تهران", 26, true, false, Color(0.94, 0.92, 0.88, 0.95))',
    'var sub := _mk_label("مسابقه‌ی خیابانی تهران  •  پنج مرحله  •  یک قهرمان", 26, true, false, Color(0.94, 0.92, 0.88, 0.95))')

# ── ۲) برچسب نسخه — بدون هیچ نام سازنده (قانون کاربر) ──
rep('var l := _mk_label("بوقی v%s (build %d)  •  از استودیو ایماروید" % [Globals.VERSION, Globals.BUILD], 16, true, false, Color(1, 1, 1, 0.58))',
    'var l := _mk_label("تیز پا v%s — بیلد %d" % [Globals.VERSION, Globals.BUILD], 16, true, false, Color(1, 1, 1, 0.58))')

# ── ۳) صفحه‌ی خانه: دکمه‌ها مرتب + درباره ما در آخر ──
rep('''        var row1 := HBoxContainer.new()
        row1.add_theme_constant_override("separation", 10)
        var b_play := _mk_button(Globals.L("levels"), 26, "dark", 88)
        b_play.pressed.connect(func(): _show(panel_levels))
        play_btn = b_play
        row1.add_child(b_play)
        var b_life := _mk_button("زندگی محله", 26, "dark", 88)
        b_life.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/story.tscn"))
        row1.add_child(b_life)
        hb.add_child(row1)

        var row2 := HBoxContainer.new()
        row2.add_theme_constant_override("separation", 10)
        var b_garage := _mk_button("کارگاه", 24, "dark", 80)
        b_garage.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/garage.tscn"))
        row2.add_child(b_garage)
        # چند نفره آنلاین — جست‌وجوی حریف؛ پیدا نشد → اکبر AI پشت فرمون
        var b_online := _mk_button("آنلاین", 24, "dark", 80)
        b_online.pressed.connect(_open_online)
        row2.add_child(b_online)
        hb.add_child(row2)''',
'''        var row1 := HBoxContainer.new()
        row1.add_theme_constant_override("separation", 10)
        var b_play := _mk_button("مراحل", 26, "dark", 84)
        b_play.pressed.connect(func(): _show(panel_levels))
        play_btn = b_play
        row1.add_child(b_play)
        var b_garage := _mk_button("کارگاه", 24, "dark", 84)
        b_garage.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/garage.tscn"))
        row1.add_child(b_garage)
        hb.add_child(row1)

        var row2 := HBoxContainer.new()
        row2.add_theme_constant_override("separation", 10)
        var b_guide := _mk_button("راهنمای بازی", 24, "dark", 78)
        b_guide.pressed.connect(func(): _show(panel_guide))
        row2.add_child(b_guide)
        var b_life := _mk_button("زندگی محله", 24, "dark", 78)
        b_life.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/story.tscn"))
        row2.add_child(b_life)
        hb.add_child(row2)

        # درباره ما — همیشه آخرین گزینه‌ی منو (قانون کاربر)
        var b_about := _mk_button("درباره ما", 22, "dark", 66)
        b_about.pressed.connect(func(): _show(panel_about))
        hb.add_child(b_about)''')

# ── ۴) پنل مراحل: ۵ مرحله‌ی واقعی تیز پا (نه ۵۰ مأموریت قدیمی) ──
old_levels_head = '''        # هدر: اکبر سیبیلو (شخصیت طنز) + تیکه‌ی تصادفی
        var hdr := HBoxContainer.new()
        hdr.add_theme_constant_override("separation", 14)
        akbar_rect = TextureRect.new()
        akbar_rect.texture = _safe_load("res://assets/sprites/akbar.png")
        if akbar_rect.texture != null:
                akbar_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
                akbar_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
                akbar_rect.custom_minimum_size = Vector2(92, 108)
                hdr.add_child(akbar_rect)
        var ak := VBoxContainer.new()
        ak.add_theme_constant_override("separation", 2)
        # خودِ ستون هم باید کل عرض هدر را بگیرد — وگرنه لیبل‌ها در جعبه‌ی تنگ گیر می‌کنند
        ak.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        var ak_name := _mk_label("اکبر سیبیلو — رئیس مأموریت‌ها", 26, false, true, COL_GOLD)
        # ⛔ درس اسکرین‌شات: لیبل RTL با LEFT در صحنه‌ی LTR-قفل حروف را له می‌کند —
        # RIGHT‌ نقطه‌ی شروع طبیعی فارسی است + EXPAND_FILL تا عرض هرگز کم نیاید
        ak_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        ak_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        ak.add_child(ak_name)
        akbar_line_label = _mk_label("", 20, true, false, COL_CREAM)
        akbar_line_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        akbar_line_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        akbar_line_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
        akbar_line_label.add_theme_constant_override("outline_size", 5)
        ak.add_child(akbar_line_label)
        hdr.add_child(ak)
        lv.add_child(hdr)
        var scroll := ScrollContainer.new()
        scroll.custom_minimum_size = Vector2(1196, 300)
        scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
        var grid := GridContainer.new()
        # ⛔ درس اسکرین‌شات گوشی: ۸ ستونِ ۱۱۲px «دکمه‌های ریز» می‌سازد —
        # ۴ ستون کاشی درشت (۲۸۰×۱۰۴) با فونت درشت = هدف لمسی واقعی
        grid.columns = 4
        grid.add_theme_constant_override("h_separation", 12)
        grid.add_theme_constant_override("v_separation", 12)
        for id in range(1, 51):
                var st: int = Globals.level_stars.get(id, 0)
                var unlocked: bool = Globals.level_unlocked(id)
                var b := Button.new()
                b.custom_minimum_size = Vector2(280, 104)
                _style_btn(b, "tile")
                b.disabled = not unlocked
                # دو خط: عدد (لاله‌زار درشت) + ردیف ستاره (وازیرمتن — گلیف تضمینی)
                var vb := VBoxContainer.new()
                vb.set_anchors_preset(Control.PRESET_FULL_RECT)
                vb.alignment = BoxContainer.ALIGNMENT_CENTER
                vb.add_theme_constant_override("separation", 0)
                vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
                var num := Label.new()
                num.text = str(id)
                if font_display != null:
                        num.add_theme_font_override("font", font_display)
                num.add_theme_font_size_override("font_size", 46)
                num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
                num.add_theme_color_override("font_color", COL_CREAM if unlocked else Color(0.55, 0.53, 0.50))
                num.mouse_filter = Control.MOUSE_FILTER_IGNORE
                vb.add_child(num)
                var stars := Label.new()
                var st_txt := ""
                for s in 3:
                        st_txt += "٭" if s < st else "·"
                stars.text = st_txt
                if font_bold != null:
                        stars.add_theme_font_override("font", font_bold)
                stars.add_theme_font_size_override("font_size", 20)
                stars.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
                stars.add_theme_color_override("font_color", COL_GOLD if st > 0 else Color(0.42, 0.44, 0.47))
                stars.mouse_filter = Control.MOUSE_FILTER_IGNORE
                vb.add_child(stars)
                b.add_child(vb)
                b.pressed.connect(_start_level.bind(id))
                grid.add_child(b)
                if id == 1:
                        first_tile = b
        scroll.add_child(grid)
        lv.add_child(scroll)'''

new_levels_head = '''        # هدر: هلیا — راننده‌ی تیز پا
        var hdr := HBoxContainer.new()
        hdr.add_theme_constant_override("separation", 14)
        var helia := TextureRect.new()
        helia.texture = _safe_load("res://assets/sprites/helia_portrait.png")
        if helia.texture != null:
                helia.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
                helia.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
                helia.custom_minimum_size = Vector2(92, 108)
                hdr.add_child(helia)
        var ak := VBoxContainer.new()
        ak.add_theme_constant_override("separation", 2)
        # ⛔ درس RTL: RIGHT + EXPAND_FILL تا عرض هرگز کم نیاید
        ak.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        var ak_name := _mk_label("هلیا — راننده‌ی تیز پا", 26, false, true, COL_GOLD)
        ak_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        ak_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        ak.add_child(ak_name)
        var ak_line := _mk_label("پنج مرحله، یک هدف: خط پایان از جلو!", 20, true, false, COL_CREAM)
        ak_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        ak_line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        ak_line.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
        ak_line.add_theme_constant_override("outline_size", 5)
        ak.add_child(ak_line)
        hdr.add_child(ak)
        lv.add_child(hdr)
        var scroll := ScrollContainer.new()
        scroll.custom_minimum_size = Vector2(1196, 330)
        scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
        var grid := GridContainer.new()
        grid.columns = 3
        grid.add_theme_constant_override("h_separation", 12)
        grid.add_theme_constant_override("v_separation", 12)
        for lv_def in RACE3D.LEVELS:
                var id: int = int(lv_def["id"])
                var st: int = Globals.level_stars.get(id, 0)
                var unlocked: bool = Globals.level_unlocked(id)
                var b := Button.new()
                b.custom_minimum_size = Vector2(388, 118)
                _style_btn(b, "tile")
                b.disabled = not unlocked
                var vb := VBoxContainer.new()
                vb.set_anchors_preset(Control.PRESET_FULL_RECT)
                vb.alignment = BoxContainer.ALIGNMENT_CENTER
                vb.add_theme_constant_override("separation", 0)
                vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
                var num := Label.new()
                num.text = str(id) + " — " + str(lv_def["name"])
                if font_display != null:
                        num.add_theme_font_override("font", font_display)
                num.add_theme_font_size_override("font_size", 32)
                num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
                num.add_theme_color_override("font_color", COL_CREAM if unlocked else Color(0.55, 0.53, 0.50))
                num.mouse_filter = Control.MOUSE_FILTER_IGNORE
                vb.add_child(num)
                var desc := Label.new()
                desc.text = str(lv_def["desc"]) if unlocked else "با قهرمانی در مرحله‌ی قبل باز می‌شود"
                if font_bold != null:
                        desc.add_theme_font_override("font", font_bold)
                desc.add_theme_font_size_override("font_size", 16)
                desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
                desc.add_theme_color_override("font_color", Color(0.80, 0.80, 0.76, 0.85) if unlocked else Color(0.45, 0.44, 0.42))
                desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
                vb.add_child(desc)
                var stars := Label.new()
                var st_txt := ""
                for s in 3:
                        st_txt += "٭" if s < st else "·"
                stars.text = st_txt + "   •   " + str(int(lv_def["laps"])) + " دور"
                if font_bold != null:
                        stars.add_theme_font_override("font", font_bold)
                stars.add_theme_font_size_override("font_size", 18)
                stars.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
                stars.add_theme_color_override("font_color", COL_GOLD if st > 0 else Color(0.42, 0.44, 0.47))
                stars.mouse_filter = Control.MOUSE_FILTER_IGNORE
                vb.add_child(stars)
                b.add_child(vb)
                b.pressed.connect(_start_level.bind(id))
                grid.add_child(b)
                if id == 1:
                        first_tile = b
        scroll.add_child(grid)
        lv.add_child(scroll)'''
rep(old_levels_head, new_levels_head)

# ── ۵) متغیرهای پنل نو + RACE3D ──
rep('var panel_levels: PanelContainer\n',
    'var panel_levels: PanelContainer\nvar panel_guide: PanelContainer\nvar panel_about: PanelContainer\n')
rep('const BRAIN_SCRIPT := preload("res://scripts/car_brain.gd")',
    'const BRAIN_SCRIPT := preload("res://scripts/car_brain.gd")\nconst RACE3D := preload("res://scripts/race3d.gd")')

# ── ۶) ساخت پنل راهنما + درباره ما ──
rep('''func _build_ui() -> void:
        _build_title()
        _build_home_panel()
        _build_levels_panel()
        _show(panel_home)''',
'''func _build_info_panels() -> void:
        # راهنمای بازی — همه‌چیزی که راننده‌ی نو لازم دارد
        panel_guide = PanelContainer.new()
        var gs := _sb(Color(0.115, 0.125, 0.145, 0.97), Color(0.85, 0.68, 0.28, 0.55), 24, 3)
        panel_guide.add_theme_stylebox_override("panel", gs)
        panel_guide.custom_minimum_size = Vector2(1100, 560)
        panel_guide.set_anchors_preset(Control.PRESET_CENTER)
        panel_guide.offset_top = 10.0
        panel_guide.grow_horizontal = Control.GROW_DIRECTION_BOTH
        panel_guide.grow_vertical = Control.GROW_DIRECTION_BOTH
        var gv := VBoxContainer.new()
        gv.add_theme_constant_override("separation", 10)
        panel_guide.add_child(gv)
        var gt := _mk_label("راهنمای بازی", 44, false, true, COL_GOLD)
        gt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        gt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        gv.add_child(gt)
        var lines := [
                "هدف: قبل از سه رقیب از خط پایان رد شو — جایگاه اول سه ستاره می‌دهد.",
                "فرمان: انگشتت را نیمه‌ی چپ صفحه بکش — هرچه بیشتر بکشی تندتر می‌پیچی.",
                "دستی (دکمه‌ی قرمز): بگیر و بپیچ تا ماشین بلغزد — این همان دریفت است!",
                "نیترو (دکمه‌ی آبی): دریفت بزن تا شارژ شود، بعد نگه‌دار تا شعله بزند.",
                "ترمز: دکمه‌ی خاکستری کنار دستی — داخل پیچ تنگ سر کم کن.",
                "مراقب تاکسی‌ها و وانت‌ها باش — خوردن به آن‌ها سرعتت را می‌گیرد.",
                "ستاره‌ها در هر مرحله ذخیره می‌شوند و مرحله‌ی بعدی را باز می‌کنند.",
                "سکه‌ها را جمع کن و در کارگاه ماشین تازه و تیون بخر.",
        ]
        for ln in lines:
                var rl := _mk_label("•  " + ln, 22, true, false, COL_CREAM)
                rl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
                rl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
                rl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
                gv.add_child(rl)
        var gb := _mk_button(Globals.L("back"), 28, "dark", 68)
        gb.pressed.connect(func(): _show(panel_home))
        back_btn = gb
        gv.add_child(gb)
        add_child(panel_guide)
        panel_guide.visible = false

        # درباره ما — آخرین گزینه‌ی منو؛ بدون هیچ نام سازنده (متن نهایی بعداً توسط مالک بازی کامل می‌شود)
        panel_about = PanelContainer.new()
        var asb := _sb(Color(0.115, 0.125, 0.145, 0.97), Color(0.85, 0.68, 0.28, 0.55), 24, 3)
        panel_about.add_theme_stylebox_override("panel", asb)
        panel_about.custom_minimum_size = Vector2(900, 430)
        panel_about.set_anchors_preset(Control.PRESET_CENTER)
        panel_about.offset_top = 10.0
        panel_about.grow_horizontal = Control.GROW_DIRECTION_BOTH
        panel_about.grow_vertical = Control.GROW_DIRECTION_BOTH
        var av := VBoxContainer.new()
        av.add_theme_constant_override("separation", 12)
        panel_about.add_child(av)
        var at := _mk_label("درباره ما", 44, false, true, COL_GOLD)
        at.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        at.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        av.add_child(at)
        var a1 := _mk_label("تیز پا — مسابقه‌ی خیابانی خیابان‌های تهران", 26, true, false, COL_CREAM)
        a1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        a1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        av.add_child(a1)
        var a2 := _mk_label("از ولیعصر تا میدان آزادی؛ پنج مرحله، دریفت واقعی و نیترو.", 22, true, false, COL_CREAM)
        a2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        a2.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        a2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        av.add_child(a2)
        var a3 := _mk_label("نسخه " + Globals.VERSION + " — بیلد " + str(Globals.BUILD), 18, true, false, Color(1, 1, 1, 0.6))
        a3.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        a3.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        av.add_child(a3)
        var ab := _mk_button(Globals.L("back"), 28, "dark", 68)
        ab.pressed.connect(func(): _show(panel_home))
        av.add_child(ab)
        add_child(panel_about)
        panel_about.visible = false

func _build_ui() -> void:
        _build_title()
        _build_home_panel()
        _build_levels_panel()
        _build_info_panels()
        _show(panel_home)''')

# ── ۷) _show: پنل‌های نو ──
rep('''func _show(p: PanelContainer) -> void:
        if panel_home == null or panel_levels == null:
                return
        panel_home.visible = p == panel_home
        panel_levels.visible = p == panel_levels''',
'''func _show(p: PanelContainer) -> void:
        if panel_home == null or panel_levels == null:
                return
        panel_home.visible = p == panel_home
        panel_levels.visible = p == panel_levels
        if panel_guide != null:
                panel_guide.visible = p == panel_guide
        if panel_about != null:
                panel_about.visible = p == panel_about''')

# ── ۸) پلاک پیش‌فرض هلیا ──
rep('Globals.plate_name = "بوقی"', 'Globals.plate_name = "هلیا"')

# ── ۹) مسابقه سریع = مرحله‌ی اول تیز پا ──
rep('''func _start_quick_race() -> void:
        # مسابقه سریع با حریف AI (قاب: حلقه‌ی مسابقه‌ی محله)
        Globals.set_meta("custom_level", {
                "id": 901, "type": "race", "name": "حلقه‌ی مسابقه‌ی محله", "district": "محله",
                "speed": 13.2, "distance": 460, "time": 70,
                "obstacle_rate": 0.5, "coin_rate": 0.85, "ramp_rate": 0.3, "reward": 70,
        })
        Globals.set_meta("start_level", 901)
        get_tree().change_scene_to_file("res://scenes/game.tscn")''',
'''func _start_quick_race() -> void:
        # مسابقه سریع = آخرین مرحله‌ی باز شده (یا مرحله‌ی ۱)
        var nid := 1
        for i in range(5, 0, -1):
                if Globals.level_unlocked(i):
                        nid = i
                        break
        Globals.set_meta("start_level", nid)
        get_tree().change_scene_to_file("res://scenes/game.tscn")''')

# حذف ارجاع اکبر در _show (دیگر اکبر در هدر نیست)
rep('''        # هر باز شدن مأموریت‌ها: تیکه تازه‌ی اکبر
        if p == panel_levels and akbar_line_label != null:
                var line := CarBrain.pick_line("akbar", "idle")
                if line.is_empty():
                        line = "امروز جاده مال ماست!"
                akbar_line_label.text = line
                if brain != null and akbar_rect != null and is_instance_valid(akbar_rect) and akbar_rect.texture != null:
                        brain.say(akbar_rect, "akbar", "idle")
        _refresh()''',
'''        _refresh()''')

io.open(P, "w", encoding="utf-8").write(src)
if fails:
    print("FAILED patterns:")
    for f in fails:
        print("  ✗", f)
    sys.exit(1)
print("menu.gd patched OK — all patterns applied")
