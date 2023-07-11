extends TileMap


enum Mode {
	HORIZONTAL,
	VERTICAL,
}


const REVEAL_H: Texture = preload("res://assets/textures/backgrounds/puzzle_tiles/reveal_h.png")
const REVEAL_V: Texture = preload("res://assets/textures/backgrounds/puzzle_tiles/reveal_v.png")


@export var size: Vector2i = Vector2i(7, 11)


var revealed_tiles: PackedVector2Array = PackedVector2Array()


func _ready() -> void:
	setup(1)


func setup(layer: int) -> void:
	for x in size.x:
		for y in size.y:
			var mode = get_cell_mode(Vector2i(x, y))
			var tile_x = 0 if mode == Mode.HORIZONTAL else 1
			set_cell(layer, Vector2i(x, y), tile_set.get_source_id(0), Vector2i(tile_x, layer))


func get_cell_mode(pos: Vector2i) -> Mode:
	return Mode.HORIZONTAL if pow(-1, pos.x + pos.y) == 1 else Mode.VERTICAL 


func reveal_random() -> void:
	if revealed_tiles.size() >= size.x * size.y:
		return
	
	var pos = Vector2i(randi_range(0, size.x), randi_range(0, size.y))
	if revealed_tiles.has(pos) or get_cell_atlas_coords(0, pos) == Vector2i(-1, -1):
		reveal_random()
	else:
		var sprite = Sprite2D.new()
		sprite.texture = REVEAL_H if Mode.HORIZONTAL else REVEAL_V
		sprite.position = map_to_local(pos)
		add_child(sprite)
		var tween = sprite.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_property(sprite, "position", sprite.position + Vector2(0, -10), 0.3)
		tween.tween_callback(sprite.queue_free)
		erase_cell(1, pos)
		revealed_tiles.append(pos)
