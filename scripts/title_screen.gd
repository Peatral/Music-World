extends Control


var tile_size = Vector2i(6, 10)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		get_tree().change_scene_to_file("res://scenes/level.tscn")


func fill_random() -> void:
	for y in tile_size.y:
		for x in tile_size.x:
			$TileMap.set_cell(0, Vector2i(x, y), $TileMap.tile_set.get_source_id(0), Vector2i(randi_range(0, 2), 0))
			$TileMap.force_update()
