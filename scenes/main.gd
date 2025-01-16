extends Node

@export var snake: Array[Vector2i]

class Tile:
	const FLOOR := Vector2i(1,1)
	const SNAKE := Vector2i(1,3)
	const HEAD := Vector2i(0, 3)
	const FOOD := Vector2i(2,3)
	const WALL := Vector2i(6,2)

var dir := Vector2i.UP
var prev_dir := Vector2i.UP

func _ready() -> void:
	draw_snake(Vector2i(-1,-1), false)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		dir = Input.get_vector(&"left", &"right", &"up", &"down")
	if  event.is_action_pressed(&"close"):
		get_tree().quit()

func move(move_dir: Vector2i):
	# Prevent snake from moving back to itself
	if move_dir == -prev_dir:
		move_dir = prev_dir
	prev_dir = move_dir
	
	var ate := false
	# Position where head will be next
	var next_pos: Vector2i = snake[0] + move_dir
	# Position where tail was
	var clear_pos: Vector2i = snake[-1]
	
	# Check collision with walls, self, or food
	var next_tile_data: TileData = %TileMap.get_cell_tile_data(next_pos)
	if next_tile_data.get_custom_data("death"):
		get_tree().reload_current_scene()
		return
	elif next_tile_data.get_custom_data("interactable"):
		snake.append(clear_pos)
		# Don't clear anything this round if we ate, so we can add new tail
		ate = true
	# Move
	# Invert i, so we can go from tail to head
	for i in range(1, snake.size()):
		snake[-i] = snake[-i-1]
	snake[0] = next_pos
	# Draw snake
	draw_snake(clear_pos, ate)
	# Spawn new food
	if ate:
		spawn_food()

func draw_snake(clear_pos: Vector2i, keep_tile: bool):
	%TileMap.set_cell(snake[0], 0, Tile.HEAD)
	%TileMap.set_cell(snake[1], 0, Tile.SNAKE)
	# Keep tail if we ate
	if keep_tile:
		return
	%TileMap.set_cell(clear_pos, 0, Tile.FLOOR)

# Spawn new food by getting all emtpy floor tiles
func spawn_food() -> void:
	var cells = %TileMap.get_used_cells_by_id(0, Vector2i(1, 1))
	%TileMap.set_cell(cells.pick_random(), 0, Tile.FOOD)

# Move every tick
func _on_timer_timeout() -> void:
	move(dir)
