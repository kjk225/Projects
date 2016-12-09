open State

type ai_msg =
  | AiFW
  | AiFL
  | AiTrade
  | AiWin
  | AiLose
  | Normal

val string_of_ai_msg : ai_msg -> string 

(* This is the interface for the AI we will use in Stratego.
 * The AI's main purpose is to execute a move given a board
 * and then return the new board to continue gameplay *)
module Ai :
sig
  (* [move board] returns the board after the AI has made
   * its turn along with the a message stating whether the move
   * was valid or invalid *)
  val move: board -> (board * ai_msg)
end
