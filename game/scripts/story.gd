extends Control

const PRE_DASTAN := preload("res://scripts/story_mgr.gd")
const PRE_SEKANS := preload("res://scripts/cutscene.gd")

const RANG_SHISHE := Color(0.10, 0.11, 0.13, 0.92)
const RANG_TALA := Color(0.96, 0.76, 0.25)
const RANG_KERM := Color(0.95, 0.93, 0.88)
const RANG_GHERMEZ := Color(0.78, 0.15, 0.12)

var shabake: GridContainer
var matne_delha: Label
var payam: Label
var sahne: Control = null
var azm_dastan := false
var _st_ok := false

func _ready() -> void:
        layout_direction = Control.LAYOUT_DIRECTION_LTR
        azm_dastan = OS.get_cmdline_user_args().has("--storytest")
        _paszamine_besaz()
        _rabet_besaz()
        _taze_sazi()
        if azm_dastan:
                _azme_dastan()

func _paszamine_besaz() -> void:
        var gt := GradientTexture2D.new()
        var g := Gradient.new()
        g.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
        g.colors = PackedColorArray([Color(0.24, 0.13, 0.10), Color(0.13, 0.08, 0.07), Color(0.06, 0.04, 0.04)])
        gt.gradient = g
        gt.fill_from = Vector2(0.3, 0.0)
        gt.fill_to = Vector2(0.7, 1.0)
        var paszamine := TextureRect.new()
        paszamine.texture = gt
        paszamine.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        paszamine.set_anchors_preset(Control.PRESET_FULL_RECT)
        paszamine.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(paszamine)

func _fnt(masir: String) -> FontFile:
        if ResourceLoader.exists(masir):
                var r := load(masir)
                if r is FontFile:
                        return r
        return null

func _matn_besaz(matn: String, size: int, display := false, rangi := RANG_KERM) -> Label:
        var l := Label.new()
        l.text = matn
        var f := _fnt("res://assets/fonts/Lalezar-Regular.ttf") if display else _fnt("res://assets/fonts/Vazirmatn-Regular.ttf")
        if f != null:
                l.add_theme_font_override("font", f)
        l.add_theme_font_size_override("font_size", size)
        l.add_theme_color_override("font_color", rangi)
        l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        return l

func _sb(paszamine: Color, border: Color, radius: int) -> StyleBoxFlat:
        var sb := StyleBoxFlat.new()
        sb.bg_color = paszamine
        sb.set_corner_radius_all(radius)
        sb.border_color = border
        sb.set_border_width_all(2)
        sb.shadow_color = Color(0, 0, 0, 0.45)
        sb.shadow_size = 8
        return sb

