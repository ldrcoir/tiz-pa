# بازی آزمایشی: پلتفرمر با هنر آمادهٔ Kenney (CC0) — تستِ «آیا ایتچ مشکل را حل می‌کند؟»
extends Node2D

const T := 54.0
const LEVEL_W := 40
const GROUND_ROW := 11

const PlayerScript := preload("res://player.gd")
const ZombieScript := preload("res://zombie.gd")
const CoinScript := preload("res://coin.gd")

var helia_poses := {}
var zombie_poses := {}
var tiles_tex := {}
var bg_tex := {}

var player
var cam: Camera2D
var score := 0
var digit_sprites: Array = []
var steps: Array = []
var step_i := 0
var wait_t := 0.0
var jumped := {}
var holding := false
var cheer := false
var aks_mode := false
var aks_done := false
var run_t := 0.0
var bg_far: Node2D
var bg_mid: Node2D
var dbg := false
var dbg_t := 0.0

class SunNode extends Node2D:
        func _draw() -> void:
                draw_circle(Vector2.ZERO, 52.0, Color(1.0, 0.93, 0.55, 0.55))
                draw_circle(Vector2.ZERO, 38.0, Color(1.0, 0.97, 0.8, 1.0))

class CloudNode extends Node2D:
        var defs := []
        func _draw() -> void:
                for d in defs:
                        var p := Vector2(d[0], d[1])
                        var s: float = d[2]
                        draw_circle(p, 26.0 * s, Color(1, 1, 1, 0.95))
                        draw_circle(p + Vector2(26.0 * s, 7.0 * s), 20.0 * s, Color(1, 1, 1, 0.95))
                        draw_circle(p + Vector2(-26.0 * s, 8.0 * s), 18.0 * s, Color(1, 1, 1, 0.95))
                        draw_circle(p + Vector2(6.0 * s, 16.0 * s), 18.0 * s, Color(1, 1, 1, 0.95))

func _ready() -> void:
        _load_assets()
        _build_background()
        _build_level()
        _build_coins()
        _build_player()
        _build_zombie()
        _build_hud()
        _setup_demo()
        var args := OS.get_cmdline_user_args()
        aks_mode = args.has("--aks")
        dbg = args.has("--dbg")

func _load_assets() -> void:
        for p in ["idle", "walk1", "walk2", "jump", "fall", "cheer1", "cheer2"]:
                var path := "res://assets/helia/female_%s.png" % p
                if ResourceLoader.exists(path):
                        helia_poses[p] = load(path)
        for p in ["walk1", "walk2"]:
                var zp := "res://assets/zombie/zombie_%s.png" % p
                if ResourceLoader.exists(zp):
                        zombie_poses[p] = load(zp)
        for n in ["0000", "0001", "0002", "0003", "0010", "0011", "0012", "0013", "0047", "0067", "0078", "0079", "0145", "0151"]:
                tiles_tex[n] = load("res://assets/tiles/tile_%s.png" % n)
        for d in range(10):
                tiles_tex["d%d" % d] = load("res://assets/tiles/tile_017%d.png" % d)
        for n in ["0008", "0009", "0014", "0015"]:
                bg_tex[n] = load("res://assets/tiles/bg_tile_%s.png" % n)

func _tile(parent: Node, tex: Texture2D, pos: Vector2, scl: float = 3.0) -> Sprite2D:
        var s := Sprite2D.new()
        s.texture = tex
        s.position = pos
        s.scale = Vector2(scl, scl)
        s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        parent.add_child(s)
        return s

func _build_background() -> void:
        var grad := Gradient.new()
        grad.colors = PackedColorArray([Color(0.42, 0.7, 0.92), Color(0.78, 0.89, 0.97)])
        grad.offsets = PackedFloat32Array([0.0, 1.0])
        var gt := GradientTexture2D.new()
        gt.gradient = grad
        gt.fill_from = Vector2(0, 0)
        gt.fill_to = Vector2(0, 1)
        gt.width = 64
        gt.height = 256
        var sky := TextureRect.new()
        sky.texture = gt
        sky.position = Vector2(-600, -400)
        sky.size = Vector2(3600, 1500)
        sky.z_index = -50
        add_child(sky)
        bg_far = Node2D.new()
        bg_far.z_index = -45
        add_child(bg_far)
        bg_mid = Node2D.new()
        bg_mid.z_index = -40
        add_child(bg_mid)
        # ابرهای نرم — کشیده‌شده با دایره، نه تایل مربعی
        var clouds := CloudNode.new()
        for k in range(8):
                clouds.defs.append([110.0 + k * 330.0, 95.0 + (k % 3) * 78.0, 0.9 + (k % 3) * 0.25])
        bg_far.add_child(clouds)
        # تپه‌های سبز — پارالاکس میانه، پایینشان روی سطح زمین
        var hx := 20.0
        var j := 0
        while hx < 1800.0:
                var htex: Texture2D = bg_tex["0014"] if j % 2 == 0 else bg_tex["0015"]
                _tile(bg_mid, htex, Vector2(hx, GROUND_ROW * T - 27.0), 3.0).modulate = Color(0.78, 0.86, 1.0, 0.9)
                hx += 108.0
                j += 1

