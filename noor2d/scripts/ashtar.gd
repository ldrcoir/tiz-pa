extends Object
## ابزارهای مشترک «سه‌گانهٔ نور»: هالهٔ نور، رقم فارسی، اسکرین‌شات، فونت، گرادیان

const DIR_SHAT := "/home/z/my-project/download/screenshots_modern_2d"


static func halo(rang: Color, shoa: float, pakhshe := 1.0) -> Sprite2D:
        ## هالهٔ نورانی با مخلوط افزودنی — درخشش ارزان و همیشه‌کار
        var g := Gradient.new()
        g.offsets = PackedFloat32Array([0.0, 0.35, 1.0])
        g.colors = PackedColorArray([Color(rang, rang.a), Color(rang, rang.a * 0.4), Color(rang, 0.0)])
        var t := GradientTexture2D.new()
        t.gradient = g
        t.fill = GradientTexture2D.FILL_RADIAL
        t.width = 256
        t.height = 256
        t.fill_from = Vector2(0.5, 0.5)
        t.fill_to = Vector2(1.0, 0.5)
        var s := Sprite2D.new()
        s.texture = t
        var m := CanvasItemMaterial.new()
        m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
        s.material = m
        s.scale = Vector2.ONE * (shoa * 2.0 * pakhshe / 256.0)
        return s


static func fa(adad) -> String:
        ## تبدیل رقم لاتین به رقم فارسی
        var kh := ""
        for c in str(adad):
                if c >= "0" and c <= "9":
                        kh += String.chr(0x06F0 + int(c))
                else:
                        kh += c
        return kh


static func fon(masir: String) -> FontFile:
        var f := FontFile.new()
        f.load_dynamic_font(masir)
        return f


static func shat(vp: Viewport, nom: String) -> void:
        DirAccess.make_dir_recursive_absolute(DIR_SHAT)
        var img := vp.get_texture().get_image()
        img.save_png(DIR_SHAT.path_join(nom))
        print("SHAT: ", nom)


static func aks_faal() -> bool:
        return "--aks" in OS.get_cmdline_user_args()


static func aks_ravat(node: Node, t0: int, plan: Array, i: int) -> int:
        ## پیشبرد برنامهٔ اسکرین‌شات؛ در پایان خودش بازی را می‌بندد
        var m := Time.get_ticks_msec() - t0
        if i < plan.size():
                if m >= int(plan[i][0]):
                        shat(node.get_viewport(), plan[i][1])
                        return i + 1
                return i
        if m >= int(plan[i - 1][0]) + 1500:
                node.get_tree().quit()
        return i


static func bargo(rangha: Array, amudi := true) -> GradientTexture2D:
        ## گرادیان خطی برای آسمان و کارت‌ها
        var g := Gradient.new()
        var offs := PackedFloat32Array()
        var cols := PackedColorArray()
        for i in rangha.size():
                offs.append(float(i) / float(maxi(1, rangha.size() - 1)))
                cols.append(rangha[i])
        g.offsets = offs
        g.colors = cols
        var t := GradientTexture2D.new()
        t.gradient = g
        t.fill = GradientTexture2D.FILL_LINEAR
        t.fill_from = Vector2.ZERO
        t.fill_to = Vector2(0.0, 1.0) if amudi else Vector2(1.0, 0.0)
        return t


static func enfejar(parent: Node, pos: Vector2, rang: Color, tedad := 26, sorat := 240.0) -> void:
        ## انفجار ذرات یک‌باره
        var p := CPUParticles2D.new()
        p.position = pos
        p.amount = tedad
        p.lifetime = 0.7
        p.one_shot = true
        p.explosiveness = 1.0
        p.direction = Vector2.UP
        p.spread = 180.0
        p.gravity = Vector2.ZERO
        p.initial_velocity_min = sorat * 0.4
        p.initial_velocity_max = sorat
        p.scale_amount_min = 2.0
        p.scale_amount_max = 5.0
        p.color = rang
        p.emitting = true
        parent.add_child(p)
        parent.get_tree().create_timer(1.4).timeout.connect(p.queue_free)
