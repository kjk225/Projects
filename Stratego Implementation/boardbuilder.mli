open State

type add_msg = 
  | SquareOccupied
  | PieceAlreadyUsed
  | IllegalAddSquare
  | ValidAdd

(* [string_of_add_msg m] returns the string representation of an add_msg *)
val string_of_add_msg: add_msg -> string

type rem_msg = 
  | SquareEmpty
  | IllegalRemoveSquare
  | ValidRemove

(* [string_of_rem_msg m] returns the string representation of a rem_msg *)
val string_of_rem_msg: rem_msg -> string

(* This is the interface used to build the board.
 * The player can choose between adding, removing,
 * and finalizing the board in this stage of the game.
 * The player can also ask for help. *)
module Boardbuilder 
: sig

  type t

  (* TODO *)
  val make: unit -> t

  (* [add t (pc,pl)] allows the player to add piece
   * to the bboard. Given the current bboard and placement
   * add will return the new board and message stating the
   * placement was valid or invalid *)
  val add: t -> placement -> (t * add_msg)

  (* [remove b*pl (x*y)] allows player to remove piece
   * from the board. Given the current bboard and placement
   * add will return the new board and message stating the
   * placement on the board was valid or invalid *)
  val remove : t -> position -> (t * rem_msg)

  (* [finish] takes the set of pieces that are left and inserts them into 
   * the matrix in an unspecified order. *)
  val finish : t -> board

  (* [help t] is a message to help the player setup the board*)
  val help: t -> message

  (* [try_build t] is executed when a build is attempted, and fails if it 
   * is not ready to build yet *)
  val ready_to_build : t -> bool

  (* TODO: Docuemnt. this is for printing *)
  val to_piece_option_matrix: t -> piece option array array

end