func _rabet_besaz() -> void:
        var onvan := _matn_besaz("زندگی محله", 46, true, RANG_TALA)
        onvan.anchor_left = 0.0
        onvan.anchor_right = 1.0
        onvan.offset_top = 30
        onvan.offset_bottom = 92
        add_child(onvan)
        var matne_zir := _matn_besaz("فصل ۱ — تهران  •  هر کارِ خوب، یک دل به محله", 18, false, Color(1, 1, 1, 0.85))
        matne_zir.anchor_left = 0.0
        matne_zir.anchor_right = 1.0
        matne_zir.offset_top = 96
        matne_zir.offset_bottom = 126
        add_child(matne_zir)
        matne_delha = _matn_besaz("", 24, true, Color(0.95, 0.45, 0.45))
        matne_delha.anchor_left = 0.0
        matne_delha.anchor_right = 1.0
        matne_delha.offset_top = 132
        matne_delha.offset_bottom = 168
        add_child(matne_delha)
        var panel := PanelContainer.new()
        panel.add_theme_stylebox_override("panel", _sb(RANG_SHISHE, Color(0.85, 0.68, 0.28, 0.5), 22))
        panel.custom_minimum_size = Vector2(880, 440)
        panel.set_anchors_preset(Control.PRESET_CENTER)
        panel.offset_top = 30
        panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
        panel.grow_vertical = Control.GROW_DIRECTION_BOTH
        add_child(panel)
        var mv := MarginContainer.new()
        mv.add_theme_constant_override("margin_left", 16)
        mv.add_theme_constant_override("margin_right", 16)
        mv.add_theme_constant_override("margin_top", 12)
        mv.add_theme_constant_override("margin_bottom", 12)
        panel.add_child(mv)
        shabake = GridContainer.new()
        shabake.columns = 4
        shabake.add_theme_constant_override("h_separation", 12)
        shabake.add_theme_constant_override("v_separation", 12)
        mv.add_child(shabake)
        payam = _matn_besaz("", 20, false, RANG_TALA)
        payam.anchor_left = 0.0
        payam.anchor_right = 1.0
        payam.anchor_top = 1.0
        payam.anchor_bottom = 1.0
        payam.offset_top = -60
        payam.offset_bottom = -24
        add_child(payam)
        var bargasht := Button.new()
        bargasht.text = "برگشت به منو"
        var fb := _fnt("res://assets/fonts/Vazirmatn-Bold.ttf")
        if fb != null:
                bargasht.add_theme_font_override("font", fb)
        bargasht.add_theme_font_size_override("font_size", 24)
        bargasht.custom_minimum_size = Vector2(240, 76)
        bargasht.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
        bargasht.offset_left = 18
        bargasht.offset_top = -98
        bargasht.offset_bottom = -22
        var sb := _sb(Color(0.16, 0.175, 0.20, 0.97), RANG_TALA, 14)
        bargasht.add_theme_stylebox_override("normal", sb)
        bargasht.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/menu.tscn"))
        add_child(bargasht)

func _taze_sazi() -> void:
        matne_delha.text = "دلِ محله: %d / %d" % [Koli.delha, PRE_DASTAN.total_hearts()]
        for c in shabake.get_children():
                c.queue_free()
        var kartha: Array = PRE_DASTAN.card_list()
        for i in kartha.size():
                var c: Dictionary = kartha[i]
                var b := Button.new()
                b.custom_minimum_size = Vector2(220, 104)
                var qesme_amaade: bool = bool(c.get("ready", false))
                var dide: bool = bool(c.get("seen", false))
                var bazshode: bool = PRE_DASTAN.unlocked(i)
                var vb := VBoxContainer.new()
                vb.set_anchors_preset(Control.PRESET_FULL_RECT)
                vb.alignment = BoxContainer.ALIGNMENT_CENTER
                vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
                var n := Label.new()
                n.text = str(int(c["num"]))
                var fd := _fnt("res://assets/fonts/Lalezar-Regular.ttf")
                if fd != null:
                        n.add_theme_font_override("font", fd)
                n.add_theme_font_size_override("font_size", 38)
                n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
                n.mouse_filter = Control.MOUSE_FILTER_IGNORE
                vb.add_child(n)
                var t := Label.new()
                t.text = str(c["title"])
                var fb := _fnt("res://assets/fonts/Vazirmatn-Bold.ttf")
                if fb != null:
                        t.add_theme_font_override("font", fb)
                t.add_theme_font_size_override("font_size", 17)
                t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
                t.mouse_filter = Control.MOUSE_FILTER_IGNORE
                vb.add_child(t)
                var st := Label.new()
                st.text = "انجام شد" if dide else ("بازی کن" if (qesme_amaade and bazshode) else ("قفل" if qesme_amaade else "به‌زودی"))
                st.add_theme_font_size_override("font_size", 15)
                st.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
                st.mouse_filter = Control.MOUSE_FILTER_IGNORE
                st.add_theme_color_override("font_color", Color(0.55, 0.85, 0.55) if dide else (RANG_TALA if (qesme_amaade and bazshode) else Color(0.5, 0.5, 0.5)))
                vb.add_child(st)
                b.add_child(vb)
                b.disabled = not (qesme_amaade and bazshode)
                b.pressed.connect(_baz_kon.bind(i, kartha))
                shabake.add_child(b)

