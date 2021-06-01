extends Node

func _row_win(game_state: Array, piece: int) -> bool:
	var win: bool = false
	for row in game_state:
		if row.count(piece) == row.size():
			win = true
			break
	return win

func _col_win(game_state: Array, piece: int) -> bool:
	var win: bool
	var n_rows: int = game_state.size()
	var m_cols: int = game_state[0].size()
	for j in range(m_cols):
		for i in range(n_rows):
			win = game_state[i][j] == piece
			if not win:
				break
		if win:
			break
	return win

func _diag_win(game_state: Array, piece: int) -> bool:
	var win_r: bool
	var win_l: bool
	var k: int = game_state.size()-1
	for i in range(game_state.size()):
		win_r = game_state[i][i] == piece
		if not win_r:
			break
	for i in range(game_state.size()):
		win_l = game_state[k][i] == piece
		if not win_l:
			break
		k -= 1
	return win_r or win_l
