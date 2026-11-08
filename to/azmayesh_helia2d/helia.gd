# هلیا — کاراکترِ ساخته‌شده از ورقِ حرکتِ AI (عکسِ زیبا ← ورقِ فریم ← انیمیشنِ بازی)
# سه حرکت: ist (ایستادن) / dovid (دویدن) / parsh (پرش)
# ورق‌ها و فایلِ helia_frames.tres را ابزارِ scripts/sakht_varagh_helia.py می‌سازد
extends CharacterBody2D

const SPEED := 300.0
const JUMP_V := -680.0
const GRAV := 1500.0

var jadval_parsh: Array = [1.6, 3.5, 5.6, 7.7, 9.8, 11.9]   # زمان‌های پرش در فیلمِ نمایشی
var zaman := 0.0
var parsh_zade := {}
var anim: AnimatedSprite2D
var soye: Sprite2D          # سایه — از بیرون (main.gd) داده می‌شود
var zamin_y := 660.0


func amade() -> void:
	anim = AnimatedSprite2D.new()
	anim.name = "Harekat"
	anim.scale = Vector2(0.82, 0.82)
	anim.position = Vector2(0, -100)   # کفِ پا روی مبدأِ نود (خطِ زمین)
	add_child(anim)
	# تبدیلِ «ورق ← انیمیشن»: اول فایلِ tresِ تولیدشده، اگر نبود ساختِ دستی از ورق‌ها
	var sf := load("res://assets/helia/helia_frames.tres") as SpriteFrames
	if sf == null:
		sf = SpriteFrames.new()
		_az_varagh(sf, "ist", "res://assets/helia/helia_ist.png", 8, 7.0, true)
		_az_varagh(sf, "dovid", "res://assets/helia/helia_dovid.png", 8, 14.0, true)
		_az_varagh(sf, "parsh", "res://assets/helia/helia_parsh.png", 6, 10.0, false)
	anim.sprite_frames = sf
	anim.play("dovid")
	var shakl := CollisionShape2D.new()
	var kapsul := CapsuleShape2D.new()
	kapsul.radius = 20.0
	kapsul.height = 112.0
	shakl.shape = kapsul
	shakl.position = Vector2(0, -58)
	add_child(shakl)


func _az_varagh(sf: SpriteFrames, esm: String, masir: String, tedad: int, sorat: float, halghe: bool) -> void:
	# برشِ ورقِ افقی به فریم‌های ۲۵۶×۲۵۶
	sf.add_animation(esm)
	sf.set_animation_speed(esm, sorat)
	sf.set_animation_loop(esm, halghe)
	var varagh: Texture2D = load(masir)
	for i in range(tedad):
		var at := AtlasTexture.new()
		at.atlas = varagh
		at.region = Rect2(i * 256.0, 0.0, 256.0, 256.0)
		sf.add_frame(esm, at)


func _physics_process(delta: float) -> void:
	zaman += delta
	velocity.x = SPEED   # دویِ خودکار به راست برای فیلمِ نمایشی
	for tp in jadval_parsh:
		if not parsh_zade.has(tp) and zaman >= tp and is_on_floor():
			parsh_zade[tp] = true
			velocity.y = JUMP_V
			anim.play("parsh")
	velocity.y += GRAV * delta
	move_and_slide()
	if is_on_floor() and anim.animation != "dovid":
		anim.play("dovid")
	# سایه روی زمین می‌ماند و با بلندیِ پرش کوچک و کم‌رنگ می‌شود
	if soye != null:
		soye.global_position.x = global_position.x
		soye.global_position.y = zamin_y - 3.0
		var bolandi := clampf(1.0 - (zamin_y - 3.0 - global_position.y) / 400.0, 0.35, 1.0)
		soye.scale = Vector2(1.4, 0.5) * bolandi
		soye.modulate.a = 0.5 * bolandi
