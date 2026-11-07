#!/bin/bash
# ساخت هنر «گردآفرید» — نسخهٔ پیش‌رو؛ فایل‌های موجود را رد می‌کند
set -u
KH=/tmp/honar
mkdir -p "$KH"
log() { echo "[$(date +%H:%M:%S)] $1"; }

HELIA="young beautiful Persian heroine Gordafarid with warm smile and big brown eyes, long black braided hair, navy blue silk headscarf flowing behind under a small golden open helmet, bright crimson red tunic with ornate gold embossed chest armor, two small round golden mirror badges on the chest, flowing emerald green sash belt, dark leather boots"
STILE="Persian Shahnameh miniature painting style, modern flat 2D game art, bold clean dark outlines, rich saturated turquoise gold crimson palette, high quality, detailed"
SEP="full body, complete character visible, side view facing right, isolated on solid flat pure chroma green background color #00FF00, no shadows, no ground, no other objects, centered composition"

gen() {
        local nam="$1"; shift
        local size="$1"; shift
        local prompt="$1"
        if [ -s "$KH/$nam.png" ]; then
                log "بود: $nam"
                return
        fi
        log "می‌سازم: $nam"
        timeout 150 z-ai image -p "$prompt" -o "$KH/$nam.png" -s "$size" || log "ناموفق: $nam"
}

gen "gordafarid_zadan" 1024x1024 "$HELIA, swinging curved shamshir sword raised high overhead in dynamic mid attack pose, motion energy, $STILE, $SEP"
gen "gordafarid_tirandaz" 1024x1024 "$HELIA, drawing a Persian recurve bow aiming forward with arrow nocked, focused archer pose, quiver on back, $STILE, $SEP"
gen "sarbaz_turan" 1024x1024 "Turanian enemy soldier, menacing warrior with bronze helmet and dark plume, leather lamellar armor in dark brown and black, round painted shield and curved sword, angry face, $STILE, $SEP"
gen "div_bozorg" 1024x1024 "giant Persian div demon from Shahnameh, muscular green-skinned ogre with two curved bull horns, yellow fangs, wild fiery red hair, tiger skin loincloth, huge wooden spiked club, evil grin, $STILE, $SEP"
gen "div_sefid" 1024x1024 "colossal White Div boss from Shahnameh, muscular pale ice-white skinned demon with icy blue crystal accents, single large spiral horn, glowing yellow eyes, ice encrusted stone mace, terrifying, $STILE, $SEP"
gen "div_kuchak" 1024x1024 "small mischievous Persian imp demon, tiny green goblin with small horns, big pointy ears, naughty grin, simple loincloth, $STILE, $SEP"
gen "asb" 1024x1024 "noble white Persian mare standing, ornate golden saddle with crimson tassels and red bridle, graceful, $STILE, full body, complete horse visible, side view facing right, isolated on solid flat pure chroma green background color #00FF00, no shadows, no ground, no other objects, centered composition"
gen "savare" 1024x1024 "Persian heroine warrior woman in crimson tunic and gold armor with navy blue headscarf and flowing green sash, riding a galloping white horse with golden saddle, cape flying, heroic charge pose, $STILE, full scene with horse and rider visible, side view facing right, isolated on solid flat pure chroma green background color #00FF00, no shadows, no ground, no other objects, centered"
gen "aseman" 1344x768 "vast golden hour sunset sky, layered warm amber and rose clouds, soft radiant sun glow near horizon, Persian miniature painting style, flat painterly texture, dreamy epic atmosphere, no ground, no buildings, no mountains, only sky and clouds, wide panoramic composition"
gen "kuh" 1344x768 "distant Alborz mountain range at dusk with a great white castle fortress with towers standing on the highest snowy peak, Persian miniature painting style, flat layered tones of deep indigo and violet and mauve, wide panoramic silhouette strip, no foreground details, no sky clouds only distant haze"
gen "shahr" 1344x768 "ancient Persian city skyline strip with turquoise domes, tall minarets, badgir wind towers, slender cypress trees, arched bridges, Persian miniature painting style, flat rich colors of turquoise gold and terracotta, wide horizontal panoramic strip, no ground, no sky, no foreground, detailed silhouettes"
gen "kash" 1024x1024 "seamless tileable ornate Persian brick wall texture, sandstone blocks with turquoise geometric tile inlay star pattern band, flat miniature painting style, even lighting, no shadows, no perspective, straight on flat texture, repeats horizontally seamlessly"
gen "enar" 1024x1024 "single ripe pomegranate fruit icon with small green leaves, glossy red seeds glinting, magical health item, $STILE, isolated on solid flat pure chroma green background color #00FF00, no shadows, no other objects, centered"
gen "senobar" 1024x1024 "single tall slender Persian cypress tree with dark green foliage and small golden ornaments, $STILE, full tree visible, isolated on solid flat pure chroma green background color #00FF00, no shadows, no ground, no other objects, centered"
gen "dargah" 864x1152 "magnificent ancient Persian castle gate facade, tall arched wooden door with golden studs and iron rings, turquoise glazed brick wall with geometric patterns, two small towers flanking, $STILE, front view, isolated on solid flat pure chroma green background color #00FF00, no shadows, no ground, no other objects, centered"

log "PAYAN"
ls "$KH" | wc -l
