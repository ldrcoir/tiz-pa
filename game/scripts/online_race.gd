extends Control

signal akbar_oomad
signal lagh_shod

const RANG_SHISHE := Color(0.10, 0.11, 0.13, 0.96)
const RANG_TALA := Color(0.96, 0.76, 0.25)
const RANG_KERM := Color(0.95, 0.93, 0.88)
const RANG_GHERMEZ := Color(0.78, 0.15, 0.12)

const JOMLE_JOSTOJOO := [
        "دنبال یه راننده‌ی واقعی تو محله…",
        "کی‌چی آنلاینه؟… داری گرم می‌شی؟",
        "یه حریف از سراسر ایران… صبر کن هنوز!",
        "اینترنت محله نفسش بند اومد…",
]
const JOMLE_AKBAR := [
        "پیدا نشد! اکبر پشت فرمون می‌شینه…",
        "اکبر: بگذریم که حاجی‌خانم منتظره!",
]

var s_entezar := 15.0
var _faz := "SEARCHING"
var _t := 0.0
var _vaziat: Label
var _noqtha: Label
var _midad: ProgressBar
var _tamaam := false

func _ready() -> void:
        layout_direction = Control.LAYOUT_DIRECTION_LTR
        set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT) # فیکس: درختی=حفظ مستطیل ۰×۰؛ باید آفست‌ها هم ست شوند
        var parde := ColorRect.new()
        parde.color = Color(0, 0, 0, 0.72)
        parde.set_anchors_preset(Control.PRESET_FULL_RECT)
        add_child(parde)
        var panel := PanelContainer.new()
        var sb := StyleBoxFlat.new()
        sb.bg_color = RANG_SHISHE
        sb.border_color = RANG_TALA
        sb.set_border_width_all(2)
        sb.set_corner_radius_all(22)
        sb.shadow_color = Color(0, 0, 0, 0.55)
        sb.shadow_size = 14
        sb.content_margin_left = 26
        sb.content_margin_right = 26
        sb.content_margin_top = 20
        sb.content_margin_bottom = 20
        panel.add_theme_stylebox_override("panel", sb)
        panel.custom_minimum_size = Vector2(560, 300)
        panel.set_anchors_preset(Control.PRESET_CENTER)
        panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
        panel.grow_vertical = Control.GROW_DIRECTION_BOTH
        add_child(panel)
        var vb := VBoxContainer.new()
        vb.add_theme_constant_override("separation", 14)
        vb.alignment = BoxContainer.ALIGNMENT_CENTER
        panel.add_child(vb)
        var f_d := _fnt("res://assets/fonts/Lalezar-Regular.ttf")
        var f_b := _fnt("res://assets/fonts/Vazirmatn-Bold.ttf")
        var onvan := Label.new()
        onvan.text = "مسابقه آنلاین"
        if f_d != null:
                onvan.add_theme_font_override("font", f_d)
        onvan.add_theme_font_size_override("font_size", 34)
        onvan.add_theme_color_override("font_color", RANG_TALA)
        onvan.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        vb.add_child(onvan)
        _vaziat = Label.new()
        if f_b != null:
                _vaziat.add_theme_font_override("font", f_b)
        _vaziat.add_theme_font_size_override("font_size", 21)
        _vaziat.add_theme_color_override("font_color", RANG_KERM)
        _vaziat.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        _vaziat.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        _vaziat.custom_minimum_size = Vector2(500, 60)
        vb.add_child(_vaziat)
        _noqtha = Label.new()
        _noqtha.text = "• • •"
        _noqtha.add_theme_font_size_override("font_size", 26)
        _noqtha.add_theme_color_override("font_color", RANG_TALA)
        _noqtha.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        vb.add_child(_noqtha)
        _midad = ProgressBar.new()
        _midad.min_value = 0
        _midad.max_value = 1.0
        _midad.value = 0.0
        _midad.show_percentage = false
        _midad.custom_minimum_size = Vector2(500, 14)
        var por := StyleBoxFlat.new()
        por.bg_color = RANG_GHERMEZ
        por.set_corner_radius_all(7)
        _midad.add_theme_stylebox_override("fill", por)
        var skrole_paszamine := StyleBoxFlat.new()
        skrole_paszamine.bg_color = Color(0.18, 0.19, 0.22)
        skrole_paszamine.set_corner_radius_all(7)
        _midad.add_theme_stylebox_override("background", skrole_paszamine)
        vb.add_child(_midad)
        var ersh := Label.new()
        ersh.text = "دلتنگ نشدی؟ می‌تونی صبر کنی، اکبر همیشه در دسترسه!"
        if f_b != null:
                ersh.add_theme_font_override("font", f_b)
        ersh.add_theme_font_size_override("font_size", 15)
        ersh.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))
        ersh.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        vb.add_child(ersh)
        var lagh := Button.new()
        lagh.text = "بی‌خیال"
        if f_b != null:
                lagh.add_theme_font_override("font", f_b)
        lagh.add_theme_font_size_override("font_size", 22)
        lagh.custom_minimum_size = Vector2(220, 72)
        lagh.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
        var dokme_lagh := StyleBoxFlat.new()
        dokme_lagh.bg_color = Color(0.20, 0.22, 0.25)
        dokme_lagh.set_corner_radius_all(12)
        lagh.add_theme_stylebox_override("normal", dokme_lagh)
        lagh.pressed.connect(func(): _payan(false))
        vb.add_child(lagh)

func _fnt(masir: String) -> FontFile:
        if ResourceLoader.exists(masir):
                var r := load(masir)
                if r is FontFile:
                        return r
        return null

func shoroo(p_wait_s := 15.0) -> void:
        s_entezar = maxf(5.0, p_wait_s)
        _faz = "SEARCHING"
        _t = 0.0
        _vaziat.text = JOMLE_JOSTOJOO[0]

func _process(delta: float) -> void:
        if _tamaam:
                return
        _t += delta
        _noqtha.visible = fmod(_t, 0.8) < 0.55
        if _faz == "SEARCHING":
                _midad.value = clamp(_t / s_entezar, 0.0, 1.0)
                var sh := int(_t / maxf(s_entezar / JOMLE_JOSTOJOO.size(), 0.01))
                _vaziat.text = JOMLE_JOSTOJOO[clampi(sh, 0, JOMLE_JOSTOJOO.size() - 1)]
                if _t >= s_entezar:
                        _faz = "TAKEOVER"
                        _t = 0.0
                        _vaziat.text = JOMLE_AKBAR[0]
                        _vaziat.add_theme_color_override("font_color", Color(0.95, 0.55, 0.35))
        elif _faz == "TAKEOVER":
                _vaziat.text = JOMLE_AKBAR[0] if _t < 1.4 else JOMLE_AKBAR[1]
                if _t >= 2.6:
                        _payan(true)

func _payan(takeover: bool) -> void:
        if _tamaam:
                return
        _tamaam = true
        if takeover:
                akbar_oomad.emit()
        else:
                lagh_shod.emit()
        queue_free()
