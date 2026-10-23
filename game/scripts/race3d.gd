extends Node3D

const TEST_MOSABEGE := false

# صحنه‌ها همه روزِ روشن
const MARHALEHA := [
        {
                "id": 1, "name": "خیابان ولیعصر", "desc": "درخت‌های چنار و جریان آرام — گرم‌کردن موتور",
                "laps": 2, "half": 9.0, "skill": 0.80,
                "reward": 120, "time": "day",
                "ctrl": [
                        Vector3(-210, 0, -150), Vector3(0, 0, -205), Vector3(205, 0, -160),
                        Vector3(255, 0, -20), Vector3(190, 0, 130), Vector3(40, 0, 200),
                        Vector3(-150, 0, 180), Vector3(-255, 0, 40),
                ],
                "trees": 1.0, "bazaar": 0.0, "landmark": "milad",
                "sky_top": Color(0.22, 0.52, 0.93), "sky_hz": Color(0.74, 0.85, 0.94),
                "sun": Vector3(-0.5, -0.9, -0.35), "sun_col": Color(1.0, 0.97, 0.88), "sun_e": 1.3,
                "ground": Color(0.52, 0.50, 0.45), "fog": Color(0.80, 0.86, 0.94), "fog_d": 0.0009,
                "bld": [Color(0.72, 0.62, 0.48), Color(0.64, 0.50, 0.40), Color(0.56, 0.56, 0.52), Color(0.76, 0.68, 0.56)],
        },
        {
                "id": 2, "name": "بازار بزرگ تهران", "desc": "کوچه‌های تنگ و پیچ‌های ۹۰ درجه — دریفت دستی بزن!",
                "laps": 2, "half": 5.6, "skill": 0.86,
                "reward": 160, "time": "day",
                "ctrl": [
                        Vector3(-130, 0, -110), Vector3(0, 0, -125), Vector3(125, 0, -110),
                        Vector3(140, 0, -10), Vector3(60, 0, 0), Vector3(60, 0, 95),
                        Vector3(140, 0, 105), Vector3(120, 0, 190),
                        Vector3(0, 0, 200), Vector3(-125, 0, 185),
                        Vector3(-145, 0, 80), Vector3(-70, 0, 60), Vector3(-70, 0, -20), Vector3(-140, 0, -25),
                ],
                "trees": 0.25, "bazaar": 1.0, "landmark": "",
                "sky_top": Color(0.34, 0.58, 0.90), "sky_hz": Color(0.85, 0.86, 0.88),
                "sun": Vector3(-0.35, -0.95, -0.2), "sun_col": Color(1.0, 0.96, 0.86), "sun_e": 1.3,
                "ground": Color(0.55, 0.52, 0.47), "fog": Color(0.85, 0.85, 0.87), "fog_d": 0.0011,
                "bld": [Color(0.70, 0.50, 0.34), Color(0.60, 0.42, 0.30), Color(0.74, 0.60, 0.44), Color(0.52, 0.36, 0.28)],
        },
        {
                "id": 3, "name": "بزرگراه چمران", "desc": "پیچ‌های سرعتی بلند — پدال را زمین بگذار",
                "laps": 3, "half": 10.0, "skill": 0.91,
                "reward": 220, "time": "day",
                "ctrl": [
                        Vector3(-260, 0, -170), Vector3(-60, 0, -230), Vector3(160, 0, -190),
                        Vector3(290, 0, -60), Vector3(240, 0, 110), Vector3(60, 0, 190),
                        Vector3(-140, 0, 230), Vector3(-300, 0, 90),
                ],
                "trees": 0.5, "bazaar": 0.0, "landmark": "milad",
                "sky_top": Color(0.28, 0.52, 0.86), "sky_hz": Color(0.80, 0.87, 0.93),
                "sun": Vector3(0.4, -0.9, -0.4), "sun_col": Color(1.0, 0.98, 0.90), "sun_e": 1.25,
                "ground": Color(0.50, 0.49, 0.46), "fog": Color(0.82, 0.88, 0.95), "fog_d": 0.0008,
                "bld": [Color(0.62, 0.62, 0.66), Color(0.54, 0.56, 0.62), Color(0.72, 0.66, 0.58), Color(0.48, 0.50, 0.54)],
        },
        {
                "id": 4, "name": "تجریش — غروب", "desc": "آفتاب طلایی، پیچ‌های ترکیبی — سبقت در شیب!",
                "laps": 2, "half": 7.6, "skill": 0.95,
                "reward": 260, "time": "golden",
                "ctrl": [
                        Vector3(-170, 0, -140), Vector3(0, 0, -180), Vector3(150, 0, -120),
                        Vector3(195, 0, 0), Vector3(130, 0, 120), Vector3(20, 0, 175),
                        Vector3(-120, 0, 150), Vector3(-200, 0, 30),
                ],
                "trees": 0.85, "bazaar": 0.3, "landmark": "",
                "sky_top": Color(0.36, 0.50, 0.78), "sky_hz": Color(0.98, 0.82, 0.58),
                "sun": Vector3(0.75, -0.55, 0.35), "sun_col": Color(1.0, 0.83, 0.60), "sun_e": 1.35,
                "ground": Color(0.55, 0.50, 0.44), "fog": Color(0.95, 0.80, 0.62), "fog_d": 0.0013,
                "bld": [Color(0.78, 0.58, 0.42), Color(0.68, 0.50, 0.38), Color(0.82, 0.66, 0.50), Color(0.60, 0.46, 0.36)],
        },
        {
                "id": 5, "name": "میدان آزادی", "desc": "دورِ بلوار بنای آزادی — نبرد نهایی با بهترین‌ها",
                "laps": 3, "half": 8.5, "skill": 1.0,
                "reward": 340, "time": "sunset",
                "ctrl": [
                        Vector3(-190, 0, -95), Vector3(-60, 0, -185), Vector3(95, 0, -175),
                        Vector3(200, 0, -70), Vector3(185, 0, 80), Vector3(60, 0, 175),
                        Vector3(-105, 0, 180), Vector3(-205, 0, 65),
                        Vector3(-60, 0, 0), Vector3(60, 0, 0),
                ],
                "trees": 0.35, "bazaar": 0.0, "landmark": "azadi",
                "sky_top": Color(0.45, 0.48, 0.72), "sky_hz": Color(1.0, 0.72, 0.45),
                "sun": Vector3(0.85, -0.45, 0.3), "sun_col": Color(1.0, 0.75, 0.48), "sun_e": 1.45,
                "ground": Color(0.56, 0.50, 0.44), "fog": Color(0.98, 0.76, 0.55), "fog_d": 0.0012,
                "bld": [Color(0.74, 0.58, 0.44), Color(0.62, 0.50, 0.42), Color(0.80, 0.64, 0.48), Color(0.56, 0.46, 0.40)],
        },
]

var tarjome: Dictionary = {}            # مرحله فعال
var ferman_dasti: Array = []              # نقاط کنترل مسیر
var NEMOONEHA: PackedVector3Array         # نمونه‌های مسیر
var MAMASHA: PackedVector3Array         # مماس‌ها (نرمال)
var NORMLHA: PackedVector3Array       # نرمال جانبی (راست)
var TOOL_JAM: PackedFloat32Array        # طول تجمعی
var toole_masir: float = 0.0
var NEMOONE_N := 900                     # تعداد نمونه

var mashin: Node3D                   # ریشه ماشین بازیکن
var lastikha: Array = []
var lastikaye_jelo: Array = []
var shole_mashin: MeshInstance3D
var mate_badane: StandardMaterial3D

var ja := Vector3.ZERO
var semat := 0.0
var v_jelo := 0.0                     # سرعت جلو (m/s)
var v_janebi := 0.0                     # سرعت جانبی (dریفت)
var ferman := 0.0
var sh := 0                      # نمونه‌ی نزدیک مسیر (کش)
var s_hala := 0.0
var dour := 0
var pishraft := 0.0
var zamane_mosabeqe := 0.0

var nitro := 0.5
var nitro_rushan := false
var dar_darift := false
var emtiaze_darift := 0
var zanjire_darift := 0.0
var rah_e_ghalat := 0.0
var larze := 0.0
var zavie_dorbin := 72.0
var ghame_dorbin := 0.0 # خم‌شدن دوربین در پیچ — حس دریفت
var seyest := 0.0
var tamaam_shod := false
var jaye_payan := 1
var halat := "count"              # count / race / finish / panel
var shomarvar := 3.9

var raqibha: Array = []            # {root, s, lat, vf, skill, name, paint, wheels}
var saktha: Array = []            # {x,z,r}
var shabake_sakht := {}              # سلول → ایندکس‌ها
const KHANE := 26.0

# ورودی
var mizane_ferman := 0.0
var paye_gaz := 1.0                 # گاز خودکار (سبک موبایلی NFS)
var paye_termoz := false
var dasti := false
var id_fermane_lamsi := -1
var x0_fermane_lamsi := 0.0
var meghdare_fermane_lamsi := 0.0
var sh_dokmeha := {}                 # نام دکمه → index لمس

var dorbin: Camera3D
var jaye_dorbin := Vector3.ZERO
var negahe_dorbin := Vector3.ZERO
var dorbin_avalie := false
var khat_sorat: ColorRect           # خطوط تندباد لبه‌ی کادر
var javane_khat: ShaderMaterial

# رد لاستیک
var meshe_jigh: ImmediateMesh
var mate_jigh: StandardMaterial3D
var noghate_jigh := [[], []]          # دو چرخ عقب
const HADDE_JIGH := 900

var hud: CanvasLayer
var sanje_hud: Control
var matne_ja: Label
var matne_dour: Label
var matne_zaman: Label
var matne_vasat: Label
var matne_darift: Label
var matne_ghalat: Label
var mostatil_nitro: ColorRect
var sharge_nitro: ColorRect
var dokme_tavaqof: TextureButton

var dood: CPUParticles3D
var t_test := 0.0
var marhale_test := 0
var halate_aks := false
var sh_aks := 0
var otopilot := false
var arg_line: Array = []

@onready var A := Seda

func _ready() -> void:
        arg_line = OS.get_cmdline_user_args()
        halate_aks = arg_line.has("--shots")
        otopilot = halate_aks or arg_line.has("--playtest")
        # راهنمای تست مستقیم هر مرحله از خط فرمان: --start_level=N
        for a in arg_line:
                if a.begins_with("--start_level="):
                        Koli.set_meta("start_level", int(a.split("=")[1]))
        var marhale := int(Koli.get_meta("start_level", 1))
        tarjome = _marhale_ba_id(marhale)
        ferman_dasti = tarjome["ctrl"]
        print("[tizpa][race] level=", tarjome["id"], " name=", tarjome["name"], " laps=", tarjome["laps"])
        _donya_besaz()
        _masir_besaz()
        _manzare_besaz()
        _mashin_bepar()
        _hud_besaz()
        _azm_ertebat()
        print("[tizpa][race] SPAWN OK half=", tarjome["half"], " len=", int(toole_masir))

func _marhale_ba_id(lid: int) -> Dictionary:
        for l in MARHALEHA:
                if int(l["id"]) == lid:
                        return l
        return MARHALEHA[0]

# ═══════════════════════════ دنیا: آسمان/خورشید/زمین ═══════════════════════════
func _donya_besaz() -> void:
        var we := WorldEnvironment.new()
        var poush := Environment.new()
        var asman := Sky.new()
        var mate := ProceduralSkyMaterial.new()
        mate.sky_top_color = tarjome["sky_top"]
        mate.sky_horizon_color = tarjome["sky_hz"]
        mate.ground_bottom_color = tarjome["sky_hz"].darkened(0.25)
        mate.ground_horizon_color = tarjome["sky_hz"]
        mate.sun_angle_max = 18.0 # قرص آفتاب پهن — آسمان خورشیدی مسابقه‌ای
        mate.sun_curve = 0.12
        asman.radiance_size = Sky.RADIANCE_SIZE_128
        asman.sky_material = mate
        poush.background_mode = Environment.BG_SKY
        poush.sky = asman
        poush.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
        poush.ambient_light_energy = 1.12 # سایه‌ی ساختمان‌ها را می‌کشد بالا — جاده سیاه‌قلم نمی‌شود
        poush.tonemap_mode = Environment.TONE_MAPPER_FILMIC
        poush.tonemap_white = 6.0
        # درخشش ظریف — آفتاب و رنگ‌فلزی جان می‌گیرند، نه نئون شبانه
        poush.glow_enabled = true
        poush.glow_intensity = 0.55
        poush.glow_strength = 1.0
        poush.glow_bloom = 0.06
        poush.glow_hdr_threshold = 1.38 # فقط خورشید/شعله بدرخشند — تابلوها نه
        poush.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
        # رنگ‌ها جان بگیرند — بدون این، صحنه شسته و بد رنگ دیده می‌شود
        poush.adjustment_enabled = true
        poush.adjustment_brightness = 1.0
        poush.adjustment_contrast = 1.13
        poush.adjustment_saturation = 1.25
        poush.fog_enabled = true
        poush.fog_light_color = tarjome["fog"]
        poush.fog_density = tarjome["fog_d"]
        poush.fog_sky_affect = 0.0
        we.environment = poush
        add_child(we)

        var khorsid := DirectionalLight3D.new()
        khorsid.rotation = Vector3(0.62, 0.0, 0.0)  # پایین می‌آید؛ جهت با پایین پایین ست می‌شود
        var d: Vector3 = tarjome["sun"]
        khorsid.look_at_from_position(Vector3(-d.x * 80, -d.y * 80, -d.z * 80), Vector3.ZERO, Vector3.UP)
        khorsid.light_color = tarjome["sun_col"]
        khorsid.light_energy = tarjome["sun_e"] * 0.94
        khorsid.shadow_enabled = true
        khorsid.directional_shadow_max_distance = 130.0
        khorsid.shadow_blur = 1.4 # سایه‌ی تیز — سایه‌ی شسته ‌شده حس NFS نمی‌دهد
        khorsid.shadow_opacity = 0.82
        add_child(khorsid)

        var zamin := MeshInstance3D.new()
        var gm := PlaneMesh.new()
        gm.size = Vector2(4200, 4200)
        var gmat := StandardMaterial3D.new()
        gmat.albedo_color = tarjome["ground"].darkened(0.25)
        var zamin_b := _tex_bargozar("zamin")
        if zamin_b != null:
                gmat.albedo_texture = zamin_b
        else:
                gmat.albedo_texture = _bafte_zamin() # لکه‌های خاک و چمن — زمین مرده‌ی یک‌دست نیست
        gmat.uv1_triplanar = true
        gmat.uv1_world_triplanar = true
        gmat.uv1_scale = Vector3(0.045, 0.045, 0.045)
        gmat.roughness = 1.0
        gm.material = gmat
        zamin.mesh = gm
        zamin.position.y = -0.06
        add_child(zamin)

        # کوه‌های دور (پس‌زمینه تهران — توچال)
        _koohestanha()

func _koohestanha() -> void:
        var mm := MultiMesh.new()
        mm.transform_format = MultiMesh.TRANSFORM_3D
        var makute := CylinderMesh.new()
        makute.top_radius = 0.0
        makute.bottom_radius = 1.0
        makute.height = 1.0
        makute.radial_segments = 7
        var m := StandardMaterial3D.new()
        m.albedo_color = Color(0.62, 0.66, 0.72)
        m.roughness = 1.0
        m.vertex_color_use_as_albedo = true
        makute.material = m
        mm.mesh = makute
        mm.use_colors = true
        var tasadof := RandomNumberGenerator.new()
        tasadof.seed = 77
        var sh := 26
        mm.instance_count = sh
        for i in sh:
                var a := TAU * i / sh + tasadof.randf_range(-0.05, 0.05)
                var fasele := tasadof.randf_range(1250, 1900)
                var h := tasadof.randf_range(160, 420)
                var tr := Transform3D(Basis.IDENTITY.scaled(Vector3(h * tasadof.randf_range(1.3, 2.2), h, h * tasadof.randf_range(1.3, 2.2))),
                        Vector3(cos(a) * fasele, h * 0.5 - 8.0, sin(a) * fasele))
                var c: Color = Color(0.60, 0.65, 0.72).lerp(Color(0.75, 0.78, 0.84), tasadof.randf())
                if tarjome["time"] == "sunset" or tarjome["time"] == "golden":
                        c = c.lerp(Color(0.95, 0.72, 0.5), 0.35)
                mm.set_instance_color(i, c)
        var mmi := MultiMeshInstance3D.new()
        mmi.multimesh = mm
        add_child(mmi)

