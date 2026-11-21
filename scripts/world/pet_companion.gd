extends Node2D
## Companheiro da Fazenda Colonial (Caramelo — cachorro vira-lata colonial).
## Aguarda adoção na Praça do Coreto; após adotado, segue o fazendeiro,
## pode ser acariciado e encontra 1 achado de sorte por dia.

var adopted: bool = false
var pet_name: String = "Caramelo"
var found_gift_today: bool = false
var follow_target: Node2D = null

var _facing_right: bool = true
var _is_moving: bool = false
var _t: float = 0.0
var _hop_y: float = 0.0
var _follow_speed: float = 72.0


func _ready() -> void:
	z_index = 4


func set_adopted(is_adopted: bool, target: Node2D = null) -> void:
	adopted = is_adopted
	follow_target = target
	queue_redraw()


func reset_daily() -> void:
	found_gift_today = false


func trigger_happy_hop() -> void:
	var tw := create_tween()
	tw.tween_property(self, "_hop_y", -7.0, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "_hop_y", 0.0, 0.16).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


func _physics_process(delta: float) -> void:
	_t += delta
	_is_moving = false
	if adopted and follow_target != null and is_instance_valid(follow_target) and visible:
		var target_pos: Vector2 = follow_target.global_position + Vector2(-18.0 if _facing_right else 18.0, 4.0)
		var diff: Vector2 = target_pos - global_position
		var dist: float = diff.length()
		if dist > 160.0:
			global_position = target_pos
		elif dist > 14.0:
			var dir: Vector2 = diff / dist
			var spd: float = _follow_speed if dist < 60.0 else (_follow_speed * 1.45)
			global_position += dir * spd * delta
			_facing_right = dir.x >= 0.0
			_is_moving = true
	queue_redraw()


func _draw() -> void:
	var bob: float = (absf(sin(_t * 14.0)) * -2.0) if _is_moving else 0.0
	var y_off: float = bob + _hop_y
	var flip: float = 1.0 if _facing_right else -1.0

	# Sombra no chão
	draw_rect(Rect2(-6.0, 1.0, 12.0, 3.0), Color(0.08, 0.10, 0.08, 0.35))

	# Rabinho abanando
	var wag: float = sin(_t * (16.0 if adopted else 8.0)) * 2.5
	draw_line(
		Vector2(-5.0 * flip, -4.0 + y_off),
		Vector2(-8.5 * flip, -7.5 + wag * 0.4 + y_off),
		Color("#c68642"),
		2.0
	)

	# Corpo caramelo colonial
	draw_rect(Rect2(-6.0, -7.0 + y_off, 12.0, 6.0), Color("#3b2314"))
	draw_rect(Rect2(-5.0, -6.0 + y_off, 10.0, 4.5), Color("#d4954a"))
	# Patinhas
	var stride: float = sin(_t * 14.0) * 1.5 if _is_moving else 0.0
	draw_rect(Rect2(-4.5, -1.5 + stride * 0.5 + y_off, 2.0, 3.0), Color("#b57632"))
	draw_rect(Rect2(2.5, -1.5 - stride * 0.5 + y_off, 2.0, 3.0), Color("#b57632"))

	# Coleira vermelha quando adotado
	if adopted:
		draw_rect(Rect2(2.5 * flip - 1.5, -6.5 + y_off, 3.0, 4.5), Color("#d32f2f"))

	# Cabeça e orelhas caídas
	var hx: float = 4.5 * flip
	draw_rect(Rect2(hx - 4.0, -12.0 + y_off, 8.0, 6.5), Color("#3b2314"))
	draw_rect(Rect2(hx - 3.0, -11.0 + y_off, 6.0, 4.5), Color("#e0a458"))
	# Orelha
	draw_rect(Rect2(hx - 2.5 * flip - 1.0, -10.5 + y_off, 2.5, 4.0), Color("#9c5f28"))
	# Olho e focinho
	draw_rect(Rect2(hx + 0.8 * flip, -9.8 + y_off, 1.5, 1.5), Color("#1e140e"))
	draw_rect(Rect2(hx + 2.5 * flip, -8.5 + y_off, 1.8, 1.5), Color("#2b1b12"))
