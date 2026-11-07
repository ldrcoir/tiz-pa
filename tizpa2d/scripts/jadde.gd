# ═══════════════════════════════════════════════════════════════
#  جاده — آسفالت، خط چین وسط، جوب‌ها؛ همه با draw، بدون حتی یک عکس
# ═══════════════════════════════════════════════════════════════
extends Node2D

func _process(_dt: float) -> void:
        queue_redraw()

func _draw() -> void:
        var pedar := get_parent()
        var sekant: float = pedar.sekant
        # آسفالت با دو ته‌رنگ — تیره بالا، روشن‌تر پایین
        draw_rect(Rect2(0, 556, 1280, 164), Color("2e3238"))
        draw_rect(Rect2(0, 556, 1280, 26), Color("343940"))
        draw_rect(Rect2(0, 714, 1280, 6), Color(0, 0, 0, 0.3))
        # خط زرد جدول + شکستن نوری روی آن
        draw_rect(Rect2(0, 550, 1280, 7), Color("d8b93a"))
        draw_rect(Rect2(0, 550, 1280, 2), Color("f2d97a"))
        # خط چین وسط خیابان — با سرعت جهانی می‌چرخد
        var paye := fposmod(sekant, 240.0)
        for i in 7:
                draw_rect(Rect2(i * 240.0 - paye - 120.0, 614, 112, 9), Color(1, 1, 1, 0.42))
        # جوب‌های آسفالت هر ۹۷۰ پیکسل
        var paye2 := fposmod(sekant, 970.0)
        for i in 3:
                draw_circle(Vector2(i * 970.0 - paye2 + 420.0, 678), 19.0, Color(0, 0, 0, 0.26))
                draw_circle(Vector2(i * 970.0 - paye2 + 420.0, 678), 13.0, Color(0, 0, 0, 0.34))
