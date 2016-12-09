open GMain
open GdkKeysyms
open State

(*ocamlfind ocamlc -g -thread -package lablgtk2 -linkpkg board_gui.ml -o board_gui*)

let locale = GtkMain.Main.init ()

let current_screen = ref MainMenu

let current_piece = ref (Soldier 1) (*current piece being placed during setup*)

let (move1:position option ref) = ref None
let (reset_move:position option)= None
let (move2:position option ref) = ref None
let full_move = ref None
let (reset_full_move:move option) = None
let get_full_move f = !f
let get_move move = match move with | None -> failwith "you should not be getting" |Some (x,y) -> (x,y)

(*placements of pieces on board*)
let (placements:placement array array) = Array.make_matrix 10 4 {piece=Spy; position=(0,0)}

(*number of pieces placed on the board. should be 40 total*)
let pieces_placed = ref 0

let string_of_piece p = 
  match p with
  | Soldier(x) -> string_of_int(x)
  | Flag -> "flag"
  | Bomb -> "bomb"
  | Spy -> "spy"

let string_of_player p = 
  match p with
  |Red -> "red"
  |Blue -> "blue"

(* transorm game coordinates to gui coordinates
                         j:col
  09..........99      i:row 00............09
  .            .            .             .
  .            .            .             .
  00..........90            90............99
      game                        gui
*)

let row_swap n = abs(n - 9)
let game_to_gui (x,y) = (row_swap y, x) 
let gui_to_game (row,column) = (column, row_swap row)

