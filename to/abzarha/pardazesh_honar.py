# ═══════════════════════════════════════════════════════════════
#  پالایش هنرهای AI — پس‌زمینه‌ی سفید را شفاف می‌کنیم تا پارالاکس شود
#  و یک ورقه‌ی تماس می‌سازیم تا چیدمان لایه‌ها را چک کنیم
# ═══════════════════════════════════════════════════════════════
import sys
from pathlib import Path
import numpy as np
from PIL import Image

HONAR = Path("/home/z/my-project/tizpa2d/assets/art")


def shefafe_saz(masir: Path, alaye: int = 244) -> None:
    """سفیدِ پس‌زمینه را شفاف می‌کند — با پر کفتی نرم لبه‌ها"""
    t = Image.open(masir).convert("RGBA")
    a = np.array(t).astype(np.int16)
    sefid = a[..., :3].min(axis=2)          # هرچه روشن‌تر، سفیدتر
    alpha = np.clip((alaye - sefid) * (255.0 / max(alaye - 225, 1)), 0, 255)
    a[..., 3] = alpha.astype(np.int16)
    Image.fromarray(a.astype(np.uint8)).save(masir)
    print("[honar] شفاف شد:", masir.name)


def varagheli() -> None:
    """ورقه‌ی تماس — چهار لایه روی هم در یک تصویر برای بررسی چشمی"""
    aseman = Image.open(HONAR / "aseman.png").convert("RGBA").resize((672, 384))
    safhe = Image.new("RGBA", (672, 384 * 3))
    safhe.paste(aseman, (0, 0))
    y = 384
    for nm in ("khat_shahr.png", "sakhtemanha.png", "derakht.png"):
        t = Image.open(HONAR / nm).convert("RGBA").resize((672, 384))
        safhe.paste(t, (0, y), t)
        y += 384
    safhe.save(HONAR / "varagheli.png")
    print("[honar] ورقه‌ی تماس ساخته شد")


if __name__ == "__main__":
    for nm in ("khat_shahr.png", "sakhtemanha.png", "derakht.png"):
        shefafe_saz(HONAR / nm)
    varagheli()
    print("[honar] TAMAM")
