# صحنهٔ نمایشِ ورقِ حرکتِ هلیا — پس‌زمینه، زمین و سایه با کد کشیده می‌شوند
# سناریو: هلیا خودش می‌دود و در زمان‌های معیّن می‌پرد؛ برای فیلمِ نمایشی ۱۴ثانیه‌ای
# اجرا:  godot --path to/azmayesh_helia2d          (خروج در ۱۵ ثانیه)
#        godot --path to/azmayesh_helia2d -- --aks (فقط یک عکس برای بررسی)
extends Node2D

const ZAMIN_Y := 660.0
const JAHAN_W := 6000.0

const HeliaScript := preload("res://helia.gd")

var player: CharacterBody2D
var cam: Camera2D
var bg_kuh: Node2D
var bg_tappe: Node2D
var t := 0.0
var aks_mode := false
var aks_done := false


class Khorshid extends Node2D:
	func _draw() -> void:
		draw_circle(Vector2.ZERO, 95.0, Color(1.0, 0.88, 0.55, 0.22))
		draw_circle(Vector2.ZERO, 62.0, Color(1.0, 0.92, 0.62, 0.40))
		draw_circle(Vector2.ZERO, 44.0, Color(1.0, 0.97, 0.80, 1.0))


class Abr extends Node2D:
	var defs := []
	func _draw() -> void:
		for d in defs:
			var p := Vector2(d[0], d[1])
			var s: float = d[2]
			draw_circle(p, 34.0 * s, Color(1, 1, 1, 0.25))
			draw_circle(p, 26.0 * s, Color(1, 1, 1, 0.95))
			draw_circle(p + Vector2(30.0 * s, 8.0 * s), 19.0 * s, Color(1, 1, 1, 0.95))
			draw_circle(p + Vector2(-30.0 * s, 9.0 * s), 17.0 * s, Color(1, 1, 1, 0.95))
			draw_circle(p + Vector2(8.0 * s, 18.0 * s), 16.0 * s, Color(1, 1, 1, 0.92))


class Kuhha extends Node2D:
	# کوه‌های دوردست با قلهٔ برفی — الگوی تکرارشونده برای پارالاکسِ بی‌پایان
	func _draw() -> void:
		for k in range(4):
			var ox := k * 1700.0
			var pts := PackedVector2Array([
				Vector2(ox - 50.0, 310.0), Vector2(ox + 220.0, 60.0), Vector2(ox + 430.0, 200.0),
				Vector2(ox + 660.0, 0.0), Vector2(ox + 900.0, 190.0), Vector2(ox + 1120.0, 60.0),
				Vector2(ox + 1360.0, 240.0), Vector2(ox + 1620.0, 120.0), Vector2(ox + 1800.0, 310.0)])
			draw_colored_polygon(pts, Color(0.47, 0.42, 0.68, 1.0))
			var barf := PackedVector2Array([
				Vector2(ox + 660.0, 0.0), Vector2(ox + 612.0, 48.0), Vector2(ox + 642.0, 38.0),
				Vector2(ox + 668.0, 52.0), Vector2(ox + 694.0, 40.0), Vector2(ox + 708.0, 48.0)])
			draw_colored_polygon(barf, Color(1, 1, 1, 0.9))


class Tappeha extends Node2D:
	# تپه‌های نزدیک‌تر — دایره‌های سبزِ روی خطِ زمین
	func _draw() -> void:
		var rng := RandomNumberGenerator.new()
		rng.seed = 21
		for k in range(42):
			var x := k * 90.0 + rng.randf_range(-18.0, 18.0)
			var r := rng.randf_range(55.0, 125.0)
			var c := Color(0.36, 0.62, 0.45, 1.0) if k % 2 == 0 else Color(0.33, 0.58, 0.42, 1.0)
			draw_circle(Vector2(x, 10.0), r, c)


class Zamin extends Node2D:
	# زمین: چمن + خاک + بوته و گل‌های کوچک
	var w := 6000.0
	func _draw() -> void:
		draw_rect(Rect2(0, 14, w, 66), Color(0.58, 0.42, 0.29, 1.0))
		draw_rect(Rect2(0, 70, w, 60), Color(0.48, 0.35, 0.24, 1.0))
		draw_rect(Rect2(0, 0, w, 16), Color(0.44, 0.76, 0.42, 1.0))
		draw_rect(Rect2(0, 0, w, 4), Color(0.58, 0.88, 0.50, 1.0))
		var rng := RandomNumberGenerator.new()
		rng.seed = 7
		for i in range(18):
			var bx := rng.randf_range(60.0, w - 60.0)
			draw_circle(Vector2(bx, 2.0), rng.randf_range(13.0, 24.0), Color(0.30, 0.55, 0.36, 1.0))
		var rangha := [Color(1, 0.85, 0.35), Color(1, 0.62, 0.76), Color(1, 1, 1)]
		for i in range(110):
			var x := rng.randf_range(10.0, w - 10.0)
			var c: Color = rangha[i % 3]
			draw_line(Vector2(x, 2.0), Vector2(x, -7.0), Color(0.33, 0.58, 0.30), 2.0)
			draw_circle(Vector2(x, -9.0), 3.2, c)
			draw_circle(Vector2(x, -9.0), 1.3, Color(1.0, 0.75, 0.25))


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	aks_mode = args.has("--aks")
	_build_background()
	_build_ground()
	_build_player()
	_build_hud()


