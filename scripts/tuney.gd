class_name Tuney
extends Area2D


signal was_tapped
signal was_failed


enum Direction {
	LEFT,
	SLIGHT_LEFT,
	CENTER,
	SLIGHT_RIGHT,
	RIGHT,
}


const animation_directions = [
	"Left",
	"Slight Left",
	"Center",
	"Slight Right",
	"Right",
]


@export var direction: Direction = Direction.CENTER
@export var non_looping_anims: Array[String] = []


var failed: bool = false
var waiting: bool = false
var tapped: bool = false

var _tween: Tween


func _ready() -> void:
	var animplayer: AnimationPlayer = $tuney/AnimationPlayer
	for anim_name in non_looping_anims:
		var anim: Animation = animplayer.get_animation(anim_name)
		anim.loop_mode = Animation.LOOP_NONE


func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if not (event is InputEventScreenTouch or event is InputEventMouseButton):
		return
	if not event.pressed:
		return
	
	if failed or tapped:
		return
	
	if _tween:
		_tween.stop()
	
	var anim = ""
	var duration = 0.0
	
	if waiting:
		tapped = true
		was_tapped.emit()
		anim = "Tap Normal"
		duration = get_anim_duration(anim)
	else:
		failed = true
		was_failed.emit()
		anim = "Zapped"
		duration = 0.4
	
	
	$tuney/AnimationPlayer.play(anim)
	_tween = create_tween()
	_tween.tween_callback(queue_free).set_delay(duration)


func setup(from: Vector2, to: Vector2, duration: float, use_offset: bool = false, offset: float = 0.5) -> void:
	position = from
	
	var end = Vector2(to.x + (to - from).x * 0.5, 400 + 10)
	
	var angle = from.angle_to_point(to) + PI / 2
	if abs(angle) < 0.0001:
		direction = Direction.CENTER
	if abs(angle) >= 0.0001:
		direction = Direction.SLIGHT_LEFT if angle < 0 else Direction.SLIGHT_RIGHT
	if abs(angle) >= PI / 8: #22.5 deg
		direction = Direction.LEFT if angle < 0 else Direction.RIGHT
	$tuney/AnimationPlayer.play(jumping_anim_name())
	
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_parallel(true)
	_tween.tween_property(self, "position:x", to.x, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "position:y", to.y, duration)
	_tween.tween_callback(flip).set_delay(duration - get_flip_duration())
	_tween.tween_callback(func(): waiting = true).set_delay(duration - 0.2)
	_tween.chain().tween_property(self, "position:y", end.y, duration * 0.7).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "position:x", end.x, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_tween.tween_callback(miss).set_delay(0.2)
	_tween.tween_callback(fall).set_delay(get_anim_duration("Missed"))
	_tween.chain().tween_callback(queue_free)


func flip() -> void:
	$tuney/AnimationPlayer.play(flipping_anim_name())


func miss() -> void:
	failed = true
	was_failed.emit()
	$tuney/AnimationPlayer.play("Missed")


func fall() -> void:
	$tuney/AnimationPlayer.play("Falling")


func get_flip_duration() -> float:
	return get_anim_duration(flipping_anim_name())


func get_anim_duration(anim: String) -> float:
	return $tuney/AnimationPlayer.get_animation(anim).length


func flipping_anim_name() -> String:
	return "Flipping " + animation_directions[direction]


func jumping_anim_name() -> String:
	return "Jumping " + animation_directions[direction]
