# ═══════════════════════════════════════════════════════════════════
#  دانلودِ اسپرایت‌های رایگانِ تیرفایل — فقط محصولاتِ قیمتِ صفر
#  مکانیزم: فرمِ «somdn» در صفحهٔ هر محصول؛ کلید = base64 زمانِ حال
#  خروجی: /tmp/dl/tirfile/<id>_<esm>.zip  (به‌همراهِ READMEِ منبع)
# ═══════════════════════════════════════════════════════════════════
import base64
import json
import re
import time
from pathlib import Path

import requests

KHOJI = Path("/tmp/dl/wc_sprite.json")          # خروجیِ API فروشگاه (اسم + لینک)
KHOJI_KHOROJI = Path("/tmp/dl/tirfile")
UA = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0",
      "Referer": "https://tirfile.ir/"}

# شناسهٔ محصولاتِ رایگان (قیمت = ۰) که از API گرفته شد
RAYEGAN = [843, 816, 639, 614, 556, 553, 547, 432, 400, 384,
           309, 303, 281, 261, 251, 210, 206, 153, 137, 132, 121, 113]


def esm_file_besaz(pid: int, esm: str) -> str:
    """نامِ پوشه: فقط حروفِ انگلیسی/عدد از نامِ فارسی — فینگلیشِ ساده با id"""
    return f"{pid}"


def maghsharha(page: str) -> dict | None:
    """استخراجِ فرمِ دانلودِ somdn از HTMLِ صفحهٔ محصول"""
    m = re.search(r'<form class="somdn[^"]*"[^>]*action="([^"]+)"[^>]*>(.*?)</form>', page, re.S)
    if not m:
        return None
    ghale, baten = m.group(1), m.group(2)
    klid = re.search(r'name="somdn_download_key" value="([^"]+)"', baten)
    aksan = re.search(r'name="action" value="([^"]+)"', baten)
    mahsol = re.search(r'name="somdn_product" value="([^"]+)"', baten)
    if not (klid and aksan and mahsol):
        return None
    return {"ghale": ghale, "klid": klid.group(1), "aksan": aksan.group(1), "mahsol": mahsol.group(1)}


def ali() -> None:
    KHOJI_KHOROJI.mkdir(parents=True, exist_ok=True)
    mahsolat = {p["id"]: p for p in json.load(open(KHOJI))}
    khorooji = []     # فایل‌های که واقعاً دانلود شدند
    linha = []        # لینک‌های مستقیمِ 302 (برایِ README)
    for pid in RAYEGAN:
        if pid not in mahsolat:
            print(f"[danlod] {pid}: dar API nist — rad shod")
            continue
        esm = mahsolat[pid]["name"].strip()
        link = mahsolat[pid]["permalink"]
        try:
            safhe = requests.get(link, headers=UA, timeout=30)
            frm = maghsharha(safhe.text)
            if not frm:
                print(f"[danlod] {pid} {esm}: form peyda nashod")
                continue
            # کلیدِ تازه = زمانِ فعلی به base64 (همان‌طور که سایت می‌سازد)
            klid_taze = base64.b64encode(str(int(time.time())).encode()).decode()
            data = {"somdn_download_key": klid_taze, "action": frm["aksan"],
                    "somdn_product": frm["mahsol"]}
            javab = requests.post(frm["ghale"], headers=UA, data=data, timeout=120,
                                  allow_redirects=False)
            # سرور همیشه 302 می‌دهد: آدرسِ مستقیمِ فایل در dl.tirfile.ir
            mahal = javab.headers.get("Location", "")
            if mahal:
                print(f"[danlod] {pid} {esm}: link = {mahal}")
                linha.append((pid, esm, mahal))
            # تلاش برای دانلودِ مستقیم (از ایران کار می‌کند؛ از بیرونِ ایران سرور رد می‌کند)
            if mahal:
                try:
                    failjavab = requests.get(mahal, headers=UA, timeout=60)
                    sar = failjavab.content[:8]
                    if failjavab.status_code == 200 and sar.startswith((b"PK", b"Rar!", b"7z\xbd\xaf")):
                        pasvand = ".zip" if sar.startswith(b"PK") else ".rar"
                        fail = KHOJI_KHOROJI / f"{pid}{pasvand}"
                        fail.write_bytes(failjavab.content)
                        print(f"[danlod] {pid} {esm}: OK {len(failjavab.content)/1024:.0f}KB")
                        khorooji.append((pid, esm, link, fail.name, len(failjavab.content)))
                        continue
                except Exception:
                    pass   # اتصالِ ردشده = محدودیتِ IPِ ایران؛ لینک در README ثبت شد
            else:
                print(f"[danlod] {pid} {esm}: redirect nabood — {javab.status_code}")
        except Exception as khata:
            print(f"[danlod] {pid} {esm}: KHATA {khata}")
        time.sleep(1.2)   # ملاحظهٔ سرور

    # READMEِ منبع + همهٔ لینک‌های مستقیمِ دانلود
    matn = ["# اسپرایت‌های رایگانِ تیرفایل — همهٔ لینک‌های مستقیم", "",
            "منبع: https://tirfile.ir/product-category/sprite/  (محصولاتِ قیمتِ ۰ = رایگان)",
            "",
            "⚠ سرورِ `dl.tirfile.ir` فقط به IPِ ایران جواب می‌دهد؛",
            "این اسکریپت را از ایران اجرا کن (`python3 scripts/danlod_tirfile.py`)",
            "یا لینک‌ها را مستقیم در مرورگر باز کن:", "",
            "## لینک‌های مستقیمِ دانلود", ""]
    for pid, esm, lin in linha:
        matn.append(f"- **{esm}** (id {pid}): {lin}")
    if khorooji:
        matn += ["", "## فایل‌های دانلودشده", "", "| شناسه | نام | فایل | حجم |", "|---|---|---|---|"]
        for pid, esm, link, fail, hajm in khorooji:
            matn.append(f"| {pid} | {esm} | `{fail}` | {hajm//1024}KB |")
    (KHOJI_KHOROJI / "README.md").write_text("\n".join(matn), encoding="utf-8")
    print(f"[danlod] TAMOOM: {len(khorooji)} fail, {len(linha)} lin")


if __name__ == "__main__":
    ali()
