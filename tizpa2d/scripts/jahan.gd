# ═══════════════════════════════════════════════════════════════
#  جهان — نقاشی موانع و سکه‌ها روی جاده
#  مخروط، چاله، گهی، شیب پرش — سکه‌های چرخان طلایی
# ═══════════════════════════════════════════════════════════════
extends Node2D

func _process(_dt: float) -> void:
        queue_redraw()

func _draw() -> void:
        var pedar := get_parent()
        var sekant: float = pedar.sekant
        for m in pedar.mane_ha:
                var x: float = float(m["wx"]) - sekant
                if x < -240.0 or x > 1520.0:
                        continue
                match String(m["noe"]):
                        "cone":
                                draw_rect(Rect2(x - 30.0, 684, 60, 8), Color("8a4b1f"))
                                draw_colored_polygon(PackedVector2Array([Vector2(x, 640), Vector2(x - 22, 686), Vector2(x + 22, 686)]), Color("ff7b3a"))
                                draw_rect(Rect2(x - 15.0, 656, 30, 9), Color(1, 1, 1, 0.85))
                        "chaleh":
                                draw_set_transform(Vector2(x, 690), 0.0, Vector2(1.7, 0.55))
                                draw_circle(Vector2.ZERO, 27.0, Color(0, 0, 0, 0.55))
                                draw_circle(Vector2.ZERO, 20.0, Color(0, 0, 0, 0.75))
                                draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
                        "gahi":
                                draw_rect(Rect2(x - 78.0, 666, 156, 18), Color("3a3f45"))
                                for i in 4:
                                        draw_rect(Rect2(x - 70.0 + float(i) * 38.0, 666, 22, 18), Color("e9b44c"))
                        "shib":
                                var noghte_shib := PackedVector2Array([Vector2(x - 96.0, 690), Vector2(x + 84.0, 690), Vector2(x + 84.0, 622), Vector2(x - 96.0, 690)])
                                draw_colored_polygon(noghte_shib, Color("caa53d"))
                                draw_polyline(noghte_shib, Color("5a4615"), 3.0)
                                for i in 3:
                                        draw_line(Vector2(x - 60.0 + float(i) * 42.0, 690), Vector2(x - 18.0 + float(i) * 42.0, 678.0 - float(i) * 5.0), Color(0, 0, 0, 0.5), 5.0)
        for s in pedar.sekke_ha:
                if bool(s["gerefte"]):
                        continue
                var x: float = float(s["wx"]) - sekant
                if x < -60.0 or x > 1340.0:
                        continue
                # چرخش سکه — پهنایش سینوسی می‌شود، حس چرخش سه‌بعدی
                var charkh := maxf(absf(sin(pedar.zaman * 6.5 + float(s["wx"]) * 0.02)), 0.16)
                draw_set_transform(Vector2(x, float(s["y"])), 0.0, Vector2(charkh, 1.0))
                draw_circle(Vector2.ZERO, 17.0, Color("c9972e"))
                draw_circle(Vector2.ZERO, 12.5, Color("ffd94a"))
                draw_circle(Vector2(-4.0, -5.0), 3.0, Color(1, 1, 1, 0.75))
                draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
