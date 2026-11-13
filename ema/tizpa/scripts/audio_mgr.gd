extends Node

var sfx := {}
var pakhsh_ahang: AudioStreamPlayer
var pakhsh_motor: AudioStreamPlayer
var pakhsh_jigh: AudioStreamPlayer
var pakhsh_vizhe: AudioStreamPlayer

func _sfx_bekhon() -> void:
        for n in ["horn", "coin", "jump", "boost", "crash", "win", "fail", "clank", "nitro", "lap", "beep"]:
                var masir := "res://assets/audio/%s.wav" % n
                if ResourceLoader.exists(masir):
                        sfx[n] = load(masir)

func _ready() -> void:
        # سانتی‌ها بعد از اولین فریم خوانده می‌شوند — بوت چندصدم سریع‌تر، بدون لکنت
        call_deferred("_sfx_bekhon")
        pakhsh_ahang = AudioStreamPlayer.new()
        # آهنگِ واقعیِ مسابقه‌ای — قطعهٔ کاملِ چندسازواره؛ نسخهٔ قدیمی به‌عنوانِ پشتیبان
        var masire_ahang := "res://assets/audio/music_nfs.ogg"
        if not ResourceLoader.exists(masire_ahang):
                masire_ahang = "res://assets/audio/music_loop.ogg"
        if ResourceLoader.exists(masire_ahang):
                pakhsh_ahang.stream = load(masire_ahang)
                if pakhsh_ahang.stream is AudioStreamOggVorbis:
                        pakhsh_ahang.stream.loop = true
        pakhsh_ahang.volume_db = -9.0
        pakhsh_ahang.finished.connect(func(): pakhsh_ahang.play())
        add_child(pakhsh_ahang)
        # آهنگ بلافاصله از لحظه‌ی بوت شروع می‌شود — حتی قبل از منو
        if pakhsh_ahang.stream != null:
                pakhsh_ahang.play()
        # پخش‌کننده‌ی سرود قهرمانی — سکوی نفر اول بدون آهنگِ کامل، جشن نیست
        pakhsh_vizhe = AudioStreamPlayer.new()
        var masire_vizhe := "res://assets/audio/ahang_piroozi.ogg"
        if ResourceLoader.exists(masire_vizhe):
                pakhsh_vizhe.stream = load(masire_vizhe)
        pakhsh_vizhe.volume_db = -5.0
        add_child(pakhsh_vizhe)
        pakhsh_motor = AudioStreamPlayer.new()
        # غرشِ موتورِ جدید — لوپِ بی‌درزِ چندموجی؛ قدیمی پشتیبان
        var masire_motor := "res://assets/audio/motor_nfs.wav"
        if not ResourceLoader.exists(masire_motor):
                masire_motor = "res://assets/audio/engine.wav"
        pakhsh_motor.stream = load(masire_motor)
        # لوپ بی‌درز موتور — اگر یک‌بار مکث شنیده شود حس رباتیک می‌دهد
        var jaryan_motor := pakhsh_motor.stream as AudioStreamWAV
        if jaryan_motor != null:
                jaryan_motor.loop_mode = AudioStreamWAV.LOOP_FORWARD
                jaryan_motor.loop_begin = 0
                var bayt_dar_kadr := 2 # ۱۶-بیت مونو
                if jaryan_motor.stereo:
                        bayt_dar_kadr = 4
                jaryan_motor.loop_end = jaryan_motor.data.size() / bayt_dar_kadr
        pakhsh_motor.volume_db = -60.0
        pakhsh_motor.finished.connect(func(): if pakhsh_motor.volume_db > -50.0: pakhsh_motor.play())
        add_child(pakhsh_motor)
        # لوپ جیغ لاستیک — دریفت واقعی صدای لاستیک می‌خواهد
        pakhsh_jigh = AudioStreamPlayer.new()
        var masire_sfx := "res://assets/audio/skid.wav"
        if ResourceLoader.exists(masire_sfx):
                pakhsh_jigh.stream = load(masire_sfx)
                var jaryan_jigh := pakhsh_jigh.stream as AudioStreamWAV
                if jaryan_jigh != null:
                        jaryan_jigh.loop_mode = AudioStreamWAV.LOOP_FORWARD
                        jaryan_jigh.loop_begin = 0
                        var bayt_dar_kadr2 := 2
                        if jaryan_jigh.stereo:
                                bayt_dar_kadr2 = 4
                        jaryan_jigh.loop_end = jaryan_jigh.data.size() / bayt_dar_kadr2
                pakhsh_jigh.volume_db = -60.0
                pakhsh_jigh.finished.connect(func(): if pakhsh_jigh.volume_db > -50.0: pakhsh_jigh.play())
                add_child(pakhsh_jigh)

func ahang_baz() -> void:
        # سرود قهرمانی اگر هنوز پخش می‌شود، تمامش کن — منو آهنگِ خودش را می‌خواهد
        if pakhsh_vizhe != null and pakhsh_vizhe.playing:
                pakhsh_vizhe.stop()
        if not pakhsh_ahang.playing:
                pakhsh_ahang.play()

func ahang_qat() -> void:
        pakhsh_ahang.stop()
        if pakhsh_vizhe != null:
                pakhsh_vizhe.stop()

func ahang_vizhe() -> void:
        # سرود کامل قهرمانی (~۵۰ ثانیه) — جای چند بیت کوتاه
        pakhsh_ahang.stop()
        if pakhsh_vizhe != null and pakhsh_vizhe.stream != null:
                pakhsh_vizhe.play()

func sfx_baz(name: String) -> void:
        if sfx.has(name):
                var p := AudioStreamPlayer.new()
                p.stream = sfx[name]
                p.volume_db = -2.0
                add_child(p)
                p.play()
                p.finished.connect(p.queue_free)

func motor_bede(active: bool, intensity: float = 0.5) -> void:
        if active:
                if not pakhsh_motor.playing:
                        pakhsh_motor.play()
                pakhsh_motor.volume_db = lerp(-26.0, -10.0, clamp(intensity, 0.0, 1.0))
                pakhsh_motor.pitch_scale = 0.85 + 0.55 * clamp(intensity, 0.0, 1.0)
        else:
                pakhsh_motor.stop()

func jigh_bede(active: bool, intensity: float = 0.6) -> void:
        if pakhsh_jigh == null or pakhsh_jigh.stream == null:
                return
        if active:
                if not pakhsh_jigh.playing:
                        pakhsh_jigh.play()
                pakhsh_jigh.volume_db = lerp(-24.0, -6.0, clamp(intensity, 0.0, 1.0))
                pakhsh_jigh.pitch_scale = 0.92 + 0.16 * clamp(intensity, 0.0, 1.0)
        else:
                pakhsh_jigh.stop()
