open State

type add_msg =
  | SquareOccupied
  | PieceAlreadyUsed
  | IllegalAddSquare
  | ValidAdd

let string_of_add_msg = function
  | SquareOccupied -> "The square is currently occupied. Remove from this square first if you want to take it."
  | PieceAlreadyUsed -> "There are no more pieces of this kind left to place."
  | IllegalAddSquare -> "You cannot add pieces from squares not in the first 4 rows"
  | ValidAdd -> "Piece successfully added"

type rem_msg =
  | SquareEmpty
  | IllegalRemoveSquare
  | ValidRemove

let string_of_rem_msg = function
  | SquareEmpty -> "The square is empty, so nothing can be removed."
  | IllegalRemoveSquare -> "You cannot remove pieces from squares not in the first 4 rows."
  | ValidRemove -> "Piece successfully removed from the board."

type build_msg =
  | BuildComplete
  | BuildIncomplete

let string_of_build_msg = function
  | BuildComplete -> "BuildComplete"
  | BuildIncomplete -> "BuildIncomplete"

module Boardbuilder = struct
  type int_piece_map = (piece * int) list
  type t = piece option array array * int_piece_map

  (* I wasn't able to get OCaml maps working within a reasonable amount of
   * time, so I instead decided to use association lists with the appropriate
   * functions implemented. *)
  let map_find piece m =
    List.assoc piece m

  let map_mem piece m =
    List.mem_assoc piece m

  let map_remove piece m =
    List.remove_assoc piece m

  let map_empty m =
    m = []

  let map_add piece value m =
    if map_mem piece m then
      let new_map = map_remove piece m in
      (piece,value)::new_map
    else
      (piece,value)::m

  (* [decr pl piece] decrements the count of the piece. If equal to 0, it
   * is removed *)
  let map_decr pieces_left piece:int_piece_map =
    let new_count = ((map_find piece pieces_left) - 1) in
    let decremented = map_add piece new_count pieces_left in
    if map_find piece decremented = 0 then
      map_remove piece decremented
    else
      decremented

  (* [map_incr pl piece] decrements the count of the piece. If not in the
   * list, it is added with count 1 *)
  let map_incr pieces_left piece:int_piece_map =
    if map_mem piece pieces_left then
      map_add piece ((map_find piece pieces_left) + 1) pieces_left
    else
      map_add piece 1 pieces_left

  (* [make] should be automatically called and creates an empty board
   * and creates the original full pieceslist*)
  let pieces_initially_left () =
    []
    |> map_add (Spy) 1 |> map_add (Bomb) 6 |> map_add (Flag) 1
    |> map_add (Soldier(1)) 1 |> map_add (Soldier(2)) 1
    |> map_add (Soldier(3)) 2 |> map_add (Soldier(4)) 3
    |> map_add (Soldier(5)) 4 |> map_add (Soldier(6)) 4
    |> map_add (Soldier(7)) 4 |> map_add (Soldier(8)) 5
    |> map_add (Soldier(9)) 8

  let make ():t =
    let board = Array.make_matrix 10 10 None in
    for x = 0 to 9 do 
      for y = 0 to 9 do 
        board.(x).(y) <- None; 
      done;
    done;
    (board, pieces_initially_left ())

  let add (b,pieces_left) placement : t * add_msg =
    let piece = placement.piece in
    let (x,y) = placement.position in
    if y >= 4 then
      (b,pieces_left) , IllegalAddSquare
    else
    match b.(x).(y) with
    | None when map_mem piece pieces_left -> begin
        b.(x).(y) <- Some piece;
        (b,map_decr pieces_left piece) , ValidAdd
    end
    | None ->
        (b,pieces_left) , PieceAlreadyUsed
    | Some(_) ->
      (b,pieces_left) , SquareOccupied

  let remove (b,pl) (x,y):t*rem_msg =
    if y >= 4 then
      (b,pl), IllegalRemoveSquare
    else
    match b.(x).(y) with
    | Some(pc) -> begin
      b.(x).(y) <- None;
      (b,map_incr pl pc) , ValidRemove
    end
    | None ->
      (b, pl) , SquareEmpty

  (* [help bboard] is a message to help the player setup the board*)
  let help (b,pl):message =
    if map_empty pl then
      "You are ready to start. Type build"
    else
      "There are three commands available: \n"^
      "add piece x y-\n"^
      "  add a piece on row x and column y. The piece can be\n"^
      "  either an integer from 1-10 for its power, a spy, a\n"^
      "  bomb, or a flag. Valid x coordinates are from 0 to 9\n"^
      "  and valid y coordinates are from 0 to 3\n"^
      "remove x y-\n"^
      "  remove a piece on row x and column y.\n"^
      "build-\n"^
      "  Confirm your build! Now you can start playing the game.\n"^
      "reset-\n"^
      "  Reset the board to the initial build state.\n"^
      "finish-\n"^
      "  Stop with custom building and fill the rest of your board with\n"^
      "  random pieces.\n"

  let ready_to_build (b,pl) =
    List.length pl = 0

  let parse_ai_board j =
    (* Some of these anonymous functions are taken from my implementation of
     * A2-gn93 *)
    let open Yojson.Basic.Util in
    let json_to_string = fun j m -> j |> member m |> to_string in
    let json_to_list = fun j f m -> j |> member m |> to_list |> List.map f in
    let json_to_int = fun j m -> j |> member m |> to_int in
    let parse_square j =
      let position = (json_to_int j "x", json_to_int j "y") in
      let piece = "piece" |> json_to_string j |> piece_of_string in
      {position; piece} in
    "contents" |> json_to_list j parse_square

  let rec add_ai_pieces_to_board (b:square array array) = function
    | [] -> b
    | h::tl -> begin
      let piece = h.piece in
      let (x,y) = h.position in
      let () = b.(x).(y) <- (Occupied(piece,Blue,false)) in
      add_ai_pieces_to_board b tl
    end

  (* http://stackoverflow.com/questions/15095541/ *)
  let shuffle d =
    Random.self_init ();
    let nd = List.map (fun c -> (Random.bits (), c)) d in
    let sond = List.sort compare nd in
    List.map snd sond

  (* [(a,1);(b;2)] --> [a;b;b] *)
  let expand pl =
    let rec exp (x,n) =
      match n with
      | 0 -> []
      | n -> x::(exp (x,(n-1))) in
    pl |> List.map exp |> List.flatten

  let build_ai_board b =
    Random.self_init ();
    let filename = "aiboard" ^ (string_of_int (Random.int 8)) ^ ".json" in 
    let json = Yojson.Basic.from_file filename in 
    let pieces_to_add = parse_ai_board json in 
    add_ai_pieces_to_board b pieces_to_add 
    (* let pieces_left_expanded = ref  *)
    (*   (pieces_initially_left () |> expand |> shuffle) in  *)
    (* for x = 0 to 9 do *)
    (*   for y = 6 to 9 do *)
    (*     match !pieces_left_expanded with *)
    (*     | [] -> failwith "build ai board" *)
    (*     | pc::xs -> begin *)
    (*       b.(x).(y) <- (Occupied(pc,Blue,true));  *)
    (*       pieces_left_expanded := xs *)
    (*     end *)
    (*   done; *)
    (* done; *)
    (* b *)

  let build (b,pl):board =
    let board_with_pieces = Array.make_matrix 10 10 Empty in
    for x = 0 to 9 do
      for y = 0 to 3 do
        let pc = match b.(x).(y) with
        | Some(p) -> p
        | None -> failwith "pieces_left doesn't match with output" in
        board_with_pieces.(x).(y) <- (Occupied(pc,Red,true));
      done;
    done;
    (* Add lakes *)
    board_with_pieces.(2).(4) <- Lake;
    board_with_pieces.(3).(4) <- Lake;
    board_with_pieces.(6).(4) <- Lake;
    board_with_pieces.(7).(4) <- Lake;

    board_with_pieces.(2).(5) <- Lake;
    board_with_pieces.(3).(5) <- Lake;
    board_with_pieces.(6).(5) <- Lake;
    board_with_pieces.(7).(5) <- Lake;
    let board_with_ai_pieces = build_ai_board board_with_pieces in
    {board_state=board_with_ai_pieces;turn=1;player_to_move=Red}

  let finish (b,pl) =
    let pieces_left_expanded = ref (pl |> expand |> shuffle) in
    for x = 0 to 9 do
      for y = 0 to 3 do
        match b.(x).(y) with
        | None -> begin
          match !pieces_left_expanded with
          | [] -> failwith "pieces left don't correspond"
          | pc::xs -> b.(x).(y) <- (Some(pc)); pieces_left_expanded := xs; ()
        end
        | Some x -> ()
      done;
    done;
    build (b,pl)

  let to_piece_option_matrix t =
    fst t
end
