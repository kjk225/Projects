open State
open Game
open Ai
open Player
open Boardbuilder
open Cmdlineboardviewer

let c_to_i c =
  (int_of_char c) - 48

(* a0b0 --> ((0,0),(1,0)) and so on *)
let rec parse_move str =
  if String.length str <> 4 then
    `Invalid
  else
  let x0 = String.get str 0 in
  let y0 = String.get str 1 in
  let x1 = String.get str 2 in
  let y1 = String.get str 3 in
  let valid_idx = fun c -> c >= '0' && c <= '9' in
  if (not (valid_idx x0)) || (not (valid_idx x1)) ||
     (not (valid_idx y0)) || (not (valid_idx y1)) then
    `Invalid
  else
    `Valid (((c_to_i x0),(c_to_i y0)),((c_to_i x1),(c_to_i y1)))

(* Handle parsing for gameplay moves. In this case, the notation is a sequence 
 * of four numbers from 0 to 9 for the x and y coordinates. *)
let rec parse_gameplay b =
  let inp = read_line () in
  match parse_move inp with
  | `Invalid -> begin
    (* Should never happen on the gui, since it should be from 0-9 already *)
    print_endline "Please input with the form xyxy, where x and y are from 0 to 9.";
    parse_gameplay b
  end
  | `Valid(move)  -> begin
    (* Make the player move. If valid, Make the AI move. Otherwise, retry. *)
    match Player.move b move with
    | (b,ValidMove(s)) -> begin
      print_endline s;
      let (ai_board,ai_msg) = Ai.move b in
      print_endline (string_of_ai_msg ai_msg);
      match ai_msg with
      | Normal | AiFW | AiFL | AiTrade -> main (`Gameplay(ai_board))
      | AiWin | AiLose ->
        Cmdlineboardviewer.display_board ai_board;
        main `End
    end
    | (winna,WinningMove) -> begin
      Cmdlineboardviewer.display_board winna;
      main `End
    end
    | (_,InvalidMove) -> begin
      print_endline "The piece you are attempting to move cannot move that way.";
      parse_gameplay b
    end
  end

(* Parse commands for board building. The specification for the functions that
 * can be called from the command line can be found in boardbuilder.ml's help
 * function. *)
and parse_build t:unit =
  let inp = read_line () in
  match Str.(split (regexp "[ \t]+") inp) with
  | [] ->
    failwith "Please do not type newlines."
  | ["finish"] -> begin
    print_endline "Finishing the board building.";
    let my_board = Boardbuilder.finish t in
    main (`Gameplay(my_board))
  end
  | ["add";p;x_str;y_str] -> begin
    let pc = match State.piece_of_string p with
    | ppp -> ppp 
    | exception _ -> begin
      print_endline "Invalid piece name, attempting to add a spy.";
      Spy
    end in 
    try
      let x = int_of_string x_str in
      let y = int_of_string y_str in
      let (t,add_msg) =  (Boardbuilder.add t {position=(x,y);piece=pc}) in
      print_endline (string_of_add_msg add_msg);
      main (`Build t)
    with
      | _ -> begin
        print_endline "Invalid input of some sort, please input real integers.";
        main (`Build t)
      end
  end
  | ["remove";x_str;y_str] -> begin
    try
      let x = int_of_string x_str in
      let y = int_of_string y_str in
      let (t,rem_msg) = (Boardbuilder.remove t (x,y)) in
      print_endline (string_of_rem_msg rem_msg);
      main (`Build(t))
    with
      | _ -> begin
        print_endline "Invalid integer parsing for the two remove arguments.";
        main (`Build t)
      end

  end
  | ["reset"] -> begin
    print_endline "Resetting board building to its initial state.";
    let new_board = Boardbuilder.make () in 
    main (`Build new_board)
  end
  | ["help"]-> begin
    (* TODO: This might not be necessary for the GUI version *)
    print_endline (Boardbuilder.help t);
    parse_build t
  end
  | _ -> begin
    print_endline "Invalid command. Please type \"help\" to see valid commands.";
    parse_build t
  end

(* The introductory state of the program. At this point, you read from standard
 * input until the user types "start" or "s" *)
and parse_beginning () =
  let inp = read_line() in
  match inp with
  | "start" | "s" ->
    main (`Build(Boardbuilder.make ()))
  | _ -> begin
    print_endline "Plz type start"; parse_beginning ()
  end

(* The endgame state of the program. At this point, you read from standard
 * input. If you want to restart the game again, you type restart and you head
 * back to the board building state. If you type exit, you return unit. Input
 * is parsed until either "restart" or "exit" is typed. *)
and parse_end () =
  let inp = read_line () in
  match inp with
  | "exit" -> begin
    print_endline "~~~Goodbye~~~";
    ()
  end
  | "restart" -> begin
    print_endline "Rebuilding the board.";
    main (`Build(Boardbuilder.make ()))
  end
  |  _ -> begin
    print_endline "Please input \"exit\" or \"restart\".";
    parse_end ()
  end

(* The state machine for the program. At this point, you check what state you 
 * are in and acts appropriately based on that input. *)
and main state:unit =
  match state with
  | `Beginning -> begin
    print_endline "Welcome to Stratego! Type \"start\" to begin the game.";
    parse_beginning ()
  end
  | `Build (t) -> begin
    print_endline "Building phase, type help for instructions, or enter a command.";
    Cmdlineboardviewer.display_build (Boardbuilder.to_piece_option_matrix t);
    parse_build t
  end
  | `Gameplay b -> begin
    print_endline ("Type a move of the form \"xyxy\", where x and y are from\n"^
                   "0-9, the first x is the first column, the second x is the\n"^
                   "second column, and so on.");
    Cmdlineboardviewer.display_board b;
    parse_gameplay b
  end
  | `End -> begin
    print_endline ("Congrats, you reached the end. Type exit to exit the game"^
                   " or restart to go back to the board building state.");
    parse_end ()
  end

let () =
  main `Beginning