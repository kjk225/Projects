open State

type player_move_msg = 
    | InvalidMove
    | ValidMove of string 
    | WinningMove

val string_of_player_move_msg : player_move_msg -> string

module Player 
: sig  
    (* [move b m] attempts to move the board if the specified move m
     * is valid. If valid, either ValidMove or WinningMove are returned 
     * alongside the mutated board. Otherwise, InvalidMove is returned 
     * with the same board state as before *)
    val move: board -> move -> (board * player_move_msg)
end

