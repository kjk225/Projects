type message = string

type position = int * int

type piece = 
  | Soldier of int
  | Flag
  | Bomb
  | Spy

let piece_of_string = function
  | "1" -> Soldier(1)
  | "2" -> Soldier(2)
  | "3" -> Soldier(3)
  | "4" -> Soldier(4)
  | "5" -> Soldier(5)
  | "6" -> Soldier(6)
  | "7" -> Soldier(7)
  | "8" -> Soldier(8)
  | "9" -> Soldier(9)
  | "F" | "f" | "flag" | "Flag" -> Flag
  | "B" | "b" | "bomb" | "Bomb" -> Bomb
  | "S" | "s" | "spy" | "Spy"   -> Spy
  | _ -> failwith "invalid piece_of_string"

let string_of_piece = function
  | Soldier(i) -> string_of_int i 
  | Flag -> "F"
  | Bomb -> "B"
  | Spy -> "S"

type placement = {
  piece:piece;
  position:position
}

type move = position * position

type player = 
  | Red 
  | Blue

type square = 
  | Lake
  | Empty
  | Occupied of piece * player * bool

let string_of_square square = 
    match square with
    | Lake -> "Lake"
    | Empty -> "Empty"
    | Occupied(pc,_,_) -> ("Occupied(" ^ string_of_piece pc ^ ")")

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