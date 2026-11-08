# ارسال عکس هلیا به دموی Idol (Speridlabs) روی ZeroGPU و گرفتن مدل سه‌بعدی
import os
import sys
import time
from gradio_client import Client, handle_file

TOKEN = os.environ.get("HF_TOKEN")
if not TOKEN:
    print("NO_TOKEN")
    sys.exit(1)

img = sys.argv[1] if len(sys.argv) > 1 else "/home/z/my-project/to/idol_test/helia_input.png"
out_dir = sys.argv[2] if len(sys.argv) > 2 else "/home/z/my-project/to/idol_test"

client = Client("speridlabs/idol", token=TOKEN, verbose=False)
print("connected, running...", flush=True)
t0 = time.time()
result = client.predict(
    image=handle_file(img),
    mode="Synthetic",
    steps=50,
    cfg_scale=3.0,
    rescale_t=3.0,
    seed=42,
    randomize=False,
    gaussians="131,072",
    api_name="/run",
)
print("elapsed: %.1fs" % (time.time() - t0), flush=True)
print("result:", result, flush=True)
# خروجی: (Model3D filepath, Number, Html)
try:
    model_path = result[0]
except Exception:
    model_path = result
print("MODEL_PATH:", model_path, flush=True)
