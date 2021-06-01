extends Node
signal turn_played(player_type, piece, board_coord)
class_name AIPlayer
const _N_ROWS: int = 3
const _M_COLS: int = 3
const _EMPTY_CELL: int = 2
const _PLAYER_TYPE: int = 1
var _piece: int
var _turn: int
var _game_state: Array
var _movements: Array
var _best_movement: Vector2

func _ready():
	self._movements = []
	self._best_movement = Vector2()
	for i in range(self._N_ROWS):
		for j in range(self._M_COLS):
			self._movements.append(Vector2(i, j))
	randomize()

func set_piece(piece: int) -> void:
	self._piece = piece

func set_turn(turn: int) -> void:
	self._turn = turn

func _ai_wins(game_state: Array) -> bool:
	var result: bool = Util._col_win(game_state, self._piece)
	result = result or Util._row_win(game_state, self._piece)
	result = result or Util._diag_win(game_state, self._piece)
	return result

func _player_wins(game_state: Array) -> bool:
	var piece: int = (self._piece+1)%2
	var result: bool = Util._col_win(game_state, piece)
	result = result or Util._row_win(game_state, piece)
	result = result or Util._diag_win(game_state, piece)
	return result

func _draw(game_state: Array) -> bool:
	var draw: bool = true
	for row in game_state:
		if row.find(self._EMPTY_CELL) != -1:
			draw = false
			break
	return draw

func _get_game_status(game_state: Array) -> int:
	var status: int = 3
	if self._ai_wins(game_state):
		status = 0
	elif self._player_wins(game_state):
		status = 1
	elif self._draw(game_state):
		status = 2
	return status

func _minimax(game_state: Array, depth: int, max_player: bool) -> int:
	var value: int
	var best_value: int
	var i: int
	var j: int
	match self._get_game_status(game_state):
		0:
			best_value = 10-depth
		1:
			best_value = depth-10
		2:
			best_value = 5-depth
		3:
			if max_player:
				best_value = -1000
				for movement in self._movements:
					i = movement.x
					j = movement.y
					if game_state[i][j] == self._EMPTY_CELL:
						game_state[i][j] = self._piece
						value = self._minimax(game_state, depth+1, false)
						if value > best_value:
							best_value = value
							self._best_movement = movement
						game_state[i][j] = self._EMPTY_CELL
			else:
				best_value = 1000
				for movement in self._movements:
					i = movement.x
					j = movement.y
					if game_state[i][j] == self._EMPTY_CELL:
						game_state[i][j] = (self._piece+1)%2
						value = self._minimax(game_state, depth+1, true)
						if value < best_value:
							best_value = value
							self._best_movement = movement
						game_state[i][j] = self._EMPTY_CELL
	return best_value

func _empty_game_state(game_state: Array):
	var empty: bool = true
	for i in range(self._N_ROWS):
		for j in range(self._M_COLS):
			if game_state[i][j] != self._EMPTY_CELL:
				empty = false
				break
	return empty

func _on_Game_curr_turn_changed(turn: int) -> void:
	if self._turn == turn:
		if self._empty_game_state(self._game_state):
			self._best_movement = self._movements[randi()%self._movements.size()]
		else:
# warning-ignore:return_value_discarded
			self._minimax(self._game_state, 0, true)
		$Timer.start()

func _on_Game_got_game_state(game_state: Array) -> void:
	self._game_state = game_state

func _on_Timer_timeout() -> void:
	self.emit_signal("turn_played", self._PLAYER_TYPE, self._piece, self._best_movement)
