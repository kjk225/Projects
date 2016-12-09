open State
open Game

type player_move_msg = 
  | InvalidMove
  | ValidMove of string 
  | WinningMove

let string_of_player_move_msg pmm =
  match pmm with 
  | InvalidMove -> "Invalid move. Please input a better move"
  | ValidMove(s)   -> s
  | WinningMove  -> "Congratulations, you win!"

module Player = struct

  let battle i1 i2 =
    if i1 < i2 then
      `Win
    else if i1 = i2 then
      `Both
    else
      `Lose

  let fight_win b (winner_x,winner_y) (loser_x,loser_y) pc pl s =
    b.(winner_x).(winner_y) <- Empty;
    b.(loser_x).(loser_y) <- (Occupied(pc,pl,true));
    (b,(ValidMove(s)))

  let both_lose b (x1,y1) (x2,y2) s =
    b.(x2).(y2) <- Empty;
    b.(x1).(y1) <- Empty;
    (b,ValidMove(s))

  let take_flag b (x1,y1) (x2,y2) =
    b.(x2).(y2) <- b.(x1).(y1);
    b.(x1).(y1) <- Empty;
    (b,WinningMove)

  let normal_move b (x1,y1) (x2,y2) pc pl visibility =
    let is_scout_move = (abs (x1-x2)) > 1 || (abs (y1-y2)) > 1  in
    let new_visibility = visibility || is_scout_move in
    b.(x2).(y2) <- (Occupied(pc,pl,new_visibility));
    b.(x1).(y1) <- Empty;
    (b,ValidMove("You moved your piece."))

  let move board ((x1,y1),(x2,y2)) =
    if not (Game.is_valid board Red ((x1,y1),(x2,y2))) then
      (board,InvalidMove)
    else 
    let b = board.board_state in 
    let new_board_state,res = 
      match b.(x1).(y1), b.(x2).(y2) with
      | Occupied(pc, pl, visibility), Empty ->
        normal_move b (x1,y1) (x2,y2) pc pl visibility
      | Occupied(Soldier(8),pl,_), Occupied(Bomb,_,_) ->
        fight_win b (x1,y1) (x2,y2) (Soldier(8)) pl "Bomb defused."
      | Occupied(Soldier(_),_,_), Occupied(Bomb,_,_) ->
        both_lose b (x1,y1) (x2,y2) "BOOM! You walked into a bomb"
      | Occupied(_,_,_), Occupied(Flag,_,_) ->
        take_flag b (x1,y1) (x2,y2)
      | Occupied(Soldier(i1),pl1,_), Occupied(Soldier(i2),pl2,_) -> begin
        match battle i1 i2 with
        | `Win ->  fight_win b (x1,y1) (x2,y2) (Soldier(i1)) pl1 "You win the fight!"
        | `Lose -> fight_win b (x2,y2) (x1,y1) (Soldier(i2)) pl2 "You lose the fight!"
        | `Both -> both_lose b (x1,y1) (x2,y2) "Tie battle! Both pieces die"
      end
      | Occupied(Soldier(i1),pl1,_), Occupied(Spy,_,_) ->
        fight_win b (x1,y1)  (x2,y2) (Soldier(i1)) pl1 "Spy down! Good job!"
      | Occupied(Spy,pl1,_), Occupied(Soldier(1),_,_) ->
        fight_win b (x1,y1) (x2,y2) Spy pl1 "Spy has assassinated the marshal."
      | Occupied(Spy,_,_), Occupied(Spy,pc2,pl2) ->
        both_lose b (x1,y1) (x2,y2) "Tie battle! Both spies die"
      | Occupied(Spy,_,_), Occupied(pc2,pl2,_) ->
        fight_win b (x2,y2) (x1,y1) pc2 pl2 "Your spy died"
      | _ -> failwith "This should be an invalid move" in 
    {board with board_state=new_board_state; player_to_move=Blue},res

end