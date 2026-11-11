# ═══════════════════════════════════════════════════════════════
#  تست تجربی «AI تصویربه‌سه‌بعدی» — همان خانواده‌ی فناوری Tripo
#  ایده: به‌جای اکانت‌سازی (که ایمیل می‌خواهد)، از خودِ اسپیس رسمی
#  stabilityai/TripoSR روی هاگینگ‌فیس استفاده می‌کنیم — همان مدلی که
#  تیم Tripo ساخته؛ ورودی: اسپرایت زرد ماشین تیزپا (شفاف)
# ═══════════════════════════════════════════════════════════════
import shutil, sys, traceback, os
from pathlib import Path

from PIL import Image

VORUDI = Path("/home/z/my-project/game/assets/sprites/car_boghi_yellow.webp")
KAR_MASKANI = Path("/tmp/azmayesh_ai")
KHORUJI_GLB = Path("/home/z/my-project/demos/bazi2d/assets/models/ai_mashin.glb")


def amade_sazi_voruudi() -> Path:
    KAR_MASKANI.mkdir(parents=True, exist_ok=True)
    tasvir = Image.open(VORUDI).convert("RGBA")
    # مربع‌سازی با حاشیه‌ی شفاف — مدل‌های volumetric مربع را بهتر می‌فهمند
    b = max(tasvir.size) + 40
    safhe = Image.new("RGBA", (b, b), (0, 0, 0, 0))
    safhe.paste(tasvir, ((b - tasvir.width) // 2, (b - tasvir.height) // 2), tasvir)
    masir = KAR_MASKANI / "vorudi_mashin.png"
    safhe.save(masir)
    print("[ai] ورودی آماده:", masir, safhe.size)
    return masir


def stats_mesh(masir: Path) -> str:
    import trimesh
    sahneh = trimesh.load(str(masir), force="mesh")
    return (
        f"vertices={len(sahneh.vertices)} faces={len(sahneh.faces)} "
        f"hajm_fail={masir.stat().st_size / 1024:.0f}KB"
    )


def asli():
    from gradio_client import Client, handle_file
    vorudi = amade_sazi_voruudi()
    print("[ai] اتصال به اسپیس stabilityai/TripoSR ...")
    client = Client("stabilityai/TripoSR")
    client.view_api()  # برای لاگِ امضای دقیق API

    natije = None
    for vorudi_ha in (
        [handle_file(str(vorudi)), True, 0.85, 3.0],
        [handle_file(str(vorudi)), True, 0.85],
        [handle_file(str(vorudi)), True],
    ):
        try:
            natije = client.predict(*vorudi_ha, api_name="/generate")
            print("[ai] با امضای", len(vorudi_ha), "پارامتری جواب داد")
            break
        except Exception as e:
            print("[ai] این امضا نشد:", type(e).__name__, str(e)[:300])
    if natije is None:
        raise RuntimeError("هیچ امضایی جواب نداد")

    print("[ai] خروجی خام:", natije)
    glb = None
    mozoo = natije if isinstance(natije, (tuple, list)) else [natije]
    for m in mozoo:
        s = str(m)
        if s.lower().endswith((".glb", ".ply", ".obj")) or (os.path.exists(s) and Path(s).is_file()):
            glb = Path(s)
            break
    if glb is None:
        raise RuntimeError("فایل مدل در خروجی پیدا نشد")
    KHORUJI_GLB.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy(glb, KHORUJI_GLB)
    print("[ai] مدل ذخیره شد:", KHORUJI_GLB)
    print("[ai] آمار مدل AI:", stats_mesh(KHORUJI_GLB))

    # برای مقایسه، آمار مدل دست‌ساز بلندری تیزپا را هم بده
    tizpa = Path("/home/z/my-project/game/assets/models/tizpa.glb")
    if tizpa.exists():
        print("[ai] آمار مدل بلندری تیزپا:", stats_mesh(tizpa))
    print("[ai] TAAMOOM OK")


if __name__ == "__main__":
    try:
        asli()
    except Exception:
        traceback.print_exc()
        print("[ai] FAIL")
        sys.exit(1)
