# آزمایشِ ComfyUI لوکال — جوابِ «میتونی لوکال نصب کنی؟»: بله ✔

این عکس (comfy_tizpa_test.png) با ComfyUI نسخهٔ ۰.۴۴ روی **CPU همین سندباکس** تولید شد
(بدونِ GPU، بدونِ اینترنتِ موقعِ تولید).

## رسپیِ نصب (نکته‌های مهم)
۱. `pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu`
۲. `pip install -r requirements.txt` (از مخزنِ comfyanonymous/ComfyUI)
۳. اجرا: `python3 main.py --cpu --force-fp16` — **پرچمِ force-fp16 حیاتی است؛**
   بدونِ آن مدل را fp32 بالا می‌برد و رمِ ۴ گیگ اُام می‌شود.
۴. مدلِ سبک: `Comfy-Org/stable-diffusion-v1-5-archive` → فایلِ
   `v1-5-pruned-emaonly-fp16.safetensors` (۲.۱۳GB) → در `models/checkpoints/`
   اگر HF محدود زد (429)، میرورِ `hf-mirror.com` با دانلودِ **تک‌تکه‌نشده** کار می‌کند؛
   دانلودِ resume با این میرور فایل را خراب می‌کند (آزموده شد).
۵. ورک‌فلو با POST به `http://127.0.0.1:8188/prompt` و پولِ `/history/<id>`

## عددِ واقعیِ سرعتِ CPU (۲ رشته)
۳۲۰×۳۲۰ با ۶ گام ≈ ۴ دقیقه — برایِ تولیدِ انبوهِ اسپرایت مناسب نیست ولی برایِ
آزمایشِ ایده و ساختِ طرحِ پایه (که بعداً با پایپ‌لاینِ ورقِ فریم تبدیل می‌شود) مفید است.
زیرِ همین سقف، هر تصویرِ تازه فقط همین ورک‌فلو را دوباره POST می‌کند.
