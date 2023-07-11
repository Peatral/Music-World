@tool
extends Control


signal pressed


@export var text: Texture = preload("res://assets/textures/menu/play.png"):
	set(value):
		text = value
		$Background/Text.texture_normal = value

@export var background: Texture = preload("res://assets/textures/menu/menu_button.png"):
	set(value):
		background = value
		$Background.texture = value


func _on_text_pressed() -> void:
	pressed.emit()
