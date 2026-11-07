# ═══════════════════════════════════════════════════════════════
#  کاوشگر اسپیس‌های تصویربه‌سه‌بعدی — کدام اسپیس زنده و بی‌لاگین است؟
# ═══════════════════════════════════════════════════════════════
import sys, traceback

from gradio_client import Client

NAMESPASE_HA = [
    "tencent/Hunyuan3D-2",
    "microsoft/TRELLIS",
    "stabilityai/TripoSR",
    "JeffreyXiang/TRELLIS",
]

for nm in NAMESPASE_HA:
    try:
        print("=" * 20, nm)
        c = Client(nm, verbose=False)
        print("CONNECT OK")
        c.view_api()
        print("API-OK", nm)
    except Exception as e:
        print("FAIL:", type(e).__name__, str(e)[:200])
    sys.stdout.flush()