# ═══════════════════════════ مسیر و آسفالت ═══════════════════════════
func _cr(p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3, t: float) -> Vector3:
        var t2 := t * t
        var t3 := t2 * t
        return 0.5 * ((2.0 * p1) + (-p0 + p2) * t + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 + (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3)

func _masir_besaz() -> void:
        var m := ferman_dasti.size()
        NEMOONEHA = PackedVector3Array()
        NEMOONEHA.resize(NEMOONE_N)
        for i in NEMOONE_N:
                var u := float(i) / NEMOONE_N * m
                var k := int(u) % m
                var t: float = u - floor(u)
                var p0: Vector3 = ferman_dasti[(k - 1 + m) % m]
                var p1: Vector3 = ferman_dasti[k]
                var p2: Vector3 = ferman_dasti[(k + 1) % m]
                var p3: Vector3 = ferman_dasti[(k + 2) % m]
                NEMOONEHA[i] = _cr(p0, p1, p2, p3, t)
        MAMASHA = PackedVector3Array()
        NORMLHA = PackedVector3Array()
        MAMASHA.resize(NEMOONE_N)
        NORMLHA.resize(NEMOONE_N)
        TOOL_JAM = PackedFloat32Array()
        TOOL_JAM.resize(NEMOONE_N)
        for i in NEMOONE_N:
                var a: Vector3 = NEMOONEHA[(i - 1 + NEMOONE_N) % NEMOONE_N]
                var b: Vector3 = NEMOONEHA[(i + 1) % NEMOONE_N]
                var tv := (b - a).normalized()
                MAMASHA[i] = tv
                NORMLHA[i] = Vector3(tv.z, 0.0, -tv.x)  # راستِ مسیر
                TOOL_JAM[i] = 0.0
        for i in range(1, NEMOONE_N):
                TOOL_JAM[i] = TOOL_JAM[i - 1] + NEMOONEHA[i].distance_to(NEMOONEHA[i - 1])
        toole_masir = TOOL_JAM[NEMOONE_N - 1] + NEMOONEHA[0].distance_to(NEMOONEHA[NEMOONE_N - 1])
        _meshe_jade()
        _khatkoshi_jade()
        print("[tizpa][race] track built len=", int(toole_masir))

func _nime_dar(i: int) -> float:
        return tarjome["half"]

func _meshe_jade() -> void:
        var st := SurfaceTool.new()
        st.begin(Mesh.PRIMITIVE_TRIANGLES)
        var tasadof := RandomNumberGenerator.new()
        tasadof.seed = 9
        var n := NEMOONE_N
        for i in n:
                var j := (i + 1) % n
                var h0 := _nime_dar(i)
                var h1 := _nime_dar(j)
                var l0: Vector3 = NEMOONEHA[i] - NORMLHA[i] * h0
                var r0: Vector3 = NEMOONEHA[i] + NORMLHA[i] * h0
                var l1: Vector3 = NEMOONEHA[j] - NORMLHA[j] * h1
                var r1: Vector3 = NEMOONEHA[j] + NORMLHA[j] * h1
                var saye := 0.88 + 0.028 * (sin(float(i) * 0.13) + tasadof.randf() * 0.5)
                var c := Color(saye, saye, saye + 0.006)
                var up := Vector3.UP
                # بافت آسفالت باید در طول جاده تکرار شود — uv طولی
                var v0: float = TOOL_JAM[i] * 0.12
                var v1: float = TOOL_JAM[j] * 0.12
                st.set_uv(Vector2(0, v0)); st.set_color(c); st.set_normal(up); st.add_vertex(l0)
                st.set_uv(Vector2(0, v1)); st.set_color(c); st.set_normal(up); st.add_vertex(l1)
                st.set_uv(Vector2(1, v1)); st.set_color(c); st.set_normal(up); st.add_vertex(r1)
                st.set_uv(Vector2(0, v0)); st.set_color(c); st.set_normal(up); st.add_vertex(l0)
                st.set_uv(Vector2(1, v1)); st.set_color(c); st.set_normal(up); st.add_vertex(r1)
                st.set_uv(Vector2(1, v0)); st.set_color(c); st.set_normal(up); st.add_vertex(r0)
        var meshe := st.commit()
        var mi := MeshInstance3D.new()
        var mate := StandardMaterial3D.new()
        mate.albedo_color = Color(0.46, 0.45, 0.44)
        mate.vertex_color_use_as_albedo = true
        var asfalt_b := _tex_bargozar("asfalt")
        if asfalt_b != null:
                mate.albedo_texture = asfalt_b # عکس واقعی آسفالت
        else:
                mate.albedo_texture = _bafte_asfalt() # بافت رویه‌ای — آسفالت یک‌دست مرده نیست
        mate.roughness = 0.82
        mate.metallic = 0.04
        mate.metallic_specular = 0.6 # برق آفتاب روی آسفالت
        meshe.surface_set_material(0, mate)
        mi.mesh = meshe
        add_child(mi)
        _piyaderoha()

func _mostati(st: SurfaceTool, c0: Vector3, c1: Vector3, w: float, rangi: Color, y: float) -> void:
        # نوار کوتاه روی جاده بین دو نقطه با عرض w
        var d := (c1 - c0)
        if d.length() < 0.01:
                return
        var kenar := Vector3(d.z, 0.0, -d.x).normalized() * w * 0.5
        var a := c0 - kenar + Vector3.UP * y
        var b := c0 + kenar + Vector3.UP * y
        var cc := c1 + kenar + Vector3.UP * y
        var e := c1 - kenar + Vector3.UP * y
        var up := Vector3.UP
        st.set_color(rangi); st.set_normal(up); st.add_vertex(a)
        st.set_color(rangi); st.set_normal(up); st.add_vertex(b)
        st.set_color(rangi); st.set_normal(up); st.add_vertex(cc)
        st.set_color(rangi); st.set_normal(up); st.add_vertex(a)
        st.set_color(rangi); st.set_normal(up); st.add_vertex(cc)
        st.set_color(rangi); st.set_normal(up); st.add_vertex(e)

func _piyaderoha() -> void:
        # پیاده‌روی دو طرف: نوار بلند روشن + جدول — خیابان را «شهر واقعی» می‌کند
        var st := SurfaceTool.new()
        st.begin(Mesh.PRIMITIVE_TRIANGLES)
        var h: float = tarjome["half"]
        var sw := 2.4
        for kenar in [-1.0, 1.0]:
                var i := 0
                while i < NEMOONE_N:
                        var j := (i + 1) % NEMOONE_N
                        var a0: Vector3 = NEMOONEHA[i] + NORMLHA[i] * kenar * h
                        var b0: Vector3 = NEMOONEHA[j] + NORMLHA[j] * kenar * h
                        var a1: Vector3 = NEMOONEHA[i] + NORMLHA[i] * kenar * (h + sw)
                        var b1: Vector3 = NEMOONEHA[j] + NORMLHA[j] * kenar * (h + sw)
                        var bala := Color(0.62, 0.61, 0.585)
                        var up := Vector3.UP
                        var a0t := a0 + Vector3.UP * 0.12
                        var b0t := b0 + Vector3.UP * 0.12
                        var a1t := a1 + Vector3.UP * 0.12
                        var b1t := b1 + Vector3.UP * 0.12
                        # uv طولی — سنگ‌فرش در طول پیاده‌رو تکرار می‌شود
                        var v0: float = TOOL_JAM[i] * 0.35
                        var v1: float = TOOL_JAM[j] * 0.35
                        st.set_uv(Vector2(0, v0)); st.set_color(bala); st.set_normal(up); st.add_vertex(a0t)
                        st.set_uv(Vector2(0, v1)); st.set_color(bala); st.set_normal(up); st.add_vertex(b0t)
                        st.set_uv(Vector2(1, v1)); st.set_color(bala); st.set_normal(up); st.add_vertex(b1t)
                        st.set_uv(Vector2(0, v0)); st.set_color(bala); st.set_normal(up); st.add_vertex(a0t)
                        st.set_uv(Vector2(1, v1)); st.set_color(bala); st.set_normal(up); st.add_vertex(b1t)
                        st.set_uv(Vector2(1, v0)); st.set_color(bala); st.set_normal(up); st.add_vertex(a1t)
                        # جدول سمت جاده (دیواره‌ی ۰.۱۲)
                        var jadval := Color(0.74, 0.72, 0.685)
                        st.set_color(jadval); st.set_normal(-NORMLHA[i] * kenar); st.add_vertex(a0)
                        st.set_color(jadval); st.set_normal(-NORMLHA[j] * kenar); st.add_vertex(b0)
                        st.set_color(jadval); st.set_normal(-NORMLHA[j] * kenar); st.add_vertex(b0t)
                        st.set_color(jadval); st.set_normal(-NORMLHA[i] * kenar); st.add_vertex(a0)
                        st.set_color(jadval); st.set_normal(-NORMLHA[j] * kenar); st.add_vertex(b0t)
                        st.set_color(jadval); st.set_normal(-NORMLHA[i] * kenar); st.add_vertex(a0t)
                        i += 1
        var meshe := st.commit()
        var mate_p := _mate_rangras(false)
        var piyade_b := _tex_bargozar("piyaderah")
        if piyade_b != null:
                mate_p.albedo_texture = piyade_b # سنگ‌فرش واقعی پیاده‌رو
        mate_p.roughness = 0.9
        meshe.surface_set_material(0, mate_p)
        var mi := MeshInstance3D.new()
        mi.mesh = meshe
        add_child(mi)


func _khatkoshi_jade() -> void:
        # خط‌چین وسط + دو خط زرد لبه + خط شروع
        var st := SurfaceTool.new()
        st.begin(Mesh.PRIMITIVE_TRIANGLES)
        var qadam := 6
        var i := 0
        while i < NEMOONE_N:
                var j := (i + qadam / 2) % NEMOONE_N
                if (i / qadam) % 2 == 0:
                        var a: Vector3 = NEMOONEHA[i] + MAMASHA[i] * 1.3
                        var b: Vector3 = NEMOONEHA[i] - MAMASHA[i] * 1.3
                        _mostati(st, a, b, 0.20, Color(0.95, 0.95, 0.93), 0.02)
                i += qadam
        var h: float = tarjome["half"]
        var range_y := Color(0.95, 0.78, 0.10)
        for kenar in [-1.0, 1.0]:
                i = 0
                while i < NEMOONE_N:
                        var j2 := (i + 2) % NEMOONE_N
                        var a2: Vector3 = NEMOONEHA[i] + NORMLHA[i] * kenar * (h - 0.35)
                        var b2: Vector3 = NEMOONEHA[j2] + NORMLHA[j2] * kenar * (h - 0.35)
                        _mostati(st, a2, b2, 0.14, range_y, 0.02)
                        i += 2
        # دو نوار لاستیک‌سوخته‌ی ظریف در هر جهت — آسفالت کارکرده، نه ریل قطار
        var sayer := Color(0.34, 0.335, 0.33)
        for lane in [0.34, 0.66]:
                for kenar in [-1.0, 1.0]:
                        i = 0
                        while i < NEMOONE_N:
                                var j4 := (i + 2) % NEMOONE_N
                                var a4: Vector3 = NEMOONEHA[i] + NORMLHA[i] * kenar * h * lane
                                var b4: Vector3 = NEMOONEHA[j4] + NORMLHA[j4] * kenar * h * lane
                                _mostati(st, a4, b4, h * 0.035, sayer, 0.015)
                                i += 2
        # خط شروع شطرنجی — ۲۵ متر جلوتر از اسپان تا دوربینِ شمارش رویش سوار نشود
        var t_shorou := 12
        var ix0 := 15
        for k in t_shorou:
                var sc: Color = Color(0.72, 0.72, 0.70) if k % 2 == 0 else Color(0.16, 0.16, 0.16)
                var a3: Vector3 = NEMOONEHA[ix0] - MAMASHA[ix0] * 0.6 + NORMLHA[ix0] * (h - 0.4 - k * (2 * h - 0.8) / float(t_shorou))
                var b3: Vector3 = NEMOONEHA[ix0] + MAMASHA[ix0] * 0.6 + NORMLHA[ix0] * (h - 0.4 - (k + 1) * (2 * h - 0.8) / float(t_shorou))
                _mostati(st, a3, b3, 1.2, sc, 0.025)
        var meshe := st.commit()
        meshe.surface_set_material(0, _mate_rangras(false))
        var mi := MeshInstance3D.new()
        mi.mesh = meshe
        add_child(mi)

func _mate_rangras(emissive := false) -> StandardMaterial3D:
        var m := StandardMaterial3D.new()
        m.vertex_color_use_as_albedo = true
        m.roughness = 0.85
        if emissive:
                m.emission_enabled = true
                m.emission = Color(1, 1, 1)
                m.emission_energy_multiplier = 0.7
        return m

# فاصله‌ی جانبی از مرکز مسیر (مثبت = راست جاده)
func _janebi(p: Vector3, at_i: int) -> float:
        return (p - NEMOONEHA[at_i]).dot(NORMLHA[at_i])

func _naztarin(p: Vector3, ersh: int) -> int:
        # جست‌وجوی پنجره‌ای دور نمونه‌ی قبلی — سریع و پایدار
        var behtarin := ersh
        var bd := 1e12
        for k in range(-30, 31):
                var i := (ersh + k + NEMOONE_N) % NEMOONE_N
                var d := (NEMOONEHA[i] - p).length_squared()
                if d < bd:
                        bd = d
                        behtarin = i
        return behtarin

# ═══════════════════════════ شهر: ساختمان/درخت/چراغ/بناهای معروف ═══════════════════════════
func _khane_efe(x: float, z: float, r: float) -> void:
        # در هر ۹ سلول همسایه ثبت می‌شود تا پرس‌وجوی سلولِ خودی همیشه کامل باشد
        var id := saktha.size()
        saktha.append({"x": x, "z": z, "r": r})
        var cx := int(floor(x / KHANE))
        var cz := int(floor(z / KHANE))
        for dx in range(-1, 2):
                for dz in range(-1, 2):
                        var kelid := str(cx + dx) + "," + str(cz + dz)
                        if not shabake_sakht.has(kelid):
                                shabake_sakht[kelid] = []
                        shabake_sakht[kelid].append(id)

func _saktha_nazdik(p: Vector3) -> Array:
        var kelid := str(int(floor(p.x / KHANE))) + "," + str(int(floor(p.z / KHANE)))
        return shabake_sakht.get(kelid, [])

# ═════════════ بافت‌های رویه‌ای: آسفالت و نمای ساختمان — بدون فایل خارجی ═════════════
# عکس‌های آماده در assets/textures — اگر نبود، همان رویه‌ی قدیمی
func _tex_bargozar(nam: String) -> Texture2D:
        var masir := "res://assets/textures/" + nam + ".jpg"
        if ResourceLoader.exists(masir):
                return load(masir)
        return null

func _bafte_asfalt() -> ImageTexture:
        var aks := Image.create(128, 128, false, Image.FORMAT_RGB8)
        var t := RandomNumberGenerator.new()
        t.seed = 41
        for y in 128:
                for x in 128:
                        var g := 0.88 + t.randf_range(-0.08, 0.08)
                        if t.randf() < 0.04:
                                g -= 0.16 # دانه‌های درشت آسفالت
                        aks.set_pixel(x, y, Color(g, g, g * 1.015))
        return ImageTexture.create_from_image(aks)

func _bafte_zamin() -> ImageTexture:
        # زمین اطراف شهر: لکه‌های نرم خاک/چمن — یکدستِ مرده نیست
        var aks := Image.create(64, 64, false, Image.FORMAT_RGB8)
        var t := RandomNumberGenerator.new()
        t.seed = 63
        var ghobleha := []
        for b in 18:
                ghobleha.append([t.randf(), t.randf(), t.randf_range(0.05, 0.16), t.randf_range(-0.10, 0.10)])
        for y in 64:
                for x in 64:
                        var u := float(x) / 64.0
                        var v := float(y) / 64.0
                        var m := 0.0
                        for gb in ghobleha:
                                var dx := minf(absf(u - gb[0]), 1.0 - absf(u - gb[0]))
                                var dy := minf(absf(v - gb[1]), 1.0 - absf(v - gb[1]))
                                m += gb[3] * exp(-(dx * dx + dy * dy) / (gb[2] * gb[2]))
                        var g := clampf(0.94 + m + t.randf_range(-0.05, 0.05), 0.0, 1.0)
                        aks.set_pixel(x, y, Color(g, g, g))
        return ImageTexture.create_from_image(aks)

# برج شیشه‌ای مدرن — شبکه‌ی مولیون فلزی و شیشه‌های آبی با انعکاس آسمان
func _bafte_shishe() -> Array: # [albedo, emission]
        var aks := Image.create(256, 256, false, Image.FORMAT_RGB8)
        var tash := Image.create(256, 256, false, Image.FORMAT_RGB8)
        var t := RandomNumberGenerator.new()
        t.seed = 21
        aks.fill(Color(0.10, 0.15, 0.22))
        tash.fill(Color(0, 0, 0))
        var qadam := 32
        for satr in 8:
                var y0 := satr * qadam
                for soton in 8:
                        var x0 := soton * qadam
                        # شیشه‌ی هر خانه: بازتاب آسمان یا تیره یا روشن (اتاق روشن)
                        var no := t.randf()
                        var shishe := Color(0.16, 0.26, 0.36)
                        if no < 0.18:
                                shishe = Color(0.34, 0.46, 0.56) # انعکاس ابر
                        elif no < 0.30:
                                shishe = Color(0.09, 0.13, 0.19)
                        var ghash := t.randf() < 0.10
                        for y in range(y0 + 1, y0 + qadam - 1):
                                for x in range(x0 + 1, x0 + qadam - 1):
                                        var jolge := 1.35 if (x - x0) < 7 else 1.0
                                        aks.set_pixel(x, y, Color(shishe.r * jolge, shishe.g * jolge, shishe.b * jolge))
                                        if ghash:
                                                tash.set_pixel(x, y, Color(0.72, 0.60, 0.34))
                        # مولیون‌های فلزی قاب
                        for y in range(y0, y0 + qadam):
                                aks.set_pixel(x0, y, Color(0.62, 0.65, 0.68))
                        for x in range(x0, x0 + qadam):
                                aks.set_pixel(x, y0, Color(0.55, 0.58, 0.61))
        var b1 := ImageTexture.create_from_image(aks)
        var b2 := ImageTexture.create_from_image(tash)
        return [b1, b2]

# نمای آجری کلاسیک — پنجره‌ی کوچک با قاب گچی و زیرپنجره
func _bafte_ajoori() -> Array: # [albedo, emission]
        var aks := Image.create(256, 256, false, Image.FORMAT_RGB8)
        var tash := Image.create(256, 256, false, Image.FORMAT_RGB8)
        var t := RandomNumberGenerator.new()
        t.seed = 34
        aks.fill(Color(0.62, 0.34, 0.24))
        tash.fill(Color(0, 0, 0))
        # بافت آجر — خطوط افقی ریز
        for y in 256:
                if y % 8 == 0:
                        for x in 256:
                                var c := aks.get_pixel(x, y)
                                aks.set_pixel(x, y, c.darkened(0.18))
        var boland := 42   # ~۶ طبقه در هر تکرار بافت
        for satr in 6:
                var y0 := satr * boland
                for soton in 5:
                        var x0 := soton * 51 + 12
                        # قاب گچی روشن
                        for y in range(y0 + 4, y0 + 34):
                                for x in range(x0 - 3, x0 + 33):
                                        if x < 0 or x >= 256 or y >= 256:
                                                continue
                                        aks.set_pixel(x, y, Color(0.86, 0.82, 0.74))
                        # شیشه تیره
                        var roshan := t.randf() < 0.14
                        for y in range(y0 + 7, y0 + 31):
                                for x in range(x0, x0 + 30):
                                        var jolge := 1.3 if (y - y0) < 11 else 1.0
                                        aks.set_pixel(x, y, Color(0.11 * jolge, 0.14 * jolge, 0.18 * jolge))
                                        if roshan:
                                                tash.set_pixel(x, y, Color(0.65, 0.52, 0.30))
                        # زیرپنجره
                        for x in range(x0 - 4, x0 + 34):
                                if y0 + 34 < 256:
                                        aks.set_pixel(x, y0 + 34, Color(0.78, 0.74, 0.66))
        var b1 := ImageTexture.create_from_image(aks)
        var b2 := ImageTexture.create_from_image(tash)
        return [b1, b2]

# نمای مغازه‌دار — طبقه‌ی همکف ویترین رنگی + پاروزه، بالای آن گچی
func _bafte_maghazi() -> Array: # [albedo, emission]
        var aks := Image.create(256, 256, false, Image.FORMAT_RGB8)
        var tash := Image.create(256, 256, false, Image.FORMAT_RGB8)
        var t := RandomNumberGenerator.new()
        t.seed = 55
        aks.fill(Color(0.88, 0.84, 0.78))
        tash.fill(Color(0, 0, 0))
        var paroize := [Color(0.72, 0.24, 0.20), Color(0.20, 0.42, 0.70), Color(0.80, 0.58, 0.16), Color(0.24, 0.52, 0.36), Color(0.55, 0.26, 0.60)]
        # همکف = ردیف بالای بافت (v=0 پایِ دیوار در تریمپلانار جهانی)
        for k in 4:
                var x0 := k * 64
                var rang: Color = paroize[t.randi() % paroize.size()]
                # پاروزه‌ی مغازه
                for y in range(0, 14):
                        for x in range(x0, x0 + 64):
                                aks.set_pixel(x, y, rang)
                # ویترین شیشه‌ای
                for y in range(14, 34):
                        for x in range(x0 + 4, x0 + 60):
                                aks.set_pixel(x, y, Color(0.14, 0.18, 0.22))
                                tash.set_pixel(x, y, Color(0.55, 0.50, 0.36))
                # ستون بین مغازه‌ها
                for y in range(0, 34):
                        for x in range(x0, x0 + 3):
                                aks.set_pixel(x, y, Color(0.80, 0.76, 0.70))
        # طبقات بالایی: پنجره‌های گچی ساده
        var boland := 36
        for satr in range(1, 7):
                var y0 := satr * 36
                for soton in 6:
                        var x0 := soton * 42 + 6
                        var roshan := t.randf() < 0.12
                        for y in range(y0 + 5, y0 + 27):
                                for x in range(x0, x0 + 28):
                                        if y >= 256:
                                                continue
                                        aks.set_pixel(x, y, Color(0.14, 0.17, 0.21))
                                        if roshan:
                                                tash.set_pixel(x, y, Color(0.62, 0.50, 0.30))
        var b1 := ImageTexture.create_from_image(aks)
        var b2 := ImageTexture.create_from_image(tash)
        return [b1, b2]

# چهار جعبه‌ی نمای متفاوت — شهر تک‌رنگ نمی‌ماند
func _namaha_besaz() -> Array:
        # اول عکس‌های واقعی، نبودند بافت رویه‌ای
        var shishe_b := _tex_bargozar("nam_shishe")
        var ajoori_b := _tex_bargozar("nam_ajoori")
        var gh_b := _tex_bargozar("nam_sangi")
        var maghazi_b := _tex_bargozar("nam_maghazi")
        var ferq := [
                {"bafte": shishe_b if shishe_b != null else _bafte_shishe()[0], "rough": 0.18, "metal": 0.55, "uv": 0.085},
                {"bafte": ajoori_b if ajoori_b != null else _bafte_ajoori()[0], "rough": 0.95, "metal": 0.0, "uv": 0.095},
                {"bafte": gh_b if gh_b != null else _bafte_namasakht()[0], "rough": 0.85, "metal": 0.0, "uv": 0.085},
                {"bafte": maghazi_b if maghazi_b != null else _bafte_maghazi()[0], "rough": 0.9, "metal": 0.0, "uv": 0.095},
        ]
        var khoruj := []
        for f in ferq:
                var m := StandardMaterial3D.new()
                m.vertex_color_use_as_albedo = true
                m.albedo_texture = f["bafte"]
                m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
                m.roughness = f["rough"]
                m.metallic = f["metal"]
                m.metallic_specular = 0.5
                m.uv1_triplanar = true
                m.uv1_world_triplanar = true
                m.uv1_scale = Vector3(f["uv"], f["uv"], f["uv"])
                var q := BoxMesh.new()
                q.size = Vector3(1, 1, 1)
                q.material = m
                khoruj.append(q)
        return khoruj

func _bafte_namasakht() -> Array: # [albedo, emission]
        var aks := Image.create(512, 512, false, Image.FORMAT_RGB8)
        var tash := Image.create(512, 512, false, Image.FORMAT_RGB8)
        var t := RandomNumberGenerator.new()
        t.seed = 77
        aks.fill(Color(0.965, 0.945, 0.92))
        tash.fill(Color(0, 0, 0))
        var boland := 51   # ۵۱۲ ÷ ۱۰ طبقه
        for satr in 10:
                var y0 := satr * boland
                # لبه‌ی طبقه — خط سایه‌دار که مرز هر طبقه را می‌خواند
                for x in 512:
                        aks.set_pixel(x, y0, Color(0.78, 0.77, 0.75))
                        aks.set_pixel(x, y0 + 1, Color(0.87, 0.86, 0.84))
                for soton in 5:
                        var x0 := soton * 102 + 22
                        var y1 := y0 + 12
                        # قاب روشن پنجره
                        for y in range(y1 - 3, y1 + 33):
                                for x in range(x0 - 3, x0 + 61):
                                        if x < 0 or x >= 512 or y >= 512:
                                                continue
                                        aks.set_pixel(x, y, Color(0.90, 0.89, 0.86))
                        # شیشه‌ی تیره — تنوع روشنایی + انعکاس لبه‌ی بالایی
                        var shishe := Color(0.12, 0.18, 0.26).lerp(Color(0.25, 0.31, 0.39), t.randf())
                        var roshan := t.randf() < 0.12
                        for y in range(y1, y1 + 30):
                                for x in range(x0, x0 + 58):
                                        var jolge := 1.3 if (y - y1) < 4 else 1.0
                                        aks.set_pixel(x, y, Color(shishe.r * jolge, shishe.g * jolge, shishe.b * jolge))
                                        if roshan:
                                                tash.set_pixel(x, y, Color(0.60, 0.50, 0.28))
        var b1 := ImageTexture.create_from_image(aks)
        var b2 := ImageTexture.create_from_image(tash)
        return [b1, b2]

func _manzare_besaz() -> void:
        var tasadof := RandomNumberGenerator.new()
        tasadof.seed = int(tarjome["id"]) * 1337 + 5
        var h: float = tarjome["half"]
        var range_sakhtema: Array = tarjome["bld"]
        # چهار نوع نما: برج شیشه‌ای / آجری / گچی / مغازه‌دار — شهر یکدست و مرده نمی‌ماند
        var quteha: Array = _namaha_besaz()
        var ghesmatha := [[], [], [], []]
        var qadam := 3
        var i := 0
        while i < NEMOONE_N:
                for kenar in [-1.0, 1.0]:
                        if tasadof.randf() < 0.12:
                                continue
                        var paye: Vector3 = NEMOONEHA[i] + NORMLHA[i] * kenar * (h + 11.0 + tasadof.randf() * 9.0)
                        var door := _kamtarin_fasele(paye)
                        if door < h + 6.0:
                                continue
                        var ht := tasadof.randf_range(7, 9) + (14.0 if tasadof.randf() < 0.3 else 0.0) + (22.0 if tasadof.randf() < 0.08 else 0.0)
                        # نوع نما بر اساس بلندی + شانس — بلندها برج شیشه‌ای، همکف‌ها مغازه‌دار
                        var no := 2
                        if ht > 20.0:
                                no = 0 if tasadof.randf() < 0.75 else 1
                        elif ht < 12.0 and tasadof.randf() < 0.45:
                                no = 3
                        elif tasadof.randf() < 0.5:
                                no = 1
                        ghesmatha[no].append({"p": paye, "c": range_sakhtema[tasadof.randi() % range_sakhtema.size()],
                                "w": tasadof.randf_range(7, 15), "d": tasadof.randf_range(7, 13), "ht": ht})
                i += qadam
        var hamgi := [[0.95, 0.97, 1.0], [1.0, 0.96, 0.92], [1.0, 1.0, 1.0], [1.04, 1.0, 0.94]]
        for no in 4:
                if ghesmatha[no].size() == 0:
                        continue
                var mm := MultiMesh.new()
                mm.transform_format = MultiMesh.TRANSFORM_3D
                mm.use_colors = true
                mm.mesh = quteha[no]
                mm.instance_count = ghesmatha[no].size()
                for k in ghesmatha[no].size():
                        var sp: Dictionary = ghesmatha[no][k]
                        var sc := Vector3(sp["w"], sp["ht"], sp["d"])
                        var qabe := Basis(Vector3.UP, tasadof.randf_range(-0.25, 0.25)).scaled(sc) # چرخش کم — گوشه‌ی ساختمان نباید داخل جاده بیفتد
                        mm.set_instance_transform(k, Transform3D(qabe, Vector3(sp["p"].x, sp["ht"] * 0.5, sp["p"].z)))
                        var rangi: Color = sp["c"]
                        var hgb: Array = hamgi[no]
                        rangi = Color(rangi.r * hgb[0], rangi.g * hgb[1], rangi.b * hgb[2])
                        mm.set_instance_color(k, rangi)
                        _khane_efe(sp["p"].x, sp["p"].z, maxf(sp["w"], sp["d"]) * 0.42)
                var mmi := MultiMeshInstance3D.new()
                mmi.multimesh = mm
                mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
                add_child(mmi)
        var mashalha: Array = []
        for no in 4:
                mashalha += ghesmatha[no]
        _posh_bam(mashalha, tasadof)

        # درخت‌ها + تیرهای چراغ (هر دو با برخورد دایره‌ای)
        _derakht_cheragh(tasadof)
        # ماشین‌های پارک‌شده کنار جدول — خیابان خالی، خیابان نیست
        _mashinha_park(tasadof)
        # مخروط‌های راهنما داخل پیچ‌های تند
        _ghootiha(tasadof)
        # ابرهای نرم آسمان
        _abrha()
        # چادر/سایبان بازار
        if tarjome["bazaar"] > 0.5:
                _sayeba_bazar(tasadof)
        # بناهای معروف
        if tarjome["landmark"] == "azadi":
                _bonaye_azadi()
        elif tarjome["landmark"] == "milad":
                _borje_milad(tasadof)
        # بیلبوردهای فارسی — با یک فریم تأخیر تا متن‌ها رندر شوند
        _bilon_bepar.call_deferred()

# پشت‌بام: جان‌پناه + کولر + منبع آب — خط افق شهر را زنده می‌کند
func _posh_bam(mashalha: Array, tasadof: RandomNumberGenerator) -> void:
        var beton := StandardMaterial3D.new()
        beton.vertex_color_use_as_albedo = true
        beton.roughness = 0.95
        var jane_paneh := BoxMesh.new()
        jane_paneh.size = Vector3(1, 1, 1)
        jane_paneh.material = beton
        var kollr := BoxMesh.new()
        kollr.size = Vector3(1, 1, 1)
        kollr.material = beton
        var tank := CylinderMesh.new()
        tank.top_radius = 0.9
        tank.bottom_radius = 0.9
        tank.height = 1.5
        tank.radial_segments = 10
        tank.material = beton
        var mm1 := MultiMesh.new()
        mm1.transform_format = MultiMesh.TRANSFORM_3D
        mm1.use_colors = true
        mm1.mesh = jane_paneh
        var mm2 := MultiMesh.new()
        mm2.transform_format = MultiMesh.TRANSFORM_3D
        mm2.use_colors = true
        mm2.mesh = kollr
        var mm3 := MultiMesh.new()
        mm3.transform_format = MultiMesh.TRANSFORM_3D
        mm3.use_colors = true
        mm3.mesh = tank
        # اول همه‌ی ترنسفورم‌ها ساخته می‌شوند، بعد count دقیق از اندازه‌ی آرایه — هیچ بیرون‌زدگی‌ای ممکن نیست
        var lst1: Array = []   # جان‌پناه
        var lst2: Array = []   # کولر
        var lst3: Array = []   # منبع آب
        for sp in mashalha:
                var w: float = sp["w"]
                var d: float = sp["d"]
                var ht: float = sp["ht"]
                var p: Vector3 = sp["p"]
                # جان‌پناه — لبه‌ی بتنی دور بام
                lst1.append(Transform3D(Basis.IDENTITY.scaled(Vector3(w + 0.35, 0.5, d + 0.35)),
                        Vector3(p.x, ht + 0.12, p.z)))
                # کولرهای پشت‌بام
                var tedad := 1 + tasadof.randi() % 3
                for c in tedad:
                        var ac := tasadof.randf_range(0.8, 1.5)
                        var ax := p.x + tasadof.randf_range(-w * 0.3, w * 0.3)
                        var az := p.z + tasadof.randf_range(-d * 0.3, d * 0.3)
                        lst2.append(Transform3D(Basis.IDENTITY.scaled(Vector3(ac, ac * 0.6, ac)),
                                Vector3(ax, ht + ac * 0.3 + 0.25, az)))
                # منبع آب — علامتِ پشت‌بامِ تهران
                if tasadof.randf() < 0.3:
                        lst3.append(Transform3D(Basis.IDENTITY,
                                Vector3(p.x + tasadof.randf_range(-w * 0.2, w * 0.2), ht + 1.0, p.z + tasadof.randf_range(-d * 0.2, d * 0.2))))
        mm1.instance_count = lst1.size()
        mm2.instance_count = lst2.size()
        mm3.instance_count = lst3.size()
        for k in lst1.size():
                mm1.set_instance_transform(k, lst1[k])
                mm1.set_instance_color(k, Color(0.58, 0.56, 0.53))
        for k in lst2.size():
                mm2.set_instance_transform(k, lst2[k])
                mm2.set_instance_color(k, Color(0.66, 0.65, 0.62))
        for k in lst3.size():
                mm3.set_instance_transform(k, lst3[k])
                mm3.set_instance_color(k, Color(0.72, 0.70, 0.66))
        var mi1 := MultiMeshInstance3D.new(); mi1.multimesh = mm1; add_child(mi1)
        var mi2 := MultiMeshInstance3D.new(); mi2.multimesh = mm2; add_child(mi2)
        var mi3 := MultiMeshInstance3D.new(); mi3.multimesh = mm3; add_child(mi3)

func _kamtarin_fasele(p: Vector3) -> float:
        var md := 1e12
        for i in range(0, NEMOONE_N, 12):
                var d: float = (NEMOONEHA[i] - p).length_squared()
                if d < md:
                        md = d
        return sqrt(md)

func _derakht_cheragh(tasadof: RandomNumberGenerator) -> void:
        var h: float = tarjome["half"]
        var sandugh := CylinderMesh.new()
        sandugh.top_radius = 0.16
        sandugh.bottom_radius = 0.26
        sandugh.height = 1.0
        sandugh.radial_segments = 6
        var tmat := StandardMaterial3D.new()
        tmat.albedo_color = Color(0.42, 0.30, 0.20)
        tmat.roughness = 1.0
        sandugh.material = tmat
        var barg := SphereMesh.new()
        barg.radius = 1.0
        barg.height = 2.0
        barg.radial_segments = 11
        barg.rings = 6
        var lmat := StandardMaterial3D.new()
        lmat.vertex_color_use_as_albedo = true
        lmat.roughness = 1.0
        barg.material = lmat
        # لایه‌ی دوم تاج — گوی تنها شبیه توپ فوتبال است
        var barg2 := SphereMesh.new()
        barg2.radius = 1.0
        barg2.height = 2.0
        barg2.radial_segments = 10
        barg2.rings = 5
        barg2.material = lmat
        var mmT := MultiMesh.new()
        mmT.transform_format = MultiMesh.TRANSFORM_3D
        mmT.mesh = sandugh
        var mmL := MultiMesh.new()
        mmL.transform_format = MultiMesh.TRANSFORM_3D
        mmL.use_colors = true
        mmL.mesh = barg
        var mmL2 := MultiMesh.new()
        mmL2.transform_format = MultiMesh.TRANSFORM_3D
        mmL2.use_colors = true
        mmL2.mesh = barg2
        var tir := CylinderMesh.new()
        tir.top_radius = 0.07
        tir.bottom_radius = 0.09
        tir.height = 1.0
        tir.radial_segments = 6
        var pmat := StandardMaterial3D.new()
        pmat.albedo_color = Color(0.35, 0.37, 0.40)
        tir.material = pmat
        var mmP := MultiMesh.new()
        mmP.transform_format = MultiMesh.TRANSFORM_3D
        mmP.mesh = tir
        var sar := BoxMesh.new()
        sar.size = Vector3(0.9, 0.16, 0.34)
        var hmat := StandardMaterial3D.new()
        hmat.albedo_color = Color(0.9, 0.9, 0.85)
        hmat.emission_enabled = true
        hmat.emission = Color(1.0, 0.92, 0.7)
        hmat.emission_energy_multiplier = 0.4
        sar.material = hmat
        var mmH := MultiMesh.new()
        mmH.transform_format = MultiMesh.TRANSFORM_3D
        mmH.mesh = sar

        var spotsT: Array = []
        var spotsP: Array = []
        var i := 0
        var qadam := 7
        while i < NEMOONE_N:
                # چراغ هر دو طرف با فاصله منظم
                for kenar in [-1.0, 1.0]:
                        var pp: Vector3 = NEMOONEHA[i] + NORMLHA[i] * kenar * (h + 0.9)
                        spotsP.append({"p": pp, "side": kenar, "i": i})
                        _khane_efe(pp.x, pp.z, 0.3)
                # درخت‌ها
                var derakhtan := int(round(float(tarjome["trees"]) * 2.0))
                for t in derakhtan:
                        if tasadof.randf() < 0.35:
                                continue
                        for kenar in [-1.0, 1.0]:
                                var khamosh := h + 3.6 + tasadof.randf() * 2.8
                                var qi: int = (i + tasadof.randi() % 5) % NEMOONE_N
                                var tp: Vector3 = NEMOONEHA[qi] + NORMLHA[qi] * kenar * khamosh
                                if _kamtarin_fasele(tp) < h + 1.6:
                                        continue
                                spotsT.append(tp)
                                _khane_efe(tp.x, tp.z, 0.5)
                i += qadam
        mmT.instance_count = spotsT.size()
        mmL.instance_count = spotsT.size()
        mmL2.instance_count = spotsT.size()
        for k in spotsT.size():
                var tp: Vector3 = spotsT[k]
                var th := tasadof.randf_range(2.2, 3.6)
                mmT.set_instance_transform(k, Transform3D(Basis.IDENTITY.scaled(Vector3(1, th, 1)), Vector3(tp.x, th * 0.5, tp.z)))
                var lh := tasadof.randf_range(1.6, 2.6)
                var lb := Basis.IDENTITY.scaled(Vector3(lh, lh * 1.05, lh))
                mmL.set_instance_transform(k, Transform3D(lb, Vector3(tp.x, th + lh * 0.42, tp.z)))
                # لایه‌ی دوم تاج — جابجا و کوچک‌تر، درخت «پر» دیده می‌شود
                var lh2 := lh * tasadof.randf_range(0.55, 0.7)
                var af := tasadof.randf_range(0.35, 0.75)
                var lb2 := Basis.IDENTITY.scaled(Vector3(lh2, lh2 * 0.95, lh2))
                mmL2.set_instance_transform(k, Transform3D(lb2, Vector3(tp.x + af, th + lh * 0.42 + lh2 * 0.5, tp.z + af * 0.5)))
                var lc := Color(0.26, 0.45, 0.20).lerp(Color(0.40, 0.58, 0.26), tasadof.randf())
                if tarjome["time"] == "golden":
                        lc = lc.lerp(Color(0.68, 0.56, 0.22), 0.3)
                mmL.set_instance_color(k, lc)
                mmL2.set_instance_color(k, lc.darkened(0.12))
        mmP.instance_count = spotsP.size()
        mmH.instance_count = spotsP.size()
        for k in spotsP.size():
                var sp2: Dictionary = spotsP[k]
                var pp: Vector3 = sp2["p"]
                var si: int = sp2["i"]
                mmP.set_instance_transform(k, Transform3D(Basis.IDENTITY.scaled(Vector3(1, 5.6, 1)), Vector3(pp.x, 2.8, pp.z)))
                # سر چراغ رو به جاده — از نرمالِ همان نمونه (بدون جست‌وجوی پرهزینه)
                var hp := pp + (-NORMLHA[si]) * 0.9 + Vector3.UP * 5.5
                var b := Basis(Vector3.UP, atan2(MAMASHA[si].x, MAMASHA[si].z))
                mmH.set_instance_transform(k, Transform3D(b.scaled(Vector3(1, 1, 1)), hp))
        var miT := MultiMeshInstance3D.new(); miT.multimesh = mmT; add_child(miT)
        var miL := MultiMeshInstance3D.new(); miL.multimesh = mmL; add_child(miL)
        var miL2 := MultiMeshInstance3D.new(); miL2.multimesh = mmL2; add_child(miL2)
        var miP := MultiMeshInstance3D.new(); miP.multimesh = mmP; add_child(miP)
        var miH := MultiMeshInstance3D.new(); miH.multimesh = mmH; add_child(miH)

func _sayeba_bazar(tasadof: RandomNumberGenerator) -> void:
        var h: float = tarjome["half"]
        var st := SurfaceTool.new()
        st.begin(Mesh.PRIMITIVE_TRIANGLES)
        var sotunha := [Color(0.85, 0.30, 0.25), Color(0.20, 0.45, 0.75), Color(0.90, 0.65, 0.20), Color(0.25, 0.55, 0.35)]
        var i := 0
        while i < NEMOONE_N:
                for kenar in [-1.0, 1.0]:
                        if tasadof.randf() < 0.45:
                                continue
                        var j := (i + 3) % NEMOONE_N
                        var a: Vector3 = NEMOONEHA[i] + NORMLHA[i] * kenar * (h + 1.6) + Vector3.UP * 2.6
                        var b: Vector3 = NEMOONEHA[j] + NORMLHA[j] * kenar * (h + 1.6) + Vector3.UP * 2.6
                        var darunsuma: Vector3 = -NORMLHA[i] * kenar * 1.5
                        var a2: Vector3 = a + darunsuma
                        var b2: Vector3 = b + (-NORMLHA[j] * kenar * 1.5)
                        var up := Vector3.UP
                        var c: Color = sotunha[tasadof.randi() % sotunha.size()]
                        st.set_color(c); st.set_normal(up); st.add_vertex(a)
                        st.set_color(c); st.set_normal(up); st.add_vertex(b)
                        st.set_color(c); st.set_normal(up); st.add_vertex(b2)
                        st.set_color(c); st.set_normal(up); st.add_vertex(a)
                        st.set_color(c); st.set_normal(up); st.add_vertex(b2)
                        st.set_color(c); st.set_normal(up); st.add_vertex(a2)
                i += 4
        var meshe := st.commit()
        meshe.surface_set_material(0, _mate_rangras(false))
        var mi := MeshInstance3D.new()
        mi.mesh = meshe
        add_child(mi)

func _bonaye_azadi() -> void:
        # بنای آزادی — وسط میدان؛ حلقه‌ی مسیر دورش می‌چرخد
        var g := Node3D.new()
        g.position = Vector3(0, 0, 0)
        var wmat := StandardMaterial3D.new()
        wmat.albedo_color = Color(0.94, 0.92, 0.86)
        wmat.roughness = 0.8
        # دو پایه‌ی مورب (شکل Y وارونه) + سردر
        for sx in [-1.0, 1.0]:
                var pa := PrismMesh.new()
                pa.left_to_right = 0.5
                pa.size = Vector3(7.0, 24.0, 10.0)
                var lm := MeshInstance3D.new()
                lm.mesh = pa
                lm.material_override = wmat
                lm.position = Vector3(sx * 7.5, 12.0, 0)
                lm.rotation_degrees = Vector3(0, 0, -sx * 13)
                g.add_child(lm)
        var bala := BoxMesh.new()
        bala.size = Vector3(26.0, 6.0, 11.0)
        var tm := MeshInstance3D.new()
        tm.mesh = bala
        tm.material_override = wmat
        tm.position = Vector3(0, 26.0, 0)
        g.add_child(tm)
        var taq := BoxMesh.new()
        taq.size = Vector3(10.0, 10.0, 11.5)
        var am := MeshInstance3D.new()
        am.mesh = taq
        am.material_override = wmat
        am.position = Vector3(0, 30.5, 0)
        g.add_child(am)
        add_child(g)
        _khane_efe(0, 0, 17.0)
        print("[tizpa][race] azadi monument placed")

func _borje_milad(tasadof: RandomNumberGenerator) -> void:
        # سیلوئت برج میلاد در دوردست (بیرون از مسیر — فقط دکور)
        var a := tasadof.randf_range(0, TAU)
        var paye := Vector3(cos(a) * 620, 0, sin(a) * 620)
        var cmat := StandardMaterial3D.new()
        cmat.albedo_color = Color(0.80, 0.80, 0.82)
        var mehvar := CylinderMesh.new()
        mehvar.top_radius = 3.2
        mehvar.bottom_radius = 7.5
        mehvar.height = 180.0
        mehvar.radial_segments = 10
        var sm := MeshInstance3D.new()
        sm.mesh = mehvar
        sm.material_override = cmat
        sm.position = paye + Vector3(0, 90, 0)
        add_child(sm)
        var sar := CylinderMesh.new()
        sar.top_radius = 2.2
        sar.bottom_radius = 13.0
        sar.height = 26.0
        sar.radial_segments = 10
        var hm := MeshInstance3D.new()
        hm.mesh = sar
        hm.material_override = cmat
        hm.position = paye + Vector3(0, 190, 0)
        add_child(hm)
        var antn := CylinderMesh.new()
        antn.top_radius = 0.4
        antn.bottom_radius = 1.0
        antn.height = 46.0
        var am := MeshInstance3D.new()
        am.mesh = antn
        am.material_override = cmat
        am.position = paye + Vector3(0, 226, 0)
        add_child(am)

# ═════════════ مخروط‌های راهنما در پیچ‌های تند — بوی پیست دریفت ═════════════
func _ghootiha(tasadof: RandomNumberGenerator) -> void:
        var h: float = tarjome["half"]
        var q := CylinderMesh.new()
        q.top_radius = 0.02
        q.bottom_radius = 0.15
        q.height = 0.52
        q.radial_segments = 8
        var m := StandardMaterial3D.new()
        m.albedo_color = Color(0.95, 0.45, 0.08)
        m.roughness = 0.6
        m.emission_enabled = true
        m.emission = Color(0.9, 0.38, 0.05)
        m.emission_energy_multiplier = 0.3
        q.material = m
        var jayha := []
        var i := 0
        while i < NEMOONE_N:
                var badi := MAMASHA[(i + 14) % NEMOONE_N]
                var lav := MAMASHA[i].angle_to(badi)
                if lav > 0.10:
                        # سمت بیرون پیچ: ضرب‌دکرودی مماس‌ها — پیچ چپ، بیرونش راست جاده است
                        var bojn := MAMASHA[i].cross(badi).y
                        var kenar := 1.0 if bojn > 0.0 else -1.0
                        var c := 0
                        var t2 := i
                        while c < 4 and t2 < i + 16:
                                var tp: Vector3 = NEMOONEHA[t2 % NEMOONE_N] + NORMLHA[t2 % NEMOONE_N] * kenar * (h + 0.55 + (c % 2) * 0.5)
                                jayha.append(tp)
                                c += 1
                                t2 += 4
                        i += 16
                i += 6
        if jayha.size() == 0:
                return
        var mm := MultiMesh.new()
        mm.transform_format = MultiMesh.TRANSFORM_3D
        mm.mesh = q
        mm.instance_count = jayha.size()
        for k in jayha.size():
                var p: Vector3 = jayha[k]
                mm.set_instance_transform(k, Transform3D(Basis.IDENTITY, Vector3(p.x, 0.26, p.z)))
        var mmi := MultiMeshInstance3D.new()
        mmi.multimesh = mm
        add_child(mmi)

# ═════════════ ابرهای نرم — آسمان خالی، آسمان بازی نیست ═════════════
func _abrha() -> void:
        var t := RandomNumberGenerator.new()
        t.seed = 91
        var aks := Image.create(128, 64, false, Image.FORMAT_RGBA8)
        var ghobleha := []
        for b in 20:
                ghobleha.append([t.randf_range(0.22, 0.78), t.randf_range(0.38, 0.62), t.randf_range(0.09, 0.20), t.randf_range(0.55, 1.0)])
        for y in 64:
                for x in 128:
                        var u := float(x) / 64.0
                        var v := float(y) / 64.0
                        var mohre := 0.0
                        for gb in ghobleha:
                                var dx: float = u - float(gb[0])
                                var dy: float = (v - float(gb[1])) * 1.9
                                mohre = maxf(mohre, gb[3] * exp(-(dx * dx + dy * dy) / (gb[2] * gb[2])))
                        var hazhe := clampf(minf(u, 2.0 - u) * 1.3, 0.0, 1.0) * clampf(minf(v, 2.0 - v) * 1.6, 0.0, 1.0)
                        aks.set_pixel(x, y, Color(1, 1, 1, clampf(mohre, 0.0, 1.0) * hazhe * 0.8))
        aks.generate_mipmaps() # بدون این، نمونه‌برداری ناقص است — همان درس بیلبوردها
        var tex := ImageTexture.create_from_image(aks)
        var q := QuadMesh.new()
        q.size = Vector2(1, 0.5)
        var m2 := StandardMaterial3D.new()
        m2.albedo_texture = tex
        m2.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
        m2.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        m2.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        m2.cull_mode = BaseMaterial3D.CULL_DISABLED
        # رنگ پایه — در غروب ابرها طلایی می‌گیرند
        m2.albedo_color = Color(1, 1, 1, 1) if tarjome["time"] == "day" else Color(1.0, 0.86, 0.7, 1.0)
        q.material = m2
        # رو به مرکز شهر — بیلبوردِ ثابت در رندرر سازگاری لبه‌ای می‌شود، دستی می‌چرخانیم
        for k in 16:
                var a := TAU * k / 16.0 + t.randf_range(-0.2, 0.2)
                var fasele := t.randf_range(240.0, 720.0)
                var boland := t.randf_range(110.0, 200.0)
                var afqi := t.randf_range(170.0, 320.0)
                var abr := MeshInstance3D.new()
                abr.mesh = q
                abr.scale = Vector3(afqi, afqi * 0.5, 1.0)
                abr.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
                add_child(abr)
                abr.position = Vector3(cos(a) * fasele, boland, sin(a) * fasele)
                abr.look_at(Vector3(0, boland, 0.01))

# ═════════════ بیلبوردهای فارسی کنار جاده — جانِ خیابانِ ایرانی ═════════════
func _matn_tex(matn: String, bg: Color, fg := Color(0.1, 0.08, 0.06)) -> ImageTexture:
        # متن فارسیِ شکل‌گرفته با فونت واقعی → بافت؛ بدون این، تابلوها بی‌جان‌اند
        var vp := SubViewport.new()
        vp.size = Vector2i(512, 256)
        vp.render_target_update_mode = SubViewport.UPDATE_ONCE
        add_child(vp)
        var rect := ColorRect.new()
        rect.color = bg
        rect.size = Vector2(512, 256)
        vp.add_child(rect)
        # جداسازی دوسطری برای حروف درشت — تابلوی بزرگ، متن بزرگ
        var khat1 := matn
        var khat2 := ""
        if matn.length() > 8:
                var fasleha := []
                for k in matn.length():
                        if matn.substr(k, 1) == " ":
                                fasleha.append(k)
                if fasleha.size() > 0:
                        var vasat: int = fasleha[fasleha.size() / 2]
                        khat1 = matn.substr(0, vasat)
                        khat2 = matn.substr(vasat + 1)
        var tuli := maxf(khat1.length(), maxf(khat2.length(), 1))
        var lbl := Label.new()
        lbl.text = khat1 + ("\n" + khat2 if khat2 != "" else "")
        lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        lbl.size = Vector2(512, 256)
        var f := load("res://assets/fonts/Lalezar-Regular.ttf")
        if f != null:
                lbl.add_theme_font_override("font", f)
        lbl.add_theme_constant_override("line_spacing", -10)
        # بودجه‌ی ارتفاع: لاله‌زار خطِ بلند دارد — دوسطری باید در ۲۵۶ پیکسل جا شود
        var fs_v := int(236.0 / (1.35 * (2.0 if khat2 != "" else 1.0) - 0.12))
        var fs_w := int(500.0 / tuli / 0.56)
        lbl.add_theme_font_size_override("font_size", clampi(mini(fs_v, fs_w), 48, 148))
        lbl.add_theme_color_override("font_color", fg)
        vp.add_child(lbl)
        await RenderingServer.frame_post_draw
        var aks := vp.get_texture().get_image()
        vp.queue_free()
        aks.generate_mipmaps() # زنجیره‌ی مپی‌مپ کامل — در پیچ و دور، متن باز می‌ماند
        return ImageTexture.create_from_image(aks)

func _bilon_bepar() -> void:
        var h: float = tarjome["half"]
        var matnha := ["پیتزا ساندویچ", "کافه چنار", "تعویض روغن", "خشکبار تهرانی", "عطر و ادکلن", "آژانس مسافرتی", "دوچرخه ژیان", "میوه‌فروشی"]
        var zamineha := [Color(0.95, 0.78, 0.10), Color(0.82, 0.22, 0.16), Color(0.16, 0.45, 0.80), Color(0.93, 0.90, 0.86), Color(0.55, 0.20, 0.62), Color(0.15, 0.55, 0.35), Color(0.93, 0.48, 0.10), Color(0.20, 0.62, 0.55)]
        var bafteha: Array = []
        for k in matnha.size():
                bafteha.append(await _matn_tex(matnha[k], zamineha[k]))
        var charchubi := StandardMaterial3D.new()
        charchubi.albedo_color = Color(0.24, 0.25, 0.28)
        charchubi.roughness = 0.7
        # دو پوستر هنری هم بین تابلوهای فارسی — مثل بیلبوردهای ولیعصر
        var poster1 := _tex_bargozar("poster_tas")
        var poster2 := _tex_bargozar("poster_shahr")
        var paye_m := CylinderMesh.new()
        paye_m.top_radius = 0.09
        paye_m.bottom_radius = 0.12
        paye_m.height = 1.0
        paye_m.radial_segments = 6
        paye_m.material = charchubi
        var panjare_m := BoxMesh.new()
        panjare_m.size = Vector3(1, 1, 1)
        panjare_m.material = charchubi
        var shomare := 0
        var i := 24
        while i < NEMOONE_N - 24:
                var kenar := 1.0 if (shomare % 2) == 0 else -1.0
                var pp: Vector3 = NEMOONEHA[i] + NORMLHA[i] * kenar * (h + 3.4)
                var g := Node3D.new()
                g.position = Vector3(pp.x, 0.0, pp.z)
                # چرخش: کمی رو به راننده‌ی نزدیک‌شونده — تابلو از دور خوانده می‌شود
                var dakheli := (-NORMLHA[i] * kenar - MAMASHA[i] * 0.78).normalized()
                g.rotation.y = atan2(dakheli.x, dakheli.z)
                # دو پایه
                for sx in [-2.6, 2.6]:
                    var p_m := MeshInstance3D.new()
                    p_m.mesh = paye_m
                    p_m.scale = Vector3(1, 5.4, 1)
                    p_m.position = Vector3(sx, 2.7, 0)
                    g.add_child(p_m)
                # قاب تیره + تخته‌ی تابلو — فارسی یا پوستر، یکی در میان
                var qab := MeshInstance3D.new()
                qab.mesh = panjare_m
                qab.scale = Vector3(7.4, 3.9, 0.16)
                qab.position = Vector3(0, 7.35, 0.05)
                g.add_child(qab)
                var panel_m := StandardMaterial3D.new()
                var aks_shomare := shomare % 3
                if aks_shomare == 2 and poster1 != null:
                        panel_m.albedo_texture = poster1 if (shomare / 3) % 2 == 0 else (poster2 if poster2 != null else poster1)
                else:
                        panel_m.albedo_texture = bafteha[shomare % bafteha.size()]
                panel_m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
                panel_m.emission_enabled = true
                panel_m.emission_texture = panel_m.albedo_texture
                panel_m.emission_energy_multiplier = 0.25 # تابلو در غروب هم جان داشته باشد
                panel_m.roughness = 0.5
                var panel := QuadMesh.new()
                panel.size = Vector2(7.1, 3.6)
                panel.material = panel_m
                var pmi := MeshInstance3D.new()
                pmi.mesh = panel
                pmi.position = Vector3(0, 7.4, 0.14)
                g.add_child(pmi)
                add_child(g)
                shomare += 1
                i += 62

# ═══════════════════ ماشین‌ساز — بدنه‌ی اسپرت کم‌ضلع ═══════════════════
func _mate_rang(c: Color, metallic := 0.5) -> StandardMaterial3D:
        var m := StandardMaterial3D.new()
        m.albedo_color = c
        m.roughness = 0.22
        m.metallic = clampf(metallic, 0.0, 1.0)
        m.metallic_specular = 0.7
        # لایه‌ی کلیرکوت — همان برق شیشه‌ای روی لاک که ماشین‌های NFS دارند
        m.clearcoat_enabled = true
        m.clearcoat = 0.9
        m.clearcoat_roughness = 0.12
        m.rim_enabled = true
        m.rim = 0.55
        m.rim_tint = 0.3
        return m

func _mate_tir(c: Color, rough := 0.7) -> StandardMaterial3D:
        var m := StandardMaterial3D.new()
        m.albedo_color = c
        m.roughness = rough
        return m

func _qute(parent: Node3D, size: Vector3, pos3: Vector3, mate: StandardMaterial3D, rot := Vector3.ZERO) -> MeshInstance3D:
        var bm := BoxMesh.new()
        bm.size = size
        var mi := MeshInstance3D.new()
        mi.mesh = bm
        mi.material_override = mate
        parent.add_child(mi)
        mi.position = pos3
        mi.rotation_degrees = rot
        return mi

# ═══════════════════ ماشین‌ساز — بدنه‌ی لوفت‌شده‌ی چندوجهی، نه مکعب ═══════════════════
func _halqeh_badane(z: float, y_paeen: float, y_kamar: float, nime_arz: float, y_taj: float) -> Array:
        # مقطع بدنه در یک ایستگاه — ۱۴ گوشه، از کف دور می‌زنیم به سقف (نرمال رو به بیرون)
        return [
                Vector3(0.0, y_paeen, z),
                Vector3(nime_arz * 0.78, y_paeen, z),
                Vector3(nime_arz * 0.965, y_paeen + 0.07, z),
                Vector3(nime_arz, y_kamar - 0.15, z),
                Vector3(nime_arz * 0.985, y_kamar, z),
                Vector3(nime_arz * 0.80, y_taj - 0.05, z),
                Vector3(nime_arz * 0.45, y_taj, z),
                Vector3(0.0, y_taj + 0.02, z),
                Vector3(-nime_arz * 0.45, y_taj, z),
                Vector3(-nime_arz * 0.80, y_taj - 0.05, z),
                Vector3(-nime_arz * 0.985, y_kamar, z),
                Vector3(-nime_arz, y_kamar - 0.15, z),
                Vector3(-nime_arz * 0.965, y_paeen + 0.07, z),
                Vector3(-nime_arz * 0.78, y_paeen, z),
        ]

func _halqeh_kabin(z: float, y_paye: float, nime_arz: float, y_taj: float) -> Array:
        # مقطع اتاقک شیشه‌ای — گنبد باریک‌شونده
        var vasat := (y_taj + y_paye) * 0.5
        return [
                Vector3(0.0, y_paye, z),
                Vector3(nime_arz, y_paye + 0.02, z),
                Vector3(nime_arz * 0.92, vasat, z),
                Vector3(0.0, y_taj, z),
                Vector3(-nime_arz * 0.92, vasat, z),
                Vector3(-nime_arz, y_paye + 0.02, z),
        ]

func _loft_bede(st: SurfaceTool, halqeha: Array, sar_bastan := true) -> void:
        # دوختن حلقه‌های پشت‌سرهم — سیلوئت صاف و پیوسته
        for k in range(halqeha.size() - 1):
                var a: Array = halqeha[k]
                var b: Array = halqeha[k + 1]
                for j in range(a.size()):
                        var j2 := (j + 1) % a.size()
                        st.add_vertex(a[j]); st.add_vertex(a[j2]); st.add_vertex(b[j2])
                        st.add_vertex(a[j]); st.add_vertex(b[j2]); st.add_vertex(b[j])
        if sar_bastan:
                for idx in [0, halqeha.size() - 1]:
                        var h: Array = halqeha[idx]
                        var m := Vector3.ZERO
                        for p in h:
                                m += p
                        m /= h.size()
                        for j in range(h.size()):
                                var j2 := (j + 1) % h.size()
                                if idx == 0:
                                        st.add_vertex(m); st.add_vertex(h[j2]); st.add_vertex(h[j])
                                else:
                                        st.add_vertex(m); st.add_vertex(h[j]); st.add_vertex(h[j2])

func _mashin_besaz(rang: Color, kind := "sport", with_driver := false) -> Dictionary:
        var rishe := Node3D.new()
        var pm := _mate_rang(rang)
        var shishe := StandardMaterial3D.new()
        # شیشه‌ی دودی — کمی روشن‌تر که آسمون روش بشینه، نه سیاه‌قلم
        shishe.albedo_color = Color(0.075, 0.10, 0.14)
        shishe.roughness = 0.05
        shishe.metallic = 0.85
        var tir := _mate_tir(Color(0.10, 0.10, 0.11), 0.85)     # پلاستیک مشکی
        var laki := _mate_rang(rang)                            # تکه‌های رنگ‌بدنه
        var khoruj := {"root": rishe, "wheels": [], "front": [], "paint": pm}

        # ── بدنه‌ی اصلی: کوپه‌ی کلاسیک — کاپوت بلند، کابین عقب‌کشیده، دم باریک ──
        var istgahha := [
                [-2.18, 0.32, 0.70, 0.58, 0.78],   # دم باریک (kammback)
                [-1.95, 0.26, 0.76, 0.70, 0.86],   # شانه‌ی عقب
                [-1.45, 0.25, 0.78, 0.80, 0.88],
                [-0.95, 0.24, 0.78, 0.81, 0.86],   # دک صندوق
                [-0.35, 0.24, 0.76, 0.80, 0.84],
                [ 0.30, 0.24, 0.74, 0.80, 0.80],
                [ 0.90, 0.24, 0.72, 0.81, 0.76],   # شانه‌ی کاپوت
                [ 1.50, 0.25, 0.70, 0.78, 0.72],
                [ 1.95, 0.27, 0.68, 0.72, 0.68],
                [ 2.20, 0.31, 0.66, 0.62, 0.64],   # نوک پوزه
        ]
        var halqeha := []
        for s in istgahha:
                halqeha.append(_halqeh_badane(s[0], s[1], s[2], s[3], s[4]))
        var st := SurfaceTool.new()
        st.begin(Mesh.PRIMITIVE_TRIANGLES)
        _loft_bede(st, halqeha)
        st.generate_normals()
        var badane := MeshInstance3D.new()
        badane.mesh = st.commit()
        badane.material_override = pm
        rishe.add_child(badane)

        # ── اتاقک شیشه‌ای: گنبد عقب‌کشیده روی دک — سیلوئت کوپه ──
        var kabin_ist := [
                [-1.20, 0.85, 0.58, 0.90],
                [-0.65, 0.83, 0.54, 1.16],
                [-0.05, 0.82, 0.51, 1.24],
                [ 0.50, 0.81, 0.50, 1.10],
                [ 1.02, 0.79, 0.49, 0.80],
        ]
        var halqeha_k := []
        for s2 in kabin_ist:
                halqeha_k.append(_halqeh_kabin(s2[0], s2[1], s2[2], s2[3]))
        var st2 := SurfaceTool.new()
        st2.begin(Mesh.PRIMITIVE_TRIANGLES)
        _loft_bede(st2, halqeha_k)
        st2.generate_normals()
        var kabin := MeshInstance3D.new()
        kabin.mesh = st2.commit()
        kabin.material_override = shishe
        rishe.add_child(kabin)
        # سقف رنگ‌بدنه روی گنبد شیشه — مثل ماشین واقعی
        _qute(rishe, Vector3(0.94, 0.05, 0.90), Vector3(0, 1.25, -0.05), laki)

        # ── جزئیات جلو: اسپلیتر + جلوپنجره + چراغ ──
        _qute(rishe, Vector3(1.46, 0.06, 0.30), Vector3(0, 0.225, 2.16), tir)
        _qute(rishe, Vector3(0.90, 0.16, 0.05), Vector3(0, 0.56, 2.13), tir)
        var hlm := StandardMaterial3D.new()
        hlm.albedo_color = Color(1.0, 0.97, 0.85)
        hlm.emission_enabled = true
        hlm.emission = Color(1.0, 0.95, 0.75)
        hlm.emission_energy_multiplier = 1.7
        var tlm := StandardMaterial3D.new()
        tlm.albedo_color = Color(0.65, 0.04, 0.04)
        tlm.emission_enabled = true
        tlm.emission = Color(0.95, 0.06, 0.04)
        tlm.emission_energy_multiplier = 1.4
        for sx in [-0.44, 0.44]:
                _qute(rishe, Vector3(0.36, 0.10, 0.05), Vector3(sx, 0.56, 2.135), hlm)
        # ── عقب: سپر + نوار چراغ عقب تمام‌عرض + پلاک + اگزوز ──
        _qute(rishe, Vector3(1.08, 0.20, 0.20), Vector3(0, 0.30, -2.10), tir)
        _qute(rishe, Vector3(1.24, 0.09, 0.045), Vector3(0, 0.72, -2.105), tlm)
        _qute(rishe, Vector3(0.38, 0.12, 0.03), Vector3(0, 0.46, -2.19), _mate_tir(Color(0.85, 0.85, 0.80), 0.5))
        var egzoz := CylinderMesh.new()
        egzoz.top_radius = 0.045
        egzoz.bottom_radius = 0.045
        egzoz.height = 0.18
        egzoz.radial_segments = 8
        var egi := MeshInstance3D.new()
        egi.mesh = egzoz
        egi.material_override = _mate_tir(Color(0.62, 0.63, 0.66), 0.35)
        egi.rotation_degrees = Vector3(90, 0, 0)
        egi.position = Vector3(0.40, 0.26, -2.13)
        rishe.add_child(egi)
        # ── اسپویلر اردک‌دمی چسبیده به عقب — نه قفسه‌ی معلق ──
        _qute(rishe, Vector3(1.34, 0.05, 0.30), Vector3(0, 0.905, -1.99), laki)
        _qute(rishe, Vector3(0.05, 0.09, 0.22), Vector3(0.58, 0.875, -2.01), tir)
        _qute(rishe, Vector3(0.05, 0.09, 0.22), Vector3(-0.58, 0.875, -2.01), tir)
        # ── دامن جانبی + آینه‌ها ──
        _qute(rishe, Vector3(0.05, 0.09, 1.90), Vector3(0.875, 0.235, 0), tir)
        _qute(rishe, Vector3(0.05, 0.09, 1.90), Vector3(-0.875, 0.235, 0), tir)
        _qute(rishe, Vector3(0.16, 0.06, 0.10), Vector3(0.90, 0.86, 0.72), laki)
        _qute(rishe, Vector3(0.16, 0.06, 0.10), Vector3(-0.90, 0.86, 0.72), laki)
        # ── هود اسکوپ — چسبیده به کاپوتِ پایین‌آمده ──
        _qute(rishe, Vector3(0.55, 0.05, 0.42), Vector3(0, 0.735, 1.42), tir, Vector3(-6, 0, 0))
        # دهانه‌های هوا در پوزه — نفس‌کشیدن اسپرت
        _qute(rishe, Vector3(0.34, 0.11, 0.04), Vector3(0.34, 0.42, 2.155), tir)
        _qute(rishe, Vector3(0.34, 0.11, 0.04), Vector3(-0.34, 0.42, 2.155), tir)
        # ── راه‌راه دریفت روی سقف و دک — سبک ماشین‌های دریفت ایرانی ──
        var ragh := _mate_tir(Color(0.10, 0.10, 0.11), 0.4)
        _qute(rishe, Vector3(0.09, 0.012, 0.92), Vector3(0.16, 1.282, -0.08), ragh)
        _qute(rishe, Vector3(0.09, 0.012, 0.92), Vector3(-0.16, 1.282, -0.08), ragh)
        _qute(rishe, Vector3(0.09, 0.012, 0.62), Vector3(0.15, 0.895, -1.74), ragh, Vector3(-7, 0, 0))
        _qute(rishe, Vector3(0.09, 0.012, 0.62), Vector3(-0.15, 0.895, -1.74), ragh, Vector3(-7, 0, 0))

        # ── راننده — هلیا با مقنعه، از شیشه‌ی دودی پیداست ──
        if with_driver:
                var ranande := Node3D.new()
                rishe.add_child(ranande)
                ranande.position = Vector3(0, 0.58, 0.30)
                var sar := SphereMesh.new()
                sar.radius = 0.125
                sar.height = 0.25
                var hm2 := MeshInstance3D.new()
                hm2.mesh = sar
                hm2.material_override = _mate_tir(Color(0.85, 0.62, 0.48))
                hm2.position = Vector3(0, 0.16, 0)
                ranande.add_child(hm2)
                var mag := SphereMesh.new()
                mag.radius = 0.165
                mag.height = 0.33
                var gm2 := MeshInstance3D.new()
                gm2.mesh = mag
                gm2.material_override = _mate_tir(Color(0.16, 0.28, 0.32))
                gm2.position = Vector3(0, 0.10, 0.04)
                ranande.add_child(gm2)
                _qute(ranande, Vector3(0.40, 0.20, 0.18), Vector3(0, -0.10, 0), _mate_tir(Color(0.25, 0.32, 0.38)))

        # ── چرخ‌ها: لاستیک توری + رینگ پنج‌پره + دیسک و کالیپر ترمز ──
        var wr := 0.34
        var lastik_tori := TorusMesh.new()
        lastik_tori.inner_radius = 0.150
        lastik_tori.outer_radius = 0.345
        lastik_tori.rings = 22
        lastik_tori.ring_segments = 12
        var wmat2 := _mate_tir(Color(0.065, 0.065, 0.07), 0.92)
        lastik_tori.material = wmat2
        var ring := CylinderMesh.new()
        ring.top_radius = 0.175
        ring.bottom_radius = 0.175
        ring.height = 0.15
        ring.radial_segments = 16
        ring.material = _mate_tir(Color(0.62, 0.64, 0.68), 0.22)
        var hub := CylinderMesh.new()
        hub.top_radius = 0.055
        hub.bottom_radius = 0.055
        hub.height = 0.17
        hub.radial_segments = 10
        hub.material = _mate_tir(Color(0.18, 0.18, 0.20), 0.5)
        # دیسک ترمز و کالیپر — از لای لایه‌های رینگ پیداست
        var disk := CylinderMesh.new()
        disk.top_radius = 0.20
        disk.bottom_radius = 0.20
        disk.height = 0.04
        disk.radial_segments = 14
        disk.material = _mate_tir(Color(0.45, 0.44, 0.43), 0.45)
        var kaliper := BoxMesh.new()
        kaliper.size = Vector3(0.05, 0.12, 0.09)
        var kmat := _mate_tir(Color(0.72, 0.08, 0.06), 0.45)
        # لاینر تیره‌ی گلگیر — حلقه‌ی سایه‌مانند پشت چرخ
        var liner := CylinderMesh.new()
        liner.top_radius = 0.41
        liner.bottom_radius = 0.41
        liner.height = 0.14
        liner.radial_segments = 12
        liner.material = _mate_tir(Color(0.045, 0.045, 0.05), 0.95)
        for wp in [Vector3(0.80, wr, 1.45), Vector3(-0.80, wr, 1.45), Vector3(0.80, wr, -1.45), Vector3(-0.80, wr, -1.45)]:
                var wh := Node3D.new()
                rishe.add_child(wh)
                wh.position = wp
                var lin := MeshInstance3D.new()
                lin.mesh = liner
                lin.rotation_degrees = Vector3(0, 0, 90)
                lin.position = Vector3(-signf(wp.x) * 0.055, 0.05, 0)
                rishe.add_child(lin)
                var lastik := MeshInstance3D.new()
                lastik.mesh = lastik_tori
                lastik.material_override = wmat2
                lastik.rotation_degrees = Vector3(0, 0, 90)
                wh.add_child(lastik)
                var ring2 := MeshInstance3D.new()
                ring2.mesh = ring
                ring2.rotation_degrees = Vector3(0, 0, 90)
                wh.add_child(ring2)
                # پنج پره — هر پره یک جعبه‌ی باریک چرخیده دور محور
                for p in 5:
                        var gooshe := p * TAU / 5.0
                        var pare := MeshInstance3D.new()
                        var bm2 := BoxMesh.new()
                        bm2.size = Vector3(0.16, 0.135, 0.042)
                        bm2.material = _mate_tir(Color(0.56, 0.58, 0.62), 0.28)
                        pare.mesh = bm2
                        pare.position = Vector3(0, cos(gooshe) * 0.10, sin(gooshe) * 0.10)
                        pare.rotation.x = -gooshe
                        wh.add_child(pare)
                var disk2 := MeshInstance3D.new()
                disk2.mesh = disk
                disk2.rotation_degrees = Vector3(0, 0, 90)
                disk2.position = Vector3(-signf(wp.x) * 0.03, 0, 0)
                wh.add_child(disk2)
                var kal := MeshInstance3D.new()
                kal.mesh = kaliper
                kal.material_override = kmat
                kal.position = Vector3(-signf(wp.x) * 0.05, 0.16, 0.12 if wp.z > 0 else -0.12)
                wh.add_child(kal)
                var hub2 := MeshInstance3D.new()
                hub2.mesh = hub
                hub2.rotation_degrees = Vector3(0, 0, 90)
                wh.add_child(hub2)
                khoruj["wheels"].append(wh)
                if wp.z > 0:
                        khoruj["front"].append(wh)
        # ── شعله اگزوز نیترو ──
        var shole := MeshInstance3D.new()
        var makute := CylinderMesh.new()
        makute.top_radius = 0.02
        makute.bottom_radius = 0.14
        makute.height = 0.9
        makute.radial_segments = 6
        var fm := StandardMaterial3D.new()
        fm.albedo_color = Color(1.0, 0.6, 0.15)
        fm.emission_enabled = true
        fm.emission = Color(1.0, 0.55, 0.1)
        fm.emission_energy_multiplier = 2.2
        shole.mesh = makute
        shole.material_override = fm
        shole.rotation_degrees = Vector3(-90, 0, 0)
        shole.position = Vector3(0.40, 0.26, -2.35)
        shole.visible = false
        rishe.add_child(shole)
        khoruj["flame"] = shole
        return khoruj

# ═══════════════════ اسپان ماشین‌ها ═══════════════════
const RANG_RAQIBHA := [Color(0.85, 0.20, 0.16), Color(0.16, 0.42, 0.85), Color(0.92, 0.75, 0.15)]
const ESME_RAQIBHA := ["آرش", "سینا", "رِضا"]

func _mashin_bepar() -> void:
        var ci := clampi(Koli.mashin_entekhabi, 0, Koli.MASHINHA.size() - 1)
        # رنگ سه‌بعدی از همان رنگ تعریف‌شده‌ی هر ماشین در فهرست
        var rang: Color = Color(str(Koli.MASHINHA[ci].get("rang", "#c8141e")))
        var pc := _mashin_besaz(rang, "sport", true)
        mashin = pc["root"]
        lastikha = pc["wheels"]
        lastikaye_jelo = pc["front"]
        shole_mashin = pc["flame"]
        mate_badane = pc["paint"]
        add_child(mashin)
        ja = NEMOONEHA[0]
        semat = atan2(MAMASHA[0].x, MAMASHA[0].z)
        mashin.position = ja
        mashin.rotation.y = semat
        _saye_zir(mashin)
        mashin.add_child(_cheraghe_jelo())
        # دود لاستیک
        dood = CPUParticles3D.new()
        dood.amount = 40
        dood.lifetime = 0.7
        dood.emitting = false
        dood.mesh = _mostati_dood()
        dood.direction = Vector3(0, 1, 0)
        dood.spread = 30.0
        dood.initial_velocity_min = 0.6
        dood.initial_velocity_max = 1.6
        dood.gravity = Vector3(0, 1.2, 0)
        dood.scale_amount_min = 0.5
        dood.scale_amount_max = 1.4
        dood.position = Vector3(0, 0.25, -1.6)
        mashin.add_child(dood)
        # رقیب‌ها — جلوی بازیکن گرید می‌شوند (سبک NFS)
        for r in 3:
                var rr := _mashin_besaz(RANG_RAQIBHA[r % RANG_RAQIBHA.size()], "sport", false)
                add_child(rr["root"])
                _saye_zir(rr["root"])
                raqibha.append({"root": rr["root"], "wheels": rr["wheels"], "s": 10.0 + 6.0 * r,
                        "lat": (2.6 if r % 2 == 0 else -2.6), "vf": 0.0,
                        "skill": float(tarjome["skill"]) * (1.0 - 0.045 * r),
                        "name": ESME_RAQIBHA[r % ESME_RAQIBHA.size()], "fin": -1.0})
        # رد لاستیک
        meshe_jigh = ImmediateMesh.new()
        var smi := MeshInstance3D.new()
        smi.mesh = meshe_jigh
        var skm := StandardMaterial3D.new()
        skm.albedo_color = Color(0.06, 0.06, 0.06, 0.75)
        skm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        skm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        mate_jigh = skm   # بعد از اولین سطح اعمال می‌شود — روی مش خالی خطا می‌دهد
        add_child(smi)

func _mostati_dood() -> Mesh:
        var qm := QuadMesh.new()
        qm.size = Vector2(0.7, 0.7)
        var smat := StandardMaterial3D.new()
        smat.albedo_color = Color(0.82, 0.82, 0.82, 0.5)
        smat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        smat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
        qm.material = smat
        return qm

# ── سایه‌ی تماس زیر ماشین — بدون این، ماشین «شناور» دیده می‌شود ──
var bafte_saye: ImageTexture = null

func _bafte_saye_zir() -> ImageTexture:
        if bafte_saye != null:
                return bafte_saye
        var aks := Image.create(128, 64, false, Image.FORMAT_RGBA8)
        for y in 64:
                for x in 128:
                        var u := (x - 64.0) / 58.0
                        var v := (y - 32.0) / 27.0
                        var d := u * u + v * v
                        var alfa := clampf(1.0 - d, 0.0, 1.0)
                        aks.set_pixel(x, y, Color(0.02, 0.02, 0.03, alfa * alfa * 0.66))
        bafte_saye = ImageTexture.create_from_image(aks)
        return bafte_saye

func _saye_zir(rishe: Node3D) -> void:
        var q := QuadMesh.new()
        q.size = Vector2(2.7, 5.1)
        var m := StandardMaterial3D.new()
        m.albedo_texture = _bafte_saye_zir()
        m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        q.material = m
        var mi := MeshInstance3D.new()
        mi.mesh = q
        mi.rotation_degrees = Vector3(-90, 0, 0)
        mi.position = Vector3(0, 0.028, 0)
        mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
        rishe.add_child(mi)

# ── ماشین‌های پارک‌شده‌ی خیابانی — سیلوئت ساده، روح شهر ──
func _mashin_sade(rang: Color) -> Node3D:
        var rishe := Node3D.new()
        var pm := _mate_rang(rang, 0.35)
        var ist := [
                [-2.05, 0.30, 0.74, 0.70, 0.86],
                [-1.55, 0.25, 0.80, 0.82, 0.94],
                [-0.60, 0.24, 0.80, 0.84, 0.94],
                [ 0.50, 0.24, 0.78, 0.82, 0.90],
                [ 1.40, 0.25, 0.74, 0.78, 0.78],
                [ 2.05, 0.29, 0.70, 0.68, 0.70],
        ]
        var halqeha := []
        for s in ist:
                halqeha.append(_halqeh_badane(s[0], s[1], s[2], s[3], s[4]))
        var st := SurfaceTool.new()
        st.begin(Mesh.PRIMITIVE_TRIANGLES)
        _loft_bede(st, halqeha)
        st.generate_normals()
        var badane := MeshInstance3D.new()
        badane.mesh = st.commit()
        badane.material_override = pm
        rishe.add_child(badane)
        var kist := [[-0.90, 0.86, 0.60, 0.98], [-0.20, 0.84, 0.56, 1.24], [0.45, 0.82, 0.53, 1.10], [0.95, 0.79, 0.50, 0.84]]
        var hk := []
        for s2 in kist:
                hk.append(_halqeh_kabin(s2[0], s2[1], s2[2], s2[3]))
        var st2 := SurfaceTool.new()
        st2.begin(Mesh.PRIMITIVE_TRIANGLES)
        _loft_bede(st2, hk)
        st2.generate_normals()
        var kabin := MeshInstance3D.new()
        kabin.mesh = st2.commit()
        kabin.material_override = _mate_tir(Color(0.05, 0.07, 0.10), 0.18)
        rishe.add_child(kabin)
        var tori := TorusMesh.new()
        tori.inner_radius = 0.15
        tori.outer_radius = 0.33
        tori.rings = 14
        tori.ring_segments = 8
        var tm := _mate_tir(Color(0.08, 0.08, 0.085), 0.9)
        var dic := CylinderMesh.new()
        dic.top_radius = 0.16
        dic.bottom_radius = 0.16
        dic.height = 0.13
        dic.radial_segments = 10
        dic.material = _mate_tir(Color(0.35, 0.36, 0.38), 0.5)
        for wp in [Vector3(0.78, 0.33, 1.38), Vector3(-0.78, 0.33, 1.38), Vector3(0.78, 0.33, -1.38), Vector3(-0.78, 0.33, -1.38)]:
                var wh := Node3D.new()
                wh.position = wp
                rishe.add_child(wh)
                var t1 := MeshInstance3D.new()
                t1.mesh = tori
                t1.material_override = tm
                t1.rotation_degrees = Vector3(0, 0, 90)
                wh.add_child(t1)
                var d1 := MeshInstance3D.new()
                d1.mesh = dic
                d1.rotation_degrees = Vector3(0, 0, 90)
                wh.add_child(d1)
        _saye_zir(rishe)
        return rishe

func _mashinha_park(tasadof: RandomNumberGenerator) -> void:
        var h: float = tarjome["half"]
        var rangha := [Color(0.88, 0.88, 0.90), Color(0.72, 0.73, 0.75), Color(0.16, 0.17, 0.19),
                Color(0.30, 0.34, 0.40), Color(0.55, 0.56, 0.58), Color(0.45, 0.22, 0.18), Color(0.24, 0.34, 0.24)]
        var shomare := 0
        var i := 20
        while i < NEMOONE_N - 20:
                if tasadof.randf() < 0.40:
                        i += 14
                        shomare += 1
                        continue
                var kenar := 1.0 if shomare % 2 == 0 else -1.0
                var pi: int = (i + tasadof.randi() % 6) % NEMOONE_N
                var pp: Vector3 = NEMOONEHA[pi] + NORMLHA[pi] * kenar * (h + 1.95)
                if _kamtarin_fasele(pp) < h + 1.2:
                        i += 14
                        shomare += 1
                        continue
                var mc := _mashin_sade(rangha[tasadof.randi() % rangha.size()])
                mc.position = Vector3(pp.x, 0.12, pp.z)  # روی پیاده‌رو می‌ایستد
                mc.rotation.y = atan2(MAMASHA[pi].x, MAMASHA[pi].z) + (PI if tasadof.randf() < 0.4 else 0.0)
                add_child(mc)
                _khane_efe(pp.x, pp.z, 1.3)
                shomare += 1
                i += 14

func _cheraghe_jelo() -> Node3D:
        var n := Node3D.new()
        var mashal := SpotLight3D.new()
        mashal.light_color = Color(1.0, 0.95, 0.8)
        mashal.spot_range = 24.0
        mashal.spot_angle = 36.0
        mashal.light_energy = 0.8
        mashal.position = Vector3(0, 0.7, 2.2)
        n.add_child(mashal)
        return n

# ═══════════════════ فیزیک بازیکن — قلب دریفت ═══════════════════
func _hasteye_fizik(dt: float) -> void:
        var gaz: float = 0.0 if paye_termoz else paye_gaz
        if halat != "race":
                gaz = 0.0
        var ci := clampi(Koli.mashin_entekhabi, 0, Koli.MASHINHA.size() - 1)
        var tarhe_mashin: Dictionary = Koli.MASHINHA[ci]
        var shetab := 13.0 * float(tarhe_mashin.get("accel", 1.0))
        var bala := 44.0 + 2.0 * float(tarhe_mashin.get("jump", 1.0))
        if nitro_rushan and nitro > 0.0 and halat == "race":
                shetab += 9.0
                bala += 11.0
        if dasti:
                gaz *= 0.35
        var tavan := shetab * (1.0 - pow(clampf(v_jelo / bala, 0.0, 1.0), 2.2))
        v_jelo += tavan * gaz * dt
        if paye_termoz:
                v_jelo -= 24.0 * dt
                if v_jelo < -9.0:
                        v_jelo = -9.0
        v_jelo -= (0.4 + 0.0125 * absf(v_jelo)) * dt * signf(v_jelo)
        if dasti:
                v_jelo -= 5.5 * dt * signf(v_jelo)
        # فرمان حساس به سرعت
        var hade_ferman := 0.62 / (1.0 + absf(v_jelo) * 0.05)
        ferman = lerpf(ferman, mizane_ferman * hade_ferman, 1.0 - exp(-9.0 * dt))
        # سقف شتاب جانبی = گریپ؛ با دستی آزادتر → دریفت
        var shetab_bish := 16.5 if dasti else 11.5
        var enheraf := (v_jelo / 2.6) * tan(ferman)
        var hade_enheraf := shetab_bish / maxf(absf(v_jelo), 4.0)
        enheraf = clampf(enheraf, -hade_enheraf, hade_enheraf)
        semat += enheraf * dt * (1.0 if v_jelo >= 0.0 else -1.0)
        # پروجکشن سرعت روی محور جدید — قلب دریفت واقعی
        var jelo := Vector3(sin(semat), 0.0, cos(semat))
        var kenar := Vector3(jelo.z, 0.0, -jelo.x)
        var sorat := jelo * v_jelo + kenar * v_janebi
        v_jelo = sorat.dot(jelo)
        v_janebi = sorat.dot(kenar)
        var chasp := 1.7 if dasti else 7.0
        v_janebi *= exp(-chasp * dt)
        ja += (jelo * v_jelo + kenar * v_janebi) * dt
        ja.y = 0.0
        var liz := absf(v_janebi)
        dar_darift = liz > 3.2 and absf(v_jelo) > 7.0
        if dar_darift and halat == "race":
                zanjire_darift += liz * dt
                nitro = clampf(nitro + liz * dt * 0.022, 0.0, 1.0)
                if zanjire_darift > 30.0:
                        emtiaze_darift += 25
                        zanjire_darift = 0.0
                        _jaeze_darift()
        else:
                zanjire_darift = maxf(0.0, zanjire_darift - dt * 20.0)
        # نیترو
        if nitro_rushan and nitro > 0.0 and halat == "race":
                nitro = maxf(0.0, nitro - dt * 0.22)
                shole_mashin.visible = true
                larze = maxf(larze, 0.10)
        else:
                shole_mashin.visible = false
                if nitro <= 0.0:
                        nitro_rushan = false
        # مسیر
        sh = _naztarin(ja, sh)
        var janebi := _janebi(ja, sh)
        s_hala = TOOL_JAM[sh]
        var h: float = tarjome["half"]
        var al := absf(janebi)
        if al > h - 0.55 and al <= h + 2.2:
                v_jelo *= 1.0 - 1.6 * dt
                larze = maxf(larze, 0.08)
        elif al > h + 2.2:
                var hale := (h + 2.4 - al) * signf(janebi)
                ja += NORMLHA[sh] * hale
                v_jelo *= 1.0 - 3.0 * dt
                larze = maxf(larze, 0.25)
        _saktha_tasadom(dt)
        # دور
        var pishraft_qabli := pishraft
        pishraft = float(dour) * toole_masir + s_hala
        if pishraft_qabli > toole_masir * 0.7 and s_hala < toole_masir * 0.12 and halat == "race":
                dour += 1
                print("[tizpa][race] LAP ", dour, "/", tarjome["laps"])
                A.sfx_baz("lap")
                if dour >= int(tarjome["laps"]):
                        _payane_mosabeqe()
        # مسیر اشتباه
        var zarb_jelo: float = jelo.dot(MAMASHA[sh])
        if zarb_jelo < -0.35 and v_jelo > 4.0:
                rah_e_ghalat += dt
        else:
                rah_e_ghalat = 0.0
        _neshaneye_jigh(dt)
        mashin.position = ja
        mashin.rotation.y = semat
        for w in lastikha:
                w.rotation.x -= v_jelo * dt / 0.34
        for w in lastikaye_jelo:
                w.rotation.y = ferman * 0.9
        dood.emitting = dar_darift
        A.motor_bede(halat != "panel", clampf(absf(v_jelo) / 46.0, 0.0, 1.0))
        A.jigh_bede(dar_darift, clampf(liz / 8.0, 0.0, 1.0))

func _saktha_tasadom(dt: float) -> void:
        seyest = maxf(0.0, seyest - dt)
        for id in _saktha_nazdik(ja):
                var s: Dictionary = saktha[id]
                var dx := ja.x - float(s["x"])
                var dz := ja.z - float(s["z"])
                var rr := float(s["r"]) + 1.25
                var d2 := dx * dx + dz * dz
                if d2 < rr * rr and d2 > 0.0001:
                        var d := sqrt(d2)
                        ja.x = float(s["x"]) + dx / d * rr
                        ja.z = float(s["z"]) + dz / d * rr
                        if seyest <= 0.0 and absf(v_jelo) > 6.0:
                                A.sfx_baz("clank")
                                larze = 0.5
                                seyest = 0.7
                        v_jelo *= 0.55
                        v_janebi = 0.0
                        break

func _neshaneye_jigh(dt: float) -> void:
        if not dar_darift:
                for liste in noghate_jigh:
                        if liste.size() > 0:
                                liste.clear()
                return
        var jelo := Vector3(sin(semat), 0.0, cos(semat))
        var kenar := Vector3(jelo.z, 0.0, -jelo.x)
        for k in 2:
                var sx := 0.82 if k == 0 else -0.82
                var wp := ja + kenar * sx - jelo * 1.42 + Vector3.UP * 0.03
                var liste: Array = noghate_jigh[k]
                liste.append([wp.x, wp.z])
                if liste.size() > HADDE_JIGH:
                        liste.pop_front()
        _keshidan_jigh()

func _keshidan_jigh() -> void:
        meshe_jigh.clear_surfaces()
        meshe_jigh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
        for liste in noghate_jigh:
                var n: int = liste.size()
                if n < 2:
                        continue
                var rangi := Color(0.07, 0.07, 0.07, 0.7)
                for i in range(1, n):
                        var a: Array = liste[i - 1]
                        var b: Array = liste[i]
                        var dv := Vector3(float(b[0]) - float(a[0]), 0.0, float(b[1]) - float(a[1]))
                        if dv.length() > 2.5:
                                continue
                        var sd := Vector3(dv.z, 0.0, -dv.x).normalized() * 0.11
                        var av := Vector3(float(a[0]), 0.035, float(a[1]))
                        var bv := Vector3(float(b[0]), 0.035, float(b[1]))
                        meshe_jigh.surface_set_color(rangi)
                        meshe_jigh.surface_add_vertex(av - sd)
                        meshe_jigh.surface_set_color(rangi)
                        meshe_jigh.surface_add_vertex(av + sd)
                        meshe_jigh.surface_set_color(rangi)
                        meshe_jigh.surface_add_vertex(bv + sd)
                        meshe_jigh.surface_set_color(rangi)
                        meshe_jigh.surface_add_vertex(av - sd)
                        meshe_jigh.surface_set_color(rangi)
                        meshe_jigh.surface_add_vertex(bv + sd)
                        meshe_jigh.surface_set_color(rangi)
                        meshe_jigh.surface_add_vertex(bv - sd)
        meshe_jigh.surface_end()
        if meshe_jigh.get_surface_count() > 0 and mate_jigh != null:
                meshe_jigh.surface_set_material(0, mate_jigh)

# ═══════════════════ دوربین تعقیبی — قلب NFS ═══════════════════
func _hasteye_dorbin(dt: float) -> void:
        if dorbin == null:
                dorbin = Camera3D.new()
                dorbin.fov = 72.0
                dorbin.near = 0.2
                dorbin.far = 2600.0
                add_child(dorbin)
                dorbin.make_current()
        var jelo := Vector3(sin(semat), 0.0, cos(semat))
        var kenar := Vector3(jelo.z, 0.0, -jelo.x)
        var fasele := 5.2 + absf(v_jelo) * 0.045
        var erteza := 2.1 + absf(v_jelo) * 0.010
        # نیترو: دوربین می‌خوابد و کمی عقب‌تر — حالت هجومی
        if nitro_rushan and nitro > 0.0:
                fasele += 0.35
                erteza -= 0.30
        var hadaf := ja - jelo * fasele + Vector3.UP * erteza
        if larze > 0.0:
                larze = maxf(0.0, larze - dt * 1.6)
                hadaf += Vector3(randf_range(-1, 1), randf_range(-0.5, 0.5), randf_range(-1, 1)) * larze * 0.5
        if halat == "count":
                var a := shomarvar * 1.6
                hadaf = ja + Vector3(sin(a) * 7.0, 2.6, cos(a) * 7.0)
        var k := 1.0 - exp(-6.5 * dt)
        if not dorbin_avalie:
                jaye_dorbin = hadaf
                negahe_dorbin = ja + jelo * 6.0 + Vector3.UP * 1.0
                dorbin_avalie = true
        jaye_dorbin = jaye_dorbin.lerp(hadaf, k)
        # نگاه کمی به سمتِ لیز خوردن بدنه — زاویه‌ی دریفت دیده می‌شود
        var nega_t := ja + jelo * 8.5 + Vector3.UP * 1.15 + kenar * clampf(v_janebi * 0.14, -1.6, 1.6)
        negahe_dorbin = negahe_dorbin.lerp(nega_t, 1.0 - exp(-8.0 * dt))
        dorbin.position = jaye_dorbin
        dorbin.look_at(negahe_dorbin, Vector3.UP)
        # خم‌شدن دوربین داخل پیچ — دریفت زیر گوش روح بازی را می‌گیرد
        ghame_dorbin = lerpf(ghame_dorbin, clampf(-v_janebi * 0.0045, -0.055, 0.055), 1.0 - exp(-4.0 * dt))
        dorbin.rotate_object_local(Vector3(0, 0, 1), ghame_dorbin)
        var zavie_hadaf := 68.0 + (18.0 if nitro_rushan and nitro > 0.0 else 0.0) + absf(v_jelo) * 0.12
        zavie_dorbin = lerpf(zavie_dorbin, zavie_hadaf, 1.0 - exp(-5.0 * dt))
        dorbin.fov = zavie_dorbin
        if javane_khat != null:
                # خطوط تندباد فقط در سرعت بالا — پایین آوردن آستانه، کل کادر را آشغال می‌کند
                var tond := clampf((absf(v_jelo) - 38.0) / 22.0, 0.0, 0.6)
                if nitro_rushan and nitro > 0.0:
                        tond = maxf(tond, 0.85)
                javane_khat.set_shader_parameter("tavan", tond)

func _jaeze_darift() -> void:
        if matne_darift:
                matne_darift.text = "+۲۵ دریفت!"
                matne_darift.modulate.a = 1.0
                var tw := create_tween()
                tw.tween_property(matne_darift, "modulate:a", 0.0, 1.2)

# ═══════════════════ رقیب‌ها و ترافیک ═══════════════════
func _nemone_dar(s: float) -> int:
        var i := int(s / toole_masir * NEMOONE_N) % NEMOONE_N
        return clampi(i, 0, NEMOONE_N - 1)

func _donya_dar(s: float, janebi: float) -> Vector3:
        var i := _nemone_dar(fposmod(s, toole_masir))
        return NEMOONEHA[i] + NORMLHA[i] * janebi

func _hasteye_raqibha(dt: float) -> void:
        var sh_tamamshode := 0
        for rv in raqibha:
                # سرعت هدف از پیچِ پیش‌رو + مهارت + کش‌وسان
                var nega_s := fposmod(float(rv["s"]) + 16.0 + float(rv["vf"]) * 0.7, toole_masir)
                var li := _nemone_dar(nega_s)
                var kaji := 1.0 - clampf(absf(MAMASHA[li].angle_to(MAMASHA[_nemone_dar(fposmod(nega_s + 30.0, toole_masir))])) * 1.6, 0.0, 0.72)
                var rb := 1.0
                var sheyaf := pishraft - (float(rv["s"]))
                if sheyaf > 70.0:
                        rb = 1.10
                elif sheyaf < -60.0:
                        rb = 0.90
                var shoae_bala := (40.0 + 6.0 * float(rv["skill"])) * kaji * float(rv["skill"]) * rb
                rv["vf"] = move_toward(float(rv["vf"]), shoae_bala, 14.0 * dt)
                rv["s"] = fposmod(float(rv["s"]) + float(rv["vf"]) * dt, toole_masir * 8.0)
                var w := _donya_dar(float(rv["s"]), float(rv["lat"]))
                var rishe: Node3D = rv["root"]
                rishe.position = w
                var i2 := _nemone_dar(float(rv["s"]))
                if float(rv["vf"]) > 0.5:
                        rishe.rotation.y = atan2(MAMASHA[i2].x, MAMASHA[i2].z)
                for wh in rv["wheels"]:
                        wh.rotation.x -= float(rv["vf"]) * dt / 0.34
        # جایگاه
        jaye_payan = 1
        for rv in raqibha:
                if float(rv["s"]) > pishraft:
                        jaye_payan += 1

# ═══════════════════ جریان مسابقه ═══════════════════
func _payane_mosabeqe() -> void:
        if tamaam_shod:
                return
        tamaam_shod = true
        halat = "finish"
        # جایگاه نهایی
        jaye_payan = 1
        for rv in raqibha:
                if float(rv["s"]) > pishraft:
                        jaye_payan += 1
        A.sfx_baz("win" if jaye_payan <= 3 else "fail")
        var setareha := 3 if jaye_payan == 1 else (2 if jaye_payan == 2 else (1 if jaye_payan == 3 else 0))
        Koli.setare_bede(int(tarjome["id"]), setareha)
        var jaeze := int(tarjome["reward"]) + (int(tarjome["reward"]) / 2 if jaye_payan == 1 else 0)
        Koli.pool_efe(jaeze)
        print("[tizpa][race] FINISH pos=", jaye_payan, " stars=", setareha, " time=", int(zamane_mosabeqe))
        get_tree().create_timer(1.4).timeout.connect(_panel_neshon)

func _panel_neshon() -> void:
        halat = "panel"
        A.motor_bede(false)
        var setareha := 3 if jaye_payan == 1 else (2 if jaye_payan == 2 else (1 if jaye_payan == 3 else 0))
        var p := PanelContainer.new()
        var sb := StyleBoxFlat.new()
        sb.bg_color = Color(0.10, 0.11, 0.15, 0.96)
        sb.set_corner_radius_all(22)
        sb.border_width_bottom = 3
        sb.border_color = Color(0.95, 0.76, 0.25)
        p.add_theme_stylebox_override("panel", sb)
        p.set_anchors_preset(Control.PRESET_CENTER)
        p.custom_minimum_size = Vector2(560, 460)
        p.position = Vector2(640 - 280, 360 - 230)
        var vb := VBoxContainer.new()
        vb.add_theme_constant_override("separation", 14)
        p.add_child(vb)
        var f := load("res://assets/fonts/Vazirmatn-Bold.ttf")
        var t := Label.new()
        t.text = "پایان مسابقه!"
        t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        t.add_theme_font_size_override("font_size", 40)
        t.add_theme_color_override("font_color", Color(0.95, 0.76, 0.25))
        if f != null:
                t.add_theme_font_override("font", f)
        vb.add_child(t)
        var st := Label.new()
        st.text = "★".repeat(setareha) + "☆".repeat(3 - setareha)
        st.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        st.add_theme_font_size_override("font_size", 52)
        st.add_theme_color_override("font_color", Color(0.95, 0.76, 0.25))
        vb.add_child(st)
        var etelaat := Label.new()
        var fa_d := str(jaye_payan)
        var mohu := ""
        for ch in fa_d:
                mohu += "۰۱۲۳۴۵۶۷۸۹"[int(ch)] if ch >= "0" and ch <= "9" else ch
        etelaat.text = "جایگاه: " + mohu + " — زمان: " + _zaman_fa(zamane_mosabeqe)
        etelaat.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        etelaat.add_theme_font_size_override("font_size", 26)
        if f != null:
                etelaat.add_theme_font_override("font", f)
        vb.add_child(etelaat)
        var hb := HBoxContainer.new()
        hb.alignment = BoxContainer.ALIGNMENT_CENTER
        hb.add_theme_constant_override("separation", 16)
        vb.add_child(hb)
        var sh_dakheli := int(tarjome["id"]) + 1
        if sh_dakheli <= 5:
                var dokme_badi := Button.new()
                dokme_badi.text = "مرحله بعد"
                dokme_badi.custom_minimum_size = Vector2(200, 74)
                _dokme_shekl(dokme_badi, "red")
                dokme_badi.pressed.connect(func():
                        Koli.set_meta("start_level", sh_dakheli)
                        get_tree().change_scene_to_file("res://scenes/game.tscn"))
                hb.add_child(dokme_badi)
        var dokme_dobare := Button.new()
        dokme_dobare.text = "دوباره"
        dokme_dobare.custom_minimum_size = Vector2(160, 74)
        _dokme_shekl(dokme_dobare, "dark")
        dokme_dobare.pressed.connect(func():
                Koli.set_meta("start_level", int(tarjome["id"]))
                get_tree().change_scene_to_file("res://scenes/game.tscn"))
        hb.add_child(dokme_dobare)
        var dokme_menu := Button.new()
        dokme_menu.text = "منو"
        dokme_menu.custom_minimum_size = Vector2(140, 74)
        _dokme_shekl(dokme_menu, "dark")
        dokme_menu.pressed.connect(func():
                # برای چرخه‌ی تست کامل: برگشت به منو باید علامت بخورد
                if arg_line.has("--autotest-full"):
                        Koli.set_meta("at_menu_return", true)
                get_tree().change_scene_to_file("res://scenes/menu.tscn"))
        hb.add_child(dokme_menu)
        $HUD.add_child(p)
        print("[tizpa][race] PANEL OK")

func _zaman_fa(t: float) -> String:
        var m := int(t) / 60
        var s := int(t) % 60
        var khoruj := ""
        for ch in (str(m) + ":" + ("%02d" % s)):
                khoruj += "۰۱۲۳۴۵۶۷۸۹"[int(ch)] if ch >= "0" and ch <= "9" else ch
        return khoruj

# ═══════════════════ HUD ═══════════════════
func _dokme_shekl(b: Button, kind := "red") -> void:
        var paszamine := Color(0.82, 0.18, 0.15) if kind == "red" else Color(0.16, 0.17, 0.22)
        var sb := StyleBoxFlat.new()
        sb.bg_color = paszamine
        sb.set_corner_radius_all(16)
        sb.border_width_bottom = 3
        sb.border_color = paszamine.darkened(0.35)
        b.add_theme_stylebox_override("normal", sb)
        var sb2: StyleBoxFlat = sb.duplicate()
        sb2.bg_color = paszamine.lightened(0.12)
        b.add_theme_stylebox_override("hover", sb2)
        var sb3: StyleBoxFlat = sb.duplicate()
        sb3.bg_color = paszamine.darkened(0.15)
        b.add_theme_stylebox_override("pressed", sb3)
        b.add_theme_color_override("font_color", Color(1, 1, 1))
        b.add_theme_font_size_override("font_size", 26)
        var f := load("res://assets/fonts/Vazirmatn-Bold.ttf")
        if f != null:
                b.add_theme_font_override("font", f)

func _hud_besaz() -> void:
        hud = CanvasLayer.new()
        hud.name = "HUD"
        add_child(hud)
        # خطوط سرعت — از لبه‌ها به بیرون، با سرعت روشن می‌شوند
        khat_sorat = ColorRect.new()
        khat_sorat.set_anchors_preset(Control.PRESET_FULL_RECT)
        khat_sorat.mouse_filter = Control.MOUSE_FILTER_IGNORE
        javane_khat = ShaderMaterial.new()
        var shd := Shader.new()
        shd.code = """
shader_type canvas_item;
uniform float tavan : hint_range(0.0, 1.0) = 0.0;
void fragment() {
        vec2 uv = UV - vec2(0.5, 0.56);
        float r = length(uv) * 2.0;
        float a = atan(uv.y, uv.x);
        float m = 0.5 + 0.5 * sin(a * 22.0 + TIME * 3.0);
        m = pow(m, 7.0);
        float hazhe = smoothstep(0.45, 1.15, r);
        vec3 rang = mix(vec3(0.85, 0.93, 1.0), vec3(0.55, 0.75, 1.0), m);
        COLOR = vec4(rang, m * hazhe * tavan * 0.45);
}
"""
        javane_khat.shader = shd
        javane_khat.set_shader_parameter("tavan", 0.0)
        khat_sorat.material = javane_khat
        khat_sorat.color = Color(1, 1, 1, 1)
        hud.add_child(khat_sorat)
        var f: FontFile = load("res://assets/fonts/Vazirmatn-Bold.ttf")
        var fd: FontFile = load("res://assets/fonts/Lalezar-Regular.ttf")
        if fd == null:
                fd = f
        # گیج سرعت (رسم سفارشی)
        sanje_hud = Control.new()
        sanje_hud.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
        sanje_hud.position = Vector2(-300, -300)
        sanje_hud.size = Vector2(260, 260)
        sanje_hud.draw.connect(_sanje_kesh.bind(sanje_hud))
        hud.add_child(sanje_hud)
        # نوار نیترو
        mostatil_nitro = ColorRect.new()
        mostatil_nitro.color = Color(0.1, 0.1, 0.14, 0.75)
        mostatil_nitro.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
        mostatil_nitro.position = Vector2(-326, -224)
        mostatil_nitro.size = Vector2(20, 180)
        hud.add_child(mostatil_nitro)
        sharge_nitro = ColorRect.new()
        sharge_nitro.color = Color(0.25, 0.65, 1.0)
        sharge_nitro.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
        sharge_nitro.position = Vector2(2, 0)
        sharge_nitro.size = Vector2(16, 180)
        mostatil_nitro.add_child(sharge_nitro)
        # جایگاه
        matne_ja = Label.new()
        matne_ja.set_anchors_preset(Control.PRESET_TOP_LEFT)
        matne_ja.position = Vector2(24, 18)
        matne_ja.add_theme_font_size_override("font_size", 64)
        matne_ja.add_theme_font_override("font", fd)
        matne_ja.add_theme_color_override("font_color", Color(0.95, 0.76, 0.25))
        hud.add_child(matne_ja)
        # دور + زمان
        matne_dour = Label.new()
        matne_dour.set_anchors_preset(Control.PRESET_TOP_RIGHT)
        matne_dour.position = Vector2(-260, 18)
        matne_dour.size = Vector2(236, 40)
        matne_dour.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        matne_dour.add_theme_font_size_override("font_size", 30)
        matne_dour.add_theme_font_override("font", f)
        hud.add_child(matne_dour)
        matne_zaman = Label.new()
        matne_zaman.set_anchors_preset(Control.PRESET_TOP_RIGHT)
        matne_zaman.position = Vector2(-260, 62)
        matne_zaman.size = Vector2(236, 34)
        matne_zaman.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        matne_zaman.add_theme_font_size_override("font_size", 24)
        matne_zaman.add_theme_font_override("font", f)
        matne_zaman.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
        hud.add_child(matne_zaman)
        # مرکز: شمارش/پیام
        matne_vasat = Label.new()
        matne_vasat.set_anchors_preset(Control.PRESET_CENTER)
        matne_vasat.position = Vector2(-300, -160)
        matne_vasat.size = Vector2(600, 200)
        matne_vasat.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        matne_vasat.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        matne_vasat.add_theme_font_size_override("font_size", 150)
        matne_vasat.add_theme_font_override("font", fd)
        matne_vasat.add_theme_color_override("font_color", Color(0.95, 0.76, 0.25))
        hud.add_child(matne_vasat)
        # پاداش دریفت
        matne_darift = Label.new()
        matne_darift.set_anchors_preset(Control.PRESET_CENTER)
        matne_darift.position = Vector2(60, -40)
        matne_darift.size = Vector2(300, 60)
        matne_darift.add_theme_font_size_override("font_size", 34)
        matne_darift.add_theme_font_override("font", fd)
        matne_darift.add_theme_color_override("font_color", Color(0.35, 0.8, 1.0))
        matne_darift.modulate.a = 0.0
        hud.add_child(matne_darift)
        # مسیر اشتباه
        matne_ghalat = Label.new()
        matne_ghalat.set_anchors_preset(Control.PRESET_CENTER)
        matne_ghalat.position = Vector2(-300, -230)
        matne_ghalat.size = Vector2(600, 60)
        matne_ghalat.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        matne_ghalat.text = "برگرد! مسیر اشتباه است"
        matne_ghalat.add_theme_font_size_override("font_size", 36)
        matne_ghalat.add_theme_font_override("font", fd)
        matne_ghalat.add_theme_color_override("font_color", Color(1.0, 0.35, 0.3))
        matne_ghalat.visible = false
        hud.add_child(matne_ghalat)
        _dokmehaye_lamsi_besaz()

func _sanje_kesh(g: Control) -> void:
        var c := g.size * 0.5
        var r := minf(g.size.x, g.size.y) * 0.42
        g.draw_arc(c, r, PI * 0.75, PI * 2.25, 40, Color(1, 1, 1, 0.25), 10.0)
        var sp := clampf(absf(v_jelo) / 56.0, 0.0, 1.0)
        var rangi := Color(0.95, 0.76, 0.25) if nitro_rushan == false else Color(0.35, 0.8, 1.0)
        g.draw_arc(c, r, PI * 0.75, PI * 0.75 + PI * 1.5 * sp, 40, rangi, 10.0)
        var zavie := PI * 0.75 + PI * 1.5 * sp
        var noke := c + Vector2(cos(zavie), sin(zavie)) * (r - 6.0)
        g.draw_line(c, noke, Color(1, 1, 1, 0.9), 4.0)
        var f: Font = g.get_theme_default_font()
        if f != null:
                var kmh := int(absf(v_jelo) * 3.6)
                # عدد سرعت بزرگ با دورخط — امضای گیج مسابقه‌ای
                var fnt_b: Font = load("res://assets/fonts/Lalezar-Regular.ttf")
                if fnt_b == null:
                        fnt_b = f
                var rang_km := Color(1, 1, 1) if sp < 0.8 else Color(1.0, 0.85, 0.35)
                g.draw_string_outline(fnt_b, c + Vector2(-56, 58), str(kmh), HORIZONTAL_ALIGNMENT_CENTER, 112, 56, 7, Color(0.07, 0.07, 0.1, 0.9))
                g.draw_string(fnt_b, c + Vector2(-56, 58), str(kmh), HORIZONTAL_ALIGNMENT_CENTER, 112, 56, rang_km)
                g.draw_string(f, c + Vector2(-56, 80), "km/h", HORIZONTAL_ALIGNMENT_CENTER, 112, 17, Color(1, 1, 1, 0.62))

func _keshide_flsh(ar: Control, kenar: float) -> void:
        var noqtha := PackedVector2Array()
        var cx := 55.0
        var cy := 55.0
        noqtha.append(Vector2(cx - kenar * 30.0, cy - 34.0))
        noqtha.append(Vector2(cx - kenar * 30.0, cy + 34.0))
        noqtha.append(Vector2(cx + kenar * 34.0, cy))
        ar.draw_colored_polygon(noqtha, Color(1, 1, 1, 0.75))

func _dokmehaye_lamsi_besaz() -> void:
        # زون فرمان چپ (کشیدنی آنالوگ) + دستی/ترمز/نیترو راست
        var mantagheha := [
                {"name": "hb", "pos": Vector2(640 - 120, 720 - 120), "r": 62, "col": Color(0.9, 0.3, 0.2, 0.45), "label": "دستی"},
                {"name": "brake", "pos": Vector2(640 - 250, 720 - 70), "r": 50, "col": Color(0.2, 0.2, 0.25, 0.45), "label": "ترمز"},
                {"name": "nitro", "pos": Vector2(640 - 265, 720 - 210), "r": 55, "col": Color(0.2, 0.5, 0.95, 0.5), "label": "نیترو"},
        ]
        for z in mantagheha:
                var halqe := Control.new()
                halqe.position = z["pos"] - Vector2(z["r"], z["r"])
                halqe.size = Vector2(z["r"] * 2, z["r"] * 2)
                halqe.draw.connect(func():
                        var c2 := Vector2(z["r"], z["r"])
                        halqe.draw_circle(c2, z["r"], Color(0.04, 0.05, 0.08, 0.55))
                        halqe.draw_arc(c2, z["r"] - 2.0, 0.0, TAU, 40, Color(0.96, 0.76, 0.25, 0.75), 3.0)
                        halqe.draw_circle(c2, z["r"] * 0.82, z["col"])
                        var f: Font = halqe.get_theme_default_font()
                        if f != null:
                                halqe.draw_string(f, Vector2(6, z["r"] + 8), z["label"], HORIZONTAL_ALIGNMENT_CENTER, z["r"] * 2 - 12, 20, Color(1, 1, 1, 0.95)))
                halqe.mouse_filter = Control.MOUSE_FILTER_IGNORE
                hud.add_child(halqe)
        # فلش فرمان — دو بلوک صریح (بدون حلقه/capture)
        var pakan_chap := Control.new()
        pakan_chap.position = Vector2(30, 720 - 170)
        pakan_chap.size = Vector2(110, 110)
        pakan_chap.draw.connect(func():
                pakan_chap.draw_circle(Vector2(55, 55), 50.0, Color(0.04, 0.05, 0.08, 0.50))
                pakan_chap.draw_arc(Vector2(55, 55), 48.0, 0.0, TAU, 40, Color(0.96, 0.76, 0.25, 0.55), 2.5)
                _keshide_flsh(pakan_chap, -1.0))
        pakan_chap.mouse_filter = Control.MOUSE_FILTER_IGNORE
        hud.add_child(pakan_chap)
        var pakan_rast := Control.new()
        pakan_rast.position = Vector2(240, 720 - 170)
        pakan_rast.size = Vector2(110, 110)
        pakan_rast.draw.connect(func():
                pakan_rast.draw_circle(Vector2(55, 55), 50.0, Color(0.04, 0.05, 0.08, 0.50))
                pakan_rast.draw_arc(Vector2(55, 55), 48.0, 0.0, TAU, 40, Color(0.96, 0.76, 0.25, 0.55), 2.5)
                _keshide_flsh(pakan_rast, 1.0))
        pakan_rast.mouse_filter = Control.MOUSE_FILTER_IGNORE
        hud.add_child(pakan_rast)

# ═══════════════════ ورودی ═══════════════════
func _input(event: InputEvent) -> void:
        if event is InputEventScreenTouch:
                var t := event as InputEventScreenTouch
                if t.pressed:
                        if t.position.x < 430 and id_fermane_lamsi == -1:
                                id_fermane_lamsi = t.index
                                x0_fermane_lamsi = t.position.x
                                meghdare_fermane_lamsi = 0.0
                        else:
                                var zn := _mantaghe_dar(t.position)
                                if zn != "":
                                        sh_dokmeha[zn] = t.index
                                        if zn == "nitro":
                                                nitro_rushan = true
                                        elif zn == "hb":
                                                dasti = true
                                        elif zn == "brake":
                                                paye_termoz = true
                else:
                        if t.index == id_fermane_lamsi:
                                id_fermane_lamsi = -1
                                meghdare_fermane_lamsi = 0.0
                        for zn in sh_dokmeha.keys():
                                if sh_dokmeha[zn] == t.index:
                                        if zn == "nitro":
                                                nitro_rushan = false
                                        elif zn == "hb":
                                                dasti = false
                                        elif zn == "brake":
                                                paye_termoz = false
                                        sh_dokmeha.erase(zn)
                                        break
        elif event is InputEventScreenDrag:
                var d := event as InputEventScreenDrag
                if d.index == id_fermane_lamsi:
                        meghdare_fermane_lamsi = clampf((d.position.x - x0_fermane_lamsi) / 160.0, -1.0, 1.0)
        # کیبورد برای تست دسکتاپ
        if event is InputEventKey and event.pressed:
                if event.keycode == KEY_SPACE:
                        dasti = true
                elif event.keycode == KEY_SHIFT:
                        nitro_rushan = true
                elif event.keycode == KEY_DOWN:
                        paye_termoz = true
        if event is InputEventKey and not event.pressed:
                if event.keycode == KEY_SPACE:
                        dasti = false
                elif event.keycode == KEY_SHIFT:
                        nitro_rushan = false
                elif event.keycode == KEY_DOWN:
                        paye_termoz = false

func _mantaghe_dar(p: Vector2) -> String:
        var mantagheha := {"hb": Vector2(640 - 120, 720 - 120), "brake": Vector2(640 - 250, 720 - 70), "nitro": Vector2(640 - 265, 720 - 210)}
        var rs := {"hb": 78.0, "brake": 66.0, "nitro": 72.0}
        for zn in mantagheha.keys():
                if p.distance_to(mantagheha[zn]) < rs[zn]:
                        return zn
        return ""

func _ferman_kibord() -> float:
        var k := 0.0
        if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
                k -= 1.0
        if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
                k += 1.0
        return k

# ═══════════════════ حلقه‌ی اصلی ═══════════════════
func _process(dt: float) -> void:
        if halat == "count":
                shomarvar -= dt
                var n := int(ceil(shomarvar - 0.9))
                if shomarvar > 0.9:
                        var fa_n := "۳۲۱"[clampi(3 - n, 0, 2)]
                        matne_vasat.text = fa_n
                        if n != int(get_meta("last_n", -1)):
                                set_meta("last_n", n)
                                A.sfx_baz("beep")
                else:
                        if matne_vasat.text != "برو!":
                                matne_vasat.text = "برو!"
                                A.sfx_baz("boost")
                        halat = "race"
                        matne_vasat.text = ""
        _voroode_mosabeqe()
        if halat == "race" or halat == "finish":
                zamane_mosabeqe += dt
                _hasteye_fizik(dt)
                _hasteye_raqibha(dt)
        _hasteye_dorbin(dt)
        _hasteye_hud()
        _tike_azm_ertebat(dt)

func _voroode_mosabeqe() -> void:
        var ks := _ferman_kibord()
        mizane_ferman = clampf(ks + meghdare_fermane_lamsi, -1.0, 1.0)
        if halat == "finish":
                paye_gaz = 0.35
                dasti = false
                nitro_rushan = false
        elif halat == "race":
                paye_gaz = 1.0

func _hasteye_hud() -> void:
        if sanje_hud:
                sanje_hud.queue_redraw()
        if sharge_nitro:
                sharge_nitro.size.y = 176.0 * nitro
                sharge_nitro.position.y = 180.0 - 176.0 * nitro
        if matne_ja:
                var fa_p := ""
                for ch in str(jaye_payan if halat != "race" else _ja_e_zende()):
                        fa_p += "۰۱۲۳۴۵۶۷۸۹"[int(ch)] if ch >= "0" and ch <= "9" else ch
                matne_ja.text = fa_p + "/" + "۴"
        if matne_dour:
                var fa_l := ""
                for ch in str(mini(dour + 1, int(tarjome["laps"]))):
                        fa_l += "۰۱۲۳۴۵۶۷۸۹"[int(ch)] if ch >= "0" and ch <= "9" else ch
                matne_dour.text = "دور " + fa_l + " از " + "۱۲۳"[int(tarjome["laps"]) - 1]
        if matne_zaman:
                matne_zaman.text = _zaman_fa(zamane_mosabeqe)
        if matne_ghalat:
                matne_ghalat.visible = rah_e_ghalat > 1.0

func _ja_e_zende() -> int:
        var p := 1
        for rv in raqibha:
                if float(rv["s"]) > pishraft:
                        p += 1
        return p

# ═══════════════════ تست خودکار + عکس ═══════════════════
func _azm_ertebat() -> void:
        if arg_line.has("--shots"):
                otopilot = true
                print("[tizpa][race] SHOTS MODE")
        elif arg_line.has("--playtest") or arg_line.has("--autotest-full"):
                otopilot = true
                print("[tizpa][race] PLAYTEST MODE")

func _tike_azm_ertebat(dt: float) -> void:
        if not otopilot:
                return
        t_test += dt
        # اتوپایلوت: فرمان به سمت نقطه‌ی پیش‌رو
        var nega := fposmod(s_hala + 14.0 + absf(v_jelo) * 0.55, toole_masir)
        var li := _nemone_dar(nega)
        var to := NEMOONEHA[li] - ja
        var khaste := atan2(to.x, to.z)
        var tafavot := wrapf(khaste - semat, -PI, PI)
        meghdare_fermane_lamsi = clampf(tafavot * 1.8, -1.0, 1.0)
        if absf(tafavot) > 0.5 and absf(v_jelo) > 16.0:
                dasti = true
        else:
                dasti = false
        # برای عکس‌ها: لحظه‌های خاص
        if halate_aks:
                _tike_aks()
        else:
                _tike_test(dt)

func _tike_test(dt: float) -> void:
        # سناریوی تست: دریفت مصنوعی + نیترو + پایان
        if t_test > 4.0 and t_test < 5.4:
                dasti = true
                meghdare_fermane_lamsi = 1.0
        if t_test > 7.0 and t_test < 8.2:
                nitro_rushan = true
        elif t_test >= 8.2:
                nitro_rushan = false
        if t_test > 6.0 and marhale_test == 0:
                marhale_test = 1
                print("[tizpa][race] DRIFT OK slip=", absf(v_janebi))
        if t_test > 8.0 and marhale_test == 1:
                marhale_test = 2
                print("[tizpa][race] NITRO OK vf=", v_jelo)
        # پایان سریع برای تست: پس از 25 ثانیه مأموریت را تمام کن
        if t_test > 25.0 and halat == "race":
                _payane_mosabeqe()
        if halat == "panel" and marhale_test < 9:
                marhale_test = 9
                print("[tizpa][race] PLAYTEST PASS")
                if arg_line.has("--autotest-full"):
                        Koli.set_meta("at_menu_return", true)
                get_tree().create_timer(1.0).timeout.connect(func():
                        get_tree().change_scene_to_file("res://scenes/menu.tscn"))

var aks_tamaam := {}
func _tike_aks() -> void:
        var neshanha := [[1.7, "countdown"], [4.6, "chase"], [5.8, "drift"], [7.9, "nitro"], [11.5, "city"]]
        for m in neshanha:
                var tt: float = m[0]
                var nm: String = m[1]
                if t_test > tt and not aks_tamaam.has(nm):
                        aks_tamaam[nm] = true
                        var aks := get_viewport().get_texture().get_image()
                        var masir := "/tmp/shot_" + nm + ".png"
                        aks.save_png(masir)
                        print("[tizpa][race] SHOT ", nm, " -> ", masir)
        if t_test > 13.0:
                print("[tizpa][race] SHOTS DONE")
                get_tree().quit()
