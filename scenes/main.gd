extends Node

@export var snake: Array[Vector2i]

var input_vector := Vector2i.UP
var prev_vector := Vector2i.UP

@onready var tilemap: TileMapLayer = %TileMap

func _unhandled_key_input(event: InputEvent) -> void:
	# Get input vector
	if event is InputEventKey and event.is_pressed():
		input_vector = Input.get_vector(&"left", &"right", &"up", &"down")
		print(input_vector)
	# Close game
	if  event.is_action_pressed(&"close"):
		get_tree().quit()

func move(move_vector: Vector2i) -> void:
	# Prevent snake from moving back to itself
	if move_vector == -prev_vector or move_vector == Vector2i.ZERO:
		move_vector = prev_vector

	prev_vector = move_vector
	
	var ate_food := false
	# Position where head will be next
	var new_head_pos: Vector2i = snake[0] + move_vector
	# Position where tail was
	var tail_clear_pos: Vector2i = snake[-1]
	
	# Check collision with walls, self, or food
	var next_pos_data: TileData = %TileMap.get_cell_tile_data(new_head_pos)
	if next_pos_data.get_custom_data("kill_snake"):
		get_tree().reload_current_scene()
		return
	elif next_pos_data.get_custom_data("food"):
		snake.append(tail_clear_pos)
		# Don't clear anything this round if we ate, so we can add new tail
		ate_food = true
	# Move
	# Invert i, so we can go from tail to head
	for i in range(1, snake.size()):
		snake[-i] = snake[-i-1]

	snake[0] = new_head_pos
	# Draw snake
	draw_snake(tail_clear_pos, ate_food)
	# Spawn new food
	if ate_food:
		spawn_food()

func draw_snake(tail_clear_pos: Vector2i, keep_tile: bool) -> void:
	tilemap.set_cell(snake[0], 0, AtlasTile.HEAD)
	tilemap.set_cell(snake[1], 0, AtlasTile.SNAKE)
	# Keep tail if we ate food
	if keep_tile:
		return
	tilemap.set_cell(tail_clear_pos, 0, AtlasTile.FLOOR)

# Spawn new food by getting all emtpy floor cells
func spawn_food() -> void:
	var floor_cells = tilemap.get_used_cells_by_id(0, Vector2i(1, 1))
	tilemap.set_cell(floor_cells.pick_random(), 0, AtlasTile.FOOD)

# Move every tick
func _on_timer_timeout() -> void:
	move(input_vector)

# Atlas tiles
class AtlasTile:
	const FLOOR := Vector2i(1,1)
	const SNAKE := Vector2i(1,3)
	const HEAD := Vector2i(0, 3)
	const FOOD := Vector2i(2,3)
	const WALL := Vector2i(6,2)