func _build_level() -> void:
        # زمین: چهار قطعه با دو سربالایی ناپدید (گپ)
        var segs := [[0, 8], [11, 17], [21, 30], [33, 39]]
        for seg in segs:
                for c in range(seg[0], seg[1] + 1):
                        var top_n: String = "0000" if c == seg[0] else ("0002" if c == seg[1] else "0001")
                        _tile(self, tiles_tex[top_n], Vector2(c * T + 27.0, GROUND_ROW * T + 27.0))
                        for r in [12, 13]:
                                _tile(self, tiles_tex["0003"], Vector2(c * T + 27.0, r * T + 27.0))
                var body := StaticBody2D.new()
                var shape := CollisionShape2D.new()
                var rect := RectangleShape2D.new()
                var w: float = (seg[1] - seg[0] + 1) * T
                rect.size = Vector2(w, 3 * T)
                shape.shape = rect
                body.position = Vector2(seg[0] * T + w / 2.0, (GROUND_ROW + 1.5) * T)
                shape.shape = rect
                body.add_child(shape)
                add_child(body)
        # سکوهای قرمز — یک‌طرفه (از پایین رد می‌شود، از بالا می‌ایستد)
        for plat in [[9, 4, 6], [9, 13, 15], [9, 24, 26]]:
                for c in range(plat[1], plat[2] + 1):
                        var n: String = "0013"
                        _tile(self, tiles_tex[n], Vector2(c * T + 27.0, plat[0] * T + 27.0))
                var pb := StaticBody2D.new()
                var ps := CollisionShape2D.new()
                var pr := RectangleShape2D.new()
                pr.size = Vector2((plat[2] - plat[1] + 1) * T, 18.0)
                ps.shape = pr
                ps.one_way_collision = true
                pb.position = Vector2((plat[1] + (plat[2] - plat[1]) / 2.0 + 0.5) * T, plat[0] * T + 9.0)
                pb.add_child(ps)
                add_child(pb)
        # سکوی سبز پایانی (ستون ۳۴-۳۵)
        _tile(self, tiles_tex["0078"], Vector2(34 * T + 27.0, 9 * T + 27.0))
        _tile(self, tiles_tex["0079"], Vector2(35 * T + 27.0, 9 * T + 27.0))
        var gb := StaticBody2D.new()
        var gs := CollisionShape2D.new()
        var gr := RectangleShape2D.new()
        gr.size = Vector2(2 * T, 18.0)
        gs.shape = gr
        gs.one_way_collision = true
        gb.position = Vector2(35 * T, 9 * T + 9.0)
        gb.add_child(gs)
        add_child(gb)
        # تابلوی پایان
        _tile(self, tiles_tex["0047"], Vector2(37.5 * T, GROUND_ROW * T - 27.0))

func _build_coins() -> void:
        var coin_pos := [
                [2.5, 10.05], [3.5, 10.05],
                [9.5, 8.25], [10.5, 8.1],
                [4.5, 10.05], [5.5, 10.05], [6.5, 10.05],
                [13.5, 10.05], [14.5, 10.05], [15.5, 10.05],
                [24.5, 7.55], [25.5, 7.55], [26.5, 7.55],
        ]
        var phase := 0.0
        for cp in coin_pos:
                var cnode := CoinScript.new()
                cnode.position = Vector2(cp[0] * T, cp[1] * T)
                add_child(cnode)
                cnode.setup(cp[1] * T, phase, "coin", tiles_tex["0151"])
                cnode.got.connect(_on_coin_got)
                phase += 0.7
        var gem := CoinScript.new()
        gem.kind = "gem"
        gem.position = Vector2(26.8 * T, 7.55 * T)
        add_child(gem)
        gem.setup(7.55 * T, 1.2, "gem", tiles_tex["0067"])
        gem.got.connect(_on_coin_got)

func _build_player() -> void:
        player = CharacterBody2D.new()
        player.set_script(PlayerScript)
        player.position = Vector2(150.0, GROUND_ROW * T - 45.0)
        add_child(player)
        player.setup(helia_poses)
        cam = Camera2D.new()
        player.add_child(cam)
        cam.limit_left = 0
        cam.limit_right = LEVEL_W * int(T)
        cam.limit_top = -400
        cam.limit_bottom = 14 * int(T)
        cam.position_smoothing_enabled = true
        cam.position_smoothing_speed = 6.0
        cam.offset = Vector2(0, -70)
        cam.make_current()

func _build_zombie() -> void:
        var z = Node2D.new()
        z.set_script(ZombieScript)
        add_child(z)
        z.setup(zombie_poses, 22.5 * T, 29.0 * T, Vector2(26.0 * T, GROUND_ROW * T - 47.0))

