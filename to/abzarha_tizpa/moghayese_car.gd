extends Node3D
# اسم اسکریپت: car.gd — به یک Node3D وصلش کن

var wheels: Array[Node3D] = []
var speed := 0.0

func _ready():
    _build_car()

func _build_car():
    var body_mat = StandardMaterial3D.new()
    body_mat.albedo_color = Color(0.8, 0.1, 0.1)

    var glass_mat = StandardMaterial3D.new()
    glass_mat.albedo_color = Color(0.2, 0.4, 0.6, 0.7)
    glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

    # بدنه اصلی
    var body = _box(Vector3(2.0, 0.6, 4.0), Vector3(0, 0.6, 0), body_mat)
    add_child(body)

    # کابین
    var cabin = _box(Vector3(1.7, 0.7, 2.0), Vector3(0, 1.25, -0.2), glass_mat)
    add_child(cabin)

    # چرخ‌ها
    var wheel_positions = [
        Vector3(-0.95, 0.35, 1.3),
        Vector3( 0.95, 0.35, 1.3),
        Vector3(-0.95, 0.35, -1.3),
        Vector3( 0.95, 0.35, -1.3)
    ]
    for pos in wheel_positions:
        var wheel = _make_wheel(pos)
        add_child(wheel)
        wheels.append(wheel)

    # چراغ‌ها
    var light_mat = StandardMaterial3D.new()
    light_mat.albedo_color = Color(1, 1, 0.7)
    light_mat.emission_enabled = true
    light_mat.emission = Color(1, 1, 0.7)
    add_child(_box(Vector3(0.3, 0.2, 0.1), Vector3(-0.6, 0.7, 2.0), light_mat))
    add_child(_box(Vector3(0.3, 0.2, 0.1), Vector3( 0.6, 0.7, 2.0), light_mat))

func _box(size: Vector3, pos: Vector3, mat: Material) -> MeshInstance3D:
    var mi = MeshInstance3D.new()
    var m = BoxMesh.new()
    m.size = size
    mi.mesh = m
    mi.position = pos
    mi.material_override = mat
    return mi

func _make_wheel(pos: Vector3) -> Node3D:
    var pivot = Node3D.new()
    pivot.position = pos
    var mi = MeshInstance3D.new()
    var m = CylinderMesh.new()
    m.top_radius = 0.35
    m.bottom_radius = 0.35
    m.height = 0.25
    mi.mesh = m
    mi.rotation_degrees = Vector3(0, 0, 90)
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(0.05, 0.05, 0.05)
    mi.material_override = mat
    pivot.add_child(mi)
    return pivot

func _process(delta):
    # چرخش چرخ‌ها بر اساس سرعت
    for w in wheels:
        w.rotate_object_local(Vector3.RIGHT, -speed * delta)
