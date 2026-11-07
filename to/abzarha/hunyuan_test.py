# ═══════════════════════════════════════════════════════════════
#  تست تجربی AI تصویربه‌سه‌بعدی — مدل رسمی Hunyuan3D-2 (تکنات)
#  روی اسپیس رسمی بدون لاگین؛ ورودی: اسپرایت زرد ماشین تیزپا
#  خروجی: GLB بافت‌دار → مقایسه با مدل دست‌ساز بلندری تیزپا
# ═══════════════════════════════════════════════════════════════
import shutil, sys, traceback
from pathlib import Path

VORUDI = Path("/tmp/azmayesh_ai/vorudi_mashin.png")
KHORUJI_GLB = Path("/home/z/my-project/tizpa2d/assets/models/ai_mashin.glb")


def stats_mesh(masir: Path) -> str:
    import trimesh
    sahneh = trimesh.load(str(masir), force="mesh")
    return "vertices=%d faces=%d hajm=%.0fKB" % (
        len(sahneh.vertices), len(sahneh.faces), masir.stat().st_size / 1024)


def asli():
    from gradio_client import Client, handle_file
    print("[ai] ورودی:", VORUDI, VORUDI.stat().st_size, "bytes")
    print("[ai] اتصال به tencent/Hunyuan3D-2 ...")
    client = Client("tencent/Hunyuan3D-2", verbose=False)
    print("[ai] متصل شد — تولید شروع شد (روی GPU خودشان)...")
    vorudi = handle_file(str(VORUDI))
    natije = None
    for api in ("/generation_all", "/shape_generation"):
        try:
            natije = client.predict(
                None,                    # caption
                vorudi,                  # image
                None, None, None, None,  # چندنمای
                30,                      # steps
                5.0,                     # guidance_scale
                1234,                    # seed
                256,                     # octree_resolution
                True,                    # حذف پس‌زمینه
                8000,                    # num_chunks
                False,                   # seed ثابت برای تکرارپذیری
                api_name=api,
            )
            print("[ai] با", api, "جواب داد")
            break
        except Exception as e:
            print("[ai]", api, "نشد:", type(e).__name__, str(e)[:200])
    if natije is None:
        raise RuntimeError("هیچ امضایی جواب نداد")
    print("[ai] خروجی خام:", type(natije), str(natije)[:300])
    fail = natije[0] if isinstance(natije, (tuple, list)) else natije
    if isinstance(fail, dict) and "value" in fail:
        fail = fail["value"]
    if fail is None or not Path(str(fail)).exists():
        raise RuntimeError("فایل خروجی پیدا نشد")
    KHORUJI_GLB.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy(str(fail), KHORUJI_GLB)
    print("[ai] ذخیره شد:", KHORUJI_GLB)
    print("[ai] آمار مدل AI:", stats_mesh(KHORUJI_GLB))
    tizpa = Path("/home/z/my-project/game/assets/models/tizpa.glb")
    print("[ai] آمار مدل بلندری تیزپا:", stats_mesh(tizpa))
    if isinstance(natije, (tuple, list)) and len(natije) > 2:
        print("[ai] mesh_stats سرور:", str(natije[2])[:300])
    print("[ai] TAAMOOM OK")


if __name__ == "__main__":
    try:
        asli()
    except Exception:
        traceback.print_exc()
        print("[ai] FAIL")
        sys.exit(1)
