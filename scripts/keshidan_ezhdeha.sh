#!/bin/bash
# ═══════════════════════════════════════════════════════════
#  کشیدنِ اژدهای کوچولو + کاستوم‌هایش — ۹ عکس با سبکِ یکسان
#  همه: چیبی، نیمرخِ رو به راست، پس‌زمینهٔ سبزِ خالص برای کلیدِ رنگی
# ═══════════════════════════════════════════════════════════
set -e
JA=/home/z/my-project/to/ezhdeha/kham
mkdir -p "$JA"

sabk="Cute chibi baby dragon, full body side view facing right, flat 2D cartoon game sprite, big head small body, tiny wings, big friendly cartoon eyes, thick clean dark outlines, flat colors, simple shapes, standing pose, perfectly centered, plain solid pure green background #00FF00, no shadow, no ground, no text, no watermark"

declare -A kastum
kastum[ezhdeha_asli]="green baby dragon with soft orange belly, tiny orange horns and a happy smile"
kastum[ezhdeha_jadugar]="the same green baby dragon wearing a purple pointed wizard hat with golden stars and a small flowing purple cape"
kastum[ezhdeha_polis]="the same green baby dragon wearing a dark blue police cap with a golden badge, friendly guardian look"
kastum[ezhdeha_faza]="the same green baby dragon wearing a white astronaut helmet with clear glass dome, tiny space suit"
kastum[ezhdeha_daryayi]="the same green baby dragon wearing a black pirate bandana with white dots, one playful eye patch"
kastum[ezhdeha_shah]="the same green baby dragon wearing a shiny golden crown with red gems and a small red royal cape"
kastum[ezhdeha_zemestani]="the same green baby dragon wearing a red knitted winter beanie with white pompom and a cozy striped scarf"
kastum[ezhdeha_ranande]="the same green baby dragon wearing a red racing helmet with visor lifted up showing the eyes"
kastum[ezhdeha_ninja]="the same green baby dragon wearing a dark ninja hood with a red headband, tiny determined face"

for esm in ezhdeha_asli ezhdeha_jadugar ezhdeha_polis ezhdeha_faza ezhdeha_daryayi ezhdeha_shah ezhdeha_zemestani ezhdeha_ranande ezhdeha_ninja; do
  if [ -s "$JA/$esm.png" ]; then echo "mojood: $esm"; continue; fi
  echo ">> mikesham: $esm"
  z-ai image -p "$sabk, ${kastum[$esm]}" -o "$JA/$esm.png" -s 1024x1024
done
echo "== tamam =="
ls -la "$JA"
