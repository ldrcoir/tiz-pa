extends Control

signal tamaam_shod(episode_id: String)
signal mamooryat_khast(qesmat: Dictionary)

const PRE_GFT := preload("res://scripts/dialogue.gd")

const ASMAN_BALA := Color(0.32, 0.55, 0.78)
const ASMAN_PAIN := Color(0.88, 0.72, 0.52)
const ZAMIN_RAS := Color(0.22, 0.20, 0.19)
const PIYADERO := Color(0.42, 0.40, 0.37)
const ZAMIN_Y := 0.78   # خط آسفالت (نسبت ارتفاع)
const ARZE_MASHIN := 0.20      # ارتفاع ماشین (نسبت ارتفاع)

var qesmat: Dictionary = {}
var goftogu: Control
var _bazigaran := {}       # id -> Dictionary{node, h, base_y}
var _tvinha: Array = []
var _entezare_lamse := false
var _dar_ejra := false

func tanzim(ep: Dictionary) -> void:
        qesmat = ep

func _ready() -> void:
        set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT) # فیکس: درختی=حفظ مستطیل ۰×۰؛ باید آفست‌ها هم ست شوند
        layout_direction = Control.LAYOUT_DIRECTION_LTR
        _khiaban_besaz()
        goftogu = PRE_GFT.new()
        add_child(goftogu)
        goftogu.next_requested.connect(func(): _entezare_lamse = false)
        var girande_lams := Button.new()
        girande_lams.flat = true
        girande_lams.set_anchors_preset(Control.PRESET_FULL_RECT)
        girande_lams.modulate.a = 0.0
        girande_lams.pressed.connect(_lamse_shod)
        add_child(girande_lams)
        if not _dar_ejra:
                _dar_ejra = true
                _ejra.call_deferred()

func _khiaban_besaz() -> void:
        var gt := GradientTexture2D.new()
        var g := Gradient.new()
        g.offsets = PackedFloat32Array([0.0, 1.0])
        g.colors = PackedColorArray([ASMAN_BALA, ASMAN_PAIN])
        gt.gradient = g
        gt.fill_from = Vector2(0, 0)
        gt.fill_to = Vector2(0, 1)
        var asman := TextureRect.new()
        asman.texture = gt
        asman.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        asman.set_anchors_preset(Control.PRESET_FULL_RECT)
        asman.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(asman)
        # دور شهر — همان اسپرایت‌های مسیر (هویت بصری مشترک)
        _laye("res://assets/sprites/bg_far.png", 0.30, 0.20, 0.52)
        _laye("res://assets/sprites/bg_mid.png", 0.52, 0.14, 0.40)
        # پیاده‌رو و آسفالت
        var rahro := ColorRect.new()
        rahro.color = PIYADERO
        rahro.anchor_left = 0.0
        rahro.anchor_right = 1.0
        rahro.anchor_top = ZAMIN_Y - 0.05
        rahro.anchor_bottom = ZAMIN_Y
        rahro.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(rahro)
        var jade := ColorRect.new()
        jade.color = ZAMIN_RAS
        jade.anchor_left = 0.0
        jade.anchor_right = 1.0
        jade.anchor_top = ZAMIN_Y
        jade.anchor_bottom = 1.0
        jade.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(jade)
        var khat := ColorRect.new()
        khat.color = Color(0.85, 0.82, 0.75, 0.7)
        khat.anchor_left = 0.0
        khat.anchor_right = 1.0
        khat.anchor_top = ZAMIN_Y + 0.075
        khat.anchor_bottom = ZAMIN_Y + 0.083
        khat.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(khat)

func _laye(masir: String, bala: float, h: float, alpha: float) -> void:
        if not ResourceLoader.exists(masir):
                return
        var tr := TextureRect.new()
        tr.texture = load(masir)
        tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
        tr.modulate.a = alpha
        tr.anchor_left = 0.0
        tr.anchor_right = 1.0
        tr.anchor_top = bala
        tr.anchor_bottom = bala + h
        tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(tr)

func _bazigar(id: String) -> Dictionary:
        return _bazigaran.get(id, {})

func _tamin_bazigar(a: Dictionary) -> Control:
        var id := str(a.get("id", ""))
        if _bazigaran.has(id) and is_instance_valid(_bazigaran[id]["node"]):
                return _bazigaran[id]["node"]
        var tr := TextureRect.new()
        var masire_teks := "res://assets/sprites/car_%s.webp" % str(a.get("sprite", id))
        if ResourceLoader.exists(masire_teks):
                tr.texture = load(masire_teks)
        tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        tr.flip_h = not bool(a.get("flip", false)) # اسپرایت‌های تازه رو به چپ‌اند
        tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
        var vw := get_viewport_rect().size
        var h := ARZE_MASHIN * float(a.get("scale", 1.0)) * vw.y
        var w := h * 2.1 # نسبت تقریبی عرض/ارتفاع اسپرایت‌های side
        # چیدمان مستقیم (بدون انکر) — ضد مشکل RTL و ضدرزولوشن
        tr.anchor_left = 0.0
        tr.anchor_right = 0.0
        tr.anchor_top = 0.0
        tr.anchor_bottom = 0.0
        tr.size = Vector2(w, h)
        tr.position = Vector2(float(a.get("x", 0.5)) * vw.x - w * 0.5, ZAMIN_Y * vw.y - h + h * 0.10)
        add_child(tr)
        _bazigaran[id] = {"node": tr, "h": h}
        return tr

