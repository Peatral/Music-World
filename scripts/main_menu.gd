extends Control


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
