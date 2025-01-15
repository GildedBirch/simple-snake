extends Node

@export var snake: Array[Vector2i]

class TILE:
	const FLOOR := Vector2i(1,1)
	const SNAKE := Vector2i(1,3)
	const HEAD := Vector2i(0, 3)
	const FOOD := Vector2i(2,3)
	const WALL := Vector2i(6,2)

var dir := Vector2i.UP

func _ready() -> void:
	draw_snake(Vector2i(-1,-1))

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"up"):
		dir = Vector2i.UP
	if Input.is_action_just_pressed(&"down"):
		dir = Vector2i.DOWN
	if Input.is_action_just_pressed(&"left"):
		dir = Vector2i.LEFT
	if Input.is_action_just_pressed(&"right"):
		dir = Vector2i.RIGHT

func move(move_dir: Vector2i):
	var ate := false
	var next_pos: Vector2i = snake[0] + move_dir
	
	var next_tile_data: TileData = %TileMap.get_cell_tile_data(next_pos)
	if next_tile_data.get_custom_data("death"):
		get_tree().quit()
		return
	elif next_tile_data.get_custom_data("interactable"):
		snake.append(snake[-1])
		ate = true

	for i in range(snake.size()):
		var new_pos: Vector2i = next_pos
		next_pos = snake[i]
		snake[i] = new_pos
	draw_snake(next_pos)
	if ate: spawn_food()

func draw_snake(clear_pos: Vector2i):
	for snake_pos: Vector2i in snake:
		%TileMap.set_cell(snake_pos, 0, TILE.SNAKE)
	%TileMap.set_cell(snake[0], 0, TILE.HEAD)
	%TileMap.set_cell(clear_pos, 0, TILE.FLOOR)

func spawn_food() -> void:
	var area := []
	for y in range(1,6):
		for x in range(1,8):
			var pos := Vector2i(x, y)
			if not snake.has(pos):
				area.append(pos)
	%TileMap.set_cell(area.pick_random(), 0, TILE.FOOD)

func _on_timer_timeout() -> void:
	move(dir)
