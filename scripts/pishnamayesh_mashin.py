# پیش‌نمایش مدل: دو رندر — سه‌رخ جلو و نیم‌رخ — تا با چشم بفهمیم ماشین درست است
import bpy, sys, math

GLB = "/home/z/my-project/game/assets/models/tizpa.glb"
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=GLB)

scn = bpy.context.scene
scn.render.engine = 'CYCLES'
scn.cycles.samples = 48
scn.cycles.device = 'CPU'
scn.display.shading.light = 'STUDIO'
scn.display.shading.color_type = 'MATERIAL'
scn.render.resolution_x = 900
scn.render.resolution_y = 520
scn.render.film_transparent = False

# آسمان روشن
w = bpy.data.worlds.new("donya")
scn.world = w
w.use_nodes = True
bg = w.node_tree.nodes["Background"]
bg.inputs[0].default_value = (0.55, 0.65, 0.80, 1.0)
bg.inputs[1].default_value = 1.0

# خورشید
sun = bpy.data.objects.new("aftab", bpy.data.lights.new("aftab", 'SUN'))
sun.data.energy = 3.5
sun.rotation_euler = (math.radians(50), 0, math.radians(30))
bpy.context.collection.objects.link(sun)

def rend(nam, loc, look):
    cam = bpy.data.objects.new("cam_" + nam, bpy.data.cameras.new("cam_" + nam))
    bpy.context.collection.objects.link(cam)
    cam.location = loc
    d = (look[0] - loc[0], look[1] - loc[1], look[2] - loc[2])
    import mathutils
    cam.rotation_euler = mathutils.Vector(d).to_track_quat('-Z', 'Y').to_euler()
    scn.camera = cam
    scn.render.filepath = "/tmp/preview_" + nam + ".png"
    bpy.ops.render.render(write_still=True)
    print("RENDERED", nam)

rend("sakerakh", (5.5, -5.5, 2.6), (0, 0, 0.7))     # سه‌رخ جلو — دماغه رو به -Y
rend("nimrakh", (7.8, 0, 1.6), (0, 0, 0.7))          # نیم‌رخ
rend("aqab", (-4.5, 6.0, 2.4), (0, 0, 0.8))          # سه‌رخ عقب
print("PREVIEW DONE")
