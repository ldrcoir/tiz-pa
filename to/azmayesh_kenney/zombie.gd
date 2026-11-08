# زامبی دشمن — گشت‌زنی با انیمیشن واقعی
extends Node2D

var anim: AnimatedSprite2D
var x1 := 0.0
var x2 := 0.0
var speed := 45.0
var dir := 1

func setup(poses: Dictionary, from_x: float, to_x: float, start: Vector2) -> void:
        position = start
        x1 = from_x
        x2 = to_x
        anim = AnimatedSprite2D.new()
        var sf := SpriteFrames.new()
        sf.add_animation("walk")
        sf.set_animation_speed("walk", 6.0)
        sf.add_frame("walk", poses["walk1"])
        sf.add_frame("walk", poses["walk2"])
        anim.sprite_frames = sf
        anim.scale = Vector2(0.85, 0.85)
        add_child(anim)
        anim.play("walk")

func _physics_process(delta: float) -> void:
        position.x += dir * speed * delta
        if position.x > x2:
                dir = -1
        elif position.x < x1:
                dir = 1
        anim.flip_h = dir < 0  # پک Kenney به راست نگاه می‌کند
