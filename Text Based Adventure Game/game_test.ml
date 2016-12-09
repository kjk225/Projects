open OUnit2
open Game

let j = Yojson.Basic.from_file "tworoom.json"

open Yojson.Basic.Util

let Dictionary b = [("apple", "file1"), ("fries","file2"), ("pizza", "file3"), ("cake", "file5")]
let set_test =
[
  "set1" >:: (fun _ -> assert_equal 11111 (d |> init_state |> max_score));
  "set2" >:: (fun _ -> assert_equal 10001 (j |> init_state |> score));
  "set3" >:: (fun _ -> assert_equal 0 (j |> init_state |> turns));
  "set4" >:: (fun _ -> assert_equal "room1" (j |> init_state |> current_room_id));
]
(*much of my testing was done by "playtesting" in the game*)

let state_tests = 
[

let roomslist = j |> member "rooms" |> to_list in
let allrooms = buildrooms roomslist [] in
let roomtree = make_roomtree allrooms Empty in

let itemslist = j |> member "items" |> to_list in
let allitems = builditems itemslist [] in
let itemtree = make_itemtree allitems Empty in

let initialstate = {inventory = ["white hat"]; room = "room1" ; 
					points = 10001; turns =0; max_score= 11111; visited = ["room1"]; 
					locations = [("black hat", "room1");("red hat", "room1")];
					roomtree = roomtree;
					itemtree = itemtree;
					} in

  "initial_state"  >:: (fun _ -> assert_equal initialstate (init_state j));
]

let suite =
  "Adventure test suite"
  >::: state_tests @ tests

let _ = run_test_tt_main suite