let tile_clicked (i,j) red_shadow =
  print_endline ("square " ^ string_of_int(i) ^ string_of_int(j));
  (match red_shadow#misc#visible with
  |true -> red_shadow#misc#hide ()
  |false ->red_shadow#misc#show ());

  (match !move1 with
  | Some (x,y) -> (match !move2 with 
                |Some (p,q) -> failwith "you didnt reset the move boolean"
                |None -> move2 := Some (i,j));
  | None -> move1 := Some (i,j));

  (if (!move1 <> None) && (!move2 <> None) 
  then (full_move := (Some ((get_move !move1),(get_move !move2))); move1 := reset_move; move2 := reset_move) 
  else ());
  true

let add_piece (i,j) packing  = 
  let (x,y) = gui_to_game (i,j) in
  print_endline ("gui:" ^ string_of_int i ^ string_of_int j ^ " " ^ "game:" ^string_of_int x ^ string_of_int y);
  placements.(x).(y) <- {piece = !current_piece; position = (x,y) };
  let piece_img = GMisc.image ~file:("/Users/kjk225/3110/Stratego/images/red_pieces/" ^ string_of_piece !current_piece ^ ".png") () in
  packing piece_img#coerce;
  incr pieces_placed;
  true

let make_mainmenu ~packing =
  let mainmenu = GPack.hbox ~packing () in 
  let main_img = GMisc.image ~file:"/Users/kjk225/3110/Stratego/images/mainmenu.png" () in (*CHANGE*)
  mainmenu#pack main_img#coerce;
  mainmenu#misc#show ();
  mainmenu

let make_helpscreen ~packing =
  let helpscreen= GPack.hbox ~packing () in 
  let instructions = GMisc.image ~file:"/Users/kjk225/3110/Stratego/images/rules.png" () in
  helpscreen#pack instructions#coerce;
  helpscreen#misc#hide ();
  helpscreen

let make_winscreen ~packing winner = 
  let winscreen = GPack.hbox ~packing () in
  let redwins = GMisc.image ~file:"/Users/kjk225/3110/Stratego/images/redwins.png" () in
  let bluewins = GMisc.image ~file:"/Users/kjk225/3110/Stratego/images/bluewins.png" () in
  (match winner with
  | Red -> winscreen#add redwins#coerce
  | Blue -> winscreen#add bluewins#coerce);
  winscreen#misc#hide ();
  winscreen


let setup_gameboard ~packing =
  let setup_board = GPack.fixed ~packing () in 
  let setup_img = GMisc.image ~file:"/Users/kjk225/3110/Stratego/images/setup_bkg.png" () in setup_board#put ~x:(0) ~y:(0) setup_img#coerce;
  let boardholder = GPack.hbox ~width:695 ~height:695 ~packing: (setup_board#put ~x:(0) ~y:(0)) () in
  let boardframe = GBin.frame ~packing:(boardholder#pack) () in
  let hbox = GPack.hbox ~packing:(boardframe#add) () in
  let fixed = GPack.fixed ~packing:(hbox#pack) () in
  (*setup top of board*)
  for i = 0 to 3 do
    for j = 0 to 9 do
      let squareij = GBin.frame ~width:70 ~height:70 ~packing:(fixed#put ~x:(j * 70 - j) ~y:(i * 70 - i)) () in
      let imagecontainer = GPack.fixed ~packing:squareij#add () in
      let bg_file = "/Users/kjk225/Downloads/boardbckg [www.imagesplitter.net]/boardbckg [www.imagesplitter.net]-" ^ string_of_int(i) ^ "-" ^ string_of_int(j) ^ ".jpeg" in
      let tile = GMisc.image ~file:bg_file () in
      let piece_img = GMisc.image ~file:"/Users/kjk225/3110/Stratego/images/blue_pieces/blue_back.png" () in
      imagecontainer#put ~x:(0) ~y:(0) tile#coerce;
      imagecontainer#put ~x:(1) ~y:(1) piece_img#coerce;
    done
  done;

  for i = 4 to 5 do
    for j = 0 to 9 do
    (* if you are on a lake ... *)
    if (j=2 || j=3 || j=6 || j=7)
    then () (*do nothing*)
    else
      let squareij = GBin.frame ~width:70 ~height:70 ~packing:(fixed#put ~x:(j * 70 - j) ~y:(i * 70 - i)) () in
      let imagecontainer = GPack.fixed ~packing:squareij#add () in
      let bg_file = "/Users/kjk225/Downloads/boardbckg [www.imagesplitter.net]/boardbckg [www.imagesplitter.net]-" ^ string_of_int(i) ^ "-" ^ string_of_int(j) ^ ".jpeg" in
      let tile = GMisc.image ~file:bg_file () in
      imagecontainer#put ~x:(0) ~y:(0) tile#coerce;
    done
  done;

  (*add lake tiles to the board*)
  let lake_l = GBin.frame ~width:140 ~height:140 ~packing:(fixed#put ~x:(138) ~y:(276)) () in
  let lake_r = GBin.frame ~width:140 ~height:140 ~packing:(fixed#put ~x:(414) ~y:(276)) () in
  let l_img = "/Users/kjk225/Downloads/boardbckg [www.imagesplitter.net] (1)/left.jpeg" in
  let r_img = "/Users/kjk225/Downloads/boardbckg [www.imagesplitter.net] (1)/right.jpeg" in
  let tilel = GMisc.image ~file:l_img () in
  let tiler = GMisc.image ~file:r_img () in
  lake_l#add tilel#coerce;
  lake_r#add tiler#coerce;

  (*setup bottom of board...requires user input*)
  for i = 6 to 9 do
    for j = 0 to 9 do
      (* initialize every square to an eventbox *)
      let squareij = GBin.frame ~width:70 ~height:70 ~packing:(fixed#put ~x:(j * 70 - j) ~y:(i * 70 - i)) () in
      let event_box = GBin.event_box ~packing:squareij#add () in
      let imagecontainer = GPack.fixed ~packing:event_box#add () in
      (*add background image, and red shadows to every tile*)
      let bg_file = "/Users/kjk225/Downloads/boardbckg [www.imagesplitter.net]/boardbckg [www.imagesplitter.net]-" ^ string_of_int(i) ^ "-" ^ string_of_int(j) ^ ".jpeg" in
      let tile = GMisc.image ~file:bg_file () in
      imagecontainer#put ~x:(0) ~y:(0) tile#coerce;
      event_box#event#add [`BUTTON_PRESS];
      ignore (event_box#event#connect#button_press ~callback: (fun _ -> (add_piece (i,j) (imagecontainer#put ~x:(1) ~y:(1)) )));
      event_box#misc#realize ();
      Gdk.Window.set_cursor event_box#misc#window (Gdk.Cursor.create `HAND1);
    done
  done;
  setup_board#misc#hide ();
  setup_board

let handle_key current_state winner screens k =
  let (holder,mainmenu,helpscreen) = screens in 
  let key = GdkEvent.Key.keyval k in 
  match !current_screen with
  |MainMenu -> (match key with
               | 115|83 (*s*) -> (let setup_board = setup_gameboard ~packing:holder#add in setup_board#misc#show (); current_screen := SetupScreen; current_state := Start; mainmenu#misc#hide (); helpscreen#misc#hide ())
               | 114|82 (*r*)-> (current_screen := HelpScreen; helpscreen#misc#show (); mainmenu#misc#hide ())
               | 113|81 (*q*)-> (current_state :=  EndGame; GMain.Main.quit ()) 
               | _ -> ());true

  |HelpScreen -> (match key with
                  | 98|66 (*b*)-> (current_screen := MainMenu; mainmenu#misc#show (); helpscreen#misc#hide () ) (*switch back mainscreen*)
                  | _ -> ()); true

  (*at setup screen, the only keys that matter are the ones that correspond to the pieces to setup, 1-9, s, b, f*)
  |SetupScreen -> (match key with
                  | 49 -> current_piece := Soldier 1
                  | 50 -> current_piece := Soldier 2
                  | 51 -> current_piece := Soldier 3
                  | 52 -> current_piece := Soldier 4
                  | 53 -> current_piece := Soldier 5
                  | 54 -> current_piece := Soldier 6
                  | 55 -> current_piece := Soldier 7
                  | 56 -> current_piece := Soldier 8
                  | 57 -> current_piece := Soldier 9
                  | 115|83 -> current_piece := Spy
                  | 98|66 -> current_piece := Bomb
                  | 70|102 -> current_piece := Flag
                  | 65293 (*enter*) -> if !pieces_placed = 40 
                                      then (current_screen := GameScreen; (current_state := GamePlay);)
                                      else () 
                  | _ -> ()); true

  |GameScreen -> (); true

  |WinScreen -> (match key with
                | 115|83 (*s*) -> (current_screen := MainMenu; (current_state := BoardBuilding)) 
                | 113|81 -> ((current_state := EndGame); GMain.Main.quit ()) 
                | _ -> ());true


let play_board current_state board ~packing =
  let gameboard = GPack.fixed ~packing () in
  let main_img = GMisc.image ~file:"/Users/kjk225/3110/Stratego/images/mainbkg.jpg" () in 
  gameboard#put ~x:(0) ~y:(0) main_img#coerce;
  let boardholder = GPack.hbox ~width:695 ~height:695 ~packing: (gameboard#put ~x:(0) ~y:(0)) () in
  let boardframe = GBin.frame ~packing:(boardholder#pack) () in
  let hbox = GPack.hbox ~packing:(boardframe#add) () in
  let fixed = GPack.fixed ~packing:(hbox#pack) () in
  let current_board = board.board_state in
  (for i = 0 to 9 do
    (for j = 0 to 9 do
    (* if you are on a lake ... *)
    if ((i = 4 || i = 5) && (j=2 || j=3 || j=6 || j=7))
    then 
      let (x,y) = gui_to_game (i,j) in
      current_board.(x).(y) <- Lake;
    else
      (* initialize every square*)
      let (x,y) = gui_to_game (i,j) in 
      let squarexy = GBin.frame ~width:70 ~height:70 ~packing:(fixed#put ~x:(y * 70 - y) ~y:(x * 70 - x)) () in
      let event_box = GBin.event_box ~packing:squarexy#add () in
      let imagecontainer = GPack.fixed ~packing:event_box#add () in
      let bg_file = "/Users/kjk225/Downloads/boardbckg [www.imagesplitter.net]/boardbckg [www.imagesplitter.net]-" ^ string_of_int(i) ^ "-" ^ string_of_int(j) ^ ".jpeg" in
      let tile = GMisc.image ~file:bg_file () in
      imagecontainer#put ~x:(0) ~y:(0) tile#coerce;
      (match current_board.(x).(y) with
      | Empty -> ()
      | Occupied (cpiece, player, blue_visible) ->
        (match player with
        |Blue -> if blue_visible 
                 then
                  let piece_img = GMisc.image ~file:("/Users/kjk225/3110/Stratego/images/blue_pieces/" ^ string_of_piece cpiece ^ ".png") () in
                  imagecontainer#put ~x:(1) ~y:(1) piece_img#coerce;
                 else 
                  let piece_img = GMisc.image ~file:("/Users/kjk225/3110/Stratego/images/blue_pieces/blue_back.png") () in
                  imagecontainer#put ~x:(1) ~y:(1) piece_img#coerce;

        |Red -> let piece_img = GMisc.image ~file:("/Users/kjk225/3110/Stratego/images/red_pieces/" ^ string_of_piece cpiece ^ ".png") () in
                imagecontainer#put ~x:(1) ~y:(1) piece_img#coerce;);
        
      | Lake -> failwith "gui lake coordinates do not match with game lake coordinates");

      let red_shadow_img =  GMisc.image ~file:"/Users/kjk225/3110/Stratego/red_shadow.png" () in
      let red_shadow = red_shadow_img#coerce in
      imagecontainer#put ~x:(0) ~y:(0) red_shadow;
      red_shadow#misc#hide ();
      event_box#event#add [`BUTTON_PRESS];
      ignore (event_box#event#connect#button_press ~callback:(fun _ -> (tile_clicked (i,j) red_shadow)));
      event_box#misc#realize ();
      Gdk.Window.set_cursor event_box#misc#window (Gdk.Cursor.create `HAND1);
    done)
  done); 
  gameboard#misc#hide ();
  gameboard

(*-------------------------------MAIN*)
let main current_state board winner () =
  let window = GWindow.window ~title:"Stratego" ~width:1000 ~height:695 ~resizable:false () in
  let holder = GPack.hbox ~packing:window#add () in 
  let mainmenu = make_mainmenu ~packing:holder#add  in
  let helpscreen = make_helpscreen ~packing:holder#add  in
  (*let winscreen = make_winscreen ~packing:holder#add in*)
  (*let gameboard = play_board current_state board ~packing:holder#add in *)
  (*you dont have playboard*)
  let screens = (holder, mainmenu, helpscreen) in 
  ignore (window#event#connect#key_press ~callback:(fun k -> (handle_key current_state winner screens k)));
  ignore (window#connect#destroy ~callback:GMain.Main.quit);
  window#show ();
  GMain.Main.main ()

let _ = Printexc.print main (ref Start) ({board_state = (Array.make_matrix 10 4 Empty); turn = 0 ; player_to_move = Red}) Red ()