func _build_background() -> void:
	var grad := Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
	grad.colors = PackedColorArray([Color(0.36, 0.62, 0.88), Color(0.86, 0.78, 0.72), Color(0.98, 0.85, 0.62)])
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill_from = Vector2(0, 0)
	gt.fill_to = Vector2(0, 1)
	gt.width = 64
	gt.height = 256
	var sky := TextureRect.new()
	sky.texture = gt
	sky.position = Vector2(-500, -400)
	sky.size = Vector2(9000, 1600)
	sky.z_index = -50
	add_child(sky)
	# ابرِ دور (پشتِ کوه‌ها) و ابرِ نزدیک (جلو)
	var abr_dor := Abr.new()
	abr_dor.z_index = -48
	for k in range(19):
		abr_dor.defs.append([80.0 + k * 340.0, 70.0 + (k % 4) * 62.0, 0.8 + (k % 3) * 0.22])
	add_child(abr_dor)
	bg_kuh = Kuhha.new()
	bg_kuh.position = Vector2(0, ZAMIN_Y - 310.0)
	bg_kuh.z_index = -45
	add_child(bg_kuh)
	bg_tappe = Tappeha.new()
	bg_tappe.position = Vector2(0, ZAMIN_Y)
	bg_tappe.z_index = -40
	add_child(bg_tappe)
	var abr_nazdik := Abr.new()
	abr_nazdik.z_index = -38
	for k in range(12):
		abr_nazdik.defs.append([200.0 + k * 560.0, 150.0 + (k % 3) * 75.0, 1.1 + (k % 2) * 0.3])
	add_child(abr_nazdik)


func _build_ground() -> void:
	var zamin := Zamin.new()
	zamin.w = JAHAN_W
	zamin.position = Vector2(0, ZAMIN_Y)
	add_child(zamin)
	var badane := StaticBody2D.new()
	var shakl := CollisionShape2D.new()
	var mostatil := RectangleShape2D.new()
	mostatil.size = Vector2(JAHAN_W + 400.0, 140.0)
	shakl.shape = mostatil
	badane.position = Vector2(JAHAN_W / 2.0, ZAMIN_Y + 70.0)
	badane.add_child(shakl)
	add_child(badane)


func _build_player() -> void:
	# سایه — جدا از کاراکتر تا هنگامِ پرش روی زمین بماند
	var soye := Sprite2D.new()
	soye.name = "Soye"
	soye.texture = load("res://assets/helia/soye.png")
	soye.position = Vector2(220.0, ZAMIN_Y - 3.0)
	soye.z_index = -5
	add_child(soye)
	player = CharacterBody2D.new()
	player.set_script(HeliaScript)
	player.position = Vector2(220.0, ZAMIN_Y)
	add_child(player)
	player.amade()
	player.soye = soye
	player.zamin_y = ZAMIN_Y
	cam = Camera2D.new()
	player.add_child(cam)
	cam.limit_left = 0
	cam.limit_right = int(JAHAN_W)
	cam.limit_top = -300
	cam.limit_bottom = 820
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 5.0
	cam.offset = Vector2(0, -130)
	cam.make_current()


func _build_hud() -> void:
	var hud := CanvasLayer.new()
	hud.layer = 10
	add_child(hud)
	var khorshid := Khorshid.new()
	khorshid.position = Vector2(1140, 110)
	hud.add_child(khorshid)
	var fnt: Font = load("res://assets/fonts/Vazirmatn-Bold.ttf")
	var onvan := Label.new()
	onvan.text = "هلیا — ورقِ حرکت"
	onvan.add_theme_font_override("font", fnt)
	onvan.add_theme_font_size_override("font_size", 36)
	onvan.add_theme_color_override("font_color", Color(1, 0.98, 0.93))
	onvan.add_theme_color_override("font_shadow_color", Color(0.25, 0.18, 0.30, 0.65))
	onvan.add_theme_constant_override("shadow_offset_x", 2)
	onvan.add_theme_constant_override("shadow_offset_y", 3)
	onvan.position = Vector2(26, 20)
	hud.add_child(onvan)
	var zir := Label.new()
	zir.text = "عکسِ AI ← ورقِ فریم ← انیمیشنِ بازی"
	zir.add_theme_font_override("font", fnt)
	zir.add_theme_font_size_override("font_size", 21)
	zir.add_theme_color_override("font_color", Color(1, 0.97, 0.90, 0.85))
	zir.add_theme_color_override("font_shadow_color", Color(0.25, 0.18, 0.30, 0.55))
	zir.add_theme_constant_override("shadow_offset_y", 2)
	zir.position = Vector2(28, 66)
	hud.add_child(zir)


func _process(delta: float) -> void:
	t += delta
	if player != null:
		bg_kuh.position.x = -player.global_position.x * 0.22
		bg_tappe.position.x = -player.global_position.x * 0.45
	if aks_mode and not aks_done and t > 1.4:
		aks_done = true
		var img := get_viewport().get_texture().get_image()
		img.save_png("/tmp/aks_helia2d.png")
		get_tree().quit()
	if not aks_mode and t > 15.0:
		get_tree().quit()
