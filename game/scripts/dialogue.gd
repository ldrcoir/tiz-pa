extends Control

signal badi_khast

const RANG_ZAMINE := Color(0.085, 0.095, 0.115, 0.96)
const RANG_LABE := Color(0.85, 0.68, 0.28, 0.55)
const RANG_KERM := Color(0.95, 0.93, 0.88)
const RANG_TALA := Color(0.96, 0.76, 0.25)
const RANG_KHAMOSH := Color(0.86, 0.62, 0.55) # گوینده‌ی نامرئی (پشت دیوار)

var fnt_matn: FontFile
var esme_fnt: FontFile
var _matne_esm: Label
var _matne_badane: Label
var _panel: PanelContainer
var _matne_kamel := ""
var _harf_dar_sanie := 34.0
var _faal := false

func _ready() -> void:
        set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT) # فیکس: درختی=حفظ مستطیل ۰×۰؛ باید آفست‌ها هم ست شوند
        mouse_filter = Control.MOUSE_FILTER_IGNORE
        fnt_matn = _fnt("res://assets/fonts/Vazirmatn-Regular.ttf")
        esme_fnt = _fnt("res://assets/fonts/Lalezar-Regular.ttf")
        _panel = PanelContainer.new()
        var sb := StyleBoxFlat.new()
        sb.bg_color = RANG_ZAMINE
        sb.border_color = RANG_LABE
        sb.set_border_width_all(2)
        sb.set_corner_radius_all(18)
        sb.shadow_color = Color(0, 0, 0, 0.5)
        sb.shadow_size = 12
        sb.content_margin_left = 22
        sb.content_margin_right = 22
        sb.content_margin_top = 12
        sb.content_margin_bottom = 14
        _panel.add_theme_stylebox_override("panel", sb)
        _panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
        var vb := VBoxContainer.new()
        vb.add_theme_constant_override("separation", 4)
        vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
        _panel.add_child(vb)
        _matne_esm = Label.new()
        _matn_shekl(_matne_esm, 26, true, true)
        _matne_esm.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        vb.add_child(_matne_esm)
        _matne_badane = Label.new()
        _matn_shekl(_matne_badane, 24, false, false)
        _matne_badane.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        _matne_badane.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        vb.add_child(_matne_badane)
        add_child(_panel)
        # نوار پایین — عرض پنل با انکرها (ضد چیدمان دستی)
        _panel.anchor_left = 0.5
        _panel.anchor_right = 0.5
        _panel.anchor_top = 1.0
        _panel.anchor_bottom = 1.0
        _panel.offset_left = -420.0
        _panel.offset_right = 420.0
        _panel.offset_top = -196.0
        _panel.offset_bottom = -24.0
        _panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
        _panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
        visible = false

func _fnt(masir: String) -> FontFile:
        if ResourceLoader.exists(masir):
                var r := load(masir)
                if r is FontFile:
                        return r
        return null

func _matn_shekl(l: Label, size: int, disp: bool, outline: bool) -> void:
        var f := esme_fnt if disp else fnt_matn
        if f != null:
                l.add_theme_font_override("font", f)
        l.add_theme_font_size_override("font_size", size)
        l.add_theme_color_override("font_color", RANG_TALA if disp else RANG_KERM)
        if outline:
                l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.75))
                l.add_theme_constant_override("outline_size", 5)

func jomle_neshon(ki: String, text: String, offscreen := false) -> void:
        _matne_esm.text = ki + ("  (از پشت دیوار)" if offscreen else "")
        _matne_esm.add_theme_color_override("font_color", RANG_KHAMOSH if offscreen else RANG_TALA)
        _matne_kamel = text
        _matne_badane.text = text
        _matne_badane.visible_characters = 0
        visible = true
        _faal = true

func jomle_pin() -> void:
        visible = false
        _faal = false

func dar_neveshtan() -> bool:
        # ⛔ فیکس باگ «قفل روی اولین جمله»: visible_characters=-1 یعنی «کامل نشان بده»
        # ولی مقایسه‌ی ساده -1 < length همیشه true می‌ماند و next هرگز نمی‌آمد!
        if not _faal:
                return false
        var vc := _matne_badane.visible_characters
        if vc < 0:
                return false
        return vc < _matne_kamel.length()

func faal_ast() -> bool:
        return _faal

func _process(delta: float) -> void:
        if _faal and dar_neveshtan():
                _matne_badane.visible_characters += int(maxf(1.0, _harf_dar_sanie * delta))

func lamse() -> void:
        if not _faal:
                return
        if dar_neveshtan():
                _matne_badane.visible_characters = -1 # کامل نشون بده
        else:
                badi_khast.emit()
