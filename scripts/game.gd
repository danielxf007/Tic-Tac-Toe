extends Node
signal curr_turn_changed(turn)
signal got_game_state(game_state)
const _WIN_MSSG: String = "You Win"
const _LOSE_MSSG: String = "You Lose"
const _DRAW_MSSG: String = "You Draw"
const _EMPTY_CELL: int = 2
const _N_ROWS: int = 3
const _N_COLS: int = 3
var _game_state: Array
var _curr_turn: int
var _pieces: TileMap
var _players: Array

func _ready():
	self._game_state = []
	self._pieces = $Pieces
	var row: Array
	for _i in self._N_ROWS:
		row = []
		for _j in self._N_COLS:
			row.append(2)
		self._game_state.append(row)
	self.emit_signal("got_game_state", self._game_state)
	randomize()
	self._players = [$Player, $AIPlayer]

func _coord_in_board(i: int, j: int) -> bool:
	return i>=0 and self._N_ROWS-1>=i and j>=0 and self._N_COLS-1>=j

func _valid_placement(i: int, j: int) -> bool:
	return self._coord_in_board(i, j) and self._game_state[i][j] == 2

func _set_piece(i: int, j: int, piece: int) -> void:
	self._pieces.set_cell(j, i, piece)
	self._game_state[i][j] = piece

func _reset_game_state() -> void:
	for i in self._N_ROWS:
		for j in self._N_COLS:
			self._game_state[i][j] = 2

func _next_turn() -> void:
	self._curr_turn +=1
	self._curr_turn %= self._players.size()
	self.emit_signal("curr_turn_changed", self._curr_turn)

func _set_curr_turn(value: int) -> void:
	self._curr_turn = value
	self.emit_signal("curr_turn_changed", value)

func _player_wins(game_state: Array, piece: int) -> bool:
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

func _check_game_status(game_state: Array, player_type: int, piece: int) -> void:
	if self._player_wins(game_state, piece):
		if player_type == 0:
			$Label.text = self._WIN_MSSG
		else:
			$Label.text = self._LOSE_MSSG
	elif self._draw(game_state):
		$Label.text = self._DRAW_MSSG


func play_turn(player_type: int, piece: int, b_coord: Vector2) -> void:
	if self._valid_placement(b_coord.x, b_coord.y):
		self._set_piece(b_coord.x, b_coord.y, piece)
		self._check_game_status(self._game_state, player_type, piece)
		$Timer.start()
		yield($Timer, "timeout")
		self._next_turn()

func _on_Start_button_down() -> void:
	self._players[0].set_turn(1)
	self._players[0].set_piece(1)
	self._players[1].set_turn(0)
	self._players[1].set_piece(0)
	$Start.hide()
	self._set_curr_turn(0)

func _on_Reset_button_down() -> void:
	self._pieces.clear()
	self._reset_game_state()
	self._set_curr_turn(0)
	$Label.text = ""