func _baz_kon(sh: int, kartha: Array) -> void:
        var c: Dictionary = kartha[sh]
        var ep: Dictionary = PRE_DASTAN.load_episode(str(c["id"]))
        if ep.is_empty():
                return
        if sahne != null and is_instance_valid(sahne):
                sahne.queue_free()
        sahne = PRE_SEKANS.new()
        sahne.setup(ep)
        sahne.finished.connect(_qesmat_tamaam_shod.bind(ep))
        add_child(sahne)

func _qesmat_tamaam_shod(_episode_id: String, ep: Dictionary) -> void:
        # ⛔ فیکس: سیگنال finished خودش episode_id می‌فرستد + bind(ep) → دو آرگومان؛
        # امضای قبلی تک‌آرگومان بود و کل پایان اپیزود بی‌صدا شکست می‌خورد
        if sahne != null and is_instance_valid(sahne):
                sahne.queue_free()
                sahne = null
        var delha := int(ep.get("hearts", 1))
        var avalin := not Koli.dastan_dide.has(str(ep.get("id", "")))
        PRE_DASTAN.mark_seen(str(ep.get("id", "")), delha if avalin else 0)
        var mamooryat: Dictionary = ep.get("mission", {})
        if avalin and not mamooryat.is_empty() and not azm_dastan:
                Koli.set_meta("custom_level", mamooryat.get("level", {}))
                Koli.set_meta("start_level", int(mamooryat["level"].get("id", 101)))
                Koli.set_meta("mission_label_custom", str(mamooryat.get("label", "")))
                get_tree().change_scene_to_file("res://scenes/game.tscn")
                return
        if avalin and not mamooryat.is_empty() and azm_dastan:
                # مسیر مأموریت در تست فقط بررسی می‌شود، وارد مسابقه نمی‌رویم
                var marhale_darad: bool = mamooryat.has("level") and not (mamooryat["level"] as Dictionary).is_empty()
                print("[tizpa][storytest] MISSION-DATA ", "OK" if marhale_darad else "FAIL")
        if avalin:
                Koli.pool_efe(40)
                _payame_zoodgozar("اپیزود تمام شد! +۴۰ سکه و یک دلِ محله")
        else:
                _payame_zoodgozar("دوباره دیدی! محله هنوز همون قد بامزه‌ست")
        _taze_sazi()
        if azm_dastan:
                _st_ok = true

func _payame_zoodgozar(matn: String) -> void:
        payam.text = matn
        payam.modulate.a = 1.0
        var tw := create_tween()
        tw.tween_interval(2.2)
        tw.tween_property(payam, "modulate:a", 0.0, 0.6)

func _azme_dastan() -> void:
        await get_tree().create_timer(0.8).timeout
        _aks("/home/z/my-project/scripts/shot_story_hub.png")
        _baz_kon(0, PRE_DASTAN.card_list())
        await get_tree().create_timer(1.4).timeout
        _aks("/home/z/my-project/scripts/shot_story_scene.png")
        # تپ شبیه‌سازی‌شده تا پایان اپیزود — همان مسیر ورودی واقعی Button
        var paseban := 0
        while sahne != null and is_instance_valid(sahne) and paseban < 400:
                paseban += 1
                if paseban % 20 == 0:
                        print("[tizpa][storytest] tap#", paseban, " stage_alive=", is_instance_valid(sahne),
                                " size=", sahne.size, " gpos=", sahne.global_position,
                                " vis=", sahne.visible, " ar=", sahne.anchor_right, " ab=", sahne.anchor_bottom, " parent=", sahne.get_parent().name, " psize=", sahne.get_parent().size,
                                " dialog_active=", sahne.dialogue.is_active() if sahne.dialogue != null else "?")
                sahne._on_tap()
                await get_tree().create_timer(0.22).timeout
        await get_tree().create_timer(0.6).timeout
        _aks("/home/z/my-project/scripts/shot_story_end.png")
        if _st_ok or Koli.dastan_dide.has("ep1"):
                print("[tizpa][storytest] STORYTEST OK — اپیزود کامل پخش شد")
                get_tree().quit(0)
        else:
                print("[tizpa][storytest] STORYTEST FAIL")
                get_tree().quit(1)

func _aks(masir: String) -> void:
        var aks := get_viewport().get_texture().get_image()
        if aks != null:
                aks.save_png(masir)
