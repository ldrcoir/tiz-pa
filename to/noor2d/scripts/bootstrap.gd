extends Node
## بوت‌استرپ: با آرگومان --sahne=نام، صحنهٔ دلخواه را سوار می‌کند
## نمونه: godot --path noor2d -- --aks --sahne=madar

func _ready() -> void:
        var nom := "menu"
        for a in OS.get_cmdline_user_args():
                if a.begins_with("--sahne="):
                        nom = a.trim_prefix("--sahne=")
        var sk := load("res://scripts/%s.gd" % nom)
        if sk == null:
                push_error("sahne nayaft: " + nom)
                get_tree().quit(1)
                return
        var n := Node2D.new()
        n.name = nom
        n.set_script(sk)
        add_child(n)
