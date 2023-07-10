class_name Level
extends Node2D


const TARGET_SPINNER_SCENE: PackedScene = preload("res://scenes/target_spinner.tscn")
const TUNEY_SCENE: PackedScene = preload("res://scenes/tuney.tscn")


# Only used to track in animation as the spawning of tuneys actually predates the keys
@export var use_offset: bool = false
@export_range(0.0, 1.0) var offset: float = 0.5

@export var tuney_speed: float = 150


func _ready() -> void:
	var anim: Animation = $AnimationPlayer.get_animation("morning_dew")
	
	var position_track = anim.find_track(NodePath("TuneyMarker:position"), Animation.TYPE_VALUE)
	var use_offset_track = anim.find_track(NodePath(".:use_offset"), Animation.TYPE_VALUE)
	var offset_track = anim.find_track(NodePath(".:offset"), Animation.TYPE_VALUE)
	var method_track = anim.add_track(Animation.TYPE_METHOD)
	anim.track_set_path(method_track, ".")
	
	var keys = anim.track_get_key_count(1)
	
	for key in keys:
		var key_time = anim.track_get_key_time(position_track, key)
		var target_position = anim.track_get_key_value(position_track, key)
		var start_position = get_tuney_start_position(
				target_position, 
				anim.value_track_interpolate(use_offset_track, key_time), 
				anim.value_track_interpolate(offset_track, key_time))
		var duration = max(0.54, get_tuney_duration(start_position, target_position))
		
		var spawn_key_time = key_time - duration
		
		var key_value = {
			"method": &"spawn_tuney",
			"args": [
				start_position,
				target_position,
				duration,
			]
		}
		
		anim.track_insert_key(method_track, spawn_key_time, key_value)
	$TuneyMarker.visible = false
	$AnimationPlayer.play("morning_dew")


func _tuney_tapped():
	$PuzzleTiles.reveal_random()


func get_tuney_duration(from: Vector2, to: Vector2) -> float:
	return from.distance_to(to) / tuney_speed


func get_tuney_start_position(to: Vector2, use_off: bool, off: float) -> Vector2:
	return Vector2(240 * off if use_off else to.x, 400)


func spawn_tuney(from: Vector2, to: Vector2, duration: float, show_marker: bool = true, bounce: bool = false) -> void:
	var marker
	if show_marker:
		marker = TARGET_SPINNER_SCENE.instantiate()
		marker.position = to
		marker.z_index = -1
		add_child(marker)
		create_tween().tween_callback(marker.queue_free).set_delay(duration)
	
	var tuney = TUNEY_SCENE.instantiate()
	add_child(tuney)
	tuney.was_tapped.connect(_tuney_tapped)
	tuney.was_failed.connect(func(): pass)
	tuney.setup(from, to, duration)

