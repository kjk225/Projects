print_endline "Tests!";
open State
open Game
open OUnit2
open Ai
open State
open Player
open Boardbuilder
open Cmdlineboardviewer

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

let emptyboardstate =
  [|  [|Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty|];
      [|Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty|];
      [|Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty|];
      [|Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty|];
      [|Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty|];
      [|Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty|];
      [|Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty|];
      [|Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty|];
      [|Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty|];
      [|Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty|];
  |]
let bdeepcopy = deepcopy emptyboardstate
(* boards to test validmoves soliders 1-9, bombs, flags, spy *)
let bstates9 = deepcopy emptyboardstate
let () = bstates9.(0).(0) <- (Occupied(Soldier(9),Red,false)); ()
let bstates9l = deepcopy bstates9
let () = bstates9l.(0).(1) <- (Lake); ()
let bstates1 = deepcopy emptyboardstate
let () = bstates1.(0).(0) <- (Occupied(Soldier(1),Red,false)); ()
let bstates1l = deepcopy bstates1
let () = bstates1l.(0).(1) <- (Lake); ()
let bstates3 = deepcopy emptyboardstate
let () = bstates3.(0).(0) <- (Occupied(Soldier(3),Red,false)); ()
let bstates3l = deepcopy bstates3
let () = bstates3l.(0).(1) <- (Lake); ()
let bstates5 = deepcopy emptyboardstate
let () = bstates5.(0).(0) <- (Occupied(Soldier(5),Red,false)); ()
let bstates5l = deepcopy bstates5
let () = bstates5l.(0).(1) <- (Lake); ()
let bstates8 = deepcopy emptyboardstate
let () = bstates8.(0).(0) <- (Occupied(Soldier(8),Red,false)); ()
let bstates8l = deepcopy bstates8
let () = bstates8l.(0).(1) <- (Lake); ()
let bstatespy = deepcopy emptyboardstate
let () = bstatespy.(0).(0) <- (Occupied(Spy,Red,false)); ()
let bstatespyl = deepcopy bstatespy
let () = bstatespyl.(0).(1) <- (Lake); ()
let bstatebomb = deepcopy emptyboardstate
let () = bstatebomb.(0).(0) <- (Occupied(Bomb,Red,false)); ()
let bstatebombl = deepcopy bstatebomb
let () = bstatebombl.(0).(1) <- (Lake); ()
let bstateflag = deepcopy emptyboardstate
let () = bstateflag.(0).(0) <- (Occupied(Flag,Red,false)); ()
let bstateflagl = deepcopy bstateflag
let () = bstateflagl.(0).(1) <- (Lake); ()

let bstates8bomb = deepcopy bstates8
let () = bstates8bomb.(0).(1) <- (Occupied(Bomb,Blue,false)); ()
let bstates1bomb = deepcopy bstates8bomb
let () = bstates1bomb.(0).(0) <- (Occupied(Soldier(1),Red,false)); ()
let bstates9bomb = deepcopy bstates8bomb
let () = bstates9bomb.(0).(0) <- (Occupied(Soldier(9),Red,false)); ()
let bstatespybomb = deepcopy bstates8bomb
let () = bstatespybomb.(0).(0) <- (Occupied(Spy,Red,false)); ()

let bstates9s1 = deepcopy bstates9
let () = bstates9s1.(0).(1) <- (Occupied(Soldier(1),Red,false)); ()
let bstates3s1 = deepcopy bstates3
let () = bstates3s1.(0).(1) <- (Occupied(Soldier(1),Red,false)); ()

let bstates8ba = deepcopy emptyboardstate
let () = bstates8ba.(0).(1) <- (Occupied(Soldier(8),Red,false)); ()

let bdfsstate = deepcopy bstates8bomb

