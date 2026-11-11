# صحنهٔ نمایشِ اژدها — دشتِ آفتابی، پارالاکس، سایه و HUDِ نامِ کاستوم
# فیلمِ نمایشی ~۱۶ثانیه‌ای: دویدن + تعویضِ ۸ کاستوم + پُفِ آتش + پرشِ جشن
# اجرا:  godot --path to/ezhdeha --write-movie /tmp/ezh.avi --fixed-fps 30
#        godot --path to/ezhdeha -- --aks   (فقط عکس برای بررسی)
extends Node2D

const ZAMIN_Y := 660.0
const JAHAN_W := 6000.0

var player: CharacterBody2D
var cam: Camera2D
var t := 0.0
var aks_mode := false
var aks_done := false
var neveshta: Label
var esm_kastum: Label


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
	func _draw() -> void:
		for k in range(4):
			var ox := k * 1700.0
			var pts := PackedVector2Array([
				Vector2(ox - 50.0, 310.0), Vector2(ox + 220.0, 60.0), Vector2(ox + 430.0, 200.0),
				Vector2(ox + 660.0, 0.0), Vector2(ox + 900.0, 190.0), Vector2(ox + 1120.0, 60.0),
				Vector2(ox + 1360.0, 240.0), Vector2(ox + 1620.0, 120.0), Vector2(ox + 1800.0, 310.0)])
			draw_colored_polygon(pts, Color(0.52, 0.62, 0.55, 1.0))
			var barf := PackedVector2Array([
				Vector2(ox + 660.0, 0.0), Vector2(ox + 612.0, 48.0), Vector2(ox + 642.0, 38.0),
				Vector2(ox + 668.0, 52.0), Vector2(ox + 694.0, 40.0), Vector2(ox + 708.0, 48.0)])
			draw_colored_polygon(barf, Color(1, 1, 1, 0.9))


class Tappeha extends Node2D:
	func _draw() -> void:
		var rng := RandomNumberGenerator.new()
		rng.seed = 21
		for k in range(42):
			var x := k * 90.0 + rng.randf_range(-18.0, 18.0)
			var r := rng.randf_range(55.0, 125.0)
			var c := Color(0.42, 0.70, 0.48, 1.0) if k % 2 == 0 else Color(0.38, 0.66, 0.45, 1.0)
			draw_circle(Vector2(x, 10.0), r, c)


class Zamin extends Node2D:
	var w := 6000.0
	func _draw() -> void:
		draw_rect(Rect2(0, 14, w, 66), Color(0.58, 0.42, 0.29, 1.0))
		draw_rect(Rect2(0, 70, w, 60), Color(0.48, 0.35, 0.24, 1.0))
		draw_rect(Rect2(0, 0, w, 16), Color(0.46, 0.80, 0.44, 1.0))
		draw_rect(Rect2(0, 0, w, 4), Color(0.62, 0.90, 0.52, 1.0))
		var rng := RandomNumberGenerator.new()
		rng.seed = 7
		for i in range(18):
			var bx := rng.randf_range(60.0, w - 60.0)
			draw_circle(Vector2(bx, 2.0), rng.randf_range(13.0, 24.0), Color(0.32, 0.58, 0.38, 1.0))
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
	grad.colors = PackedColorArray([Color(0.42, 0.68, 0.92), Color(0.80, 0.88, 0.86), Color(0.96, 0.92, 0.72)])
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
	var khorshid := Khorshid.new()
	khorshid.position = Vector2(1080, 140)
	khorshid.z_index = -49
	add_child(khorshid)
	var abr_dor := Abr.new()
	abr_dor.z_index = -48
	for k in range(19):
		abr_dor.defs.append([80.0 + k * 340.0, 70.0 + (k % 4) * 62.0, 0.8 + (k % 3) * 0.22])
	add_child(abr_dor)
	var kuh := Kuhha.new()
	kuh.position = Vector2(0, ZAMIN_Y - 310.0)
	kuh.z_index = -45
	add_child(kuh)
	var tappe := Tappeha.new()
	tappe.position = Vector2(0, ZAMIN_Y)
	tappe.z_index = -40
	add_child(tappe)
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
	var soye := Sprite2D.new()
	soye.name = "Soye"
	soye.texture = load("res://assets/honar/soye.png")
	soye.position = Vector2(220.0, ZAMIN_Y - 3.0)
	soye.z_index = -5
	add_child(soye)

	player = CharacterBody2D.new()
	player.set_script(load("res://ezhdeha.gd"))
	player.position = Vector2(220.0, ZAMIN_Y)
	add_child(player)
	player.soye = soye
	player.zamin_y = ZAMIN_Y
	player.amade()

	cam = Camera2D.new()
	cam.position = Vector2(220.0 + 300.0, ZAMIN_Y - 210.0)
	add_child(cam)
	cam.make_current()


func _build_hud() -> void:
	var kanvas := CanvasLayer.new()
	add_child(kanvas)
	neveshta = Label.new()
	neveshta.text = "🐉 اژدهای کوچولو و کاستوم‌هایش"
	neveshta.add_theme_font_override("font", load("res://assets/fonts/Vazirmatn-Bold.ttf"))
	neveshta.add_theme_font_size_override("font_size", 44)
	neveshta.add_theme_color_override("font_color", Color(1.0, 0.62, 0.24))
	neveshta.add_theme_color_override("font_outline_color", Color(0.12, 0.08, 0.05))
	neveshta.add_theme_constant_override("outline_size", 10)
	neveshta.position = Vector2(30, 18)
	kanvas.add_child(neveshta)
	esm_kastum = Label.new()
	esm_kastum.text = "کاستوم: عادی"
	esm_kastum.add_theme_font_override("font", load("res://assets/fonts/Vazirmatn-Bold.ttf"))
	esm_kastum.add_theme_font_size_override("font_size", 26)
	esm_kastum.add_theme_color_override("font_color", Color(1, 1, 1))
	esm_kastum.add_theme_color_override("font_outline_color", Color(0.12, 0.08, 0.05))
	esm_kastum.add_theme_constant_override("outline_size", 7)
	esm_kastum.position = Vector2(30, 78)
	kanvas.add_child(esm_kastum)


var esm_fa := ["عادی", "جادوگر", "پلیس", "فضانورد", "دزد دریایی", "شاه", "زمستانی", "مسابقه‌ای", "نینجا"]
var kastum_ghabli := 0


func _process(delta: float) -> void:
	t += delta
	# دوربین دنبالِ اژدها
	cam.position = Vector2(player.position.x + 300.0, ZAMIN_Y - 210.0)
	# نامِ کاستوم در HUD تازه شود
	if player.kastum != kastum_ghabli:
		kastum_ghabli = player.kastum
		esm_kastum.text = "کاستوم: " + esm_fa[player.kastum]
		esm_kastum.modulate = Color(1.0, 0.85, 0.4)
		var tv := create_tween()
		tv.tween_property(esm_kastum, "modulate", Color(1, 1, 1), 0.5)
	if t > 0.9:
		neveshta.visible = t < 4.2 or fmod(t, 1.2) < 0.7   # چشمکِ ملایم بعد از ۴ ثانیه
	# فیلمِ ۱۶.۶ ثانیه‌ای — پایانِ خودکار برای Movie Maker
	if not aks_mode and t > 16.6:
		get_tree().quit()
	if aks_mode and t > 1.6 and not aks_done:
		aks_done = true
		var aks := get_viewport().get_texture().get_image()
		aks.save_png("res://aks_sahne.png")
		get_tree().quit()
