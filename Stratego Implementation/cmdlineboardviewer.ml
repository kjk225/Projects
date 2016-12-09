open State
open ANSITerminal

module Cmdlineboardviewer = struct
  
  let string_of_piece = function
    | Spy ->  "S"
    | Flag -> "F"
    | Bomb -> "B"
    | Soldier(i) -> (string_of_int i) 

  (* Print the board with the perspective of the *client*. Therefore, all 
   * printing on red is visible whereas printing on blue is only visible 
   * if they won a battle.  *)
  let string_of_square = function
    | Empty -> " "
    | Lake ->  "L"
    | Occupied(pc,Blue,false) -> "x"
    | Occupied(pc,_,_) -> string_of_piece pc 

  let style_of_square s = 
    let open ANSITerminal in 
    match s with 
    | Empty -> black 
    | Lake -> cyan
    | Occupied(_,Blue,_) -> blue
    | Occupied(_,Red,_) -> red

  let display_piece pc =
    let bg = ANSITerminal.on_black in 
    let text_color = ANSITerminal.red in 
    match pc with 
    | None -> ANSITerminal.sprintf [bg;text_color] "  " 
    | Some pc -> ANSITerminal.sprintf [bg;text_color] "%s " (string_of_piece pc)

  let display_square sq = 
    let bg = ANSITerminal.on_black in 
    let text_color = style_of_square sq in 
    ANSITerminal.sprintf [bg;text_color] "%s " (string_of_square sq)

  (* Print the board with the perspective of the *client* *)
  let display_board (b:board) = 
    let print_width = 22 in 
    let buf = Buffer.create (print_width*print_width) in 
    for y=0 to 9 do 
      (* Print column headers *)
      Buffer.add_string buf (string_of_int (9-y));
      for x=0 to 9 do 
        Buffer.add_string buf (display_square b.board_state.(x).(9-y));
      done;
      Buffer.add_string buf "\n";
    done;
    Buffer.add_string buf " 0 1 2 3 4 5 6 7 8 9\n";
    Pervasives.print_string (Buffer.contents buf)

  (* TODO: Do without the pasta *)
  let display_build (t:piece option array array) = 
   let print_width = 22 in 
   let buf = Buffer.create (print_width*print_width) in 
    for y=0 to 9 do 
      (* Print column headers *)
      Buffer.add_string buf (string_of_int (9-y));
      for x=0 to 9 do 
        Buffer.add_string buf (display_piece t.(x).(9-y));
      done;
      Buffer.add_string buf "\n";
    done;
    Buffer.add_string buf " 0 1 2 3 4 5 6 7 8 9\n";
    Pervasives.print_string (Buffer.contents buf) 

end 