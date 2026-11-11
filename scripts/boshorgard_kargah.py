#!/usr/bin/env python3
# ═══════════════════════════════════════════════════════════════════
#  بزرگ‌کردنِ کارگاهِ تیزپا:
#  ۱) تبِ سوم «اژدها» — پیش‌نمایشِ زنده با ۹ کاستوم × ۴ حرکت (ورق‌های webp داخلِ فایل)
#  ۲) شیت‌ساز: دکمهٔ «برعکسِ ترتیبِ فریم‌ها» و «دانلودِ خودِ ورق»
#  کارگاه همچنان یک فایلِ HTMLِ تنها می‌ماند
# ═══════════════════════════════════════════════════════════════════
import base64
import json
from pathlib import Path

KARGAH = Path("/home/z/my-project/to/kargah.html")
DANEHA = Path("/home/z/my-project/to/ezhdeha/kargah_data")

kod = KARGAH.read_text(encoding="utf-8")

# ── دادهٔ اژدها: json + ورق‌های webp به base64 ──
jason = json.loads((DANEHA / "ezhdeha.json").read_text(encoding="utf-8"))
for k in jason["kastumha"]:
    webp = (DANEHA / k["varagh"]).read_bytes()
    k["data"] = "data:image/webp;base64," + base64.b64encode(webp).decode()
# کلیدِ حرکت‌ها به ترتیبِ درست (dict حفظِ ترتیب)
jason["harekat"] = {
    "ist":   {"az": 0, "tedad": 2, "sorat": 6,  "halghe": True},
    "doid":  {"az": 2, "tedad": 4, "sorat": 12, "halghe": True},
    "parsh": {"az": 6, "tedad": 3, "sorat": 8,  "halghe": True},
    "dam":   {"az": 9, "tedad": 2, "sorat": 6,  "halghe": True},
}
dane_js = json.dumps(jason, ensure_ascii=False)

# ── ۱) دکمهٔ تبِ اژدها در nav ──
kod = kod.replace(
    '<button id="tab_3d">🧊 سه‌بعدی‌ساز</button>',
    '<button id="tab_3d">🧊 سه‌بعدی‌ساز</button>\n  <button id="tab_ezh">🐉 اژدها</button>', 1)

# ── ۲) زیرنویسِ سربرگ ──
kod = kod.replace(
    "ورقِ فریم ← انیمیشنِ گودوت &nbsp;|&nbsp; مدلِ سه‌بعدی ← صحنه ← خروجیِ glb &nbsp;—&nbsp; همه‌چیزِ تحتِ وب و رایگان",
    "ورقِ فریم ← انیمیشنِ گودوت &nbsp;|&nbsp; سه‌بعدی ← صحنه ← glb &nbsp;|&nbsp; اژدها با ۹ کاستوم و آتش &nbsp;—&nbsp; همه‌چیزِ تحتِ وب و رایگان", 1)

# ── ۳) بدنهٔ تبِ اژدها — قبل از importmap ──
tab_html = '''
<!-- ════════════════ کارگاهِ اژدها ════════════════ -->
<div id="karzhal_ezh" class="karzhal" style="display:none">
  <div class="do_sotoon">
    <div>
      <div class="jaye">
        <h2>اژدهای کوچولو — زنده</h2>
        <canvas id="bomme_ezhdeha" width="320" height="320"></canvas>
        <div class="khatchin" style="margin-top:8px">
          <span>همان ورق‌هایِ فریم که گودوت هم از همان‌ها انیمیشن می‌سازد</span>
        </div>
      </div>
    </div>
    <div>
      <div class="jaye">
        <h2>کاستوم‌ها</h2>
        <div class="chideman" id="list_ezh_kastum"></div>
        <div class="bakhsh">
          <h2 style="margin-bottom:6px">حرکت‌ها</h2>
          <div class="chideman" id="list_ezh_harekat"></div>
        </div>
        <div class="bakhsh">
          <button class="amal khamoshine" id="dokme_ezh_pakhsh">⏸ توقف</button>
          <label style="margin-right:10px">آینه ⬌ <input type="checkbox" id="ezh_ayene"></label>
          <button class="amal khamoshine" id="dokme_ezh_aks">📸 عکسِ فریم</button>
        </div>
        <div class="piam" id="piam_ezh"></div>
      </div>
    </div>
  </div>
</div>

<script type="importmap">'''
kod = kod.replace('<script type="importmap">', tab_html, 1)

# ── ۴) دکمه‌های تازهٔ شیت‌ساز (بعد از دانلودِ tres) ──
kod = kod.replace(
    '<button class="amal khamoshine" id="dokme_danlod_tres">دانلودِ .tres</button>',
    '<button class="amal khamoshine" id="dokme_danlod_tres">دانلودِ .tres</button>\n'
    '        <button class="amal khamoshine" id="dokme_baraks">↺ برعکسِ ترتیبِ فریم‌ها</button>\n'
    '        <button class="amal khamoshine" id="dokme_danlod_varagh">🖼 دانلودِ خودِ ورق</button>', 1)

