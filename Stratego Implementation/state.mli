type message = string

(* [position] is a position the board *)
type position = int * int

(* [piece] is a piece in the army. *)
type piece = 
  | Soldier of int
  | Flag
  | Bomb
  | Spy

(* [piece_of_string s] returns the string representation of a given piece 
 * such that piece_of_string (string_of_piece p) = p. If the string doesn't
 * adhere to anything, piece_of_string throws an exception. *)
val piece_of_string: string -> piece

(* [string_of_piece p] returns the string representation of a given piece. 
* if the piece is a soldier, only the integer representing it is returned. *)
val string_of_piece: piece -> string
  
(* [placement] is the position and piece on the board where the
* player wants add his piece*)
type placement = {
  piece:piece;
  position:position
}

(* [move] is the beginning and end postion of a piece on
* the board *)
type move = position * position

(* [player] represents the player of the game *)
type player = 
  | Red 
  | Blue

(* [square] represents the contents of a square on the board *)
type square = 
  | Lake
  | Empty
  | Occupied of piece * player * bool
  
(* [string_of_square] returns the string representation of a given square. 
 * If the square is occupied, it will return the piece that occupies it, 
 * but not the player that owns it or whether it is visible to a given side *)
val string_of_square : square -> string 

(* [board] represents the board used in the game *)
type board = {
  board_state:square array array;
  turn:int;
  player_to_move: player
}

type screen_state =
  | MainMenu
  | HelpScreen
  | SetupScreen
  | GameScreen
  | WinScreen 

type game_state = 
  | Begin
  | Build of piece option array array
  | Gameplay of board
  | EndGame