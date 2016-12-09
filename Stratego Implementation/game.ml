open State

module Game = struct

  let within_bounds i:bool =
    i >= 0 && i <= 9

  (* moving 1 square up, down, left, or right *)
  let is_adjacent ((x1,y1),(x2,y2)) =
    ((abs (x1-x2)) = 1 && (abs (y1-y2)) = 0) ||
    ((abs (x1-x2)) = 0 && (abs (y1-y2)) = 1)

  (* Check if a soldier is moving along a row or column *)
  let movement_type ((x1,y1),(x2,y2)) =
    if (abs (x1-x2)) <> 0 && (abs (y1-y2)) = 0 then
      `Row
    else if (abs (x1-x2)) = 0 && (abs (y1-y2)) <> 0 then
      `Column
    else
      `Neither

  (* http://stackoverflow.com/questions/243864 *)
  let (--) i j =
    if i=j then [i] else
    let rec aux n acc =
      if n < i then acc else aux (n-1) (n :: acc)
    in aux j []

  let is_valid (board:State.board) player (((x1,y1),(x2,y2)):State.move):bool =
    if not (within_bounds x1) || not (within_bounds y1) ||
       not (within_bounds x2) || not (within_bounds y2)
    then false else
    let b = board.board_state in
    let s1 = b.(x1).(y1) in
    let s2 = b.(x2).(y2) in
    match s1, s2 with
    | Lake, _ -> false
    | Empty, _ -> false
    | Occupied(_,pl,_),_ when player <> player -> false
    | Occupied(_,player1,_),Occupied(_,player2,_) when player1=player2 -> false
    | Occupied(Bomb,_,_),_ -> false
    | Occupied(Flag,_,_),_ -> false
    | Occupied(p1,_,_),Lake -> false
    | Occupied(Soldier(9),_,_),Empty -> begin
      match movement_type ((x1,y1),(x2,y2)) with
      | `Row ->
        let not_empty = fun x -> b.(x).(y1) <> Empty in
        let lower = min x1 x2 in
        let higher = max x1 x2 in
        (lower--higher) |> List.find_all not_empty |> List.length |> ((=) 1)
      | `Column ->
        let not_empty = fun y -> b.(x1).(y) <> Empty in
        let lower = min y1 y2 in
        let higher = max y1 y2 in
        (lower--higher) |> List.find_all not_empty |> List.length |> ((=) 1)
      | `Neither ->
        false
    end
    | Occupied(_,_,_),_ -> is_adjacent ((x1,y1),(x2,y2))

  (* http://stackoverflow.com/questions/10893521 *)
  let cartesian_product l l' =
    List.concat (List.map (fun e -> List.map (fun e' -> (e,e')) l') l)

  (* Returns the set of moves that can possibly by made from a given square. 
   * All pieces can only move along a row or a column, so we enumerate all 
   * possibilities based on this. *)
  let possible_moves_for_square (x0,y0) =
    let possible_nums = 0--9 in
    let x_fixed = List.map (fun y -> (x0,y)) possible_nums in
    let y_fixed = List.map (fun x -> (x,y0)) possible_nums in
    let dests = List.rev_append x_fixed y_fixed in
    let make_move = fun dst -> (x0,y0),dst in
    List.map make_move dests

  let valid_moves (b:board) player =
    let x_list = 0--9 in
    let y_list = 0--9 in
    let prod = cartesian_product x_list y_list in
    let square_is_player (x,y) =
      match b.board_state.(x).(y) with
      | Occupied(_,pl,_) when pl = player -> true
      | _ -> false in
    prod
      |> List.filter square_is_player
      |> List.map possible_moves_for_square
      |> List.flatten
      |> List.filter (is_valid b player)
end


