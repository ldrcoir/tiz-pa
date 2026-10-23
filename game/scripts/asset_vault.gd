extends RefCounted

const JADOO := "BVAULT1"

# جدول partA با ماسک حسابی (0x37 + i*0x9D) — بازسازی در زمان اجرا
const _KA := [39, 243, 42, 42, 212, 142, 238, 168, 57, 181, 107, 0, 114, 76, 237, 229,
                222, 229, 138, 120, 126, 24, 58, 100, 28, 86, 7, 167, 201, 71, 121, 243]
const _KB := [106, 251, 97, 223, 47, 160, 177, 141, 240, 111, 25, 150, 236, 135, 93, 70]

static var _key_cache: PackedByteArray = PackedByteArray()

static func _mask(i: int) -> int:
        return (0x37 + i * 0x9D) & 0xFF

static func _part_b() -> PackedByteArray:
        var khoruj := PackedByteArray()
        for i in 16:
                khoruj.append(_KB[i] ^ _mask(i))
        return khoruj

static func _get_key() -> PackedByteArray:
        if _key_cache.size() == 32:
                return _key_cache
        var pa := PackedByteArray()
        for i in 32:
                pa.append(_KA[i] ^ _mask(i))
        var hc := HashingContext.new()
        hc.start(HashingContext.HASH_SHA256)
        hc.update(pa)
        hc.update(_part_b())
        _key_cache = hc.finish()
        return _key_cache

static func _le32(b: PackedByteArray, khamosh: int) -> int:
        return (b[khamosh] | (b[khamosh + 1] << 8) | (b[khamosh + 2] << 16) | (b[khamosh + 3] << 24)) & 0xFFFFFFFF

static func _rotl(v: int, c: int) -> int:
        # ⛔ فیکس باگ BVAULT: PackedInt32Array مقادیر بالای bit31 را منفی ذخیره می‌کند
        # و شیفت راستِ GDScript روی منفی «حسابی» است — بدون ماسک، بیت‌های علامت
        # به نتیجه می‌ریزند و کلید-استریم خراب می‌شود (سناریو روی گوشی باز نمی‌شد)
        return ((v << c) & 0xFFFFFFFF) | ((v & 0xFFFFFFFF) >> (32 - c))

static func _qr(s: PackedInt32Array, a: int, b: int, c: int, d: int) -> void:
        s[a] = (s[a] + s[b]) & 0xFFFFFFFF; s[d] = _rotl(s[d] ^ s[a], 16)
        s[c] = (s[c] + s[d]) & 0xFFFFFFFF; s[b] = _rotl(s[b] ^ s[c], 12)
        s[a] = (s[a] + s[b]) & 0xFFFFFFFF; s[d] = _rotl(s[d] ^ s[a], 8)
        s[c] = (s[c] + s[d]) & 0xFFFFFFFF; s[b] = _rotl(s[b] ^ s[c], 7)

static func _chacha20_xor(kelid: PackedByteArray, yeksar: PackedByteArray, dade: PackedByteArray, counter0: int = 0) -> PackedByteArray:
        var khoruj := PackedByteArray()
        khoruj.resize(dade.size())
        var sh_block := (dade.size() + 63) / 64
        for blk in sh_block:
                var st := PackedInt32Array([0x61707865, 0x3320646E, 0x79622D32, 0x6B206574,
                        _le32(kelid, 0), _le32(kelid, 4), _le32(kelid, 8), _le32(kelid, 12),
                        _le32(kelid, 16), _le32(kelid, 20), _le32(kelid, 24), _le32(kelid, 28),
                        (counter0 + blk) & 0xFFFFFFFF,
                        _le32(yeksar, 0), _le32(yeksar, 4), _le32(yeksar, 8)])
                var w := PackedInt32Array(st)
                for r in 10:
                        _qr(w, 0, 4, 8, 12); _qr(w, 1, 5, 9, 13); _qr(w, 2, 6, 10, 14); _qr(w, 3, 7, 11, 15)
                        _qr(w, 0, 5, 10, 15); _qr(w, 1, 6, 11, 12); _qr(w, 2, 7, 8, 13); _qr(w, 3, 4, 9, 14)
                var paye := blk * 64
                for j in 16:
                        var vazhe := (w[j] + st[j]) & 0xFFFFFFFF
                        for k in 4:
                                var sh := paye + j * 4 + k
                                if sh < dade.size():
                                        khoruj[sh] = dade[sh] ^ ((vazhe >> (8 * k)) & 0xFF)
        return khoruj