func _build_hud() -> void:
        var hud := CanvasLayer.new()
        hud.layer = 10
        add_child(hud)
        var sun := SunNode.new()
        sun.position = Vector2(1150, 95)
        hud.add_child(sun)
        var coin_icon := Sprite2D.new()
        coin_icon.texture = tiles_tex["0151"]
        coin_icon.scale = Vector2(2.0, 2.0)
        coin_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        coin_icon.position = Vector2(34, 36)
        hud.add_child(coin_icon)
        for i in range(3):
                var d := Sprite2D.new()
                d.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
                d.scale = Vector2(2.0, 2.0)
                d.position = Vector2(64 + i * 40, 36)
                d.visible = false
                hud.add_child(d)
                digit_sprites.append(d)
        _update_hud()

func _update_hud() -> void:
        var s := str(score)
        for i in range(digit_sprites.size()):
                var sp: Sprite2D = digit_sprites[i]
                if i < s.length():
                        sp.texture = tiles_tex["d" + s[i]]
                        sp.position.x = 64 + i * 40
                        sp.visible = true
                else:
                        sp.visible = false

func _on_coin_got(kind: String) -> void:
        score += 5 if kind == "gem" else 1
        _update_hud()

func _spawn_hearts(pos: Vector2) -> void:
        var offsets := [[-40.0, 0.0], [40.0, -10.0], [0.0, -30.0], [-70.0, -20.0], [70.0, -35.0], [-15.0, -55.0]]
        for off in offsets:
                var h := Sprite2D.new()
                h.texture = tiles_tex["0145"]
                h.scale = Vector2(2.4, 2.4)
                h.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
                h.position = pos + Vector2(off[0], off[1])
                h.z_index = 20
                add_child(h)
                var tw := create_tween()
                tw.set_parallel(true)
                tw.tween_property(h, "position", h.position + Vector2(off[0] * 0.6, -110.0), 1.2).set_trans(Tween.TRANS_SINE)
                tw.tween_property(h, "modulate:a", 0.0, 1.2).set_delay(0.3)
                tw.chain().tween_callback(h.queue_free)

func _setup_demo() -> void:
        # سناریوی نمایش: توقف درست، پرش روی گپ‌ها، سکه‌ها، سکو، جواهر، جشن
        steps = [
                {"x": 170.0, "wait": 0.7},
                {"x": 700.0, "jump_at": 450.0},
                {"x": 780.0, "wait": 0.2},
                {"x": 1180.0, "jump_at": 934.0},
                {"x": 1180.0, "wait": 0.25},
                {"x": 1445.0, "jump_at": 1260.0},
                {"x": 1310.0, "wait": 0.3},
                {"x": 1470.0, "wait": 0.1},
                {"x": 1660.0, "wait": 0.15},
                {"x": 2050.0, "jump_at": 1630.0},
                {"x": 2050.0, "wait": 0.3},
                {"cheer": true},
        ]

func _demo(delta: float) -> void:
        if cheer or steps.is_empty() or player == null:
                return
        var st: Dictionary = steps[step_i]
        if st.has("cheer"):
                cheer = true
                player.celebrate()
                _spawn_hearts(player.global_position + Vector2(0, -95))
                var tw := create_tween()
                tw.tween_property(cam, "zoom", Vector2(0.92, 0.92), 1.4).set_trans(Tween.TRANS_SINE)
                return
        if not holding:
                player.target_x = float(st["x"])
                if st.has("jump_at") and not jumped.has(step_i):
                        if player.global_position.x >= float(st["jump_at"]):
                                jumped[step_i] = true
                                player.want_jump = true
                if absf(player.global_position.x - float(st["x"])) < 12.0:
                        if st.has("wait"):
                                holding = true
                                wait_t = 0.0
                                player.target_x = player.global_position.x
                        else:
                                step_i += 1
        else:
                player.target_x = player.global_position.x
                wait_t += delta
                if wait_t >= float(st["wait"]):
                        holding = false
                        step_i += 1

func _process(delta: float) -> void:
        run_t += delta
        if dbg and run_t - dbg_t > 0.25:
                dbg_t = run_t
                print("t=%.2f step=%d px=%.0f py=%.0f vx=%.0f vy=%.0f floor=%s want=%s jumped=%s" % [run_t, step_i, player.global_position.x, player.global_position.y, player.velocity.x, player.velocity.y, player.is_on_floor(), player.want_jump, jumped])
        if player != null:
                bg_far.position.x = -player.global_position.x * 0.25
                bg_mid.position.x = -player.global_position.x * 0.5
        _demo(delta)
        if aks_mode and not aks_done and run_t > 1.3:
                aks_done = true
                var img := get_viewport().get_texture().get_image()
                img.save_png("/tmp/aks.png")
                get_tree().quit()
        if not aks_mode and run_t > 14.0:
                get_tree().quit()
