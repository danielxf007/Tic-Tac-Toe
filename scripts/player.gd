extends Node
signal turn_played(player_type, piece, board_coord)
class_name Player
const _CELL_DIM: Vector2 = Vector2(190, 190)
const _INPUT_SLEEP_TIME: float = 0.1
const _PLAYER_TYPE: int = 0
var _input_timer: Timer
var _piece: int
var _turn: int
var _playing: bool

func _ready():
	self._input_timer = Timer.new()
	self._input_timer.wait_time = self._INPUT_SLEEP_TIME
	self._input_timer.one_shot = true
	self.add_child(self._input_timer)
	self._playing = false

func set_piece(piece: int) -> void:
	self._piece = piece

func set_turn(turn: int) -> void:
	self._turn = turn

func get_turn() -> int:
	return self._turn

func _get_to_board_coord(coord: Vector2) -> Vector2:
	var board_coord: Vector2 = Vector2()
	board_coord.y = floor(coord.x/self._CELL_DIM.x)
	board_coord.x = floor(coord.y/self._CELL_DIM.y)
	return board_coord

func _input(event):
	if self._playing and event is InputEventMouseButton and self._input_timer.is_stopped():
		var coord: Vector2 = self._get_to_board_coord(event.position)
		self.emit_signal("turn_played", self._PLAYER_TYPE, self._piece, coord)
		self._input_timer.start()


func _on_Game_curr_turn_changed(turn: int) -> void:
	self._playing = self._turn == turn
