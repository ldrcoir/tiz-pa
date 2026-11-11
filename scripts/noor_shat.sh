#!/bin/bash
## اجرای صحنه‌های «سه‌گانهٔ نور» زیر Xvfb و گرفتن اسکرین‌شات واقعی
set -u
export LIBGL_ALWAYS_SOFTWARE=1
export DISPLAY=:99
GODOT=/home/z/tools/godot/godot
PROJ=/home/z/my-project/noor2d
if [ ! -x "$GODOT" ]; then
        GODOT=$(ls /home/z/tools/godot/Godot_*linux.x86_64 2>/dev/null | head -1)
fi
echo "GODOT=$GODOT"
"$GODOT" --version
for s in menu madar shabtab badbadek ketabche; do
        echo "=== SAHNE: $s ==="
        timeout 90 "$GODOT" --path "$PROJ" --rendering-driver opengl3 --audio-driver Dummy -- --aks --sahne=$s > /tmp/noor_$s.log 2>&1
        rg "SHAT|KETABCHE|SCRIPT ERROR|ERROR" /tmp/noor_$s.log | head -12 || true
done
echo "=== TAMAM ==="
ls -la /home/z/my-project/download/screenshots_modern_2d/
