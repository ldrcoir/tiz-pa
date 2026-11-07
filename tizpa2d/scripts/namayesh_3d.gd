# ═══════════════════════════════════════════════════════════════
#  نمایش‌گر سه‌بعدی آزمایشگاه — هر GLB را می‌گیرد، هم‌اندازه‌اش می‌کند
#  و از دو زاویه عکس می‌گیرد؛ برای مقایسه‌ی «مدل بلندری» با «خروجی AI»
#  دستور: godot scenes/namayesh_3d.tscn -- --glb=/masir/fail.glb --nm=esm
# ═══════════════════════════════════════════════════════════════
extends Node3D

const MASIR_AKS := "/home/z/my-project/download/screenshots_2d"

var argha: Array = []
var aks_mode := false
var t_test := 0.0
var aks_gerefte := {}
var esm_khoruji := "model"
var zaman := 0.0
var dorbin: Camera3D

func _ready() -> void:
        argha = OS.get_cmdline_user_args()
        aks_mode = argha.has("--aks")
        var masir_glb := ""
        for a in argha:
                if a.begins_with("--glb="):
                        masir_glb = a.split("=", true, 1)[1]
                if a.begins_with("--nm="):
                        esm_khoruji = a.split("=", true, 1)[1]
        _mohit_besaz()
        if masir_glb == "" or not ResourceLoader.exists(masir_glb):
                print("[tizpa2d][3d] FAIL — GLB پیدا نشد: ", masir_glb)
                get_tree().quit(1)
                return
        var paket := load(masir_glb) as PackedScene
        if paket == null:
                print("[tizpa2d][3d] FAIL — لود GLB نشد")
                get_tree().quit(1)
                return
        var ghaleb := paket.instantiate()
        add_child(ghaleb)
        _hamvar_saz(ghaleb)
        dorbin = Camera3D.new()
        add_child(dorbin)
        print("[tizpa2d][3d] LOADED ", masir_glb, " nm=", esm_khoruji)

# مدل را هم‌اندازه می‌کند: بلندترین بعدش ۳ متر، پایش روی زمین، وسط صحنه
# نکته: لامبادا در گودوت متغیر را کپی می‌کند — پس با دیکشنری (رفرنسی) کار می‌کنیم
func _hamvar_saz(gereh: Node3D) -> void:
        var juzi := {"mohit": AABB(Vector3.ZERO, Vector3.ONE), "aval": true}
        var kar := func(n: Node) -> void:
                if n is MeshInstance3D and n.mesh != null:
                        var a: AABB = n.global_transform * n.mesh.get_aabb()
                        if juzi["aval"]:
                                juzi["mohit"] = a
                                juzi["aval"] = false
                        else:
                                juzi["mohit"] = (juzi["mohit"] as AABB).merge(a)
        _dor_zel(gereh, kar)
        var mohit: AABB = juzi["mohit"]
        var andaze := mohit.size
        var bozorgtar := maxf(andaze.x, maxf(andaze.y, andaze.z))
        if bozorgtar <= 0.0:
                bozorgtar = 1.0
        var v := 3.0 / bozorgtar
        var markaz := mohit.get_center()
        gereh.scale = Vector3(v, v, v)
        gereh.position = Vector3(-markaz.x * v, -mohit.position.y * v, -markaz.z * v)
        print("[tizpa2d][3d] AABB=", mohit.size, " maghsas=", v)

func _dor_zel(gereh: Node, kar: Callable) -> void:
        kar.call(gereh)
        for b in gereh.get_children():
                _dor_zel(b, kar)

func _mohit_besaz() -> void:
        var aseman := ProceduralSkyMaterial.new()
        aseman.sky_top_color = Color("1a2b4a")
        aseman.sky_horizon_color = Color("cfe3ff")
        aseman.ground_bottom_color = Color("3c4650")
        aseman.ground_horizon_color = Color("cfe3ff")
        var mohit := Environment.new()
        mohit.background_mode = Environment.BG_SKY
        mohit.sky = Sky.new()
        mohit.sky.sky_material = aseman
        mohit.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
        var donya := WorldEnvironment.new()
        donya.environment = mohit
        add_child(donya)
        var khorshid := DirectionalLight3D.new()
        khorshid.rotation_degrees = Vector3(-48, 34, 0)
        khorshid.light_energy = 1.25
        add_child(khorshid)
        var por := OmniLight3D.new()
        por.position = Vector3(-4, 3, 4)
        por.light_energy = 0.8
        por.omni_range = 14.0
        por.light_color = Color("bcd7ff")
        add_child(por)
        var zamin := MeshInstance3D.new()
        var me := PlaneMesh.new()
        me.size = Vector2(16, 16)
        zamin.mesh = me
        var mt := StandardMaterial3D.new()
        mt.albedo_color = Color("6e7681")
        mt.roughness = 0.85
        zamin.material_override = mt
        add_child(zamin)

func _process(dt: float) -> void:
        zaman += dt
        if dorbin == null:
                return
        var zavie := zaman * 0.85 + 0.6
        dorbin.position = Vector3(sin(zavie) * 5.4, 2.3, cos(zavie) * 5.4)
        dorbin.look_at(Vector3(0, 1.05, 0), Vector3.UP)
        if aks_mode:
                t_test += dt
                for m in [[1.1, "A"], [2.7, "B"]]:
                        if t_test > float(m[0]) and not aks_gerefte.has(m[1]):
                                aks_gerefte[m[1]] = true
                                var aks := get_viewport().get_texture().get_image()
                                if aks != null:
                                        aks.save_png(MASIR_AKS + "/" + esm_khoruji + "_" + String(m[1]) + ".png")
                                        print("[tizpa2d][3d] SHOT ", esm_khoruji, "_", m[1])
                if t_test > 3.4:
                        print("[tizpa2d][3d] DONE nm=", esm_khoruji)
                        get_tree().quit()
