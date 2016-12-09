(*
 * CS 3110 Fall 2016 A2
 * Author: Kanu Kanu
 * NetID: kjk225
 *
 * Acknowledge here any contributions made to your solution that
 * did not originate from you or from the course staff:
 *
 *)

open Yojson.Basic.Util

type room = {
  description : string;
  points : int;
  exits : (string * string) list;
  treasure : string list;
}

type item = {
    description : string;
    points : int;
}

(*json tree with each node containing the id and info about the jason object*)
type ('id, 'info) jsontree = 
  | Empty
  | Node of 'id * 'info * ('id , 'info) jsontree * ('id , 'info) jsontree

type state = {
  inventory : string list;
  room : string;
  points : int;
  turns : int;
  max_score: int;
  visited: string list;
  locations: (string * string) list;
  itemtree: (string, item) jsontree;
  roomtree: (string, room) jsontree;
}

type verb =
  | Go of string
  | Look
  | Take of string
  | Drop of string
  | Inventory
  | Score
  | Turns
  | Quit

(*[insert_jtree id info jsontree] is the jsontree given the id and info*)
let rec insert_jtree id info jsontree =
  match jsontree with
  | Empty -> Node(id, info, Empty, Empty)
  | Node (a, b, jt1, jt2) -> if (a = id) then Node (id, info, jt1, jt2) else
                              if (id < a) then Node (a, b, (insert_jtree id info jt1), jt2) else
                                                Node (a, b, jt1, (insert_jtree id info jt2))
(*[read_jtree id jsontree] is the info of any given id in a jsontree. 
  Not_found is raised if there is no such id*)
let rec read_jtree id jsontree =
  match jsontree with
  | Empty -> raise Not_found
  | Node (a, b, jt1, jt2) -> if (a = id) then b else
                              if (id < a) then read_jtree id jt1 else
                                                read_jtree id jt2