# ── ۵) کدِ جاوااسکریپتِ اژدها + دستگیره‌های تازه + بازچینشِ تب‌ها — قبل از بسته‌شدنِ script ──
ezh_js = '''
/* ═══════════════════════════ بخشِ ۳: کارگاهِ اژدها ═══════════════════════════ */
const EZH = __EZH_DANE__;
const ezh_img = {};
EZH.kastumha.forEach(k => {
  const aks = new Image();
  aks.onload = () => { ezh_img[k.esm] = aks; };
  aks.src = k.data;
});
let ezh_kastum = 0, ezh_harekat = 'doid', ezh_sayeh = 0, ezh_darHarkat = true;
const ezh_esm_harekat = { ist: 'ایستادن', doid: 'دویدن', parsh: 'پرش', dam: 'آتش 🔥' };

function ezhFram() {
  const h = EZH.harekat[ezh_harekat];
  return h.az + (Math.floor(ezh_sayeh) % h.tedad);
}
function ezhBekesh() {
  const bom = $('bomme_ezhdeha'), d = bom.getContext('2d');
  d.clearRect(0, 0, bom.width, bom.height);
  const k = EZH.kastumha[ezh_kastum], img = ezh_img[k.esm];
  if (!img) return;
  const fi = ezhFram();
  d.imageSmoothingEnabled = false;
  d.save();
  if ($('ezh_ayene').checked) { d.translate(bom.width, 0); d.scale(-1, 1); }
  d.drawImage(img, fi * EZH.frame, 0, EZH.frame, EZH.frame, 0, 0, bom.width, bom.height);
  d.restore();
}
let ezh_zamanGhabli = 0;
function halgheEzh(zaman) {
  const h = EZH.harekat[ezh_harekat];
  if (ezh_darHarkat) ezh_sayeh += (zaman - ezh_zamanGhabli) / 1000 * h.sorat;
  ezh_zamanGhabli = zaman;
  ezhBekesh();
  requestAnimationFrame(halgheEzh);
}
requestAnimationFrame(halgheEzh);

function listEzhKastum() {
  const ja = $('list_ezh_kastum'); ja.innerHTML = '';
  EZH.kastumha.forEach((k, i) => {
    const dokme = document.createElement('div');
    dokme.className = 'halghe_fr' + (i === ezh_kastum ? ' ghazal' : '');
    dokme.textContent = k.esm_fa;
    dokme.onclick = () => { ezh_kastum = i; ezh_sayeh = 0; listEzhKastum(); };
    ja.appendChild(dokme);
  });
}
function listEzhHarekat() {
  const ja = $('list_ezh_harekat'); ja.innerHTML = '';
  Object.keys(EZH.harekat).forEach(ha => {
    const dokme = document.createElement('div');
    dokme.className = 'halghe_fr' + (ha === ezh_harekat ? ' ghazal' : '');
    dokme.textContent = ezh_esm_harekat[ha];
    dokme.onclick = () => { ezh_harekat = ha; ezh_sayeh = 0; listEzhHarekat(); };
    ja.appendChild(dokme);
  });
}
listEzhKastum(); listEzhHarekat();

$('dokme_ezh_pakhsh').onclick = () => {
  ezh_darHarkat = !ezh_darHarkat;
  $('dokme_ezh_pakhsh').textContent = ezh_darHarkat ? '⏸ توقف' : '▶ پخش';
};
$('dokme_ezh_aks').onclick = () => {
  const a = document.createElement('a');
  a.href = $('bomme_ezhdeha').toDataURL('image/png');
  a.download = 'ezhdeha_' + EZH.kastumha[ezh_kastum].esm + '_' + ezh_harekat + '.png';
  a.click();
  $('piam_ezh').textContent = '✔ عکسِ فریم ذخیره شد';
};

/* ── دستگیره‌های تازهٔ شیت‌ساز ── */
$('dokme_baraks').onclick = () => {
  halatha[ghazal].framha.reverse();
  bommeSheetBekesh(); listAnima();
};
$('dokme_danlod_varagh').onclick = () => {
  if (!tasvir) return;
  const a = document.createElement('a');
  a.href = tasvir.src; a.download = 'varagh_kol.png'; a.click();
};

/* ── بازچینشِ هر سهٔ تب با تابعِ مشترک ── */
function tabBekesh(karzhal, dokme) {
  ['karzhal_sheet', 'karzhal_3d', 'karzhal_ezh'].forEach(id => $(id).style.display = 'none');
  ['tab_sheet', 'tab_3d', 'tab_ezh'].forEach(id => $(id).classList.remove('ghazal'));
  $(karzhal).style.display = 'block';
  $(dokme).classList.add('ghazal');
}
$('tab_sheet').onclick = () => tabBekesh('karzhal_sheet', 'tab_sheet');
$('tab_ezh').onclick = () => tabBekesh('karzhal_ezh', 'tab_ezh');
$('tab_3d').onclick = async () => { tabBekesh('karzhal_3d', 'tab_3d'); if (!THREE) await tashkil3D(); };
'''
kod = kod.replace("</script>\n</body>", ezh_js.replace("__EZH_DANE__", dane_js) + "</script>\n</body>", 1)

KARGAH.write_text(kod, encoding="utf-8")
print("kargah be-rooz shod — hajm:", KARGAH.stat().st_size // 1024, "KB")
