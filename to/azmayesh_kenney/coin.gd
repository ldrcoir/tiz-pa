# سکه و جواهر — چرخش بالا-پایین و برداشتن
extends Area2D

signal got(kind: String)

var base_y := 0.0
var t := 0.0
var kind := "coin"
var picked := false

func setup(y: float, phase: float, kind_name: String, tex: Texture2D) -> void:
	base_y = y
	t = phase
	kind = kind_name
	spr_setup(tex)

func spr_setup(tex: Texture2D) -> void:
	var s := Sprite2D.new()
	s.texture = tex
	s.scale = Vector2(3.0, 3.0) if kind == "coin" else Vector2(3.2, 3.2)
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(s)
	var shape := CollisionShape2D.new()
	var c := CircleShape2D.new()
	c.radius = 26.0
	shape.shape = c
	add_child(shape)
	body_entered.connect(_on_body)

func _physics_process(delta: float) -> void:
	t += delta
	position.y = base_y + sin(t * 3.0) * 6.0

func _on_body(body: Node) -> void:
	if picked:
		return
	if body.is_in_group("player"):
		picked = true
		set_deferred("monitoring", false)
		emit_signal("got", kind)
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(self, "scale", Vector2(1.8, 1.8), 0.25)
		tw.tween_property(self, "modulate:a", 0.0, 0.25)
		tw.chain().tween_callback(queue_free)