let boards9 = {board_state = bstates9; turn = 0; player_to_move = Red}
let boards9l = {board_state = bstates9l; turn = 0; player_to_move = Red}
let boards1 = {board_state = bstates1; turn = 0; player_to_move = Red}
let boards1l = {board_state = bstates1l; turn = 0; player_to_move = Red}
let boards3 = {board_state = bstates3; turn = 0; player_to_move = Red}
let boards3l = {board_state = bstates3l; turn = 0; player_to_move = Red}
let boards5 = {board_state = bstates5; turn = 0; player_to_move = Red}
let boards5l = {board_state = bstates5l; turn = 0; player_to_move = Red}
let boards8 = {board_state = bstates8; turn = 0; player_to_move = Red}
let boards8l = {board_state = bstates8l; turn = 0; player_to_move = Red}
let boardspy = {board_state = bstatespy; turn = 0; player_to_move = Red}
let boardspyl = {board_state = bstatespyl; turn = 0; player_to_move = Red}
let boardbomb = {board_state = bstatebomb; turn = 0; player_to_move = Red}
let boardbombl = {board_state = bstatebombl; turn = 0; player_to_move = Red}
let boardflag = {board_state = bstateflag; turn = 0; player_to_move = Red}
let boardflagl = {board_state = bstateflagl; turn = 0; player_to_move = Red}
let boards8bomb = {board_state = bstates8bomb; turn = 0; player_to_move = Red}
let boards1bomb = {board_state = bstates1bomb; turn = 0; player_to_move = Red}
let boards9bomb = {board_state = bstates9bomb; turn = 0; player_to_move = Red}
let boardspybomb = {board_state = bstatespybomb; turn = 0; player_to_move = Red}
let boards9s1 = {board_state = bstates9s1; turn = 0; player_to_move = Red}
let boards3s1 = {board_state = bstates3s1; turn = 0; player_to_move = Red}


let tests = "test suite" >:::
[
  "deepcopytest" >:: (fun _ -> assert_equal emptyboardstate bdeepcopy);
  "validmovess9" >:: (fun _ -> assert_equal
    18 (List.length(Game.valid_moves boards9 Red)));
  "validmovess9l" >:: (fun _ -> assert_equal
    9 (List.length(Game.valid_moves boards9l Red)));
  "validmovess1" >:: (fun _ -> assert_equal
    2 (List.length(Game.valid_moves boards1 Red)));
  "validmovess1l" >:: (fun _ -> assert_equal
    1 (List.length(Game.valid_moves boards1l Red)));
  "validmovess3" >:: (fun _ -> assert_equal
    2 (List.length(Game.valid_moves boards3 Red)));
  "validmovess3l" >:: (fun _ -> assert_equal
    1 (List.length(Game.valid_moves boards3l Red)));
  "validmovess5" >:: (fun _ -> assert_equal
    2 (List.length(Game.valid_moves boards5 Red)));
  "validmovess5l" >:: (fun _ -> assert_equal
    1 (List.length(Game.valid_moves boards5l Red)));
  "validmovess8" >:: (fun _ -> assert_equal
    2 (List.length(Game.valid_moves boards8 Red)));
  "validmovess8l" >:: (fun _ -> assert_equal
    1 (List.length(Game.valid_moves boards8l Red)));
  "validmovesbomb" >:: (fun _ -> assert_equal
    0 (List.length(Game.valid_moves boardbomb Red)));
  "validmovesbombl" >:: (fun _ -> assert_equal
    0 (List.length(Game.valid_moves boardbombl Red)));
  "validmovesflag" >:: (fun _ -> assert_equal
    0 (List.length(Game.valid_moves boardflag Red)));
  "validmovesflagl" >:: (fun _ -> assert_equal
    0 (List.length(Game.valid_moves boardflagl Red)));
  "validmovess8bomb" >:: (fun _ -> assert_equal
    2 (List.length(Game.valid_moves boards8bomb Red)));
  "validmovess1bomb" >:: (fun _ -> assert_equal
    2 (List.length(Game.valid_moves boards1bomb Red)));
  "validmovess9bomb" >:: (fun _ -> assert_equal
    10 (List.length(Game.valid_moves boards9bomb Red)));
  "validmovespybomb" >:: (fun _ -> assert_equal
    2 (List.length(Game.valid_moves boardspybomb Red)));
  "validmovess9s1" >:: (fun _ -> assert_equal
    11 (List.length(Game.valid_moves boards9s1 Red)));
  "validmovess3s1" >:: (fun _ -> assert_equal
    3 (List.length(Game.valid_moves boards3s1 Red)));

]

let _ = run_test_tt_main tests