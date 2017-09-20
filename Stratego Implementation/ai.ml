open State
open Game

type ai_msg =
  | AiFW
  | AiFL
  | AiTrade
  | AiWin
  | AiLose
  | Normal

(* [string_of_ai msg] is used for printing statements that the player can read
*)
let string_of_ai_msg = function
  | AiFW -> "The Ai has won a battle."
  | AiFL -> "The Ai has lost a battle."
  | AiTrade -> "The Ai traded pieces."
  | AiWin -> "The Ai has won the game."
  | AiLose -> "The Ai has lost the game."
  | Normal -> "The Ai made a move."

module Ai = struct

  (* [battle i1 i2] is used to find the winner between two soldiers*)
  let battle i1 i2 =
    if i1 < i2 then
      `Win
    else if i1 = i2 then
      `Both
    else
      `Lose

  (* [fight_win b (wx,wy) (lx,ly) pc pl] is used to edit the board state
   * after the AI wins a fight *)
  let fight_win b (winner_x,winner_y) (loser_x,loser_y) pc pl =
    b.(winner_x).(winner_y) <- Empty;
    b.(loser_x).(loser_y) <- (Occupied(pc,pl,true));
    (b,AiFW)

  (* [fight_lose b (lx,ly) (wx,wy) pc pl] is used to edit the board state
   * after the AI loses a fight *)
  let fight_lose b (loser_x,loser_y) (winner_x,winner_y) pc pl =
    b.(winner_x).(winner_y) <- Empty;
    b.(loser_x).(loser_y) <- (Occupied(pc,pl,true));
    (b,AiFL)

  (* [both_lose b (x1,y1) (x2,y2)] is used to edit the boardstate after a draw
   *)
  let both_lose b (x1,y1) (x2,y2) =
    b.(x2).(y2) <- Empty;
    b.(x1).(y1) <- Empty;
    (b,AiTrade)

  (* [takeflag b (x1,y1) (x2,y2)] is used to edit the boardstate after the Ai
   * takes the flag *)
  let take_flag b (x1,y1) (x2,y2) =
    b.(x2).(y2) <- b.(x1).(y1);
    b.(x1).(y1) <- Empty;
    (b,AiWin)

  (* [normal_move b (x1,y1) (x2,y2) pc pl visibility] is used to edit the
   * boardstate after the Ai makes a move to an empty square *)
  let normal_move b (x1,y1) (x2,y2) pc pl visibility =
    let is_scout_move = (abs (x1-x2)) > 1 || (abs (y1-y2)) > 1  in
    let new_visibility = visibility || is_scout_move in
    b.(x2).(y2) <- (Occupied(pc,pl,new_visibility));
    b.(x1).(y1) <- Empty;
    (b,Normal)

  (* [deepcopy b] is used to deepcopy the Array array function boardstate *)
  let deepcopy b =
    let newboard0 = Array.copy(b.(0)) in
    let newboard1 = Array.copy(b.(1)) in
    let newboard2 = Array.copy(b.(2)) in
    let newboard3 = Array.copy(b.(3)) in
    let newboard4 = Array.copy(b.(4)) in
    let newboard5 = Array.copy(b.(5)) in
    let newboard6 = Array.copy(b.(6)) in
    let newboard7 = Array.copy(b.(7)) in
    let newboard8 = Array.copy(b.(8)) in
    let newboard9 = Array.copy(b.(9)) in
    let newboard = [|newboard0; newboard1; newboard2; newboard3; newboard4;
      newboard5; newboard6; newboard7; newboard8; newboard9|] in
    newboard

  (* [boardedit board ((x1,y1),(x2,y2))] edits the board based on the move
   * given*)
  let boardedit board ((x1,y1),(x2,y2)) =
    let b = board.board_state in
    let new_board_state,msg =
      match b.(x1).(y1), b.(x2).(y2) with
      | Occupied(pc, pl, visibility), Empty ->
        normal_move b (x1,y1) (x2,y2) pc pl visibility
      | Occupied(Soldier(8),pl,_), Occupied(Bomb,_,_) ->
        fight_win b (x1,y1) (x2,y2) (Soldier(8)) pl
      | Occupied(Soldier(_),_,_), Occupied(Bomb,_,_) ->
        both_lose b (x1,y1) (x2,y2)
      | Occupied(_,_,_), Occupied(Flag,_,_) ->
        take_flag b (x1,y1) (x2,y2)
      | Occupied(Soldier(i1),pl1,_), Occupied(Soldier(i2),pl2,_) -> begin
        match battle i1 i2 with
        | `Win ->  fight_win b (x1,y1) (x2,y2) (Soldier(i1)) pl1
        | `Lose -> fight_lose b (x1,y1) (x2,y2) (Soldier(i2)) pl2
        | `Both -> both_lose b (x1,y1) (x2,y2)
        end
      | Occupied(Soldier(i1),pl1,_), Occupied(Spy,_,_) ->
        fight_win b (x1,y1)  (x2,y2) (Soldier(i1)) pl1
      | Occupied(Spy,pl1,_), Occupied(Soldier(1),_,_) ->
        fight_win b (x1,y1) (x2,y2) Spy pl1
      | Occupied(Spy,_,_), Occupied(Spy,pc2,pl2) ->
        both_lose b (x1,y1) (x2,y2)
      | Occupied(Spy,_,_), Occupied(pc2,pl2,_) ->
        fight_lose b (x1,y1) (x2,y2) pc2 pl2
      | _ -> failwith "This should be invalid"
    in
    ({board_state = new_board_state; turn = (board.turn + 1);
        player_to_move = Red}, msg)

  (* [pointsvalwin square] assigns a pointvalue to each square, used in
   * Ai move calculations*)
  let pointsvalwin square =
    match square with
      | Occupied(Soldier(x),_,_) -> x
      | Occupied(Flag,_,_) -> (-100)
      | Occupied(Spy,_,_) -> (3)
      | Occupied(Bomb,_,_) -> (5)
      | _ -> (100)

  (* [pointsvallose square] assigns a pointvalue to each square, used in
   * Ai move calculations*)
  let pointsvallose square =
    match square with
      | Occupied(Soldier(x),_,_) -> x
      | Occupied(Flag,_,_) -> (0)
      | Occupied(Spy,_,_) -> (3)
      | Occupied(Bomb,_,_) -> (0)
      | _ -> (-100)

  (* [highvaluep2 b battlelist move pv] discovers the highest value piece
   * in the second spot in move, used in attacks *)
  let rec highvaluep2 b battlelist move pv =
    match battlelist with
    | [] -> (move, pv)
    | ((x1,y1),(x2,y2))::t ->
      let s2 = b.(x2).(y2) in
      let pointsval = pointsvalwin s2 in
      if pointsval < pv then highvaluep2 b t ((x1,y1),(x2,y2)) pointsval

      else highvaluep2 b t move pv

  (* [lowvaluep1 b battlelist move pv] discovers the lowest value piece
   * from the initial spot in move, used in sacrifices *)
  let rec lowvaluep1 b battlelist move pv =
    match battlelist with
    | [] -> (move, pv)
    | ((x1,y1),(x2,y2))::t ->
      let s1 = b.(x1).(y1) in
      let pointsval = pointsvallose s1 in
      if pointsval > pv then lowvaluep1 b t ((x1,y1),(x2,y2)) pointsval
    else lowvaluep1 b t move pv

  (* [safeenemyfilter movelist b lm bl] filters possible enemy moves
   * given the board state b*)
  let rec safeenemyfilter movelist b lm bl =
    match movelist with
    | [] -> (lm, bl)
    | ((x1,y1),(x2,y2))::t ->
      let s1 = b.(x1).(y1) in
      let s2 = b.(x2).(y2) in
      (match s1, s2 with
      | Occupied(_,_,_), Occupied(Flag,Blue,_) ->
        let losemoves = ((x1,y1),(x2,y2))::lm in
        safeenemyfilter t b losemoves bl
      | Occupied(_,_,_), Occupied(Spy,Blue,_)->
        let battlelose = ((x1,y1),(x2,y2))::bl in
        safeenemyfilter t b lm battlelose
      | Occupied(Spy,Red,_), Occupied(Soldier(1),Blue,_) ->
        let battlelose = ((x1,y1),(x2,y2))::bl in
        safeenemyfilter t b lm battlelose
      | Occupied(Soldier(x),Red,_),Occupied(Soldier(y),Blue,_) ->
        (match battle x y with
        | `Win  ->
          let battlelose = ((x1,y1),(x2,y2))::bl in
          safeenemyfilter t b lm battlelose
        | `Both | `Lose ->
          safeenemyfilter t b lm bl
        )
      | _ ->
        safeenemyfilter t b lm bl
      )

  (* [safemovepred b movelist ml pv] Ai's method of cheating, calculates
   * possible human moves after certain moves *)
  let rec safemovepred b movelist ml pv=
    match movelist with
    | [] -> (ml, pv)
    | ((x1,y1),(x2,y2))::t ->
      let tempboardstate = deepcopy b in
      let tempboard = {board_state = tempboardstate; turn = 0;
        player_to_move = Red} in
      let (tempboard, msg) = boardedit tempboard ((x1,y1),(x2,y2)) in
      let tempmovelist = Game.valid_moves tempboard Red in
      let (lmoves, blose) =
        safeenemyfilter tempmovelist tempboard.board_state [] [] in
      let pointsval =
        if (List.length lmoves > 0) then (-100)
        else if (List.length blose > 0) then
          let (tempmove, temppoints) =
            (highvaluep2 (tempboard.board_state) blose ((0,0),(0,0)) 999) in
          temppoints
        else 10 in
      if pointsval > pv then safemovepred b t [((x1,y1),(x2,y2))] pointsval
      else if (pointsval = pv) then safemovepred b t (((x1,y1),(x2,y2))::ml) pv
      else safemovepred b t ml pv

  (* [findflag board x y] finds the Red flag on the board *)
  let rec findflag board x y =
    if y > 9 then (9,9)
    else
      let piece = board.(x).(y) in
      match piece with
      | Occupied(Flag,Red,_) ->
        (x,y)
      | _ ->
        if x = 9 then findflag board 0 (y+1)
        else findflag board (x+1) y

  (* [closertoflag flagloc mv] if the movement makes the unit move closer
   * to the flag, return one else return 0. Used in aggromovepred calc*)
  let closertoflag flagloc mv =
    let (xflag,yflag) = flagloc in
    let ((x1,y1),(x2,y2)) = mv in
    if ((abs (yflag-y2)) + (abs (xflag - x2))) <
      ((abs (yflag-y1)) + (abs (xflag - x1)))
      then 1 else 0

  (* [aggromovepred b movelist ml pv fl] The Ai's more aggressive cheating
   * method *)
  let rec aggromovepred b movelist ml pv fl =
    match movelist with
    | [] -> (ml, pv)
    | ((x1,y1),(x2,y2))::t ->
      let tempboardstate = deepcopy b in
      let tempboard = {board_state = tempboardstate; turn = 0;
        player_to_move = Red} in
      let closeflag = closertoflag fl ((x1,y1),(x2,y2)) in
      let (tempboard, msg) = boardedit tempboard ((x1,y1),(x2,y2)) in
      let tempmovelist = Game.valid_moves tempboard Red in
      let (lmoves, blose) =
        safeenemyfilter tempmovelist tempboard.board_state [] [] in
      let pointsval =
        if (List.length lmoves > 0) then (-100)
        else if (List.length blose > 0) then
          let (tempmove, temppoints) =
            (highvaluep2 (tempboard.board_state) blose ((0,0),(0,0)) 999) in
          (temppoints * 2 + closeflag)
        else 20 + closeflag in
      if pointsval > pv then aggromovepred b t [((x1,y1),(x2,y2))] pointsval fl
      else if pointsval = pv then
        aggromovepred b t (((x1,y1),(x2,y2))::ml) pv fl
      else aggromovepred b t ml pv fl


  (* [safemovelistfilter movelist b wm pm bdf bw bs bwh nm bm] filters
   * possible movelists based on priority, this is the AI's first moveset
   *
   * The Ai prioritizes winning moves > certain large powerswings > defusing
   * a bomb > winning a battle > scouting out unseen pieces > winning an
   * unknown battle (cheating) > moving regularly (cheating here too) *)
  let rec safemovelistfilter movelist b wm pm bdf bw bs bwh nm bm =
    match movelist with
    | [] -> (b, wm, pm, bdf, bw, bs, bwh, nm, bm)
    | ((x1,y1),(x2,y2))::t ->
      let s1 = b.(x1).(y1) in
      let s2 = b.(x2).(y2) in
      (match s1, s2 with
      | Occupied(_,_,_), Occupied(Flag,Red,_) ->
        let winmoves = ((x1,y1),(x2,y2))::wm in
        safemovelistfilter t b winmoves pm bdf bw bs bwh nm bm
      | Occupied(_,_,_), Occupied(Spy,Red,_) ->
        let battlewin = ((x1,y1),(x2,y2))::bw in
        safemovelistfilter t b wm pm bdf battlewin bs bwh nm bm
      | Occupied(Spy,Blue,_),Occupied(Soldier(x),Red,_) ->
        (if x = 1 then
          let prioritymoves = ((x1,y1),(x2,y2))::pm in
          safemovelistfilter t b wm prioritymoves bdf bw bs bwh nm bm
        else
          let badmove = ((x1,y1),(x2,y2))::bm in
          safemovelistfilter t b wm pm bdf bw bs bwh nm badmove
        )
      | Occupied(Soldier(8),Blue,_),Occupied(Bomb,Red,_) ->
        let bombdefuse = ((x1,y1),(x2,y2))::bdf in
        safemovelistfilter t b wm pm bombdefuse bw bs bwh nm bm
      | Occupied(Soldier(9),Blue,_),Occupied(Bomb,Red,_) ->
        let bombdefuse = ((x1,y1),(x2,y2))::bdf in
        safemovelistfilter t b wm pm bombdefuse bw bs bwh nm bm
      | Occupied(_,_,_), Occupied(Bomb,Red,_) ->
        let badmove = ((x1,y1),(x2,y2))::bm in
        safemovelistfilter t b wm pm bdf bw bs bwh nm badmove
      | Occupied(Soldier(9),Blue,_),Occupied(_,_,false) ->
        let badmove = ((x1,y1),(x2,y2))::bm in
        safemovelistfilter t b wm pm bdf bw bs bwh nm badmove
      | Occupied(Soldier(1),Blue,_),Occupied(Soldier(y),Red,_) ->
        (match battle 1 y with
        | `Win ->
          let (ml, pv) =
            (safemovepred b [((x1,y1),(x2,y2))] [((0,0),(0,0))] (-999)) in
          if pv = 1 then
            let badmove = ((x1,y1),(x2,y2))::bm in
            safemovelistfilter t b wm pm bdf bw bs bwh nm badmove
          else
            let battlewin = ((x1,y1),(x2,y2))::bw in
            safemovelistfilter t b wm pm bdf battlewin bs bwh nm bm
        | `Both | `Lose ->
          let badmove = ((x1,y1),(x2,y2))::bm in
          safemovelistfilter t b wm pm bdf bw bs bwh nm badmove
        )
      | Occupied(Soldier(x),Blue,_),Occupied(Soldier(y),Red,false) ->
        (match battle x y with
        | `Win ->
          let battlewin = ((x1,y1),(x2,y2))::bw in
          safemovelistfilter t b wm pm bdf battlewin bs bwh nm bm
        | `Both | `Lose ->
          (if x < 6 then
            let badmove = ((x1,y1),(x2,y2))::bm in
            safemovelistfilter t b wm pm bdf bw bs bwh nm badmove
          else
            let battlescout = ((x1,y1),(x2,y2))::bs in
            safemovelistfilter t b wm pm bdf bw battlescout bwh nm bm
          )
        )
      | Occupied(Soldier(x),Blue,_),Occupied(Soldier(y),Red,true) ->
        (match battle x y with
        | `Win ->
          let battlewinhidden = ((x1,y1),(x2,y2))::bwh in
          safemovelistfilter t b wm pm bdf bw bs battlewinhidden nm bm
        | `Both | `Lose ->
          let badmove = ((x1,y1),(x2,y2))::bm in
          safemovelistfilter t b wm pm bdf bw bs bwh nm badmove
        )
      | Occupied(_,_,_), Empty ->
        let neutralmove = ((x1,y1),(x2,y2))::nm in
        safemovelistfilter t b wm pm bdf bw bs bwh neutralmove bm
      | _ ->
        let badmove = ((x1,y1),(x2,y2))::bm in
        safemovelistfilter t b wm pm bdf bw bs bwh nm badmove
      )

  (* [aggromovelistfilter movelist b wm pm bdf bw bwh bt bs nm bm] filters
   * possible movelists based on priority, this is the Ai's second moveset.
   *
   * This moveset is much more aggressive and the Ai begins to cheat more and
   * take ties
   *
   * The Ai prioritizes winning moves > certain priority moves > bomb defusal
   * > winning a battle > winning a hidden battle > taking a tie > scouting >
   * making a regular move*)
  let rec aggromovelistfilter movelist b wm pm bdf bw bwh bt bs nm bm =
    match movelist with
    | [] -> (b, wm, pm, bdf, bw, bwh, bt, bs, nm, bm)
    | ((x1,y1),(x2,y2))::t ->
      let s1 = b.(x1).(y1) in
      let s2 = b.(x2).(y2) in
      (match s1, s2 with
      | Occupied(_,_,_), Occupied(Flag,Red,_) ->
        let winmoves = ((x1,y1),(x2,y2))::wm in
        aggromovelistfilter t b winmoves pm bdf bw bwh bt bs nm bm
      | Occupied(_,_,_), Occupied(Spy,Red,_) ->
        let prioritymoves = ((x1,y1),(x2,y2))::pm in
        aggromovelistfilter t b wm prioritymoves bdf bw bwh bt bs nm bm
      | Occupied(Soldier(1),Blue,_),Occupied(Soldier(y),Red,_) ->
        (match battle 1 y with
        | `Win ->
          let (ml, pv) =
            (safemovepred b [((x1,y1),(x2,y2))] [((0,0),(0,0))] (-999)) in
          if pv = 1 then
            let badmove = ((x1,y1),(x2,y2))::bm in
            aggromovelistfilter t b wm pm bdf bw bwh bt bs nm badmove
          else
            let battlewin = ((x1,y1),(x2,y2))::bw in
            aggromovelistfilter t b wm pm bdf battlewin bwh bt bs nm bm
        | `Both ->
          let battletie = ((x1,y1),(x2,y2))::bt in
          aggromovelistfilter t b wm pm bdf bw bwh battletie bs nm bm
        | `Lose ->
          let badmove = ((x1,y1),(x2,y2))::bm in
          aggromovelistfilter t b wm pm bdf bw bwh bt bs nm badmove
        )
      | Occupied(Soldier(2),Blue,_),Occupied(Soldier(y),Red,_) ->
        (match battle 2 y with
        | `Win ->
          let (ml, pv) =
            (safemovepred b [((x1,y1),(x2,y2))] [((0,0),(0,0))] (-999)) in
          if pv < 3 then
            let badmove = ((x1,y1),(x2,y2))::bm in
            aggromovelistfilter t b wm pm bdf bw bwh bt bs nm badmove
          else
            let battlewin = ((x1,y1),(x2,y2))::bw in
            aggromovelistfilter t b wm pm bdf battlewin bwh bt bs nm bm
        | `Both ->
          let battletie = ((x1,y1),(x2,y2))::bt in
          aggromovelistfilter t b wm pm bdf bw bwh battletie bs nm bm
        | `Lose ->
          let badmove = ((x1,y1),(x2,y2))::bm in
          aggromovelistfilter t b wm pm bdf bw bwh bt bs nm badmove
        )
      | Occupied(Spy,Blue,_),Occupied(Soldier(x),Red,_) ->
        (if x = 1 then
          let prioritymoves = ((x1,y1),(x2,y2))::pm in
          aggromovelistfilter t b wm prioritymoves bdf bw bwh bt bs nm bm
        else
          let badmove = ((x1,y1),(x2,y2))::bm in
          aggromovelistfilter t b wm pm bdf bw bwh bt bs nm badmove
        )
      | Occupied(Soldier(x),Blue,_),Occupied(Bomb,Red,_) ->
        (if x > 5 then
          let bombdefuse = ((x1,y1),(x2,y2))::bdf in
          aggromovelistfilter t b wm pm bombdefuse bw bwh bt bs nm bm
        else
          let badmove = ((x1,y1),(x2,y2))::bm in
          aggromovelistfilter t b wm pm bdf bw bwh bt bs nm badmove
        )
      | Occupied(_,_,_), Occupied(Bomb,Red,_) ->
        let badmove = ((x1,y1),(x2,y2))::bm in
        aggromovelistfilter t b wm pm bdf bw bwh bt bs nm badmove
      | Occupied(Soldier(9),Blue,_),Occupied(_,_,false) ->
        let battlescout = ((x1,y1),(x2,y2))::bs in
        aggromovelistfilter t b wm pm bdf bw bwh bt battlescout nm bm
      | Occupied(Soldier(x),Blue,_),Occupied(Soldier(y),Red,false) ->
        (match battle x y with
        | `Win ->
          let battlewinhidden = ((x1,y1),(x2,y2))::bwh in
          aggromovelistfilter t b wm pm bdf bw battlewinhidden bt bs nm bm
        | `Both ->
          let battlescout = ((x1,y1),(x2,y2))::bs in
          aggromovelistfilter t b wm pm bdf bw bwh bt battlescout nm bm
        | `Lose ->
          if x > 5 then
            let battlescout = ((x1,y1),(x2,y2))::bs in
            aggromovelistfilter t b wm pm bdf bw bwh bt battlescout nm bm
          else
            let badmove = ((x1,y1),(x2,y2))::bm in
            aggromovelistfilter t b wm pm bdf bw bwh bt bs nm badmove
        )
      | Occupied(Soldier(x),Blue,_),Occupied(Soldier(y),Red,true) ->
        (match battle x y with
        | `Win ->
          let battlewin = ((x1,y1),(x2,y2))::bw in
          aggromovelistfilter t b wm pm bdf battlewin bwh bt bs nm bm
        | `Both ->
          let battletie = ((x1,y1),(x2,y2))::bt in
          aggromovelistfilter t b wm pm bdf bw bwh battletie bs nm bm
        | `Lose ->
          let badmove = ((x1,y1),(x2,y2))::bm in
          aggromovelistfilter t b wm pm bdf bw bwh bt bs nm badmove
        )
      | Occupied(_,_,_), Empty ->
        let neutralmove = ((x1,y1),(x2,y2))::nm in
        aggromovelistfilter t b wm pm bdf bw bwh bt bs neutralmove bm
      | _ ->
        let badmove = ((x1,y1),(x2,y2))::bm in
        aggromovelistfilter t b wm pm bdf bw bwh bt bs nm badmove
      )

  (* [searchmovelistfilter movelist b wm pm bdf bw bwh bt nm bm] filters
   * possible movelists based on priority, this is the Ai's third moveset
   *
   * This moveset is much more aggressive and the Ai begins to cheat even
   * more and refuses to scout
   *
   * The Ai prioritizes winning moves > certain priority moves > bomb defusal
   * > winning a battle > winning a hidden battle > taking a tie >
   * making a regular move*)
  let rec searchmovelistfilter movelist b wm pm bdf bw bt nm bm =
    match movelist with
    | [] -> (b, wm, pm, bdf, bw, bt, nm, bm)
    | ((x1,y1),(x2,y2))::t ->
      let s1 = b.(x1).(y1) in
      let s2 = b.(x2).(y2) in
      (match s1, s2 with
      | Occupied(_,_,_), Occupied(Flag,Red,_) ->
        let winmoves = ((x1,y1),(x2,y2))::wm in
        searchmovelistfilter t b winmoves pm bdf bw bt nm bm
      | Occupied(_,_,_), Occupied(Spy,Red,_) ->
        let prioritymoves = ((x1,y1),(x2,y2))::pm in
        searchmovelistfilter t b wm prioritymoves bdf bw bt nm bm
      | Occupied(Soldier(1),Blue,_),Occupied(Soldier(y),Red,_) ->
        (match battle 1 y with
        | `Win ->
          let (ml, pv) =
            (safemovepred b [((x1,y1),(x2,y2))] [((0,0),(0,0))] (-999)) in
          if pv = 1 then
            let badmove = ((x1,y1),(x2,y2))::bm in
            searchmovelistfilter t b wm pm bdf bw bt nm badmove
          else
            let battlewin = ((x1,y1),(x2,y2))::bw in
            searchmovelistfilter t b wm pm bdf battlewin bt nm bm
        | `Both ->
          let battletie = ((x1,y1),(x2,y2))::bt in
          searchmovelistfilter t b wm pm bdf bw battletie nm bm
        | `Lose ->
          let badmove = ((x1,y1),(x2,y2))::bm in
          searchmovelistfilter t b wm pm bdf bw bt nm badmove
        )
      | Occupied(Soldier(2),Blue,_),Occupied(Soldier(y),Red,_) ->
        (match battle 2 y with
        | `Win ->
          let (ml, pv) =
            (safemovepred b [((x1,y1),(x2,y2))] [((0,0),(0,0))] (-999)) in
          if pv < 3 then
            let badmove = ((x1,y1),(x2,y2))::bm in
            searchmovelistfilter t b wm pm bdf bw bt nm badmove
          else
            let battlewin = ((x1,y1),(x2,y2))::bw in
            searchmovelistfilter t b wm pm bdf battlewin bt nm bm
        | `Both ->
          let battletie = ((x1,y1),(x2,y2))::bt in
          searchmovelistfilter t b wm pm bdf bw battletie nm bm
        | `Lose ->
          let badmove = ((x1,y1),(x2,y2))::bm in
          searchmovelistfilter t b wm pm bdf bw bt nm badmove
        )

      | Occupied(Spy,Blue,_),Occupied(Soldier(x),Red,_) ->
        if x = 1 then
          let prioritymoves = ((x1,y1),(x2,y2))::pm in
          searchmovelistfilter t b wm prioritymoves bdf bw bt nm bm
        else
          let badmove = ((x1,y1),(x2,y2))::bm in
          searchmovelistfilter t b wm pm bdf bw bt nm badmove
      | Occupied(Soldier(x),Blue,_),Occupied(Bomb,Red,_) ->
        if x > 3 then
          let bombdefuse = ((x1,y1),(x2,y2))::bdf in
          searchmovelistfilter t b wm pm bombdefuse bw bt nm bm
        else
          let badmove = ((x1,y1),(x2,y2))::bm in
          searchmovelistfilter t b wm pm bdf bw bt nm badmove
      | Occupied(Spy,Blue,_), Occupied(Bomb,Red,_) ->
        let bombdefuse = ((x1,y1),(x2,y2))::bdf in
        searchmovelistfilter t b wm pm bombdefuse bw bt nm bm
      | Occupied(Soldier(x),Blue,_),Occupied(Soldier(y),Red,false) ->
        (match battle x y with
        | `Win ->
          let battlewin = ((x1,y1),(x2,y2))::bw in
          searchmovelistfilter t b wm pm bdf battlewin bt nm bm
        | `Both ->
          let battletie = ((x1,y1),(x2,y2))::bt in
          searchmovelistfilter t b wm pm bdf bw battletie nm bm
        | `Lose ->
          let badmove = ((x1,y1),(x2,y2))::bm in
          searchmovelistfilter t b wm pm bdf bw bt nm badmove
        )
      | Occupied(Soldier(x),Blue,_),Occupied(Soldier(y),Red,true) ->
        (match battle x y with
        | `Win ->
          let battlewin = ((x1,y1),(x2,y2))::bw in
          searchmovelistfilter t b wm pm bdf battlewin bt nm bm
        | `Both ->
          let battletie = ((x1,y1),(x2,y2))::bt in
          searchmovelistfilter t b wm pm bdf bw battletie nm bm
        | `Lose ->
          let badmove = ((x1,y1),(x2,y2))::bm in
          searchmovelistfilter t b wm pm bdf bw bt nm badmove
        )
      | Occupied(_,_,_), Empty ->
        let neutralmove = ((x1,y1),(x2,y2))::nm in
        searchmovelistfilter t b wm pm bdf bw bt neutralmove bm
      | _ ->
        let badmove = ((x1,y1),(x2,y2))::bm in
        searchmovelistfilter t b wm pm bdf bw bt nm badmove
      )

  (* [move board] the main move function for Ai, takes in a board and returns
   * a new board*ai_msg Filters movesets by safe < 30, aggro < 70, else search*)
  let move board =
    let turn = board.turn in
    let movelist = Game.valid_moves board Blue in
    let bstate = board.board_state in
    if List.length(movelist) = 0 then
      (board , AiLose)
    else

    if turn < 30 then
      let (b, wm, pm, bdf, bw, bs, bwh, nm, bm) =
          safemovelistfilter movelist bstate [] [] [] [] [] [] [] [] in
      let ((x1,y1),(x2,y2)) =
      (if List.length(wm) > 0 then
          List.hd wm
      else if List.length(pm) > 0 then
          let (mv, pv) = (highvaluep2 b pm ((0,0),(0,0)) 999) in
          mv
      else if List.length(bdf) > 0 then
          let (mv, pv) = (lowvaluep1 b bdf ((0,0),(0,0)) (-9999)) in
          mv
      else if List.length(bw) > 0 then
          let (mv, pv) = (highvaluep2 b bw ((0,0),(0,0)) 999) in
          mv
      else if List.length(bs) > 0 then
          let (mv, pv) = (highvaluep2 b bs ((0,0),(0,0)) 999) in
          mv
      else if List.length(bwh) > 0 then
          let (mv, pv) = (highvaluep2 b bwh ((0,0),(0,0)) 999) in
          mv
      else if List.length(nm) > 0 then
          let (ml, pv) = (safemovepred b nm [((0,0),(0,0))] (-9999)) in
          List.nth ml (ml |> List.length |> Random.int)
      else List.nth movelist (movelist |> List.length |> Random.int)
      ) in
      boardedit board ((x1,y1),(x2,y2))

    else if turn < 70 then
      let (b, wm, pm, bdf, bw, bwh, bt, bs, nm, bm) =
        aggromovelistfilter movelist bstate [] [] [] [] [] [] [] [] [] in
      let ((x1,y1),(x2,y2)) =
      (if List.length(wm) > 0 then
          List.hd wm
      else if List.length(pm) > 0 then
          let (mv, pv) = (highvaluep2 b pm ((0,0),(0,0)) 999) in
          mv
      else if List.length(bw) > 0 then
          let (mv, pv) = (highvaluep2 b bw ((0,0),(0,0)) 999) in
          mv
      else if List.length(bdf) > 0 then
          let (mv, pv) = (lowvaluep1 b bdf ((0,0),(0,0)) (-9999)) in
          mv
      else if List.length(bwh) > 0 then
          let (mv, pv) = (highvaluep2 b bwh ((0,0),(0,0)) 999) in
          mv
      else if List.length(bt) > 0 then
          let (mv, pv) = (highvaluep2 b bt ((0,0),(0,0)) 999) in
          mv
      else if List.length(bs) > 0 then
          let (mv, pv) = (highvaluep2 b bs ((0,0),(0,0)) 999) in
          mv
      else if List.length(nm) > 0 then
          let flagloc = findflag b 0 0 in
          let (ml,pv) = (aggromovepred b nm [((0,0),(0,0))] (-9999) flagloc) in
          List.nth ml (ml |> List.length |> Random.int)
      else List.nth movelist (movelist |> List.length |> Random.int)
      ) in
      boardedit board ((x1,y1),(x2,y2))

    else
      let (b, wm, pm, bdf, bw, bt, nm, bm) =
        searchmovelistfilter movelist bstate [] [] [] [] [] [] [] in
      let ((x1,y1),(x2,y2)) =
      (if List.length(wm) > 0 then
          List.hd wm
      else if List.length(pm) > 0 then
          let (mv, pv) = (highvaluep2 b pm ((0,0),(0,0)) 999) in
          mv
      else if List.length(bw) > 0 then
          let (mv, pv) = (highvaluep2 b bw ((0,0),(0,0)) 999) in
          mv
      else if List.length(bdf) > 0 then
          let (mv, pv) = (lowvaluep1 b bdf ((0,0),(0,0)) (-9999)) in
          mv
      else if List.length(bt) > 0 then
          let (mv, pv) = (highvaluep2 b bt ((0,0),(0,0)) 999) in
          mv
      else if List.length(nm) > 0 then
          let flagloc = findflag b 0 0 in
          let (ml,pv) = (aggromovepred b nm [((0,0),(0,0))] (-9999) flagloc) in
          List.nth ml (ml |> List.length |> Random.int)
      else List.nth movelist (movelist |> List.length |> Random.int)
      ) in
      boardedit board ((x1,y1),(x2,y2))

end
