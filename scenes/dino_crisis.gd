extends Node
var S = [Vector2i(3,3),Vector2i(3,4),Vector2i(3,5)]
var pv = Vector2i.UP
var IV = Vector2i.UP
func _unhandled_key_input(_event):
	if _event.is_action_pressed("close"): get_tree().quit()

func _ready() -> void:
	var t = get_child(1)
	t.timeout.connect(func(): Can_Move = true)
	
class AT:
	const Floor = Vector2i(1,1)
	const Snake = Vector2i(1,3)
	const head = Vector2i(0, 3)
	const Food = Vector2i(2,3)
	const Wall = Vector2i(6,2)
var Can_Move = true
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("up"): IV = Vector2i.UP
	if Input.is_action_just_pressed("down"): IV = Vector2i.DOWN
	if Input.is_action_just_pressed("right"): IV = Vector2i.RIGHT
	if Input.is_action_just_pressed("left"): IV = Vector2i.LEFT
	if Can_Move:
		if IV == -pv or IV == Vector2i.ZERO: IV = pv
		pv = IV
		var a_f = false
		var n_h_p: Vector2i = S[0] + IV
		var TCP: Vector2i = S[-1]
		var npd: TileData = $"%TileMap".get_cell_tile_data(n_h_p)
		if npd.get_custom_data("kill_snake"): get_tree().reload_current_scene(); return
		elif npd.get_custom_data("food"): S.append(TCP); a_f = true
		for i in range(1, S.size()): S[-i] = S[-i-1]
		S[0] = n_h_p
		var Draw = func(clr_pos,keep_tile):
			$"%TileMap".set_cell(S[0], 0, AT.head); $"%TileMap".set_cell(S[1], 0, AT.Snake); if keep_tile: return
			$"%TileMap".set_cell(clr_pos, 0, AT.Floor)
		Draw.call(TCP, a_f)
		if a_f: $"%TileMap".set_cell($"%TileMap".get_used_cells_by_id(0, Vector2i(1, 1)).pick_random(), 0, AT.Food)
		Can_Move = false
