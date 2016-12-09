type message = string

(* [position] is a position the board *)
type position = int * int

(* [piece] is a piece in the army. *)
type piece = 
    | Soldier of int
    | Flag
    | Bomb
    | Spy
    
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
| Start
| BoardBuilding
| GamePlay
| EndGame