static func open_bvault(masir: String) -> PackedByteArray:
        if not FileAccess.file_exists(masir):
                return PackedByteArray()
        var f := FileAccess.open(masir, FileAccess.READ)
        if f == null:
                return PackedByteArray()
        var tike := f.get_buffer(f.get_length())
        f.close()
        if tike.size() < 21 or tike.slice(0, 7).get_string_from_ascii() != JADOO:
                return PackedByteArray()
        var yeksar := tike.slice(8, 20)
        return _chacha20_xor(_get_key(), yeksar, tike.slice(20))

static func load_json(masir: String) -> Dictionary:
        var paye := masir.get_basename()
        var dade := open_bvault(paye + ".bvault")
        var tajziye = null
        if not dade.is_empty():
                tajziye = JSON.parse_string(dade.get_string_from_utf8())
                if tajziye is Dictionary:
                        return tajziye
                push_warning("BVAULT parse failed: " + paye + ".bvault")
        if OS.is_debug_build():
                # fallback توسعه: خزانه نبود یا خراب بود → پلین JSON کنارش
                var jp := paye + ".json"
                if FileAccess.file_exists(jp):
                        var f := FileAccess.open(jp, FileAccess.READ)
                        if f != null:
                                var p2 = JSON.parse_string(f.get_as_text())
                                if p2 is Dictionary:
                                        return p2
        return {}

static func self_test() -> bool:
        # ۱) بردار استاندارد RFC 8439 §2.4.2 — جواب درست از بیرون آمده،
        # پس اگر پیاده‌سازی خراب شود (مثل باگ rotl منفی) این تست می‌گیردش؛
        # راند‌تریپ متقارنِ ساده این باگ را پنهان می‌کرد!
        var kelide_rfc := PackedByteArray()
        for i in 32:
                kelide_rfc.append(i)
        var yeksare_rfc := PackedByteArray()
        for b in PackedByteArray([0, 0, 0, 0, 0, 0, 0, 0x4a, 0, 0, 0, 0]):
                yeksare_rfc.append(b)
        var matne_rfc := "Ladies and Gentlemen of the class of '99: If I could offer you only one tip for the future, sunscreen would be it.".to_utf8_buffer()
        var hexe_mored := "6e2e359a2568f98041ba0728dd0d6981e97e7aec1d4360c20a27afccfd9fae0bf91b65c5524733ab8f593dabcd62b3571639d624e65152ab8f530c359f0861d807ca0dbf500d6a6156a38e088a22b65e52bc514d16ccf806818ce91ab77937365af90bbf74a35be6b40b8eedf2785e42874d"
        var gereft := _chacha20_xor(kelide_rfc, yeksare_rfc, matne_rfc, 1)
        if gereft.hex_encode() != hexe_mored:
                push_error("BVAULT self_test: RFC 8439 vector FAILED")
                return false
        # ۲) راند‌تریپ UTF-8
        var matn := "تیز پا — vault سالم است"
        var peygham := matn.to_utf8_buffer()
        var yeksar := PackedByteArray()
        yeksar.resize(12)
        for i in 12:
                yeksar[i] = (i * 7 + 3) & 0xFF
        var kod_bezan := _chacha20_xor(_get_key(), yeksar, peygham)
        var kod_baz := _chacha20_xor(_get_key(), yeksar, kod_bezan)
        return kod_baz == peygham and kod_baz.get_string_from_utf8() == matn
