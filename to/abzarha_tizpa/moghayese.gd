extends Node3D
# مقایسه: ماشینِ کدنویسی‌شده (چپ) در برابر مدلِ فعلیِ تیزپا (راست)
# خروجی: ema/moghayese_mashin.png — سپس خروج

func _ready() -> void:
        # نور و محیط
        var nur := DirectionalLight3D.new()
        nur.rotation_degrees = Vector3(-50, 35, 0)
        nur.light_energy = 1.2
        add_child(nur)
        var mahit := Environment.new()
        mahit.background_mode = Environment.BG_COLOR
        mahit.background_color = Color(0.35, 0.38, 0.45)
        mahit.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
        mahit.ambient_light_color = Color(0.7, 0.7, 0.75)
        mahit.ambient_light_energy = 0.5
        var jahan := WorldEnvironment.new()
        jahan.environment = mahit
        add_child(jahan)
        # زمین
        var zamin := MeshInstance3D.new()
        var pel := PlaneMesh.new()
        pel.size = Vector2(40, 24)
        zamin.mesh = pel
        var zm := StandardMaterial3D.new()
        zm.albedo_color = Color(0.5, 0.5, 0.52)
        zamin.material_override = zm
        add_child(zamin)
        # چپ: ماشینِ کدِ کاربر
        var kart := Node3D.new()
        kart.set_script(load("res://scripts/moghayese_car.gd"))
        kart.position = Vector3(-2.7, 0, 0)
        add_child(kart)
        # راست: مدلِ فعلیِ تیزپا
        var sahne := load("res://assets/models/tizpa.glb") as PackedScene
        var mashin: Node3D = sahne.instantiate()
        mashin.position = Vector3(2.7, 0, 0)
        add_child(mashin)
        # دوربین
        var cam := Camera3D.new()
        cam.position = Vector3(0, 2.1, 7.4)
        cam.rotation_degrees = Vector3(-13, 0, 0)
        add_child(cam)
        cam.current = true
        # صبر، عکس، خروج
        await get_tree().create_timer(1.5).timeout
        var aks := get_viewport().get_texture().get_image()
        aks.save_png("/home/z/my-project/ema/moghayese_mashin.png")
        print("MOGHAYESE_OK")
        get_tree().quit()
