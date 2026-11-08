# هلیا (کاراکتر زنِ پک Kenney) — انیمیشن واقعیِ فریمی، نه فرمول ریاضی
extends CharacterBody2D

const SPEED := 235.0
const JUMP_V := -560.0
const GRAV := 1300.0

var anim: AnimatedSprite2D
var target_x := 0.0
var want_jump := false
var control := true

func setup(poses: Dictionary) -> void:
        anim = AnimatedSprite2D.new()
        var sf := SpriteFrames.new()
        sf.add_animation("idle")
        sf.set_animation_speed("idle", 2.0)
        sf.add_frame("idle", poses["idle"])
        sf.add_animation("run")
        sf.set_animation_speed("run", 9.0)
        sf.add_frame("run", poses["walk1"])
        sf.add_frame("run", poses["walk2"])
        sf.add_animation("jump")
        sf.add_frame("jump", poses["jump"])
        sf.add_animation("fall")
        sf.add_frame("fall", poses["fall"])
        sf.add_animation("cheer")
        sf.set_animation_speed("cheer", 5.0)
        sf.add_frame("cheer", poses["cheer1"])
        sf.add_frame("cheer", poses["cheer2"])
        anim.sprite_frames = sf
        anim.scale = Vector2(0.9, 0.9)
        add_child(anim)
        anim.play("idle")
        var shape := CollisionShape2D.new()
        var cap := CapsuleShape2D.new()
        cap.radius = 16.0
        cap.height = 86.0
        shape.shape = cap
        add_child(shape)
        add_to_group("player")

func _physics_process(delta: float) -> void:
        if control:
                var dx := target_x - global_position.x
                if dx > 8.0:
                        velocity.x = SPEED
                elif dx < -8.0:
                        velocity.x = -SPEED
                else:
                        velocity.x = move_toward(velocity.x, 0.0, 1600.0 * delta)
        else:
                velocity.x = move_toward(velocity.x, 0.0, 1400.0 * delta)
        if want_jump:
                want_jump = false
                if is_on_floor():
                        velocity.y = JUMP_V
        velocity.y += GRAV * delta
        move_and_slide()
        if is_on_floor():
                if absf(velocity.x) > 12.0:
                        anim.play("run")
                elif anim.animation != "idle" and anim.animation != "cheer":
                        anim.play("idle")
        else:
                if velocity.y < 0.0:
                        anim.play("jump")
                else:
                        anim.play("fall")
        if absf(velocity.x) > 12.0:
                anim.flip_h = velocity.x < 0.0  # پک Kenney به راست نگاه می‌کند

func celebrate() -> void:
        control = false
        anim.play("cheer")