(* [Illegal] is raised by [do'] to indicate that a command is illegal;
 * see the documentation of [do'] below. *)
exception Illegal

(*[Terminate] is raised calling quit in the game*)
exception Terminate

(*[buildrooms roomslist allrooms] is a list of all the rooms of type room
 given a list of rooms of type json*)
let rec buildrooms roomslist allrooms=
  match roomslist with
  |thisroom::nextroom -> let id = thisroom |> member "id" |> to_string in 
                              let room = {
                              description = thisroom |> member "description" |> to_string;
                              points = thisroom |> member "points" |> to_int;
                              exits = thisroom |> member "exits" |> to_list |>
                                      List.map (fun j -> ((member "direction" j |> to_string), (member "room_id" j |> to_string)));
                              treasure = thisroom |> member "treasure" |> to_list |> filter_string} in

                              buildrooms nextroom ((id, room)::allrooms)

  | [] -> if allrooms = [] then failwith "Sorry, there are no rooms in the adventure"
                                else allrooms

(*[make_roomtree allrooms roomtree] is a jsontree of all the rooms of type room*)
let rec make_roomtree allrooms roomtree=
    match allrooms with
    | (id, roominfo)::next -> make_roomtree next ((insert_jtree id roominfo) roomtree)
    | [] -> roomtree

(*[builditems itemslist allitems] is a list of all the items of type item
 given a list of items of type json*)
let rec builditems itemslist allitems=
      match itemslist with
      |thisitem::nextitem -> let id = thisitem |> member "id" |> to_string in let item = {
                              description = thisitem |> member "description" |> to_string;
                              points = thisitem |> member "points" |> to_int} in

                              builditems nextitem ((id, item)::allitems)

      | [] -> if allitems = [] then failwith "Sorry, there are no items in the adventure"
                                else allitems

(*[make_itemtree allitems itemtree] is a jsontree of all the itemss of type item*)
let rec make_itemtree allitems itemtree=
    match allitems with
    | (id, iteminfo)::next -> make_itemtree next ((insert_jtree id iteminfo) itemtree)
    | [] -> itemtree

(*[get_points ...] is the number of points the player will start out with*)
let rec get_points init_score startlocations roomtree itemtree= 
      match startlocations with 
      |(itemid, roomid)::next -> if (List.mem itemid ((read_jtree roomid roomtree).treasure)) 
                                  then init_score + ((read_jtree itemid itemtree):item).points 
                                  else get_points init_score next roomtree itemtree
      |[] -> init_score

(* [init_state j] is the initial state of the game as
 * determined by JSON object [j] *)
let init_state j =
    
    let init_room = j |> member "start_room" |> to_string in

    let roomslist = j |> member "rooms" |> to_list in
    let allrooms = buildrooms roomslist [] in
    let roomtree = make_roomtree allrooms Empty in

    let itemslist = j |> member "items" |> to_list in
    let allitems = builditems itemslist [] in
    let itemtree = make_itemtree allitems Empty in

    let init_inventorylist = [j] |> filter_member "start_inv" |> flatten |> filter_string in

    let maxscore_items = itemslist |> List.map (fun j -> member "points" j |> to_int) in
    let maxscore_rooms = roomslist |> List.map (fun j -> member "points" j |> to_int) in
    let maxscore_total = List.append maxscore_rooms maxscore_items |> List.fold_left (+) 0 in

    let item_locations = j |> member "start_locations" |> to_list
                            |> List.map (fun j -> ((member "item" j |> to_string), (member "room" j |> to_string))) in

    let init_score = (get_points 0 item_locations roomtree itemtree) + (read_jtree init_room roomtree).points in

    if maxscore_total <= init_score then print_endline "You did it. You've reached the max score!" else print_string ""; 

  {
    inventory = init_inventorylist;
    room = init_room;
    points= init_score;
    turns= 0;
    max_score = maxscore_total;
    visited = [init_room];
    locations = item_locations;
    roomtree = roomtree;
    itemtree = itemtree;
  }

(* [max_score s] is the maximum score for the adventure whose current
 * state is represented by [s]. *)
let max_score s =
  s.max_score

(* [score s] is the player's current score. *)
let score s =
  s.points

(* [turns s] is the number of turns the player has taken so far. *)
let turns s =
  s.turns

(* [current_room_id s] is the id of the room in which the adventurer
 * currently is. *)
let current_room_id s =
  s.room

(* [inv s] is the list of item id's in the adventurer's current inventory.
 * No item may appear more than once in the list.  Order is irrelevant. *)
let inv s =
  s.inventory

(* [visited s] is the list of id's of rooms the adventurer has visited.
 * No room may appear more than once in the list.  Order is irrelevant. *)
let visited s =
  s.visited

(* [locations s] is an association list mapping item id's to the
 * id of the room in which they are currently located.  Items
 * in the adventurer's inventory are not located in any room.
 * No item may appear more than once in the list.  The relative order
 * of list elements is irrelevant, but the order of pair components
 * is essential:  it must be [(item id, room id)]. *)
let locations s =
  s.locations

(*[do_action state verb] is the state given the action of [verb]*)
let do_action state verb=
  let current_room = read_jtree state.room state.roomtree in
  match verb with
  | Go direction ->(
                        try( 
                          let next_roomid =(try(
                                                List.assoc (String.uppercase_ascii direction) current_room.exits
                                                )
                                               with Not_found -> List.assoc (String.lowercase_ascii direction) current_room.exits) in


                          let next_room = read_jtree next_roomid state.roomtree in
                          let next_roompts = if List.mem next_roomid state.visited 
                                              then 0
                                              else state.points + next_room.points in

                          let new_visited = if List.mem next_roomid state.visited
                                              then state.visited
                                              else next_roomid::state.visited in
                          let new_turn = state.turns + 1 in

                          print_endline next_room.description;
                          print_string "Items in this room:"; print_string(String.concat " " next_room.treasure);
                          print_newline (); print_newline ();

                          if state.max_score <= next_roompts then print_endline "You did it. You've reached the max score!" else print_string "";

                          {state with 
                                        room = next_roomid;
                                        points = next_roompts;
                                        visited = new_visited;
                                        turns = new_turn;
                          }
                        )
                        with Not_found -> print_endline "That is not a valid command"; raise Illegal)

  | Look -> print_endline current_room.description; print_newline (); state;

  | Take itemname->(
            print_newline ();
            try(
            let current_itemid = List.find (fun theitem -> (theitem = (String.uppercase_ascii itemname) || theitem = String.lowercase_ascii itemname)) current_room.treasure in
            let new_treasure = List.filter (fun theitem -> theitem <> current_itemid) current_room.treasure in
            let new_inventorylist = current_itemid::state.inventory in
            let new_points = if List.mem current_itemid state.inventory 
                              then state.points - (read_jtree current_itemid state.itemtree).points
                              else state.points in
            let new_turn = state.turns + 1 in
            let new_locations =  List.filter (fun (itemid,roomid) -> (itemid,roomid) <> (current_itemid, state.room)) state.locations in

            let updated_room = {current_room with
                                treasure = new_treasure
                                } in

            let updated_roomtree = insert_jtree state.room updated_room state.roomtree in

            if state.max_score <= new_points then print_endline "You did it. You've reached the max score!" else print_string "";

            {state with 
                        inventory = new_inventorylist;
                        points =  new_points;
                        turns = new_turn;
                        locations = new_locations;
                        roomtree = updated_roomtree
            }
          )
          with Not_found -> print_endline "That is not a valid item to take"; raise Illegal)

  | Drop itemname->(
            print_newline ();
            try(
            let current_itemid = List.find (fun theitem -> (theitem = (String.uppercase_ascii itemname) || theitem = String.lowercase_ascii itemname)) current_room.treasure in
            let new_treasure = current_itemid::current_room.treasure in
            let new_inventorylist = List.filter (fun theitem -> theitem <> current_itemid) state.inventory in
            let new_points = if List.mem current_itemid current_room.treasure
                              then state.points + (read_jtree current_itemid state.itemtree).points
                              else state.points in
            let new_turn = state.turns + 1 in
            let new_locations =  List.filter (fun (itemid,roomid) -> (itemid,roomid) <> (current_itemid, state.room)) state.locations in

            let updated_room = {current_room with
                                treasure = new_treasure
                                } in

            let updated_roomtree = insert_jtree state.room updated_room state.roomtree in

            if state.max_score <= new_points then print_endline "You did it. You've reached the max score!" else print_string "";

            {state with 
                        inventory = new_inventorylist;
                        points =  new_points;
                        turns = new_turn;
                        locations = new_locations;
                        roomtree = updated_roomtree
            }
          )
          with Not_found -> print_endline "That is not a valid item to drop"; raise Illegal)

  | Inventory ->  if (List.length state.inventory > 0)
                  then 
                  match state.inventory with
                        | h::t -> print_string h; print_newline () 
                        | [] -> ()
                  else print_endline "Your inventory is empty"; print_newline (); state
  | Score -> print_int state.points; print_newline (); state;
  | Turns -> print_int state.turns; print_newline (); state;
  | Quit -> state; raise Terminate

(* [do' c st] is [st'] if it is possible to do command [c] in
 * state [st] and the resulting new state would be [st'].  The
 * function name [do'] is used because [do] is a reserved keyword.
 *   - The "go" (and its shortcuts), "take" and "drop" commands
 *     either result in a new state, or are not possible because
 *     their object is not valid in state [st] hence they raise [Illegal].
 *       + the object of "go" is valid if it is a direction by which
 *         the current room may be exited
 *       + the object of "take" is valid if it is an item in the
 *         current room
 *       + the object of "drop" is valid if it is an item in the
 *         current inventory
 *       + if no object is provided (i.e., the command is simply
 *         the bare word "go", "take", or "drop") the behavior
 *         is unspecified
 *   - The "quit", "look", "inventory", "inv", "score", and "turns"
 *     commands are always possible and leave the state unchanged.
 *   - The behavior of [do'] is unspecified if the command is
 *     not one of the commands given in the assignment writeup.
 * The underspecification above is in order to enable karma
 * implementations that provide new commands. *)

let do' c st =
  let command = String.uppercase_ascii c in

  let first_word= (try(
                      String.sub command 0 (String.index command ' ')
                      )
                      with _ -> command) in


  let possible_commands =
      let getGo_dir = (try( 
                          String.sub command 3 ((String.length command)-3)
                          )
                          with _ -> first_word) in

      let getitem = (try(
                        String.sub command 5 ((String.length command)-5)
                        )
                        with _-> first_word) in             
                            
      [("GO", Go(getGo_dir)); 
       ("TAKE", Take(getitem)); 
       ("DROP", Drop(getitem)); 
       ("LOOK", Look);
       ("INVENTORY", Inventory);
       ("INV", Inventory);
       ("SCORE", Score);
       ("TURNS", Turns);
       ("QUIT", Quit)] in

  let rec findtheverb = function
    | (comm,verb)::t -> if (comm=first_word) then do_action st verb else findtheverb t
    | _ -> do_action st (Go(command)) in
    
    findtheverb possible_commands

(* [main f] is the main entry point from outside this module
 * to load a game from file [f] and start playing it
 *)
let main file_name =

  let rec repl state = 
    let input = read_line () in
    repl (do' input state) in

  try(
    let j = Yojson.Basic.from_file file_name in
    let initialstate = init_state j in

    print_newline ();
    print_endline "Hello! Welcome to Kanu's Adventure Game! I hope you enjoy.";
    print_endline "To start, tell me something to do! I can GO in a direction, TAKE/DROP an item,";
    print_endline "LOOK at the room you're in, check your INVENTORY/INV, check your SCORE, check";
    print_endline "how many TURNS you've made, Or you can just QUIT the game.";
    print_newline ();

    repl initialstate
  )
  with
  | Yojson.Json_error _ -> print_endline "Your JSON Object is incorrect. Please try again";
  | Illegal -> print_newline ();
  | Terminate -> print_endline "Thanks for playing. See you soon."; print_newline (); ()
  | Sys_error _ -> print_endline "Did you enter the correct file name? Try again"; print_newline ()
  | _ -> print_endline "There's something wrong. Try again"; print_newline ()  