func _jaybede(gereh: Control, x01: float) -> void:
        var vw := get_viewport_rect().size
        gereh.position.x = x01 * vw.x - gereh.size.x * 0.5

func _tw() -> Tween:
        var t := create_tween()
        _tvinha.append(t)
        return t

func _lamse_shod() -> void:
        if goftogu != null and goftogu.is_active():
                goftogu.tap()
        else:
                _entezare_lamse = false

func _benar(text: String) -> void:
        var l := Label.new()
        l.text = text
        var f := _fnt("res://assets/fonts/Lalezar-Regular.ttf")
        if f != null:
                l.add_theme_font_override("font", f)
        l.add_theme_font_size_override("font_size", 40)
        l.add_theme_color_override("font_color", Color(0.96, 0.76, 0.25))
        l.add_theme_color_override("font_outline_color", Color(0.08, 0.05, 0.03))
        l.add_theme_constant_override("outline_size", 10)
        l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        l.set_anchors_preset(Control.PRESET_TOP_WIDE)
        l.offset_top = 24
        l.offset_bottom = 84
        l.mouse_filter = Control.MOUSE_FILTER_IGNORE
        add_child(l)
        l.modulate.a = 0.0
        _tw().tween_property(l, "modulate:a", 1.0, 0.35)
        _tw().tween_interval(1.6)
        _tw().tween_property(l, "modulate:a", 0.0, 0.5)
        _tw().tween_callback(l.queue_free)

func _fnt(masir: String) -> FontFile:
        if ResourceLoader.exists(masir):
                var r := load(masir)
                if r is FontFile:
                        return r
        return null

func _ejra() -> void:
        var zarbha: Array = qesmat.get("beats", [])
        for b in zarbha:
                await _zarbe_dastan(b)
                while _entezare_lamse:
                        await get_tree().process_frame
                if not is_inside_tree():
                        return
        tamaam_shod.emit(str(qesmat.get("id", "")))

func _zarbe_dastan(b: Dictionary) -> void:
        var naghsh := str(b.get("do", ""))
        var vw := get_viewport_rect().size
        match naghsh:
                "banner":
                        _benar(str(b.get("text", "")))
                        await get_tree().create_timer(0.6).timeout
                "enter":
                        var gereh: Control = _tamin_bazigar(b)
                        var kenar := str(b.get("side", "right"))
                        var hadaf := float(b.get("x", 0.5))
                        var x_shoroo := (1.25 if kenar == "right" else -0.25)
                        _jaybede(gereh, x_shoroo)
                        _tw().tween_property(gereh, "position:x", hadaf * vw.x - gereh.size.x * 0.5, float(b.get("dur", 1.0)))\
                                .set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
                        await get_tree().create_timer(float(b.get("dur", 1.0))).timeout
                "move":
                        var n2: Control = _bazigar(str(b.get("actor", "")))["node"] if _bazigaran.has(str(b.get("actor", ""))) else null
                        if n2 != null:
                                _tw().tween_property(n2, "position:x", float(b.get("x", 0.5)) * vw.x - n2.size.x * 0.5, float(b.get("dur", 0.8)))\
                                        .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
                                await get_tree().create_timer(float(b.get("dur", 0.8))).timeout
                "flip":
                        var n3: Control = _bazigar(str(b.get("actor", "")))["node"] if _bazigaran.has(str(b.get("actor", ""))) else null
                        if n3 != null:
                                n3.flip_h = bool(b.get("flip", true))
                "bounce":
                        var qute4: Dictionary = _bazigar(str(b.get("actor", "")))
                        if qute4.has("node") and is_instance_valid(qute4["node"]):
                                var n4: Control = qute4["node"]
                                var y0 := n4.position.y
                                var damane := float(b.get("amp", 0.030)) * vw.y
                                var t := _tw()
                                for i in int(b.get("times", 2)):
                                        t.tween_property(n4, "position:y", y0 - damane, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
                                        t.tween_property(n4, "position:y", y0, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
                                await t.finished
                "nod":
                        var qute5: Dictionary = _bazigar(str(b.get("actor", "")))
                        if qute5.has("node") and is_instance_valid(qute5["node"]):
                                var n5: Control = qute5["node"]
                                n5.pivot_offset = Vector2(n5.size.x * 0.5, n5.size.y)
                                var t5 := _tw()
                                for i in 2:
                                        t5.tween_property(n5, "rotation_degrees", 5.0, 0.12)
                                        t5.tween_property(n5, "rotation_degrees", -5.0, 0.12)
                                t5.tween_property(n5, "rotation_degrees", 0.0, 0.1)
                                await t5.finished
                "line":
                        var ki := str(b.get("who", ""))
                        var sh_langar := str(b.get("actor", ""))
                        var d: Control = goftogu
                        d.show_line(ki, str(b.get("text", "")), bool(b.get("offscreen", false)))
                        _entezare_lamse = true
                        while _entezare_lamse:
                                await get_tree().process_frame
                        await get_tree().create_timer(0.12).timeout
                        d.hide_line()
                "wait":
                        await get_tree().create_timer(float(b.get("dur", 0.5))).timeout
                "end":
                        pass
