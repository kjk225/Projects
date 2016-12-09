open State

module Game : sig
  (* [is_valid board move] is true if a move the 
   * current board is a valid move, otherwise its false *)
  val is_valid: State.board -> State.player -> State.move ->  bool
  
  (* [valid_moves board player] returns the set of valid moves
   * available for that given player. *)
  val valid_moves: State.board -> State.player -> move list 
end