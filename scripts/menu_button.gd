@tool
extends Control

@export var text: Texture = preload("res://assets/sprites/menu/play.png"):
	set(value):
		text = value
		$Background/Text.texture_normal = value

@export var background: Texture = preload("res://assets/sprites/menu/menu_button.png"):
	set(value):
		background = value
		$Background.texture = value

signal pressed

func _on_text_pressed():
	pressed.emit()