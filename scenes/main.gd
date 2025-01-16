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
	draw_snake(Vector2i(-1,-1))

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"up"):
		dir = Vector2i.UP
	if Input.is_action_just_pressed(&"down"):
		dir = Vector2i.DOWN
	if Input.is_action_just_pressed(&"left"):
		dir = Vector2i.LEFT
	if Input.is_action_just_pressed(&"right"):
		dir = Vector2i.RIGHT
	if  Input.is_action_just_pressed(&"close"):
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
	var next_Tile_data: TileData = %TileMap.get_cell_tile_data(next_pos)
	if next_Tile_data.get_custom_data("death"):
		get_tree().reload_current_scene()
		return
	elif next_Tile_data.get_custom_data("interactable"):
		snake.append(clear_pos)
		# Don't clear anything this round if we ate, so we can add new tail
		clear_pos = Vector2i(-1, -1)
		ate = true

	# Move
	for i in range(-1, -snake.size(), -1):
		snake[i] = snake[i-1]
	snake[0] = next_pos

	# Draw snake
	draw_snake(clear_pos)
	
	# Spawn new food
	if ate:
		spawn_food()

func draw_snake(clear_pos: Vector2i):
	%TileMap.set_cell(snake[0], 0, Tile.HEAD)
	%TileMap.set_cell(snake[1], 0, Tile.SNAKE)
	# Clear tail only if we didn't eat
	if clear_pos != Vector2i(-1, -1):
		%TileMap.set_cell(clear_pos, 0, Tile.FLOOR)

# Spawn new food by getting all emtpy floor tiles
func spawn_food() -> void:
	var cells = %TileMap.get_used_cells_by_id(0, Vector2i(1, 1))
	%TileMap.set_cell(cells.pick_random(), 0, Tile.FOOD)

# Move every tick
func _on_timer_timeout() -> void:
	move(dir)
