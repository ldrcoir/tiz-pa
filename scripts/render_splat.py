# رندرِ چرخشیِ فایل Gaussian Splat (ply خروجی Idol) بدون GPU — numpy + PIL
import argparse
import math
import os
import sys

import numpy as np
from PIL import Image, ImageDraw

C0 = 0.28209479177387814


def load_ply(path):
    with open(path, "rb") as f:
        header = b""
        while True:
            line = f.readline()
            header += line
            if line.strip() == b"end_header":
                break
        n = int([l for l in header.decode(errors="ignore").splitlines() if l.startswith("element vertex")][0].split()[-1])
        fields = []
        for l in header.decode(errors="ignore").splitlines():
            if l.startswith("property float"):
                fields.append(l.split()[-1])
        data = np.frombuffer(f.read(), dtype=np.dtype([(name, "<f4") for name in fields]), count=n)
    return data


def rotation_y(a):
    c, s = math.cos(a), math.sin(a)
    return np.array([[c, 0, s], [0, 1, 0], [-s, 0, c]])


def render_frame(data, yaw, size, f, D, pitch=0.12, radius_mul=1.05):
    SS = 2  # سوپرسمپل برای لبهٔ نرم
    W = H = size * SS
    img = Image.new("RGBA", (W, H), (24, 26, 34, 255))
    draw = ImageDraw.Draw(img, "RGBA")

    pos = np.stack([data["x"], data["y"], data["z"]], axis=1).astype(np.float64)
    ctr = (pos.min(0) + pos.max(0)) / 2.0
    pos -= ctr
    pos = pos @ rotation_y(yaw).T
    # کمی زاویه از بالا + فلیپ عمودی (قرارداد Y معکوس است)
    cp, sp = math.cos(pitch), math.sin(pitch)
    y2 = -(cp * pos[:, 1] - sp * pos[:, 2])
    z2 = sp * pos[:, 1] + cp * pos[:, 2]
    xv, yv, zv = pos[:, 0], y2, D + z2

    rgb = np.clip(0.5 + C0 * np.stack([data["f_dc_0"], data["f_dc_1"], data["f_dc_2"]], axis=1), 0, 1)
    rgb = (rgb * 255).astype(np.int32)
    alpha = 1.0 / (1.0 + np.exp(-data["opacity"].astype(np.float64)))
    sig = np.exp(np.stack([data["scale_0"], data["scale_1"], data["scale_2"]], axis=1).astype(np.float64))
    sig_max = sig.max(1)

    order = np.argsort(zv)  # دورها اول
    cx = cy = W / 2
    sx = cx + f * xv / zv
    sy = cy - f * yv / zv
    rp = f * sig_max / zv * radius_mul

    keep = (rp > 0.6) & (sx > -rp) & (sx < W + rp) & (sy > -rp) & (sy < H + rp) & (zv > 0.05)
    idx = order[keep[order]]
    for i in idx:
        r = rp[i]
        a = int(alpha[i] * 255)
        if a <= 2:
            continue
        draw.ellipse(
            (sx[i] - r, sy[i] - r, sx[i] + r, sy[i] + r),
            fill=(rgb[i, 0], rgb[i, 1], rgb[i, 2], a),
        )
    return img.resize((size, size), Image.LANCZOS)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--ply", required=True)
    ap.add_argument("--out", default="/tmp/splat_frames")
    ap.add_argument("--frames", type=int, default=150)
    ap.add_argument("--size", type=int, default=760)
    ap.add_argument("--test", action="store_true")
    args = ap.parse_args()

    data = load_ply(args.ply)
    print("vertices:", len(data))
    pos = np.stack([data["x"], data["y"], data["z"]], axis=1)
    ext = (pos.max(0) - pos.min(0)).max() / 2.0
    D = 3.0 * ext
    f = 0.52 * args.size * D / ext
    os.makedirs(args.out, exist_ok=True)

    if args.test:
        t0 = __import__("time").time()
        img = render_frame(data, 0.5, args.size, f, D)
        img.convert("RGB").save("/tmp/splat_test.png")
        print("test frame in %.1fs" % (__import__("time").time() - t0))
        return

    import time as _t
    t0 = _t.time()
    for k in range(args.frames):
        yaw = 2.0 * math.pi * k / args.frames
        im = render_frame(data, yaw, args.size, f, D)
        im.convert("RGB").save(os.path.join(args.out, "f_%04d.png" % k))
        if k % 30 == 0:
            print("frame %d/%d (%.0fs)" % (k, args.frames, _t.time() - t0), flush=True)
    print("done:", args.frames)


if __name__ == "__main__":
    main()
