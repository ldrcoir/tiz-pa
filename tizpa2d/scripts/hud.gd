# ═══════════════════════════════════════════════════════════════
#  HUD — قلب‌ها، سکه، نوار نیترو، فلش قرمز؛ همه با draw
# ═══════════════════════════════════════════════════════════════
extends Node2D

func _process(_dt: float) -> void:
        queue_redraw()

func _draw() -> void:
        var pedar := get_tree().current_scene
        if pedar == null:
                return
        # فلش قرمز هنگام تصادف
        if pedar.flash > 0.0:
                draw_rect(Rect2(0, 0, 1280, 720), Color(1, 0.25, 0.3, 0.30 * pedar.flash))
        # قلب‌ها — دوتا دایره + یک مثلث
        for i in 3:
                var ja := Vector2(44 + i * 48, 44)
                var rang := Color("ff5470") if i < int(pedar.jan) else Color(1, 1, 1, 0.16)
                draw_circle(ja + Vector2(-8, -5), 10.0, rang)
                draw_circle(ja + Vector2(8, -5), 10.0, rang)
                draw_colored_polygon(PackedVector2Array([Vector2(ja.x - 17, ja.y - 1), Vector2(ja.x + 17, ja.y - 1), Vector2(ja.x, ja.y + 16)]), rang)
        # سکه‌ی کنار شمارنده
        draw_circle(Vector2(46, 96), 13.0, Color("c9972e"))
        draw_circle(Vector2(46, 96), 9.0, Color("ffd94a"))
        draw_circle(Vector2(43, 93), 2.5, Color(1, 1, 1, 0.8))
        # نوار سوخت نیترو — وسط پایین، دور از دکمه‌های لمسی
        draw_rect(Rect2(430, 668, 420, 20), Color(1, 1, 1, 0.12))
        draw_rect(Rect2(430, 668, 420, 20), Color(1, 1, 1, 0.4), false, 2.0)
        var purnesh := clampf(pedar.nitro_pur, 0.0, 1.0)
        var rang_nitro := Color("ffd94a").lerp(Color("ff7b3a"), purnesh)
        draw_rect(Rect2(432, 670, 416.0 * purnesh, 16), rang_nitro)
        if pedar.nitro_mande > 0.0:
                draw_rect(Rect2(430, 694, 420.0 * clampf(pedar.nitro_mande / 2.6, 0.0, 1.0), 7), Color("ff5470"))
